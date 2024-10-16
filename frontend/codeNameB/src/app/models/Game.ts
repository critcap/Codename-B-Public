import { GameStartParameters } from './GameStartParameters';
import { ShopItem } from './ShopItem';
import { User } from './User';

export interface Game {
  id: number;
  win: boolean;
  defeatedEnemies: number;
  surviveTime: number;
  levelReached: number;
  gold: number;
  score: number;
  itemsUsed: ShopItem[];
  gameStartParameters: GameStartParameters;
  user: User;
}
