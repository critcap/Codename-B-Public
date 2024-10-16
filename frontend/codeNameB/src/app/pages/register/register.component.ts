import { Component } from '@angular/core';
import {
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Router } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { AuthService } from '../../services/auth.service';
import {
  ERROR_TIME,
  SUCCESS_TIME,
  WARNING_TIME,
} from '../../static/SnackBarValues';
import { UtilsService } from '../../services/utils.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss',
})
export class RegisterComponent {
  constructor(
    private apiService: ApiService,
    private authService: AuthService,
    private router: Router,
    private utilityService: UtilsService,
  ) {}

  registerForm = new FormGroup({
    firstName: new FormControl('', Validators.required),
    lastName: new FormControl('', Validators.required),
    userName: new FormControl('', Validators.required),
    email: new FormControl('', [Validators.required, Validators.email]),
    password: new FormControl('', [Validators.min(8), Validators.required]),
    passwordRepeat: new FormControl('', [
      Validators.min(8),
      Validators.required,
    ]),
    role: new FormControl('PLAYER', Validators.required),
  });

  onSubmitForm() {
    if (!this.registerForm.valid) {
      this.utilityService.openSnackbar(
        'Bitte füllen Sie alle Pflichtfelder korrekt aus!',
        'warning',
        WARNING_TIME,
      );
      return;
    }

    if (
      this.registerForm.value.password !==
      this.registerForm.value.passwordRepeat
    ) {
      this.utilityService.openSnackbar(
        'Ihre Passwörter stimmen nicht überein!',
        'warning',
        WARNING_TIME,
      );
      return;
    }

    const { ['passwordRepeat']: removedKey, ...userDetails } =
      this.registerForm.value;
    this.apiService.registerUser(userDetails).subscribe({
      next: (response) => {
        this.authService.setAuthentication({
          access_token: response.access_token,
          refresh_token: response.refresh_token,
        });
        this.router.navigate(['/game']).then(() => {
          this.utilityService.openSnackbar(
            'Sie haben sich erfolgreich registriert!',
            'success',
            SUCCESS_TIME,
          );
        });
      },
      error: (error) => {
        console.log('Warning: ', error);
        this.utilityService.openSnackbar(
          'Registrierung fehlgeschlagen!',
          'error',
          ERROR_TIME,
        );
      },
    });
  }
}
