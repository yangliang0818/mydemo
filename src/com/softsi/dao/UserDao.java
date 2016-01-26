package com.softsi.dao;

import com.softsi.bean.UserBean;
import org.springframework.orm.hibernate3.HibernateTemplate;
import org.springframework.stereotype.Component;

/**
 * 软思科技-助力信息时代互联互通
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/15
 * Description:
 */
@Component
public class UserDao {
    private HibernateTemplate hibernateTemplate;

    public void add(UserBean u) {
        System.out.println("UserDao.add()");
        hibernateTemplate.save(u);
    }

    public HibernateTemplate getHibernateTemplate() {
        return hibernateTemplate;
    }

    public void setHibernateTemplate(HibernateTemplate hibernateTemplate) {
        this.hibernateTemplate = hibernateTemplate;
    }
}
