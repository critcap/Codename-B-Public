import { Inventory } from './Inventory';

export class User {
  constructor(
    public id: number,
    public firstname: string,
    public lastname: string,
    public username: string,
    public email: string,
    public inventory: Inventory,
    public role: string,
  ) {}
}
