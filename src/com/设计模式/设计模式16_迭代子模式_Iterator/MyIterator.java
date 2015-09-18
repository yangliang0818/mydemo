package com.设计模式.设计模式16_迭代子模式_Iterator;


/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/9/18
 * Description:
 */
public class MyIterator implements Iterator {
    private Collection collection;
    private int pos = -1;

    public MyIterator(Collection collection) {
        this.collection = collection;
    }

    @Override
    public Object previous() {
        if (pos > 0) {
            pos--;
        }
        return collection.get(pos);
    }

    @Override
    public Object next() {
        if (pos < collection.size() - 1) {
            pos++;
        }
        return collection.get(pos);
    }

    @Override
    public boolean hasNext() {
        if (pos < collection.size() - 1) {
            return true;
        } else {
            return false;
        }
    }
    @Override
    public Object first() {
        pos = 0;
        return collection.get(pos);
    }
}
