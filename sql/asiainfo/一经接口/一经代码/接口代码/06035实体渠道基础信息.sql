insert into {BASS1DWD}.BASS1_CHANNEL_INFO_BASE_&TASK_ID
  (CHANNEL_ID,
   CHANNEL_TYPE,
   CMCC_ID,
   NC_FLAG,
   COUNTY_NAME,
   TOWN_NAME,
   CHANNEL_NAME,
   CHANNEL_ADDRESS,
   CHANNEL_MANAGE_NAME,
   CHANNEL_MANAGE_MOBILE,
   CHANNEL_phone,
   LOCATION_TYPE,
   AREA_TYPE,
   CHANNEL_KIND,
   NO_OTHER,
   IS_SELL_MOBILE_FLAG,
   flag_ddqh,
   flag_vip,
   flag_term,
   flag_kq,
   CHANNEL_STATUS,
   START_TIME,
   END_TIME,
   VALID_DATE,
   EXPIRE_DATE,
   OP_MONTH,
   LATITUDE,
   MAGNITUTE,
   DECO_FEE,
   DEVICE_FEE,
   OFFICE_FEE,
   PENSION,
   SUPPLIER_TYPE,
   PURCHASE_MONTH,
   BUILDING_CERT_NO
   -- ,LAND_CERT_NO
  ,
   IC_NO,
   PRICE,
   RENT_START_DATE,
   RENT_END_DATE,
   AVERAGE_RENT,
   BUILDING_AREA,
   USEABLE_AREA,
   FRONTER_AREA,
   COUNTER_NUM,
   STAFF_NUM,
   SEC_NUM,
   CLEANER_NUM,
   QUERY_FLAG,
   POS_FLAG,
   VIP_COUNTER_FLAG,
   VIP_ROOM_FLAG
   --,NEWBUSI_PLAT_NUM
   --,G3_TERM_NUM
   --,NET_TERM_NUM
   --,PRINTER_NUM
  ,
   TERM_NUM
   -- ,G3_AREA
  ,
   TV_NUM
   --,NEWBUSI_PLAT_NUM
   --,G3_TERM_NUM
   --,NET_TERM_NUM
   --,AREA
   --,SERVICE_AREA
   --,NET_TYPE
   --,AIR_CHARGE_FLAG
   )
  select B.CHANNEL_ENTITY_ID as CHANNEL_ID,
         case
           when N.NODE_KIND = 1 then
            '1'
           when N.NODE_KIND = 2 then
            '2'
         end as CHANNEL_TYPE,
         '10200' as cmcc_id,
         case
           when NC.nc_flag is null then
            '0'
           else
            NC.nc_flag
         end as nc_flag,
         value(h.code_name, '其他') as county_name,
         case
           when B.DISTRICT_ID = 1 then
            '市区'
           when B.DISTRICT_ID = 2 then
            '南郊'
           when B.DISTRICT_ID = 3 then
            '北郊'
           when B.DISTRICT_ID = 11 then
            '东区'
           when B.DISTRICT_ID = 12 then
            '南区'
           when B.DISTRICT_ID = 13 then
            '西区'
           when B.DISTRICT_ID = 14 then
            '北区'
           when B.DISTRICT_ID = 15 then
            '渠道运营中心(市区)'
           when B.DISTRICT_ID = 21 then
            '闵行'
           when B.DISTRICT_ID = 22 then
            '松江'
           when B.DISTRICT_ID = 23 then
            '南汇'
           when B.DISTRICT_ID = 24 then
            '金山'
           when B.DISTRICT_ID = 25 then
            '奉贤'
           when B.DISTRICT_ID = 26 then
            '南郊中心'
           when B.DISTRICT_ID = 31 then
            '宝山'
           when B.DISTRICT_ID = 32 then
            '青浦'
           when B.DISTRICT_ID = 33 then
            '嘉定'
           when B.DISTRICT_ID = 34 then
            '崇明'
           when B.DISTRICT_ID = 35 then
            '北郊中心'
         end as TOWN_NAME,
         B.channel_entity_name as CHANNEL_NAME,
         value(N.node_addr, '无') as CHANNEL_ADDRESS,
         case
           when r.relation_name is not null then
            r.relation_name
           else
            '未知'
         end as CHANNEL_MANAGE_NAME,
         case
           when r.relation_mobile is not null then
            r.relation_mobile
           else
            '未知'
         end as CHANNEL_MANAGE_MOBILE,
         case
           when n.NODE_KIND = 1 then
            '10086'
           else
            null
         end as CHANNEL_phone,
         char(N.address_type + 1) as LOCATION_TYPE,
         char(N.area_shape + 1) as AREA_TYPE,
         case
           when N.node_kind = 1 and N.node_grade = 1 THEN
            '3'
           ELSE
            '1'
         END CHANNEL_KIND,
         '1' as NO_OTHER,
         char(is_store) IS_SELL_MOBILE_FLAG,
         case
           when N.NODE_KIND = 1 then
            '1'
           else
            null
         end as flag_ddqh,
         ----@待增加字段后使用 char(E.has_offer_get_goods) else null end ,
         case
           when N.NODE_KIND = 1 then
            char(E.IS_VIP)
           else
            null
         end as flag_vip,
         case
           when N.NODE_KIND = 1 then
            '1'
           else
            null
         end as flag_term,
         null as flag_kq,
         char(case
                when B.channel_entity_status in (3, 11) then
                 1
                when B.channel_entity_status in (4, 13) then
                 2
                when B.channel_entity_status in (12, 5) then
                 3
              end) as CHANNEL_STATUS,
         SUBSTR(busi_time, LOCATE('-', busi_time) - 4, 4) as START_TIME,
         SUBSTR(busi_time, LOCATE('-', busi_time) + 1, 4) as END_TIME,
         case
           when N.NODE_KIND = 2 and N.SIGN_BEGIN_DATE is not null and
                N.SIGN_BEGIN_DATE < current
            date and N.SIGN_END_DATE > current date then
            replace(char(SUBSTR(N.SIGN_END_DATE, 1, 10)), '-', '')
           else
            '00010101'
         end as VALID_DATE,
         case
           when N.NODE_KIND = 2 and N.SIGN_END_DATE is not null and
                N.SIGN_BEGIN_DATE < current
            date and N.SIGN_END_DATE > current date then
            replace(char(SUBSTR(N.SIGN_END_DATE, 1, 10)), '-', '')
           else
            '00010101'
         end as EXPIRE_DATE,
         case
           when N.SIGN_BEGIN_DATE is not null and
                N.SIGN_END_DATE is not null and N.SIGN_END_DATE > current
            date and N.SIGN_BEGIN_DATE < current date then
            12 * (year(current date) - year(N.SIGN_BEGIN_DATE)) +
            (month(current date) - month(N.SIGN_BEGIN_DATE))
         end as OP_MONTH,
         case
           when decimal(N.LONGITUDE) >= 123 or decimal(N.LONGITUDE) < 120 or
                N.LONGITUDE is null then
            char(121.00000)
           else
            left(N.LONGITUDE, 9)
         end as LATITUDE,
         case
           when decimal(N.LATITUDE) > 33 or decimal(N.LATITUDE) < 30 or
                N.LATITUDE is null then
            char(31.00000)
           else
            left(N.LATITUDE, 9)
         end as MAGNITUTE,
         value(value(N.BUILDING_AMOUNT, N.Sum_area * 2200), 0) as DECO_FEE,
         value(N.EQMT_AMOUNT,
               case
                 when g.org_class in (1, 2, 6, 7, 8, 9) then
                  750000
                 when g.org_class in (3) then
                  500000
                 when g.org_class in (4, 5) then
                  250000
                 else
                  0
               end) as DEVICE_FEE ,
         value(N.OFFICES_AMOUNT,
               case
                 when g.org_class in (1, 2, 6, 7, 8, 9) then
                  190000
                 when g.org_class in (3) then
                  142000
                 when g.org_class in (4, 5) then
                  123000
                 else
                  0
               end) as OFFICE_FEE ,
         0 as PENSION,
         CHAR(N.property_Nature + 1) as SUPPLIER_TYPE,
         '000101' as PURCHASE_MONTH, --由于新模型无buy_credit字段 且无"上市公司购建" 物业来源类型 ，所以填写固定值
         case
           when N.property_Nature = 0 then
            char(N.Property_Id)
         end as BUILDING_CERT_NO,
         -- '',         --由于新模型无"土地证号"字段 且无"上市公司购建" 物业来源类型 ，所以填写固定值
         case
           when N.property_Nature = 0 then
            N.Node_License_Id
         end as IC_NO ,
         case
           when N.property_Nature = 0 then
            value((N.Building_Amount + N.Eqmt_Amount + N.Offices_Amount), 0)
         end as PRICE,
         value(case
                 when N.property_Nature in (1, 2) then
                  replace(char(date(n.RENT_START_DATE)), '-', '')
                 else
                  '00010101'
               end,
               '00010101') as RENT_START_DATE,
         value(case
                 when N.property_Nature in (1, 2) and
                      N.RENT_START_DATE is not null then
                  (case
                    when N.RENT_START_DATE <= N.RENT_END_DATE then
                     replace(char(date(N.RENT_END_DATE)), '-', '')
                    else
                     '20991231'
                  end)
                 else
                  '00010101'
               end,
               '00010101') as RENT_END_DATE,
         case
           when N.property_Nature in (1, 2) then
            case
              when N.House_Rent_Amount * 12 <= 10000000 then
               House_Rent_Amount * 12
              else
               0
            end
         end as AVERAGE_RENT,
         case
           when N.Sum_Area is not null then
            decimal(N.Sum_Area, 15, 2)
         end as building_area,
         case
           when N.USE_AREA is not null and char(N.USE_AREA) <> '#REF!' then
            decimal(N.USE_AREA, 15, 2)
         end as USEABLE_AREA,
         N.FRONT_USE_AREA as FRONTER_AREA,
         E.SEAT_NUM as COUNTER_NUM ,
         E.staff_num as STAFF_NUM,
         E.EMP_SAFE_NUMS as SEC_NUM,
         E.EMP_CLEAR_NUMS as CLEANER_NUM,
         '' as QUERY_FLAG ----@待增加字段后使用 CHAR(E.has_queue_machine)   QUERY_FLAG
        ,
         '' as POS_FLAG --@待增加字段后使用  CHAR(E.has_pos_machine  ) POS_FLAG
        ,
         CHAR(E.IS_VIP) as VIP_COUNTER_FLAG,
         CHAR(E.IS_VIP) as VIP_ROOM_FLAG,
         0 as TERM_NUM ----@待增加字段后使用 self_help_amount TEAM_NUM
        ,
         0 as TV_NUM ----@待增加字段后使用 tv_screen_amount TV_NUM
    from (select *
            from {ODS}.ods_channel_entity_basic_info_NEW_&TASK_ID
           where rec_status = 1
             and channel_entity_type = 2) B
    join (select n.*,
                 case
                   when business_Time is not null and
                        substr(business_Time, 1, 1) = '0' then
                    replace(replace(replace(replace(business_time, '－', '-'),
                                            '：',
                                            ':'),
                                    ':',
                                    ''),
                            ' ',
                            '')
                   else
                    '0900-1800'
                 end busi_time
            from {ODS}.ods_channel_node_NEW_&TASK_ID n
           where rec_status = 1
             and NODE_KIND IN (1, 2)) N
      on B.channel_entity_id = N.node_id
    join (select *
            from {ODS}.ods_channel_node_extinfo_NEW_&TASK_ID
           where rec_status = 1) E
      on B.channel_entity_id = E.node_id
    left join (select channel_entity_id, agent_id, org_id
                 from {BASS1DWD}.dim_BASS1_channel_org_agent_&TASK_ID) DIM
      on B.channel_entity_id = DIM.channel_entity_id
    left join (select *
                 from {ODS}.ods_CHANNEL_AGENT_INFO_NEW_&TASK_ID
                where rec_status = 1) f
      on DIM.agent_id = f.agent_id
    left join (select *
                 from shdw.DIM_PRTY_ORG_INFO
                where START_DATE <= '&TASK_DATE'
                  AND END_DATE > '&TASK_DATE') g
      on DIM.org_id = g.org_id
    left join (select *
                 from {ODS}.ods_channel_sys_base_type_NEW_&TASK_ID
                where code_type = 10023) h
      on B.REGION_ID = char(h.code_id)
    left join (select *
                 from (select rownumber() over(partition by channel_entity_id order by relation_type) as n,
                              a.*
                         from {ODS}.ods_channel_entity_relation_info_&TASK_ID a
                        where relation_type in (1, 5, 6, 8)
                          and rec_status = 1) a
                where n = 1) r
      on B.channel_entity_id = r.channel_entity_id
    left join {BASS1DWD}.BASS1_06035_CHANNEL_NC_INFO nc
      on char(B.channel_entity_id) = nc.channel_id
