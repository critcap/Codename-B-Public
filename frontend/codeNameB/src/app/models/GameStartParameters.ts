import { Difficulty } from './Difficulty';
import { Map } from './Map';
import { ShopItem } from './ShopItem';

export class GameStartParameters {
  constructor(
    public character: ShopItem,
    public map: Map,
    public difficulty: Difficulty,
    public items: ShopItem[],
  ) {}
}
