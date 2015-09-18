package com.设计模式.设计模式5_原型模式_Prototype;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class MainTest {
    public static void main(String[] args) throws Exception {
        Prototype baseObj = new Prototype();
        baseObj.setString("Yang Liang");
        baseObj.setObj(new SerializableObject());
        print(baseObj);
        //浅复制
        Prototype prototype = (Prototype) baseObj.clone();
        print(prototype);
        //深复制
        prototype = (Prototype) baseObj.deepClone();
        print(prototype);

    }

    public static void print(Prototype prototype) {
        System.out.println(prototype);
        System.out.println(prototype.getString());
        System.out.println(prototype.getObj());
        System.out.println("-----------------------");
    }
}
