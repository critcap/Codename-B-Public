import { Component, Input } from '@angular/core';
import { User } from '../../../models/User';
import { Router } from '@angular/router';
import { UserService } from '../../../services/user.service';
import { Game } from '../../../models/Game';
import { CommonModule } from '@angular/common';
import { ShopItem } from '../../../models/ShopItem';
import { MatIconModule } from '@angular/material/icon';
import { SecondsToMinutesPipe } from '../../../pipes/seconds-to-minutes.pipe';

@Component({
  selector: 'app-game-history',
  standalone: true,
  imports: [CommonModule, MatIconModule, SecondsToMinutesPipe],
  templateUrl: './game-history.component.html',
  styleUrl: './game-history.component.scss',
})
export class GameHistoryComponent {
  @Input()
  public user?: User;
  public games?: Game[];
  public toggledDetails: number = -1;
  public page: number = 1;
  public availablePages: number = 0;
  public GAMES_PER_PAGE: number = 5;

  constructor(
    private router: Router,
    private userSerivce: UserService,
  ) {}

  ngOnInit(): void {
    if (this.user!.id == -1) {
      this.router.navigate(['/game']);
    }

    this.userSerivce.getAllGames(this.user!.id).subscribe({
      next: (games: Game[]) => {
        this.games = games;
        this.availablePages = Math.ceil(
          this.games.length / this.GAMES_PER_PAGE,
        );
      },
      error: (error: any) => {
        console.log('Couldnt get games for user ', this.user!.id);
      },
    });
  }

  public toggleGameDetail(id: number): void {
    // Toggle details
    if (this.toggledDetails == id) {
      this.toggledDetails = -1;
    } else {
      this.toggledDetails = id;
    }
  }

  public getFilteredItems(items: ShopItem[]): ShopItem[] {
    let foundIds: number[] = [];
    return items.filter((item: ShopItem) => {
      if (item.itemType == 'ITEM_PLAYER' || foundIds.includes(item.id)) {
        return false;
      }
      foundIds.push(item.id);
      return true;
    });
  }

  public getAmountOfItem(itemId: number, items: ShopItem[]): number {
    return items.filter((item: ShopItem) => itemId == item.id).length;
  }

  public nextPage(): void {
    this.page++;
    console.log('Page: ', this.page);
  }

  public previousPage(): void {
    this.page--;
    console.log('Page: ', this.page);
  }

  public get gamesOnPage(): Game[] {
    const end = this.page * this.GAMES_PER_PAGE;
    const start = end - this.GAMES_PER_PAGE;
    if (this.games != undefined) {
      return this.games.slice(start, end);
    }
    return [];
  }
}
