package com.codenameb.service;

import com.codenameb.config.JwtService;
import com.codenameb.exception.DefaultItemNotFoundException;
import com.codenameb.exception.UserAlreadyExistsException;
import com.codenameb.model.*;
import com.codenameb.model.authentication.*;
import com.codenameb.model.inventory.Inventory;
import com.codenameb.model.inventory.ShopItem;
import com.codenameb.repository.ItemRepository;
import com.codenameb.repository.TokenRepository;
import com.codenameb.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

  private final UserRepository userRepository;
  private final TokenRepository tokenRepository;
  private final PasswordEncoder passwordEncoder;
  private final ItemRepository itemRepository;
  private final JwtService jwtService;
  private final AuthenticationManager authenticationManager;

  @Value("${user.on.register.credits}")
  private int defaultCreditsOnRegister;

  public ResponseEntity<AuthenticationResponse> register(RegisterRequest request) {
    if (userRepository.findByEmail(request.getEmail()).isPresent()) {
      throw new UserAlreadyExistsException(
          "User with email " + request.getEmail() + " already exists");
    }

    if (userRepository.findByUsername(request.getUserName()).isPresent()) {
      throw new UserAlreadyExistsException(
          "User with this Username " + request.getUserName() + " already exists");
    }

    Optional<ShopItem> defaultCharacterOptional =
        this.itemRepository.findByIdentifier("1_player_Knight");
    if (defaultCharacterOptional.isEmpty()) {
      throw new DefaultItemNotFoundException();
    }

    Optional<ShopItem> defaultWeaponOptional =
        this.itemRepository.findByIdentifier("1_weapon_fireball");
    if (defaultWeaponOptional.isEmpty()) {
      throw new DefaultItemNotFoundException();
    }

    User user =
        User.builder()
            .firstname(request.getFirstName())
            .lastname(request.getLastName())
            .username(request.getUserName())
            .email(request.getEmail())
            .password(passwordEncoder.encode(request.getPassword()))
            .inventory(
                Inventory.builder()
                    .credits(defaultCreditsOnRegister)
                    .items(List.of(defaultCharacterOptional.get(), defaultWeaponOptional.get()))
                    .build())
            .role(request.getRole())
            .build();
    user.getInventory().setUser(user);
    var savedUser = userRepository.save(user);
    var jwtToken = jwtService.generateToken(user);
    var refreshToken = jwtService.generateRefreshToken(user);
    saveUserToken(savedUser, jwtToken);
    return ResponseEntity.ok(
        AuthenticationResponse.builder().accessToken(jwtToken).refreshToken(refreshToken).build());
  }

  public AuthenticationResponse authenticate(AuthenticationRequest request) {
    authenticationManager.authenticate(
        new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));
    var user = userRepository.findByEmail(request.getEmail()).orElseThrow();
    var jwtToken = jwtService.generateToken(user);
    var refreshToken = jwtService.generateRefreshToken(user);
    revokeAllUserTokens(user);
    saveUserToken(user, jwtToken);
    return AuthenticationResponse.builder()
        .accessToken(jwtToken)
        .refreshToken(refreshToken)
        .build();
  }

  private void saveUserToken(User user, String jwtToken) {
    var token =
        Token.builder()
            .user(user)
            .token(jwtToken)
            .tokenType(TokenType.BEARER)
            .expired(false)
            .revoked(false)
            .build();
    tokenRepository.save(token);
  }

  public void revokeAllUserTokens(User user) {
    var validUserTokens = tokenRepository.findAllValidTokenByUser(user.getId());
    if (validUserTokens.isEmpty()) return;
    validUserTokens.forEach(
        token -> {
          token.setExpired(true);
          token.setRevoked(true);
        });
    tokenRepository.saveAll(validUserTokens);
  }

  public void refreshToken(HttpServletRequest request, HttpServletResponse response)
      throws IOException {
    final String authHeader = request.getHeader(HttpHeaders.AUTHORIZATION);
    final String refreshToken;
    final String userEmail;
    if (authHeader == null || !authHeader.startsWith("Bearer ")) {
      return;
    }
    refreshToken = authHeader.substring(7);
    userEmail = jwtService.extractUsername(refreshToken);
    if (userEmail != null) {
      var user = this.userRepository.findByEmail(userEmail).orElseThrow();
      if (jwtService.isTokenValid(refreshToken, user)) {
        var accessToken = jwtService.generateToken(user);
        revokeAllUserTokens(user);
        saveUserToken(user, accessToken);
        var authResponse =
            AuthenticationResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
        new ObjectMapper().writeValue(response.getOutputStream(), authResponse);
      }
    }
  }
}
