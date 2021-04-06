package com.gyh.service.controller

import com.gyh.service.entity.User
import com.gyh.service.service.UserService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.core.io.ClassPathResource
import org.springframework.core.io.Resource
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.http.ZeroCopyHttpOutputMessage
import org.springframework.http.codec.multipart.FilePart
import org.springframework.http.server.reactive.ServerHttpResponse
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Mono
import java.io.File
import java.io.IOException
import java.util.*


/**
 * Created by gyh on 2021/1/6
 */
@RestController
@RequestMapping("/user")
class UserController {
    @Autowired
    private lateinit var userService: UserService

    @PostMapping("/login")
    suspend fun login(@RequestBody map: User): User? {
        println(map.toString())
        return userService.login(map.username, map.password)
    }

    @PostMapping("/register")
    suspend fun register(@RequestBody user: User): User {
        return userService.register(user)
    }

    @PostMapping("/upload")
    fun requestBodyFlux(@RequestPart("file") filePart: FilePart): Mono<String>? {
        println(filePart.filename())
        val fileName = UUID.randomUUID().toString() + filePart
        val file = File("file/")
        if (!file.parentFile.exists()) {
            file.parentFile.mkdirs();  //新建文件夹
        }
        return filePart.transferTo(file).map { filePart.filename() }
    }

    @GetMapping("/download")
    @Throws(IOException::class)
    fun downloadByWriteWith(response: ServerHttpResponse): Mono<Void?>? {
        val zeroCopyResponse = response as ZeroCopyHttpOutputMessage
        response.getHeaders().set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=parallel.png")
        response.getHeaders().setContentType(MediaType.IMAGE_PNG)
        val resource: Resource = ClassPathResource("parallel.png")
        val file: File = resource.getFile()
        return zeroCopyResponse.writeWith(file, 0, file.length())
    }

}