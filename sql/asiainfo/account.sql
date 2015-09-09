select * from pd.pm_composite_offer_price where pricing_plan_id='60006308';
--70004833
select * from pd.PM_COMPONENT_PRODOFFER_PRICE where price_id='70004833';
--
select * from pd.PM_RECURRING_FEE_DTL where price_id='70004833';
select * from pd.pm_rates where rate_id='1269300';
select * from pd.PM_CURVE_SEGMENTS where curve_id='1269300';
select * from pd.PM_COMPOSITE_RULE_PRICE where pricing_plan_id='60006308';--11628
select * from pd.PM_PROD_OFFER_PRICE_RULE where price_rule_id='11628';
select * from pd.PM_PRODUCT_PRICING_PLAN where pricing_plan_id='60006308';
select * from pd.PM_PRODUCT_OFFERING where product_offering_id='90156001';
select * from pd.PM_USAGE_REGULATION;
select * from pd.PM_ALARM_DEF;
select * from pd.PM_BUDGET_REGULATION;
select * from all_tables where table_name like '%SYS_POLICY%' ;
select * from ad.ca_account_41 where acct_id='10119305191';
select * from cd.co_prod_41 where object_id = '1120128152' and expire_date > sysdate ;
--40100001
select * from pd.pm_product_offering where product_offering_id='91195002';
select b.name, a.*
  from cd.co_prod_41 a
  join pd.pm_product_offering b on a.product_offering_id =
                                   b.product_offering_id
                               and object_id = '1120128152'
                               and a.expire_date > sysdate;
select * from pd.PM_PRODUCT_PRICING_PLAN where product_offering_id='40000409' and pricing_plan_id='40000409';
select * from pd.Pm_Charge_Revenue;
select * from pd.pm_composite_offer_price where pricing_plan_id='40000409';
select * from pd.PM_COMPONENT_PRODOFFER_PRICE where price_id='80003106';
select * from pd.PM_BILLING_DISCOUNT_DTL where price_id='80003106';
select * from pd.PM_RECURRING_FEE_DTL where price_id='80006541';
select * from pd.PM_DISCOUNT_PRICE_DTL where price_id='80003324';
select * from pd.PM_RATING_TARIFF where price_id='11800000';
select * from sd.SYS_POLICY where policy_id='0';
select * from pd.PM_ALLOWANCE_FREERES_DETAILS where CYCLE_NUM_FORMULA='0' ;
select * from pd.PM_ALLOWANCE_FREERES_SEGMENT;