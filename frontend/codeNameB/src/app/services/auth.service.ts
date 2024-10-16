import { Injectable, signal } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  public accessToken = signal<string>(this.getAuthToken() || '');

  private getAuthentication(): {
    access_token: string;
    refresh_token: string;
    timestamp: Date;
  } {
    return JSON.parse(window.localStorage.getItem('authentication') || '{}');
  }

  public setAuthentication(authentication: {
    access_token: string;
    refresh_token: string;
  }): void {
    this.accessToken.set(authentication.access_token);
    window.localStorage.setItem(
      'authentication',
      JSON.stringify({
        ...authentication,
        timestamp: new Date(),
      }),
    );
  }

  public getAuthToken(): string | null {
    const authentication: {
      access_token: string;
      refresh_token: string;
      timestamp: Date;
    } = this.getAuthentication();
    return authentication.access_token;
  }

  public hasAuthentication(): boolean {
    const authenticationToken = this.getAuthToken();
    if (authenticationToken) {
      return true;
    }
    return false;
  }

  public authTokenIsExpired(): boolean {
    const auth_token = this.getAuthToken();
    const payload = auth_token?.split('.')[1];
    if (payload == null) {
      return true;
    }
    const decodedToken = atob(payload);
    const tokenObject: { exp: number; iat: number; sub: string } =
      JSON.parse(decodedToken);
    if (tokenObject.exp * 1000 < Date.now()) {
      return true;
    }
    return false;
  }

  public getRefreshToken(): string | null {
    const authentication: {
      access_token: string;
      refresh_token: string;
      timestamp: Date;
    } = this.getAuthentication();
    return authentication.refresh_token;
  }

  public refreshTokenIsExpired(): boolean {
    const refresh_token = this.getRefreshToken();
    const payload = refresh_token?.split('.')[1];
    if (payload == null) {
      return true;
    }
    const decodedToken = atob(payload);
    const tokenObject: { exp: number; iat: number; sub: string } =
      JSON.parse(decodedToken);

    if (tokenObject.exp * 1000 < Date.now()) {
      return true;
    }
    return false;
  }

  public deleteCurrentAuthentication(): void {
    window.localStorage.removeItem('authentication');
  }
}
