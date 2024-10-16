import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ApiService {
  private readonly apiUrl = 'http://localhost:8080/api/v1/auth';

  constructor(private http: HttpClient) {}

  registerUser(userDetails: any): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/register`, userDetails);
  }

  loginUser(userDetails: any): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/authenticate`, userDetails);
  }

  refreshToken(refreshToken: string): Observable<any> {
    return this.http.post<any>(
      `${this.apiUrl}/refresh-token`,
      {},
      {
        headers: {
          Authorization: `Bearer ${refreshToken}`,
        },
      },
    );
  }

  forgotPassword(email: string): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/forgot-password`, { email });
  }

  resetPassword(token: string, newPassword: string): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/reset-password`, {
      token,
      newPassword,
    });
  }
}
