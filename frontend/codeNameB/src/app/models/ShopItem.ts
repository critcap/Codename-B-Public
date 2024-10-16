export class ShopItem {
  constructor(
    public id: number,
    public name: string,
    public identifier: string,
    public description: string,
    public price: number,
    public imageName: string,
    public itemType: string,
    public maxBuyCount: number,
    public shopable: boolean,
  ) {}
}
