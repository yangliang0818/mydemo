﻿select REC_SO_NBR, BILL_NO, USER_ID, ACCT_ID, ITEM_CODE, 
    ASSET_CODE, RATE_FEE, BILL_FEE, BILL_MONTH, RATE_DATE, 
    BEGIN_DATE, END_DATE, STAT_MON, DATA_TIME
  from SHDW.DWD_ACC_APPLIED_RATE_201311;
select count(1) from SHDW.DWD_ACC_APPLIED_RATE_201311;

select RATE_ID, RATE_TYPE, AMOUNT, ITEM_ID, ITEM_CODE, DEST_AMOUNT
    , MEASURE_ID, DEST_ITEM_ID, DEST_ITEM_CODE, DEST_MEASURE_ID, 
    ACCT_ID, PRODUCT_ID, RESOURCE_ID, BILL_MONTH, BILL_NO, 
    REL_NUMBER, RATE_DATE, QUANTITY, DESCRIPTION, SO_NBR, 
    VALID_DATE, EXPIRE_DATE, BEGIN_DATE, END_DATE
  from SHODS.ODS_CA_APPLIED_RATE_201311;
select count(1) from SHODS.ODS_CA_APPLIED_RATE_201311;


select count(1) from SHDW.DWD_ACC_APPLIED_RATE_201311;
select BILL_NO, USER_ID, ACCT_ID, ITEM_CODE,
    ASSET_CODE, RATE_FEE, BILL_FEE
  from SHDW.DWD_ACC_APPLIED_RATE_201311;
select BILL_NO
                            ,RESOURCE_ID
                            ,ACCT_ID
                            ,ITEM_CODE
                            ,DEST_ITEM_CODE
                            ,AMOUNT*1.0/100
                            ,DEST_AMOUNT*1.0/100
  from SHODS.ODS_CA_APPLIED_RATE_201311;