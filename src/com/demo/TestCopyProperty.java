package com.demo;

import java.lang.reflect.InvocationTargetException;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/17
 * Description:
 */
public class TestCopyProperty {
    public static void main(String[] args) throws IllegalAccessException, NoSuchMethodException, InvocationTargetException {
        A a = new A();
        a.name = "yangliang";
        B b = new B();
        //BeanUtils.copyProperties(a, b);
        System.out.println(b.name);
    }

    static class A {
        private String name;

        public String getName() {
            return name;
        }
    }

    static class B {
        private String name;

        public void setName(String name) {
            this.name = name;
        }
    }
}
