package com.codenameb.service;

import com.codenameb.dto.GetInventoryDto;
import com.codenameb.dto.ShopItemDto;
import com.codenameb.exception.AuditorNotFoundException;
import com.codenameb.exception.NotAbleToBuyException;
import com.codenameb.mapper.InventoryMapper;
import com.codenameb.model.User;
import com.codenameb.model.inventory.ShopItem;
import com.codenameb.repository.InventoryRespository;
import com.codenameb.repository.ItemRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ItemService {
  private final ItemRepository itemRepository;
  private final InventoryRespository inventoryRespository;
  private final InventoryService inventoryService;
  private final InventoryMapper inventoryMapper;

  public List<ShopItem> getAllItems() {
    return this.itemRepository.findAll();
  }

  public GetInventoryDto buyShopItem(ShopItemDto itemToBuy) {
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    if (authentication == null
        || !authentication.isAuthenticated()
        || authentication instanceof AnonymousAuthenticationToken) {
      throw new AuditorNotFoundException(
          "Der aktuelle Auditor konnte leider nicht gefunden werden!");
    }

    User userPrincipal = (User) authentication.getPrincipal();
    GetInventoryDto currentInventory =
        this.inventoryService.getInventoryByUserId(userPrincipal.getId());
    List<ShopItemDto> currentInventoryItems = currentInventory.getItems();

    if (!this.isAbleToBuy(itemToBuy, currentInventoryItems, currentInventory.getCredits())) {
      throw new NotAbleToBuyException(itemToBuy.getId());
    }

    // Spent money after isAbleToBuy check
    int itemAmount = this.getItemAmount(itemToBuy.getId(), currentInventoryItems);
    Long itemPrice = this.calculatePrice(itemToBuy, itemAmount);
    currentInventory.setCredits(currentInventory.getCredits() - itemPrice.intValue());

    // Add new Items to inventory
    currentInventoryItems.add(itemToBuy);
    currentInventory.setItems(currentInventoryItems);

    return this.inventoryMapper.toGetInventoryDto(
        this.inventoryRespository.save(this.inventoryMapper.toInventory(currentInventory)));
  }

  private boolean isAbleToBuy(
      ShopItemDto itemToBuy, List<ShopItemDto> currentInventoryItems, int availableCredits) {
    List<ShopItem> allItems = this.itemRepository.findAll();
    for (ShopItem boughtItem : allItems) {
      if (boughtItem.getId().equals(itemToBuy.getId())) {
        int itemAmount = this.getItemAmount(boughtItem.getId(), currentInventoryItems);
        Long itemPrice = this.calculatePrice(itemToBuy, itemAmount);
        return availableCredits >= itemPrice && itemToBuy.getMaxBuyCount() > itemAmount;
      }
    }
    return false;
  }

  private int getItemAmount(Long id, List<ShopItemDto> items) {
    int amount = 0;
    for (ShopItemDto item : items) {
      if (id.equals(item.getId())) {
        amount += 1;
      }
    }
    return amount;
  }

  private Long calculatePrice(ShopItemDto shopItemDto, int itemAmount) {
    if (itemAmount == 0) {
      return shopItemDto.getPrice();
    }
    return (long) Math.floor(itemAmount * shopItemDto.getPrice() * 2.5);
  }
}
