import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root',
})
export class DefaultService {
  private readonly apiUrl = 'http://localhost:8080/api/v1/defaults';

  constructor(
    private http: HttpClient,
    private auth: AuthService,
  ) {}

  public getAllDefaults(): Observable<any> {
    return this.http.get(this.apiUrl, {
      headers: {
        Authorization: 'Bearer '.concat(this.auth.getAuthToken() || ''),
      },
    });
  }
}
