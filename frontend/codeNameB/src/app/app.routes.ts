import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { RegisterComponent } from './pages/register/register.component';
import { LandingpageComponent } from './pages/landing-page/landing-page.component';
import { AuthGuard } from './security/auth.guard';
import { LoginComponent } from './pages/login/login.component';
import { LayoutComponent } from './pages/game/layout/layout.component';
import { GamepageComponent } from './pages/game/game-page/game-page.component';
import { ShopPageComponent } from './pages/game/shop-page/shop-page.component';
import { ForgotPasswordComponent } from './pages/forgot-password/forgot-password.component';
import { ResetPasswordComponent } from './pages/reset-password/reset-password.component';
import { GameHistoryComponent } from './pages/game/game-history/game-history.component';
import { GameLeaderboardComponent } from './pages/game/game-leaderboard/game-leaderboard.component';

export const titlePrefix: string = 'CodenameB | ';
const webRoutes: Routes = [
  {
    path: '',
    component: LandingpageComponent,
    title: titlePrefix.concat('Willkommen'),
  },
  {
    path: 'login',
    component: LoginComponent,
    title: titlePrefix.concat('Login'),
  },
  {
    path: 'register',
    component: RegisterComponent,
    title: titlePrefix.concat('Registrierung'),
  },
  {
    path: 'forgot-password',
    component: ForgotPasswordComponent,
    title: titlePrefix.concat('Passwort vergessen'),
  },
  {
    path: 'reset-password',
    component: ResetPasswordComponent,
    title: titlePrefix.concat('Passwort zurücksetzen'),
  },
  {
    path: 'leaderboard',
    component: GameLeaderboardComponent,
    title: titlePrefix.concat('Leaderboard'),
  },
];

const gameRoutes: Routes = [
  {
    path: 'game',
    component: LayoutComponent,
    title: titlePrefix.concat('Spielbereich'),
    canActivate: [AuthGuard],
    canActivateChild: [AuthGuard],
    children: [
      {
        path: 'codenameb',
        component: GamepageComponent,
        title: titlePrefix.concat('Spiel'),
      },
      {
        path: 'shop',
        component: ShopPageComponent,
        title: titlePrefix.concat('Shop'),
      },
      {
        path: 'history',
        component: GameHistoryComponent,
        title: titlePrefix.concat('Historie'),
      },
    ],
  },
];

export const routes: Routes = [...webRoutes, ...gameRoutes];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
