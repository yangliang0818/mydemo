package com.设计模式.设计模式18_命令模式_Command;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class MainTest {
    public static void main(String[] args) {
        Receiver receiver = new Receiver();
        Command cmd = new MyCommand(receiver);
        Invoker invoker = new Invoker(cmd);
        invoker.action();
        MyReceiver myReceiver=new MyReceiver();
        cmd=new MyCommand(myReceiver);
        invoker=new Invoker(cmd);
        invoker.action();
    }
}
