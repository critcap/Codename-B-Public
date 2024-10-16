import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { Router, RouterModule } from '@angular/router';
import { GamepageComponent } from '../game-page/game-page.component';
import { ShopPageComponent } from '../shop-page/shop-page.component';
import { GameHistoryComponent } from '../game-history/game-history.component';
import { UserService } from '../../../services/user.service';
import { User } from '../../../models/User';
import { Inventory } from '../../../models/Inventory';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [RouterModule, RouterModule, CommonModule],
  templateUrl: './layout.component.html',
  styleUrl: './layout.component.scss',
})
export class LayoutComponent {
  private currentUser: User = new User(
    -1,
    '',
    '',
    '',
    '',
    new Inventory(0, 0, []),
    '',
  );

  constructor(
    private router: Router,
    private userService: UserService,
  ) {
    this.userService.getCurrentUser().subscribe({
      next: (user: User) => {
        this.currentUser = user;
      },
      error: (error: any) => {
        console.log('Error getting current user!');
      },
    });
  }

  select(link: string): void {
    this.router.navigate([link]);
  }

  onActivate(
    component: GamepageComponent | ShopPageComponent | GameHistoryComponent,
  ): void {
    if (
      component instanceof ShopPageComponent ||
      component instanceof GameHistoryComponent
    ) {
      component.user = this.currentUser;
    }
  }
}
