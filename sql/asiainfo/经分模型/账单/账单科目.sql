﻿select ITEM_ID
			,NAME
			,SERVICE_SPEC_ID
			,ITEM_TYPE
			,PRIORITY
			,DESCRIPTION
			,b.R00901
			,b.R00902
			,b.R01001
			,b.R01002
  from DB2INFO.ODS_PM_PRICE_EVENT_201311 a left join
       TJUSER.RPT_VR011 b on a.item_id=b.R01101
--账单科目个性化语句
create table SHDW.DIM_ACC_ITEM_CODE_201405_BAK like SHDW.DIM_ACC_ITEM_CODE;
delete from SHDW.DIM_ACC_ITEM_CODE;
INSERT INTO SHDW.DIM_ACC_ITEM_CODE(ITEM_CODE, ITEM_NAME, ITEM_CODE_ONE, FIN_ITEM_ONE_NAME,
    ITEM_CODE_TWO, FIN_ITEM_TWO_NAME,DAYACC_ITEM_ONE, DAYACC_ITEM_ONE_NAME, DAYACC_ITEM_TWO,
    DAYACC_ITEM_TWO_NAME, DAYACC_ITEM_THREE, DAYACC_ITEM_THREE_NAME,
    START_DATE, END_DATE) select ACC_CODE, ACC_NAME, KIND_ID, KIND_NAME, TYPE_ID, TYPE_NAME,
    ACCTDAY_ITEM1,    ACCTDAY_ITEM1_NAME, ACCTDAY_ITEM2, ACCTDAY_ITEM2_NAME,
    ACCTDAY_ITEM3, ACCTDAY_ITEM3_NAME,'1970-01-01','2099-12-31'
  from SHDW.DIM_SUBJECT;
runstats on table SHDW.DIM_ACC_ITEM_CODE with distribution and detailed indexes all;
--纸质账单归类语句2
INSERT INTO SHFIN.DIM_ACC_ITEM_CODE_YL_20140912
WITH T1(RULE_ID,BILL_ITEM_ID,BILL_ITEM_NAME,PARENT_ITEM_ID,PARENT_ITEM_NAME) AS
(SELECT DISTINCT A.RULE_ID,A.BILL_ITEM_ID,B.ITEM_NAME,A.PARENT_ITEM_ID,
C.ITEM_NAME FROM SHODS.ODS_CA_BILL_ITEM_MULTILEVEL_201408 A
LEFT JOIN SHODS.ODS_CA_BILL_ITEM_DEF_201408 B ON A.BILL_ITEM_ID=B.BILL_ITEM_ID
LEFT JOIN SHODS.ODS_CA_BILL_ITEM_DEF_201408 C ON A.PARENT_ITEM_ID=C.BILL_ITEM_ID
LEFT JOIN SHODS.ODS_CA_BILL_ITEM_FEE_ITEM_201408 D ON A.BILL_ITEM_ID=D.BILL_ITEM_ID
),
T2(RULE_ID,ITEM_CODE,PAPER_ITEM_TWO,PAPER_ITEM_TWO_NAME,PAPER_ITEM_ONE,PAPER_ITEM_ONE_NAME,ROW_NUM)AS
(SELECT DISTINCT B.RULE_ID,A.FEE_ITEM_ID,B.PARENT_ITEM_ID,B.PARENT_ITEM_NAME,C.PARENT_ITEM_ID,C.PARENT_ITEM_NAME,
ROW_NUMBER() OVER(PARTITION BY A.FEE_ITEM_ID ORDER BY C.RULE_ID) AS ROW_NUM
FROM SHODS.ODS_CA_BILL_ITEM_FEE_ITEM_201408 A LEFT JOIN T1 AS B ON A.BILL_ITEM_ID=B.BILL_ITEM_ID
LEFT JOIN T1 AS C ON B.PARENT_ITEM_ID=C.BILL_ITEM_ID
),
T3(RULE_ID,ITEM_CODE,PAPER_ITEM_TWO,PAPER_ITEM_TWO_NAME,PAPER_ITEM_ONE,PAPER_ITEM_ONE_NAME,ROW_NUM) AS
(SELECT RULE_ID,ITEM_CODE,PAPER_ITEM_TWO,PAPER_ITEM_TWO_NAME,PAPER_ITEM_ONE,PAPER_ITEM_ONE_NAME,ROW_NUM FROM T2 WHERE ROW_NUM=1),
T4(ITEM_CODE, ITEM_NAME, ITEM_CODE_ONE, FIN_ITEM_ONE_NAME,
ITEM_CODE_TWO, FIN_ITEM_TWO_NAME, PAPER_ITEM_ONE,
PAPER_ITEM_ONE_NAME, PAPER_ITEM_TWO, PAPER_ITEM_TWO_NAME,
DAYACC_ITEM_ONE, DAYACC_ITEM_ONE_NAME, DAYACC_ITEM_TWO,
DAYACC_ITEM_TWO_NAME, DAYACC_ITEM_THREE, DAYACC_ITEM_THREE_NAME,
START_DATE, END_DATE) AS
(SELECT A.ITEM_CODE, A.ITEM_NAME, A.ITEM_CODE_ONE, A.FIN_ITEM_ONE_NAME,
A.ITEM_CODE_TWO, A.FIN_ITEM_TWO_NAME, T3.PAPER_ITEM_ONE,
T3.PAPER_ITEM_ONE_NAME, T3.PAPER_ITEM_TWO, T3.PAPER_ITEM_TWO_NAME,
A.DAYACC_ITEM_ONE, A.DAYACC_ITEM_ONE_NAME, A.DAYACC_ITEM_TWO,
A.DAYACC_ITEM_TWO_NAME, A.DAYACC_ITEM_THREE, A.DAYACC_ITEM_THREE_NAME,
A.START_DATE, A.END_DATE FROM SHDW.DIM_ACC_ITEM_CODE A
LEFT JOIN T3 ON A.ITEM_CODE=T3.ITEM_CODE),
T5(ITEM_CODE, ITEM_NAME, ITEM_CODE_ONE, FIN_ITEM_ONE_NAME,
ITEM_CODE_TWO, FIN_ITEM_TWO_NAME, PAPER_ITEM_ONE,
PAPER_ITEM_ONE_NAME, PAPER_ITEM_TWO, PAPER_ITEM_TWO_NAME,
DAYACC_ITEM_ONE, DAYACC_ITEM_ONE_NAME, DAYACC_ITEM_TWO,
DAYACC_ITEM_TWO_NAME, DAYACC_ITEM_THREE, DAYACC_ITEM_THREE_NAME,
START_DATE, END_DATE) AS
(SELECT DISTINCT T4.ITEM_CODE, T4.ITEM_NAME, T4.ITEM_CODE_ONE, T4.FIN_ITEM_ONE_NAME,
T4.ITEM_CODE_TWO, T4.FIN_ITEM_TWO_NAME, VALUE(T3.PAPER_ITEM_ONE,T4.PAPER_ITEM_ONE),
VALUE(T3.PAPER_ITEM_ONE_NAME,T4.PAPER_ITEM_ONE_NAME), VALUE(T3.PAPER_ITEM_TWO,T4.PAPER_ITEM_TWO),
VALUE(T3.PAPER_ITEM_TWO_NAME,T4.PAPER_ITEM_TWO_NAME),
T4.DAYACC_ITEM_ONE, T4.DAYACC_ITEM_ONE_NAME, T4.DAYACC_ITEM_TWO,
T4.DAYACC_ITEM_TWO_NAME, T4.DAYACC_ITEM_THREE, T4.DAYACC_ITEM_THREE_NAME,
T4.START_DATE, T4.END_DATE FROM T4
LEFT JOIN SHODS.ODS_PM_ITEM_SPLIT_RATE_201408 A
ON T4.ITEM_CODE=A.DST_ITEM_CODE
LEFT JOIN T3 ON A.ITEM_CODE=T3.ITEM_CODE),
T6(ITEM_CODE,PAPER_ITEM_ONE,
PAPER_ITEM_ONE_NAME, PAPER_ITEM_TWO, PAPER_ITEM_TWO_NAME) AS
(SELECT ITEM_CODE,PAPER_ITEM_ONE,
PAPER_ITEM_ONE_NAME, PAPER_ITEM_TWO, PAPER_ITEM_TWO_NAME FROM T5 WHERE ITEM_CODE LIKE '%1' AND PAPER_ITEM_ONE IS NOT NULL
UNION
SELECT INTEGER(ITEM_CODE/10||'2'),PAPER_ITEM_ONE,
PAPER_ITEM_ONE_NAME, PAPER_ITEM_TWO, PAPER_ITEM_TWO_NAME FROM T5 WHERE ITEM_CODE LIKE '%1' AND PAPER_ITEM_ONE IS NOT NULL
UNION
SELECT INTEGER(ITEM_CODE/10||'4'),PAPER_ITEM_ONE,
PAPER_ITEM_ONE_NAME, PAPER_ITEM_TWO, PAPER_ITEM_TWO_NAME FROM T5 WHERE ITEM_CODE LIKE '%1' AND PAPER_ITEM_ONE IS NOT NULL
UNION
SELECT INTEGER(ITEM_CODE/10||'5'),PAPER_ITEM_ONE,
PAPER_ITEM_ONE_NAME, PAPER_ITEM_TWO, PAPER_ITEM_TWO_NAME FROM T5 WHERE ITEM_CODE LIKE '%1' AND PAPER_ITEM_ONE IS NOT NULL)
SELECT DISTINCT T5.ITEM_CODE, T5.ITEM_NAME, T5.ITEM_CODE_ONE, T5.FIN_ITEM_ONE_NAME,
T5.ITEM_CODE_TWO, T5.FIN_ITEM_TWO_NAME, VALUE(T6.PAPER_ITEM_ONE,T5.PAPER_ITEM_ONE),
VALUE(T6.PAPER_ITEM_ONE_NAME,T5.PAPER_ITEM_ONE_NAME), VALUE(T6.PAPER_ITEM_TWO,T5.PAPER_ITEM_TWO),
VALUE(T6.PAPER_ITEM_TWO_NAME,T5.PAPER_ITEM_TWO_NAME),
T5.DAYACC_ITEM_ONE, T5.DAYACC_ITEM_ONE_NAME, T5.DAYACC_ITEM_TWO,
T5.DAYACC_ITEM_TWO_NAME, T5.DAYACC_ITEM_THREE, T5.DAYACC_ITEM_THREE_NAME,
T5.START_DATE, T5.END_DATE FROM T5 LEFT JOIN T6 ON T5.ITEM_CODE=T6.ITEM_CODE;


--20150201个性化脚本
select *
  from "SHDW"."DIM_SUBJECT" where acc_code in (1967542,
1976124,
1946544,
9950081,
9950091,
1946175,
1967541,
9950174);
create table SHDW.DIM_ACC_ITEM_CODE_201501_BAK_YL like SHDW.DIM_ACC_ITEM_CODE;
delete from SHDW.DIM_ACC_ITEM_CODE;
insert into SHDW.DIM_ACC_ITEM_CODE_201501_BAK_YL select * from SHDW.DIM_ACC_ITEM_CODE;
INSERT INTO SHDW.DIM_ACC_ITEM_CODE(ITEM_CODE, ITEM_NAME, ITEM_CODE_ONE, FIN_ITEM_ONE_NAME,
    ITEM_CODE_TWO, FIN_ITEM_TWO_NAME,DAYACC_ITEM_ONE, DAYACC_ITEM_ONE_NAME, DAYACC_ITEM_TWO,
    DAYACC_ITEM_TWO_NAME, DAYACC_ITEM_THREE, DAYACC_ITEM_THREE_NAME,
    START_DATE, END_DATE) select ACC_CODE, ACC_NAME, KIND_ID, KIND_NAME, TYPE_ID, TYPE_NAME,
    ACCTDAY_ITEM1,    ACCTDAY_ITEM1_NAME, ACCTDAY_ITEM2, ACCTDAY_ITEM2_NAME,
    ACCTDAY_ITEM3, ACCTDAY_ITEM3_NAME,'1970-01-01','2099-12-31'
  from SHDW.DIM_SUBJECT where acc_code in (1967542,
1976124,
1946544,
9950081,
9950091,
1946175,
1967541,
9950174);
runstats on table SHDW.DIM_ACC_ITEM_CODE with distribution and detailed indexes all;