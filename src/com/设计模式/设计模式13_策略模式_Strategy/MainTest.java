package com.设计模式.设计模式13_策略模式_Strategy;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:策略模式的决定权在用户，系统本身提供不同算法的实现，
 * 新增或者删除算法，对各种算法做封装。因此，策略模式多用在算法决
 * 策系统中，外部用户只需要决定用哪个算法即可。
 */
public class MainTest {
    public static void main(String[] args) {
        String exp = "2+8";
        ICalculator cal = new Plus();
        int result = cal.calculate(exp);
        System.out.println(result);
        exp="2*8";
        cal=new Multiply();
        System.out.println(cal.calculate(exp));
        exp="2-8";
        cal=new Minus();
        System.out.println(cal.calculate(exp));
    }
}
