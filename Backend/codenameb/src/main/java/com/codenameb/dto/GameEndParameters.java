package com.codenameb.dto;

import com.codenameb.model.inventory.ShopItem;
import java.util.List;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GameEndParameters {
  private boolean win;
  private int defeatedEnemies;
  private int surviveTime;
  private int levelReached;
  private int gold;
  private int score;
  private List<ShopItem> itemsUsed;
}
