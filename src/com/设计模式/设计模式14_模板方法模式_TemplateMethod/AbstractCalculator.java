package com.设计模式.设计模式14_模板方法模式_TemplateMethod;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public abstract class AbstractCalculator {
    /*主方法，实现对本类其它方法的调用*/
    public final int calculate(String exp,String opt){
        int array[] = split(exp,opt);
        return calculate(array[0],array[1]);
    }

    /*被子类重写的方法*/
    abstract public int calculate(int num1,int num2);

    public int[] split(String exp,String opt){
        String array[] = exp.split(opt);
        int arrayInt[] = new int[2];
        arrayInt[0] = Integer.parseInt(array[0]);
        arrayInt[1] = Integer.parseInt(array[1]);
        return arrayInt;
    }
}
