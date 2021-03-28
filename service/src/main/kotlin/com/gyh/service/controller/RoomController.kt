package com.gyh.service.controller

import com.gyh.service.entity.Room
import com.gyh.service.service.RoomService
import kotlinx.coroutines.flow.Flow
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.bind.annotation.*

/**
 * Created by gyh on 2021/1/8
 */
@RestController
@RequestMapping("/room")
class RoomController {

    @Autowired
    lateinit var roomService: RoomService

    @PutMapping("/create")
    suspend fun createRoom(userId: Int, name: String, description: String): Room {
        return roomService.createRoom(userId, name, description)
    }

    @GetMapping("/find")
    suspend fun findAllRoom(id: Int): Flow<MutableMap<String, Any>> {
        return roomService.findAllRoom(id)
    }

    @GetMapping("/search")
    suspend fun searchRoom(name: String): Flow<Room> {
        return roomService.searchRoom(name)
    }

    @PutMapping("/join")
    suspend fun joinRoom(userId: Int, roomId: Int): String {
        return roomService.joinRoom(userId, roomId)
    }

    @GetMapping("/remove")
    suspend fun removeRoom(@RequestParam userId: Int,@RequestParam roomId: Int): Boolean {
        return roomService.removeRoom(userId, roomId)
    }

    @GetMapping("/delete")
    suspend fun deleteRoom(userId: Int, roomId: Int): Int {
        return roomService.deleteRoom(userId, roomId)
    }

}