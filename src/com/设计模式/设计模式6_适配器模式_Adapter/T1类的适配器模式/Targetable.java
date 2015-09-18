package com.设计模式.设计模式6_适配器模式_Adapter.T1类的适配器模式;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public interface Targetable {
    /* 与原类中的方法相同 */
    public void method1();

    /* 新类的方法 */
    public void method2();
}
