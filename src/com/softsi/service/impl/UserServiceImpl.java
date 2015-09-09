package com.softsi.service.impl;

import com.softsi.bean.UserBean;
import com.softsi.dao.UserDao;
import com.softsi.model.UserModel;
import com.softsi.service.UserService;

/**
 * 软思科技-助力信息时代互联互通
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/15
 * Description:
 */
public class UserServiceImpl implements UserService {
    private UserDao userDao;

    @Override
    public void add(UserModel userModel) {
        System.out.println("UserService.add()");
        UserBean u = new UserBean();
        u.setName(userModel.getName());
        u.setSex(userModel.getSex());
        userDao.add(u);
    }

    @Override
    public UserDao getUserDao() {
        return userDao;
    }

    @Override
    public void setUserDao(UserDao userDao) {
        this.userDao = userDao;
    }
}
