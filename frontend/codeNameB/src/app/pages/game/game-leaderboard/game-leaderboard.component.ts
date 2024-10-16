import { Component } from '@angular/core';
import { GameService } from '../../../services/game.service';
import { Game } from '../../../models/Game';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { SecondsToMinutesPipe } from '../../../pipes/seconds-to-minutes.pipe';

@Component({
  selector: 'app-game-leaderboard',
  standalone: true,
  imports: [CommonModule, MatIconModule, SecondsToMinutesPipe],
  templateUrl: './game-leaderboard.component.html',
  styleUrl: './game-leaderboard.component.scss',
})
export class GameLeaderboardComponent {
  private games: Game[] = [];
  private columnSorting: string = 'place';
  public displayedGames: Game[] = [];

  constructor(private gameService: GameService) {
    this.gameService.getAllGames().subscribe((games: Game[]) => {
      console.log('Games: ', games);
      this.games = games;
      this.sort();
    });
  }

  public get sortIdentifier(): string {
    return this.columnSorting;
  }

  public getPlace(gameId: number): number {
    return (
      this.games.indexOf(
        this.games.filter((game: Game) => game.id == gameId)[0],
      ) + 1
    );
  }

  public setSortingType(sortingType: string): void {
    if (this.columnSorting == sortingType) {
      this.columnSorting = 'place';
    } else {
      this.columnSorting = sortingType;
    }
    this.sort();
  }

  private sort(): void {
    switch (this.columnSorting) {
      case 'place':
        this.displayedGames = this.games;
        break;
      case 'name':
        this.displayedGames = [...this.games].sort(this.compareByName);
        break;
      case 'score':
        this.displayedGames = [...this.games].sort(this.compareByScore);
        break;
      case 'gold':
        this.displayedGames = [...this.games].sort(this.compareByGold);
        break;
      case 'time':
        this.displayedGames = [...this.games].sort(this.compareByTime);
        break;
      case 'wave':
        this.displayedGames = [...this.games].sort(this.compareByWave);
        break;
      case 'kills':
        this.displayedGames = [...this.games].sort(this.compareByKills);
        break;
      default:
        this.displayedGames = this.games;
    }
  }

  // Sorting Game comparator
  private compareByKills(gameA: Game, gameB: Game): number {
    if (gameA.defeatedEnemies > gameB.defeatedEnemies) {
      return -1;
    }
    if (gameA.defeatedEnemies < gameB.defeatedEnemies) {
      return 1;
    }
    return 0;
  }

  private compareByName(gameA: Game, gameB: Game): number {
    return gameA.user.firstname.localeCompare(gameB.user.firstname);
  }

  private compareByScore(gameA: Game, gameB: Game): number {
    if (gameA.score > gameB.score) {
      return -1;
    }
    if (gameA.score < gameB.score) {
      return 1;
    }
    return 0;
  }

  private compareByGold(gameA: Game, gameB: Game): number {
    if (gameA.gold > gameB.gold) {
      return -1;
    }
    if (gameA.gold < gameB.gold) {
      return 1;
    }
    return 0;
  }

  private compareByTime(gameA: Game, gameB: Game): number {
    if (gameA.surviveTime > gameB.surviveTime) {
      return -1;
    }
    if (gameA.surviveTime < gameB.surviveTime) {
      return 1;
    }
    return 0;
  }

  private compareByWave(gameA: Game, gameB: Game): number {
    if (gameA.levelReached > gameB.levelReached) {
      return -1;
    }
    if (gameA.levelReached < gameB.levelReached) {
      return 1;
    }
    return 0;
  }
}
