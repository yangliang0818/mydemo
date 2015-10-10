package com.demo;

import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * SOFTSI-助力信息时代互联互通
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/14
 * Description:
 */
public class TestMainAnnotation {
    public static void main(String[] args) throws NoSuchMethodException, InvocationTargetException, IllegalAccessException, ClassNotFoundException, NoSuchFieldException, InstantiationException {
        Class clazz = Class.forName("com.demo.TestMyAnnotation");
        Annotation[] annotation = clazz.getAnnotations();
        Field filed =clazz.getDeclaredField("name");
        System.out.println(filed.getAnnotation(TestFieldAnnotaion.class).filedCN());
        TestAnnotation testAnnotation = (TestAnnotation) annotation[0];
        Method method = TestAnnotation.class.getMethod("hello");
        System.out.println(method.invoke(annotation[0]));
        System.out.println(testAnnotation.flag);
        System.out.println(testAnnotation.toString());
        System.out.println(50000 - 14257.1);
        System.out.println(testAnnotation.clazz().toString());
        System.out.println(testAnnotation.clazz().newInstance());
    }
}
