package com.设计模式.设计模式6_适配器模式_Adapter.T2对象的适配器模式;

import com.设计模式.设计模式6_适配器模式_Adapter.T1类的适配器模式.Source;
import com.设计模式.设计模式6_适配器模式_Adapter.T1类的适配器模式.Targetable;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class Wrapper implements Targetable {
    private Source source;

    public Wrapper(Source source) {
        super();
        this.source = source;
    }

    @Override
    public void method2() {
        System.out.println("this is the targetable method!");
    }

    @Override
    public void method1() {
        source.method1();
    }
}
