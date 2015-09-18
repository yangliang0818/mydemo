package com.设计模式.设计模式4_建造者模式_Builder;

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
        Builder builder = new Builder();
        builder.produceMailSender(10);
        for (Sender sender : builder.getList()) {
            sender.send();
        }
    }
}
