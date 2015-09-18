package com.设计模式.设计模式11_组合模式_Composite;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class Tree {
    TreeNode root = null;

    public Tree(String name) {
        root = new TreeNode(name);
    }
}
