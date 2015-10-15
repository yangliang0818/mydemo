package com.demo.net;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

/**
 * Created with IntelliJ IDEA.
 * User: caina
 * Date: 15-9-5
 * Time: 下午5:39
 * To change this template use File | Settings | File Templates.
 */
public class PageMain {
    public static void main(String[] args) {
        readPage();
    }

    public static void readPage() {
        String leibie = "1";
        String num ="吉H";
        StringBuffer temp = new StringBuffer();
        try {
            /*String url = "http://www.baidu.com/jiaojing/ser.php";*/
            String url="http://www.baidu.com/";
            HttpURLConnection uc = (HttpURLConnection) new URL(url).
                    openConnection();
            uc.setConnectTimeout(10000);
            uc.setDoOutput(true);
            uc.setRequestMethod("GET");
            uc.setUseCaches(false);
            DataOutputStream out = new DataOutputStream(uc.getOutputStream());

            // 要传的参数
            String s = URLEncoder.encode("ra", "GB2312") + "=" +
                    URLEncoder.encode(leibie, "GB2312");
            s += "&" + URLEncoder.encode("keyword", "GB2312") + "=" +
                    URLEncoder.encode(num, "GB2312");
            // DataOutputStream.writeBytes将字符串中的16位的unicode字符以8位的字符形式写道流里面
            out.writeBytes(s);
            out.flush();
            out.close();
            InputStream in = new BufferedInputStream(uc.getInputStream());
            Reader rd = new InputStreamReader(in, "utf-8");
            int c = 0;
            while ((c = rd.read()) != -1) {
                temp.append((char) c);
            }
            System.out.println(temp.toString());
            in.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println(temp.toString());
    }
}
