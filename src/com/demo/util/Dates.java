package com.demo.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/10/9
 * Description:
 */
public class Dates {
    public static enum DateTypeEnum {
        时分秒格式("yyyy-MM-dd HH:mm:ss"),
        日期格式("yyyy-MM-dd");
        String value;

        DateTypeEnum(String value) {
            this.value = value;
        }
    }
    public static void main(String[] args) throws ParseException {
        String date="2015-10-09 00:00:00.0";
        SimpleDateFormat sdf=new SimpleDateFormat(DateTypeEnum.时分秒格式.value);
        System.out.println(sdf.parse(date));
        System.out.println();
    }
}
