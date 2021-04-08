package com.gyh.service.dao

import com.gyh.service.entity.Message
import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Slice
import org.springframework.data.repository.reactive.ReactiveSortingRepository
import reactor.core.publisher.Flux

/**
 * Created by gyh on 2021/3/31
 */
interface RoomMessageDao : ReactiveSortingRepository<Message, Int> {

    fun findAllByRoomId(roomId: Int, pageable: Pageable) : Flux<Message>
}