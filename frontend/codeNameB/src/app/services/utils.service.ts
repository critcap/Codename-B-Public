import { Injectable, Injector } from '@angular/core';
import {
  MatSnackBar,
  MatSnackBarVerticalPosition,
} from '@angular/material/snack-bar';
import { SnackbarComponent } from '../components/snackbar/snackbar.component';
import { Router } from '@angular/router';
import { NavigationService } from './navigation.service';

@Injectable({
  providedIn: 'root',
})
export class UtilsService {
  constructor(
    public router: Router,
    public snackBar: MatSnackBar,
    private injector: Injector,
  ) {}

  public openSnackbar(
    data: string,
    snackType: string = 'success',
    duration: number = 10000,
    verticalPosition: MatSnackBarVerticalPosition = 'top',
  ) {
    this.snackBar.openFromComponent(SnackbarComponent, {
      data,
      panelClass: 'snackbar-'.concat(snackType),
      duration,
      verticalPosition,
    });
  }

  openSnackbarThenRouteToLandingPage(
    message: string,
    type: string,
    duration: number,
  ): void {
    const navigationService: NavigationService =
      this.injector.get(NavigationService);
    if (navigationService.getCurrentRoute() === 'Home') {
      navigationService.reloadAllRoutes();
    }
    this.router
      .navigate(['/'])
      .then(() => this.openSnackbar(message, type, duration));
  }
}
