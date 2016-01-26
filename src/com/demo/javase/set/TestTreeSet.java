package com.demo.javase.set;

import java.util.TreeSet;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/11/5
 * Description:
 */
public class TestTreeSet {
    public static void main(String[] args) {
        TreeSet treeSet = new TreeSet();
        treeSet.add(1);
        treeSet.add(3);
        treeSet.add(4);
        treeSet.add(5);
        //返回小于等于当前值的对象
        System.out.println(treeSet.floor(4));
        //返回小于当前值的对象
        System.out.println(treeSet.lower(4));
        //返回大于等于当前值的对象
        System.out.println(treeSet.ceiling(4));
        //返回大于当前值的对象
        System.out.println(treeSet.higher(4));
        //获取并移除第一个（最低）元素；如果此 set为空，则返回 null。
        System.out.println(treeSet.pollFirst());
        System.out.println(treeSet);
        //获取并移除最后一个（最高）元素；如果此 set为空，则返回 null。
        System.out.println(treeSet.pollLast());
        System.out.println(treeSet);
    }
}
