package com.gyh.service.dao

import com.gyh.service.entity.User
import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.kotlin.CoroutineCrudRepository

/**
 * Created by gyh on 2020/3/17.
 */
interface UserDao : CoroutineCrudRepository<User, Int> {

    suspend fun existsByUsername(username: String): Boolean

    suspend fun findByUsername(username: String): User?

}