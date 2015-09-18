package com.设计模式.设计模式14_模板方法模式_TemplateMethod;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class MainTest {
    public static void main(String[] args) {
        String exp = "8+8";
        AbstractCalculator cal = new Plus();
        int result = cal.calculate(exp, "\\+");
        System.out.println(result);
        cal=new Minus();
        exp="2-8";
        System.out.println(cal.calculate(exp, "\\-"));
    }
}
