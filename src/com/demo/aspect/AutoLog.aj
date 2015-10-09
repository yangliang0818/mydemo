package com.demo.aspect;




/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public aspect AutoLog {
    pointcut publicMethods() : execution(public * org.apache.cactus..*(..));
    pointcut logObjectCalls() :
            execution(* Logger.*(..));

    pointcut loggableCalls() : publicMethods() && ! logObjectCalls();

    before() : loggableCalls(){
        //Logger.entry(thisJoinPoint.getSignature().toString());
    }

    after() : loggableCalls(){
        //Logger.exit(thisJoinPoint.getSignature().toString());
    }
}
