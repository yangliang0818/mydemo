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
        long t1 = System.currentTimeMillis();
        bakDB(TableEnum.PHP楼盘数据);
        long t2 = System.currentTimeMillis();
        System.out.println("备份" + TableEnum.PHP楼盘数据.toString() + "所需毫秒数" + (t2 - t1));
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
        PHP楼盘数据("php_house", "select house_id,list_pic,house_name,house_pic,house_address,house_state,house_discount,house_rate," +
                "house_goal,house_type,house_property,house_building,house_area,house_plate,house_price,house_lot,house_unit,house_features," +
                "house_developers,house_description,house_advantage,house_shortcoming,house_shangjia,house_t,house_z,house_kucun,house_starttime," +
                "house_endtime,house_time,house_update_time,house_youhui,house_1_1,house_total,house_x,house_y,house_city,tag,house_cq," +
                "house_fs,house_jianjin,house_main,house_tj,cjurl,cjtime,pic_tag,soufun_page,soufun_domain,soufun_id,now() as soufun_time,ad_pic,money,house_order," +
                "haiwai_country,haiwai_city,haiwai_label,haiwai_area,haiwai_total,app_houseid from php_house",
                "insert into php_house (house_id,list_pic,house_name,house_pic,house_address,house_state,house_discount,house_rate,house_goal,house_type," +
                        "house_property,house_building,house_area,house_plate,house_price,house_lot,house_unit,house_features,house_developers,house_description," +
                        "house_advantage,house_shortcoming,house_shangjia,house_t,house_z,house_kucun,house_starttime,house_endtime,house_time,house_update_time," +
                        "house_youhui,house_1_1,house_total,house_x,house_y,house_city,tag,house_cq,house_fs,house_jianjin,house_main,house_tj,cjurl," +
                        "cjtime,pic_tag,soufun_page,soufun_domain,soufun_id,soufun_time,ad_pic,money,house_order,haiwai_country,haiwai_city,haiwai_label,haiwai_area," +
                        "haiwai_total,app_houseid values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?," +
                        "?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,)", 58);
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
        //preBakTableDeal(objconn, tableEnum.tabname);
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
        long startTime = Dates.getDayLong();
        TableEnum[] tableEnums = TableEnum.values();
        int i = 1;
        for (TableEnum tableEnum : tableEnums) {
            if (i++ == tableEnums.length) {
                dbLocal.set(true);
            }
            bakDB(tableEnum);
        }
        System.out.println("-------------共计备份" + tableEnums.length + "张表----耗时" + (Dates.getDayLong() - startTime) / 1000 + "秒-----------------");
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
            try {
                statement.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }

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
