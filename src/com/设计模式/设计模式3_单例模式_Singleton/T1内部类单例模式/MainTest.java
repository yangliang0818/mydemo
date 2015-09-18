package com.设计模式.设计模式3_单例模式_Singleton.T1内部类单例模式;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class MainTest {
    public static void main(String[] args) {
        Singleton singleton = Singleton.getInstance();
        System.out.println(singleton);
        singleton=Singleton.getInstance();
        System.out.println(singleton);
    }
}
