package org.csu.aiinterview.controller;

import org.csu.aiinterview.common.Result;
import org.csu.aiinterview.dto.LoginRequest;
import org.csu.aiinterview.dto.LoginResponse;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @PostMapping("/login")
    public Result<LoginResponse> login(@RequestBody LoginRequest request) {
        // TODO: 这里写真正的登录逻辑

        // 临时返回，让接口先跑起来
        LoginResponse response = new LoginResponse();
        response.setToken("临时token");
        response.setUserId(1L);
        response.setUsername(request.getUsername());

        return Result.success(response);
    }
}