package com.codenameb.controller;

import com.codenameb.model.authentication.AuthenticationRequest;
import com.codenameb.model.authentication.AuthenticationResponse;
import com.codenameb.model.authentication.RegisterRequest;
import com.codenameb.service.AuthenticationService;
import com.codenameb.service.PasswordResetService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import java.io.IOException;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/auth")
public class AuthenticationController {

  private final AuthenticationService authenticationService;
  private final PasswordResetService passwordResetService;

  @PostMapping("/register")
  public ResponseEntity<AuthenticationResponse> register(
      @RequestBody @Valid RegisterRequest request) {
    return authenticationService.register(request);
  }

  @PostMapping("/authenticate")
  public ResponseEntity<AuthenticationResponse> authenticate(
      @RequestBody AuthenticationRequest request) {
    return ResponseEntity.ok(authenticationService.authenticate(request));
  }

  @PostMapping("/refresh-token")
  public void refreshToken(HttpServletRequest request, HttpServletResponse response)
      throws IOException {
    authenticationService.refreshToken(request, response);
  }

  @PostMapping("/forgot-password")
  public ResponseEntity<Map<String, String>> forgotPassword(
      @RequestBody Map<String, String> request) {
    String email = request.get("email");
    try {
      passwordResetService.generatePasswordResetToken(email);
      Map<String, String> response =
          Map.of("message", "Password reset link has been sent to your email.");
      return ResponseEntity.ok(response);
    } catch (IllegalArgumentException e) {
      Map<String, String> response = Map.of("error", e.getMessage());
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    } catch (Exception e) {
      Map<String, String> response = Map.of("error", "An error occurred while sending the email.");
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }
  }

  @PostMapping("/reset-password")
  public ResponseEntity<Map<String, String>> resetPassword(
      @RequestBody Map<String, String> request) {
    String token = request.get("token");
    String newPassword = request.get("newPassword");
    try {
      passwordResetService.resetPassword(token, newPassword);
      Map<String, String> response = Map.of("message", "Password successfully reset.");
      return ResponseEntity.ok(response);
    } catch (IllegalArgumentException e) {
      Map<String, String> response = Map.of("error", e.getMessage());
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    } catch (Exception e) {
      Map<String, String> response =
          Map.of("error", "An error occurred while resetting the password.");
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }
  }
}
