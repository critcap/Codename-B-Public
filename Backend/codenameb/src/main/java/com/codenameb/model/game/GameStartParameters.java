package com.codenameb.model.game;

import com.codenameb.model.defaults.Difficulty;
import com.codenameb.model.defaults.Map;
import com.codenameb.model.inventory.ShopItem;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
public class GameStartParameters {
  @Id @GeneratedValue private Long id;

  @ManyToOne private ShopItem character;

  @ManyToOne private Map map;

  @ManyToOne private Difficulty difficulty;

  @ManyToMany(fetch = FetchType.EAGER)
  @JoinTable(
      name = "game_start_parameter_items",
      joinColumns = {@JoinColumn(name = "game_start_parameter_id")},
      inverseJoinColumns = {@JoinColumn(name = "shop_item_id")})
  private List<ShopItem> items;

  @JsonIgnore
  @OneToOne(mappedBy = "gameStartParameters")
  private Game game;
}
