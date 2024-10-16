import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { AuthService } from './auth.service';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class InventoryService {
  private readonly apiUrl = 'http://localhost:8080/api/v1/inventories';

  constructor(
    private http: HttpClient,
    private auth: AuthService,
  ) {}

  public getAvailableCharacters(id: number): Observable<any> {
    return this.http.get(this.apiUrl.concat(`/${id}/characters`), {
      headers: {
        Authorization: 'Bearer '.concat(this.auth.getAuthToken() || ''),
      },
    });
  }

  public getInventoryById(id: number): Observable<any> {
    return this.http.get(this.apiUrl.concat(`/${id}`), {
      headers: {
        Authorization: 'Bearer '.concat(this.auth.getAuthToken() || ''),
      },
    });
  }
}
