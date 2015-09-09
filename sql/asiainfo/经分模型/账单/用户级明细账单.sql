SELECT B.BILL_NO,
       SUBSTR(A.BILL_CODE, 1, 11) AS ACC_ID,
       A.SUB_ID,
       A.ACC_CODE,
       A.TOTAL_FEE,
       0 AS TAX_FEE,
       0 AS TAX_RATE
  FROM ODS.ODS_SRVC_BILL_DTL_THREE_201312 A
  LEFT JOIN ODS.ODS_CA_BILL_201312 B
    ON SUBSTR(A.BILL_CODE, 1, 11) = B.ACCT_ID
---检查数据量
select count(1) from shdw.DWD_ACC_ITEM_DTL_201311;
select count(1) from SHODS.ODS_CA_BILL_ITEM_201311;
---检查主要字段
select BILL_NO, ITEM_CODE, BILL_FEE
      from SHDW.DWD_ACC_ITEM_DTL_201311;
select BILL_NO, ITEM_CODE, BILL_FEE
      from SHODS.ODS_CA_BILL_ITEM_201311 ;
---检查费用的平衡性
select sum(bill_fee) from shdw.DWD_ACC_ITEM_DTL_201311;
select sum(bill_fee)*1.0/100 from shods.ods_ca_bill_item_201311 WHERE ITEM_CODE<>5090023;
--账户，用户，科目
