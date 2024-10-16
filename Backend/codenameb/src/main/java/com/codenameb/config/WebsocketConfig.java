package com.codenameb.config;

import com.codenameb.service.WebsocketSessionService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.web.socket.server.standard.ServletServerContainerFactoryBean;

@Configuration
@EnableWebSocket
@RequiredArgsConstructor
public class WebsocketConfig implements WebSocketConfigurer {

  private final WebsocketSessionService websocketService;

  public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
    registry.addHandler(socketHandler(), "/socket").setAllowedOriginPatterns("*");
  }

  @Bean
  WebSocketHandler socketHandler() {
    return new WebsocketHandler(websocketService);
  }

  @Bean
  public ServletServerContainerFactoryBean createWebSocketContainer() {
    ServletServerContainerFactoryBean container = new ServletServerContainerFactoryBean();
    container.setMaxTextMessageBufferSize(1024000);
    container.setMaxBinaryMessageBufferSize(1024000);
    return container;
  }
}
