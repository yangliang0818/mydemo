package com.demo.strategy;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/27
 * Description:
 */
public class Caina extends AbstraceWork {
    public Caina() {
        setStrategy(new CainaStrategy());
    }

    @Override
    public void work() {
        System.out.println("今天真热，早上还停电了，没心思工作~");
        getStrategy().doSomeThing();
    }
}
