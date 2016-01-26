package com.demo.net.talkingdata.ssl;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import java.io.IOException;
/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/11/16
 * Description:
 */
public class HttpClientUtil {
    /**
     *
     * @param url
     * @param parameter
     * @return
     * @throws IOException
     */
    public static String doPostSSL(String url, Object parameter) throws IOException {
        DefaultHttpClient httpclient = new DefaultHttpClient();
        httpclient = (DefaultHttpClient) WebClientDevWrapper.wrapClient(httpclient);
        System.out.println(parameter);
        HttpPost post = new HttpPost(url);

        post.setHeader("Content-Type", "application/json");

        post.setEntity(new StringEntity(parameter.toString(), "UTF-8"));

        HttpResponse response = httpclient.execute(post);

        HttpEntity entity = response.getEntity();

        return EntityUtils.toString(entity, "UTF-8");
    }


}
