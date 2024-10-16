package com.codenameb.exception;

public class DefaultItemNotFoundException extends RuntimeException {
  public DefaultItemNotFoundException() {
    super("Es tut mir leid aber das Standarditem 'Aurelius' konnte nicht gefunden werden!");
  }
}
