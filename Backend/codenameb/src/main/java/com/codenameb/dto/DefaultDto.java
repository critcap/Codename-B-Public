package com.codenameb.dto;

import com.codenameb.model.defaults.Difficulty;
import com.codenameb.model.defaults.Map;
import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class DefaultDto {
  private List<Map> maps;
  private List<Difficulty> difficulties;
}
