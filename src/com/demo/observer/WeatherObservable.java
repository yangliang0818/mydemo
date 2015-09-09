package com.demo.observer;


import java.util.Observable;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/28
 * Description:
 */
public class WeatherObservable extends Observable {

    private String weather;

    public String getWeather() {
        return weather;
    }

    public void setWeather(String weather) {
        this.weather = weather;
        this.setChanged();
        this.notifyObservers();
    }
}
