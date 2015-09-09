package com.softsi.service;

import com.softsi.dao.UserDao;
import com.softsi.model.UserModel;

/**
 * 上海软思信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/15
 * Description:
 */
public interface UserService {
    void add(UserModel userModel);

    UserDao getUserDao();

    void setUserDao(UserDao userDao);
}
