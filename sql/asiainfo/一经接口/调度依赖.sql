select a.procname,a.tabname,value(b.procname,c.i),a.type from
(
select distinct * from inoutputrel where procname='Bass02004UseUpD'
)a left join
(
select distinct tabname,procname from inoutputrel where type='OUTPUT'
)b on a.tabname=b.tabname
left join ei c on a.tabname=c.t
order by type desc
