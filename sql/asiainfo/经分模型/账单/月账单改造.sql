select "BILL_NO", "FEE_TYPE", "ITEM_CODE", "PRIMAL_FEE", "PRODUCT_ID", "UNIT",
    "TAX_FEE", "TAX_INCLUDE", "PRICE_ID", "BEGIN_DATE", "END_DATE", "UNIT_ID"
  from "SHDW"."TEMP_ODS_CA_BILL_PROD_201312";
insert into "SHDW"."TEMP_ODS_CA_BILL_PROD_201312" select * from "DB2INFO"."ODS_CA_BILL_PROD_201312";

"BILL_CODE"     VARCHAR(30)     NOT NULL,
  "SUB_ID"        VARCHAR(21)     NOT NULL,
  "ACC_CODE"      INTEGER         NOT NULL,
  "ADJUST_NO"     BIGINT          NOT NULL,
  "TOTAL_FEE"     BIGINT          NOT NULL,
  "PRE_FEE"       BIGINT          NOT NULL,
  "UNPAY_AMT"     BIGINT          NOT NULL,
  "TOTAL_UNIT"    BIGINT,
  "TOTAL_CNT"     BIGINT,
  "CELL_COUNT"    BIGINT,
  "HAS_LATE_FEE"  BIGINT          NOT NULL

 SELECT (A.ACCT_ID * 10000 +1312) BILL_CODE,A.RESOURCE_ID SUB_ID,B.ITEM_CODE ACC_CODE,
  A.BILL_NO ADJUST_NO,SUM(B.PRIMAL_FEE) TOTAL_FEE,SUM(B.PRIMAL_FEE) PRE_FEE,SUM(B.PRIMAL_FEE) UNPAY_AMT,
  0 TOTAL_UNIT,B.PRODUCT_ID TOTAL_CNT,SUM(B.UNIT) CELL_COUNT,B.UNIT_ID HAS_LATE_FEE
  FROM db2info.ods_CA_BILL_201312 A, shdw.TEMP_ODS_CA_BILL_PROD_201312 B
  WHERE A.BILL_NO = B.BILL_NO GROUP BY (A.ACCT_ID * 10000 + 1312) ,A.RESOURCE_ID,B.ITEM_CODE,B.UNIT_ID,B.PRODUCT_ID,A.BILL_NO;
  --第一步先跑基本的数据
  insert into shdw.ODS_SRVC_BILL_DTL_STEP1_201312_1
   SELECT (A.ACCT_ID * 10000 +1312) BILL_CODE,A.RESOURCE_ID SUB_ID,B.ITEM_CODE ACC_CODE,
  A.BILL_NO ADJUST_NO,B.PRIMAL_FEE TOTAL_FEE,B.PRIMAL_FEE PRE_FEE,B.PRIMAL_FEE UNPAY_AMT,
  0 TOTAL_UNIT,B.PRODUCT_ID TOTAL_CNT,B.UNIT CELL_COUNT,B.UNIT_ID HAS_LATE_FEE
  FROM db2info.ods_CA_BILL_201312 A, shdw.TEMP_ODS_CA_BILL_PROD_201312 B
  WHERE A.BILL_NO = B.BILL_NO;
  --第二步汇总数据
    insert into shdw.ODS_SRVC_BILL_DTL_STEP1_201312_2
  select BILL_CODE,SUB_ID,ACC_CODE,ADJUST_NO,sum(TOTAL_FEE),sum(PRE_FEE) ,sum(UNPAY_AMT),TOTAL_UNIT,TOTAL_CNT,sum(CELL_COUNT),HAS_LATE_FEE
  from shdw.ODS_SRVC_BILL_DTL_STEP1_201312_1 group by BILL_CODE,SUB_ID,ACC_CODE, ADJUST_NO,TOTAL_UNIT,TOTAL_CNT,HAS_LATE_FEE;
  --第三步科目进行拆分
  insert into shdw.ODS_SRVC_BILL_DTL_STEP1_201312_3
select a.bill_code,a.sub_id,value(b.dst_acc_code,a.acc_code) acc_code,a.adjust_no,a.total_fee,a.pre_fee,a.unpay_amt,a.total_unit,a.total_cnt,a.cell_count,a.has_late_fee
 from shdw.ODS_SRVC_BILL_DTL_STEP1_201312_2  a left join db2info.ODS_SHXC_BILL_DTL_SPLIT_CFG_DST_201311 b on a.acc_code=b.plan_id;
 --第四步科目进行归并，相同订购的数据取最大值的那条
insert into shdw.ODS_SRVC_BILL_DTL_STEP1_201312_4
 select bill_code,sub_id,acc_code,max(adjust_no),0,0,0,max(total_unit),max(total_cnt),0,max(has_late_fee)
 from shdw.ODS_SRVC_BILL_DTL_STEP1_201312_3  group by bill_code,sub_id,acc_code ;

 --第五部向最终表插入数据
 insert into shdw.ODS_SRVC_BILL_DTL_STEP1_201312_5
select a.bill_code,a.sub_id,a.acc_code,value(b.adjust_no,a.adjust_no),a.total_fee,a.pre_fee,a.unpay_amt,
	   value(b.total_unit,a.total_unit),value(b.total_cnt,a.total_cnt),a.cell_count,value(b.has_late_fee,a.has_late_fee)
   from db2info.ODS_SRVC_BILL_DTL_STEP1_201312 a left join shdw.ODS_SRVC_BILL_DTL_STEP1_201312_4 b on
   a.bill_code=b.bill_code and a.sub_id=b.sub_id and a.acc_code=b.acc_code;

---往DWD插入数据

insert into "SHDW"."DWD_ACC_FIN_ITEM_DTL_201401"
(BILL_NO
                            ,ACCT_ID
                            ,USER_ID
                            ,ITEM_CODE
                            ,BILL_FEE
                            ,PROD_INST_ID
                            ,CELL_CNT
                            ,MEASURE_ID
                            ,TAX_FEE
                            ,TAX_RATE
                            ,STAT_MON
                            ,DATA_TIME)
SELECT
                       ADJUST_NO
                      ,SUBSTR(BILL_CODE,1,11) AS ACC_ID
                      ,SUB_ID
                      ,ACC_CODE
                      ,TOTAL_FEE*1.00/100
                      ,TOTAL_CNT  AS PROD_INST_ID
                      ,CELL_COUNT AS CELL_CNT
                      ,HAS_LATE_FEE
                      ,0 AS TAX_FEE
                      ,0 AS TAX_RATE
                      ,201401
                      ,2014021819
                 FROM shdw.ODS_SRVC_BILL_DTL_STEP1_201401_5

   select * from shdw.ODS_SRVC_BILL_DTL_STEP1_201312_3 where bill_code='900015099511312';

   select * from shdw.ODS_SRVC_BILL_DTL_STEP1_201312_2 where bill_code='900015099511312';

   select BILL_CODE,SUB_ID,ACC_CODE,ADJUST_NO,sum(TOTAL_FEE),sum(PRE_FEE) ,sum(UNPAY_AMT),TOTAL_UNIT,TOTAL_CNT,sum(CELL_COUNT),HAS_LATE_FEE
  from shdw.ODS_SRVC_BILL_DTL_STEP1_201312_3
   where bill_code='900015099511312' and sub_id=1475231 and acc_code=4500011
  group by BILL_CODE,SUB_ID,ACC_CODE, ADJUST_NO,TOTAL_UNIT,TOTAL_CNT,HAS_LATE_FEE