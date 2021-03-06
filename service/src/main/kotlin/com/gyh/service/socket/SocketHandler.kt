package com.gyh.service.socket

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.*
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import com.gyh.service.common.NotifyOrder
import com.gyh.service.common.Util
import com.gyh.service.entity.ResponseInfo
import org.slf4j.LoggerFactory
import org.springframework.web.reactive.socket.WebSocketHandler
import org.springframework.web.reactive.socket.WebSocketSession
import reactor.core.publisher.Mono
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId

/**
 * Created by gyh on 2020/5/19.
 */
abstract class SocketHandler : WebSocketHandler {
    private val logger = LoggerFactory.getLogger(this.javaClass)
    private val blankRegex = "\\s".toRegex()
    private val orderRegex = "\"order\":(.*?)[,}]".toRegex()
    private val dataRegex = "\"data\":(.*?})[,}]".toRegex()
    private val reqRegex = "\"req\":(.*?)[,}]".toRegex()
    val json = jacksonObjectMapper()

    init {
        json.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
        val javaTimeModule = JavaTimeModule()
        javaTimeModule.addSerializer(LocalDateTime::class.java, object : JsonSerializer<LocalDateTime>() {
            override fun serialize(value: LocalDateTime, gen: JsonGenerator, serializers: SerializerProvider) {
                val timestamp = value.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
                gen.writeNumber(timestamp)
            }
        })
        javaTimeModule.addDeserializer(LocalDateTime::class.java, object : JsonDeserializer<LocalDateTime>() {
            override fun deserialize(p: JsonParser, ctxt: DeserializationContext): LocalDateTime {
                val temp = p.valueAsLong
                return LocalDateTime.ofInstant(Instant.ofEpochMilli(temp), ZoneId.systemDefault())
            }
        })
        json.registerModule(javaTimeModule)
    }

    override fun handle(session: WebSocketSession): Mono<Void> {
        val sessionHandler = WebSocketSessionHandler(session)
        val watchDog = WebSocketWatchDog().start(sessionHandler, 5000)
        val queryMap = Util.getQueryMap(sessionHandler.getSession().handshakeInfo.uri.query)
        val connect = sessionHandler.connected().flatMap { onConnect(queryMap, sessionHandler) }
            .flatMap { sessionHandler.send(ResponseInfo.ok<Unit>("????????????"), NotifyOrder.connectSucceed, true) }
        sessionHandler.disconnected{ onDisconnected(queryMap, sessionHandler) }
        val output = sessionHandler.receive()
            .map(::toServiceRequestInfo)
            .map(::printLog)
            .filter { it.order != "/ping" }    // ??????????????????
            .filter { filterConfirm(it, sessionHandler) }
            .flatMap {
                val resp = ServiceResponseInfo(req = it.req, order = NotifyOrder.requestReq)
                doDispatch(it, resp)
                    .flatMap { resp.getMono() }
            }.onErrorResume {
                it.printStackTrace()
                ServiceResponseInfo(
                    ResponseInfo.failed("?????? ${it.message}"),
                    NotifyOrder.errorNotify,
                    NotifyOrder.requestReq
                ).getMono()
            }.flatMap{ sessionHandler.send(it, true) }
            .doOnNext { logger.info("send> $it") }
            .then()

        return sessionHandler.handle()
            .zipWith(connect)
            .zipWith(watchDog)
            .zipWith(output)
            .then()
    }

    abstract fun doDispatch(requestInfo: ServiceRequestInfo, responseInfo: ServiceResponseInfo): Mono<*>

    /**
     * ???socket?????????
     */
    abstract fun onConnect(queryMap: Map<String, String>, sessionHandler: WebSocketSessionHandler): Mono<*>

    /**
     * ???socket???????????????
     */
    abstract fun onDisconnected(queryMap: Map<String, String>, sessionHandler: WebSocketSessionHandler)

    private fun toServiceRequestInfo(data: String): ServiceRequestInfo {
        // TODO ???????????????????????????jackson???????????????
        val json = data.replace(blankRegex, "")
        val orderString = orderRegex.find(json)!!.groups[1]!!.value.replace("\"", "")
        val dataString = dataRegex.find(json)?.groups?.get(1)?.value
        val reqString = reqRegex.find(json)!!.groups[1]!!.value.toInt()
        return ServiceRequestInfo(orderString, dataString, reqString)
    }

    private fun printLog(info: ServiceRequestInfo): ServiceRequestInfo {
        if (info.order != "/echo" && info.order != "/ping")
            logger.info("???????????????order:{} req:{} data:{}", info.order, info.req, info.body)
        return info
    }

    private fun filterConfirm(info: ServiceRequestInfo, sessionHandler: WebSocketSessionHandler): Boolean {
        if (info.order == "/ok") {
            sessionHandler.reqIncrement(info.req)
            return false
        }
        return true
    }
}