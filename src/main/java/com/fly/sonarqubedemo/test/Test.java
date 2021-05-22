package com.fly.sonarqubedemo.test;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * @Title:
 * @ClassName: com.fly.sonarqubedemo.test.Test.java
 * @Description:
 *
 * @Copyright 2020-2021  - Powered By 研发中心
 * @author: 王延飞
 * @date:  2021/5/22 14:22
 * @version V1.0
 */
public class Test {

    public static void main(String[] args) {
        // 演示线程池不规范创建 p3c 会警告
        ScheduledExecutorService scheduledThreadPool = Executors.newScheduledThreadPool(5);
        scheduledThreadPool.schedule(() -> System.out.println("123"), 1, TimeUnit.SECONDS);
        scheduledThreadPool.shutdown();
    }
}
