package com.gyh.service.controller

import com.gyh.service.entity.User
import com.gyh.service.service.UserService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.bind.annotation.*

/**
 * Created by gyh on 2021/1/6
 */
@RestController
@RequestMapping("/user")
class UserController {
    @Autowired
    private lateinit var userService: UserService

    @PostMapping("/login")
    suspend fun login(@RequestBody map: User): User? {
        println(map.toString())
        return userService.login(map.username, map.password)
    }

    @PostMapping("/register")
    suspend fun register(@RequestBody user: User): User {
        return userService.register(user)
    }
}