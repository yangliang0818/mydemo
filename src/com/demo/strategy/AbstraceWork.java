package com.demo.strategy;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/27
 * Description:
 */
public abstract class AbstraceWork {

    private InterfaceStrategy strategy;

    public InterfaceStrategy getStrategy() {
        return strategy;
    }

    public void setStrategy(InterfaceStrategy strategy) {
        this.strategy = strategy;
    }

    /**
     * 乘坐交通工具上班
     */
    public void go() {
        System.out.println("乘坐交通工具去上班");
    }

    /**
     * 到公司后做些事情
     */
    public void work() {
        strategy.doSomeThing();
    }
}
