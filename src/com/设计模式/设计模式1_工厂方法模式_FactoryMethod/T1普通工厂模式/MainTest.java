package com.设计模式.设计模式1_工厂方法模式_FactoryMethod.T1普通工厂模式;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class MainTest {
    public static void main(String[] args) {
        //原始设计
        SendFactory factory = new SendFactory();
        Sender sender = factory.produce("sms");
        sender.send();
        //改进设计
        sender = factory.produceNG("mail");
        sender.send();
    }
}
