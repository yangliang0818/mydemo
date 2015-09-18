package com.设计模式.设计模式11_组合模式_Composite;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:使用场景：将多个对象组合在一起进行操作，常用于表示树形结构中，例如二叉树，数等。
 */
public class MainTest {
    public static void main(String[] args) {
        Tree tree = new Tree("A");
        TreeNode nodeB = new TreeNode("B");
        TreeNode nodeC = new TreeNode("C");

        nodeB.add(nodeC);
        tree.root.add(nodeB);
        System.out.println("build the tree finished!");
    }
}
