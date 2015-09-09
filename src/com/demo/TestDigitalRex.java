package com.demo;

import java.util.regex.Pattern;

/**
 * SOFTSI-助力信息时代互联互通
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/10
 * Description:
 */
public class TestDigitalRex {
    public static void main(String[] args) {
        //如果是以数字开头则在前面加一个_否则直接实例化
        System.out.println(Pattern.compile("^[0-9]", Pattern.CASE_INSENSITIVE).matcher("360").find() ? "_360" : "360");
    }
}
