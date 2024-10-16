import { Injectable } from '@angular/core';
import { ShopItem } from '../models/ShopItem';
import { AuthService } from './auth.service';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ItemService {
  private baseUrl: string = 'http://localhost:8080/api/v1/items';

  constructor(
    private http: HttpClient,
    private authService: AuthService,
  ) {}

  public getAllShopItems(): Observable<any> {
    return this.http.get(this.baseUrl, {
      headers: {
        Authorization: 'Bearer '.concat(this.authService.getAuthToken() || ''),
      },
    });
  }

  public getShopItemById(id: number): Observable<any> {
    return this.http.get(this.baseUrl.concat(`/${id}`), {
      headers: {
        Authorization: 'Bearer '.concat(this.authService.getAuthToken() || ''),
      },
    });
  }

  public buyShopItem(shopItem: ShopItem): Observable<any> {
    return this.http.post(this.baseUrl.concat('/buy'), shopItem, {
      headers: {
        Authorization: 'Bearer '.concat(this.authService.getAuthToken() || ''),
      },
    });
  }
}
