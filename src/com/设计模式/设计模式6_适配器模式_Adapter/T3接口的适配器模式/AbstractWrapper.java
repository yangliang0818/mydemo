package com.设计模式.设计模式6_适配器模式_Adapter.T3接口的适配器模式;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public abstract class AbstractWrapper implements Sourceable {
    @Override
    public void method1() {
        System.out.println("this is  AbstractWrapper method1");
    }

    @Override
    public void method2() {
        System.out.println("this is  AbstractWrapper method2");
    }
}
