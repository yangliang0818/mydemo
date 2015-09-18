package com.设计模式.设计模式23_解释器模式_Interpreter;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class Minus implements Expression {
    @Override
    public int interpret(Context context) {
        return context.getNum1()-context.getNum2();
    }
}
