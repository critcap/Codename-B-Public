package com.codenameb.model.authentication;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class RegisterRequest {

  @NotBlank(message = "First name is required")
  private String firstName;

  @NotBlank(message = "Last name is required")
  private String lastName;

  @NotBlank(message = "Username is required")
  private String userName;

  @NotBlank(message = "Email is required")
  @Pattern(regexp = "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$", message = "Invalid email")
  private String email;

  @Pattern(
      regexp =
          "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[ !\"#$%&'()*+,-./:;<=>?@\\[\\]^_`{|}~])(?=\\S+$).{8,}$",
      message = "Invalid password")
  private String password;

  private Role role;
}
