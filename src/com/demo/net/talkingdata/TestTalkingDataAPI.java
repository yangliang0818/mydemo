package com.demo.net.talkingdata;

import net.sf.json.JSONObject;

import java.io.IOException;

/**
 * 上海好屋网信息技术有限公司
 * Copyright (C), 2012-2015
 * Author:   YangLiang 003631
 * Date:     2015/11/16
 * Description:
 */
public class TestTalkingDataAPI {
    public static void main(String[] args) throws IOException {
        //查询一段时间范围内，每日的新增用户
        String api_url = "https://api.talkingdata.com/metrics/app/v1";
        JSONObject filter = new JSONObject();
        filter.put("start", "2015-04-01");
        filter.put("end", "2015-04-07");
        filter.put("platformid_list", new int[]{1});
        JSONObject params = new JSONObject();
        params.put("filter", filter);
        params.put("metrics", new String[]{"newuser"});
        params.put("groupby", "daily");
        params.put("accesskey", "eb103ef8eb01abf798cde6374da8f568");//accesskey should be replaced
        System.out.println(TalkingDataHttpClient.doPost(api_url, params));

        //查询 version list，如果需要过滤平台可添加相应filter
        String query_url = "https://api.talkingdata.com/metrics/app/v1/versionlist";
        params = new JSONObject();
        params.put("accesskey", "eb103ef8eb01abf798cde6374da8f568");//accesskey should be replaced
        System.out.println(TalkingDataHttpClient.doPost(query_url, params));
    }
}
