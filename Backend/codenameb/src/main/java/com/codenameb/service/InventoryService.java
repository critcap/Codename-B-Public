package com.codenameb.service;

import com.codenameb.dto.GetInventoryDto;
import com.codenameb.dto.ShopItemDto;
import com.codenameb.exception.InventoryNotFoundException;
import com.codenameb.exception.ShopItemNotFoundException;
import com.codenameb.exception.UserNotFoundException;
import com.codenameb.mapper.InventoryMapper;
import com.codenameb.model.User;
import com.codenameb.model.inventory.Inventory;
import com.codenameb.model.inventory.ItemType;
import com.codenameb.model.inventory.ShopItem;
import com.codenameb.repository.InventoryRespository;
import com.codenameb.repository.ItemRepository;
import com.codenameb.repository.UserRepository;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class InventoryService {
  private final InventoryRespository inventoryRespository;
  private final ItemRepository itemRepository;
  private final UserRepository userRepository;
  private final InventoryMapper inventoryMapper;

  public Inventory addItemToInventoryById(Long inventoryId, Long shopItemId) {
    Optional<Inventory> inventoryOptional = this.inventoryRespository.findById(inventoryId);
    Optional<ShopItem> shopItemOptional = this.itemRepository.findById(shopItemId);

    if (inventoryOptional.isEmpty()) {
      throw new InventoryNotFoundException(inventoryId);
    }

    if (shopItemOptional.isEmpty()) {
      throw new ShopItemNotFoundException(shopItemId);
    }

    Inventory inventory = inventoryOptional.get();
    ShopItem shopItem = shopItemOptional.get();
    List<ShopItem> inventoryItems = inventory.getItems();
    inventoryItems.add(shopItem);
    inventory.setItems(inventoryItems);
    return this.inventoryRespository.save(inventory);
  }

  public List<GetInventoryDto> getAllInventories() {
    List<Inventory> allInventories = this.inventoryRespository.findAll();
    return this.inventoryMapper.toGetInventoryDtos(allInventories);
  }

  public GetInventoryDto getInventoryByUserId(Long userId) {
    Optional<User> userOptional = this.userRepository.findById(userId);
    if (userOptional.isEmpty()) {
      throw new UserNotFoundException(userId);
    }
    return this.inventoryMapper.toGetInventoryDto(userOptional.get().getInventory());
  }

  public GetInventoryDto getInventoryByInventoryId(Long inventoryId) {
    Optional<Inventory> inventoryOptional = this.inventoryRespository.findById(inventoryId);
    if (inventoryOptional.isEmpty()) {
      throw new InventoryNotFoundException(inventoryId);
    }
    return this.inventoryMapper.toGetInventoryDto(inventoryOptional.get());
  }

  public Inventory spentCredits(Long inventoryId, int itemPrice) {
    Optional<Inventory> inventoryOptional = this.inventoryRespository.findById(inventoryId);
    if (inventoryOptional.isEmpty()) {
      throw new InventoryNotFoundException(inventoryId);
    }
    Inventory inventory = inventoryOptional.get();
    inventory.setCredits(inventory.getCredits() - itemPrice);
    return this.inventoryRespository.save(inventory);
  }

  public Inventory earnCredits(Long inventoryId, int earnedCredits) {
    Optional<Inventory> inventoryOptional = this.inventoryRespository.findById(inventoryId);
    if (inventoryOptional.isEmpty()) {
      throw new InventoryNotFoundException(inventoryId);
    }
    Inventory inventory = inventoryOptional.get();
    inventory.setCredits(inventory.getCredits() + earnedCredits);
    return this.inventoryRespository.save(inventory);
  }

  public List<ShopItemDto> getAllAvailableCharacters(Long inventoryId) {
    List<ShopItemDto> chars = new ArrayList<>();
    GetInventoryDto inventoryDto = this.getInventoryByInventoryId(inventoryId);
    for (ShopItemDto shopItemDto : inventoryDto.getItems()) {
      if (shopItemDto.getItemType() == ItemType.ITEM_PLAYER) {
        chars.add(shopItemDto);
      }
    }
    return chars;
  }
}
