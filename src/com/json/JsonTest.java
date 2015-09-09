package com.json;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sf.json.JsonConfig;
import net.sf.json.util.PropertyFilter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by 003631 on 2015/7/6.
 */
public class JsonTest {
    public static void main(String args[]) {
        beanToJson();
        beanToJson1();
        beanToJson2();
        arrayToJson();
        listToJson();
        mapToJson();

    }


    /**
     * bean对象转json
     *
     * @return void
     */
    public static void beanToJson() {
        Employer employer = new Employer();
        employer.setName("小王");
        employer.setAge(23);
        employer.setDepartment("产品研发");
        JSONObject json = JSONObject.fromObject(employer);
        System.out.println("-----------------------------------------beanToJson() 开始------------------------------------------------");
        System.out.println(json.toString());
        System.out.println("-----------------------------------------beanToJson() 结束------------------------------------------------");
    }

    /**
     * bean对象转json,带过滤器
     *
     * @return void
     */
    public static void beanToJson1() {
        Employer employer = new Employer();
        employer.setName("小王");
        employer.setAge(23);
        employer.setDepartment("产品研发");
        JsonConfig jsonConfig = new JsonConfig();
        jsonConfig.setExcludes(new String[]
                {"age"});
        JSONObject json = JSONObject.fromObject(employer, jsonConfig);
        System.out.println("-----------------------------------------beanToJson1()带过滤器 开始------------------------------------------------");
        System.out.println(json.toString());
        System.out.println("-----------------------------------------beanToJson1()带过滤器 结束------------------------------------------------");
    }

    /**
     * bean对象转json,带过滤器
     *
     * @return void
     */
    public static void beanToJson2() {
        Employer employer = new Employer();
        employer.setName("小王");
        employer.setAge(23);
        employer.setDepartment("产品研发");
        JsonConfig jsonConfig = new JsonConfig();
        jsonConfig.setJsonPropertyFilter(new PropertyFilter() {
            public boolean apply(Object source, String name, Object value) {
                return source instanceof Employer && name.equals("age");
            }
        });
        JSONObject json = JSONObject.fromObject(employer, jsonConfig);
        System.out.println("-----------------------------------------beanToJson2() 带过滤器 开始------------------------------------------------");
        System.out.println(json.toString());
        System.out.println("-----------------------------------------beanToJson2() 带过滤器 结束------------------------------------------------");
    }

    /**
     * array对象转json
     *
     * @return void
     */
    public static void arrayToJson() {
        Employer employer1 = new Employer();
        employer1.setName("小王");
        employer1.setAge(23);
        employer1.setDepartment("产品研发");

        Employer employer2 = new Employer();
        employer2.setName("小王");
        employer2.setAge(23);
        employer2.setDepartment("产品研发");
        Employer[] employers = new Employer[]{employer1, employer2};
        JSONArray json = JSONArray.fromObject(employers);
        System.out.println("-----------------------------------------arrayToJson() 开始------------------------------------------------");
        System.out.println(json.toString());
        System.out.println("-----------------------------------------arrayToJson() 结束------------------------------------------------");
    }

    /**
     * list对象转json
     *
     * @return void
     */
    public static void listToJson() {
        List<String> list = new ArrayList<String>();
        list.add("first");
        list.add("second");
        JSONArray json = JSONArray.fromObject(list);
        System.out.println("-----------------------------------------listToJson() 开始------------------------------------------------");
        System.out.println(json.toString());
        System.out.println("-----------------------------------------listToJson() 结束------------------------------------------------");
    }

    /**
     * map对象转json
     *
     * @return void
     */
    public static void mapToJson() {
        Map<Object, Object> map = new HashMap<Object, Object>();
        map.put("name", "json");
        map.put("bool", Boolean.TRUE);
        map.put("int", new Integer(1));
        map.put("arr", new String[]{"a", "b"});
        map.put("func", "function(i){ return this.arr[i]; }");
        JSONObject json = JSONObject.fromObject(map);
        System.out.println("-----------------------------------------mapToJson() 开始------------------------------------------------");
        System.out.println(json.toString());
        System.out.println("-----------------------------------------mapToJson() 结束------------------------------------------------");
    }
}
