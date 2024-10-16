package com.codenameb.exception;

public class NotAbleToBuyException extends RuntimeException {
  public NotAbleToBuyException(Long itemId) {
    super("Es tut mir leid aber Sie können das Item mit der id" + itemId + " nicht erwerben.");
  }
}
