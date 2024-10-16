package com.codenameb.repository;

import com.codenameb.model.defaults.Difficulty;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DifficultyRepository extends JpaRepository<Difficulty, Long> {

  boolean existsByIdentifier(String identifier);
}
