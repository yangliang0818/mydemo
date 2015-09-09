package com.demo.handle;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/27
 * Description:
 */
public abstract class AbstractHandle {
    protected AbstractHandle parent;

    public AbstractHandle() {
    }

    public AbstractHandle(AbstractHandle parent) {
        this.parent = parent;
    }

    /**
     * 处理折扣
     */
    public abstract void dealDiscount(double discount);
}
