package com.demo.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

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
    /**
     * 日期格式枚举
     */
    public static enum DateType {
        DateTime("yyyy-MM-dd HH:mm:ss"),
        TodayCN("yyyy年MM月dd日"),
        Today("yyyy-MM-dd"),
        Today2("yyyy年MM月dd日 HH:mm"),
        Today3("yyyy-MM-dd HH:mm"),
        Today4("yyyyMMdd");

        private String value;

        public String getValue() {
            return value;
        }

        DateType(String value) {
            this.value = value;
        }
    }

    /**
     * 获取当前时间
     *
     * @return
     */
    public static String getDateTime() {
        SimpleDateFormat date = new SimpleDateFormat(DateType.DateTime.getValue());
        return date.format(new Date());
    }
    /**
     * 获取当天
     *
     * @return
     */
    public static String getToday(DateType dateType) {
        SimpleDateFormat date = new SimpleDateFormat(dateType.getValue());
        return date.format(new Date());
    }
    /**
     * 获取当天
     *
     * @return
     */
    public static String getToday(String str,DateType fdateType,DateType tdateType) throws ParseException {
        SimpleDateFormat date = new SimpleDateFormat(tdateType.getValue());
        return date.format(new SimpleDateFormat(fdateType.getValue()).parse(str));
    }

    /**
     * 获取时
     * @param date
     * @return
     * @throws ParseException
     */
    public static int getHH(String date) throws ParseException {
        SimpleDateFormat dateFormat=new SimpleDateFormat(DateType.DateTime.getValue());
        return dateFormat.parse(date).getHours();
    }

    /**
     * 获取分
     * @param date
     * @return
     * @throws ParseException
     */
    public static int getMM(String date) throws ParseException {
        SimpleDateFormat dateFormat=new SimpleDateFormat(DateType.DateTime.getValue());
        return dateFormat.parse(date).getMinutes();
    }

    /**
     * 获取当前时间常量
     * @return
     */
    public static long getDayLong(){
        return new Date().getTime();
    }
    public static void main(String[] args) throws ParseException {
        String date="2015-10-09 00:00:00.0";
        SimpleDateFormat sdf=new SimpleDateFormat(DateTypeEnum.时分秒格式.value);
        System.out.println(sdf.parse(date));
        System.out.println();
    }
}
