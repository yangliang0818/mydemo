package com.demo.handle;

import java.util.Random;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/27
 * Description:
 */
public class Client {
    public static void main(String[] args) {
        AbstractHandle handle = AbstractHandleFactory.createHandle();
        for (int i = 1; i <= 100; i++) {
            handle.dealDiscount(new Random().nextDouble());
            System.out.println("\n");
        }
    }
}
