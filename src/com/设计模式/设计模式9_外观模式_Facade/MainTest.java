package com.设计模式.设计模式9_外观模式_Facade;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:如果我们没有Computer类，
 * 那么，CPU、Memory、Disk他们之间将会相互持有实例，
 * 产生关系，这样会造成严重的依赖，修改一个类，可能
 * 会带来其他类的修改，这不是我们想要看到的，有了
 * Computer类，他们之间的关系被放在了Computer类里，
 * 这样就起到了解耦的作用，这，就是外观模式！
 */
public class MainTest {
    public static void main(String[] args) {
        Computer computer = new Computer();
        computer.startup();
        computer.shutdown();
    }
}
