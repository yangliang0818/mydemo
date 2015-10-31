package com.demo.db;

import com.demo.util.Dates;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Created with IntelliJ IDEA.
 * User: yangliang
 * Date: 13-12-8
 * Time: 下午9:42
 * To change this template use File | Settings | File Templates.
 */
public class DB2DB {
    public static final ThreadLocal<Boolean> dbLocal = new ThreadLocal();

    public static void main(String[] args) throws Exception {
        /*deleteSrcTable(objconn, TableEnum.登记律师表.tabname);
        dbLocal.set(true);*/
        long t1=System.currentTimeMillis();
        bakDB(TableEnum.提交记录统计表);
        long t2=System.currentTimeMillis();
        System.out.println("备份"+ TableEnum.提交记录统计表.toString()+"所需毫秒数"+(t2-t1));
        //bakFullDB();
    }

    //源库
    public static Connection srcconn;
    //目标库
    public static Connection objconn;

    static {
        try {
            srcconn = BaseDao.getConnnection(BaseDao.DBEnum.HAOWU_13总集成环境);
            objconn = BaseDao.getConnnection(BaseDao.DBEnum.HOSS开发环境);
            //是否备份结束标志 默认为false表示未结束 为true时关闭流
            dbLocal.set(false);
            //2.备份表djls
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 表枚举类
     */
    public static enum TableEnum {
        新闻咨询表("newask", "select id,qtype,content,askdate,date from newask", "insert into newask (id,qtype,content,askdate,date) values (?,?,?,?,?)", 5),
        登记律师表("djls", "select id,name,phone,lsname,province,city,country,date from djls", "insert into djls(id,name,phone,lsname,province,city,country,date) values(?,?,?,?,?,?,?,?)", 8),
        合作律师表("hzls", "select id,name,area,number,address,tel,email,website,imagename from hzls", "insert into hzls(id,name,area,number,address,tel,email,website,imagename) values(?,?,?,?,?,?,?,?,?)", 9),
        内容推荐表("interest", "select id,pagename,title,url,date,number,model from interest", "insert into interest(id,pagename,title,url,date,number,model) values (?,?,?,?,?,?,?)", 7),
        关键词表("keywords", "select id,title,pagename,keyword from keywords", "insert into keywords (id,title,pagename,keyword) values(?,?,?,?)", 4),
        律师信息表("lawyer", "select id,name,area,fullname,number,phone,qq,mail,firstconntime,firstconnman,content,filepath from lawyer", "insert into lawyer(id,name,area,fullname,number,phone,qq,mail,firstconntime,firstconnman,content,filepath) values(?,?,?,?,?,?,?,?,?,?,?,?)", 12),
        模块链接表("modellink", "select id,type,name,link,date from modellink", "insert into modellink(id,type,name,link,date) values(?,?,?,?,?)", 5),
        所需帮助表("needhelp", "select id,ntype,qtype,province,city,country,name,phone,content,mail,date from needhelp", " insert into needhelp(id,ntype,qtype,province,city,country,name,phone,content,mail,date) values(?,?,?,?,?,?,?,?,?,?,?)", 11),
        新闻信息表("news", "select id,area,title,content,newsDate from news", "insert into news(id,area,title,content,newsDate) values(?,?,?,?,?)", 5),
        新闻信息明细表("newsattr", "select id,newsid,attrDate,attrArea from newsattr", "insert into newsattr(id,newsid,attrDate,attrArea)values(?,?,?,?)", 4),
        新闻记录表("newss", "select id,title,content,newsDate from newss", "insert into newss(id,title,content,newsDate) values(?,?,?,?)", 4),
        案例信息表("press", "select id,area,title,content,newsDate from press", "insert into press(id,area,title,content,newsDate) values(?,?,?,?,?)", 5),
        省份信息表("province", "select id,simplename,name,status from province", "insert into province(id,simplename,name,status) values(?,?,?,?)", 4),
        接待处信息表("servarea", "select id,province,areaname,address,phone from servarea", "insert into servarea(id,province,areaname,address,phone) values(?,?,?,?,?)", 5),
        留言信息表("shiguwen", "select id,ifToll,duty,ifHaveContro,accidentJudge,judgeIfContro,accidentIfContro,phone,content from shiguwen", "insert into shiguwen(id,ifToll,duty,ifHaveContro,accidentJudge,judgeIfContro,accidentIfContro,phone,content) values(?,?,?,?,?,?,?,?,?)", 9),
        提交记录统计表("tjtj", "select id,type,ttime,stime,tstime from tjtj", "insert into tjtj(id,type,ttime,stime,tstime) values(?,?,?,?,?)", 5),
        投诉建议信息表("tsjy", "select id,type,name,phone,content,date from tsjy", "insert into tsjy(id,type,name,phone,content,date) values(?,?,?,?,?,?)", 6);
        //表名
        String tabname;
        //备份表名
        String bakTabName;
        //查询语句
        String qrySql;
        //插入语句
        String insertSql;
        int num;

        private TableEnum(String tabname, String qrySql, String insertSql, int num) {
            this.tabname = tabname;
            this.bakTabName = tabname + "_bak_" + Dates.getToday(Dates.DateType.Today4);
            this.qrySql = qrySql;
            this.insertSql = insertSql;
            this.num = num;
        }

        public static String getBakTabName(String tabName) {
            return tabName + "_bak_" + Dates.getToday(Dates.DateType.Today4);
        }
    }

    /**
     * 备份单表
     *
     * @throws Exception
     */
    public static void bakDB(TableEnum tableEnum) throws Exception {
        //备份表前预处理
        preBakTableDeal(objconn, tableEnum.tabname);
        //查询源表数据
        ResultSet srcSet = qrySrcData(srcconn, tableEnum.qrySql);
        //将源表数据插入备份表
        insertObjData(objconn, tableEnum.insertSql, tableEnum.num, srcSet);
        if (dbLocal.get()) {
            srcconn.close();
        }
        System.out.println("-------------表[" + tableEnum.tabname + "]数据备份成功-----------------");
    }

    /**
     * 备份全量数据
     *
     * @param sqls
     * @param srcconn
     * @param objconn
     * @throws Exception
     */
    public static void bakFullDB() throws Exception {
        long startTime=Dates.getDayLong();
        TableEnum[] tableEnums = TableEnum.values();
        int i = 1;
        for (TableEnum tableEnum : tableEnums) {
            if (i++ == tableEnums.length) {
                dbLocal.set(true);
            }
            bakDB(tableEnum);
        }
        System.out.println("-------------共计备份"+tableEnums.length+"张表----耗时"+(Dates.getDayLong()-startTime)/1000+"秒-----------------");
    }

    /**
     * @param conn
     * @param tableName
     * @throws Exception
     */
    public static void createBakTable(Connection conn, String tableName) throws SQLException {
        String bakTabName = TableEnum.getBakTabName(tableName);
        String sql = "create table " + bakTabName + " like " + tableName;
        PreparedStatement statement;

        try {
            statement = conn.prepareStatement(sql);
            statement.executeUpdate();
        } catch (SQLException e) {
            sql = "delete from " + bakTabName;
            statement = conn.prepareStatement(sql);
            statement.executeUpdate();
        }

    }

    /**
     * 备份表数据插入
     *
     * @param conn
     * @param tableName
     */
    public static void insertBakTable(Connection conn, String tableName) {
        try {
            String sql = "insert into " + TableEnum.getBakTabName(tableName) + " select * from " + tableName;
            PreparedStatement statement = conn.prepareStatement(sql);
            statement.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 删除源表数据
     *
     * @param conn
     * @param tableName
     */
    public static void deleteSrcTable(Connection conn, String tableName) {
        String sql = "delete from " + tableName;
        PreparedStatement statement = null;
        try {
            statement = conn.prepareStatement(sql);
            statement.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * 备份表前预处理
     *
     * @param conn
     * @param tableName
     */
    public static void preBakTableDeal(Connection conn, String tableName) throws SQLException {
        createBakTable(conn, tableName);
        insertBakTable(conn, tableName);
        deleteSrcTable(conn, tableName);
    }

    /**
     * 查询源库数据
     *
     * @param conn
     * @param sql
     * @return
     * @throws Exception
     */
    public static ResultSet qrySrcData(Connection conn, String sql) throws Exception {
        PreparedStatement statement = conn.prepareStatement(sql);
        ResultSet rs = statement.executeQuery();
        return rs;
    }

    /**
     * 插入目标数据
     *
     * @param conn
     * @param sql
     * @param num
     * @param rs
     * @throws Exception
     */
    public static void insertObjData(Connection conn, String sql, int num, ResultSet rs) throws Exception {
        PreparedStatement statement = conn.prepareStatement(sql);
        while (rs.next()) {
            for (int i = 1; i <= num; i++) {
                statement.setObject(i, rs.getObject(i));
            }
            statement.executeUpdate();
        }
        if (dbLocal.get()) {
            close(conn, statement, rs);
        }
    }

    /**
     * 关闭流
     *
     * @param conn
     * @param statement
     * @throws Exception
     */
    public static void close(Connection conn, PreparedStatement statement) throws Exception {
        conn.close();
        statement.close();

    }

    /**
     * 关闭流
     *
     * @param conn
     * @param statement
     * @param rs
     * @throws Exception
     */
    public static void close(Connection conn, PreparedStatement statement, ResultSet rs) throws Exception {
        close(conn, statement);
        rs.close();
    }
}
