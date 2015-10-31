package com.demo.db;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.sql.*;

/**
 * Created with IntelliJ IDEA.
 * User: Administrator
 * Date: 12-9-11
 * Time: 上午10:12
 * To change this template use File | Settings | File Templates.
 */
public class BaseDao {
    protected static Connection conn;

    public static enum DBEnum {
        HAOWU_13总集成环境("jdbc:mysql://172.16.10.250:3306/hoss_new_20141016_bak?useUnicode=true&amp;characterEncoding=UTF-8&amp;zeroDateTimeBehavior=convertToNull&amp;useLocalSessionState=true", "tm_jdbc", "nicainicai"),
        HOSS开发环境("jdbc:mysql://172.16.10.35:3306/hossv2_new_dev?useUnicode=true&amp;characterEncoding=UTF-8&amp;zeroDateTimeBehavior=convertToNull&amp;useLocalSessionState=true", "fdb_dev", "fdb_dev");
        String username;
        String password;
        String url;

        private DBEnum(String url, String username, String password) {
            this.url = url;
            this.username = username;
            this.password = password;
        }

        public static DBEnum getInstance() throws UnknownHostException {
            InetAddress addr = InetAddress.getLocalHost();
            String ip = addr.getHostAddress().toString();//获得本机IP
            String address = addr.getHostName().toString();//获得本机名称
            /*return ip.indexOf("192") == 0 ? 本地开发环境 : 美橙香港生产环境;*/
            return HOSS开发环境;
        }
    }

    protected Connection getConnnection() throws SQLException, ClassNotFoundException, UnknownHostException {
        Class.forName("com.mysql.jdbc.Driver");
        DBEnum dbEnum = DBEnum.getInstance();
        return conn = DriverManager
                .getConnection(dbEnum.url, dbEnum.username, dbEnum.password);
    }

    /**
     * 自定义获取数据源
     *
     * @param dbEnum
     * @return
     * @throws java.sql.SQLException
     * @throws ClassNotFoundException
     * @throws java.net.UnknownHostException
     */
    public static Connection getConnnection(DBEnum dbEnum) throws SQLException, ClassNotFoundException, UnknownHostException {
        Class.forName("com.mysql.jdbc.Driver");
        return DriverManager
                .getConnection(dbEnum.url, dbEnum.username, dbEnum.password);
    }

    protected void close(Statement statement, Connection conn) throws Exception {
        statement.close();
        conn.close();
    }

    protected void close(Statement statement, Connection conn, ResultSet rs) throws Exception {
        statement.close();
        conn.close();
        rs.close();
    }

    public static void main(String[] args) throws Exception {
        Connection conn = getConnnection(DBEnum.HOSS开发环境);
        System.out.println(conn.toString());
    }
}
