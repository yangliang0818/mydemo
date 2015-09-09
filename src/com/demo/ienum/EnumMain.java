package com.demo.ienum;


import java.util.Arrays;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/7
 * Description:
 */
public class EnumMain {
    public static void main(String[] args) {
        IEnum iEnum = MyEnum.YANG;
        iEnum.sayHello();
        iEnum=MyEnum.CAI;
        iEnum.sayHello();
        System.out.println(MyEnum.values().toString());
    }

    enum MyEnum implements IEnum {
        YANG {
            @Override
            public void sayHello() {
                System.out.println("YANGLIANG");
            }
        }, CAI {

        };

        @Override
        public void sayHello() {
            System.out.println("MyEnum is Common");
        }
    }


    interface IEnum {
        void sayHello();
    }
}
