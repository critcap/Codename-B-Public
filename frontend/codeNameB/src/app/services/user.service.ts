import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { AuthService } from './auth.service';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class UserService {
  private apiUrl: string = 'http://localhost:8080/api/v1/users';

  constructor(
    private http: HttpClient,
    private authService: AuthService,
  ) {}

  public getCurrentUser(): Observable<any> {
    return this.http.get(this.apiUrl.concat('/current'), {
      headers: {
        Authorization: 'Bearer '.concat(this.authService.getAuthToken() || ''),
      },
    });
  }

  public getAllUsers(): Observable<any> {
    return this.http.get(this.apiUrl, {
      headers: {
        Authorization: 'Bearer '.concat(this.authService.getAuthToken() || ''),
      },
    });
  }

  public getUserById(id: number): Observable<any> {
    return this.http.get(this.apiUrl.concat(`/${id}`), {
      headers: {
        Authorization: 'Bearer '.concat(this.authService.getAuthToken() || ''),
      },
    });
  }

  public getAllGames(id: number): Observable<any> {
    return this.http.get(this.apiUrl.concat(`/${id}/games`), {
      headers: {
        Authorization: 'Bearer '.concat(this.authService.getAuthToken() || ''),
      },
    });
  }
}
