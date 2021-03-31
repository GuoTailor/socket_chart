package com.gyh.service.dao

import com.gyh.service.entity.UserRoom
import kotlinx.coroutines.flow.Flow
import org.springframework.data.repository.kotlin.CoroutineCrudRepository

/**
 * Created by gyh on 2021/1/8
 */
interface UserRoomDao : CoroutineCrudRepository<UserRoom, Int> {

    //@Query("select su.* from sc_user_room ur LEFT JOIN sc_room su on su.\"id\" = ur.room_id where user_id = :userId")
    suspend fun findAllByUserId(userId: Int): Flow<UserRoom>

    suspend fun existsByUserIdAndRoomId(userId: Int, roomId: Int): Boolean

    suspend fun findByUserIdAndRoomId(userId: Int, roomId: Int): Flow<UserRoom>

    suspend fun deleteAllByUserIdAndRoomId(userId: Int, roomId: Int): Boolean
}