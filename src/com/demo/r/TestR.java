package com.demo.r;

import org.rosuda.REngine.REXP;
import org.rosuda.REngine.REXPMismatchException;
import org.rosuda.REngine.REXPString;
import org.rosuda.REngine.RList;
import org.rosuda.REngine.Rserve.RConnection;
import org.rosuda.REngine.Rserve.RserveException;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/8/4
 * Description: Java调用R语言Demo
 */
public class TestR {
    public static void main(String[] args) throws RserveException, REXPMismatchException {
        RConnection c = new RConnection();
        REXP x = c.eval("R.version");
        parseREXP(x);
        x = c.eval("1+2");
        System.out.println(x.asInteger());
        parseREXP(c.eval("objects()"));
        parseREXP(c.eval("ls()"));
        System.out.println("---------");
        parseREXP(c.eval("0/0"));
    }

    /**
     * 解析R执行的命令返回的结果
     *
     * @param x
     * @throws REXPMismatchException
     */
    private static void parseREXP(REXP x) throws REXPMismatchException {
        if (x.isList()) {
            RList rList = x.asList();
            for (int i = 0; i < rList.size(); i++) {
                REXPString str = (REXPString) rList.get(i);
                System.out.println(str.asString());
            }
        } else if (x.isString()) {
            System.out.println(x.asString());
        }
    }

}
