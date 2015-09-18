package com.设计模式.设计模式1_工厂方法模式_FactoryMethod.T3静态工厂方法模式;

import com.设计模式.设计模式1_工厂方法模式_FactoryMethod.T1普通工厂模式.MailSender;
import com.设计模式.设计模式1_工厂方法模式_FactoryMethod.T1普通工厂模式.Sender;
import com.设计模式.设计模式1_工厂方法模式_FactoryMethod.T1普通工厂模式.SmsSender;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class SendFactory {
    public static Sender produceMail(){
        return new MailSender();
    }

    public static Sender produceSms(){
        return new SmsSender();
    }
}
