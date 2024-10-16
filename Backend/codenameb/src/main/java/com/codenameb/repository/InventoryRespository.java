package com.codenameb.repository;

import com.codenameb.model.inventory.Inventory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryRespository extends JpaRepository<Inventory, Long> {}
