package com.gyh.service.entity

import java.time.LocalDateTime

/**
 * Created by gyh on 2021/1/10
 */
data class Message(
    val id: Int,
    val msgType: Int,
    val content: String,
    val path: String,
    val roomId: Int,
    val date: LocalDateTime
)
