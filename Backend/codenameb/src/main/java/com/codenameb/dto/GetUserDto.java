package com.codenameb.dto;

import com.codenameb.model.authentication.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class GetUserDto {
  private Long id;
  private String firstname;
  private String lastname;
  private String username;
  private String email;
  private GetInventoryDto inventory;
  private Role role;
}
