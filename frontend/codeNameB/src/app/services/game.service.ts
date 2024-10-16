import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { AuthService } from './auth.service';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class GameService {
  private readonly apiUrl = 'http://localhost:8080/api/v1/games';

  constructor(
    private http: HttpClient,
    private auth: AuthService,
  ) {}

  public getAllGames(): Observable<any> {
    return this.http.get(this.apiUrl, {});
  }
}
