select b.name as "????????",c.name as "??±?????",a.* from 
(
select * from ad.CA_APPLIED_RATE_41_201310 where acct_id='10119305191' and rate_type='9'
)a left join pd.pm_price_event b on a.dest_item_code=b.item_id   left join pd.pm_asset_item c on  a.item_code=c.asset_item_id  order by b.name desc;

select * from ad.CA_APPLIED_RATE_41_201310 where acct_id='10119305191' and rate_type='9';
select * from pd.pm_asset_item where asset_item_id in ('5036101','5020011','5023641','5036101','5020011'); 
select * from pd.pm_price_event where item_id in ('5030011','5023641','5036101','5020011');
select * from ad.ca_busi_rec_41_201309 where acct_id='10119305191' and busi_spec_id='202007801';
select * from ad.ca_busi_rec_rel_41_201309 where so_nbr='1037457718667';
select * from ad.acct_bill_unpay;
select * from all_tables where table_name like '%BI_BUSI_SPEC_DEF%';
select * from bd.Rs_Sys_Event_Element_Gen;
select * from ad.BI_BUSI_SPEC_DEF where busi_spec_id='202007801';
select b.name,a.amount,a.pocket_item,a.* from 
(
select * from ad.ca_pocket_34  where acct_id='31002618684' 
)a 
left  join pd.pm_asset_item b on  a.pocket_item=b.asset_item_id order by a.amount desc; 
select * from cd.co_prod_41 where so_nbr='1049751949454';
select * from ad.ca_asset_chg_41_201309;
select b.name,a.item_code,a.deal_amount/100,a.org_amount/100,a.deal_date from
(
select * from ad.ca_asset_chg_41_201310 where acct_id='10119305191'
)a left join pd.pm_asset_item b on a.item_code=b.asset_item_id order by deal_date;
select * from ad.CA_CYCLE_RUN_CON;
select * from ad.bi_busi_plan;