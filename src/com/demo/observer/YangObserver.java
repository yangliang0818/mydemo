package com.demo.observer;

import java.util.Observable;
import java.util.Observer;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/28
 * Description:
 */
public class YangObserver implements Observer {

    public YangObserver(Observable o) {
        o.addObserver(this);
    }

    @Override
    public void update(Observable o, Object arg) {
        System.out.println("我是yangliang，我在编码");
    }
}
