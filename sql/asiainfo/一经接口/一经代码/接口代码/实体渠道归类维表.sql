CREATE TABLE SHBASS.BASS1_CHANNEL_INFO_BASE_20150415
		 (CHANNEL_ID       	VARCHAR(40)  not null,
		  CHANNEL_TYPE     	VARCHAR(1)   not null,
		  HOUR24_FLAG      	VARCHAR(25),
		  CMCC_ID          	VARCHAR(5)   not null,
		  NC_FLAG          	VARCHAR(1)   not null,
		  agent_id		varchar(18),
		  COUNTY_NAME      	VARCHAR(30)  not null,
		  TOWN_NAME        	VARCHAR(50)  not null,
		  CHANNEL_NAME     	VARCHAR(100) not null,
		  CHANNEL_ADDRESS  	VARCHAR(100) not null,
		  CHANNEL_MANAGE_NAME	VARCHAR(40)  not null,
		  CHANNEL_MANAGE_MOBILE	VARCHAR(40)  not null,
		  CHANNEL_phone 	VARCHAR(40),
		  LOCATION_TYPE    	VARCHAR(1)   not null ,
		  AREA_TYPE        	VARCHAR(1)   not null ,
		  CHANNEL_KIND     	VARCHAR(1)   not null ,
		  NO_OTHER         	VARCHAR(1)   not null ,
		  IS_SELL_MOBILE_FLAG 	VARCHAR(1)   not null ,
		  flag_ddqh             VARCHAR(1)   ,
		  flag_vip              VARCHAR(1)   ,
		  flag_term             VARCHAR(1)   ,
		  flag_kq               VARCHAR(1)  ,
		  CHANNEL_LEVEL    	VARCHAR(1),
		  CHANNEL_STATUS   	VARCHAR(1)   not null ,
		  START_TIME       	VARCHAR(4)   not null,
		  END_TIME         	VARCHAR(4)   not null,
		  VALID_DATE       	VARCHAR(8)   not null,
		  EXPIRE_DATE      	VARCHAR(8)   not null,
		  OP_MONTH         	SMALLINT,
		  LATITUDE         	VARCHAR(10),
		  MAGNITUTE        	VARCHAR(10),
		  DECO_FEE         	BIGINT,
		  DEVICE_FEE       	BIGINT,
		  OFFICE_FEE       	BIGINT,;
		  PENSION          	BIGINT,
		  SUPPLIER_TYPE     VARCHAR(1)      NOT NULL,
		  PURCHASE_MONTH    VARCHAR(6),
		  BUILDING_CERT_NO  VARCHAR(50),
		  LAND_CERT_NO      VARCHAR(50),
		  IC_NO             VARCHAR(50),
		  PRICE             BIGINT,
		  RENT_START_DATE   VARCHAR(8),
		  RENT_END_DATE     VARCHAR(8),
		  AVERAGE_RENT      BIGINT,
		  BUILDING_AREA     INTEGER,
		  USEABLE_AREA      INTEGER,
		  FRONTER_AREA      INTEGER,
		  COUNTER_NUM       SMALLINT,
		  STAFF_NUM         SMALLINT,
		  SEC_NUM           SMALLINT,
		  CLEANER_NUM       SMALLINT,
		  QUERY_FLAG        VARCHAR(1),
		  POS_FLAG          VARCHAR(1),
		  VIP_COUNTER_FLAG  VARCHAR(1),
		  VIP_ROOM_FLAG     VARCHAR(1),
		  PRINTER_NUM       SMALLINT,
		  TERM_NUM          SMALLINT,
		  G3_AREA           INTEGER,
		  TV_NUM            SMALLINT,
		  NEWBUSI_PLAT_NUM  SMALLINT,
		  G3_TERM_NUM       SMALLINT,
		  NET_TERM_NUM      SMALLINT,
		  AREA              INTEGER,
		  SERVICE_AREA      INTEGER,
		  NET_TYPE          VARCHAR(1),
		  AIR_CHARGE_FLAG   VARCHAR(1)
		 )
		  DATA CAPTURE NONE
		 IN TBSN_APP
		 INDEX IN TBSN_APP
		  PARTITIONING KEY
		   (CHANNEL_ID) USING HASHING ;

		-- 1、  社会渠道
		 insert into SHBASS.BASS1_CHANNEL_INFO_BASE_20150415
  (
  	CHANNEL_ID       ,
  	CHANNEL_TYPE     ,
  	CMCC_ID          ,
  	NC_FLAG          ,
  	COUNTY_NAME      ,
  	TOWN_NAME        ,
  	CHANNEL_NAME     ,
  	CHANNEL_ADDRESS  ,
  	CHANNEL_MANAGE_NAME,
  	CHANNEL_MANAGE_MOBILE,
  	LOCATION_TYPE    ,
  	AREA_TYPE        ,
  	CHANNEL_KIND     ,
  	NO_OTHER         ,
  	IS_SELL_MOBILE_FLAG ,
  	CHANNEL_LEVEL    ,
  	CHANNEL_STATUS   ,
  	START_TIME       ,
  	END_TIME         ,
  	VALID_DATE       ,
  	EXPIRE_DATE      ,
  	OP_MONTH         ,
  	LATITUDE         ,
  	MAGNITUTE        ,
  	DECO_FEE         ,
  	DEVICE_FEE       ,
  	OFFICE_FEE       ,
  	PENSION         ,
  	SUPPLIER_TYPE
    ,PURCHASE_MONTH
    ,BUILDING_CERT_NO
    ,LAND_CERT_NO
    ,IC_NO
    ,PRICE
    ,RENT_START_DATE
    ,RENT_END_DATE
    ,AVERAGE_RENT
    --,BUILDING_AREA
    --,USEABLE_AREA
    --,FRONTER_AREA
    --,COUNTER_NUM
    --,STAFF_NUM
    --,SEC_NUM
    --,CLEANER_NUM
    --,QUERY_FLAG
    --,POS_FLAG
    --,VIP_COUNTER_FLAG
    --,VIP_ROOM_FLAG
    --,PRINTER_NUM
    --,TERM_NUM
    --,G3_AREA
    --,TV_NUM
    --,NEWBUSI_PLAT_NUM
    --,G3_TERM_NUM
    --,NET_TERM_NUM
    ,AREA
    ,SERVICE_AREA
    ,NET_TYPE
    --,AIR_CHARGE_FLAG
  )
 select
  	char(N.node_id) as CHANNEL_ID,
  	'3' as CHANNEL_TYPE,
  	'10200' as cmcc_id,
  	 case when NC.nc_flag is null then '0' else NC.nc_flag end   as nc_flag,
        value(S.code_name,'其他') as county_name,
  	case when B.DISTRICT_ID=1  then  '市区'
  	     when B.DISTRICT_ID=2  then  '南郊'
  	     when B.DISTRICT_ID=3  then  '北郊'
  	     when B.DISTRICT_ID=11 then  '东区'
  	     when B.DISTRICT_ID=12 then  '南区'
  	     when B.DISTRICT_ID=13 then  '西区'
  	     when B.DISTRICT_ID=14 then  '北区'
  	     when B.DISTRICT_ID=15 then  '渠道运营中心(市区)'
  	     when B.DISTRICT_ID=21 then  '闵行'
  	     when B.DISTRICT_ID=22 then  '松江'
  	     when B.DISTRICT_ID=23 then  '南汇'
  	     when B.DISTRICT_ID=24 then  '金山'
  	     when B.DISTRICT_ID=25 then  '奉贤'
  	     when B.DISTRICT_ID=26 then  '南郊中心'
  	     when B.DISTRICT_ID=31 then  '宝山'
  	     when B.DISTRICT_ID=32 then  '青浦'
  	     when B.DISTRICT_ID=33 then  '嘉定'
  	     when B.DISTRICT_ID=34 then  '崇明'
  	     when B.DISTRICT_ID=35 then  '北郊中心'
	end as TOWN_NAME,
  	B.channel_entity_name as CHANNEL_NAME,
  	value(N.node_addr,'无') as CHANNEL_ADDRESS,
  	case when R.relation_name is not null then R.relation_name else '未知' end,
  	case when R.relation_mobile is not null then R.relation_mobile else '未知' end,
  	char(N.address_type+1) as LOCATION_TYPE,
  	char(N.area_shape+1) as AREA_TYPE,
    '6'  as CHANNEL_KIND,
  	case
  	     when (N.is_exclusive is null or N.is_exclusive =0) then '1'
  	     when N.is_exclusive =1 then '0'
  	end as NO_OTHER,
    char(is_store) as SELL_MOBILE_FLAG ,
  	case when N.NODE_LEVEL=4 then '1'
  	     when N.NODE_LEVEL=3 then '2'
  	     when N.NODE_LEVEL=99 then '3'
  	     when N.NODE_LEVEL=2 then '4'
  	     when N.NODE_LEVEL=1 then '5'
  	     when N.node_level=6 then '6'
	end as CHANNEL_LEVEL,
  	char(case
           when B.channel_entity_status in (3,11) then 1
           when B.channel_entity_status in (4,13) then 2
           when B.channel_entity_status in (12,5) then 3
        end
        ) as CHANNEL_STATUS,
  	'0830' as START_TIME,
  	'1830' as  business_edtime ,
  	case when N.SIGN_BEGIN_DATE is not null
  	          and N.SIGN_BEGIN_DATE<current date
              and N.SIGN_END_DATE>current date
         then replace(char(N.SIGN_BEGIN_DATE),'-','')
         else '00010101'
    end,
  	case when N.SIGN_END_DATE is not null
  	          and   N.SIGN_BEGIN_DATE<current date
  	          and N.SIGN_END_DATE>current date
  	          then replace(char(N.SIGN_END_DATE),'-','')
  	           else '00010101'
  	end,
  	case when N.SIGN_BEGIN_DATE is not null
  	          and N.SIGN_END_DATE is not null
  	          and N.SIGN_END_DATE>current date
  	          and N.SIGN_BEGIN_DATE<current date
  	     then 12*(year(current date) - year(N.SIGN_BEGIN_DATE))+(month(current date) - month(N.SIGN_BEGIN_DATE))
  	 end,
  	case when decimal(N.LONGITUDE)>=123 or  decimal(N.LONGITUDE)<120 or N.LONGITUDE is null
  	     then char(121.00000)  else left(N.LONGITUDE,9)
  	end,
  	case when decimal(N.LATITUDE)>33  or decimal(N.LATITUDE)<30 or N.LATITUDE is null
  	     then char(31.00000)  else left(N.LATITUDE,9)
  	end,
  	value(value(N.BUILDING_AMOUNT,N.Sum_area*2200),0)	          ,
  	value(N.EQMT_AMOUNT	, case when g.org_class in (1,2,6,7,8,9)
  	                           then 750000
  	                           when g.org_class in (3)
  	                           then 500000
  	                           when g.org_class in (4,5)
  	                           then 250000 else 0
  	                       end)      ,
  	value(N.OFFICES_AMOUNT  , case when g.org_class in (1,2,6,7,8,9)
  	                               then 190000 when g.org_class in (3)
  	                               then 142000 when g.org_class in (4,5)
  	                               then 123000 else 0
  	                           end)         ,
  	0,
  	CHAR(N.property_Nature+1) ,
  	'000101',   --由于新模型无buy_credit字段 且无"上市公司购建" 物业来源类型 ，所以填写固定值
    case when N.property_Nature =0 then char(N.Property_Id) end,
    '',         --由于新模型无"土地证号"字段 且无"上市公司购建" 物业来源类型 ，所以填写固定值
    case when  N.property_Nature =0 then N.Node_License_Id end,
    case when  N.property_Nature =0 then N.Building_Amount+N.Eqmt_Amount+N.Offices_Amount else 0 end,
    value(case when  N.property_Nature in (1,2) then N.RENT_START_DATE else '00010101' end,'00010101'),
    value(case when  N.property_Nature in (1,2) and N.RENT_START_DATE is not null
               then (case when  N.RENT_START_DATE<=N.RENT_END_DATE
                          then  N.RENT_END_DATE
                          else '20991231'
                     end)
               else '00010101' end,'00010101'),
    case when  N.property_Nature in (1,2)
         then case when  N.House_Rent_Amount*12 <= 10000000 then HouseRentAmount*12
                   else 0
                   end
         end
               ,case when  N.Sum_Area is not null  then decimal(N.Sum_Area,15,2) else 0  end shop_area
               ,case when  N.FRONT_USE_AREA is not null  and char(N.FRONT_USE_AREA) <>'#REF!'
                     then decimal(N.FRONT_USE_AREA,15,2) else 0 end service_area
               ,char( F.net_type+1)  INTERNET_WAY
  from
 (
  	select *
  	from {ODS}.ODS_CHANNEL_NODE_NEW_20150415
  	where rec_status=1
  		and NODE_KIND IN (3,4,5,6,8,9,10)
  ) N
 left join
  	(select channel_entity_id
		       ,agent_id
		       ,org_id
		   from {BASS1DWD}.dim_BASS1_channel_org_agent_20150415 ) DIM
  on N.node_id=DIM.channel_entity_id
   join
  (
  	select *
  	   {ODS}.ODS_CHANNEL_AGENT_INFO_20150415
  	where
  		rec_status=1
  		and AGENT_LEVEL in (1)
  ) f
  on DIM.agent_id=F.agent_id
 join
 (
 	select *
 	from {ODS}.ods_channel_entity_basic_info_NEW_20150415
 	where rec_status=1 and channel_entity_type=1
	  and channel_entity_status in (3,4,5)
 ) A
 on A.channel_entity_id=DIM.agent_id
   left join
  	(select * from {DWD}.DIM_PRTY_ORG_INFO
  	  where c.START_DATE <='&TASK_DATE'  AND c.END_DATE >  '&TASK_DATE'
  	   ) g
  on
  	DIM.org_id=g.org_id
  left join
  (select *
  	from {ODS}.ods_channel_entity_basic_info_NEW_20150415
  	where
  		rec_status=1
  		and channel_entity_type=2
  ) B
  on N.node_id=B.channel_entity_id
  left join
       (select * from {ODS}.ODS_channel_sys_base_type_NEW_20150415 where code_type=10023 )h
  on
        B.REGION_ID=char(h.code_id)
  left join
  (
  	select *
 	from
 	(
 		select  rownumber() over(partition by channel_entity_id order by relation_type) as n,
 			a.*
 		from
 			{ODS}.ods_channel_entity_relation_info_20150415 a
 		where
 			relation_type in(1,5,6,8) and rec_status = 1
 	) a
 	where n=1
  ) r
  on
  	N.node_id=r.channel_entity_id
  left join
  	{BASS1DWD}.BASS1_06035_CHANNEL_NC_INFO  NC
  on
  	 char(N.node_id)=NC.channel_id	;


  	 --自营厅 ，委托加盟营业厅
 	insert into SHBASS.BASS1_CHANNEL_INFO_BASE_20150415

 (
 	CHANNEL_ID       ,
 	CHANNEL_TYPE     ,
 	CMCC_ID          ,
 	NC_FLAG          ,
 	COUNTY_NAME      ,
 	TOWN_NAME        ,
 	CHANNEL_NAME     ,
 	CHANNEL_ADDRESS  ,
 	CHANNEL_MANAGE_NAME,
   CHANNEL_MANAGE_MOBILE  ,
   CHANNEL_phone,
 	LOCATION_TYPE    ,
 	AREA_TYPE        ,
 	CHANNEL_KIND     ,
 	NO_OTHER         ,
 	IS_SELL_MOBILE_FLAG ,
 	flag_ddqh,
 	flag_vip,
 	flag_term,
 	flag_kq,
 	CHANNEL_STATUS   ,
 	START_TIME       ,
 	END_TIME         ,
 	VALID_DATE       ,
 	EXPIRE_DATE      ,
 	OP_MONTH         ,
 	LATITUDE         ,
 	MAGNITUTE        ,
 	DECO_FEE         ,
 	DEVICE_FEE       ,
 	OFFICE_FEE       ,
 	PENSION  ,
 	SUPPLIER_TYPE
   ,PURCHASE_MONTH
   ,BUILDING_CERT_NO
   ,LAND_CERT_NO
   ,IC_NO
   ,PRICE
   ,RENT_START_DATE
   ,RENT_END_DATE
   ,AVERAGE_RENT
   ,BUILDING_AREA
   ,USEABLE_AREA
   ,FRONTER_AREA
   ,COUNTER_NUM
   ,STAFF_NUM
   ,SEC_NUM
   ,CLEANER_NUM
   ,QUERY_FLAG
   ,POS_FLAG
   ,VIP_COUNTER_FLAG
   ,VIP_ROOM_FLAG
   ,NEWBUSI_PLAT_NUM
   ,G3_TERM_NUM
   ,NET_TERM_NUM
   --,PRINTER_NUM
   ,TERM_NUM
    -- ,G3_AREA
   ,TV_NUM
   --,NEWBUSI_PLAT_NUM
   --,G3_TERM_NUM
   --,NET_TERM_NUM
   --,AREA
   --,SERVICE_AREA
   --,NET_TYPE
   --,AIR_CHARGE_FLAG
      )

  select
  	char(B.CHANNEL_ENTITY_ID) as CHANNEL_ID,
  	case when N.NODE_KIND=1  then '1'
  	     when N.NODE_KIND=2 then '2'
	end as CHANNEL_TYPE,
  	'10200' as cmcc_id,
  	case when NC.nc_flag is null then '0' else NC.nc_flag end	as nc_flag,
        value(h.code_name,'其他') as county_name,
  	case when B.DISTRICT_ID=1  then  '市区'
  	     when B.DISTRICT_ID=2  then  '南郊'
  	     when B.DISTRICT_ID=3  then  '北郊'
  	     when B.DISTRICT_ID=11 then  '东区'
  	     when B.DISTRICT_ID=12 then  '南区'
  	     when B.DISTRICT_ID=13 then  '西区'
  	     when B.DISTRICT_ID=14 then  '北区'
  	     when B.DISTRICT_ID=15 then  '渠道运营中心(市区)'
  	     when B.DISTRICT_ID=21 then  '闵行'
  	     when B.DISTRICT_ID=22 then  '松江'
  	     when B.DISTRICT_ID=23 then  '南汇'
  	     when B.DISTRICT_ID=24 then  '金山'
  	     when B.DISTRICT_ID=25 then  '奉贤'
  	     when B.DISTRICT_ID=26 then  '南郊中心'
  	     when B.DISTRICT_ID=31 then  '宝山'
  	     when B.DISTRICT_ID=32 then  '青浦'
  	     when B.DISTRICT_ID=33 then  '嘉定'
  	     when B.DISTRICT_ID=34 then  '崇明'
  	     when B.DISTRICT_ID=35 then  '北郊中心'
	end as TOWN_NAME,
  	B.channel_entity_name as CHANNEL_NAME,
  	value(N.node_addr,'无') as CHANNEL_ADDRESS,
  	case when r.relation_name is not null then   r.relation_name else '未知' end,
  	case when r.relation_mobile is not null then r.relation_mobile else '未知' end,
  	case when n.NODE_KIND=1  then '10086' else null end,
  	char(N.address_type+1) as LOCATION_TYPE,
    char(N.area_shape+1) as AREA_TYPE,
  	case when N.node_kind=1 and N.node_grade =1 THEN '3'
  	     ELSE '1' END CHANNEL_KIND,
  	 '1' as NO_OTHER,
  	char(is_store)  SELL_MOBILE_FLAG ,
  	case when N.NODE_KIND=1  then '1' else null end  ,
  	case when N.NODE_KIND=1  then char(E.IS_VIP) else null end,
    case when N.NODE_KIND=1  then '1' else null end,
    case when N.NODE_KIND=1  then '1' else null end,
  	char(case
  		when B.channel_entity_status in (3,11) then 1
  		when B.channel_entity_status in  (4,13) then 2
  		when B.channel_entity_status in (12,5) then 3
  	end) as CHANNEL_STATUS,
  	'0830' as START_TIME,
    '1830' as  business_edtime ,
  	case when  N.NODE_KIND =2 and  N.SIGN_BEGIN_DATE is not null
  	      and  N.SIGN_BEGIN_DATE<current date and  N.SIGN_END_DATE>current date
  	     then replace(char( N.SIGN_BEGIN_DATE),'-','') else '0001-01-01 01:01:01.000000' end,
  	case when  N.NODE_KIND =2 and  N.SIGN_END_DATE is not null
  	      and  N.SIGN_BEGIN_DATE<current date and  N.SIGN_END_DATE>current date
  	      then replace(char( N.SIGN_END_DATE),'-','')  else '0001-01-01 01:01:01.000000' end,
  	case when  N.SIGN_BEGIN_DATE is not null and  N.SIGN_END_DATE is not null
  	      and  N.SIGN_END_DATE>current date and  N.SIGN_BEGIN_DATE<current date
  	    	then 12*(year(current date) - year( N.SIGN_BEGIN_DATE))+(month(current date) - month( N.SIGN_BEGIN_DATE)) end
  	    	 as OP_MONTH,
  	case when decimal(N.LONGITUDE)>=123 or  decimal(N.LONGITUDE)<120 or N.LONGITUDE is null then char(121.00000)  else left(N.LONGITUDE,9)   end,
  	case when decimal(N.LATITUDE)>33  or decimal(N.LATITUDE)<30 or N.LATITUDE is null then char(31.00000)  else left(N.LATITUDE,9)  end,
  	value(value(N.BUILDING_AMOUNT,N.Sum_area*2200),0)	          ,
  	value(N.EQMT_AMOUNT	, case when g.org_class in (1,2,6,7,8,9) then 750000 when g.org_class in (3) then 500000 when g.org_class in (4,5) then 250000 else 0 end)      ,
  	value(N.OFFICES_AMOUNT  , case when g.org_class in (1,2,6,7,8,9) then 190000 when g.org_class in (3) then 142000 when g.org_class in (4,5) then 123000 else 0 end)         ,
  	0,
  	CHAR(N.property_Nature+1) ,
  	'000101',
    case when N.property_Nature =0 then char(N.Property_Id) end,
    '',
    case when  N.property_Nature =0 then N.Node_License_Id end,
    case when  N.property_Nature =0 then N.Building_Amount+N.Eqmt_Amount+N.Offices_Amount else 0 end,
    value(case when  N.property_Nature in (1,2) then N.RENT_START_DATE else '0001-01-01 01:01:01.000000' end,'0001-01-01 01:01:01.000000'),
    value(case when  N.property_Nature in (1,2) and N.RENT_START_DATE is not null
               then (case when  N.RENT_START_DATE<=N.RENT_END_DATE
                          then  N.RENT_END_DATE
                          else '0001-01-01 01:01:01.000000'
                     end)
               else '0001-01-01 01:01:01.000000' end,'0001-01-01 01:01:01.000000'),
    case when  N.property_Nature in (1,2)
         then case when  N.House_Rent_Amount*12 <= 10000000 then House_Rent_Amount*12
                   else 0
                   end
         end  ,

    case when  N.Sum_Area is not null then decimal(N.Sum_Area,15,2)   end  building_area
    ,case when  N.USE_AREA is not null and char(N.USE_AREA) <>'#REF!' then decimal(N.USE_AREA,15,2)    end  USE_AREA
    ,N.FRONT_USE_AREA
    ,E.SEAT_NUM
    ,E.staff_num
    ,E.EMP_SAFE_NUMS
    ,E.EMP_CLEAR_NUMS
    ,''
    ,''
    ,CHAR(E.IS_VIP) VIP_COUNTER_FLAG
    ,CHAR(E.IS_VIP) VIP_ROOM_FLAG
    ,0
    ,0
  from
  (
  	select *
  	from {ODS}.ods_channel_entity_basic_info_NEW_20150415
  	where
  		rec_status=1
  		and channel_entity_type=2
  ) B
  join
  (
  	select *
  	from {ODS}.ods_channel_node_NEW_20150415
  	where
  		rec_status=1
  		and NODE_KIND IN (1,2)
  ) n
  on
  	B.channel_entity_id=N.node_id
  join
  (
  	select *
  	from {ODS}.ods_channel_node_extinfo_NEW_20150415
  	where
  		rec_status=1
  ) E
  	on B.channel_entity_id=E.node_id
  left join
  	(select channel_entity_id
  	       ,agent_id
		       ,org_id
		  from {BASS1DWD}.dim_BASS1_channel_org_agent_20150415
		  ) DIM
  on
  	B.channel_entity_id=DIM.channel_entity_id
  left join
  (
  	select *
  	from {ODS}.ODS_CHANNEL_AGENT_INFO_NEW_20150415
  	where
  		rec_status=1
  ) f
  on
  	DIM.agent_id=f.agent_id
  left join
  	(select * from {DWD}.DIM_PRTY_ORG_INFO
  	  where START_DATE <='&TASK_DATE'  AND END_DATE >  '&TASK_DATE'
  	   ) g
  on
  	DIM.org_id=g.org_id
  left join
       (select * from {ODS}.ODS_channel_sys_base_type_NEW_20150415 where code_type=10023 )h
  on
         B.REGION_ID=char(h.code_id)
  left join
  (
  	select *
 	from
 	(
 		select  rownumber() over(partition by channel_entity_id order by relation_type) as n,
 			a.*
 		from
 			{ODS}.ods_channel_entity_relation_info_20150415 a
 		where
 			relation_type in(1,5,6,8) and rec_status = 1
 	) a
 	where n=1
  ) r
  on
  	B.channel_entity_id=r.channel_entity_id
  left join
  	{BASS1DWD}.BASS1_06035_CHANNEL_NC_INFO nc
  on
  	char(B.channel_entity_id)=nc.channel_id	;

---实体渠道必须在全网渠道编码06043里面
select g.channel_id,substr(b.code_id,10,1) from
(
select bigint("CHANNEL_ENTITY_ID") as channel_id
  from "SHBASS"."DIM_BASS1_CHANNEL_ORG_AGENT_20150511"
except
select bigint("CHANNEL_ENTITY_ID")
  from "SHBASS"."DIM_BASS1_CHANNEL_ORG_AGENT_20150511_75"
) g left join shods.ODS_HM_CODE_ORG_REL_20150526 b on g.channel_id=b.org_id and b.status=1
where substr(b.code_id,10,1) <>1
