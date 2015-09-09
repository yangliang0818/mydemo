create table aid.tmp_union_bill_yyyymmdd_n nologging parallel(degree 5) tablespace TS_ACCT_DAT_01
  as SELECT decode(a.object_type,0,a.object_id,0) sub_id,(a.pay_acct_id*10000+yymm) bill_code ,b.item_code acc_code,
  b.primal_fee total_fee ,b.primal_fee pre_fee,b.primal_fee unpay_amt,0 cell_count,a.bill_no adjust_no,0 total_unit,b.product_id total_cnt,0 has_late_fee
  FROM ad.ca_daily_bill_yyyymmdd a, ad.ca_rc_bill_dtl_yyyymmdd b
  WHERE a.bill_no=b.bill_no AND MOD(a.pay_acct_id,10)=n
  UNION ALL
  SELECT decode(a.object_type,0,a.object_id,0) sub_id,(a.pay_acct_id*10000+yymm) bill_code ,b.item_code acc_code,b.discount_fee total_fee,
  b.discount_fee pre_fee,b.discount_fee unpay_amt,0 cell_count,a.bill_no adjust_no,0 total_unit,b.product_id total_cnt,0 has_late_fee
  FROM ad.ca_daily_bill_yyyymmdd a, ad.ca_prom_bill_dtl_yyyymmdd b
  WHERE a.bill_no=b.bill_no AND MOD(a.pay_acct_id,10)=n
  UNION ALL
  SELECT decode(a.object_type,0,a.object_id,0) sub_id,(a.pay_acct_id*10000+yymm) bill_code ,b.item_code acc_code,b.primal_fee total_fee,
  b.primal_fee pre_fee,b.primal_fee unpay_amt,b.accumulate_value cell_count,a.bill_no adjust_no,0 total_unit,b.product_id total_cnt,0 has_late_fee
  FROM ad.ca_daily_bill_yyyymmdd a, ad.ca_usage_bill_dtl_yyyymmdd b
  WHERE a.bill_no=b.bill_no AND MOD(a.pay_acct_id,10)=n;


  create table aid.ngdfee_yyyymmdd_0n nologging parallel(degree 5) tablespace TS_ACCT_DAT_01
  as SELECT bill_code,sub_id,acc_code,adjust_no,sum(total_fee) total_fee,sum(pre_fee) pre_fee,sum(unpay_amt) unpay_amt,
  total_unit,total_cnt,sum(cell_count) cell_count,has_late_fee
  from aid.tmp_union_bill_yyyymmdd_n
  group by bill_code,sub_id,acc_code,adjust_no,total_unit,total_cnt,has_late_fee

-----------------建表语句------------------
CREATE TABLE "SHODS"."ODS_CA_DAILY_BILL_20140331"
 ("BILL_NO"          BIGINT,
  "OBJECT_TYPE"      SMALLINT,
  "OBJECT_ID"        BIGINT,
  "DEFAULT_ACCT_ID"  BIGINT,
  "PAY_ACCT_ID"      BIGINT,
  "BEGIN_DATE"       TIMESTAMP,
  "END_DATE"         TIMESTAMP,
  "CURRENT_DATE"     VARCHAR(21),
  "WAIF_FLAG"        SMALLINT,
  "REGION_CODE"      SMALLINT
 )
  DATA CAPTURE NONE
 IN "TBS_ODS"
  PARTITIONING KEY
   (BILL_NO
   ) USING HASHING;

CREATE TABLE "SHODS"."ODS_CA_RC_BILL_DTL_20140331"
 ("BILL_NO"       BIGINT,
  "PRODUCT_ID"    BIGINT,
  "PRICE_ID"      INTEGER,
  "ITEM_CODE"     INTEGER,
  "PRIMAL_FEE"    BIGINT,
  "MEASURE_ID"    INTEGER,
  "BILLING_TYPE"  SMALLINT,
  "TAX_INCLUDE"   SMALLINT
 )
  DATA CAPTURE NONE
 IN "TBS_ODS"
  PARTITIONING KEY
   (BILL_NO
   ) USING HASHING;
CREATE TABLE "SHODS"."ODS_CA_PROM_BILL_DTL_20140331"
 ("BILL_NO"         BIGINT,
  "PRODUCT_ID"      BIGINT,
  "PRICE_ID"        INTEGER,
  "REF_PRODUCT_ID"  BIGINT,
  "ITEM_CODE"       INTEGER,
  "BASE_ITEM"       INTEGER,
  "ADJUST_ITEM"     INTEGER,
  "DISCOUNT_FEE"    BIGINT,
  "PROM_FLAG"       SMALLINT,
  "MEASURE_ID"      INTEGER,
  "BILLING_TYPE"    SMALLINT,
  "TAX_INCLUDE"     SMALLINT
 )
  DATA CAPTURE NONE
 IN "TBS_ODS"
  PARTITIONING KEY
   (BILL_NO
   ) USING HASHING;

CREATE TABLE "SHODS"."ODS_CA_USAGE_BILL_DTL_20140331"
 ("BILL_NO"           BIGINT,
  "PRODUCT_ID"        BIGINT,
  "ACCUMULATE_VALUE"  BIGINT,
  "ITEM_CODE"         BIGINT,
  "PRIMAL_FEE"        BIGINT,
  "DISCOUNT_FEE"      BIGINT,
  "ACCU_MEASURE_ID"   BIGINT,
  "MEASURE_ID"        BIGINT,
  "BILLING_TYPE"      INTEGER,
  "TAX_INCLUDE"       INTEGER
 )
  DATA CAPTURE NONE
 IN "TBS_ODS"
 INDEX IN "TBS_INDEX"
  PARTITIONING KEY
   (BILL_NO
   ) USING HASHING;

CREATE TABLE "DB2APP"."ODS_DAY_SRVC_BILL_DTL_STEP1_20140331"
 ("BILL_CODE"     VARCHAR(15),
  "SUB_ID"        VARCHAR(21),
  "ACC_CODE"      INTEGER,
  "ADJUST_NO"     BIGINT,
  "TOTAL_FEE"     BIGINT,
  "UNPAY_AMT"     BIGINT,
  "PRE_FEE"       BIGINT,
  "TOTAL_UNIT"    BIGINT,
  "TOTAL_CNT"     BIGINT,
  "CELL_COUNT"    BIGINT,
  "HAS_LATE_FEE"  BIGINT
 )
  DATA CAPTURE NONE
 IN "TBS_ODS"
  PARTITIONING KEY
   (BILL_CODE,
    SUB_ID
   ) USING HASHING;
---------------oralce语句-------------
create view v_dwd_acc_item_code_20140310 as
SELECT decode(a.object_type, 0, a.object_id, 0) sub_id,
       (a.pay_acct_id * 10000 + 201403) bill_code,
       b.item_code acc_code,
       b.primal_fee total_fee,
       b.primal_fee pre_fee,
       b.primal_fee unpay_amt,
       0 cell_count,
       a.bill_no adjust_no,
       0 total_unit,
       b.product_id total_cnt,
       0 has_late_fee
  FROM ad.ca_daily_bill_20140305 a, ad.ca_rc_bill_dtl_20140305 b
 WHERE a.bill_no = b.bill_no
UNION ALL
SELECT decode(a.object_type, 0, a.object_id, 0) sub_id,
       (a.pay_acct_id * 10000 + 201403) bill_code,
       b.item_code acc_code,
       b.discount_fee total_fee,
       b.discount_fee pre_fee,
       b.discount_fee unpay_amt,
       0 cell_count,
       a.bill_no adjust_no,
       0 total_unit,
       b.product_id total_cnt,
       0 has_late_fee
  FROM ad.ca_daily_bill_20140305 a, ad.ca_prom_bill_dtl_20140305 b
 WHERE a.bill_no = b.bill_no
UNION ALL
SELECT decode(a.object_type, 0, a.object_id, 0) sub_id,
       (a.pay_acct_id * 10000 + 201403) bill_code,
       b.item_code acc_code,
       b.primal_fee total_fee,
       b.primal_fee pre_fee,
       b.primal_fee unpay_amt,
       b.accumulate_value cell_count,
       a.bill_no adjust_no,
       0 total_unit,
       b.product_id total_cnt,
       0 has_late_fee
  FROM ad.ca_daily_bill_20140305 a, ad.ca_usage_bill_dtl_20140305 b
 WHERE a.bill_no = b.bill_no;




