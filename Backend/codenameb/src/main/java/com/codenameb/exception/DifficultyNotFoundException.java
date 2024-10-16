package com.codenameb.exception;

public class DifficultyNotFoundException extends RuntimeException {
  public DifficultyNotFoundException(String identifier) {
    super("Die Schwierigkeit mit dem Identifer " + identifier + " konnte nicht gefunden werden!");
  }
}
