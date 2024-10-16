import { Router } from '@angular/router';
import { Injectable, computed, signal } from '@angular/core';
import { AuthService } from './auth.service';
import { WebSocketSubject, webSocket } from 'rxjs/webSocket';
import { EMPTY, Subject, catchError, retry, throwError, timer } from 'rxjs';
import { socketRes } from '../models/socketRes';
import { GameStartParameters } from '../models/GameStartParameters';
import { ShopItem } from '../models/ShopItem';
import { Map } from '../models/Map';
import { Difficulty } from '../models/Difficulty';

const NUMBER_OF_TRY = 5;

@Injectable({
  providedIn: 'root',
})
export class WebsocketService {
  public initial: boolean = true;
  public doneLoading: Subject<boolean> = new Subject<boolean>();
  private readonly targetOrigin: string = 'http://localhost:8080';
  private readonly socketUrl: string = 'ws://localhost:8080/socket';
  private readonly ACTION_RECEIVE_GODOT_ID: string = 'SEND_SESSION_ID';
  private readonly ACTION_RELOAD_IDS: string = 'RELOAD_IDS';
  private readonly ACTION_GAME_START: string = 'POST_GAME';
  private readonly ACTION_GAME_END: string = 'GAME_END';
  private socket$!: WebSocketSubject<any>;
  private messagesSubject$ = new Subject<any>();
  private sessionIdSignal = signal<string>('');
  private godotSessionIdSignal = signal<string>('');

  private socketRequestSessionId = computed<socketRes>(() => {
    return {
      action: 'GET_SESSION_ID',
      token: this.auth.accessToken(),
      fromUser: '',
    };
  });

  private gameStartParams: GameStartParameters = new GameStartParameters(
    new ShopItem(0, '', '', '', 0, '', 'ITEM_PLAYER', 0, false),
    new Map(0, '', '', ''),
    new Difficulty(0, '', ''),
    [],
  );
  private gameStartParameterSignal = signal<GameStartParameters>(
    this.gameStartParams,
  );
  private socketRequestGameStart = computed<socketRes>(() => {
    return {
      action: this.ACTION_GAME_START,
      token: this.auth.accessToken(),
      fromUser: this.sessionIdSignal(),
      toUser: this.godotSessionIdSignal(),
      gameStartParameters: this.gameStartParameterSignal(),
    };
  });

  public messages$ = this.messagesSubject$.pipe(
    catchError((e) => {
      console.error('an error occured', e);
      return EMPTY;
    }),
  );

  constructor(
    private router: Router,
    private auth: AuthService,
  ) {
    if (!this.socket$) {
      this.connect();

      if (this.auth.accessToken()) {
        this.getSessionIDAfterLogin();
      }
    }

    this.messagesSubject$.subscribe({
      next: (message: socketRes) => this.handleMessage(message),
      error: (err) => {},
    });
  }

  public reloadGodotSession(): void {
    setTimeout(() => {
      this.sendDataToGodotBridge(
        this.sessionIdSignal(),
        this.auth.accessToken(),
      );
    }, 5000);
  }

  public setGameStartParams(startParams: GameStartParameters): void {
    this.gameStartParameterSignal.set(startParams);
  }

  private async getSessionIDAfterLogin(): Promise<void> {
    await this.sendMessageToSocket(this.socketRequestSessionId());
  }

  public async postGame(): Promise<void> {
    await this.sendMessageToSocket(this.socketRequestGameStart());
  }

  // GODOT BRIDGE FUNCTIONS
  private sendDataToGodotBridge(fromUser: string, token: string) {
    const iframe = document.getElementById('godotIframe') as HTMLIFrameElement;
    if (iframe && iframe.contentWindow) {
      iframe.contentWindow.postMessage(
        {
          token: token,
          session_id: fromUser,
        },
        this.targetOrigin,
      );
      this.initial = false;
    }
  }

  // DEFAULT SOCKET FUNCTIONS
  private connect(): void {
    this.socket$ = webSocket(this.socketUrl);

    const reconnect$ = this.socket$.pipe(
      retry({
        count: NUMBER_OF_TRY,
        delay: (error: Error, retryCount) => {
          console.log(
            'connection failed retrying for the:',
            retryCount,
            'times',
            error,
          );
          return timer(2000);
        },
      }),
      catchError((error) => {
        console.error(
          'Failed to connect after retries:',
          error,
          'refresh the page for trying again',
        );
        return throwError(() => error);
      }),
    );

    reconnect$.subscribe({
      next: (message: socketRes) => {
        return this.messagesSubject$.next(message);
      },
      error: (error) => console.error('WebSocket error!', error),
      complete: () => console.log('Completed!'),
    });
  }

  private handleMessage(message: socketRes): void {
    if (message.action == 'response_id_created') {
      this.sessionIdSignal.set(message.fromUser!);
      setTimeout(() => {
        this.sendDataToGodotBridge(message.fromUser!, message.token!);
      }, 5000);
    }

    if (message.action == this.ACTION_RECEIVE_GODOT_ID) {
      if (message.fromUser && message.toUser == this.sessionIdSignal()) {
        this.godotSessionIdSignal.set(message.fromUser);
        this.doneLoading.next(true);
      }
    }

    if (
      message.action == this.ACTION_GAME_END &&
      message.fromUser == this.godotSessionIdSignal() &&
      message.toUser == this.sessionIdSignal()
    ) {
      console.log('GAME IS OVER!');
      this.router.navigate(['/game/history']);
    }
  }

  // this should be first called for Authetication after login
  async sendMessageToSocket(msg: socketRes): Promise<void> {
    if (this.socket$) {
      this.socket$.next(msg);
    } else {
      console.error('WebSocket is not initialized!');
    }
  }
}
