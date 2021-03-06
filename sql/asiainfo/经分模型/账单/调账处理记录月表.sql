﻿---检查数据量
SELECT
   A.SO_NBR
  ,A.ADJUST_REASON
  ,A.ITEM_CODE
  ,A.BILL_NO
  ,A.SPEC_ID
  ,A.ACCT_ID
  ,A.RESOURCE_ID
  ,A.BILL_MONTH
  ,A.IDENTITY
  ,A.BILL_LEVEL
  ,A.SRC_BILL_MONTH
  ,A.ADJUST_TOTAL*1.0/100
  ,A.ORG_ID
  ,A.OP_ID
  ,A.SO_DATE
  ,A.BEGIN_DATE
  ,A.END_DATE
  ,A.ADJUST_BILLFEE*1.0/100
  ,A.ADJUST_ASSETFEE*1.0/100
  ,A.ADJUST_EXTFEE*1.0/100
  ,A.ADJUST_TYPE
  ,A.REASON_ONE
  ,A.REASON_THREE
  ,A.REASON_TWO
  ,A.REASON_FOUR
  ,A.REASON_FIVE
  ,A.DEAL_REASON
  ,C.ORDER_DEPT
  ,C.LAST_DEPT
  ,A.REMARK
  ,201311
  ,2014011410
  FROM shods.ODS_CA_BILL_BUSI_REC_201311 A  JOIN tmp.T1_DWD_ACC_BILL_BUSI_REC_201311 B
  ON A.SO_NBR=B.BILL_NO
  JOIN  tmp.T2_DWD_ACC_BILL_BUSI_REC_201311 C
  ON B.SO_NBR=C.SO_NBR
SELECT
      TRIM(SO_NBR)
     ,DEPT_CODE
     ,LAST_ORG_ID
FROM  shods.ODS_CA_ADJUST_INFO_201311






