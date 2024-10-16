package com.codenameb.model.inventory;

import com.codenameb.model.game.Game;
import com.codenameb.model.game.GameStartParameters;
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
public class ShopItem {
  @Id @GeneratedValue private Long id;

  @Column(nullable = false, unique = true)
  private String identifier;

  @Column(nullable = false)
  private String name;

  @Column(nullable = false, length = 1024)
  private String description;

  @Column(nullable = false)
  private Long price;

  @Column(nullable = false)
  private String imageName;

  @Column(nullable = false)
  private ItemType itemType;

  @Column(nullable = false)
  private int maxBuyCount;

  @Column(nullable = false)
  private boolean shopable;

  @JsonIgnore
  @ManyToMany(fetch = FetchType.EAGER, cascade = CascadeType.ALL, mappedBy = "items")
  private List<Inventory> inventories;

  @JsonIgnore
  @ManyToMany(fetch = FetchType.EAGER, cascade = CascadeType.ALL, mappedBy = "itemsUsed")
  private List<Game> games;

  @JsonIgnore
  @ManyToMany(fetch = FetchType.EAGER, mappedBy = "items", cascade = CascadeType.ALL)
  private List<GameStartParameters> gameStartParameters;
}
