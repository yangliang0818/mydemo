package com.demo.strategy;

public class Client {
    public static void main(String[] args) {
        AbstraceWork yangliang = new Yangliang();
        yangliang.go();
        yangliang.work();
        AbstraceWork caina = new Caina();
        caina.go();
        caina.work();
    }
}