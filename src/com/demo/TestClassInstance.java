package com.demo;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;

/**
 * SOFTSI-助力信息时代互联互通
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/14
 * Description:
 */
public class TestClassInstance {
    public static void main(String[] args) throws IllegalAccessException, InstantiationException {
        System.out.println(String.class.newInstance());
        System.out.println(ClassEnum.字符串类.clazz.newInstance());
        System.out.println(ClassEnum.抽象类.clazz.newInstance());
        List list = new ArrayList();
        list.add(1);
        list.add(2);
        System.out.println(list);
        int[] ints = new int[2];
        ints[0] = 1;
        ints[1] = 2;
        long i = 1248748248793l;
        BigInteger bi = new BigInteger("1248748248793");
        System.out.println(bi.intValue());
        System.out.println(bi.longValue());
    }

    public static enum ClassEnum {
        字符串类(String.class),
        抽象类(ClassImpl.class);
        protected Class clazz;

        ClassEnum(Class clazz) {
            this.clazz = clazz;
        }

    }

    public static abstract class AbstractClass {

    }

    protected static class ClassImpl extends AbstractClass {
    }
}
