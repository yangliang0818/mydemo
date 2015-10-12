package com.redis;

import org.apache.xpath.SourceTree;
import redis.clients.jedis.Jedis;

import java.util.HashSet;
import java.util.Set;

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
        System.out.println(jedis.hlen("HOSS_SESSION_HOSS_MAP_KEY_1"));
        Set set=jedis.hkeys("HOSS_SESSION_HOSS_MAP_KEY_1");
        System.out.println(set.contains("hoss_user_id2C32911132C5AF3E528EA1935BCE1DE1"));
        jedis.hset("HOSS_SESSION_HOSS_MAP_KEY_1","hoss_user_id2C32911132C5AF3E528EA1935BCE1DE1","-1");
        System.out.println(jedis.hlen("HOSS_SESSION_HOSS_MAP_KEY_1"));
        System.out.println(jedis.hget("HOSS_SESSION_HOSS_MAP_KEY_1","hoss_user_id2C32911132C5AF3E528EA1935BCE1DE1"));
        System.out.println(jedis.hget("HOSS_SESSION_HOSS_MAP_KEY_1","hoss_web_sys_user_permissECAD5ACC23AC657B6EF27D702822E09B"));
        System.out.println(jedis.hget("HOSS_SESSION_HOSS_MAP_KEY_1","hoss_web_sys_user_permissD2BD5B9EA140276B891CF0CAC2B88BDF"));
        System.out.println(jedis.hget("HOSS_SESSION_HOSS_MAP_KEY_1","HOSS_SESSION_F99038622B47E2598ECFF5CBB6BB1429"));/*第一次登录的id HOSS_SESSION_F99038622B47E2598ECFF5CBB6BB1429*/
        System.out.println(set);
    }
}
