package com.codenameb.mapper;

import com.codenameb.dto.ShopItemDto;
import com.codenameb.model.inventory.ShopItem;
import java.util.List;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ItemMapper {
  ShopItem toShopItem(ShopItemDto shopItemDto);

  ShopItemDto toShopItemDto(ShopItem shopItem);

  List<ShopItemDto> toShopItemDtos(List<ShopItem> items);
}
