select a.product_offering_id,
       a.name,
       a.billing_priority, ---表示帐务扣费优先级，冲销里面要用到的
       b.policy_id,
       b.pricing_plan_id,
       d.price_id,
       d.billing_type,
       e.price_type,

       --f.item_code, ---这个字段以后会去掉
       f.calc_serial,
       f.use_type , ---日月帐
      g.adjustrate_id,
       g.calc_type,
       h.expr_id as "优惠生效条件",
       i.policy_expr,
       i.name as iname,
       decode(h.ref_type,
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
       h.valid_cycle,
       h.expire_cycle,
       h.base_item,
       l.name,
       h.adjust_item,
       m.name,
       h.fill_item,
       decode(h.adjust_type,
             1,'当前账期优惠',
             2,'下账期优惠') as adjust_type,
       h.priority,
       h.start_val,
       h.end_val,
       h.numerator,
       h.denominator,
       h.maximum,
       h.reward_id,
       h.precision_round,
    /*   h.account_share_flag, ---账户级分摊标识*/
     /*  h.item_share_flag,   ---科目级分摊标识*/
       h.disc_type,
       h.para_use_rule,
       h.formula_id,
       h.item_share_flag,
       j.policy_expr,
       j.name as jname,
       h.donate_use_rule,
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
              '赠送优惠') as "优惠类型",
       h.ref_role,
       h.result_role/*, ---优惠分摊角色
       k.measure_id, ---优惠的货币属性
       k.measure_type_id, ---优惠的货币类型，如RMB、dollar，Baht
       k.measure_level*/
  from pd.pm_product_offering          a,
       pd.pm_product_pricing_plan      b,
        pd.pm_pricing_plan             c,
       pd.pm_composite_offer_price     d,
       pd.pm_component_prodoffer_price e,
       pd.pm_billing_discount_dtl      f,
       pd.pm_adjust_rates              g,
       pd.pm_adjust_segment            h,
       sd.sys_policy                   i, ---和帐务优惠生效条件对应
       sd.sys_policy                   j,
       sd.sys_measure                 k,
       pd.pm_price_event              l,
       pd.pm_price_event              m
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
