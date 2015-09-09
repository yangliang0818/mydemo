程序TASK_RPT_TERMINAL_SUBSIDY.SH
逻辑分析 DIM_PRTY_ORG_INFO DWD_SVC_USR_ALL_INFO_201408
--1、创建结果表
CREATE TABLE RPT_ZDMM326_TERMI_USER_DETAIL_201408(
        USER_ID              VARCHAR(20),    -- 用户编号
        CUST_ID              VARCHAR(14),    -- 客户编号
        OFFER_INST_ID        VARCHAR(30),    -- 策划实例编号
        OFFER_ID             BIGINT,         -- 策划编号
        OFFER_NAME           VARCHAR(100),   -- 策划名称
        PROD_ID              BIGINT,         -- 产品编号
        PROD_NAME            VARCHAR(100),   -- 产品名称
        CREATE_DATE          DATE,           -- 创建日期
        EFFECTIVE_DATE       DATE,           -- 生效日期
        EXPIRE_DATE          DATE,           -- 失效日期
        DONE_DATE            DATE,           -- 受理日期
        DONE_CODE            VARCHAR(25),    -- 受理编号
        OP_ID                BIGINT,         -- 操作员工号
        ORG_ID               BIGINT,         -- 组织编号
        IMEI                 VARCHAR(30),    -- 终端设备号
        MATCH_IMEI           VARCHAR(30),    -- 变更终端设备号
        IMEI_8               VARCHAR(8),     -- 终端设备号前八位
        RES_CODE             VARCHAR(30),    -- 资源编码
        ORG_TERMI_TYPE       VARCHAR(3),     -- 营业侧终端类型
        ORG_TERMI_TYPE_NAME  VARCHAR(255),   -- 营业侧终端类型编码
        TERMI_TYPE           VARCHAR(30),    -- 终端类型:口径先一经后营业
        TD_TERMI_TYPE        VARCHAR(60),    -- TD终端类型
        RES_SPEC_NAME        VARCHAR(256),   -- 终端型号
        SALE_TYPE            SMALLINT,       -- 销售类型
        MONTH                SMALLINT,       -- 捆绑月数
        PERMONTH_FEE         DECIMAL(10, 2), -- 月承诺最低消费
        PRE_DEPOSIT          DECIMAL(10, 2), -- 预存款
        MARKET_PRICE         DECIMAL(10, 2), -- 购机价
        PRIMARY_FEE          DECIMAL(10, 2), -- 返还金额
        ALLOTED_FEE          DECIMAL(10, 2), -- 已返还金额
        ALLOTED_BCYCLE_COUNT SMALLINT,       -- 已返还次数
        REMAIN_BCYCLE_COUNT  SMALLINT,       -- 剩余次数
        STATE                SMALLINT,       -- 状态:1-正常,2-回退（含预回退）,3-预约
        TERMINAL_PRICE       DECIMAL(10, 2), -- 资源价格:成本价
        ALLOWANCE3           DECIMAL(10, 2), -- 端补差价
        PRESENT_FEE          DECIMAL(10, 2), -- 话费补贴
        CAPACITY_FLAG        SMALLINT,       -- 智能终端标志:0-否,1-是
        STAT_FLAG            SMALLINT        -- 统计过的标志:0-未统计过,1-之前统计过,2-无效（目前只针对二码合一）,3-新规则变更时增补标志（只增补存在补贴的）,10以上为临时统计
);
--2、统计终端活动的OFFER_ID
INSERT INTO RPT_ZDMM326_TERMI_USER_DETAIL_201408(USER_ID, OFFER_NAME, STAT_FLAG)
          SELECT DISTINCT '-1' AS USER_ID, OFFER_ID AS OFFER_NAME, 10 AS STAT_FLAG FROM SHDW.DWD_SVC_OFF_TERM_BIND_INST_201408;
--3、统计终端活动OFFER_ID对应的名称
INSERT INTO RPT_ZDMM326_TERMI_USER_DETAIL_201408
        (USER_ID, OFFER_ID, OFFER_NAME, PROD_ID, STAT_FLAG)
        SELECT '-1' AS USER_ID,
               B.OFFER_NAME AS OFFER_ID,
               A.NAME AS OFFER_NAME,
               A.EXTEND_ID,
               11 AS STAT_FLAG
          FROM SHODS.ODS_CRM_UP_PRODUCT_ITEM_20140916       A,
               RPT_ZDMM326_TERMI_USER_DETAIL_201408 B
         WHERE A.PRODUCT_ITEM_ID = B.OFFER_NAME
           AND A.STATE = 'U'
           AND A.DEL_FLAG = 1
           AND B.STAT_FLAG = 10;
--4、删除第一步插入的统计状态为10的数据
DELETE FROM RPT_ZDMM326_TERMI_USER_DETAIL_201408 WHERE STAT_FLAG = 10;
--5、提取终端的成本价
INSERT INTO RPT_ZDMM326_TERMI_USER_DETAIL_201408
                (USER_ID,
                 OFFER_INST_ID,
                 OFFER_ID,
                 PROD_ID,
                 CREATE_DATE,
                 EFFECTIVE_DATE,
                 EXPIRE_DATE,
                 DONE_DATE,
                 DONE_CODE,
                 OP_ID,
                 ORG_ID,
                 IMEI,
                 IMEI_8,
                 RES_CODE,
                 MONTH,
                 PERMONTH_FEE,
                 PRE_DEPOSIT,
                 MARKET_PRICE,
                 PRIMARY_FEE,
                 ALLOTED_FEE,
                 ALLOTED_BCYCLE_COUNT,
                 REMAIN_BCYCLE_COUNT,
                 STATE,
                 TERMINAL_PRICE,
                 STAT_FLAG,
                 TERMI_TYPE,
                 TD_TERMI_TYPE,
                 ALLOWANCE3,
                 CAPACITY_FLAG)
WITH T1(USER_ID,OFFER_INST_ID,OFFER_ID,PROD_ID,CREATE_DATE,EFF_DATE,EXP_DATE,DONE_DATE,DONE_CODE,OP_ID,ORG_ID,IMEI,IMEI_8,
RES_SPEC_ID,MONTH_NUM,PERMONTH_FEE,PREPAY_FEE,MARKET_PRICE,TOTAL_ALLOT_FEE,ALLOTED_FEE,ALLOTED_BCYCLE_NUM,REMAIN_BCYCLE_NUM
,STATE,TERM_COST,STAT_FLAG,SEQ_NO) AS
(SELECT USER_ID,OFFER_INST_ID,OFFER_ID,PROD_ID,CREATE_DATE,EFF_DATE,EXP_DATE,DONE_DATE,DONE_CODE,
OP_ID,ORG_ID,IMEI,SUBSTR(IMEI, 1, 8) AS IMEI_8,RES_SPEC_ID,MONTH_NUM,PERMONTH_FEE AS PERMONTH_FEE ,PREPAY_FEE,
MARKET_PRICE,TOTAL_ALLOT_FEE,ALLOTED_FEE,ALLOTED_BCYCLE_NUM,REMAIN_BCYCLE_NUM,STATE,TERM_COST,10 AS STAT_FLAG
,ROW_NUMBER() OVER(PARTITION BY IMEI ORDER BY CREATE_DATE DESC) AS SEQ_NO FROM SHDW.DWD_SVC_OFF_TERM_BIND_INST_201408
WHERE IMEI IS NOT NULL AND EFF_DATE BETWEEN '2014-07-02' AND
                                               '2014-09-01'
                                           AND EXP_DATE > '2014-09-01'
                                           AND (STATE <> 2 OR SUBSTR(CREATE_DATE, 1, 7) <>
                                               SUBSTR(DONE_DATE, 1, 7))
),
T2 (KEY_IMEI, MOBILE_TYPE) AS
(SELECT KEY_IMEI, MOBILE_TYPE FROM SHFIN.RPT_DIM_TERMI WHERE CREATE_YEAR_MONTH = '201408')
SELECT T1.*,
       CASE WHEN T2.MOBILE_TYPE IN ('4G上网本',
                                    '4G手机',
                                    '4G数据卡',
                                    '4G无线固话',
                                    '4GMIFI',
                                    '4G平板电脑',
                                    '4GCPE',
                                    'TDLTE上网本',
                                    'TDLTE手机',
                                    'TDLTE数据卡',
                                    'TDLTE无线固话',
                                    'TDLTEMIFI',
                                    'TDLTE平板电脑',
                                    'TDLTECPE') THEN
                                    'LTE终端'
                         WHEN T2.MOBILE_TYPE IN ('3G上网本',
                                                '3G手机',
                                                '3G数据卡',
                                                '3G无线固话',
                                                '3GMIFI',
                                                '3G平板电脑',
                                                'TDSCDMA上网本',
                                                'TDSCDMA手机',
                                                'TDSCDMA数据卡',
                                                'TDSCDMA无线固话',
                                                'TDSCDMAMIFI',
                                                'TDSCDMA平板电脑') THEN
                          'TD-SCDMA终端'
                         ELSE
                          '2G终端'
                       END AS TERMI_TYPE,
                       CASE
                         WHEN T2.MOBILE_TYPE IN ('4G手机', 'TDLTE手机') THEN
                          'LTE手机'
                         WHEN T2.MOBILE_TYPE IN
                              ('4G数据卡', 'TDLTE数据卡', '4G平板电脑', 'TDLTE平板电脑') THEN
                          'LTE数据卡'
                         WHEN T2.MOBILE_TYPE IN ('4GMIFI', 'TDLTEMIFI') THEN
                          'LTE-MIFI'
                         WHEN T2.MOBILE_TYPE IN ('4GCPE', 'TDLTECPE') THEN
                          'LTE-CPE'
                         WHEN T2.MOBILE_TYPE IN ('3G手机', 'TDSCDMA手机') THEN
                          'TD-SCDMA手机'
                         WHEN T2.MOBILE_TYPE IN ('3G无线固话', 'TDSCDMA无线固话') THEN
                          'TD-SCDMA无线座机'
                         WHEN T2.MOBILE_TYPE IN ('3G上网本',
                                                '3G数据卡',
                                                '3GMIFI',
                                                '3G平板电脑',
                                                'TDSCDMA上网本',
                                                'TDSCDMA数据卡',
                                                'TDSCDMAMIFI',
                                                'TDSCDMA平板电脑') THEN
                          'TD-SCDMA上网卡（含上网本）'
                         ELSE
                          '2G终端'
                       END AS TD_TERMI_TYPE,
                       CASE
                         WHEN VALUE(T1.TERM_COST, 0)-VALUE(T1.MARKET_PRICE, 0)> 0 THEN
                          VALUE(T1.TERM_COST, 0)-VALUE(T1.MARKET_PRICE, 0)
                         ELSE
                          0
                       END AS ALLOWANCE3,
                       CASE
                         WHEN H.KEY_IMEI IS NULL THEN
                          0
                         ELSE
                          1
                       END AS CAPACITY_FLAG
                       FROM (SELECT * FROM T1 WHERE SEQ_NO=1) T1 LEFT JOIN T2
                       ON T1.IMEI_8 = T2.KEY_IMEI
                       LEFT JOIN (SELECT DISTINCT KEY_IMEI FROM RPT_DIM_CAPACITY_MOBILE_PHONE_201408) H
                       ON T1.IMEI_8 = H.KEY_IMEI;
--6、关联第二步和第五步生成哪些用户统计过，哪些用户未统计过
INSERT INTO RPT_ZDMM326_TERMI_USER_DETAIL_201408
                (USER_ID,
                 OFFER_INST_ID,
                 OFFER_ID,
                 OFFER_NAME,
                 PROD_ID,
                 CREATE_DATE,
                 EFFECTIVE_DATE,
                 EXPIRE_DATE,
                 DONE_DATE,
                 DONE_CODE,
                 OP_ID,
                 ORG_ID,
                 IMEI,
                 IMEI_8,
                 RES_CODE,
                 TERMI_TYPE,
                 TD_TERMI_TYPE,
                 MONTH,
                 PERMONTH_FEE,
                 PRE_DEPOSIT,
                 MARKET_PRICE,
                 PRIMARY_FEE,
                 ALLOTED_FEE,
                 ALLOTED_BCYCLE_COUNT,
                 REMAIN_BCYCLE_COUNT,
                 STATE,
                 TERMINAL_PRICE,
                 PRESENT_FEE,
                 STAT_FLAG
                 )
WITH T1(OFFER_ID,OFFER_NAME,EXTEND_ID) AS
(SELECT OFFER_ID,OFFER_NAME,BOSS_OFFER_ID FROM SHDW.DIM_SVC_OFF_PLOY WHERE START_DATE<'2014-09-16' AND END_DATE>'2014-09-16'),
T2(OFFER_ID,OFFER_NAME,EXTEND_ID) AS
(SELECT OFFER_ID, OFFER_NAME, PROD_ID FROM RPT_ZDMM326_TERMI_USER_DETAIL_201408 WHERE STAT_FLAG = 11),
T3(USER_ID,IMEI) AS
(SELECT DISTINCT SUB_ID, IMEI FROM RPT_ZDMM326_TERMI_USER_IMEI_DTL WHERE APPLY_MONTH < '201408')
SELECT DISTINCT A.USER_ID,
                A.OFFER_INST_ID,
                A.OFFER_ID,
                VALUE(T1.OFFER_NAME, T2.OFFER_NAME) AS OFFER_NAME,
                A.PROD_ID,
                A.CREATE_DATE,
                A.EFFECTIVE_DATE,
                A.EXPIRE_DATE,
                A.DONE_DATE,
                A.DONE_CODE,
                A.OP_ID,
                A.ORG_ID,
                A.IMEI,
                A.IMEI_8,
                A.RES_CODE,
                A.TERMI_TYPE,
                A.TD_TERMI_TYPE,
                A.MONTH,
                A.PERMONTH_FEE,
                A.PRE_DEPOSIT,
                A.MARKET_PRICE,
                A.PRIMARY_FEE,
                A.ALLOTED_FEE,
                A.ALLOTED_BCYCLE_COUNT,
                A.REMAIN_BCYCLE_COUNT,
                A.STATE,
                A.TERMINAL_PRICE,
                VALUE(D.PRESENT_FEE * 1.00 / 100.00, 0.00) AS PRESENT_FEE,
                CASE
                  WHEN VALUE(VALUE(T1.OFFER_NAME, T2.OFFER_NAME), '-1') LIKE
                       '%二码合一%' THEN
                   2
                  ELSE
                   CASE
                     WHEN T3.USER_ID IS NOT NULL THEN
                      1
                     ELSE
                      0
                   END
                END AS STAT_FLAG
                FROM (SELECT * FROM RPT_ZDMM326_TERMI_USER_DETAIL_201408 WHERE STAT_FLAG = 10) A
                LEFT JOIN T1 ON A.OFFER_ID=T1.OFFER_ID
                LEFT JOIN T2 ON A.OFFER_ID = T2.OFFER_ID
                LEFT JOIN SHODS.ODS_CA_PA_PROMO_DEF_20140916 D
                ON VALUE(T1.EXTEND_ID,CASE WHEN T1.OFFER_ID IS NULL THEN T2.EXTEND_ID END) = D.OUTER_PROMO_ID
                LEFT JOIN T3
                ON A.USER_ID = T3.USER_ID AND A.IMEI = T3.IMEI;
--7、删除状态为10的临时数据
DELETE FROM RPT_ZDMM326_TERMI_USER_DETAIL_201408 WHERE STAT_FLAG = 10;
--8、增加二码合一活动的处理:只有话费补贴，没有终端补贴（终端费用不经过资源、营业），且新模型可能会漏掉二码合一活动的IMEI新模型机价已包含不需要再配机价
INSERT INTO RPT_ZDMM326_TERMI_USER_DETAIL_201408
                (USER_ID,
                 OFFER_INST_ID,
                 OFFER_ID,
                 OFFER_NAME,
                 PROD_ID,
                 CREATE_DATE,
                 EFFECTIVE_DATE,
                 EXPIRE_DATE,
                 DONE_DATE,
                 DONE_CODE,
                 OP_ID,
                 ORG_ID,
                 IMEI,
                 IMEI_8,
                 RES_CODE,
                 TERMI_TYPE,
                 TD_TERMI_TYPE,
                 MONTH,
                 PERMONTH_FEE,
                 PRE_DEPOSIT,
                 MARKET_PRICE,
                 PRIMARY_FEE,
                 ALLOTED_FEE,
                 ALLOTED_BCYCLE_COUNT,
                 REMAIN_BCYCLE_COUNT,
                 STATE,
                 PRESENT_FEE,
                 TERMINAL_PRICE,
                 CAPACITY_FLAG,
                 STAT_FLAG
                 )
WITH T1(OFFER_ID,OFFER_NAME,EXTEND_ID) AS
(SELECT OFFER_ID, OFFER_NAME, PROD_ID AS EXTEND_ID FROM RPT_ZDMM326_TERMI_USER_DETAIL_201408 WHERE STAT_FLAG = 11 AND OFFER_NAME LIKE '%二码合一%'),
T2(USER_ID,OFFER_INST_ID,OFFER_ID,OFFER_NAME,PROD_ID,CREATE_DATE,EFF_DATE,EXP_DATE,DONE_DATE,DONE_CODE,OP_ID,ORG_ID,IMEI,IMEI_8,
RES_SPEC_ID,MONTH_NUM,PERMONTH_FEE,PREPAY_FEE,MARKET_PRICE,TERMINAL_PRICE,TOTAL_ALLOT_FEE,ALLOTED_FEE,ALLOTED_BCYCLE_NUM,REMAIN_BCYCLE_NUM
,STATE,EXTEND_ID,SEQ_NO) AS
(SELECT  A.USER_ID,
         A.OFFER_INST_ID,
         A.OFFER_ID,
         B.OFFER_NAME,
         A.PROD_ID,
         A.CREATE_DATE,
         A.EFF_DATE,
         A.EXP_DATE,
         A.DONE_DATE,
         A.DONE_CODE,
         A.OP_ID,
         A.ORG_ID,
         VALUE(A.IMEI, D.IMEI) AS IMEI,
         SUBSTR(VALUE(A.IMEI, D.IMEI), 1, 8) AS IMEI_8,
         A.RES_SPEC_ID,
         A.MONTH_NUM,
         A.PERMONTH_FEE,
         A.PREPAY_FEE,
         A.MARKET_PRICE,
         A.TERM_COST,
         A.TOTAL_ALLOT_FEE,
         A.ALLOTED_FEE,
         A.ALLOTED_BCYCLE_NUM,
         A.REMAIN_BCYCLE_NUM,
         A.STATE,
         B.EXTEND_ID,
         ROW_NUMBER() OVER(PARTITION BY VALUE(A.IMEI, D.IMEI) ORDER BY A.CREATE_DATE DESC) AS SEQ_NO
    FROM SHDW.DWD_SVC_OFF_TERM_BIND_INST_201408 A,
         T1 B,
         SHODS.ODS_INS_USER_201408 C,
         SHODS.ODS_INSX_GRP_TRMNL_REC_201408 D
    WHERE A.EFF_DATE BETWEEN '2014-08-02' AND
         '2014-09-01'
     AND A.EXP_DATE > '2014-09-01'
     AND (A.STATE <> 2 OR
         SUBSTR(A.CREATE_DATE, 1, 7) <> SUBSTR(A.DONE_DATE, 1, 7))
     AND A.OFFER_ID = B.OFFER_ID
     AND A.USER_ID = C.USER_ID
     AND C.EXPIRE_DATE > '2014-09-01 00:00:00.000000'
     AND C.BILL_ID = D.BILL_ID
     AND A.OFFER_ID = D.OFFER_ID
     AND VALUE(A.IMEI, D.IMEI) IS NOT NULL),
T3(KEY_IMEI,MOBILE_TYPE) AS
(SELECT KEY_IMEI, MOBILE_TYPE FROM RPT_DIM_TERMI WHERE CREATE_YEAR_MONTH = '2014-08'),
T4(KEY_IMEI) AS
(SELECT DISTINCT KEY_IMEI FROM RPT_DIM_CAPACITY_MOBILE_PHONE_201408),
T5(OFFER_ID,OFFER_NAME,EXTEND_ID) AS
(SELECT OFFER_ID,OFFER_NAME,BOSS_OFFER_ID FROM SHDW.DIM_SVC_OFF_PLOY WHERE START_DATE<'2014-09-16' AND END_DATE>'2014-09-16')
SELECT  E.USER_ID,
        E.OFFER_INST_ID,
        E.OFFER_ID,
        VALUE(F.OFFER_NAME, E.OFFER_NAME) AS OFFER_NAME,
        E.PROD_ID,
        E.CREATE_DATE,
        E.EFF_DATE,
        E.EXP_DATE,
        E.DONE_DATE,
        E.DONE_CODE,
        E.OP_ID,
        E.ORG_ID,
        E.IMEI,
        E.IMEI_8,
        E.RES_SPEC_ID,
        CASE
          WHEN H.MOBILE_TYPE IN ('4G上网本',
                                 '4G手机',
                                 '4G数据卡',
                                 '4G无线固话',
                                 '4GMIFI',
                                 '4G平板电脑',
                                 '4GCPE',
                                 'TDLTE上网本',
                                 'TDLTE手机',
                                 'TDLTE数据卡',
                                 'TDLTE无线固话',
                                 'TDLTEMIFI',
                                 'TDLTE平板电脑',
                                 'TDLTECPE') THEN 'LTE终端'
          WHEN H.MOBILE_TYPE IN ('3G上网本',
                                 '3G手机',
                                 '3G数据卡',
                                 '3G无线固话',
                                 '3GMIFI',
                                 '3G平板电脑',
                                 'TDSCDMA上网本',
                                 'TDSCDMA手机',
                                 'TDSCDMA数据卡',
                                 'TDSCDMA无线固话',
                                 'TDSCDMAMIFI',
                                 'TDSCDMA平板电脑') THEN 'TD-SCDMA终端'
          ELSE  '2G终端' END AS TERMI_TYPE,
        CASE
          WHEN H.MOBILE_TYPE IN ('4G手机', 'TDLTE手机') THEN
           'LTE手机'
          WHEN H.MOBILE_TYPE IN ('4G数据卡',
                                 'TDLTE数据卡',
                                 '4G平板电脑',
                                 'TDLTE平板电脑') THEN
           'LTE数据卡'
          WHEN H.MOBILE_TYPE IN ('4GMIFI', 'TDLTEMIFI') THEN
           'LTE-MIFI'
          WHEN H.MOBILE_TYPE IN ('4GCPE', 'TDLTECPE') THEN
           'LTE-CPE'
          WHEN H.MOBILE_TYPE IN ('3G手机', 'TDSCDMA手机') THEN
           'TD-SCDMA手机'
          WHEN H.MOBILE_TYPE IN ('3G无线固话', 'TDSCDMA无线固话') THEN
           'TD-SCDMA无线座机'
          WHEN H.MOBILE_TYPE IN ('3G上网本',
                                 '3G数据卡',
                                 '3GMIFI',
                                 '3G平板电脑',
                                 'TDSCDMA上网本',
                                 'TDSCDMA数据卡',
                                 'TDSCDMAMIFI',
                                 'TDSCDMA平板电脑') THEN
           'TD-SCDMA上网卡（含上网本）'
          ELSE
           '2G终端'
        END AS TD_TERMI_TYPE,
        E.MONTH_NUM,
        E.PERMONTH_FEE,
        E.PREPAY_FEE,
        E.MARKET_PRICE,
        E.TOTAL_ALLOT_FEE,
        E.ALLOTED_FEE,
        E.ALLOTED_BCYCLE_NUM,
        E.REMAIN_BCYCLE_NUM,
        E.STATE,
        VALUE(G.PRESENT_FEE * 1.00 / 100.00, 0.00) AS PRESENT_FEE,
        E.TERMINAL_PRICE,
        CASE
          WHEN I.KEY_IMEI IS NULL THEN
           0
          ELSE
           1
        END AS CAPACITY_FLAG,
        10 AS STAT_FLAG
FROM T2 E
LEFT JOIN T5 F
  ON E.OFFER_ID = F.OFFER_ID
LEFT JOIN SHODS.ODS_CA_PA_PROMO_DEF_20140916 G
  ON (CASE
       WHEN F.OFFER_ID IS NULL THEN
        E.EXTEND_ID
       ELSE
        F.EXTEND_ID
     END) = G.OUTER_PROMO_ID
LEFT JOIN T3 H
  ON E.IMEI_8 = H.KEY_IMEI
LEFT JOIN T4 I
  ON E.IMEI_8 = I.KEY_IMEI
WHERE E.SEQ_NO = 1;
--9、删除状态为10和11的临时数据
DELETE FROM RPT_ZDMM326_TERMI_USER_DETAIL_201408 WHERE STAT_FLAG IN (10,11);
--2014/7/6 按照营改增新要求的公式进行数据更新（只更新年表），见下面一段
--客户实际缴纳金额=用户购买终端价钱+客户预存的话费
--用户购买终端实际缴纳金额（含增值税）=客户实际缴纳金额-客户预存的话费
--用户购买终端实际缴纳金额（不含增值税）=（客户实际缴纳金额-客户预存的话费）/1.17
--成本类补贴金额=终端采购成本价格（不含增值税）-用户购买终端实际缴纳金额（不含增值税）
--              =(终端采购成本价格-用户购买终端实际缴纳金额)/1.17
--              =(终端采购成本价格-(客户实际缴纳金额-客户预存的话费))/1.17
--              =(终端采购成本价格-((用户购买终端价钱+客户预存的话费)-客户预存的话费))/1.17
--              =(终端采购成本价格-用户购买终端价钱)/1.17
--2014/7/7 财务通过集团确认，只有当终端采购成本价格-用户购买终端价钱<0时，“终端采购成本价格-用户购买终端价钱”进入此公式
--话费类补贴金额=终端采购成本价格（不含增值税）+赠送给用户的话费-用户购买终端实际缴纳金额（不含增值税）
--              =(终端采购成本价格-用户购买终端实际缴纳金额)/1.17+赠送给用户的话费
--              =(终端采购成本价格-用户购买终端价钱)/1.17+赠送给用户的话费
--10、更新表数据状态
RUNSTATS ON TABLE SHFIN.RPT_ZDMM326_TERMI_USER_DETAIL_201408
--11、建立终端补贴基础表
CREATE TABLE RPT_ZDMM326_TERMI_USER_DETAIL_2014(
	              SUB_ID         VARCHAR(20),
	              TERMI_TYPE     VARCHAR(30),
	              TD_TERMI_TYPE  VARCHAR(60),
	              BT_TYPE        VARCHAR(10),
	              BUY_PRICE      INTEGER,
	              BT_FEE         DECIMAL(10, 2),
	              CAPACITY_FLAG  SMALLINT,
	              IMEI           VARCHAR(30),
	              APPLY_MONTH    VARCHAR(10)
);
--12、删除当月数据
DELETE FROM RPT_ZDMM326_TERMI_USER_DETAIL_2014 WHERE APPLY_MONTH='201408';




