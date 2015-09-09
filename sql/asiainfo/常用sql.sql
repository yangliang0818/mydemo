select * from ad.ca_bill_41_201310 where acct_id='10119305191';
select * from ad.Ca_Bill_Chg_41_201310 where acct_id='10119305191';
select * from ad.ca_bill_item_41_201310 where bill_no='200000495198049';
select * from ad.ca_bill_prod_41_201310 where bill_no='200000495198049';
select * from ad.
select * from ad.ca_bill_prod_41_201310 where
--30000464270158 70009673
select * from cd.co_prod_41 where object_id='1120128152';
select distinct item_code from ad.ca_bill_item_41_201310 where bill_no='200000495198049';
select * from pd.pm_price_event where item_id='5023641';
select * from ad.ca_pocket_41 where acct_id='10119305191' ;
select * from pd.pm_asset_item where asset_item_id in ('5023641');
select * from ad.ca_bill_41_201310 where bill_fee =ppy_fee+unpay_fee; * ;
select acct_id,count(1) from ad.CA_CYCLE_RUN_41   group by acct_id having count(acct_id) >1 ;
select * from ad.Ca_Applied_Rate_41_201310 where acct_id='10119305191';
select * from ad.ca_pocket_his;
select * from ad.ca_billing_cycle_spec;
select * from pd.PM_PRICE_EVENT where item_id='10000001';
select * from pd.PM_PRICE_EVENT_REL where rel_item_id='4500011' ;