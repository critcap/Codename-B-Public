package com.codenameb.controller;

import com.codenameb.dto.GetInventoryDto;
import com.codenameb.dto.ShopItemDto;
import com.codenameb.model.inventory.ShopItem;
import com.codenameb.service.ItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/items")
public class ItemController {

  private final ItemService itemService;

  @GetMapping
  public ResponseEntity<List<ShopItem>> getAllItems() {
    return ResponseEntity.ok(itemService.getAllItems());
  }

  @PostMapping("/buy")
  public ResponseEntity<GetInventoryDto> buyItem(@RequestBody ShopItemDto shopItemDto) {
    GetInventoryDto item = this.itemService.buyShopItem(shopItemDto);
    return ResponseEntity.ok(item);
  }
}
