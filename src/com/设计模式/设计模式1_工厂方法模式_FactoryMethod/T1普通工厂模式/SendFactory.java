package com.设计模式.设计模式1_工厂方法模式_FactoryMethod.T1普通工厂模式;

import java.util.HashMap;
import java.util.Map;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class SendFactory {
    //原始设计
    public Sender produce(String type) {
        if ("mail".equals(type)) {
            return new MailSender();
        } else if ("sms".equals(type)) {
            return new SmsSender();
        } else {
            System.out.println("请输入正确的类型!");
            return null;
        }
    }

    private static Map<String, TypeEnum> typeEnumMap = new HashMap<String, TypeEnum>();

    enum TypeEnum {
        mail(new MailSender()), sms(new SmsSender());
        Sender sender;

        TypeEnum(Sender sender) {
            this.sender = sender;
            typeEnumMap.put(toString(), this);
        }

        static Sender getInstance(String type) {
            return null == typeEnumMap.get(type) ? null : typeEnumMap.get(type).sender;
        }
    }

    //改进设计
    public Sender produceNG(String type) {
        return TypeEnum.getInstance(type);
    }

}
