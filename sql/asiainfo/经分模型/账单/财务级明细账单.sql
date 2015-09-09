SELECT B.BILL_NO,
      SUBSTR(BILL_CODE, 1, 11) ACC_ID,
      SUB_ID,
      C.ITEM_CODE,
      C.PRIMAL_FEE,
      C.PRODUCT_ID AS PROD_INST_ID,
      C.UNIT AS CELL_CNT,
      C.UNIT_ID,
      0 AS TAX_FEE,
      0 TAX_RATE
 FROM ODS.ODS_SRVC_BILL_DTL_STEP1_201312 A
 LEFT JOIN ODS.ODS_CA_BILL_201312 B
   ON SUBSTR(A.BILL_CODE, 1, 11) = B.ACCT_ID
 LEFT JOIN ODS.ODS_CA_BILL_PROD_201312 C
   ON B.BILL_NO = C.BILL_NO

--插入SQL
INSERT INTO  shdw.DWD_ACC_FIN_ITEM_DTL_201401 (
                             BILL_NO
                            ,ACCT_ID
                            ,USER_ID
                            ,ITEM_CODE
                            ,BILL_FEE
                            ,PROD_INST_ID
                            ,TAX_FEE
                            ,TAX_RATE
                            ,CELL_CNT
                            ,MEASURE_ID
                            ,STAT_MON
                            ,DATA_TIME

                  )
                    SELECT
                       ADJUST_NO
                      ,SUBSTR(BILL_CODE,1,11) AS ACC_ID
                      ,SUB_ID
                      ,ACC_CODE
                      ,TOTAL_FEE*1.0/100
                      ,TOTAL_CNT  AS PROD_INST_ID
                      ,CELL_COUNT AS CELL_CNT
                      ,HAS_LATE_FEE
                      ,0 AS TAX_FEE
                      ,0 TAX_RATE
                      ,201401
                      ,2014021714
                 FROM DB2INFO.ODS_SRVC_BILL_DTL_STEP1_201401
           ;
