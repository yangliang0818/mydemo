package com.设计模式.设计模式12_享元模式_Flyweight;

import java.sql.Connection;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class MainTest {
    public static void main(String[] args) throws Exception{
        ConnectionPool connectionPool=new ConnectionPool();
        System.out.println(connectionPool.getConnection());
        System.out.println(connectionPool.getConnection());
        System.out.println(connectionPool.getConnection());
        System.out.println(connectionPool.getConnection());
        System.out.println(connectionPool.getConnection());
        System.out.println(connectionPool.getConnection());
        System.out.println(connectionPool.getConnection());
        System.out.println(connectionPool.getConnection());
        System.out.println(connectionPool.getConnection());
        System.out.println(connectionPool.getConnection());
        System.out.println(connectionPool.getConnection());//为空链接

    }
}
