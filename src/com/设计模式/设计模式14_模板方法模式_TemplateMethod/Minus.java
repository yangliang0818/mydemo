package com.设计模式.设计模式14_模板方法模式_TemplateMethod;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class Minus extends AbstractCalculator {
    @Override
    public int calculate(int num1, int num2) {
        return num1-num2;
    }
}
