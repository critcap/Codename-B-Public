package com.codenameb.dto;

import com.codenameb.model.inventory.ItemType;
import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ShopItemDto {
  private Long id;
  private String name;
  private String identifier;
  private String description;
  private Long price;
  private String imageName;
  private ItemType itemType;
  private int maxBuyCount;
  private boolean shopable;
}
