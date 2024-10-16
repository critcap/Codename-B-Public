package com.codenameb.config;

import com.codenameb.service.WebsocketSessionService;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

@RequiredArgsConstructor
public class WebsocketHandler extends TextWebSocketHandler {

  private final WebsocketSessionService websocketSessionService;

  @Override
  public void handleTextMessage(WebSocketSession session, TextMessage message) throws IOException {
    websocketSessionService.handleTextMessage(session, message);
  }

  @Override
  public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
    websocketSessionService.afterConnectionClosed(session, status);
  }
}
