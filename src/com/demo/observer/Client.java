package com.demo.observer;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/28
 * Description:
 */
public class Client {
    public static void main(String[] args) {
        //天气被观察者
        WeatherObservable weather = new WeatherObservable();
        //股票被观察者
        StockObservable stock = new StockObservable();
        //创建默认观察者
        //创建yangliang观察者
        YangObserver yang = new YangObserver(weather);
        CaiObserver cai = new CaiObserver(stock);
        //设置天气
        weather.setWeather("晴天");
        //设置股价
        stock.setPrice(12.4f);
    }
}
