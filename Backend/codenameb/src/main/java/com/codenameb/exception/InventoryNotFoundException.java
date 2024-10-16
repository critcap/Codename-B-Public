package com.codenameb.exception;

public class InventoryNotFoundException extends RuntimeException {
  public InventoryNotFoundException(Long inventoryId) {
    super("Inventar mit der Id " + inventoryId + " wurde nicht gefunden.");
  }
}
