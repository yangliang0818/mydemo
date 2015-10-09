package com.demo.thread;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/17
 * Description:
 */
public class ThreadMain {
    public static void main(String[] args) {
     new Thread1().start();
    }
    static class Thread1 extends Thread{
        @Override
        public void run() {
            System.out.println("hello thread!!!!");
        }
    }
}
