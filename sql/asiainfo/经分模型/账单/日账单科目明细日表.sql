select USER_ID, ACCT_ID, ITEM_CODE, BILL_FEE
  from SHDW.DWD_ACC_ITEM_DTL_20131231;
  select count(1) from SHDW.DWD_ACC_ITEM_DTL_20131231;


  SELECT           SUB_ID
                            ,BILL_CODE
                            ,ACC_CODE
                            ,TOTAL_FEE
                            ,CELL_COUNT
                            ,TOTAL_FEE
                            from shods.ODS_DAY_SRVC_BILL_DTL_STEP1_YYYYMMDD