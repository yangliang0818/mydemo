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
public class CaiObserver implements Observer {

    public CaiObserver(Observable o) {
        o.addObserver(this);
    }

    @Override
    public void update(Observable o, Object arg) {
        StockObservable stock = (StockObservable) o;
        System.out.println("我是cai,今天股价" + stock.getPrice() + "我正在炒股!");
    }
}
