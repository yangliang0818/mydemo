package com.设计模式.设计模式7_装饰模式_Decorator;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:装饰器模式的应用场景：

 1、需要扩展一个类的功能。

 2、动态的为一个对象增加功能，而且还能动态撤销。（继承不能做到这一点，继承的功能是静态的，不能动态增删。）

 缺点：产生过多相似的对象，不易排错！
 *
 */
public class MainTest {
    public static void main(String[] args) {
        Sourceable source = new Source();
        Sourceable obj = new Decorator(source);
        obj.method();
    }
}
