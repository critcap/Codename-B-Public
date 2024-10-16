package com.codenameb.model;

import com.codenameb.model.authentication.PasswordResetToken;
import com.codenameb.model.authentication.Role;
import com.codenameb.model.authentication.Token;
import com.codenameb.model.game.Game;
import com.codenameb.model.inventory.Inventory;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import java.util.Collection;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "_user")
public class User implements UserDetails {

  @Id @GeneratedValue private Long id;
  private String firstname;
  private String lastname;

  @Column(unique = true)
  private String username;

  private String email;
  private String password;

  @OneToOne(fetch = FetchType.EAGER, cascade = CascadeType.ALL)
  @JoinColumn(name = "inventory_id", referencedColumnName = "id")
  private Inventory inventory;

  @Enumerated(EnumType.STRING)
  private Role role;

  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
  private List<Token> tokens;

  @OneToMany(mappedBy = "user")
  private List<PasswordResetToken> passwordResetTokens;

  @OneToMany(mappedBy = "user")
  @JsonManagedReference
  private List<Game> games;

  @Override
  public Collection<? extends GrantedAuthority> getAuthorities() {
    return role.getAuthorities();
  }

  @Override
  public String getPassword() {
    return password;
  }

  @Override
  public String getUsername() {
    return email;
  }

  @Override
  public boolean isAccountNonExpired() {
    return true;
  }

  @Override
  public boolean isAccountNonLocked() {
    return true;
  }

  @Override
  public boolean isCredentialsNonExpired() {
    return true;
  }

  @Override
  public boolean isEnabled() {
    return true;
  }
}
