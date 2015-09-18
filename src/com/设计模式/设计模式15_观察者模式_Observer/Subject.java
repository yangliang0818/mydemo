package com.设计模式.设计模式15_观察者模式_Observer;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public interface Subject {
    /*增加观察者*/
    void add(Observer observer);

    /*删除观察者*/
    void del(Observer observer);

    /*通知所有的观察者*/
    void notifyObservers();

    /*自身的操作*/
    void operation();
}
