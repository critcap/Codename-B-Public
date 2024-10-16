import { Injectable } from '@angular/core';
import { NavigationEnd, Router } from '@angular/router';
import { routes } from '../app.routes';
import { AuthService } from './auth.service';
import { NavigationRoute } from '../models/NavigationRoute';
import { titlePrefix } from '../app.routes';

@Injectable({
  providedIn: 'root',
})
export class NavigationService {
  private route: string = '';
  private excludedPaths: string[] = ['forgot-password', 'reset-password'];
  private skipRoutingOnAuthentication: string[] = ['/login', '/register'];
  private navigationRoutes: NavigationRoute[] = [];

  constructor(
    private router: Router,
    private authService: AuthService,
  ) {
    this.reloadAllRoutes();
    this.setupEventListeners();
  }

  public getCurrentRoute(): string {
    return this.route;
  }

  public getCurrentRoutes(): NavigationRoute[] {
    return this.navigationRoutes;
  }

  public isCurrentRoute(route: string): boolean {
    if ((route === '' || route === '/') && window.location.pathname === '/') {
      return true;
    }

    if (route === '' || route === '/') {
      return false;
    }

    return window.location.pathname.includes(route);
  }

  public reloadAllRoutes(): void {
    this.navigationRoutes = [];
    routes.forEach((route) => {
      const path: string = route.path ?? '';
      let name: string = '';
      let hasChildren: boolean = false;
      const children: { path: string; name: string }[] = [];

      if (typeof route.title === 'string') {
        name = route.title;
      }

      if (route.children) {
        hasChildren = true;
        route.children.forEach((child) => {
          const childName: string = child.title?.toString() ?? '';
          if (typeof route.title === 'string') {
            name = route.title;
          }

          children.push({
            path: child.path ?? '',
            name: childName.replace(titlePrefix, ''),
          });
        });
      }

      if (!this.excludedPaths.includes(path)) {
        this.navigationRoutes.push(
          new NavigationRoute(
            path,
            name.replace(titlePrefix, ''),
            hasChildren,
            children,
          ),
        );
      }
    });

    if (
      this.authService.hasAuthentication() &&
      !this.authService.authTokenIsExpired() &&
      !this.authService.refreshTokenIsExpired()
    ) {
      this.removeLoginAndRegisterNavigation();
      this.addLogoutNavigation();
    }
  }

  private removeLoginAndRegisterNavigation(): void {
    let loginIndex = 0;
    this.navigationRoutes.forEach((route: NavigationRoute, index: number) => {
      if (route.name === 'Login') {
        loginIndex = index;
      }
    });
    this.navigationRoutes.splice(loginIndex, 2);
  }

  private addLogoutNavigation(): void {
    this.navigationRoutes.push(
      new NavigationRoute('logout', 'Logout', false, []),
    );
  }

  private setupEventListeners(): void {
    this.router.events.subscribe((event) => {
      if (event instanceof NavigationEnd) {
        // Skip routing for given paths if already logged in
        if (
          this.skipRoutingOnAuthentication.includes(window.location.pathname) &&
          this.authService.hasAuthentication() &&
          !this.authService.authTokenIsExpired() &&
          !this.authService.refreshTokenIsExpired()
        ) {
          this.router.navigate(['/game']);
        }

        this.navigationRoutes.forEach((route) => {
          if (this.isCurrentRoute(route.path)) {
            this.route = route.name;
          }
        });

        // Re-Init Routes
        this.navigationRoutes = [];
        this.reloadAllRoutes();
      }
    });
  }
}
