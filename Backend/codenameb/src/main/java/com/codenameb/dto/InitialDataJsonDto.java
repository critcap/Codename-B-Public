package com.codenameb.dto;

import com.codenameb.model.defaults.Difficulty;
import com.codenameb.model.defaults.Map;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class InitialDataJsonDto {
  private String version;
  private List<ShopItemDto> items;
  private List<Map> maps;
  private List<Difficulty> difficulties;
}
