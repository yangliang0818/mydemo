package com.demo.handle;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/27
 * Description:
 */
public class CEO extends AbstractHandle {
    @Override
    public void dealDiscount(double discount) {
        if (discount <= 0.35) {
            System.out.format("CEO%s处理折扣%f", this.getClass().getSimpleName(), discount);
        } else {
            System.out.format("CEO也不能处理此%f折扣", discount);
        }
    }
}
