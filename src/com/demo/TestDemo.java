package com.demo;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by 003631 on 2015/7/6.
 */
public class TestDemo {
    public static void main(String[] args) {
        String regex = "^[0-9]";
        Pattern pattern = Pattern.compile(regex, Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher("360");
        /*System.out.println(matcher.find());
        System.out.println(new TestMethodInnerClass.TestMyClass().name);*/
        double x = 94;
        double y = 84;
        double z = 80;
        System.out.println(x * 0.5 + y * 0.35 + z * 0.15);
        /*double x1=100;
        double y1=83.4;
        double z1=83;
        System.out.println(x1 * 0.5 + y1 * 0.35 + z1 * 0.15);*/
    }
}
