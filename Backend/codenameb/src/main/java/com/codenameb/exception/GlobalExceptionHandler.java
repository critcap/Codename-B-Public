package com.codenameb.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

  @ExceptionHandler(UserAlreadyExistsException.class)
  public ResponseEntity<Object> handleUserAlreadyExistsException(UserAlreadyExistsException ex) {
    return ResponseEntity.status(HttpStatus.CONFLICT).body(ex.getMessage());
  }

  @ExceptionHandler(AuditorNotFoundException.class)
  public ResponseEntity<Object> handleAuditorNotFoundException(AuditorNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
  }

  @ExceptionHandler(DefaultItemNotFoundException.class)
  public ResponseEntity<Object> handleDefaultItemNotFoundException(
      DefaultItemNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
  }

  @ExceptionHandler(InventoryNotFoundException.class)
  public ResponseEntity<Object> handleInventoryNotFoundException(InventoryNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
  }

  @ExceptionHandler(NotAbleToBuyException.class)
  public ResponseEntity<Object> handleNotAbleToBuyException(NotAbleToBuyException ex) {
    return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ex.getMessage());
  }

  @ExceptionHandler(ShopItemNotFoundException.class)
  public ResponseEntity<Object> handleShopItemNotFoundException(ShopItemNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
  }

  @ExceptionHandler(UserNotFoundException.class)
  public ResponseEntity<Object> handleUserNotFoundException(UserNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
  }

  @ExceptionHandler(NoSessionFoundException.class)
  public ResponseEntity<Object> handleNoSessionFoundException(NoSessionFoundException ex) {
    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(ex.getMessage());
  }

  @ExceptionHandler(DifficultyNotFoundException.class)
  public ResponseEntity<Object> handleDifficultyNotFoundException(DifficultyNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
  }
}
