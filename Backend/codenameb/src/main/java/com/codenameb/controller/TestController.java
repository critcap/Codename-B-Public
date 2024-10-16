package com.codenameb.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

  @GetMapping("/hello")
  public ResponseEntity<String> getMethodName() {
    return ResponseEntity.ok("this is a secure Endpoint");
  }
}
