package com.gyh.service.service

import com.gyh.service.dao.UserDao
import com.gyh.service.entity.User
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service

/**
 * Created by gyh on 2021/1/6
 */
@Service
class UserService {
    @Autowired
    private lateinit var userDao: UserDao

    suspend fun login(username: String, password: String): User? {
        val user = userDao.findByUsername(username)
        if (user?.password == password) {
            return userDao.findByUsername(username)
        } else {
            error("密码错误")
        }
    }

    suspend fun register(user: User): User {
        return userDao.save(user)
    }
}