package com.gyh.service.socket

import com.gyh.service.common.NotifyOrder
import com.gyh.service.entity.Message
import com.gyh.service.entity.ResponseInfo
import com.gyh.service.service.RoomService
import kotlinx.coroutines.reactor.mono
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono

/**
 * Created by gyh on 2020/4/5.
 */
@WebSocketMapping("/room")
class RoomSocketHandler : SocketHandler() {
    private val logger = LoggerFactory.getLogger(this.javaClass)

    @Autowired
    lateinit var roomService: RoomService

    override fun onConnect(queryMap: Map<String, String>, sessionHandler: WebSocketSessionHandler): Mono<*> {
        val userName = queryMap["username"] ?: return sessionHandler.send("错误，不支持的参数列表$queryMap")
            .then(sessionHandler.connectionClosed())
        val id = queryMap["id"] ?: return sessionHandler.send("错误，不支持的参数列表$queryMap")
            .then(sessionHandler.connectionClosed())
        return SocketSessionStore.addUser(sessionHandler, id.toInt(), userName)
            .onErrorResume {
                sessionHandler.send(ResponseInfo.failed("错误: ${it.message}"), NotifyOrder.errorNotify)
                    .doOnNext { msg -> logger.info("send $msg") }.flatMap { Mono.empty<Unit>() }
            }
    }

    /**
     * {"order":"/message","data":{},"req":12}
     */
    override fun doDispatch(requestInfo: ServiceRequestInfo, responseInfo: ServiceResponseInfo): Mono<Void> {
        val msg = json.readValue(requestInfo.body, Message::class.java)
        logger.info(msg.toString())
        return Flux.fromIterable(SocketSessionStore.userInfoMap.entries)
            .flatMap {
                val socketInfo = it.value
                val id = socketInfo.userId
                if (roomService.cacheRoom[id]?.contains(msg.roomId) == true && id != msg.userId) {
                    socketInfo.session
                        .send(ServiceResponseInfo.DataResponse(msg, null, NotifyOrder.requestReq))
                        .flatMap { roomService.addRoomMsg(msg) }
                } else Mono.empty()
            }.then()
    }

    override fun onDisconnected(queryMap: Map<String, String>, sessionHandler: WebSocketSessionHandler) {
        val id = queryMap["id"]?.toInt()
        SocketSessionStore.removeUser(id)
    }

}
