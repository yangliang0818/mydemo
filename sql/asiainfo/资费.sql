select * from pd.PM_COMPOSITE_OFFER_PRICE;
select * from pd.PM_COMPONENT_PRODOFFER_PRICE;
select * from pd.PM_RECURRING_FEE_DTL where description like '%?????á??%'??
select * from pd.pm_asset_item where name like '%?????á??%';
--5912111
select * from cd.co_prod_41 where object_id='1120128152';
select * from pd.pm_asset_item where asset_item_id='1502001';
select * from pd.pm_product_offering where name like '%?????á??%';
--40000585 ????????  90156001???¨·?
select * from pd.PM_PRODUCT_PRICING_PLAN where product_offering_id='90156001';
select * from pd.PM_COMPOSITE_OFFER_PRICE where pricing_plan_id='60000637';
--80003642 80003643
select * from pd.PM_COMPONENT_PRODOFFER_PRICE where price_id in (70004833,70004834);
--?????á??--??·?×???
select * from pd.PM_ALLOWANCE_FREERES_DETAILS where price_id in (70004833,70004834);
--?????á??--???¨·?
select * from pd.PM_RECURRING_FEE_DTL where price_id in (70004833,70004834);
select * from pd.PM_RATES where rate_id in (1269300,1269301);
select * from pd.PM_CURVE_SEGMENTS where curve_id in (1269300,1269301);
--?????á??--????????
select * from pd.pm_billing_discount_dtl where price_id in (70004833,70004834);
--40585002 40585001
select * from pd.pm_adjust_rates where adjustrate_id in (40585002,40585001);
select * from pd.pm_adjust_segment where adjustrate_id in (40585002,40585001);