package com.gyh.service.socket

import com.gyh.service.common.NotifyOrder
import com.gyh.service.entity.ResponseInfo
import org.slf4j.LoggerFactory
import reactor.core.publisher.Mono
import java.util.concurrent.ConcurrentHashMap

/**
 * Created by gyh on 2020/4/12.
 */
object SocketSessionStore {
    private val logger = LoggerFactory.getLogger(this.javaClass)
    internal val userInfoMap = ConcurrentHashMap<Int, UserRoomInfo>()

    fun addUser(session: WebSocketSessionHandler, id: Int, userName: String): Mono<Unit> {
        val userInfo = UserRoomInfo(session, id, userName)
        val old = userInfoMap.put(id, userInfo)
        logger.info("添加用户 $id ${session.getId()}")
        return if (old != null) {
            logger.info("用户多地登陆 $id ${old.session.getId()}")
            old.session.send(ResponseInfo.ok<Unit>("用户账号在其他地方登陆"), NotifyOrder.differentPlaceLogin)
                .flatMap { old.session.connectionClosed() }.map { Unit }.log()
        } else Mono.just(Unit)
    }

    fun removeUser(userId: Int?) {
        userInfoMap.remove(userId)
        logger.info("移除用户 $userId")
    }

    fun getRoomInfo(userId: Int): UserRoomInfo? {
        return userInfoMap[userId]
    }

    fun getOnLineSize(roomId: Int): Int {
        return userInfoMap.count { true }
    }

    data class UserRoomInfo(
        val session: WebSocketSessionHandler,
        val userId: Int,
        val userName: String
    )
}
