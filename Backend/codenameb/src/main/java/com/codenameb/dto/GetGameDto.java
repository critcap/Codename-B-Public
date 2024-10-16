package com.codenameb.dto;

import com.codenameb.model.game.GameStartParameters;
import com.codenameb.model.inventory.ShopItem;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GetGameDto {
  private Long id;
  private boolean win;
  private int defeatedEnemies;
  private int surviveTime;
  private int levelReached;
  private int gold;
  private int score;
  private List<ShopItem> itemsUsed;
  private GameStartParameters gameStartParameters;
  private GetUserDto user;
}
