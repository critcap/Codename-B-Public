package com.codenameb.mapper;

import com.codenameb.dto.GetUserDto;
import com.codenameb.model.User;
import org.mapstruct.Mapper;
import java.util.List;

@Mapper(componentModel = "spring")
public interface UserMapper {
  GetUserDto toDto(User user);

  List<GetUserDto> toDtos(List<User> users);

  User toUser(GetUserDto getUserDto);

  List<User> toUsers(List<GetUserDto> userDtos);
}
