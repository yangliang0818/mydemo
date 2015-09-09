package com.demo.strategy;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/27
 * Description:
 */
public class Yangliang extends AbstraceWork {
    public Yangliang() {
        setStrategy(new YangliangStrategy());
    }

    @Override
    public void go() {
        System.out.println("我早上是骑电动车来上班的");
    }
}
