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
        System.out.println(matcher.find());
        System.out.println(new TestMethodInnerClass.TestMyClass().name);
    }
}
