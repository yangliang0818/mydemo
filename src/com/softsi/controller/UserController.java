package com.softsi.controller;

import com.softsi.model.UserModel;
import com.softsi.service.UserService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/7/15
 * Description:
 */
@RequestMapping("/")
public class UserController {
    private UserService userService;

    @RequestMapping(value = "user")
    public ModelAndView reg(UserModel userModel) {
        System.out.println(userModel.getName());
        System.out.println(userModel.getSex());
        userService.add(userModel);
        return new ModelAndView("success");
    }
    /*@Override
    public ModelAndView handleRequest(HttpServletRequest req,
                                      HttpServletResponse resp) throws Exception {
        System.out.println("HelloController.handleRequest()");
        req.setAttribute("a", "aaaa");
        userService.add(req.getParameter("uname"));
        return new ModelAndView("index");
    }*/

    public UserService getUserService() {
        return userService;
    }

    public void setUserService(UserService userService) {
        this.userService = userService;
    }
}
