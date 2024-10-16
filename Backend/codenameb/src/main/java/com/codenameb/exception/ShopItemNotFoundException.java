package com.codenameb.exception;

public class ShopItemNotFoundException extends RuntimeException {
  public ShopItemNotFoundException(Long shopItemId) {
    super("ShopItem mit der Id " + shopItemId + " wurde nicht gefunden.");
  }
}
