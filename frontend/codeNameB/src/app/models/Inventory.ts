import { ShopItem } from './ShopItem';

export class Inventory {
  constructor(
    public id: number,
    public credits: number,
    public items: ShopItem[],
  ) {}
}
