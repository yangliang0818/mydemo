package com.设计模式.设计模式23_解释器模式_Interpreter;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class MainTest {
    public static void main(String[] args) {
        // 计算9+2-8的值
        int result = new Minus().interpret((new Context(new Plus()
                .interpret(new Context(9, 2)), 8)));
        System.out.println(result);
    }
}
