select a.PRODUCT_OFFERING_ID PROD_ID,
       a.NAME PROD_NAME,
       a.BILLING_PRIORITY,  --固费优先级
       b.POLICY_ID,
       b.PRICING_PLAN_ID,
       n.pricing_plan_name, --定价计划名
       c.PRICE_ID,
       c.BILLING_TYPE,      --付费类型（-1：ALL, 适合所有付费类型 0：预付 1：后付）
       d.PRICE_TYPE,        --固费price类型为7
       d.TAX_INCLUDED,      --含税标示
       e.ITEM_CODE,
       i.NAME,
       decode(e.ACCOUNT_TYPE, 1, '月帐', 2, '日帐', 3, '日月帐', '未定义'),
       e.EXPR_ID,                     --固费条件表达式
       k.POLICY_EXPR as "资费生效条件",
       k.DESCRIPTION as "资费生效条件描述",
       e.USE_MARKER_ID,               --状态marker
       j.POLICY_EXPR as "use_marker表达式",
       j.DESCRIPTION as "use_marker表达式描述",
       e.PRIORITY, 
       e.RATE_ID,
       e.cal_indi,
       f.CURVE_ID,
       h.FORMULA_ID,                  --固费计算公式
       l.POLICY_EXPR as "资费计算公式",
       l.DESCRIPTION as "资费计算公式描述",
       h.BASE_VAL,
       h.RATE_VAL,
       m.NAME MEASURE_NAME,
       h.share_num
  From pd.PM_PRODUCT_OFFERING          a,
       pd.PM_PRODUCT_PRICING_PLAN      b,
       pd.PM_COMPOSITE_OFFER_PRICE     c,
       pd.PM_COMPONENT_PRODOFFER_PRICE d,
       pd.PM_RECURRING_FEE_DTL         e,
       pd.PM_RATES                     f,
       pd.PM_CURVE                     g,
       pd.PM_CURVE_SEGMENTS            h,
       pd.PM_PRICE_EVENT               i,a
       sd.SYS_POLICY                   j,  --use_marker_id关联
       sd.SYS_POLICY                  k,  --formula_id关联
       sd.SYS_POLICY                   l,  --pm_recurring_fee_dtl.expr_id关联
       sd.sys_measure                  m,
       pd.pm_pricing_plan              n
 where a.PRODUCT_OFFERING_ID = b.PRODUCT_OFFERING_ID
   and b.PRICING_PLAN_ID = c.PRICING_PLAN_ID
   and b.PRICING_PLAN_ID = n.PRICING_PLAN_ID
   and c.PRICE_ID = d.PRICE_ID
   and d.PRICE_TYPE = 7                 --固费price类型为7
   and d.PRICE_ID = e.PRICE_ID
   and e.RATE_ID = f.RATE_ID
   and f.CURVE_ID = g.CURVE_ID
   and g.CURVE_ID = h.CURVE_ID
   and e.ITEM_CODE = i.ITEM_ID
   and e.USE_MARKER_ID = j.POLICY_ID
   and j.USE_TRIGGER = 28
   and  m.MEASURE_ID=10402
   and h.formula_id = l.POLICY_ID
   and l.USE_TRIGGER =22
/*   and i.ITEM_TYPE = 2
   and i.SUB_TYPE = 0*/
   and e.EXPR_ID = k.POLICY_ID
   and k.USE_TRIGGER =26
   and a.PRODUCT_OFFERING_ID in(90363005);


delete from shdw.dim_acc_rc_fee;
insert into shdw.dim_acc_rc_fee
select prod_id,item_code,sum(fee),BILLING_TYPE,TAX,start_date,end_date
from
(
select distinct
I.PROD_ID as prod_id
,f.item_code as item_code
,h.BASE_VAL*1.00/100 as fee
,e.BILLING_TYPE as BILLING_TYPE
,e.TAX_INCLUDED as TAX
,date('1970-01-01') as start_date
,date('2099-12-31') as end_date
from
shods.ODS_PM_PRODUCT_OFFERING_20141007 a
join
(select distinct product_offering_id,pricing_plan_id from shods.ods_pm_product_pricing_plan_20141007 ) b on a.product_offering_id=b.product_offering_id
join
(select c.pricing_plan_id,c.price_id,c.BILLING_TYPE,d.TAX_INCLUDED
from
shods.ods_PM_COMPOSITE_OFFER_PRICE_20141007 c,shods.ods_PM_COMPONENT_PRODOFFER_PRICE_20141007 d
where c.price_id=d.price_id and d.PRICE_TYPE=7)e
on b.pricing_plan_id=e.pricing_plan_id
join shods.ods_PM_RECURRING_FEE_DTL_20141007 f
on e.price_id=f.price_id
join shods.ods_CRM_PM_RATES_20141007 g
on f.rate_id=g.rate_id
join shods.ods_CRM_PM_CURVE_SEGMENTS_20141007 h
on g.curve_id=h.curve_id
JOIN shdw.DIM_ACC_BOSSPROD_CRMPROD_REL I
ON A.PRODUCT_OFFERING_ID=I.BOSS_PROD_ID
)
group by PROD_ID,ITEM_CODE,BILLING_TYPE,TAX,start_date,end_date