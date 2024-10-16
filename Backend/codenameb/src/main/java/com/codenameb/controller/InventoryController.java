package com.codenameb.controller;

import com.codenameb.dto.GetInventoryDto;
import com.codenameb.dto.ShopItemDto;
import com.codenameb.service.InventoryService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/inventories")
public class InventoryController {

    private final InventoryService inventoryService;

    @GetMapping
    public ResponseEntity<List<GetInventoryDto>> getAllInventories() {
        List<GetInventoryDto> allInventories = this.inventoryService.getAllInventories();
        return ResponseEntity.ok(allInventories);
    }

    @GetMapping("/{id}")
    public ResponseEntity<GetInventoryDto> getInventoryById(@PathVariable Long id) {
        GetInventoryDto inventory = this.inventoryService.getInventoryByUserId(id);
        return ResponseEntity.ok(inventory);
    }

    @GetMapping("/{id}/characters")
    public ResponseEntity<List<ShopItemDto>> getAllCharactersAvailable(@PathVariable Long id) {
        List<ShopItemDto> chars = this.inventoryService.getAllAvailableCharacters(id);
        return ResponseEntity.ok(chars);
    }
}
