import { Component, EventEmitter, Input, Output } from '@angular/core';
import { GameStartParameters } from '../../models/GameStartParameters';
import { Defaults } from '../../models/Defaults';
import { DefaultService } from '../../services/default.service';
import { ShopItem } from '../../models/ShopItem';
import { InventoryService } from '../../services/inventory.service';
import { UserService } from '../../services/user.service';
import { User } from '../../models/User';
import { Inventory } from '../../models/Inventory';
import { Difficulty } from '../../models/Difficulty';
import { Map } from '../../models/Map';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-selection',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './selection.component.html',
  styleUrl: './selection.component.scss',
})
export class SelectionComponent {
  private userInventory: Inventory = new Inventory(0, 0, []);

  @Output()
  public selectStartParameters: EventEmitter<GameStartParameters> =
    new EventEmitter<GameStartParameters>();

  public availableCharacters: ShopItem[] = [];
  public defaults: Defaults = new Defaults([], []);

  public selectedCharacter: ShopItem = new ShopItem(
    0,
    '',
    '',
    '',
    0,
    '',
    '',
    0,
    false,
  );
  public selectedDifficulty: Difficulty = new Difficulty(0, '', '');
  public selectedMap: Map = new Map(0, '', '', '');

  constructor(
    private defaultService: DefaultService,
    private inventoryService: InventoryService,
    private userService: UserService,
  ) {
    this.getDefaults();
    this.userService.getCurrentUser().subscribe({
      next: (user: User) => {
        this.userInventory = user.inventory;
        this.getAvailableCharacters(user.inventory.id);
      },
      error: (err: any) => {
        console.log('Error getting current User: ', err);
      },
    });
  }

  getDefaults(): void {
    this.defaultService.getAllDefaults().subscribe({
      next: (defaults: Defaults) => {
        this.defaults = defaults;
      },
      error: (err: any) => {
        console.log('Error getting default items!', err);
      },
    });
  }

  getAvailableCharacters(inventoryId: number): void {
    this.inventoryService.getAvailableCharacters(inventoryId).subscribe({
      next: (chars: ShopItem[]) => {
        this.availableCharacters = chars;
      },
      complete: () => {
        this.setDefaultSelectionsAfterLoad();
      },
      error: (err: any) => {
        console.log('Error getting available chars: ', err);
      },
    });
  }

  setDefaultSelectionsAfterLoad(): void {
    this.setDifficulty(1);
    this.setMap(1);
    this.setCharacter(this.availableCharacters[0].id);
  }

  setCharacter(charId: number): void {
    this.availableCharacters.filter((char: ShopItem) => {
      if (charId == char.id) {
        this.selectedCharacter = char;
      }
      return charId == char.id;
    });
  }

  setMap(mapId: number): void {
    this.defaults.maps.filter((map: Map) => {
      if (mapId == map.id) {
        this.selectedMap = map;
      }
      return mapId == map.id;
    });
  }

  setDifficulty(diffId: number): void {
    this.defaults.difficulties.filter((difficulty: Difficulty) => {
      if (diffId == difficulty.id) {
        this.selectedDifficulty = difficulty;
      }
      return diffId == difficulty.id;
    });
  }

  submitSelectedData(): void {
    this.selectStartParameters.emit(
      new GameStartParameters(
        this.selectedCharacter,
        this.selectedMap,
        this.selectedDifficulty,
        this.userInventory.items,
      ),
    );
  }
}
