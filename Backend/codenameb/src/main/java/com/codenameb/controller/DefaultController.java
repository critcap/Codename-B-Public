package com.codenameb.controller;

import com.codenameb.dto.DefaultDto;
import com.codenameb.service.DefaultService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/defaults")
public class DefaultController {

    private final DefaultService defaultService;
    @GetMapping
    public ResponseEntity<DefaultDto> getAllDefaultParams() {
        DefaultDto dto = this.defaultService.getAllDefaultParams();
        return ResponseEntity.ok(dto);
    }
}
