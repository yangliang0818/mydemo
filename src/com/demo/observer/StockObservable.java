package com.demo.observer;

import java.util.Observable;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/28
 * Description:
 */
public class StockObservable extends Observable {
    public float price;

    public float getPrice() {
        return price;
    }

    public void setPrice(float price) {
        this.price = price;
        this.setChanged();
        this.notifyObservers();
    }
}
