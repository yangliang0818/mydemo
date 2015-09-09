update SHFIN.RPT_RESOURCE_TAB_DEF b set b.expire_date =value((
select distinct '2014-12-31' from
 ( select a.id,a.valid_date from
( select a.*,rownumber() over(partition by id order by valid_date desc ) seq
 from SHFIN.RPT_RESOURCE_TAB_DEF a )   a
 where seq>1 ) a where a.id=b.id and a.valid_date=b.valid_date),b.expire_date)

select a.procname,a.tabname,b.procname,a.type from(select distinct * from inoutputrel where procname='Bass02004UseUpD')a
left join(select distinct tabname,procname from inoutputrel where type='OUTPUT')b on a.tabname=b.tabnameorder by type desc

