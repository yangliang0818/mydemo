package com.设计模式.设计模式4_建造者模式_Builder;

import com.设计模式.设计模式1_工厂方法模式_FactoryMethod.T1普通工厂模式.MailSender;
import com.设计模式.设计模式1_工厂方法模式_FactoryMethod.T1普通工厂模式.Sender;
import com.设计模式.设计模式1_工厂方法模式_FactoryMethod.T1普通工厂模式.SmsSender;


import java.util.ArrayList;
import java.util.List;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class Builder {
    private List<Sender> list = new ArrayList<Sender>();
    public void produceMailSender(int count){
        for(int i=0; i<count; i++){
            list.add(new MailSender());
        }
    }
    public void produceSmsSender(int count){
        for(int i=0; i<count; i++){
            list.add(new SmsSender());
        }
    }

    public List<Sender> getList() {
        return list;
    }
}
