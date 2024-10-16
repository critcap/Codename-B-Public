package com.codenameb.config;

import com.codenameb.dto.InitialDataJsonDto;
import com.codenameb.dto.ShopItemDto;
import com.codenameb.model.User;
import com.codenameb.model.authentication.Role;
import com.codenameb.model.defaults.Difficulty;
import com.codenameb.model.defaults.Map;
import com.codenameb.model.inventory.Inventory;
import com.codenameb.model.inventory.ShopItem;
import com.codenameb.repository.DifficultyRepository;
import com.codenameb.repository.ItemRepository;
import com.codenameb.repository.MapRepository;
import com.codenameb.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.Resource;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SetupDataLoader implements CommandLineRunner {

  private final UserRepository userRepository;
  private final ItemRepository itemRepository;
  private final MapRepository mapRepository;
  private final DifficultyRepository difficultyRepository;
  private final PasswordEncoder passwordEncoder;
  private final ObjectMapper objectMapper;

  @Value("${setup.data.email}")
  private String setupEmail;

  @Value("${setup.data.password}")
  private String setupPassword;

  @Value("${setup.data.firstname}")
  private String setupFirstname;

  @Value("${setup.data.lastname}")
  private String setupLastname;

  @Value("${setup.data.username}")
  private String setupUsername;

  @Value("${setup.data.credits}")
  private int setupCredits;

  @Value("classpath:setup-data.json")
  private Resource setupDataJsonResource;

  private InitialDataJsonDto loadInitialData() throws IOException {
    return this.objectMapper.readValue(
        this.setupDataJsonResource.getInputStream(), InitialDataJsonDto.class);
  }

  private void createSetupDataIfNotExists() {

    InitialDataJsonDto initialDataJsonDto;
    try {
      initialDataJsonDto = this.loadInitialData();
    } catch (Exception e) {
      System.out.println("Error: " + e.getMessage());
      return;
    }

    // Save items
    List<ShopItemDto> items = initialDataJsonDto.getItems();
    if (items != null && !items.isEmpty()) {
      for (ShopItemDto dto : items) {
        if (!this.itemRepository.existsByIdentifier(dto.getIdentifier())) {
          System.out.println("Adding new item: " + dto.getIdentifier());
          ShopItem item =
              ShopItem.builder()
                  .name(dto.getName())
                  .identifier(dto.getIdentifier())
                  .description(dto.getDescription())
                  .price(dto.getPrice())
                  .imageName(dto.getImageName())
                  .itemType(dto.getItemType())
                  .maxBuyCount(dto.getMaxBuyCount())
                  .shopable(dto.isShopable())
                  .build();
          itemRepository.save(item);
        }
      }
    }

    // Save Maps
    List<Map> maps = initialDataJsonDto.getMaps();
    if (maps != null && !maps.isEmpty()) {
      maps.forEach(
          map -> {
            if (!this.mapRepository.existsByIdentifier(map.getIdentifier())) {
              this.mapRepository.save(map);
            }
          });
    }

    // Save Difficulties
    List<Difficulty> difficulties = initialDataJsonDto.getDifficulties();
    if (difficulties != null && !difficulties.isEmpty()) {
      difficulties.forEach(
          difficulty -> {
            if (!this.difficultyRepository.existsByIdentifier(difficulty.getIdentifier())) {
              this.difficultyRepository.save(difficulty);
            }
          });
    }
  }

  private void createDefaultUserIfNotFound() {
    if (userRepository.findByEmail(setupEmail).isPresent()) {
      return;
    }
    User user =
        User.builder()
            .firstname(setupFirstname)
            .lastname(setupLastname)
            .email(setupEmail)
            .username(setupUsername)
            .password(passwordEncoder.encode(setupPassword))
            .inventory(
                Inventory.builder()
                    .credits(this.setupCredits)
                    .items(this.itemRepository.findAll())
                    .build())
            .role(Role.ADMIN)
            .build();
    userRepository.save(user);
  }

  @Override
  public void run(String... args) {
    // Load Items
    this.createSetupDataIfNotExists();

    // Create Default User
    this.createDefaultUserIfNotFound();
  }
}
