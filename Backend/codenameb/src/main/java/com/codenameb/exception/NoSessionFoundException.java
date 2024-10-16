package com.codenameb.exception;

public class NoSessionFoundException extends RuntimeException {
  public NoSessionFoundException(String sessionId) {
    super("No valid session was found with session-id: " + sessionId);
  }
}
