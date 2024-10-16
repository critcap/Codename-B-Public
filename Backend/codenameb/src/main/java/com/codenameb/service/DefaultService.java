package com.codenameb.service;

import com.codenameb.dto.DefaultDto;
import com.codenameb.model.defaults.Difficulty;
import com.codenameb.model.defaults.Map;
import com.codenameb.repository.DifficultyRepository;
import com.codenameb.repository.MapRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DefaultService {
  private final MapRepository mapRepository;
  private final DifficultyRepository difficultyRepository;

  public DefaultDto getAllDefaultParams() {
    List<Map> maps = this.mapRepository.findAll();
    List<Difficulty> difficulties = this.difficultyRepository.findAll();
    return DefaultDto.builder().maps(maps).difficulties(difficulties).build();
  }
}
