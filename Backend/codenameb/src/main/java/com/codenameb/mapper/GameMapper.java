package com.codenameb.mapper;

import com.codenameb.dto.GetGameDto;
import com.codenameb.model.game.Game;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class GameMapper {
  private final UserMapper userMapper;

  public List<GetGameDto> gamesToDtos(List<Game> games) {
    return games.stream()
        .map(
            game -> {
              return GetGameDto.builder()
                  .id(game.getId())
                  .win(game.isWin())
                  .defeatedEnemies(game.getDefeatedEnemies())
                  .surviveTime(game.getSurviveTime())
                  .levelReached(game.getLevelReached())
                  .gold(game.getGold())
                  .score(game.getScore())
                  .itemsUsed(game.getItemsUsed())
                  .gameStartParameters(game.getGameStartParameters())
                  .user(this.userMapper.toDto(game.getUser()))
                  .build();
            })
        .toList();
  }
}
