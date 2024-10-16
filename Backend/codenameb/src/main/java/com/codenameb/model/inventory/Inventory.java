package com.codenameb.model.inventory;

import com.codenameb.model.User;
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
public class Inventory {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  private Long id;

  @Column(nullable = false)
  private int credits;

  @ManyToMany(fetch = FetchType.EAGER)
  @JoinTable(
      name = "shop_items_inventory",
      joinColumns = {@JoinColumn(name = "inventory_id")},
      inverseJoinColumns = {@JoinColumn(name = "shop_item_id")})
  List<ShopItem> items;

  @JsonIgnore
  @OneToOne(fetch = FetchType.EAGER, cascade = CascadeType.ALL, mappedBy = "inventory")
  private User user;
}
