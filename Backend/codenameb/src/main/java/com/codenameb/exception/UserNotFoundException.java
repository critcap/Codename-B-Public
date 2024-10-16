package com.codenameb.exception;

public class UserNotFoundException extends RuntimeException {
  public UserNotFoundException(Long userId) {
    super("Der Benutzer mit der Id" + userId + " konnte nicht gefunden werden.");
  }
}
