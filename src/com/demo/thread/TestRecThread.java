package com.demo.thread;

import java.util.HashMap;
import java.util.Map;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/10/12
 * Description:
 */
public class TestRecThread {
    static ThreadLocal<Map> recMap = new ThreadLocal<Map>() {
        @Override
        protected Map initialValue() {
            return new HashMap();
        }
    };
    static Object obj1 = new Object();
    static Object obj2 = new Object();

    public static void main(String[] args) {
        System.out.println(recMap.get().get("recChannel"));
        System.out.println("obj1 的地址为" + obj1);
        System.out.println("obj2 的地址为" + obj2);
        new Thread1().start();
        new Thread2().start();
    }

    static class Thread1 extends Thread {
        @Override
        public void run() {
            while (true) {
                try {
                    recMap.get().put("recChannel", "#hoss");
                    recMap.get().put("recObject", obj1);
                    Thread.sleep(3000);
                    System.out.println("当前线程是线程1,地址为" + Thread.currentThread().getId() + "业务渠道为" + recMap.get().get("recChannel") + "对象地址为" + recMap.get().get("recObject"));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    static class Thread2 extends Thread {
        @Override
        public void run() {
            while (true) {
                try {
                    recMap.get().put("recChannel", "#zlb");
                    recMap.get().put("recObject", obj2);
                    Thread.sleep(3000);
                    System.out.println("当前线程是线程2,地址为" + Thread.currentThread().getId() + "业务渠道为" + recMap.get().get("recChannel") + "对象地址为" + recMap.get().get("recObject"));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
