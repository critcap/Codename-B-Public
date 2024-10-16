package com.codenameb.model.authentication;

import com.codenameb.model.User;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PasswordResetToken {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private String token;

  @ManyToOne
  @JoinColumn(nullable = false, name = "user_id")
  private User user;

  private LocalDateTime expiryDate;

  public PasswordResetToken(String token, User user, LocalDateTime expiryDate) {
    this.token = token;
    this.user = user;
    this.expiryDate = expiryDate;
  }

  public boolean isExpired() {
    return LocalDateTime.now().isAfter(expiryDate);
  }
}
