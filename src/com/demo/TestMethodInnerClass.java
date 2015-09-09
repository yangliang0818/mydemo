package com.demo;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/16
 * Description:
 */
public class TestMethodInnerClass {
    public static void main(String[] args) {
        abstract class ITest {
            protected abstract String getName();
        }
        class TestA extends ITest {
            String name;

            @Override
            protected String getName() {
                return name;
            }
        }
        TestA testA = new TestA();
        testA.name = "yangliang";
        System.out.println(testA.name);
        ITest iTest = testA;
        System.out.println(iTest.getName());
        TestMyClass testMyClass = new TestMyClass();
        System.out.println(testMyClass.name);
    }

    static class TestMyClass {
        protected String name;
    }

    static class TestIClass extends TestMyClass {
        public TestIClass() {
            System.out.println(this.name);
        }
    }
}
