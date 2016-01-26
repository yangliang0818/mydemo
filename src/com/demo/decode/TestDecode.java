package com.demo.decode;

import java.io.UnsupportedEncodingException;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/11/23
 * Description:
 */
public class TestDecode {
    public static void main(String[] args) throws UnsupportedEncodingException {
        String value=new String("123123快钱".getBytes("GBK"),"ISO8859-1");
        System.out.println(value);
        System.out.println(new String(value.getBytes("ISO8859-1"),"GBK"));
    }
}
