package com.设计模式.设计模式20_状态模式_State;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class MainTest {
    public static void main(String[] args) {
        State state = new State();
        Context context = new Context(state);
        //设置第一种状态
        state.setValue("state1");
        context.method();
        //设置第二种状态
        state.setValue("state2");
        context.method();
    }
}
