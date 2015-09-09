package com.demo;

import java.nio.charset.Charset;

/**
 * SOFTSI-助力信息时代互联互通
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/8
 * Description:
 */
public class TestArraycopy {
    public static void main(String[] args) {
        byte[] b1 = new byte[]{'A', 'B', 'C'};
        byte[] b2 = new byte[3];
        char[] c1 = new char[]{'杨'};
        System.arraycopy(b1, 2, b2, 0, 1);
        System.out.println(new String(b2));
        System.out.println(c1);
        System.out.println(Charset.defaultCharset());

    }
}
