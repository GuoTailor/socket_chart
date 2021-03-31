package com.gyh.service.dao

import org.springframework.data.repository.kotlin.CoroutineCrudRepository

/**
 * Created by gyh on 2021/3/31
 */
interface RoomMessageDao : CoroutineCrudRepository<RoomMessageDao, Int> {

    //   wsuspend fun find
}