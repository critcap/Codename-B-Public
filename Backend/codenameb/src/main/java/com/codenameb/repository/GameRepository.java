package com.codenameb.repository;

import com.codenameb.model.game.Game;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GameRepository extends JpaRepository<Game, Long> {
  List<Game> findAllByUserId(Long id);
}
