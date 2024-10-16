package com.codenameb.model.defaults;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
public class Map {
  @Id @GeneratedValue private Long id;
  private String name;
  private String identifier;
  private String imageName;
}
