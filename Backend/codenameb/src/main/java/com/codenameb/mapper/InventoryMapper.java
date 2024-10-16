package com.codenameb.mapper;

import com.codenameb.dto.GetInventoryDto;
import com.codenameb.model.inventory.Inventory;
import org.mapstruct.Mapper;
import java.util.List;

@Mapper(componentModel = "spring")
public interface InventoryMapper {
  GetInventoryDto toGetInventoryDto(Inventory inventory);

  Inventory toInventory(GetInventoryDto getInventoryDto);

  List<Inventory> toInventories(List<GetInventoryDto> getInventoryDtos);

  List<GetInventoryDto> toGetInventoryDtos(List<Inventory> inventories);
}
