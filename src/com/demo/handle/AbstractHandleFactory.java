package com.demo.handle;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/27
 * Description:
 */
public class AbstractHandleFactory {
    public static AbstractHandle createHandle() {
        CEO ceo = new CEO();
        Manager manager = new Manager(ceo);
        Leader leader = new Leader(manager);
        Sales sales = new Sales(leader);
        return sales;
    }
}
