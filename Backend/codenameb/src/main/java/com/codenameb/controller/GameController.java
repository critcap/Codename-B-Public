package com.codenameb.controller;

import com.codenameb.dto.GetGameDto;
import com.codenameb.service.GameService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/games")
public class GameController {

  private final GameService gameService;

  @GetMapping
  public ResponseEntity<List<GetGameDto>> getGames() {
    List<GetGameDto> games = this.gameService.getPublicGames(1000);
    return ResponseEntity.ok(games);
  }
}
