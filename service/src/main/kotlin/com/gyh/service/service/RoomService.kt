package com.gyh.service.service

import com.gyh.service.dao.RoomDao
import com.gyh.service.dao.RoomMessageDao
import com.gyh.service.dao.UserRoomDao
import com.gyh.service.entity.Message
import com.gyh.service.entity.Room
import com.gyh.service.entity.UserRoom
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.count
import kotlinx.coroutines.flow.map
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Slice
import org.springframework.data.domain.Sort
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate
import org.springframework.r2dbc.core.flow
import org.springframework.stereotype.Service
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.util.*
import java.util.concurrent.ConcurrentHashMap
import javax.annotation.Resource

/**
 * Created by gyh on 2021/1/8
 */
@Service
class RoomService {
    private val logger = LoggerFactory.getLogger(this.javaClass)
    @Resource
    lateinit var roomDao: RoomDao

    @Resource
    lateinit var userRoomDao: UserRoomDao

    @Resource
    lateinit var roomMessageDao: RoomMessageDao

    @Autowired
    lateinit var r2dbc: R2dbcEntityTemplate

    var cacheRoom: MutableMap<Int, MutableList<Int>> = ConcurrentHashMap()

    suspend fun createRoom(userId: Int, name: String, description: String): Room {
        val room = roomDao.save(Room(null, name, description, null))
        joinRoom(userId, room.id!!)
        return room
    }

    suspend fun findAllRoom(id: Int): Flow<MutableMap<String, Any>> {
        return r2dbc.databaseClient
            .sql("select su.* from sc_user_room ur LEFT JOIN sc_room su on su.\"id\" = ur.room_id where user_id = :userId")
            .bind("userId", id)
            .fetch()
            .flow()
            .map {
                val list = cacheRoom[id] ?: LinkedList<Int>()
                list.add(it["id"] as Int)
                cacheRoom[id] = list
                it
            }
    }

    suspend fun joinRoom(userId: Int, roomId: Int): String {
        return if(userRoomDao.existsByUserIdAndRoomId(userId, roomId)) {
            "失败，已添加该房间"
        } else {
            userRoomDao.save(UserRoom(null, userId, roomId))
            "成功"
        }
    }

    suspend fun removeRoom(userId: Int, roomId: Int): Boolean {
        return userRoomDao.deleteAllByUserIdAndRoomId(userId, roomId)
    }

    suspend fun searchRoom(name: String): Flow<Room> {
        return roomDao.findByNameLike("%$name%")
    }

    suspend fun deleteRoom(userId: Int, roomId: Int): Int {
        return userRoomDao.findByUserIdAndRoomId(userId, roomId).map {
            roomDao.deleteById(it.roomId)
            print(it)
        }.count()
    }

    fun addRoomMsg(msg: Message): Mono<Message> {
        return roomMessageDao.save(msg)
    }

    fun findAllMsg(page: Int, size: Int, roomId: Int): Flux<Message> {
        val pageable = PageRequest.of(page, size, Sort.by("date").descending())
        return roomMessageDao.findAllByRoomId(roomId, pageable)
    }

}