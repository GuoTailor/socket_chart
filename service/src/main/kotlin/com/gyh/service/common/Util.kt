package com.gyh.service.common

import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import org.slf4j.LoggerFactory
import org.springframework.util.StringUtils
import java.io.IOException
import java.net.URLDecoder
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*

object Util {
    private val logger = LoggerFactory.getLogger(Util::class.java)

    /**
     * 将json格式化为map
     *
     * @param json
     * @return
     */
    fun getParameterMap(json: String?): Map<String, Any> {
        var map: Map<String, Any> = HashMap()
        if (!StringUtils.isEmpty(json)) {
            try {
                map = jacksonObjectMapper().readValue(json!!)
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }
        return map
    }

    fun createDate(time: Long): String {
        return createDate("yyyy-MM-dd HH:mm:ss", time)
    }

    /**
     * 按当前时间，按`yyyy-MM-dd HH:mm:ss`格式格式化一个时间字符串
     *
     * @return 格式化后的时间字符串
     */
    @JvmOverloads
    fun createDate(pattern: String? = "yyyy-MM-dd HH:mm:ss", time: Long = System.currentTimeMillis()): String {
        return SimpleDateFormat(pattern).format(time)
    }

    /**
     * 把格式化后的时间字符串解码成时间毫秒值
     *
     * @param time 格式化后的时间字符串
     * @return 时间毫秒值
     */
    fun encoderDate(time: String?): Long? {
        try {
            return SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(time).time
        } catch (e: ParseException) {
            e.printStackTrace()
        }
        return null
    }

    fun getQueryMap(queryStr: String): Map<String, String> {
        val queryMap: MutableMap<String, String> = HashMap()
        if (queryStr.isNotEmpty()) {
            val queryParam = queryStr.split("&")
            queryParam.forEach { s: String ->
                val kv = s.split("=".toRegex(), 2)
                val value = if (kv.size == 2) kv[1] else ""
                queryMap[kv[0]] = URLDecoder.decode(value, "utf-8")
            }
        }
        return queryMap
    }
}