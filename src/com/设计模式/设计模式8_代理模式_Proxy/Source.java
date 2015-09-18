package com.设计模式.设计模式8_代理模式_Proxy;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class Source implements Sourceable {
    @Override
    public void method() {
        System.out.println("the original method!");
    }
}
