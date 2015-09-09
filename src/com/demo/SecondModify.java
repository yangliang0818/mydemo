package com.demo;

import java.io.*;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 只修改程序的中字段的长度
 *
 * @author Administrator
 * @time 2012-12-17
 */

public class SecondModify {


    /**
     * 1. 读取最外面的文件，递归找内部的每个文件夹（只嵌套两层  aa/bb/文件.sqC|sqc）
     * 2. 将文件读出按字符串处理（使用正则表达式做匹配）
     * 3. 将修改后的结果保存下来 （日志记录）
     *
     * @param args
     */
    private int count = 0;//统计一共多少个程序
    private String proPath = ""; //程序的完整路径（路径+程序名字）
    private String proName = ""; //程序的名字
    private StringBuffer content = null;//存放一个程序的内容
    private boolean Mod = false;
    private StringBuffer modContent = null;//记录修改内容

    private String replaceText = "";//字段和类型
    private String[][] modFields = new String[406][4];
    private long time = 0;
    private long startTime = 0;
    private long endTime = 0;

    /**
     * 主要执行函数
     */
    private void mainDealFun() {

        this.initFieldArray();
        File outDire = new File(FinalData.OUTPATH);
        if (outDire.isDirectory()) {
            for (File inDire : outDire.listFiles()) {
                if (inDire.isDirectory()) {
                    for (File file : inDire.listFiles()) {
                        //获取当前程序的路径
                        proPath = file.getAbsolutePath();
                        proName = file.getName();

                        //读取到当前程序的内容
                        //开始计时
                        startTime = System.currentTimeMillis();
                        content = readFile(file);
                        //处理当前程序的内容(count计数)
                        Mod = false;
                        modContent = new StringBuffer();
                        content = changePro(content);
                        //将处理完的内容写入文件（文件的路径不变）

                        if (Mod) {
                            //记录日志
                            writeLog(proName, proPath, modContent);
                            //保存文件
                            saveFile(content, proPath);
                        }
                        //结束计时
                        endTime = System.currentTimeMillis();

                        //打印时间
                        time += (endTime - startTime);
                        System.out.println((++count) + "时间:" + (double) (endTime - startTime) / 1000 + "秒,路径为" + proPath);
                    }
                }
            }
        }
        System.out.println("-------共执行了" + (double) time / 1000 + "秒！！-------");
    }

    /**
     * 读取当前程序的内容
     */
    private StringBuffer readFile(File file) {
        StringBuffer content = new StringBuffer();
        FileReader fr = null;
        BufferedReader buf = null;

        try {
            fr = new FileReader(file);
            buf = new BufferedReader(fr);
            char chs[] = new char[2048];
            int res = 0;
            String str = null;
            //获取当前程序的内容
            res = buf.read(chs);
            while (res != -1) {
                //System.out.println("res=="+res+"><><><><><>chs"+chs.length);
                str = new String(chs, 0, res);
                content.append(str);
                res = buf.read(chs);
            }
        } catch (FileNotFoundException e) {

            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (buf != null) {
                    buf.close();
                }
                if (fr != null) {
                    fr.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return content;
    }

    /**
     * 对content做处理替换,记录修改了几处，并作记录
     */
    private StringBuffer changePro(StringBuffer content) {

        String contentStr = content.toString();
        if (content != null && content.length() != 0) {
            //对同一个文件分别修改对应的字段
            String fieldName = "";//字段名
            for (int i = 0; i < modFields.length; i++) {

                //获取到修改字段的名字
                fieldName = modFields[i][0];
                //打印测试
                //System.out.println("=========="+fieldName);

                String regex = "sn{0,1}printf[^;]*((\\b" + fieldName + "\\b)\\s+((CHAR\\s*\\([0-9]+\\)|VARCHAR\\s*\\([0-9]+\\)|INTEGER|INT)))[^;]+;";
                Pattern pattern = Pattern.compile(regex, Pattern.CASE_INSENSITIVE);
                Matcher matcher = pattern.matcher(content);
                String sour = "";//保存sprintf到;
                String dest = "";
                String oldType = "";
                String newType = "";
                while (matcher.find()) {
                    sour = matcher.group(0);
                    replaceText = matcher.group(1);
                    //fieldName = matcher.group(2);
                    oldType = matcher.group(3);
                    //打印测试
                    //System.out.println("+++++++++"+oldType);
                    if (IsModify(fieldName, oldType, i)) {
                        newType = getNewType(fieldName, oldType, i);
                        //修改内容
                        modContent.append(fieldName + ":" + oldType + "--->" + newType + ";");
                        dest = sour.replace(replaceText, (fieldName + "   " + newType));
                        contentStr = contentStr.replace(sour, dest);
                        Mod = true;
                    }
                }
                content = new StringBuffer(contentStr);
            }

        }
        return new StringBuffer(contentStr);
    }

    /**
     * 判断字段类型是否需要修改
     */
    private boolean IsModify(String fieldName, String oldType, int index) {

        if (!oldType.toLowerCase().contains("int") && !oldType.toLowerCase().contains("char")) {
            return false;
        }
        if (oldType.toLowerCase().equals("bigint")) {
            return false;
        }

        if (oldType.toLowerCase().contains("char")) {
            //截取字符串长度
            String num = oldType.substring(oldType.indexOf("(") + 1, oldType.indexOf(")"));
            int length = Integer.valueOf(num);
            //取得新类型长度
            int newLength = Integer.valueOf(modFields[index][2]);
            //判断
            if (length >= newLength) {
                return false;
            }
        }
        return true;
    }

    /**
     * 通过旧类型获取新类型
     */
    private String getNewType(String fieldName, String oldType, int index) {

        if (oldType.toLowerCase().contains("char")) {

            return modFields[index][1];
        } else if (oldType.toLowerCase().contains("int")) {
            return modFields[index][3];
        }
        return null;
    }

    /**
     * 依据路径去保存一个程序的内容
     */
    private boolean saveFile(StringBuffer content, String proPath) {
        FileWriter fw = null;
        BufferedWriter bufWriter = null;
        try {
            if (content != null && content.length() != 0 && proPath != null && !proPath.equals("")) {
                File file = new File(proPath);
                fw = new FileWriter(file);
                bufWriter = new BufferedWriter(fw);
                bufWriter.write(content.toString());
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (bufWriter != null) {
                    bufWriter.close();
                }
                if (fw != null) {
                    fw.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return false;
    }


    /**
     * 写日志
     *
     * @param args
     */
    private void writeLog(String proName, String proPath, StringBuffer modContent) {

        /*String logMsg = proName+"\t\t\t\t\t"+new Time(System.currentTimeMillis())+proPath
                      +"修改plan_id"+plan_count+"次;"
                      +"修改product_id"+product_count+"\r\n";*/

        String logMsg = proName + "," + proPath.replace(proName, "") + "修改的内容有(" + modContent + ")\r\n";
        File file = null;
        FileWriter fw = null;
        try {
            file = new File(FinalData.LOGPATH);
            if (!file.exists()) {
                file.createNewFile();
            }
            fw = new FileWriter(file, true);
            fw.write(logMsg);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (fw != null) {
                    fw.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }


    /**
     * 读取文件初始化字段数组
     *
     * @param args
     */
    public void initFieldArray() {

        File file = null;
        FileReader fr = null;
        BufferedReader br = null;
        try {
            file = new File(FinalData.CONFIGERPATH);
            fr = new FileReader(file);
            br = new BufferedReader(fr);
            String line = "";
            StringTokenizer st = null;
            String str = "";
            int x = 0, y = 0;
            while ((line = br.readLine()) != null) {
                st = new StringTokenizer(line, ",");
                while (st.hasMoreTokens()) {
                    modFields[x][y++] = st.nextToken().trim();
                }
                y = 0;
                x++;
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (fr != null) {
                    fr.close();
                }
                if (br != null) {
                    br.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        //printArray(modFields);
    }

    /**
     * 测试用
     *
     * @param modFields
     */
    private void printArray(String[][] modFields) {
        int i = 0;
        for (; i < modFields.length; i++) {
            System.out.println(modFields[i][0] + "=" + modFields[i][1] + "=" + modFields[i][2] + "=" + modFields[i][3]);
        }
        System.out.println(i);
    }

    public static void main(String[] args) {

        new SecondModify().mainDealFun();

    }
}


