package com.codenameb.repository;

import com.codenameb.model.inventory.ShopItem;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ItemRepository extends JpaRepository<ShopItem, Long> {
  Optional<ShopItem> findByName(String name);

  Optional<ShopItem> findByIdentifier(String identifier);

  boolean existsByIdentifier(String identifier);
}
