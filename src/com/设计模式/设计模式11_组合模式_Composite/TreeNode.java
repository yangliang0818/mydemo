package com.设计模式.设计模式11_组合模式_Composite;

import java.util.Enumeration;
import java.util.Vector;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class TreeNode {
    private String name;
    private TreeNode parent;
    private Vector<TreeNode> children = new Vector<TreeNode>();

    public TreeNode(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public TreeNode getParent() {
        return parent;
    }

    public void setParent(TreeNode parent) {
        this.parent = parent;
    }

    //添加孩子节点
    public void add(TreeNode node) {
        children.add(node);
    }

    //删除孩子节点
    public void remove(TreeNode node) {
        children.remove(node);
    }

    //取得孩子节点
    public Enumeration<TreeNode> getChildren() {
        return children.elements();
    }
}
