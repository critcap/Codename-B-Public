package com.codenameb.service;

import com.codenameb.dto.GetGameDto;
import com.codenameb.mapper.GameMapper;
import com.codenameb.model.game.Game;
import com.codenameb.repository.GameRepository;
import java.util.Comparator;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GameService {
  private final GameRepository gameRepository;
  private final GameMapper gameMapper;

  public List<GetGameDto> getPublicGames(int limit) {
    // Find and sort games
    List<Game> games = this.gameRepository.findAll();
    games.sort(this.sortByScoreComparator());

    // Map games and return games
    List<GetGameDto> gameDtos = gameMapper.gamesToDtos(games);
    return gameDtos.size() > limit ? gameDtos.subList(0, limit - 1) : gameDtos;
  }

  private Comparator<Game> sortByScoreComparator() {
    return new Comparator<Game>() {
      @Override
      public int compare(Game game1, Game game2) {
        return Integer.compare(game2.getScore(), game1.getScore());
      }
    };
  }
}
