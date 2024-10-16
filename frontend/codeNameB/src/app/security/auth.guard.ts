import { Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { AuthService } from '../services/auth.service';
import { ApiService } from '../services/api.service';
import { UtilsService } from '../services/utils.service';
import { WARNING_TIME } from '../static/SnackBarValues';

@Injectable({
  providedIn: 'root',
})
export class AuthGuard {
  constructor(
    private authService: AuthService,
    private apiService: ApiService,
    private utilityService: UtilsService,
  ) {}

  canActivate(
    next: ActivatedRouteSnapshot,
    state: RouterStateSnapshot,
  ): boolean {
    return this.authenticationIsActive();
  }

  canActivateChild(
    next: ActivatedRouteSnapshot,
    state: RouterStateSnapshot,
  ): boolean {
    return this.authenticationIsActive();
  }

  authenticationIsActive(): boolean {
    const authTokenExpired = this.authService.authTokenIsExpired();
    const refreshTokenExpired = this.authService.refreshTokenIsExpired();
    if (authTokenExpired) {
      if (!refreshTokenExpired) {
        this.refreshTokenAndSave();
        return true;
      }
      this.removeAuthenticationAndRouteToLandingpage();
      return false;
    }
    return true;
  }

  refreshTokenAndSave(): void {
    const refreshToken = this.authService.getRefreshToken();
    if (refreshToken) {
      this.apiService.refreshToken(refreshToken).subscribe({
        next: (response: { access_token: string; refresh_token: string }) => {
          this.authService.setAuthentication({
            access_token: response.access_token,
            refresh_token: response.refresh_token,
          });
        },
        error: (error) => {
          this.removeAuthenticationAndRouteToLandingpage();
        },
      });
    } else {
      this.removeAuthenticationAndRouteToLandingpage();
    }
  }

  removeAuthenticationAndRouteToLandingpage(): void {
    this.authService.deleteCurrentAuthentication();
    this.utilityService.openSnackbarThenRouteToLandingPage(
      'Sie müssen eingeloggt sein, um diese Seite sehen zu können!',
      'warning',
      WARNING_TIME,
    );
  }
}
