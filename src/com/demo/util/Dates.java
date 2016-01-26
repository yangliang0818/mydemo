package com.demo.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
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

    public static Date format(String date) throws ParseException {
        SimpleDateFormat dateFormat = new SimpleDateFormat(DateType.Today.getValue());
        return dateFormat.parse(date);
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
    public static String getToday(String str, DateType fdateType, DateType tdateType) throws ParseException {
        SimpleDateFormat date = new SimpleDateFormat(tdateType.getValue());
        return date.format(new SimpleDateFormat(fdateType.getValue()).parse(str));
    }

    /**
     * 获取时
     *
     * @param date
     * @return
     * @throws ParseException
     */
    public static int getHH(String date) throws ParseException {
        SimpleDateFormat dateFormat = new SimpleDateFormat(DateType.DateTime.getValue());
        return dateFormat.parse(date).getHours();
    }

    /**
     * 获取分
     *
     * @param date
     * @return
     * @throws ParseException
     */
    public static int getMM(String date) throws ParseException {
        SimpleDateFormat dateFormat = new SimpleDateFormat(DateType.DateTime.getValue());
        return dateFormat.parse(date).getMinutes();
    }

    /**
     * 获取当前时间常量
     *
     * @return
     */
    public static long getDayLong() {
        return new Date().getTime();
    }

    public static String getTimeOf0() {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        cal.add(Calendar.DAY_OF_MONTH, 0);
        SimpleDateFormat dateFormat = new SimpleDateFormat(DateType.DateTime.getValue());
        return dateFormat.format(cal.getTime());
    }

    /**
     * 将一个时间格式yyyy-MM-dd HH:mm:ss加天数
     * 后返回一个Date类型日期
     *
     * @param time
     * @param days
     * @return
     */
    public static Date addDay(String time, int days) throws ParseException {
        SimpleDateFormat dateFormat = new SimpleDateFormat(DateType.DateTime.getValue());
        Date date = dateFormat.parse(time);
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        cal.add(Calendar.DAY_OF_MONTH, days);
        return cal.getTime();
    }

    public static void main(String[] args) throws ParseException {
        String date = "2015-10-09 00:00:00.0";
        SimpleDateFormat sdf = new SimpleDateFormat(DateTypeEnum.时分秒格式.value);
        System.out.println(sdf.parse(date));
        System.out.println(format("2015-12-27"));
        System.out.println(getTimeOf0());
        SimpleDateFormat dateFormat=new SimpleDateFormat(DateType.DateTime.getValue());
        String time=dateFormat.format(addDay("2015-12-31 23:12:23",1));
        System.out.println(time);
    }

}
