package com.codenameb.repository;

import com.codenameb.model.defaults.Map;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MapRepository extends JpaRepository<Map, Long> {
  boolean existsByIdentifier(String identifier);
}
