package org.csu.aiinterview.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String username;
    private String password;  // 前端传的是明文密码
}