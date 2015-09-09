#!/data/rpt/changtaihua_shell/bin/bash

#报表名称:终端补贴情况表
#报表类型:上报集团类报表
#统计周期:每月3日
#梗概:
#内容:


#作者:      刘涛
#创建时间:  2013/05/11
#修改时间:  2014/11/02
#SQL提供者: 张棋阳


#标准区域，切勿修改!!!
ScriptDir=`dirname "$0"`
ScriptName=`basename "$0"`
ScriptDir=`pwd | awk -v value="$ScriptDir" 'BEGIN {if (value==".") value=""; else {if (substr(value,1,2)=="./") value=substr(value,3)}} {if (substr(value,1,1)!="/") print $0"/"value; else print value}'`
OS=`uname -a | awk '{print $1}'`

#配置区域
AwkPath=../awkset                               #存放处理函数脚本
SqlPath=../sqlset                               #存放sql子脚本
PerlPath=../perlset                             #存放perl子脚本
CfgPath=../cfg                                  #配置目录
TmpDir=/tmp/TaskSchedule                        #启动前的临时目录
CleanLogFlag=0                                  #清除日志标志:0-保持,1-删除
BreakFlag=0                                     #断点执行标志:0-不关心,1-只能从上次断点中执行
PreLoadDefaultProfile=0                         #预装载默认配置文件:0-预加载,1-不加载
DefaultProfile=../cfg/report-common.cfg         #缺省预装配置文件
IncludePath=../include                          #外部函数路径
MsgMaxLen=1024                                  #消息文本最大长度

#以下内容，非开发人员切勿修改
ReadIni=$AwkPath/read_ini_file.awk
ConfigFile=$CfgPath/`basename $0 | awk -F. '{print $1".cfg"}'`
TmpEnvFile=$TmpDir/.$$.env

########################################   主程序   ########################################

USAGE="usage: `basename $0` -u <UserName> -p <Password> -i <InstanceName> -o <SchemaName> -f <IniFileName> -l <CleanLogFlag> -t <TableSpace> -d <ExecDate> -n <StepNo> -r <ResultPath> -m <Mode> -s <StatMode>\n\n"

#启动时临时文件目录创建
if [ ! -d "$TmpDir" ]
then
	mkdir -p "$TmpDir"
fi

#检查操作系统自带awk是否支持ENVIRON变量
case $OS in
AIX|Linux)
  #自带awk支持ENVIRON变量
  AwkOS=""
  printf "\n"
  ;;
*)
  #读取环境变量，暂时未支持后续操作
  set | awk '{if ((index($1,"=")>0)&&(substr($0,1,1)!=" ")&&(substr($0,1,1)!="\t")) {a=substr($1,1,index($1,"=")-1); gsub(/[0-9a-zA-Z_]/,"",a); if (a=="") print $0}}' > $TmpDir/.$$.env-ref
  AwkOS=$OS
  printf "\n"
  ;;
esac

#读取传入参数
while getopts u:p:i:o:f:l:t:d:n:r:m:s:H OPTION
do
	case "$OPTION" in
	f) #指定配置文件替代默认配置
		myValue="$OPTARG"
		if [ ! -f "$myValue" ]
		then
			printf "File [%s] is not exists!!!\n\n" "$myValue"
			exit 1
		else
			ConfigFile="$myValue"
		fi
		;;
	i) #数据库连接实例
		myValue="$OPTARG"
		myValue=`echo $myValue | awk '{a=$0; gsub(/[[:alnum:]_]/,"",a); if ((substr($0,1,1) ~ /[a-zA-Z]/)&&(a=="")) print $0; else {print $0; exit 1}}'`
		if [ $? -ne 0 ]
		then
			printf "Invalid user name: %s !!!\n\n" "$myValue"
			exit 1
		else
			_InstanceName=$myValue
		fi
		;;
	u) #数据库连接用户名:用户名必须字母打头，且只包含数字字母和下划线
		myValue="$OPTARG"
		myValue=`echo $myValue | awk '{a=$0; gsub(/[[:alnum:]_]/,"",a); if ((substr($0,1,1) ~ /[a-zA-Z]/)&&(a=="")) print $0; else {print $0; exit 1}}'`
		if [ $? -ne 0 ]
		then
			printf "Invalid user name: %s !!!\n\n" "$myValue"
			exit 1
		else
			_DBName=$myValue
		fi
		;;
	p) #数据库密码:注意如果有特殊字符，可能需要修改代码
		myValue="$OPTARG"
		myValue=`echo $myValue | awk '{a=$0; gsub(" ","",a); if (a!="") print $0; else {print $0; exit 1}}'`
		if [ $? -ne 0 ]
		then
			printf "Invalid password: [%s] !!!\n\n" "$myValue"
			exit 1
		else
			_DBPwd=$myValue
		fi
		;;
	o) #数据库建表的用户名:用户名必须字母打头，且只包含数字字母和下划线
		myValue="$OPTARG"
		myValue=`echo $myValue | awk '{a=$0; gsub(/[[:alnum:]_]/,"",a); if ((substr($0,1,1) ~ /[a-zA-Z]/)&&(a=="")) print $0; else {print $0;exit 1}}'`
		if [ $? -ne 0 ]
		then
			printf "Invalid schema name: %s !!!\n\n" "$myValue"
			exit 1
		else
			_SchemaName=$myValue
		fi
		;;
	l) #数据库日志:
		myValue="$OPTARG"
		myValue=`echo $myValue | awk '{a=$0; gsub(/[[:digit:]]/,"",a); if (a=="") print $0+0; else {print $0; exit 1}}'`
		if [ $? -ne 0 ]
		then
			printf "Invalid mode for cleaning log : %s !!!\n\n" "$myValue"
			exit 1
		fi
		_CleanLogFlag=$myValue
		;;
	t) #指定表空间名:必须字母打头，且只包含数字字母和下划线
		myValue="$OPTARG"
		myValue=`echo $myValue | awk '{a=$0; gsub(/[[:alnum:]_]/,"",a); if ((substr($0,1,1) ~ /[a-zA-Z]/)&&(a=="")) print $0; else exit 1}'`
		if [ $? -ne 0 ]
		then
			printf "Invalid user name: %s !!!\n\n" "$myValue"
			exit 1
		else
			_DBTabspace=$myValue
		fi
		;;
	d) #指定计算的日期:与当前不一致时使用，可以是月或日，形式如2013-05,2013-05-21,201305,20130521，只做简单判断，不做
		myValue="$OPTARG"
		myValue=`echo $myValue | awk '{
																		a=$0; gsub(/[[:alnum:]\-]/,"",a)
																		if ((substr($0,1,1) ~ /[[:alnum:]]/)&&(a==""))
																			{
																				if (index($0,"-")>0)
																					{
																						n=split($0,array,"-")
																						if ((array[1]=="")||(array[2]+0==0)||(array[2]+0>12)||(n==3)&&((array[3]+0>31)||(array[3]+0>30)&&((array[2]+0==4)||(array[2]+0==6)||(array[2]+0==9)||(array[2]+0==11))||(array[3]+0>29)&&(array[2]+0==2)))
																							{
																								print $0
																								exit 1
																							}
																						else
																							{
																							  if (n==3) printf "%d-%02d-%02d\n",array[1],array[2],array[3]
																							  else printf "%d-%02d\n",array[1],array[2]
																							}
																					}
																				else
																					{
																					  thisMonth=substr($0,5,2)+0
																					  thisDay=substr($0,7,2)+0
																					  if ((thisMonth<1)||(thisMonth>12)||(length($0)>6)&&((thisDay>31)||(thisDay>29)&&(thisMonth==2)||(thisDay>30)&&((thisMonth==4)||(thisMonth==6)||(thisMonth==9)||(thisMonth==11))))
																					  	{
																					  		print $0
																					  		exit 1
																					  	}
																					  else
																					  	{
																					  		if (length($0)==6) print substr($0,1,4)"-"(thisMonth<10?"0"thisMonth:thisMonth)
																					  		else print substr($0,1,4)"-"(thisMonth<10?"0"thisMonth:thisMonth)"-"(thisDay<10?"0"thisDay:thisDay)
																					  	}
																					}
																			}
																		else
																			{
																				print $0
																				exit 1
																			}
		                               }'`
		if [ $? -ne 0 ]
		then
			printf "Invalid date: %s !!!\n\n" "$myValue"
			exit 1
		else
			_ExecDate=$myValue
		fi
		;;
	n) #断点执行的序号:可以从状态文件中获取，也可以通过脚本参数指定
		myValue="$OPTARG"
		myValue=`echo $myValue | awk '{a=$0; gsub(/[[:digit:]]/,"",a); if (a=="") print $0+0; else {print $0; exit 1}}'`
		if [ $? -ne 0 ]
		then
			printf "Invalid break number: %s !!!\n\n" "$myValue"
			exit 1
		else
			_BreakNo=$myValue
		fi
		;;
	r) #重新指定结果路径:不创建的原因是防止不是指定的大空间专用分区
		myValue="$OPTARG"
		if [ ! -d "$myValue" ]
		then
			printf "Directory [%s] is not exists!!!\n\n" "$myValue"
			exit 1
		else
			_ResultPath="$myValue"
		fi
		;;
	m) #2014/1/25 增加“年底试报”模式
		myValue="$OPTARG"
		if [ "$myValue" != "newtest" ]
		then
			printf "Only support [%s]!!!\n\n" "$myValue"
			exit 1
		else
			_TestMode="$myValue"
		fi
		;;
	s) #2014/9/30 统计模式，0-正常执行，1-模出（或年底试报），2-执行非当月数据（日表采用当前系统），3-拍照库测试（指时间严格按照指定的时间，尤其是日表）
		myValue="$OPTARG"
		_StatMode=`echo $myValue | awk '{if ($0+0>3) print 0; else print $0+0}'`
		;;
	H)
		printf "$USAGE"
		exit 0
		;;
	\?)
		printf "$USAGE"
		exit 0
		;;
	esac
done

#增加默认用户，暂未启用
_DefaultUser=$USER

#加载时间变量
. $IncludePath/time_variable.profile

#装载外部函数
. $IncludePath/common_func.sh
. $IncludePath/database_forDB2.sh

exportTimeVar "${_StatMode}" "${_ExecDate}"

LANG1=$LANG
MyShellNamePre=`echo $ScriptName | awk '{if (index($0,".")>0) print substr($0,1,index($0,".")-1); else print $0}'`
rm -f "$TmpDir/$MyShellNamePre.log"
#读取缺省配置文件
if [ $PreLoadDefaultProfile = 0 ] && [ -f $DefaultProfile ]
then
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Preload default configure file [%s] ... " " " `basename "$DefaultProfile"`
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s 读取预加载配置文件[%s] ... " " " `basename "$DefaultProfile"` >> "$TmpDir/$MyShellNamePre.log"
	rm -f $TmpEnvFile
	export LANG=c
	awk -f $ReadIni $DefaultProfile > $TmpEnvFile
	export LANG=$LANG1
	cat $TmpEnvFile >> "$TmpDir/$MyShellNamePre.log"
	. $TmpEnvFile
	rm -f $TmpEnvFile
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Preload is finished!\n\n" " "
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s 读取预加载结束!\n\n" " " >> "$TmpDir/$MyShellNamePre.log"
fi

#检查配置文件是否存在，如果不存在，则退出
printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Read configure file [%s] ... " " " `basename "$ConfigFile"`
printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s 读取配置文件[%s] ... " " " `basename "$ConfigFile"` >> "$TmpDir/$MyShellNamePre.log"
rm -f $TmpEnvFile

#如果密码还有分号，那么这里需要修改间隔符
if [ -f $ConfigFile ]
then
	export LANG=c
	awk -v ReadOnlyList=";SchemaUser;${_SchemaName};DB2_User;${_DBName};DB2_Password;${_DBPwd};DB2_Instance;${_InstanceName};TableSpace;${_DBTabspace}" -f $ReadIni $ConfigFile > $TmpEnvFile
	export LANG=$LANG1
	cat $TmpEnvFile >> "$TmpDir/$MyShellNamePre.log"
	. $TmpEnvFile
	rm -f $TmpEnvFile
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Reading is finished!\n\n" " "
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s 读取结束!\n\n" " " >> "$TmpDir/$MyShellNamePre.log"
else
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Reading Skipped!\n\n" " "
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s 未配置[%s]，跳过读取!!!\n\n" " " `basename "$ConfigFile"` >> "$TmpDir/$MyShellNamePre.log"
fi

#设置日志文件和状态文件
LogFile="$LogPath/$MyShellNamePre.log"
StatusFile="$StatPath/$MyShellNamePre.status"

#创建日志目录
if [ ! -d "$LogPath" ]
then
	mkdir -p "$LogPath"
fi
#创建状态目录
if [ ! -d "$StatPath" ]
then
	mkdir -p "$StatPath"
fi
#创建过程目录
if [ ! -d "$ProcPath" ]
then
	mkdir -p "$ProcPath"
fi
#创建临时文件夹
if [ ! -d "$TmpPath" ]
then
	mkdir -p "$TmpPath"
fi


#特殊处理日志文件
if [ "$_CleanLogFlag" != "" ]
then
	CleanLogFlag=`echo "$_CleanLogFlag" | awk -v value="$CleanLogFlag" '{if ($0<2) print $0; else print value+0}'`
fi
if [ $CleanLogFlag -eq 1 ]
then
	rm -f "$LogFile"-`date +%Y%m%d`
fi
cat "$TmpDir/$MyShellNamePre.log" >> "$LogFile"-`date +%Y%m%d`
rm -f "$TmpDir/$MyShellNamePre.log"

#检查状态文件:断点支持，本模块实际用不到
if [ -f $StatusFile ]
then
	rm -f $TmpPath/.$$.status
	if [ -f $TmpPath/.$$.status ]
	then
		printf "\n\nWrite temp status file failed, exit!!!\n\n" " "
		exit 1
	fi
	grep -E "(^Last_Status=|^Last_Time=|^Last_Step_no=)" $StatusFile > $TmpPath/.$$.status
	. $TmpPath/.$$.status
	rm -f $TmpPath/.$$.status
fi

##################################此部分代码可以根据实际需要编写##################################

#进程启动
WriteStatusFile 2 0 $$ $StatusFile

#数据库连接
WriteStatusFile 1 1 $$ $StatusFile
if ! DB2_Connect $DB2_User $DB2_Password $DB2_Instance "$LogFile"-`date +%Y%m%d`
then
  exit 1
fi

#总体检查表
WriteStatusFile 1 2 $$ $StatusFile
if ! DB2_Check 0 3 0 0 "${TDim_Svc_Off_Ploy},${TDim_Group_Fee_Lev}" "" "" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Check 0 3 2 3 "${TDim_Prty_Org_Info}" "" "$miExecMonthF-01 00:00:00" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Check 0 3 3 3 "${TDwd_Svc_Usr_All_Info_}$PreMonthF,${TOds_Res_Oper_Order_Terminal_}$PreMonthF,${TDwd_Svc_Off_Term_Bind_Inst_}$PreMonthF,$Rpt_Imei_Res_Spec,$Rpt_Dim_Termi,$Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF,${TOds_Ins_User_}$PreMonthF,${TOds_Insx_Grp_Trmnl_Rec_}$PreMonthF" "" "$miExecMonthF-01 00:00:00" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Check 0 3 3 3 "${TOds_Up_Product_Item_}$sysPreDayF,${TOds_Res_Price_}$sysPreDayF,${TOds_Ca_Pa_Promo_Def_}$sysPreDayF,${TOds_Res_Terminal_Origin_}$sysPreDayF" "" "$miExecDayF 00:00:00" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi

#2014/2/3 增加用户IMEI锁定，防止终端捆绑出现同一个用户、同一个IMEI多次记录情况
WriteStatusFile 1 3 $$ $StatusFile
if ! DB2_Check 0 1 0 "" $Rpt_Zdmm326_Termi_User_Imei_Dtl "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Zdmm326_Termi_User_Imei_Dtl(
	              SUB_ID         VARCHAR(21),
	              IMEI           VARCHAR(64),
	              APPLY_MONTH    VARCHAR(10),
	              CREATE_DATE    DATE, -- 2014/10/10 增加锁表字段:受理时间、策划编号
	              OFFER_ID       BIGINT
	              ) in $TableSpace partitioning key(sub_id,apply_month) not logged initially" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
#清洗24个月之前的和当月帐期的
if ! DB2_Cmd "delete from $Rpt_Zdmm326_Termi_User_Imei_Dtl where apply_month='$PreMonthF' or apply_month<=replace(substr(date('$miPreMonthF-01') - 24 months,1,7),'-','')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#2014/10/10 删除已经失效的
if ! DB2_Cmd "insert into $Rpt_Zdmm326_Termi_User_Imei_Dtl
                      select a.sub_id, a.imei,a.apply_month || 'A', a.create_date, a.offer_id
                        from $Rpt_Zdmm326_Termi_User_Imei_Dtl a
                        left join (select b.user_id, nvl(b.imei, d.imei) as Imei
                                    from ${TDwd_Svc_Off_Term_Bind_Inst_}$Pre2MonthF b
                                    left join ${TRpt_Svc_Usr_Info_}$Pre2MonthF c
                                      on b.user_id = c.user_id
                                    left join ${TOds_Insx_Grp_Trmnl_Rec_}$Pre2MonthF d
                                      on c.phone_no = d.bill_id
                                     and b.offer_id = d.offer_id
                                   where b.exp_date > sysdate
                                     and nvl(b.imei, d.imei) is not null) e
                          on a.sub_id = e.user_id
                         and a.imei = e.imei
                       where e.user_id is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "delete from $Rpt_Zdmm326_Termi_User_Imei_Dtl where apply_month not like '%A'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Zdmm326_Termi_User_Imei_Dtl set apply_month=substr(apply_month,1,length(apply_month)-1)" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Zdmm326_Termi_User_Imei_Dtl" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi

#2014/10/29 增加送话费的实例
WriteStatusFile 1 4 $$ $StatusFile
if DB2_Check 0 1 0 "" $mTemp_Rpt_Zdmm326_1 "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Rpt_Zdmm326_1 "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Rpt_Zdmm326_1 "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Rpt_Zdmm326_1(
              order_id             bigint,
              so_nbr               varchar(40),
              acct_id              varchar(20),
              serv_id              varchar(20),
              promo_id             integer,
              allot_rule_id        integer,
              primary_fee          decimal(10, 2),
              alloted_fee          decimal(10, 2),
              start_allot_date     varchar(8),
              alloted_bcycle_count smallint,
              remain_bcycle_count  smallint,
              sts                  smallint,
              allot_sts            smallint,
              allot_fee            decimal(10, 2),
              allot_date           timestamp,
              extend_id            varchar(20)
              ) in $TableSpace partitioning key(order_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Rpt_Zdmm326_1 activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select a.order_id,
                       a.so_nbr,
                       a.acct_id,
                       a.serv_id,
                       a.promo_id,
                       a.allot_rule_id,
                       a.primary_fee * 1.00 / 100,
                       a.alloted_fee * 1.00 / 100,
                       a.start_allot_date,
                       a.alloted_bcycle_count,
                       a.remain_bcycle_count,
                       a.sts,
                       a.allot_sts,
                       a.allot_fee * 1.00 / 100,
                       a.allot_date,
                       c.outer_promo_id
                  from ${TOds_Ca_Pa_Allot_Info_}$PreMonthF     a,
                       ${TOds_Ca_Pa_Allot_Rule_Def_}$PreMonthF b,
                       ${TOds_Ca_Pa_Promo_Def_}$PreDayF        c
                 where a.start_allot_date between '${Pre2MonthF}01' and '${ExecMonthF}01'
                   and a.allot_rule_id = b.allot_rule_id
                   and b.book_item_id_out = 0
                   and a.promo_id = c.promo_id" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $mTemp_Rpt_Zdmm326_1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
DB2_Truncate $mTemp_Rpt_Zdmm326_2 "$LogFile"-`date +%Y%m%d`

DB2_Drop $mTemp_Rpt_Zdmm326_2 "$LogFile"-`date +%Y%m%d`

if ! DB2_Cmd "create table $mTemp_Rpt_Zdmm326_2(
              order_id             bigint,
              so_nbr               varchar(40),
              acct_id              varchar(20),
              serv_id              varchar(20),
              promo_id             integer,
              allot_rule_id        integer,
              primary_fee          decimal(10, 2),
              alloted_fee          decimal(10, 2),
              start_allot_date     varchar(8),
              alloted_bcycle_count smallint,
              remain_bcycle_count  smallint,
              sts                  smallint,
              allot_sts            smallint,
              allot_fee            decimal(10, 2),
              allot_date           timestamp,
              extend_id            integer,
              offer_id             bigint
              ) in $TableSpace partitioning key(order_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Rpt_Zdmm326_2 activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select a.*,
                       b.product_item_id
                  from $mTemp_Rpt_Zdmm326_1 a, ${TOds_Crm_Up_Product_Item_}$PreDayF b
                 where a.extend_id = b.extend_id
                   and b.state = 'U'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $mTemp_Rpt_Zdmm326_2" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
DB2_Truncate $mTemp_Rpt_Zdmm326_1 "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Rpt_Zdmm326_1 "$LogFile"-`date +%Y%m%d`



#兜取终端销售有效明细
WriteStatusFile 1 5 $$ $StatusFile
if DB2_Check 0 1 0 "" $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF(
              USER_ID              VARCHAR(20),    -- 用户编号
              CUST_ID              VARCHAR(14),    -- 客户编号
              OFFER_INST_ID        VARCHAR(30),    -- 策划实例编号
              OFFER_ID             BIGINT,         -- 策划编号
              OFFER_NAME           VARCHAR(100),   -- 策划名称
              PROD_ID              BIGINT,         -- 产品编号
              PROD_NAME            VARCHAR(100),   -- 产品名称
              CREATE_DATE          DATE,           -- 创建日期
              EFFECTIVE_DATE       DATE,           -- 生效日期
              EXPIRE_DATE          DATE,           -- 失效日期
              DONE_DATE            DATE,           -- 受理日期
              DONE_CODE            VARCHAR(25),    -- 受理编号
              OP_ID                BIGINT,         -- 操作员工号
              ORG_ID               BIGINT,         -- 组织编号
              IMEI                 VARCHAR(30),    -- 终端设备号
              MATCH_IMEI           VARCHAR(30),    -- 变更终端设备号
              IMEI_8               VARCHAR(8),     -- 终端设备号前八位
              RES_CODE             VARCHAR(30),    -- 资源编码
              ORG_TERMI_TYPE       VARCHAR(3),     -- 营业侧终端类型
              ORG_TERMI_TYPE_NAME  VARCHAR(255),   -- 营业侧终端类型编码
              TERMI_TYPE           VARCHAR(30),    -- 终端类型:口径先一经后营业
              TD_TERMI_TYPE        VARCHAR(60),    -- TD终端类型
              RES_SPEC_NAME        VARCHAR(256),   -- 终端型号
              SALE_TYPE            SMALLINT,       -- 销售类型
              MONTH                SMALLINT,       -- 捆绑月数
              PERMONTH_FEE         DECIMAL(10, 2), -- 月承诺最低消费
              PRE_DEPOSIT          DECIMAL(10, 2), -- 预存款
              MARKET_PRICE         DECIMAL(10, 2), -- 购机价
              PRIMARY_FEE          DECIMAL(10, 2), -- 返还金额
              ALLOTED_FEE          DECIMAL(10, 2), -- 已返还金额
              ALLOTED_BCYCLE_COUNT SMALLINT,       -- 已返还次数
              REMAIN_BCYCLE_COUNT  SMALLINT,       -- 剩余次数
              STATE                SMALLINT,       -- 状态:1-正常,2-回退（含预回退）,3-预约
              TERMINAL_PRICE       DECIMAL(10, 2), -- 资源价格:成本价
              ALLOWANCE3           DECIMAL(10, 2), -- 端补差价
              PRESENT_FEE          DECIMAL(10, 2), -- 话费补贴
              CAPACITY_FLAG        SMALLINT,       -- 智能终端标志:0-否,1-是
              STAT_FLAG            SMALLINT        -- 统计过的标志:0-未统计过,1-之前统计过,2-无效（目前只针对二码合一）,3-新规则变更时增补标志（只增补存在补贴的）,4-临时置失效，确保因口径改变而量稳定,10以上为临时统计
              ) in $TableSpace partitioning key(USER_ID, OFFER_INST_ID, PROD_ID) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi

#2014/5/22 更换口径统计终端成本价
#统计offer_id，以加快速度
if ! DB2_Cmd "insert into $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF
                (user_id, offer_name, stat_flag)
                select distinct '-1' as User_Id, offer_id as Offer_Name, 10 as Stat_Flag
                  from ${TDwd_Svc_Off_Term_Bind_Inst_}$PreMonthF" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF
                (user_id, offer_id, offer_name, prod_id, stat_flag)
                select '-1' as User_Id,
                       b.offer_name as Offer_Id,
                       a.name as Offer_Name,
                       a.extend_id,
                       11 as Stat_Flag
                  from ${TOds_Up_Product_Item_}$PreDayF       a,
                       $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF b
                 where a.product_item_id = b.offer_name
                   and a.state = 'U'
                   and a.del_flag = 1
                   and b.stat_flag = 10" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "delete from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF where stat_flag = 10" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "INSERT INTO RPT_ZDMM326_TERMI_USER_DETAIL_$PreMonthF
                (USER_ID,
                 OFFER_INST_ID,
                 OFFER_ID,
                 PROD_ID,
                 CREATE_DATE,
                 EFFECTIVE_DATE,
                 EXPIRE_DATE,
                 DONE_DATE,
                 DONE_CODE,
                 OP_ID,
                 ORG_ID,
                 IMEI,
                 IMEI_8,
                 RES_CODE,
                 MONTH,
                 PERMONTH_FEE,
                 PRE_DEPOSIT,
                 MARKET_PRICE,
                 PRIMARY_FEE,
                 ALLOTED_FEE,
                 ALLOTED_BCYCLE_COUNT,
                 REMAIN_BCYCLE_COUNT,
                 STATE,
                 TERMINAL_PRICE,
                 STAT_FLAG,
                 TERMI_TYPE,
                 TD_TERMI_TYPE,
                 ALLOWANCE3,
                 CAPACITY_FLAG)
WITH T1(USER_ID,OFFER_INST_ID,OFFER_ID,PROD_ID,CREATE_DATE,EFF_DATE,EXP_DATE,DONE_DATE,DONE_CODE,OP_ID,ORG_ID,IMEI,IMEI_8,
RES_SPEC_ID,MONTH_NUM,PERMONTH_FEE,PREPAY_FEE,MARKET_PRICE,TOTAL_ALLOT_FEE,ALLOTED_FEE,ALLOTED_BCYCLE_NUM,REMAIN_BCYCLE_NUM
,STATE,TERM_COST,STAT_FLAG,SEQ_NO) AS
(SELECT USER_ID,OFFER_INST_ID,OFFER_ID,PROD_ID,CREATE_DATE,EFF_DATE,EXP_DATE,DONE_DATE,DONE_CODE,
OP_ID,ORG_ID,IMEI,SUBSTR(IMEI, 1, 8) AS IMEI_8,RES_SPEC_ID,MONTH_NUM,PERMONTH_FEE AS PERMONTH_FEE ,PREPAY_FEE,
MARKET_PRICE,TOTAL_ALLOT_FEE,ALLOTED_FEE,ALLOTED_BCYCLE_NUM,REMAIN_BCYCLE_NUM,STATE,TERM_COST,10 AS STAT_FLAG ,
ROW_NUMBER() OVER(PARTITION BY IMEI ORDER BY CREATE_DATE DESC) AS SEQ_NO
FROM ${TDwd_Svc_Off_Term_Bind_Inst_}$PreMonthF WHERE IMEI IS NOT NULL AND EFF_DATE BETWEEN '$miPre2MonthF-02' AND
                                               '$miExecMonthF-01'
                                           AND EXP_DATE > '$miExecMonthF-01'
                                           AND (STATE <> 2 OR SUBSTR(CREATE_DATE, 1, 7) <>
                                               SUBSTR(DONE_DATE, 1, 7))),
T2 (KEY_IMEI, MOBILE_TYPE) AS
(SELECT KEY_IMEI, MOBILE_TYPE FROM SHFIN.RPT_DIM_TERMI WHERE CREATE_YEAR_MONTH = '$PreMonthF')
SELECT T1.USER_ID,T1.OFFER_INST_ID,T1.OFFER_ID,T1.PROD_ID,T1.CREATE_DATE,T1.EFF_DATE,T1.EXP_DATE,T1.DONE_DATE,T1.DONE_CODE,T1.OP_ID,T1.ORG_ID,T1.IMEI,T1.IMEI_8,
T1.RES_SPEC_ID,T1.MONTH_NUM,T1.PERMONTH_FEE,T1.PREPAY_FEE,T1.MARKET_PRICE,T1.TOTAL_ALLOT_FEE,T1.ALLOTED_FEE,T1.ALLOTED_BCYCLE_NUM,T1.REMAIN_BCYCLE_NUM
,T1.STATE,T1.TERM_COST,T1.STAT_FLAG,
       CASE WHEN T2.MOBILE_TYPE IN ('4G上网本',
                                    '4G手机',
                                    '4G数据卡',
                                    '4G无线固话',
                                    '4GMIFI',
                                    '4G平板电脑',
                                    '4GCPE',
                                    'TDLTE上网本',
                                    'TDLTE手机',
                                    'TDLTE数据卡',
                                    'TDLTE无线固话',
                                    'TDLTEMIFI',
                                    'TDLTE平板电脑',
                                    'TDLTECPE') THEN
                                    'LTE终端'
                         WHEN T2.MOBILE_TYPE IN ('3G上网本',
                                                '3G手机',
                                                '3G数据卡',
                                                '3G无线固话',
                                                '3GMIFI',
                                                '3G平板电脑',
                                                'TDSCDMA上网本',
                                                'TDSCDMA手机',
                                                'TDSCDMA数据卡',
                                                'TDSCDMA无线固话',
                                                'TDSCDMAMIFI',
                                                'TDSCDMA平板电脑') THEN
                          'TD-SCDMA终端'
                         ELSE
                          '2G终端'
                       END AS TERMI_TYPE,
                       CASE
                         WHEN T2.MOBILE_TYPE IN ('4G手机', 'TDLTE手机') THEN
                          'LTE手机'
                         WHEN T2.MOBILE_TYPE IN
                              ('4G数据卡', 'TDLTE数据卡', '4G平板电脑', 'TDLTE平板电脑') THEN
                          'LTE数据卡'
                         WHEN T2.MOBILE_TYPE IN ('4GMIFI', 'TDLTEMIFI') THEN
                          'LTE-MIFI'
                         WHEN T2.MOBILE_TYPE IN ('4GCPE', 'TDLTECPE') THEN
                          'LTE-CPE'
                         WHEN T2.MOBILE_TYPE IN ('3G手机', 'TDSCDMA手机') THEN
                          'TD-SCDMA手机'
                         WHEN T2.MOBILE_TYPE IN ('3G无线固话', 'TDSCDMA无线固话') THEN
                          'TD-SCDMA无线座机'
                         WHEN T2.MOBILE_TYPE IN ('3G上网本',
                                                '3G数据卡',
                                                '3GMIFI',
                                                '3G平板电脑',
                                                'TDSCDMA上网本',
                                                'TDSCDMA数据卡',
                                                'TDSCDMAMIFI',
                                                'TDSCDMA平板电脑') THEN
                          'TD-SCDMA上网卡（含上网本）'
                         ELSE
                          '2G终端'
                       END AS TD_TERMI_TYPE,
                       CASE
                         WHEN VALUE(T1.TERM_COST, 0)- VALUE(T1.MARKET_PRICE, 0)> 0 THEN
                          VALUE(T1.TERM_COST, 0)-VALUE(T1.MARKET_PRICE, 0)
                         ELSE
                          0
                       END AS ALLOWANCE3,
                       CASE
                         WHEN H.KEY_IMEI IS NULL THEN
                          0
                         ELSE
                          1
                       END AS CAPACITY_FLAG
                       FROM (SELECT * FROM  T1 WHERE SEQ_NO=1) T1 LEFT JOIN T2
                       ON T1.IMEI_8 = T2.KEY_IMEI
                       LEFT JOIN (SELECT DISTINCT KEY_IMEI FROM $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF) H
                       ON T1.IMEI_8 = H.KEY_IMEI
                       left join (select done_date,
                                    end_id,
                                    beg_id,
                                    res_spec_id,
                                    op_id,
                                    op_org,
                                    business_id,
                                    done_code,
                                    row_number() over(partition by beg_id order by res_event_id desc) as seq_no
                               from ${TOds_Res_Oper_Order_Terminal_}$PreMonthF) i
                    on t1.imei = i.beg_id
                   and i.seq_no = 1
                   and i.business_id in (9016027, 9016020) -- 2014/10/29 增加裸机销售允许当月受理立即办理送话费活动
                 " "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "INSERT INTO $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF
                (USER_ID,
                 CUST_ID,
                 OFFER_INST_ID,
                 OFFER_ID,
                 OFFER_NAME,
                 PROD_ID,
                 CREATE_DATE,
                 EFFECTIVE_DATE,
                 EXPIRE_DATE,
                 DONE_DATE,
                 DONE_CODE,
                 OP_ID,
                 ORG_ID,
                 IMEI,
                 IMEI_8,
                 RES_CODE,
                 TERMI_TYPE,
                 TD_TERMI_TYPE,
                 MONTH,
                 PERMONTH_FEE,
                 PRE_DEPOSIT,
                 MARKET_PRICE,
                 PRIMARY_FEE,
                 ALLOTED_FEE,
                 ALLOTED_BCYCLE_COUNT,
                 REMAIN_BCYCLE_COUNT,
                 STATE,
                 TERMINAL_PRICE,
                 ALLOWANCE3,
                 PRESENT_FEE,
                 CAPACITY_FLAG,
                 STAT_FLAG
                 )
WITH T1(OFFER_ID,OFFER_NAME,EXTEND_ID) AS
(SELECT DISTINCT OFFER_ID,OFFER_NAME,BOSS_OFFER_ID FROM ${TDim_Svc_Off_Ploy} WHERE START_DATE<'$miPreDayF' AND END_DATE>'$miPreDayF'),
T2(OFFER_ID,OFFER_NAME,EXTEND_ID) AS
(SELECT OFFER_ID, OFFER_NAME, PROD_ID FROM $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF WHERE STAT_FLAG = 11),
T3(USER_ID,IMEI) AS
(SELECT DISTINCT SUB_ID, IMEI FROM RPT_ZDMM326_TERMI_USER_IMEI_DTL WHERE APPLY_MONTH < '$PreMonthF'),
T4(USER_ID,CUST_ID) AS
(SELECT USER_ID,CUST_ID FROM ${TOds_Ins_User_}$PreMonthF WHERE EXPIRE_DATE > '$miExecMonthF-01 00:00:00.000000')
SELECT DISTINCT A.USER_ID,
                T4.CUST_ID,
                A.OFFER_INST_ID,
                A.OFFER_ID,
                VALUE(T1.OFFER_NAME, T2.OFFER_NAME) AS OFFER_NAME,
                A.PROD_ID,
                A.CREATE_DATE,
                A.EFFECTIVE_DATE,
                A.EXPIRE_DATE,
                A.DONE_DATE,
                A.DONE_CODE,
                A.OP_ID,
                A.ORG_ID,
                A.IMEI,
                A.IMEI_8,
                A.RES_CODE,
                A.TERMI_TYPE,
                A.TD_TERMI_TYPE,
                A.MONTH,
                A.PERMONTH_FEE,
                A.PRE_DEPOSIT,
                A.MARKET_PRICE,
                A.PRIMARY_FEE,
                A.ALLOTED_FEE,
                A.ALLOTED_BCYCLE_COUNT,
                A.REMAIN_BCYCLE_COUNT,
                A.STATE,
                A.TERMINAL_PRICE,
                A.ALLOWANCE3,
                VALUE(D.PRESENT_FEE * 1.00 / 100.00, 0.00) AS PRESENT_FEE,
                A.CAPACITY_FLAG,
                CASE
                  WHEN VALUE(VALUE(T1.OFFER_NAME, T2.OFFER_NAME), '-1') LIKE
                       '%二码合一%' THEN
                   2
                  ELSE
                   CASE
                     WHEN T3.USER_ID IS NOT NULL THEN
                      1
                     ELSE
                      0
                   END
                END AS STAT_FLAG
                FROM (SELECT * FROM $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF WHERE STAT_FLAG = 10) A
                LEFT JOIN T4 ON A.USER_ID=T4.USER_ID
                LEFT JOIN T1 ON A.OFFER_ID=T1.OFFER_ID
                LEFT JOIN T2 ON A.OFFER_ID = T2.OFFER_ID
                LEFT JOIN ${TOds_Ca_Pa_Promo_Def_}$PreDayF D
                ON VALUE(T1.EXTEND_ID,CASE WHEN T1.OFFER_ID IS NULL THEN T2.EXTEND_ID END) = D.OUTER_PROMO_ID
                LEFT JOIN T3
                ON A.USER_ID = T3.USER_ID AND A.IMEI = T3.IMEI" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "delete from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF where stat_flag = 10" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#2014/3/14 增加二码合一活动的处理:只有话费补贴，没有终端补贴（终端费用不经过资源、营业），且新模型可能会漏掉二码合一活动的IMEI新模型机价已包含不需要再配机价
#提取二码合一的活动
#配imei和话费补贴
if ! DB2_Cmd "INSERT INTO $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF
                (USER_ID,
                 CUST_ID,
                 OFFER_INST_ID,
                 OFFER_ID,
                 OFFER_NAME,
                 PROD_ID,
                 CREATE_DATE,
                 EFFECTIVE_DATE,
                 EXPIRE_DATE,
                 DONE_DATE,
                 DONE_CODE,
                 OP_ID,
                 ORG_ID,
                 IMEI,
                 IMEI_8,
                 RES_CODE,
                 TERMI_TYPE,
                 TD_TERMI_TYPE,
                 MONTH,
                 PERMONTH_FEE,
                 PRE_DEPOSIT,
                 MARKET_PRICE,
                 PRIMARY_FEE,
                 ALLOTED_FEE,
                 ALLOTED_BCYCLE_COUNT,
                 REMAIN_BCYCLE_COUNT,
                 STATE,
                 PRESENT_FEE,
                 TERMINAL_PRICE,
                 CAPACITY_FLAG,
                 STAT_FLAG
                 )
WITH T1(OFFER_ID,OFFER_NAME,EXTEND_ID) AS
(SELECT OFFER_ID, OFFER_NAME, PROD_ID AS EXTEND_ID FROM $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF WHERE STAT_FLAG = 11 AND OFFER_NAME LIKE '%二码合一%'),
T2(USER_ID,CUST_ID,OFFER_INST_ID,OFFER_ID,OFFER_NAME,PROD_ID,CREATE_DATE,EFF_DATE,EXP_DATE,DONE_DATE,DONE_CODE,OP_ID,ORG_ID,IMEI,IMEI_8,
RES_SPEC_ID,MONTH_NUM,PERMONTH_FEE,PREPAY_FEE,MARKET_PRICE,TERMINAL_PRICE,TOTAL_ALLOT_FEE,ALLOTED_FEE,ALLOTED_BCYCLE_NUM,REMAIN_BCYCLE_NUM
,STATE,EXTEND_ID,SEQ_NO) AS
(SELECT  A.USER_ID,
	       C.CUST_ID,
         A.OFFER_INST_ID,
         A.OFFER_ID,
         B.OFFER_NAME,
         A.PROD_ID,
         A.CREATE_DATE,
         A.EFF_DATE,
         A.EXP_DATE,
         A.DONE_DATE,
         A.DONE_CODE,
         A.OP_ID,
         A.ORG_ID,
         VALUE(A.IMEI, D.IMEI) AS IMEI,
         SUBSTR(VALUE(A.IMEI, D.IMEI), 1, 8) AS IMEI_8,
         A.RES_SPEC_ID,
         A.MONTH_NUM,
         A.PERMONTH_FEE,
         A.PREPAY_FEE,
         A.MARKET_PRICE,
         A.TERM_COST,
         A.TOTAL_ALLOT_FEE,
         A.ALLOTED_FEE,
         A.ALLOTED_BCYCLE_NUM,
         A.REMAIN_BCYCLE_NUM,
         A.STATE,
         B.EXTEND_ID,
         ROW_NUMBER() OVER(PARTITION BY VALUE(A.IMEI, D.IMEI) ORDER BY A.CREATE_DATE DESC) AS SEQ_NO
    FROM ${TDwd_Svc_Off_Term_Bind_Inst_}$PreMonthF A,
         T1 B,
         ${TOds_Ins_User_}$PreMonthF C,
         ${TOds_Insx_Grp_Trmnl_Rec_}$PreMonthF D
    WHERE A.EFF_DATE BETWEEN '$miPre2MonthF-02' and
         '$miExecMonthF-01'
     AND A.exp_date > '$YearBeforePreMonth-01-01'
     AND (A.STATE <> 2 OR
         SUBSTR(A.CREATE_DATE, 1, 7) <> SUBSTR(A.DONE_DATE, 1, 7))
     AND A.OFFER_ID = B.OFFER_ID
     AND A.USER_ID = C.USER_ID
     AND C.EXPIRE_DATE > '$miExecMonthF-01 00:00:00.000000'
     AND C.BILL_ID = D.BILL_ID
     AND A.OFFER_ID = D.OFFER_ID
     AND VALUE(A.IMEI, D.IMEI) IS NOT NULL),
T3(KEY_IMEI,MOBILE_TYPE) AS
(SELECT KEY_IMEI, MOBILE_TYPE FROM RPT_DIM_TERMI WHERE CREATE_YEAR_MONTH = '$PreMonthF'),
T4(KEY_IMEI) AS
(SELECT DISTINCT KEY_IMEI FROM $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF),
T5(OFFER_ID,OFFER_NAME,EXTEND_ID) AS
(SELECT OFFER_ID,OFFER_NAME,BOSS_OFFER_ID FROM ${TDim_Svc_Off_Ploy} WHERE START_DATE<'$miPreDayF' AND END_DATE>'$miPreDayF')
SELECT  E.USER_ID,
			  E.CUST_ID,
        E.OFFER_INST_ID,
        E.OFFER_ID,
        VALUE(F.OFFER_NAME, E.OFFER_NAME) AS OFFER_NAME,
        E.PROD_ID,
        E.CREATE_DATE,
        E.EFF_DATE,
        E.EXP_DATE,
        E.DONE_DATE,
        E.DONE_CODE,
        E.OP_ID,
        E.ORG_ID,
        E.IMEI,
        E.IMEI_8,
        E.RES_SPEC_ID,
        CASE
          WHEN H.MOBILE_TYPE IN ('4G上网本',
                                 '4G手机',
                                 '4G数据卡',
                                 '4G无线固话',
                                 '4GMIFI',
                                 '4G平板电脑',
                                 '4GCPE',
                                 'TDLTE上网本',
                                 'TDLTE手机',
                                 'TDLTE数据卡',
                                 'TDLTE无线固话',
                                 'TDLTEMIFI',
                                 'TDLTE平板电脑',
                                 'TDLTECPE') THEN 'LTE终端'
          WHEN H.MOBILE_TYPE IN ('3G上网本',
                                 '3G手机',
                                 '3G数据卡',
                                 '3G无线固话',
                                 '3GMIFI',
                                 '3G平板电脑',
                                 'TDSCDMA上网本',
                                 'TDSCDMA手机',
                                 'TDSCDMA数据卡',
                                 'TDSCDMA无线固话',
                                 'TDSCDMAMIFI',
                                 'TDSCDMA平板电脑') THEN 'TD-SCDMA终端'
          ELSE  '2G终端' END AS TERMI_TYPE,
        CASE
          WHEN H.MOBILE_TYPE IN ('4G手机', 'TDLTE手机') THEN
           'LTE手机'
          WHEN H.MOBILE_TYPE IN ('4G数据卡',
                                 'TDLTE数据卡',
                                 '4G平板电脑',
                                 'TDLTE平板电脑') THEN
           'LTE数据卡'
          WHEN H.MOBILE_TYPE IN ('4GMIFI', 'TDLTEMIFI') THEN
           'LTE-MIFI'
          WHEN H.MOBILE_TYPE IN ('4GCPE', 'TDLTECPE') THEN
           'LTE-CPE'
          WHEN H.MOBILE_TYPE IN ('3G手机', 'TDSCDMA手机') THEN
           'TD-SCDMA手机'
          WHEN H.MOBILE_TYPE IN ('3G无线固话', 'TDSCDMA无线固话') THEN
           'TD-SCDMA无线座机'
          WHEN H.MOBILE_TYPE IN ('3G上网本',
                                 '3G数据卡',
                                 '3GMIFI',
                                 '3G平板电脑',
                                 'TDSCDMA上网本',
                                 'TDSCDMA数据卡',
                                 'TDSCDMAMIFI',
                                 'TDSCDMA平板电脑') THEN
           'TD-SCDMA上网卡（含上网本）'
          ELSE
           '2G终端'
        END AS TD_TERMI_TYPE,
        E.MONTH_NUM,
        E.PERMONTH_FEE,
        E.PREPAY_FEE,
        E.MARKET_PRICE,
        E.TOTAL_ALLOT_FEE,
        E.ALLOTED_FEE,
        E.ALLOTED_BCYCLE_NUM,
        E.REMAIN_BCYCLE_NUM,
        E.STATE,
        VALUE(G.primary_fee * 1.00 / 100.00, 0.00) AS PRESENT_FEE,
        E.TERMINAL_PRICE,
        CASE
          WHEN I.KEY_IMEI IS NULL THEN
           0
          ELSE
           1
        END AS CAPACITY_FLAG,
        10 AS STAT_FLAG
FROM T2 E
LEFT JOIN T5 F
  ON E.OFFER_ID = F.OFFER_ID
  left join (select distinct serv_id, offer_id, primary_fee
                from $mTemp_Rpt_Zdmm326_2
		 where sts = 1) g
	 on e.user_id = g.serv_id
	 and e.offer_id = g.offer_id
	 LEFT JOIN T3 H
  ON E.IMEI_8 = H.KEY_IMEI
LEFT JOIN T4 I
  ON E.IMEI_8 = I.KEY_IMEI
WHERE E.SEQ_NO = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "delete from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF where stat_flag in (10,11)" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#2014/10/31 新口径量较以往要多，必须把8、9月的数据置失效，确保波动可控
if ! DB2_Cmd "update $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF set stat_flag=4 where stat_flag=0 and effective_date between '2014-09-02' and '2014-10-01'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#2014/7/6 按照营改增新要求的公式进行数据更新（只更新年表），见下面一段
#客户实际缴纳金额=用户购买终端价钱+客户预存的话费
#用户购买终端实际缴纳金额（含增值税）=客户实际缴纳金额-客户预存的话费
#用户购买终端实际缴纳金额（不含增值税）=（客户实际缴纳金额-客户预存的话费）/1.17
#成本类补贴金额=终端采购成本价格（不含增值税）-用户购买终端实际缴纳金额（不含增值税）
#              =(终端采购成本价格-用户购买终端实际缴纳金额)/1.17
#              =(终端采购成本价格-(客户实际缴纳金额-客户预存的话费))/1.17
#              =(终端采购成本价格-((用户购买终端价钱+客户预存的话费)-客户预存的话费))/1.17
#              =(终端采购成本价格-用户购买终端价钱)/1.17
#2014/7/7 财务通过集团确认，只有当终端采购成本价格-用户购买终端价钱<0时，“终端采购成本价格-用户购买终端价钱”进入此公式
#话费类补贴金额=终端采购成本价格（不含增值税）+赠送给用户的话费-用户购买终端实际缴纳金额（不含增值税）
#              =(终端采购成本价格-用户购买终端实际缴纳金额)/1.17+赠送给用户的话费
#              =(终端采购成本价格-用户购买终端价钱)/1.17+赠送给用户的话费
if ! DB2_Cmd "runstats on table $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
DB2_Truncate $mTemp_Rpt_Zdmm326_2 "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Rpt_Zdmm326_2 "$LogFile"-`date +%Y%m%d`


#建立终端补贴基础表
WriteStatusFile 1 6 $$ $StatusFile
if ! DB2_Check 0 1 0 "" $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear(
	              SUB_ID         VARCHAR(20),
	              TERMI_TYPE     VARCHAR(30),
	              TD_TERMI_TYPE  VARCHAR(60),
	              BT_TYPE        VARCHAR(10),
	              BUY_PRICE      INTEGER,
	              BT_FEE         DECIMAL(10, 2),
	              CAPACITY_FLAG  SMALLINT,
	              IMEI           VARCHAR(30),
	              APPLY_MONTH    VARCHAR(10)
	              ) data capture none in $TableSpace partitioning key(sub_id,apply_month) using hashing" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "delete from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear where apply_month='$PreMonthF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#从终端集中采购业务记录月表、终端采购价格维表月表
#if ! DB2_Cmd "insert into $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
#                select distinct user_id,
#                                termi_type,
#                                td_termi_type,
#                                '话费类',
#                                terminal_price, -- 终端采购价(进货价)
#                                present_fee, -- 话费补贴
#                                capacity_flag,
#                                imei,
#                                '$PreMonthF'
#                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF
#                 where stat_flag = 0
#                   and present_fee > 0" "$LogFile"-`date +%Y%m%d`
#then
#	exit 1
#fi
#if ! DB2_Cmd "insert into $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
#                select distinct user_id,
#                                termi_type,
#                                td_termi_type,
#                                '成本类',
#                                terminal_price,
#                                allowance3,
#                                capacity_flag,
#                                imei,
#                                '$PreMonthF'
#                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF
#                 where stat_flag = 0
#                   and allowance3 > 0" "$LogFile"-`date +%Y%m%d`
#then
#	exit 1
#fi
#2014/7/7 营改增
if ! DB2_Cmd "insert into $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                select distinct user_id,
                                termi_type,
                                td_termi_type,
                                '话费类',
                                terminal_price, -- 终端采购价(进货价)
                                case
                                  when b.org_id is null or allowance3 > 0 then -- 2014/8/20 增加社会渠道不判成本补贴负向值
                                   present_fee
                                  else
                                   present_fee + round((terminal_price - case
                                                         when offer_name not like '%二码合一%' then
                                                          market_price
                                                         else
                                                          terminal_price
                                                       end) * 1.00 / 1.17,
                                                       2)
                                end as Present_Fee, -- 话费补贴
                                capacity_flag,
                                imei,
                                '$PreMonthF'
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF a
                  left join (select distinct org_id
                               from ${TDim_Prty_Org_Info} -- 2014/8/20 增加渠道限制，社会渠道没有成本类补贴
                              where bass_org_type in (6, 7, 8) and start_date<='$miPreDayF' And end_date >'$miPreDayF') b
                    on a.org_id = b.org_id
                 where stat_flag = 0
                   and (terminal_price < case
                         when offer_name not like '%二码合一%' then
                          market_price
                         else
                          terminal_price
                       end and terminal_price - market_price + present_fee > 0.00 or
                       terminal_price >= case
                         when offer_name not like '%二码合一%' then
                          market_price
                         else
                          terminal_price
                       end and present_fee > 0.00)" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                select distinct user_id,
                                termi_type,
                                td_termi_type,
                                '成本类',
                                terminal_price,
                                round(allowance3 * 1.00 / 1.17, 2) as allowance3,
                                capacity_flag,
                                imei,
                                '$PreMonthF'
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF
                 where stat_flag = 0
                   and round(allowance3 * 1.00 / 1.17, 2) > 0.00
                   and org_id in (select distinct org_id
                                    from ${TDim_Prty_Org_Info} -- 2014/8/14 增加渠道限制，社会渠道没有成本类补贴
                                   where bass_org_type in (6, 7, 8) and start_date<='$miPreDayF' And end_date >'$miPreDayF' )" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#2014/7/7 由于终端补贴报表要求到元，故采取去小数（不是四舍五入）方法再处理
if ! DB2_Cmd "update $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear set bt_fee=int(bt_fee) where apply_month='$PreMonthF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#2014/10/29 对自备机参加话费补贴的，终端价格档次以话费补贴为准
if ! DB2_Cmd "update $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear set buy_price=bt_fee where apply_month='$PreMonthF' and bt_type='话费类' and buy_price is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#一般不可能，以防万一
if ! DB2_Cmd "delete from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear where apply_month='$PreMonthF' and bt_fee=0.00" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#清洗当月数据，方便程序重跑数月
if ! DB2_Cmd "delete from $Rpt_Zdmm326_Termi_User_Imei_Dtl where apply_month='$PreMonthF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Zdmm326_Termi_User_Imei_Dtl
                select distinct user_id, imei, '$PreMonthF' as Apply_Month, create_date, offer_id
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthF
                 where stat_flag = 0
                   and (round(allowance3 * 1.00 / 1.17, 2) > 0.00 and
                       org_id in (select distinct org_id
                                     from ${TDim_Prty_Org_Info} -- 2014/8/14 增加渠道限制，社会渠道没有成本类补贴
                                    where bass_org_type in (6, 7, 8) and  start_date<='$miPreDayF' And end_date >'$miPreDayF' ) or present_fee > 0)" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Zdmm326_Termi_User_Imei_Dtl" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi


#提取累计用户当月消费情况
WriteStatusFile 1 7 $$ $StatusFile
if DB2_Check 0 1 0 "" $mTemp_Zdmm326_Termi_User_Detail_Fee "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Zdmm326_Termi_User_Detail_Fee "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Zdmm326_Termi_User_Detail_Fee "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Zdmm326_Termi_User_Detail_Fee(
              sub_id        varchar(20),
              termi_type    varchar(30),
              td_termi_type varchar(60),
              total_fee     integer,
              consume_id    integer,
              consume_name  varchar(20),
              capacity_flag varchar(10),
              leave_flag    smallint -- 离网标志:1-离网
              ) in $TableSpace partitioning key(sub_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Zdmm326_Termi_User_Detail_Fee activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Zdmm326_Termi_User_Detail_Fee
                select a.sub_id,
                       a.termi_type,
                       a.td_termi_type,
                       nvl(g.total_fee, 0),
                       nvl(consume_id, 2),
                       nvl(consume_name, '10元以下'),
                       capacity_flag,
                       (case
                         when nvl(consume_id, 2) = 2 then
                          (case
                            when e.bass_user_state_id in (100, 110,111, 114) then
                             0
                            else
                             1
                          end)
                       end)
                  from (select distinct sub_id,
                                        (case
                                          when termi_type = 'TD终端' then
                                           'TD-SCDMA终端'
                                          else
                                           termi_type
                                        end) as Termi_Type,
                                        (case
                                          when td_termi_type = 'TD手机' then
                                           'TD-SCDMA手机'
                                          when td_termi_type = 'TD无线座机' then
                                           'TD-SCDMA无线座机'
                                          when td_termi_type = 'TD上网卡（含上网本）' then
                                           'TD-SCDMA上网卡（含上网本）'
                                          else
                                           td_termi_type
                                        end) as Td_Termi_Type,
                                        capacity_flag,
                                        apply_month,
                                        buy_price,
                                        imei
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where apply_month <= '$PreMonthF') as a
                  left outer join ${TDwd_Svc_Usr_All_Info_}$PreMonthF e
                    on a.sub_id = e.user_id
                  left outer join (select user_id,sum(bill_fee) as total_fee from ${TDwd_Acc_Sum_Bill_}$PreMonthF group by user_id) g
                  on e.user_id=g.user_id
                  left outer join (select * from ${TDim_Group_Fee_Lev} where id = 13) f
                    on g.total_fee > f.min_value
                   and g.total_fee <= f.max_value" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#2014/3/11 将离网从“10元”以下独立出来
if ! DB2_Cmd "update $mTemp_Zdmm326_Termi_User_Detail_Fee set consume_id=-1,consume_name='离网' where consume_id=2 and leave_flag=1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $mTemp_Zdmm326_Termi_User_Detail_Fee" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi

#生成报表结果
WriteStatusFile 1 8 $$ $StatusFile
if ! DB2_Cmd "create table $mTemp_Rpt_Zdmm326_1(
              stat_month      varchar(10),
              side_name       varchar(50),
              title_name      varchar(40),
              sub_title_name  varchar(40),
              busi_num        bigint
              ) in $TableSpace partitioning key(stat_month) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Rpt_Zdmm326_1 activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       '合计',
                       '本年累计终端补贴客户数（户）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       count(*)
                  from (select distinct sub_id, imei, bt_type
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where apply_month = '$PreMonthF')
                 group by case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       '合计',
                       '本年累计终端补贴客户数（户）',
                       '合计',
                       count(*)
                  from (select distinct sub_id, imei
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where apply_month = '$PreMonthF')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       '合计',
                       '本年累计终端补贴金额（元）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       sum(bt_fee)
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where apply_month = '$PreMonthF'
                 group by case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       termi_type,
                       '本年累计终端补贴客户数（户）',
                       case
                         when bt_type = '成本类' then
                          '其中：成本类补贴'
                         else
                          '其中：话费类补贴'
                       end,
                       count(*)
                  from (select distinct sub_id, imei, bt_type, termi_type
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where apply_month = '$PreMonthF')
                 group by termi_type,
                          case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       termi_type,
                       '本年累计终端补贴客户数（户）',
                       '合计',
                       count(*)
                  from (select distinct sub_id, imei, termi_type
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where apply_month = '$PreMonthF')
                 group by termi_type" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       termi_type,
                       '本年累计终端补贴金额（元）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       sum(bt_fee)
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where apply_month = '$PreMonthF'
                 group by termi_type,
                          case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       td_termi_type,
                       '本年累计终端补贴客户数（户）',
                       case
                         when bt_type = '成本类' then
                          '其中：成本类补贴'
                         else
                          '其中：话费类补贴'
                       end,
                       count(*)
                  from (select distinct sub_id, imei, bt_type, td_termi_type
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where apply_month = '$PreMonthF'
                           and termi_type = 'TD-SCDMA终端')
                 group by td_termi_type,
                          case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       td_termi_type,
                       '本年累计终端补贴客户数（户）',
                       '合计',
                       count(*)
                  from (select distinct sub_id, imei, td_termi_type
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where apply_month = '$PreMonthF'
                           and termi_type = 'TD-SCDMA终端')
                 group by td_termi_type" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       td_termi_type,
                       '本年累计终端补贴金额（元）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       sum(bt_fee)
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where termi_type = 'TD-SCDMA终端'
                   and apply_month = '$PreMonthF'
                 group by td_termi_type,
                          case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       td_termi_type,
                       '本年累计终端补贴客户数（户）',
                       case
                         when bt_type = '成本类' then
                          '其中：成本类补贴'
                         else
                          '其中：话费类补贴'
                       end,
                       count(*)
                  from (select distinct sub_id, imei, bt_type, td_termi_type
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where apply_month = '$PreMonthF'
                           and termi_type = 'LTE终端')
                 group by td_termi_type,
                          case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       td_termi_type,
                       '本年累计终端补贴客户数（户）',
                       '合计',
                       count(*)
                  from (select distinct sub_id, imei, td_termi_type
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where apply_month = '$PreMonthF'
                           and termi_type = 'LTE终端')
                 group by td_termi_type" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       td_termi_type,
                       '本年累计终端补贴金额（元）',
                       case
                         when bt_type = '成本类' then
                          '其中：成本类补贴'
                         else
                          '其中：话费类补贴'
                       end,
                       sum(bt_fee)
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where termi_type = 'LTE终端'
                   and apply_month = '$PreMonthF'
                 group by td_termi_type,
                          case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi

if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       '		其中：TD-SCDMA智能手机',
                       '本年累计终端补贴客户数（户）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       count(*)
                  from (select distinct sub_id, imei, bt_type
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where td_termi_type = 'TD-SCDMA手机'
                           and capacity_flag = 1
                           and apply_month = '$PreMonthF')
                 group by case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       '		其中：TD-SCDMA智能手机',
                       '本年累计终端补贴客户数（户）',
                       '合计',
                       count(*)
                  from (select distinct sub_id, imei
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where td_termi_type = 'TD-SCDMA手机'
                           and capacity_flag = 1
                           and apply_month = '$PreMonthF')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       '		其中：TD-SCDMA智能手机',
                       '本年累计终端补贴金额（元）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       sum(bt_fee)
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where td_termi_type = 'TD-SCDMA手机'
                   and capacity_flag = 1
                   and apply_month = '$PreMonthF'
                 group by case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                (stat_month, side_name, title_name, sub_title_name)
                select distinct '$PreMonthF',
                                '按照TD-SCDMA手机的进货成本价划分',
                                '本年累计终端补贴客户数（户）',
                                case
                                  when bt_type = '成本类' then
                                   '其中：成本类补贴'
                                  else
                                   '其中：话费类补贴'
                                end
                  from (select distinct sub_id, imei, bt_type
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where apply_month = '$PreMonthF') as a
                 group by case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when buy_price < 1000 then
                          '其中：1000元以下的TD-SCDMA手机'
                         when buy_price >= 1000 and buy_price < 2000 then
                          '1000-2000元的TD-SCDMA手机'
                         when buy_price >= 2000 and buy_price < 3000 then
                          '2000-3000元的TD-SCDMA手机'
                         when buy_price >= 3000 then
                          '3000元以上的TD-SCDMA手机'
                       end,
                       '本年累计终端补贴客户数（户）',
                       case
                         when bt_type = '成本类' then
                          '其中：成本类补贴'
                         else
                          '其中：话费类补贴'
                       end,
                       count(*)
                  from (select distinct sub_id, imei, bt_type, buy_price
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'TD-SCDMA终端'
                           and td_termi_type = 'TD-SCDMA手机'
                           and apply_month = '$PreMonthF') as a
                 group by case
                            when buy_price < 1000 then
                             '其中：1000元以下的TD-SCDMA手机'
                            when buy_price >= 1000 and buy_price < 2000 then
                             '1000-2000元的TD-SCDMA手机'
                            when buy_price >= 2000 and buy_price < 3000 then
                             '2000-3000元的TD-SCDMA手机'
                            when buy_price >= 3000 then
                             '3000元以上的TD-SCDMA手机'
                          end,
                          case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when buy_price < 1000 then
                          '其中：1000元以下的TD-SCDMA手机'
                         when buy_price >= 1000 and buy_price < 2000 then
                          '1000-2000元的TD-SCDMA手机'
                         when buy_price >= 2000 and buy_price < 3000 then
                          '2000-3000元的TD-SCDMA手机'
                         when buy_price >= 3000 then
                          '3000元以上的TD-SCDMA手机'
                       end,
                       '本年累计终端补贴客户数（户）',
                       '合计',
                       count(*)
                  from (select distinct sub_id, imei, buy_price
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'TD-SCDMA终端'
                           and td_termi_type = 'TD-SCDMA手机'
                           and apply_month = '$PreMonthF') as a
                 group by case
                            when buy_price < 1000 then
                             '其中：1000元以下的TD-SCDMA手机'
                            when buy_price >= 1000 and buy_price < 2000 then
                             '1000-2000元的TD-SCDMA手机'
                            when buy_price >= 2000 and buy_price < 3000 then
                             '2000-3000元的TD-SCDMA手机'
                            when buy_price >= 3000 then
                             '3000元以上的TD-SCDMA手机'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when buy_price < 1000 then '其中：1000元以下的TD-SCDMA手机'
                         when buy_price >= 1000 and buy_price < 2000 then '1000-2000元的TD-SCDMA手机'
                         when buy_price >= 2000 and buy_price < 3000 then '2000-3000元的TD-SCDMA手机'
                         when buy_price >= 3000 then '3000元以上的TD-SCDMA手机'
                       end,
                       '本年累计终端补贴金额（元）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       sum(bt_fee)
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where termi_type = 'TD-SCDMA终端'
                   and td_termi_type = 'TD-SCDMA手机'
                   and apply_month = '$PreMonthF'
                 group by case
                            when buy_price < 1000 then '其中：1000元以下的TD-SCDMA手机'
                            when buy_price >= 1000 and buy_price < 2000 then '1000-2000元的TD-SCDMA手机'
                            when buy_price >= 2000 and buy_price < 3000 then '2000-3000元的TD-SCDMA手机'
                            when buy_price >= 3000 then '3000元以上的TD-SCDMA手机'
                          end,
                          case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select stat_month, 'TD-SCDMA手机终端补贴', title_name, sub_title_name, busi_num
                  from $mTemp_Rpt_Zdmm326_1
                 where stat_month = '$PreMonthF'
                   and side_name = 'TD-SCDMA手机'
                   and title_name in
                       ('本年累计终端补贴客户数（户）', '本年累计终端补贴金额（元）')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#智能终端
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when buy_price < 1000 then
                          '其中：1000元以下的TD-SCDMA手机.'
                         when buy_price >= 1000 and buy_price < 2000 then
                          '1000-2000元的TD-SCDMA手机.'
                         when buy_price >= 2000 and buy_price < 3000 then
                          '2000-3000元的TD-SCDMA手机.'
                         when buy_price >= 3000 then
                          '3000元以上的TD-SCDMA手机.'
                       end,
                       '本年累计终端补贴客户数（户）',
                       case
                         when bt_type = '成本类' then
                          '其中：成本类补贴'
                         else
                          '其中：话费类补贴'
                       end,
                       count(*)
                  from (select distinct sub_id, imei, bt_type, buy_price
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'TD-SCDMA终端'
                           and td_termi_type = 'TD-SCDMA手机'
                           and capacity_flag = 1
                           and apply_month = '$PreMonthF') as a
                 group by case
                            when buy_price < 1000 then
                             '其中：1000元以下的TD-SCDMA手机.'
                            when buy_price >= 1000 and buy_price < 2000 then
                             '1000-2000元的TD-SCDMA手机.'
                            when buy_price >= 2000 and buy_price < 3000 then
                             '2000-3000元的TD-SCDMA手机.'
                            when buy_price >= 3000 then
                             '3000元以上的TD-SCDMA手机.'
                          end,
                          case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when buy_price < 1000 then
                          '其中：1000元以下的TD-SCDMA手机.'
                         when buy_price >= 1000 and buy_price < 2000 then
                          '1000-2000元的TD-SCDMA手机.'
                         when buy_price >= 2000 and buy_price < 3000 then
                          '2000-3000元的TD-SCDMA手机.'
                         when buy_price >= 3000 then
                          '3000元以上的TD-SCDMA手机.'
                       end,
                       '本年累计终端补贴客户数（户）',
                       '合计',
                       count(*)
                  from (select distinct sub_id, imei, buy_price
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'TD-SCDMA终端'
                           and td_termi_type = 'TD-SCDMA手机'
                           and capacity_flag = 1
                           and apply_month = '$PreMonthF') as a
                 group by case
                            when buy_price < 1000 then
                             '其中：1000元以下的TD-SCDMA手机.'
                            when buy_price >= 1000 and buy_price < 2000 then
                             '1000-2000元的TD-SCDMA手机.'
                            when buy_price >= 2000 and buy_price < 3000 then
                             '2000-3000元的TD-SCDMA手机.'
                            when buy_price >= 3000 then
                             '3000元以上的TD-SCDMA手机.'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when buy_price < 1000 then '其中：1000元以下的TD-SCDMA手机.'
                         when buy_price >= 1000 and buy_price < 2000 then '1000-2000元的TD-SCDMA手机.'
                         when buy_price >= 2000 and buy_price < 3000 then '2000-3000元的TD-SCDMA手机.'
                         when buy_price >= 3000 then '3000元以上的TD-SCDMA手机.'
                       end,
                       '本年累计终端补贴金额（元）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       sum(bt_fee)
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where termi_type = 'TD-SCDMA终端'
                   and td_termi_type = 'TD-SCDMA手机'
                   and capacity_flag = 1
                   and apply_month = '$PreMonthF'
                 group by case
                            when buy_price < 1000 then '其中：1000元以下的TD-SCDMA手机.'
                            when buy_price >= 1000 and buy_price < 2000 then '1000-2000元的TD-SCDMA手机.'
                            when buy_price >= 2000 and buy_price < 3000 then '2000-3000元的TD-SCDMA手机.'
                            when buy_price >= 3000 then '3000元以上的TD-SCDMA手机.'
                          end,
                          case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select stat_month, 'TD-SCDMA智能终端补贴', title_name, sub_title_name, busi_num
                  from $mTemp_Rpt_Zdmm326_1
                 where stat_month = '$PreMonthF'
                   and side_name = '		其中：TD-SCDMA智能手机'
                   and title_name in
                       ('本年累计终端补贴客户数（户）', '本年累计终端补贴金额（元）')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                (stat_month, side_name, title_name, sub_title_name)
                select distinct '$PreMonthF',
                                '按照TD-SCDMA手机补贴金额划分',
                                '本年累计终端补贴客户数（户）',
                                case
                                  when bt_type = '成本类' then '其中：成本类补贴'
                                  else '其中：话费类补贴'
                                end
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where apply_month = '$PreMonthF'
                 group by case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       bt_level,
                       '本年累计终端补贴客户数（户）',
                       case
                         when bt_type = '成本类' then
                          '其中：成本类补贴'
                         else
                          '其中：话费类补贴'
                       end,
                       count(*)
                  from (select distinct sub_id,
                                        imei,
                                        bt_type,
                                        case
                                          when bt_fee < 500 then
                                           '其中：补贴0-500元的用户'
                                          when bt_fee >= 500 and bt_fee < 1000 then
                                           '补贴500-1000元的用户'
                                          when bt_fee >= 1000 and bt_fee < 2000 then
                                           '补贴1000-2000元的用户'
                                          when bt_fee >= 2000 and bt_fee < 3000 then
                                           '补贴2000-3000元的用户'
                                          else
                                           '补贴3000元以上的用户'
                                        end as Bt_Level
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'TD-SCDMA终端'
                           and td_termi_type = 'TD-SCDMA手机'
                           and apply_month = '$PreMonthF')
                 group by bt_level,
                          case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       bt_level,
                       '本年累计终端补贴客户数（户）',
                       '合计',
                       count(*)
                  from (select distinct sub_id,
                                        imei,
                                        case
                                          when bt_fee < 500 then
                                           '其中：补贴0-500元的用户'
                                          when bt_fee >= 500 and bt_fee < 1000 then
                                           '补贴500-1000元的用户'
                                          when bt_fee >= 1000 and bt_fee < 2000 then
                                           '补贴1000-2000元的用户'
                                          when bt_fee >= 2000 and bt_fee < 3000 then
                                           '补贴2000-3000元的用户'
                                          else
                                           '补贴3000元以上的用户'
                                        end as Bt_Level
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'TD-SCDMA终端'
                           and td_termi_type = 'TD-SCDMA手机'
                           and apply_month = '$PreMonthF')
                 group by bt_level" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when bt_fee < 500 then '其中：补贴0-500元的用户'
                         when bt_fee >= 500 and bt_fee < 1000 then '补贴500-1000元的用户'
                         when bt_fee >= 1000 and bt_fee < 2000 then '补贴1000-2000元的用户'
                         when bt_fee >= 2000 and bt_fee < 3000 then '补贴2000-3000元的用户'
                         else '补贴3000元以上的用户'
                       end,
                       '本年累计终端补贴金额（元）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       sum(bt_fee)
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where termi_type = 'TD-SCDMA终端'
                   and td_termi_type = 'TD-SCDMA手机'
                   and apply_month = '$PreMonthF'
                 group by case
                            when bt_fee < 500 then '其中：补贴0-500元的用户'
                            when bt_fee >= 500 and bt_fee < 1000 then '补贴500-1000元的用户'
                            when bt_fee >= 1000 and bt_fee < 2000 then '补贴1000-2000元的用户'
                            when bt_fee >= 2000 and bt_fee < 3000 then '补贴2000-3000元的用户'
                            else '补贴3000元以上的用户'
                          end,
                          case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select stat_month,
                       'TD-SCDMA手机终端补贴.',
                       title_name,
                       sub_title_name,
                       busi_num
                  from $mTemp_Rpt_Zdmm326_1
                 where stat_month = '$PreMonthF'
                   and side_name = 'TD-SCDMA手机'
                   and title_name in
                       ('本年累计终端补贴客户数（户）', '本年累计终端补贴金额（元）')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       bt_level,
                       '本年累计终端补贴客户数（户）',
                       case
                         when bt_type = '成本类' then
                          '其中：成本类补贴'
                         else
                          '其中：话费类补贴'
                       end,
                       count(*)
                  from (select distinct sub_id,
                                        imei,
                                        bt_type,
                                        case
                                          when bt_fee < 500 then
                                           '其中：补贴0-500元的用户.'
                                          when bt_fee >= 500 and bt_fee < 1000 then
                                           '补贴500-1000元的用户.'
                                          when bt_fee >= 1000 and bt_fee < 2000 then
                                           '补贴1000-2000元的用户.'
                                          when bt_fee >= 2000 and bt_fee < 3000 then
                                           '补贴2000-3000元的用户.'
                                          else
                                           '补贴3000元以上的用户.'
                                        end as Bt_Level
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'TD-SCDMA终端'
                           and td_termi_type = 'TD-SCDMA手机'
                           and capacity_flag = 1
                           and apply_month = '$PreMonthF') as a
                 group by bt_level,
                          case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       bt_level,
                       '本年累计终端补贴客户数（户）',
                       '合计',
                       count(*)
                  from (select distinct sub_id,
                                        imei,
                                        case
                                          when bt_fee < 500 then
                                           '其中：补贴0-500元的用户.'
                                          when bt_fee >= 500 and bt_fee < 1000 then
                                           '补贴500-1000元的用户.'
                                          when bt_fee >= 1000 and bt_fee < 2000 then
                                           '补贴1000-2000元的用户.'
                                          when bt_fee >= 2000 and bt_fee < 3000 then
                                           '补贴2000-3000元的用户.'
                                          else
                                           '补贴3000元以上的用户.'
                                        end as Bt_Level
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'TD-SCDMA终端'
                           and td_termi_type = 'TD-SCDMA手机'
                           and capacity_flag = 1
                           and apply_month = '$PreMonthF')
                 group by bt_level" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when bt_fee < 500 then '其中：补贴0-500元的用户.'
                         when bt_fee >= 500 and bt_fee < 1000 then '补贴500-1000元的用户.'
                         when bt_fee >= 1000 and bt_fee < 2000 then '补贴1000-2000元的用户.'
                         when bt_fee >= 2000 and bt_fee < 3000 then '补贴2000-3000元的用户.'
                         else '补贴3000元以上的用户.'
                       end,
                       '本年累计终端补贴金额（元）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                      sum(bt_fee)
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where termi_type = 'TD-SCDMA终端'
                   and td_termi_type = 'TD-SCDMA手机'
                   and capacity_flag = 1
                   and apply_month = '$PreMonthF'
                 group by case
                            when bt_fee < 500 then '其中：补贴0-500元的用户.'
                            when bt_fee >= 500 and bt_fee < 1000 then '补贴500-1000元的用户.'
                            when bt_fee >= 1000 and bt_fee < 2000 then '补贴1000-2000元的用户.'
                            when bt_fee >= 2000 and bt_fee < 3000 then '补贴2000-3000元的用户.'
                            else '补贴3000元以上的用户.'
                          end,
                          case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select stat_month,
                       'TD-SCDMA智能终端补贴.',
                       title_name,
                       sub_title_name,
                       busi_num
                  from $mTemp_Rpt_Zdmm326_1
                 where stat_month = '$PreMonthF'
                   and side_name = '		其中：TD-SCDMA智能手机'
                   and title_name in
                       ('本年累计终端补贴客户数（户）', '本年累计终端补贴金额（元）')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi


#2014/01/22 增加LTE内容
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                (stat_month, side_name, title_name, sub_title_name)
                select distinct '$PreMonthF',
                                '按照LTE手机的进货成本价划分',
                                '本年累计终端补贴客户数（户）',
                                case
                                  when bt_type = '成本类' then '其中：成本类补贴'
                                  else '其中：话费类补贴'
                                end
                  from (select distinct sub_id, imei, bt_type
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where apply_month = '$PreMonthF') as a
                 group by case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when buy_price < 1000 then '其中：1000元以下的LTE手机'
                         when buy_price >= 1000 and buy_price < 2000 then '1000-2000元的LTE手机'
                         when buy_price >= 2000 and buy_price < 3000 then '2000-3000元的LTE手机'
                         when buy_price >= 3000 then '3000元以上的LTE手机'
                       end,
                       '本年累计终端补贴客户数（户）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       count(*)
                  from (select distinct sub_id, imei, bt_type, buy_price
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'LTE终端'
                           and td_termi_type = 'LTE手机'
                           and apply_month = '$PreMonthF') as a
                 group by case
                            when buy_price < 1000 then '其中：1000元以下的LTE手机'
                            when buy_price >= 1000 and buy_price < 2000 then '1000-2000元的LTE手机'
                            when buy_price >= 2000 and buy_price < 3000 then '2000-3000元的LTE手机'
                            when buy_price >= 3000 then '3000元以上的LTE手机'
                          end,
                          case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when buy_price < 1000 then '其中：1000元以下的LTE手机'
                         when buy_price >= 1000 and buy_price < 2000 then '1000-2000元的LTE手机'
                         when buy_price >= 2000 and buy_price < 3000 then '2000-3000元的LTE手机'
                         when buy_price >= 3000 then '3000元以上的LTE手机'
                       end,
                       '本年累计终端补贴客户数（户）',
                       '合计',
                       count(*)
                  from (select distinct sub_id, imei, buy_price
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'LTE终端'
                           and td_termi_type = 'LTE手机'
                           and apply_month = '$PreMonthF') as a
                 group by case
                            when buy_price < 1000 then '其中：1000元以下的LTE手机'
                            when buy_price >= 1000 and buy_price < 2000 then '1000-2000元的LTE手机'
                            when buy_price >= 2000 and buy_price < 3000 then '2000-3000元的LTE手机'
                            when buy_price >= 3000 then '3000元以上的LTE手机'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when buy_price < 1000 then '其中：1000元以下的LTE手机'
                         when buy_price >= 1000 and buy_price < 2000 then '1000-2000元的LTE手机'
                         when buy_price >= 2000 and buy_price < 3000 then '2000-3000元的LTE手机'
                         when buy_price >= 3000 then '3000元以上的LTE手机'
                       end,
                       '本年累计终端补贴金额（元）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       sum(bt_fee)
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where termi_type = 'LTE终端'
                   and td_termi_type = 'LTE手机'
                   and apply_month = '$PreMonthF'
                 group by case
                            when buy_price < 1000 then '其中：1000元以下的LTE手机'
                            when buy_price >= 1000 and buy_price < 2000 then '1000-2000元的LTE手机'
                            when buy_price >= 2000 and buy_price < 3000 then '2000-3000元的LTE手机'
                            when buy_price >= 3000 then '3000元以上的LTE手机'
                          end,
                          case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select stat_month, 'LTE手机终端补贴', title_name, sub_title_name, busi_num
                  from $mTemp_Rpt_Zdmm326_1
                 where stat_month = '$PreMonthF'
                   and side_name = 'LTE手机'
                   and title_name in
                       ('本年累计终端补贴客户数（户）', '本年累计终端补贴金额（元）')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi


if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                (stat_month, side_name, title_name, sub_title_name)
                select distinct '$PreMonthF',
                                '按照LTE手机补贴金额划分',
                                '本年累计终端补贴客户数（户）',
                                case
                                  when bt_type = '成本类' then '其中：成本类补贴'
                                  else '其中：话费类补贴'
                                end
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where apply_month = '$PreMonthF'
                 group by case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       bt_level,
                       '本年累计终端补贴客户数（户）',
                       case
                         when bt_type = '成本类' then
                          '其中：成本类补贴'
                         else
                          '其中：话费类补贴'
                       end,
                       count(*)
                  from (select distinct sub_id,
                                        imei,
                                        bt_type,
                                        case
                                          when bt_fee < 500 then
                                           '其中：补贴0-500元的用户..'
                                          when bt_fee >= 500 and bt_fee < 1000 then
                                           '补贴500-1000元的用户..'
                                          when bt_fee >= 1000 and bt_fee < 2000 then
                                           '补贴1000-2000元的用户..'
                                          when bt_fee >= 2000 and bt_fee < 3000 then
                                           '补贴2000-3000元的用户..'
                                          else
                                           '补贴3000元以上的用户..'
                                        end as Bt_Level
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'LTE终端'
                           and td_termi_type = 'LTE手机'
                           and apply_month = '$PreMonthF')
                 group by bt_level,
                          case
                            when bt_type = '成本类' then
                             '其中：成本类补贴'
                            else
                             '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       bt_level,
                       '本年累计终端补贴客户数（户）',
                       '合计',
                       count(*)
                  from (select distinct sub_id,
                                        imei,
                                        case
                                          when bt_fee < 500 then
                                           '其中：补贴0-500元的用户..'
                                          when bt_fee >= 500 and bt_fee < 1000 then
                                           '补贴500-1000元的用户..'
                                          when bt_fee >= 1000 and bt_fee < 2000 then
                                           '补贴1000-2000元的用户..'
                                          when bt_fee >= 2000 and bt_fee < 3000 then
                                           '补贴2000-3000元的用户..'
                                          else
                                           '补贴3000元以上的用户..'
                                        end as Bt_Level
                          from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                         where termi_type = 'LTE终端'
                           and td_termi_type = 'LTE手机'
                           and apply_month = '$PreMonthF') as a
                 group by bt_level" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       case
                         when bt_fee < 500 then '其中：补贴0-500元的用户..'
                         when bt_fee >= 500 and bt_fee < 1000 then '补贴500-1000元的用户..'
                         when bt_fee >= 1000 and bt_fee < 2000 then '补贴1000-2000元的用户..'
                         when bt_fee >= 2000 and bt_fee < 3000 then '补贴2000-3000元的用户..'
                         else '补贴3000元以上的用户..'
                       end,
                       '本年累计终端补贴金额（元）',
                       case
                         when bt_type = '成本类' then '其中：成本类补贴'
                         else '其中：话费类补贴'
                       end,
                       sum(bt_fee)
                  from $Rpt_Zdmm326_Termi_User_Detail_$PreMonthinYear
                 where termi_type = 'LTE终端'
                   and td_termi_type =  'LTE手机'
                   and apply_month = '$PreMonthF'
                 group by case
                            when bt_fee < 500 then '其中：补贴0-500元的用户..'
                            when bt_fee >= 500 and bt_fee < 1000 then '补贴500-1000元的用户..'
                            when bt_fee >= 1000 and bt_fee < 2000 then '补贴1000-2000元的用户..'
                            when bt_fee >= 2000 and bt_fee < 3000 then '补贴2000-3000元的用户..'
                            else '补贴3000元以上的用户..'
                          end,
                          case
                            when bt_type = '成本类' then '其中：成本类补贴'
                            else '其中：话费类补贴'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select stat_month,
                       'LTE手机终端补贴.',
                       title_name,
                       sub_title_name,
                       busi_num
                  from $mTemp_Rpt_Zdmm326_1
                 where stat_month = '$PreMonthF'
                   and side_name = 'LTE手机'
                   and title_name in
                       ('本年累计终端补贴客户数（户）', '本年累计终端补贴金额（元）')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi


#提取合计部分
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select stat_month, side_name, title_name, '合计', sum(busi_num)
                  from $mTemp_Rpt_Zdmm326_1
                 where stat_month = '$PreMonthF'
                   and title_name = '本年累计终端补贴金额（元）'
                 group by stat_month, side_name, title_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select '$PreMonthF',
                       '其中：终端公司',
                       title_name,
                       sub_title_name,
                       busi_num
                  from $mTemp_Rpt_Zdmm326_1
                 where stat_month = '$PreMonthF'
                   and side_name = '合计'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
                select distinct '$PreMonthF', '非终端公司', title_name, sub_title_name, 0
                  from $mTemp_Rpt_Zdmm326_1
                 where stat_month = '$PreMonthF'
                   and side_name = '合计'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi

#生成终端补贴一报表结果,加入以往月数据
WriteStatusFile 1 9 $$ $StatusFile
if ! DB2_Check 0 1 0 "" $Rpt_Zdmm326_1 "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Zdmm326_1(
	              STAT_MONTH       VARCHAR(10),
	              SIDE_NAME        VARCHAR(50),
	              TITLE_NAME       VARCHAR(40),
	              SUB_TITLE_NAME   VARCHAR(40),
	              BUSI_NUM         BIGINT
	              ) data capture none in $TableSpace partitioning key(stat_month) using hashing" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
#报表每年一累
if [ $PreMonthN -gt 1 ]
then
	if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_1
	                select '$PreMonthF',
	                       case
	                         when side_name = 'TD终端' then
	                          'TD-SCDMA终端'
	                         when side_name = 'TD手机' then
	                          'TD-SCDMA手机'
	                         when side_name like '%其中：TD智能手机' then
	                          '		其中：TD-SCDMA智能手机'
	                         when side_name = 'TD无线座机' then
	                          'TD-SCDMA无线座机'
	                         when side_name = 'TD上网卡（含上网本）' then
	                          'TD-SCDMA上网卡（含上网本）'
	                         when side_name = 'TD手机终端补贴' then
	                          'TD-SCDMA手机终端补贴'
	                         when side_name = 'TD手机终端补贴.' then
	                          'TD-SCDMA手机终端补贴.'
	                         when side_name = 'TD智能终端补贴' then
	                          'TD-SCDMA智能终端补贴'
	                         when side_name = 'TD智能终端补贴.' then
	                          'TD-SCDMA智能终端补贴.'
	                         when side_name = '按照TD手机的进货成本价划分' then
	                          '按照TD-SCDMA手机的进货成本价划分'
	                         when side_name = '按照TD手机补贴金额划分' then
	                          '按照TD-SCDMA手机补贴金额划分'
	                         when side_name = '其中：1000元以下的TD手机' then
	                          '其中：1000元以下的TD-SCDMA手机'
	                         when side_name = '其中：1000元以下的TD手机.' then
	                          '其中：1000元以下的TD-SCDMA手机.'
	                         when side_name = '1000-2000元的TD手机' then
	                          '1000-2000元的TD-SCDMA手机'
	                         when side_name = '1000-2000元的TD手机.' then
	                          '1000-2000元的TD-SCDMA手机.'
	                         when side_name = '2000-3000元的TD手机' then
	                          '2000-3000元的TD-SCDMA手机'
	                         when side_name = '2000-3000元的TD手机.' then
	                          '2000-3000元的TD-SCDMA手机.'
	                         when side_name = '3000元以上的TD手机' then
	                          '3000元以上的TD-SCDMA手机'
	                         when side_name = '3000元以上的TD手机.' then
	                          '3000元以上的TD-SCDMA手机.'
	                         else
	                          side_name
	                       end as side_name,
	                       title_name,
	                       sub_title_name,
	                       busi_num
	                  from $Rpt_Zdmm326_1
	                 where stat_month = '$Pre2MonthF'" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "runstats on table $mTemp_Rpt_Zdmm326_1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "delete from $Rpt_Zdmm326_1 where stat_month='$PreMonthF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Zdmm326_1
                select '$PreMonthF', side_name, title_name, sub_title_name, sum(busi_num)
                  from $mTemp_Rpt_Zdmm326_1
                 group by side_name, title_name, sub_title_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Zdmm326_1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi

#终端补贴二
WriteStatusFile 1 10 $$ $StatusFile
if ! DB2_Cmd "create table $mTemp_Rpt_Zdmm326_2(
              stat_month     varchar(10),
              consume_id     integer,
              side_name      varchar(50),
              title_name     varchar(40),
              sub_title_name varchar(40),
              busi_num       bigint
              ) in $TableSpace partitioning key(stat_month) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Rpt_Zdmm326_2 activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2 select '$PreMonthF', 1, '合计', '本年累计终端补贴客户', '客户数（户）', count(sub_id) from $mTemp_Zdmm326_Termi_User_Detail_Fee" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2 select '$PreMonthF', 1, '合计', '本年累计终端补贴客户', '账单收入（元）', sum(total_fee) from $mTemp_Zdmm326_Termi_User_Detail_Fee" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       1,
                       '合计',
                       case
                         when termi_type = 'TD-SCDMA终端' then 'TD终端合计'
                         when termi_type = 'LTE终端' then 'LTE终端合计'
                         else '2G终端合计'
                       end,
                       '客户数（户）',
                       count(sub_id)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 group by case
                            when termi_type = 'TD-SCDMA终端' then 'TD终端合计'
                            when termi_type = 'LTE终端' then 'LTE终端合计'
                            else '2G终端合计'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       1,
                       '合计',
                       case
                         when termi_type = 'TD-SCDMA终端' then 'TD终端合计'
                         when termi_type = 'LTE终端' then 'LTE终端合计'
                         else '2G终端合计'
                       end,
                       '账单收入（元）',
                       sum(total_fee)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 group by case
                            when termi_type = 'TD-SCDMA终端' then 'TD终端合计'
                            when termi_type = 'LTE终端' then 'LTE终端合计'
                            else '2G终端合计'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       1,
                       '合计',
                       case
                         when td_termi_type = 'TD-SCDMA手机' then '其中：TD手机'
                         when td_termi_type = 'TD-SCDMA无线座机' then '其中：TD无线座机'
                         else '其中：TD上网卡'
                       end,
                       '客户数（户）',
                       count(sub_id)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'TD-SCDMA终端'
                 group by case
                            when td_termi_type = 'TD-SCDMA手机' then '其中：TD手机'
                            when td_termi_type = 'TD-SCDMA无线座机' then '其中：TD无线座机'
                            else '其中：TD上网卡'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       1,
                       '合计',
                       case
                         when td_termi_type = 'TD-SCDMA手机' then '其中：TD手机'
                         when td_termi_type = 'TD-SCDMA无线座机' then '其中：TD无线座机'
                         else '其中：TD上网卡'
                       end,
                       '账单收入（元）',
                       sum(total_fee)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'TD-SCDMA终端'
                 group by case
                            when td_termi_type = 'TD-SCDMA手机' then '其中：TD手机'
                            when td_termi_type =  'TD-SCDMA无线座机' then '其中：TD无线座机'
                            else '其中：TD上网卡'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       consume_id,
                       consume_name,
                       '本年累计终端补贴客户',
                       '客户数（户）',
                       count(sub_id)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 group by consume_id, consume_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       consume_id,
                       consume_name,
                       '本年累计终端补贴客户',
                       '账单收入（元）',
                       sum(total_fee)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 group by consume_id, consume_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       consume_id,
                       consume_name,
                       case
                         when termi_type = 'TD-SCDMA终端' then 'TD终端合计'
                         when termi_type = 'LTE终端' then 'LTE终端合计'
                         else '2G终端合计'
                       end,
                       '客户数（户）',
                       count(sub_id)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 group by case
                            when termi_type = 'TD-SCDMA终端' then 'TD终端合计'
                            when termi_type = 'LTE终端' then 'LTE终端合计'
                            else '2G终端合计'
                          end,
                          consume_id,
                          consume_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       consume_id,
                       consume_name,
                       case
                         when termi_type = 'TD-SCDMA终端' then 'TD终端合计'
                         when termi_type = 'LTE终端' then 'LTE终端合计'
                         else '2G终端合计'
                       end,
                       '账单收入（元）',
                       sum(total_fee)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 group by case
                            when termi_type = 'TD-SCDMA终端' then 'TD终端合计'
                            when termi_type = 'LTE终端' then 'LTE终端合计'
                            else '2G终端合计'
                          end,
                          consume_id,
                          consume_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       consume_id,
                       consume_name,
                       case
                         when td_termi_type = 'TD-SCDMA手机' then '其中：TD手机'
                         when td_termi_type = 'TD-SCDMA无线座机' then '其中：TD无线座机'
                         else '其中：TD上网卡'
                       end,
                       '客户数（户）',
                       count(sub_id)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'TD-SCDMA终端'
                 group by case
                            when td_termi_type = 'TD-SCDMA手机' then '其中：TD手机'
                            when td_termi_type = 'TD-SCDMA无线座机' then '其中：TD无线座机'
                            else '其中：TD上网卡'
                          end,
                          consume_id,
                          consume_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       consume_id,
                       consume_name,
                       case
                         when td_termi_type = 'TD-SCDMA手机' then
                          '其中：TD手机'
                         when td_termi_type = 'TD-SCDMA无线座机' then
                          '其中：TD无线座机'
                         else
                          '其中：TD上网卡'
                       end,
                       '账单收入（元）',
                       sum(total_fee)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'TD-SCDMA终端'
                 group by case
                            when td_termi_type = 'TD-SCDMA手机' then
                             '其中：TD手机'
                            when td_termi_type = 'TD-SCDMA无线座机' then
                             '其中：TD无线座机'
                            else
                             '其中：TD上网卡'
                          end,
                          consume_id,
                          consume_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       consume_id,
                       consume_name,
                       '其中：TD智能手机',
                       '客户数（户）',
                       count(sub_id)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'TD-SCDMA终端'
                   and td_termi_type = 'TD-SCDMA手机'
                   and capacity_flag = 1
                 group by consume_id, consume_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       consume_id,
                       consume_name,
                       '其中：TD智能手机',
                       '账单收入（元）',
                       sum(total_fee)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'TD-SCDMA终端'
                   and td_termi_type = 'TD-SCDMA手机'
                   and capacity_flag = 1
                 group by consume_id, consume_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       1,
                       '合计',
                       '其中：TD智能手机',
                       '客户数（户）',
                       count(sub_id)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'TD-SCDMA终端'
                   and td_termi_type = 'TD-SCDMA手机'
                   and capacity_flag = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       1,
                       '合计',
                       '其中：TD智能手机',
                       '账单收入（元）',
                       sum(total_fee)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'TD-SCDMA终端'
                   and td_termi_type = 'TD-SCDMA手机'
                   and capacity_flag = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi

#2014/01/22 增加LTE
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       1,
                       '合计',
                       case
                         when td_termi_type = 'LTE手机' then '其中：LTE手机'
                         when td_termi_type = 'LTE数据卡' then '其中：LTE数据卡'
                         when td_termi_type = 'LTE-MIFI' then '其中：LTE-MIFI'
                         when td_termi_type = 'LTE-CPE' then '其中：LTE-CPE'
                       end,
                       '客户数（户）',
                       count(sub_id)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'LTE终端'
                 group by case
                            when td_termi_type = 'LTE手机' then '其中：LTE手机'
                            when td_termi_type = 'LTE数据卡' then '其中：LTE数据卡'
                            when td_termi_type = 'LTE-MIFI' then '其中：LTE-MIFI'
                            when td_termi_type = 'LTE-CPE' then '其中：LTE-CPE'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       1,
                       '合计',
                       case
                         when td_termi_type = 'LTE手机' then '其中：LTE手机'
                         when td_termi_type = 'LTE数据卡' then '其中：LTE数据卡'
                         when td_termi_type = 'LTE-MIFI' then '其中：LTE-MIFI'
                         when td_termi_type = 'LTE-CPE' then '其中：LTE-CPE'
                       end,
                       '账单收入（元）',
                       sum(total_fee)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'LTE终端'
                 group by case
                            when td_termi_type = 'LTE手机' then '其中：LTE手机'
                            when td_termi_type = 'LTE数据卡' then '其中：LTE数据卡'
                            when td_termi_type = 'LTE-MIFI' then '其中：LTE-MIFI'
                            when td_termi_type = 'LTE-CPE' then '其中：LTE-CPE'
                          end" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       consume_id,
                       consume_name,
                       case
                         when td_termi_type = 'LTE手机' then '其中：LTE手机'
                         when td_termi_type = 'LTE数据卡' then '其中：LTE数据卡'
                         when td_termi_type = 'LTE-MIFI' then '其中：LTE-MIFI'
                         when td_termi_type = 'LTE-CPE' then '其中：LTE-CPE'
                       end,
                       '客户数（户）',
                       count(sub_id)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'LTE终端'
                 group by case
                            when td_termi_type = 'LTE手机' then '其中：LTE手机'
                            when td_termi_type = 'LTE数据卡' then '其中：LTE数据卡'
                            when td_termi_type = 'LTE-MIFI' then '其中：LTE-MIFI'
                            when td_termi_type = 'LTE-CPE' then '其中：LTE-CPE'
                          end,
                          consume_id,
                          consume_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Rpt_Zdmm326_2
                select '$PreMonthF',
                       consume_id,
                       consume_name,
                       case
                         when td_termi_type = 'LTE手机' then '其中：LTE手机'
                         when td_termi_type = 'LTE数据卡' then '其中：LTE数据卡'
                         when td_termi_type = 'LTE-MIFI' then '其中：LTE-MIFI'
                         when td_termi_type = 'LTE-CPE' then '其中：LTE-CPE'
                       end,
                       '账单收入（元）',
                       sum(total_fee)
                  from $mTemp_Zdmm326_Termi_User_Detail_Fee
                 where termi_type = 'LTE终端'
                 group by case
                            when td_termi_type = 'LTE手机' then '其中：LTE手机'
                            when td_termi_type = 'LTE数据卡' then '其中：LTE数据卡'
                            when td_termi_type = 'LTE-MIFI' then '其中：LTE-MIFI'
                            when td_termi_type = 'LTE-CPE' then '其中：LTE-CPE'
                          end,
                          consume_id,
                          consume_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi

if ! DB2_Cmd "runstats on table $mTemp_Rpt_Zdmm326_2" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi

#生成报表结果数据
WriteStatusFile 1 11 $$ $StatusFile
if ! DB2_Check 0 1 0 "" $Rpt_Zdmm326_2 "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Zdmm326_2(
	              STAT_MONTH       VARCHAR(10),
	              CONSUME_ID       INTEGER,
	              SIDE_NAME        VARCHAR(50),
	              TITLE_NAME       VARCHAR(40),
	              SUB_TITLE_NAME   VARCHAR(40),
	              BUSI_NUM         BIGINT
	              ) data capture none in $TableSpace partitioning key(stat_month) using hashing" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "delete from $Rpt_Zdmm326_2 where stat_month='$PreMonthF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Zdmm326_2
                select '$PreMonthF',
                       consume_id,
                       side_name,
                       title_name,
                       sub_title_name,
                       sum(busi_num)
                  from $mTemp_Rpt_Zdmm326_2
                 group by consume_id, side_name, title_name, sub_title_name" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#强制增加离网项，确保excel生成时不缺内容
if ! DB2_Cmd "insert into $Rpt_Zdmm326_2
                select stat_month,
                       consume_id,
                       side_name,
                       title_name,
                       sub_title_name,
                       busi_num
                  from (select count(*) as Cnt,
                               '$PreMonthF' as Stat_Month,
                               -1 as Consume_Id,
                               '离网' as Side_Name,
                               '其中：LTE手机' as Title_Name,
                               '客户数（户）' as Sub_Title_Name,
                               null as Busi_Num
                          from $Rpt_Zdmm326_2
                         where side_name like '%离%'
                           and title_name like '%LTE%'
                           and stat_month = '$PreMonthF')
                 where cnt = 0" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Zdmm326_2
                select stat_month,
                       consume_id,
                       side_name,
                       title_name,
                       sub_title_name,
                       busi_num
                  from (select count(*) as Cnt,
                               '$PreMonthF' as Stat_Month,
                               -1 as Consume_Id,
                               '离网' as Side_Name,
                               'TD终端合计' as Title_Name,
                               '客户数（户）' as Sub_Title_Name,
                               null as Busi_Num
                          from $Rpt_Zdmm326_2
                         where side_name like '%离%'
                           and title_name like '%TD%'
                           and stat_month = '$PreMonthF')
                 where cnt = 0" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Zdmm326_2" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
DB2_Truncate $mTemp_Zdmm326_Termi_User_Detail_Fee "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Zdmm326_Termi_User_Detail_Fee "$LogFile"-`date +%Y%m%d`
DB2_Truncate $mTemp_Rpt_Zdmm326_2 "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Rpt_Zdmm326_2 "$LogFile"-`date +%Y%m%d`


#生成Excel文件
WriteStatusFile 1 100 $$ $StatusFile
if [ ! -d "`dirname \"$ResultFile_Terminal_Subsidy_1\"`" ]
then
	mkdir -p "`dirname \"$ResultFile_Terminal_Subsidy_1\"`"
fi
if [ -f "$ResultFile_Terminal_Subsidy_1" ]
then
	chmod 644 "$ResultFile_Terminal_Subsidy_1" "$ResultFile_Terminal_Subsidy_2" "$ResultFile_Terminal_Subsidy_3"
	rm -f "$ResultFile_Terminal_Subsidy_1" "$ResultFile_Terminal_Subsidy_2" "$ResultFile_Terminal_Subsidy_3"
fi
TmpFile=`echo "$ResultFile_Terminal_Subsidy_1" | awk -F\. -v OFS="." '{if (NF>1) $NF="txt"; else $0=$0".txt"; print $0}'`

#由于编译perl的DBI接口驱动有点问题，暂时采用导出语句
rm -f "$TmpFile-1" "$TmpFile-2" "$TmpFile-3"
if ! DB2_Dump 0 0 "$TmpFile-1" "select * from $Rpt_Zdmm326_1 where stat_month='$PreMonthF' order by side_name,title_name,sub_title_name" "$LogFile"-`date +%Y%m%d` 0 1
then
	exit 1
fi
chmod 444 "$TmpFile-1"
if ! DB2_Dump 0 0 "$TmpFile-2" "select stat_month,case when consume_id=-1 then 1.5 else consume_id end as Consume_Id,side_name,title_name,sub_title_name,busi_num from $Rpt_Zdmm326_2 a where stat_month='$PreMonthF' and title_name not like '%LTE%' order by case when a.consume_id=-1 then 1.5 else a.consume_id end" "$LogFile"-`date +%Y%m%d` 0 1
then
	exit 1
fi
chmod 444 "$TmpFile-2"
if ! DB2_Dump 0 0 "$TmpFile-3" "select stat_month,case when consume_id=-1 then 1.5 else consume_id end as Consume_Id,side_name,title_name,sub_title_name,busi_num from $Rpt_Zdmm326_2 a where stat_month='$PreMonthF' and title_name like '%LTE%' order by case when a.consume_id=-1 then 1.5 else a.consume_id end" "$LogFile"-`date +%Y%m%d` 0 1
then
	exit 1
fi
chmod 444 "$TmpFile-3"

#输出结果
printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s begin to create excel ... " " "
printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s 开始生成报表 ... " " " >> "$LogFile"-`date +%Y%m%d`
if perl $PerlPath/Term_Subsidy.pl $PreMonthF "$TmpFile" "$ResultFile_Terminal_Subsidy_1" "$ResultFile_Terminal_Subsidy_2" "$ResultFile_Terminal_Subsidy_3" "$LogFile"-`date +%Y%m%d`
then
	if [ -f "$ResultFile_Terminal_Subsidy_1" ]
	then
		chmod 644 "$TmpFile-1" "$TmpFile-2" "$TmpFile-3"
		rm -f "$TmpFile-1" "$TmpFile-2" "$TmpFile-3"
		chmod 400 "$ResultFile_Terminal_Subsidy_1" "$ResultFile_Terminal_Subsidy_2" "$ResultFile_Terminal_Subsidy_3"
		printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Report [%s], [%s] and [%s] have be made!" " " "$ResultFile_Terminal_Subsidy_1" "$ResultFile_Terminal_Subsidy_2" "$ResultFile_Terminal_Subsidy_3"
		printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s 报表[%s], [%s]和[%s]已生成成功!" " " "$ResultFile_Terminal_Subsidy_1" "$ResultFile_Terminal_Subsidy_2" "$ResultFile_Terminal_Subsidy_3" >> "$LogFile"-`date +%Y%m%d`
		WriteStatusFile 0 0 $$ $StatusFile
	fi
else
	rm -f "$ResultFile_Terminal_Subsidy_1" "$ResultFile_Terminal_Subsidy_2" "$ResultFile_Terminal_Subsidy_3"
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Report [%s], [%s] or [%s] was be made failed!!!" " " "$ResultFile_Terminal_Subsidy_1" "$ResultFile_Terminal_Subsidy_2" "$ResultFile_Terminal_Subsidy_3"
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s 报表[%s], [%s] 或[%s]生成失败!!!" " " "$ResultFile_Terminal_Subsidy_1" "$ResultFile_Terminal_Subsidy_2" "$ResultFile_Terminal_Subsidy_3" >> "$LogFile"-`date +%Y%m%d`
fi

