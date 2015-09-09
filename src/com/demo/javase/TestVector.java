package com.demo.javase;

import java.util.Vector;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/8/4
 * Description:
 */
public class TestVector {
    public static void main(String[] args) {
        Vector vector = new Vector();
        vector.add(111);
        vector.add(2222);
        for (int i = 0; i < vector.size(); i++) {
            System.out.println(vector.get(i));
        }
    }
}
