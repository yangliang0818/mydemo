在218上 bijava/proc
?
./run.sh "-f DimAccSpInfo -t 201405"
run.sh  DimAccSpInfo 20140715
./run.sh "-f DwdAccFinItemDtlM -t 201403"
./run.sh "-f DwdAccBusiRecDmM -t 20140515"
DwdAccFinItemDtlM

--创建临时表
CREATE TABLE {TEMP}.T2_DWD_ACC_FIN_ITEM_DTL_&MTASK_ID LIKE {TEMPLATE}.DWD_ACC_FIN_ITEM_DTL_YYYYMM;ACCT_ID,USER_ID,ITEM_CODE;{TbsTemp};{TbsIdx}
--插入临时表
{TEMP}.T1_DWD_ACC_FIN_ITEM_DTL_&MTASK_ID;
INSERT INTO  {TEMP}.T2_DWD_ACC_FIN_ITEM_DTL_&MTASK_ID (
                 BILL_NO
                ,ACCT_ID
                ,USER_ID
                ,ITEM_CODE
                ,BILL_FEE
                ,PROD_INST_ID
                ,CELL_CNT
                ,MEASURE_ID
      )
        SELECT A.BILL_NO
              ,A.ACCT_ID
              ,A.RESOURCE_ID
              ,B.ITEM_CODE
              ,B.BILL_FEE
              ,B.PROD_INST_ID
              ,B.CELL_CNT
              ,B.MEASURE_ID
          FROM {ODS}.ODS_CA_BILL&MTASK_ID A, {TEMP}.T1_DWD_ACC_FIN_ITEM_DTL_&MTASK_ID B
          WHERE A.BILL_NO = B.USER_ID

          DIM_SP厂商资料信息
          DWD_SP账单费用信息月表