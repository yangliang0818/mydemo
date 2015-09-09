select "ACCT_ID", "BILL_MONTH", "PAY_CYCLE", "EFF_TIME", "EXP_TIME", "SO_NBR",
    "EXT1", "STAT_MON", "DATA_TIME"
  from "SHTEMPLATE"."DWD_ACC_SPEC_CYCLE_YYYYMM";
create table shdw.DWD_ACC_SPEC_CYCLE_201401 like "SHTEMPLATE"."DWD_ACC_SPEC_CYCLE_YYYYMM";
insert into shdw.DWD_ACC_SPEC_CYCLE_201401
(ACCT_ID
                    ,PAY_CYCLE
                    ,EFF_TIME
                    ,EXP_TIME
                    ,SO_NBR
                    ,BILL_MONTH
                    ,STAT_MON
                    ,DATA_TIME
)
SELECT
                    acc_id                  as ACCT_ID
                   ,pay_period              as PAY_CYCLE
                   ,valid_date              as EFF_TIME
                   ,expire_date             as EXP_TIME
                   ,done_code               as SO_NBR
                   ,0                       as BILL_MONTH
                   ,201401
                   ,2014022111
               FROM
                   DB2INFO.ODS_SPECIAL_PAY_ACCOUNT_INFO_201401
               UNION ALL
                   SELECT
                         acc_id                  as ACCT_ID
                        ,pay_period              as PAY_CYCLE
                        ,valid_date              as EFF_TIME
                        ,expire_date             as EXP_TIME
                        ,done_code               as SO_NBR
                        ,bill_month              as BILL_MONTH
                        ,201401
                        ,2014022111
                   FROM
                       "DB2INFO"."ODS_SPECIAL_PAY_ACCOUNT_BILL_INFO_201401";
runstats on table  shdw.DWD_ACC_SPEC_CYCLE_201401   with distribution and detailed indexes all;
select * from shdw.DWD_ACC_SPEC_CYCLE_201401;
