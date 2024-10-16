package com.codenameb.service;

import com.codenameb.dto.GetUserDto;
import com.codenameb.exception.AuditorNotFoundException;
import com.codenameb.exception.UserNotFoundException;
import com.codenameb.mapper.UserMapper;
import com.codenameb.model.User;
import com.codenameb.model.game.Game;
import com.codenameb.repository.GameRepository;
import com.codenameb.repository.UserRepository;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.AuditorAware;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {
  private final UserRepository userRepository;
  private final UserMapper userMapper;
  private final GameRepository gameRepository;
  private final AuditorAware<Long> auditorAware;

  public GetUserDto getUserByAuthentication() {
    Optional<Long> currentAuditor = this.auditorAware.getCurrentAuditor();
    if (currentAuditor.isEmpty()) {
      throw new AuditorNotFoundException("Der aktuelle Auditor konnte nicht gefunden werden.");
    }
    Optional<User> user = this.userRepository.findById(currentAuditor.get());
    if (user.isEmpty()) {
      throw new UserNotFoundException(currentAuditor.get());
    }
    return this.userMapper.toDto(user.get());
  }

  public GetUserDto getUserById(Long userId) {
    Optional<User> userOptional = userRepository.findById(userId);
    if (userOptional.isEmpty()) {
      throw new UserNotFoundException(userId);
    }
    return this.userMapper.toDto(userOptional.get());
  }

  public List<GetUserDto> getAllUsers() {
    List<User> users = userRepository.findAll();
    return this.userMapper.toDtos(users);
  }

  public List<Game> getAllGames(Long id) {
    return this.gameRepository.findAllByUserId(id);
  }
}
