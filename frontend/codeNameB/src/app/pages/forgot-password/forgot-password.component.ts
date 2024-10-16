import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';
import { UtilsService } from '../../services/utils.service';
import { SUCCESS_TIME, ERROR_TIME } from '../../static/SnackBarValues';
import { of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [FormsModule, CommonModule],
  templateUrl: './forgot-password.component.html',
  styleUrl: './forgot-password.component.scss',
})
export class ForgotPasswordComponent {
  email: string = '';

  constructor(
    private apiService: ApiService,
    private utilsService: UtilsService,
  ) {}

  onSubmit() {
    this.apiService
      .forgotPassword(this.email)
      .pipe(
        catchError((error) => {
          console.error('Fehler erhalten:', error);
          const errorMessage =
            error.error?.error ||
            'Es ist ein Fehler aufgetreten. Bitte versuchen Sie es später erneut.';
          this.utilsService.openSnackbar(errorMessage, 'error', ERROR_TIME);
          return of(null);
        }),
      )
      .subscribe((response) => {
        if (response && response.message) {
          console.log('Antwort erhalten:', response);
          this.utilsService.openSnackbar(
            response.message,
            'success',
            SUCCESS_TIME,
          );
        }
      });
  }
}
