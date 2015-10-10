package com.demo;

/**
 * SOFTSI-助力信息时代互联互通
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/14
 * Description:
 */
@TestAnnotation(hello = false, word = "yangliang",typeEnum = TestAnnotation.TypeEnum.TYPE2,clazz = TestMyAnnotation.class)
public class TestMyAnnotation {
    @TestFieldAnnotaion(filedCN = "杨亮")
    private String name;

    @TestFieldAnnotaion(filedCN = "男")
    private String sex;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }
}
