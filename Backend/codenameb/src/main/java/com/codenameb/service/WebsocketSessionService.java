package com.codenameb.service;

import com.codenameb.config.JwtService;
import com.codenameb.dto.GameEndParameters;
import com.codenameb.exception.NoSessionFoundException;
import com.codenameb.exception.UserNotFoundException;
import com.codenameb.model.User;
import com.codenameb.model.authentication.SocketToken;
import com.codenameb.model.game.Game;
import com.codenameb.model.game.GameStartParameters;
import com.codenameb.model.inventory.Inventory;
import com.codenameb.model.inventory.ShopItem;
import com.codenameb.repository.GameRepository;
import com.codenameb.repository.ItemRepository;
import com.codenameb.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

@Service
@RequiredArgsConstructor
public class WebsocketSessionService {
  private final ObjectMapper objectMapper;
  private final JwtService jwtService;
  private final UserDetailsService userDetailsService;
  private final GameRepository gameRepository;
  private final UserRepository userRepository;
  private final ItemRepository itemRepository;
  private final InventoryService inventoryService;
  private final Map<String, WebSocketSession> userSessions = new ConcurrentHashMap<>();

  public void handleTextMessage(WebSocketSession session, TextMessage message) throws IOException {

    // Check if there is a Message incoming
    if (message == null) {
      return;
    }

    String jsonPayload = message.getPayload();
    SocketToken request;
    SocketToken response = new SocketToken();

    // Try to map the payload, else respond with an error message
    try {
      request = objectMapper.readValue(jsonPayload, SocketToken.class);
    } catch (IOException e) {
      response.setAction("response_failed");
      response.setResponse("Couldnt map the request to a SocketToken!");
      response.setToken(null);
      response.setGameStartParameters(null);
      session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
      e.printStackTrace();
      return;
    }

    // Check if the user is authenticated, else respond with an error
    if (!this.authenticateUser(request.getToken())) {
      response.setAction("response_unauthorized");
      response.setResponse("Sorry you're not auhorized to use this websocket!");
      response.setToken(null);
      response.setGameStartParameters(null);
      session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
      return;
    }

    // Check if an action is available
    if (request.getAction() == null) {
      response.setAction("response_no_action_found");
      response.setResponse("Sorry you have not defined any action!");
      response.setToken(null);
      response.setGameStartParameters(null);
      session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
      return;
    }

    if (request.getAction().equals("GET_SESSION_ID")) {
      this.handleGetSessionId(session, request, response);
    } else if (request.getAction().equals("POST_GAME")) {
      this.handlePostGame(request);
    } else if (request.getAction().equals("SEND_SESSION_ID")) {
      this.handleAngularSendMessages(request);
    } else if (request.getAction().equals("GAME_END")) {
      this.handleGameEnd(request);
    } else {
      response.setAction("response_no_valid_action_found");
      response.setResponse("Sorry your defined action is not available!");
      response.setToken(null);
      response.setGameStartParameters(null);
      session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
    }
  }

  private void handlePostGame(SocketToken request) throws IOException {
    if (request.getToUser() != null) {
      WebSocketSession godotSession = this.userSessions.get(request.getToUser());
      godotSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(request)));
    }
  }

  private void handleAngularSendMessages(SocketToken request) throws IOException {
    if (request.getToUser() != null) {
      WebSocketSession angularSession = this.userSessions.get(request.getToUser());
      if (angularSession == null) {
        throw new NoSessionFoundException(request.getToUser());
      }
      angularSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(request)));
    }
  }

  private void handleGameEnd(SocketToken request) throws IOException {
    GameStartParameters gameStartParameters = request.getGameStartParameters();
    GameEndParameters gameEndParameters = request.getGameEndParameters();

    String username = jwtService.extractUsername(request.getToken());
    Optional<User> userOptional = this.userRepository.findByEmail(username);
    if (userOptional.isEmpty()) {
      throw new UserNotFoundException((long) -1);
    }

    List<ShopItem> usedItems =
        new ArrayList<>(
            gameEndParameters.getItemsUsed().stream()
                .map(
                    item -> {
                      Optional<ShopItem> shopItem =
                          this.itemRepository.findByIdentifier(item.getIdentifier());
                      if (shopItem.isEmpty()) {
                        System.out.println("Nicht gefunden: " + item.getIdentifier());
                        return null;
                      }
                      return shopItem.get();
                    })
                .toList());
    // Remove all null objects from the List
    usedItems.removeAll(Collections.singleton(null));

    // Add new gold to the users inventory
    User user = userOptional.get();
    Inventory newInventory =
        this.inventoryService.earnCredits(user.getInventory().getId(), gameEndParameters.getGold());

    Game game =
        Game.builder()
            .win(gameEndParameters.isWin())
            .gold(gameEndParameters.getGold())
            .defeatedEnemies(gameEndParameters.getDefeatedEnemies())
            .surviveTime(gameEndParameters.getSurviveTime())
            .levelReached(gameEndParameters.getLevelReached())
            .score(gameEndParameters.getScore())
            .gameStartParameters(gameStartParameters)
            .itemsUsed(usedItems)
            .user(user)
            .build();
    this.gameRepository.save(game);
    this.handleAngularSendMessages(request);
  }

  private void handleGetSessionId(
      WebSocketSession session, SocketToken request, SocketToken response) throws IOException {
    if (request.getFromUser() == null || request.getFromUser().isEmpty()) {
      String sessionId = UUID.randomUUID().toString();
      userSessions.put(sessionId, session);
      response.setAction("response_id_created");
      response.setFromUser(sessionId);
      response.setToken(request.getToken());
      response.setGameStartParameters(request.getGameStartParameters());
      session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
    }
  }

  private boolean authenticateUser(String token) {
    if (token == null) {
      return false;
    }
    String username = jwtService.extractUsername(token);
    UserDetails userDetails = userDetailsService.loadUserByUsername(username);
    return jwtService.isTokenValid(token, userDetails);
  }

  public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
    String sessionUUID =
        userSessions.entrySet().stream()
            .filter(entry -> entry.getValue().getId().equals(session.getId()))
            .map(Map.Entry::getKey)
            .findFirst()
            .orElse(null);

    if (sessionUUID != null) {
      userSessions.remove(sessionUUID);
    }
  }
}
