package com.fly.sonarqubedemo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @Title:
 * @ClassName: com.fly.sonarqubedemo.controller.TestController.java
 * @Description:
 *
 * @Copyright 2020-2021 捷安高科 - Powered By 研发中心
 * @author: 王延飞
 * @date:  2021/5/22 14:22
 * @version V1.0
 */
@RestController
public class TestController {

    @GetMapping("test")
    public String test(){
        return  "123";
    }
}
