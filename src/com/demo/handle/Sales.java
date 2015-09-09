package com.demo.handle;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/27
 * Description:
 */
public class Sales extends AbstractHandle {


    public Sales(AbstractHandle parent) {
        super(parent);
    }

    @Override
    public void dealDiscount(double discount) {
        if (discount <= 0.05) {
            System.out.format("销售员%s处理折扣%f", this.getClass().getSimpleName(), discount);
        } else {
            parent.dealDiscount(discount);
        }
    }
}
