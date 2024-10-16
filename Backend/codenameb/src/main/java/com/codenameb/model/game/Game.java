package com.codenameb.model.game;

import com.codenameb.model.User;
import com.codenameb.model.inventory.ShopItem;
import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Game {
  @Id @GeneratedValue private Long id;
  private boolean win;
  private int defeatedEnemies;
  private int surviveTime;
  private int levelReached;
  private int gold;
  private int score;

  @ManyToMany(fetch = FetchType.EAGER)
  @JoinTable(
      name = "game_items",
      joinColumns = {@JoinColumn(name = "game_id")},
      inverseJoinColumns = {@JoinColumn(name = "shop_item_id")})
  private List<ShopItem> itemsUsed;

  @OneToOne(cascade = CascadeType.ALL)
  @JoinColumn(name = "game_start_parameters_id", referencedColumnName = "id")
  private GameStartParameters gameStartParameters;

  @ManyToOne(fetch = FetchType.EAGER, cascade = CascadeType.DETACH)
  @JoinColumn(name = "user_id", nullable = false)
  @JsonBackReference
  private User user;
}
