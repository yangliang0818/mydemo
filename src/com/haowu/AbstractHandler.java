package com.haowu;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/12/25
 * Description:
 */
public abstract class AbstractHandler implements Handler {
    private Handler handler;

    public Handler getHandler() {
        return handler;
    }

    public void setHandler(Handler handler) {
        this.handler = handler;
    }

    @Override
    public void updateName() {
        if (null != getHandler()) {
            getHandler().updateName();
        }
    }
}
