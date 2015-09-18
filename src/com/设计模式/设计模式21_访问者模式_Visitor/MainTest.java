package com.设计模式.设计模式21_访问者模式_Visitor;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class MainTest {
    public static void main(String[] args) {
        Visitor visitor = new MyVisitor();
        Subject sub = new MySubject();
        sub.accept(visitor);
        visitor =new IVisitor();
        sub.accept(visitor);
    }
}
