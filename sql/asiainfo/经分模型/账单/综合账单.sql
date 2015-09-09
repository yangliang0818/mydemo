select a.bill_no,
       acct_id,
       resource_id,
       default_acct_id,
       a.bill_fee,
       sts,
       0 as TAX_FEE,
       case
         when (a.resource_id = 0 and b.item_code = 5090023) then
          b.bill_fee
         else
          0
       end as ODD_FEE,
       BILL_MONTH,
       BEGIN_DATE,
       END_DATE
  from ad.CA_BILL_41_201311 a
  left join ad.ca_bill_item_41_201311 b
    on a.bill_no = b.bill_no
   and b.item_code = 5090023
---检查数据量
select count(1)
  from SHDW.DWD_ACC_SUM_BILL_201311;
select count(1)
  from SHODS.ODS_CA_BILL_201311;
---检查主要字段
select BILL_NO, ACCT_ID, USER_ID, BILL_STS,
     BILL_FEE  from SHDW.DWD_ACC_SUM_BILL_201311;
select BILL_NO, ACCT_ID, RESOURCE_ID, STS,BILL_FEE
      from DB2INFO.ODS_CA_BILL_201311;
--目标表总金额1568148293.30 =源表1567219087.98 减去抹零头费用(-929205.32)
--账户费用验证
select acct_id,sum(bill_fee)
  from SHDW.DWD_ACC_SUM_BILL_201311 group by acct_id;
select acct_id,sum(bill_fee)
  from SHODS.ODS_CA_BILL_201311 group by acct_id;
select * from SHDW.DWD_ACC_SUM_BILL_201311 where acct_id=10000000130;
select * from SHODS.ODS_CA_BILL_201311 where acct_id='10000000130';
--用户费用验证
select user_id,sum(bill_fee)
  from SHDW.DWD_ACC_SUM_BILL_201311 group by user_id;
select resource_id,sum(bill_fee)*1.0/100
  from SHODS.ODS_CA_BILL_201311 group by resource_id;
select bill_no,acct_id,user_id,bill_fee
  from SHDW.DWD_ACC_SUM_BILL_201311 where user_id='1000013769';
select bill_no,acct_id,resource_id,bill_fee*1.0/100
  from SHODS.ODS_CA_BILL_201311 where resource_id='1000013769';
--总金额汇总
select sum(bill_fee) from SHDW.DWD_ACC_SUM_BILL_201311;
select sum(bill_fee)*1.0/100 from SHODS.ODS_CA_BILL_201311;






















