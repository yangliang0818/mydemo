--51环境DB2调试通过版本
WITH T1(PRODUCT_OFFERING_ID,PRICING_PLAN_ID) AS
(SELECT DISTINCT PRODUCT_OFFERING_ID,PRICING_PLAN_ID FROM SHODS.ODS_PM_PRODUCT_PRICING_PLAN_20140817),
T2(PRICING_PLAN_ID,PRICE_ID,BILLING_TYPE,TAX_INCLUDED) AS
(SELECT C.PRICING_PLAN_ID,C.PRICE_ID,C.BILLING_TYPE,D.TAX_INCLUDED FROM SHODS.ODS_PM_COMPOSITE_OFFER_PRICE_20140817 C
,SHODS.ODS_PM_COMPONENT_PRODOFFER_PRICE_20140817 D WHERE C.PRICE_ID=D.PRICE_ID AND D.PRICE_TYPE=8)
SELECT DISTINCT G.PROD_ID,F.BASE_ITEM,F.PROM_TYPE,F.NUMERATOR,F.DENOMINATOR,F.START_VAL,F.END_VAL,T2.BILLING_TYPE,F.*
FROM SHODS.ODS_PM_PRODUCT_OFFERING_20140817 A JOIN T1
ON A.PRODUCT_OFFERING_ID=T1.PRODUCT_OFFERING_ID
JOIN T2
ON T1.PRICING_PLAN_ID=T2.PRICING_PLAN_ID
JOIN SHODS.ODS_PM_BILLING_DISCOUNT_DTL_20140817 E
ON T2.PRICE_ID=E.PRICE_ID
JOIN SHODS.ODS_PM_ADJUST_SEGMENT_20140817 F
ON E.ADJUSTRATE_ID=F.ADJUSTRATE_ID
JOIN SHDW.DIM_ACC_BOSSPROD_CRMPROD_REL G
ON A.PRODUCT_OFFERING_ID=G.BOSS_PROD_ID WITH UR;

--账务ORACLE版本
select distinct a.product_offering_id,
       a.name,
       a.billing_priority, ---表示帐务扣费优先级，冲销里面要用到的
       b.pricing_plan_id,
       d.price_id,
       d.billing_type,
       decode(h.ref_type,  --参考优惠费用的意思是对优惠后的费用优惠
              1,
              '参考原始费用',
              2,
              '参考优惠后的费用',
              3,
              '参考优惠后且包含预存的费用',
              4,
              '计费标准批价的费用',
              5,
              '增量优惠费用') as ref_type,
       h.base_item,   --参考科目  1原始科目 2优惠 4调整 5公免
       l.name,
       h.adjust_item, --算出的科目优惠到哪里 体账单科目 2或者5
       m.name,
       h.fill_item,   --adjust_item 为0时候才会陪fill_item 配置和base_item一样
                      --不为0 只配adjust_item
       decode(h.adjust_type,
             1,'当前账期优惠',
             2,'下账期优惠') as adjust_type,
       h.priority,
       h.start_val,
       h.end_val,
       h.numerator,
       h.denominator,
       h.item_share_flag,
       decode(h.prom_type,
              1,
              '打折（比例）',
              2,
              '指定（固定）',
              3,
              '封顶',
              4,
              '减免',
              5,
              '保底',
              6,
              '包打',
              7,
              '赠送优惠') as "优惠类型"
  from pd.pm_product_offering          a,
       pd.pm_product_pricing_plan      b,
       pd.pm_pricing_plan              c,
       pd.pm_composite_offer_price     d,
       pd.pm_component_prodoffer_price e,
       pd.pm_billing_discount_dtl      f,
       pd.pm_adjust_rates              g,
       pd.pm_adjust_segment            h,
       sd.sys_policy                   i, ---和帐务优惠生效条件对应
       sd.sys_policy                   j,
       sd.sys_measure                  k,
       pd.pm_price_event               l,
       pd.pm_price_event               m
 where a.product_offering_id = b.product_offering_id
   and b.pricing_plan_id = c.pricing_plan_id
   and c.pricing_plan_id = d.pricing_plan_id
   and d.price_id = e.price_id
   and e.price_type = 8---当定价类型为8时表示帐务优惠产品
   and e.price_id = f.price_id
   and f.adjustrate_id = g.adjustrate_id
   and g.adjustrate_id = h.adjustrate_id
   and k.measure_id = f.measure_id
   and h.expr_id = i.policy_id
   and h.formula_id = j.policy_id
   and h.base_item=l.item_id
   and h.adjust_item=m.item_id(+)
   and a.product_offering_id IN (40005750,40005768,40005761);

SELECT DISTINCT I.PROD_ID,F.ITEM_CODE,H.BASE_VAL*1.00/100,E.BILLING_TYPE,E.TAX_INCLUDED FROM SHODS.ODS_PM_PRODUCT_OFFERING_20140515 A
JOIN (SELECT DISTINCT PRODUCT_OFFERING_ID,PRICING_PLAN_ID FROM SHODS.ODS_PM_PRODUCT_PRICING_PLAN_20140515 ) B ON A.PRODUCT_OFFERING_ID=B.PRODUCT_OFFERING_ID
JOIN (SELECT C.PRICING_PLAN_ID,C.PRICE_ID,C.BILLING_TYPE,D.TAX_INCLUDED FROM SHODS.ODS_PM_COMPOSITE_OFFER_PRICE_20140515 C,SHODS.ODS_PM_COMPONENT_PRODOFFER_PRICE_20140515 D
WHERE C.PRICE_ID=D.PRICE_ID AND D.PRICE_TYPE=7)E
ON B.PRICING_PLAN_ID=E.PRICING_PLAN_ID
JOIN SHODS.ODS_PM_RECURRING_FEE_DTL_20140515 F
ON E.PRICE_ID=F.PRICE_ID
JOIN SHODS.ODS_PM_RATES_20140515 G
ON F.RATE_ID=G.RATE_ID
JOIN SHODS.ODS_PM_CURVE_SEGMENTS_20140515 H
ON G.CURVE_ID=H.CURVE_ID
JOIN SHDW.DIM_ACC_BOSSPROD_CRMPROD_REL I
ON A.PRODUCT_OFFERING_ID=I.BOSS_PROD_ID with ur;








