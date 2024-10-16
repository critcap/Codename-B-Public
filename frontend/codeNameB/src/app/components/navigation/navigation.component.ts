import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { NavigationEnd, Router, RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { NavigationRoute } from '../../models/NavigationRoute';
import { NavigationService } from '../../services/navigation.service';
import { SUCCESS_TIME } from '../../static/SnackBarValues';
import { UtilsService } from '../../services/utils.service';

@Component({
  selector: 'app-navigation',
  standalone: true,
  imports: [RouterModule, CommonModule],
  templateUrl: './navigation.component.html',
  styleUrl: './navigation.component.scss',
})
export class NavigationComponent {
  public isOpen: boolean = false;

  constructor(
    private router: Router,
    private navigationService: NavigationService,
    private authService: AuthService,
    private utilityService: UtilsService,
  ) {
    this.router.events.subscribe((event) => {
      if (event instanceof NavigationEnd) {
        this.closeMobileNavigation();
      }
    });
  }

  get currentRoute(): string {
    return this.navigationService.getCurrentRoute();
  }

  get currentRoutes(): NavigationRoute[] {
    return this.navigationService.getCurrentRoutes();
  }

  isCurrentRoute(path: string): boolean {
    return this.navigationService.isCurrentRoute(path);
  }

  logout(): void {
    this.authService.deleteCurrentAuthentication();
    this.utilityService.openSnackbarThenRouteToLandingPage(
      'Sie wurden abgemeldet!',
      'success',
      SUCCESS_TIME,
    );
    this.navigationService.reloadAllRoutes();
  }

  openMobileNavigation(): void {
    this.isOpen = true;
  }

  closeMobileNavigation(): void {
    this.isOpen = false;
  }
}
