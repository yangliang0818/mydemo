package com.设计模式.设计模式1_工厂方法模式_FactoryMethod.T2多个工厂方法模式;

import com.设计模式.设计模式1_工厂方法模式_FactoryMethod.T1普通工厂模式.Sender;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class MainTest {
    public static void main(String[] args) {
        SendFactory factory = new SendFactory();
        Sender sender = factory.produceMail();
        sender.send();
    }
}
