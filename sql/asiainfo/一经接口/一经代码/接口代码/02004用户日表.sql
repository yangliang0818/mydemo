﻿--本地侧全量用户数据
DROP TABLE SHBASS.BASS1_USER_SRVC_20150414;
CREATE TABLE SHBASS.BASS1_USER_SRVC_20150414
(
SUB_ID              VARCHAR(21),
CUSTOMER_ID         VARCHAR(21),
USER_TYPE           VARCHAR(11),
CREATE_DATE         DATE       ,
USER_BUSITYPE_ID    VARCHAR(2) ,
MSISDN              VARCHAR(30),
IMSI                VARCHAR(15),
CMCC_ID             VARCHAR(5) ,
CHANNEL_ID          VARCHAR(25),
MOBILE_PUB_TYPE     VARCHAR(1) ,
ACC_TYPE            VARCHAR(1) ,
ENTER_TYPE          VARCHAR(2) ,
BRAND_ID            VARCHAR(1) ,
DATASIM_TYPE        VARCHAR(1) ,
REGION              CHAR(1),
BASS_USER_STATE_ID  SMALLINT
) DATA CAPTURE NONE
 IN TBSN_APP
  PARTITIONING KEY
   (SUB_ID
   ) USING HASHING;
--1、出基础数据
INSERT INTO SHBASS.BASS1_USER_SRVC_20150414
WITH T1 AS--二经基础用户信息
(
SELECT A.USER_ID,A.CUST_ID,'1' AS USER_TYPE ,A.JOIN_DATE,'01' AS USER_BUSITYPE_ID,A.PHONE_NO,A.IMSI,'10200' AS CMCC_ID,
NVL(C.CHANNEL_ID,D.CHANNEL_ENTITY_ID,E.CHANNEL_ENTITY_ID,F.BASS1_CHL,G.BASS1_CHL,'BASS1_UM'),
CASE
     WHEN B.ORG_ID IS NOT NULL THEN
      INT(B.ORG_ID)
     WHEN B.ORG_ID IS NULL THEN
      CASE
        WHEN C.BILL_ID IS NOT NULL AND C.ORG_ID NOT IN (0,1) THEN
         INT(C.ORG_ID)
        WHEN C.BILL_ID IS NOT NULL AND C.ORG_ID IN (0,1) THEN
         INT(C.NETWORK_NUMBER)
        WHEN C.BILL_ID IS NULL THEN
         CASE
           WHEN D.RES_ID IS NOT NULL THEN
            INT(D.ORG_ID)
           ELSE
            NULL
         END
        ELSE
         NULL
      END
     ELSE
      NULL
   END ,
2 AS MOBILE_PUB_TYPE ,A.BILLING_TYPE,'04' AS ENTER_TYPE,A.OFFER_ID
FROM SHDW.DWD_SVC_USR_ALL_INFO_20150414 A
LEFT JOIN (SELECT BILL_ID, NETWORK_NUMBER, ORG_ID
  			               FROM (SELECT BILL_ID,
  			                            NETWORK_NUMBER,
  			                            ORG_ID,
  			                            ROW_NUMBER() OVER(PARTITION BY BILL_ID ORDER BY DONE_CODE DESC) U_ID
  			                       FROM SHODS.ODS_CRM_WHITECARD_INFO_20150414) C
  			              WHERE U_ID = 1) C
  			    ON A.PHONE_NO = C.BILL_ID
  			  LEFT JOIN (SELECT RES_ID, ORG_ID
  			               FROM (SELECT RES_ID,
  			                            ORG_ID,
  			                            ROW_NUMBER() OVER(PARTITION BY RES_ID ORDER BY DONE_CODE DESC) U_ID
  			                       FROM SHODS.ODS_RES_INACTIVE_PHONE_20150414) D
  			              WHERE U_ID = 1) D
        ON A.PHONE_NO = D.RES_ID
LEFT JOIN SHBASS.DIM_BASS1_CHANNEL_OP_INFO_20150414 F ON B.OP_ID=F.OP_ID
LEFT JOIN SHBASS.DIM_BASS1_CHANNEL_OP_INFO_20150414 G ON B.ORG_ID=G.ORG_ID
WHERE A.BASS_USER_STATE_ID <>'103'
),T2 AS --三大品牌归类
(
SELECT OFFER_ID,BASS1_VALUE1 AS BASS1_BRAND_ID,BASS1_VALUE2 AS BASS1_DATA_CARD_M2M_TYPE FROM SHBASS.BASS1_MAP_PLAN WHERE BASS1_VALUE1 IN (1,2,3)
)
SELECT T1.USER_ID,T1.CUST_ID,T1.USER_TYPE,T1.JOIN_DATE,T1.USER_BUSITYPE_ID,T1.PHONE_NO,T1.IMSI,T1.CMCC_ID,NVL(T1.CHANNEL_ID,'BASS1_UM'),
T1.MOBILE_PUB_TYPE,T1.BILLING_TYPE,T1.ENTER_TYPE,T2.BASS1_BRAND_ID,T2.BASS1_DATA_CARD_M2M_TYPE,0
FROM T1
JOIN T2 ON T1.OFFER_ID=T2.OFFER_ID
LEFT JOIN SHDW.DWD_SVC_USR_TESTCARD_20150414 D
ON T1.PHONE_NO=D.PHONE_NO
WHERE D.PHONE_NO IS NULL;

RUNSTATS ON TABLE SHBASS.BASS1_USER_SRVC_20150414;
--2、创建当日用户数据
DROP TABLE SHBASS.BASS1_USER_SRVC_DAY_20150414;
CREATE TABLE SHBASS.BASS1_USER_SRVC_DAY_20150414
(
SUB_ID              VARCHAR(21),
CUSTOMER_ID         VARCHAR(21),
USER_TYPE           VARCHAR(11),
CREATE_DATE         DATE       ,
USER_BUSITYPE_ID    VARCHAR(2) ,
MSISDN              VARCHAR(30),
IMSI                VARCHAR(15),
CMCC_ID             VARCHAR(5) ,
CHANNEL_ID          VARCHAR(25),
MOBILE_PUB_TYPE     VARCHAR(1) ,
ACC_TYPE            VARCHAR(1) ,
ENTER_TYPE          VARCHAR(2) ,
BRAND_ID            VARCHAR(1) ,
DATASIM_TYPE        VARCHAR(1) ,
REGION              CHAR(1)
) DATA CAPTURE NONE
 IN TBSN_APP
  PARTITIONING KEY
   (SUB_ID
   ) USING HASHING;
--3、根据前一天集团侧全量计算出当日新增在网用户
INSERT INTO SHBASS.BASS1_USER_SRVC_DAY_20150414
WITH T1 AS --第一步先找出本地侧全量和集团侧前一天全量增量的用户数据
(
SELECT SUB_ID,CUSTOMER_ID,USER_TYPE,CREATE_DATE,USER_BUSITYPE_ID
,MSISDN,IMSI,CMCC_ID,CHANNEL_ID,MOBILE_PUB_TYPE,ACC_TYPE,ENTER_TYPE
,BRAND_ID,DATASIM_TYPE FROM SHBASS.BASS1_USER_SRVC_20150414
EXCEPT
SELECT SUB_ID,CUSTOMER_ID,USER_TYPE,CREATE_DATE,USER_BUSITYPE_ID
,MSISDN,IMSI,CMCC_ID,CHANNEL_ID,MOBILE_PUB_TYPE,ACC_TYPE,ENTER_TYPE
,BRAND_ID,DATASIM_TYPE FROM SHBASS.BASS1_USER_20150201
)
--第二步把入网渠道和入网时间用集团侧前一天数据替换，再剔除一次，将已经上报了入网渠道和入网时间的用户去掉
SELECT T1.SUB_ID,T1.CUSTOMER_ID,T1.USER_TYPE,VALUE(B.CREATE_DATE,T1.CREATE_DATE),T1.USER_BUSITYPE_ID
,T1.MSISDN,T1.IMSI,T1.CMCC_ID,VALUE(B.CHANNEL_ID,T1.CHANNEL_ID),T1.MOBILE_PUB_TYPE,T1.ACC_TYPE,T1.ENTER_TYPE
,T1.BRAND_ID,T1.DATASIM_TYPE,0 FROM T1 LEFT JOIN SHBASS.BASS1_USER_20150201 B ON T1.SUB_ID=B.SUB_ID
EXCEPT
SELECT SUB_ID,CUSTOMER_ID,USER_TYPE,CREATE_DATE,USER_BUSITYPE_ID
,MSISDN,IMSI,CMCC_ID,CHANNEL_ID,MOBILE_PUB_TYPE,ACC_TYPE,ENTER_TYPE
,BRAND_ID,DATASIM_TYPE,0 FROM SHBASS.BASS1_USER_20150201;
--4、更新表状态
RUNSTATS ON TABLE SHBASS.BASS1_USER_SRVC_DAY_20150414;
--5、生成集团侧当日全量数据
CREATE TABLE SHBASS.BASS1_USER_20150414
(
SUB_ID            VARCHAR(21),
CUSTOMER_ID       VARCHAR(21),
USER_TYPE         VARCHAR(11),
CREATE_DATE       DATE,
USER_BUSITYPE_ID  VARCHAR(2),
MSISDN            VARCHAR(30),
IMSI              VARCHAR(15),
CMCC_ID           VARCHAR(5),
CHANNEL_ID        VARCHAR(25),
MOBILE_PUB_TYPE   VARCHAR(1),
ACC_TYPE          VARCHAR(1),
ENTER_TYPE        VARCHAR(2),
BRAND_ID          VARCHAR(1),
DATASIM_TYPE      VARCHAR(1),
REGION            CHARACTER(1)
);
--6、用今天变化的用户数据和前一天去没有变化的用户合并生成集团侧全量用户数据
INSERT INTO SHBASS.BASS1_USER_20150414
SELECT SUB_ID,CUSTOMER_ID,USER_TYPE,CREATE_DATE,USER_BUSITYPE_ID,MSISDN,IMSI,
       CMCC_ID,CHANNEL_ID,MOBILE_PUB_TYPE,ACC_TYPE,ENTER_TYPE,BRAND_ID,DATASIM_TYPE,0
       FROM SHBASS.BASS1_USER_SRVC_DAY_20150414
UNION
SELECT A.SUB_ID,A.CUSTOMER_ID,A.USER_TYPE,A.CREATE_DATE,A.USER_BUSITYPE_ID,A.MSISDN,IMSI,
       A.CMCC_ID,A.CHANNEL_ID,A.MOBILE_PUB_TYPE,A.ACC_TYPE,A.ENTER_TYPE,A.BRAND_ID,A.DATASIM_TYPE,0
       FROM SHBASS.BASS1_USER_20150414 A LEFT JOIN SHBASS.BASS1_USER_SRVC_DAY_20150414 B
       ON A.SUB_ID=B.SUB_ID 
       WHERE B.SUB_ID IS NOT NULL;--前一天集团侧全量用户，去掉今天有变更的用户
--7、更新表数据
RUNSTATS ON TABLE SHBASS.BASS1_USER_20150414;

--8、如果是日的最后一天生成月用户表SHBASS.BASS1_USER_201502
CREATE TABLE SHBASS.BASS1_USER_SRVC_201502
(
SUB_ID              VARCHAR(21),
CUSTOMER_ID         VARCHAR(21),
USER_TYPE           VARCHAR(11),
CREATE_DATE         DATE       ,
USER_BUSITYPE_ID    VARCHAR(2) ,
MSISDN              VARCHAR(30),
IMSI                VARCHAR(15),
CMCC_ID             VARCHAR(5) ,
CHANNEL_ID          VARCHAR(25),
MOBILE_PUB_TYPE     VARCHAR(1) ,
ACC_TYPE            VARCHAR(1) ,
ENTER_TYPE          VARCHAR(2) ,
BRAND_ID            VARCHAR(1) ,
DATASIM_TYPE        VARCHAR(1) ,
REGION              CHAR(1),
BASS_USER_STATE_ID  SMALLINT
) DATA CAPTURE NONE
 IN TBSN_APP
  PARTITIONING KEY
   (SUB_ID
   ) USING HASHING;
INSERT INTO SHBASS.BASS1_USER_SRVC_201502 SELECT * FROM SHBASS.BASS1_USER_SRVC_20150228;
CREATE TABLE SHBASS.BASS1_USER_201502
(
SUB_ID            VARCHAR(21),
CUSTOMER_ID       VARCHAR(21),
USER_TYPE         VARCHAR(11),
CREATE_DATE       DATE,
USER_BUSITYPE_ID  VARCHAR(2),
MSISDN            VARCHAR(30),
IMSI              VARCHAR(15),
CMCC_ID           VARCHAR(5),
CHANNEL_ID        VARCHAR(25),
MOBILE_PUB_TYPE   VARCHAR(1),
ACC_TYPE          VARCHAR(1),
ENTER_TYPE        VARCHAR(2),
BRAND_ID          VARCHAR(1),
DATASIM_TYPE      VARCHAR(1),
REGION            CHARACTER(1)
);
INSERT INTO SHBASS.BASS1_USER_201502 SELECT * FROM SHBASS.BASS1_USER_20150228;

















































