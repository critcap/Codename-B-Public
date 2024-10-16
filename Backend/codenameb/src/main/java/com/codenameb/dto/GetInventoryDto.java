package com.codenameb.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class GetInventoryDto {
  private Long id;
  private int credits;
  private List<ShopItemDto> items;
}
