package com.demo;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * SOFTSI-助力信息时代互联互通
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/14
 * Description:
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface TestAnnotation {
    boolean flag = false;

    boolean hello() default true;

    String word() default "";

    TypeEnum typeEnum() default TypeEnum.TYPE1;
    Class clazz();
    enum TypeEnum {
        TYPE1, TYPE2;
    }
}

