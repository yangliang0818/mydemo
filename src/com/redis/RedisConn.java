package com.redis;

import redis.clients.jedis.Jedis;

/**
 * SOFTSI-助力信息时代互联互通
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/8
 * Description: 客户端连接redis测试类
 */
public class RedisConn {
    public static void main(String[] args) {
        Jedis jedis = new Jedis("172.16.10.35", 6380);
        jedis.connect();
        jedis.select(10);
        System.out.println(jedis.hget("HIhaowu", "haowu"));
        jedis.hset("HIhaowu", "good", "nana");
    }
}
