import { Component } from '@angular/core';
import { FormsModule, NgForm } from '@angular/forms';
import { ApiService } from '../../services/api.service';
import { ActivatedRoute, Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { UtilsService } from '../../services/utils.service';
import { SUCCESS_TIME, ERROR_TIME } from '../../static/SnackBarValues';
import { catchError } from 'rxjs/operators';
import { of } from 'rxjs';

@Component({
  selector: 'app-reset-password',
  standalone: true,
  imports: [FormsModule, CommonModule],
  templateUrl: './reset-password.component.html',
  styleUrls: ['./reset-password.component.scss'],
})
export class ResetPasswordComponent {
  newPassword: string = '';
  confirmPassword: string = '';
  token: string | null = null;

  passwordPattern: RegExp =
    /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[ !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~])(?=\S+$).{8,}$/;

  constructor(
    private route: ActivatedRoute,
    private apiService: ApiService,
    private router: Router,
    private utilsService: UtilsService,
  ) {}

  ngOnInit(): void {
    this.token = this.route.snapshot.queryParamMap.get('token');
  }

  onSubmit(form: NgForm) {
    if (!this.passwordPattern.test(this.newPassword)) {
      this.utilsService.openSnackbar(
        'Ungültiges Passwort. Bitte beachten Sie die Anforderungen.',
        'error',
        ERROR_TIME,
      );
      return;
    }

    if (this.newPassword !== this.confirmPassword) {
      this.utilsService.openSnackbar(
        'Passwörter stimmen nicht überein.',
        'error',
        ERROR_TIME,
      );
      return;
    }

    if (this.token) {
      this.apiService
        .resetPassword(this.token, this.newPassword)
        .pipe(
          catchError((error) => {
            console.error('Fehler erhalten:', error);
            const errorMessage =
              error.error?.message ||
              'Es ist ein Fehler aufgetreten. Bitte versuchen Sie es später erneut.';
            this.utilsService.openSnackbar(errorMessage, 'error', ERROR_TIME);
            return of(null);
          }),
        )
        .subscribe((response) => {
          if (response && response.message) {
            this.utilsService.openSnackbar(
              response.message,
              'success',
              SUCCESS_TIME,
            );
            setTimeout(() => {
              this.router.navigate(['/login']); // Weiterleitung zur Login-Seite
            }, SUCCESS_TIME);
          }
        });
    } else {
      this.utilsService.openSnackbar(
        'Ungültiges Passwort-Reset-Token.',
        'error',
        ERROR_TIME,
      );
    }
  }
}
