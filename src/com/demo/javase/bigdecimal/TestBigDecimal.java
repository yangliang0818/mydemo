package com.demo.javase.bigdecimal;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.NumberFormat;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/11/6
 * Description:
 */
public class TestBigDecimal {
    static double f = 1/3;
    public static void m1() {
        BigDecimal bg = new BigDecimal(f);
        double f1 = bg.setScale(4, BigDecimal.ROUND_HALF_UP).doubleValue();
        System.out.println(f1);
    }
    /**
     * DecimalFormat转换最简便
     */
    public static void m2() {
        DecimalFormat df = new DecimalFormat("#.00");
        System.out.println(df.format(f));
    }
    public static void main(String[] args) {
        BigDecimal x=new BigDecimal(1.0/8.0);
        BigDecimal y=x.setScale(2,BigDecimal.ROUND_HALF_UP);
        System.out.println(y.doubleValue());
    }
}
