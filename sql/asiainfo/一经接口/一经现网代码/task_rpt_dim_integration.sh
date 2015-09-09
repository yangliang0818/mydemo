#!/data/rpt/changtaihua_shell/bin/bash

#报表名称:经分财报终端维表集成
#报表类型:上报集团类报表
#统计周期:每月5日
#梗概:
#内容:集中将不依赖DW层表的数据汇总成相应维表：
#     1、渠道组织维表
#     2、终端类型维表
#     3、智能终端维表（月）
#     4、终端IMEI与规格映射表
#     5、铁通帐户表
#     6、帐户套餐映射表（月）


#作者:      刘涛
#创建时间:  2014/03/03
#修改时间:  2015/03/05
#SQL提供者: 刘涛


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
DefaultProfile=../cfg/finance-common.cfg        #缺省预装配置文件
IncludePath=../include                          #外部函数路径
MsgMaxLen=1024                                  #消息文本最大长度
NormalAccDate=3                                 #表示允许1-3号出账
SimulatedDate=10                                #表示模拟出账的最开始时间
TempTablePrefix=Temp_Fetch_                     #临时表变量，进程退出时全量删除

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
#检查消息文件目录是否存在
MsgDir=`dirname "${ResultFile_NewMsg}"`
if [ ! -d "$MsgDir" ]
then
	mkdir -p "$MsgDir"
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
WriteStatusFile 2 0 $$ $StatusFile "" "集中维表程序启动……"





#数据库连接
WriteStatusFile 1 1 $$ $StatusFile "" "开始数据库连接……"
if ! DB2_Connect $DB2_User $DB2_Password $DB2_Instance "$LogFile"-`date +%Y%m%d`
then
  exit 1
fi





#总体检查表
WriteStatusFile 1 2 $$ $StatusFile "" "检查依赖表……"
if ! DB2_Check 0 3 0 0 "${TOds_Bass1_91003_}$PreMonthF,${TOds_Bass1_91002_}$PreMonthF,${TDim_Brandname_Typename_Baseinfo},${TDwd_Svc_Usr_Info_Des_Dm_}$YearBeforePreMonth,${TDwd_Svc_Usr_Info_Des_Dm_}$PreMonthinYear" "" "" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#if ! DB2_Check 0 3 2 3 "" "" "$miExecMonthF-01 00:00:00" "$LogFile"-`date +%Y%m%d`
#then
#	exit 1
#fi
if ! DB2_Check 0 3 3 3 "${TOds_Channel_Node_New_}$PreMonthF,${TOds_Channel_Node_}$PreMonthF,${TOds_Channel_Node_Extinfo_Self_}$PreMonthF,${TOds_Channel_Entity_Basic_Info_New_}$PreMonthF,${TOds_Channel_Entity_Basic_Info_}$PreMonthF,${TOds_Channel_Entity_Rel_Info_New_}$PreMonthF,${TOds_Channel_Entity_Rel_Info_}$PreMonthF,${TOds_Channel_Agent_Info_New_}$PreMonthF,${TOds_Channel_Agent_Info_}$PreMonthF,${TOds_Channel_Agent_Extinfo_}$PreMonthF,${TOds_Channel_Man_Check_}$PreMonthF,${TOds_Channel_Sys_Base_Type_New_}$PreMonthF,${TOds_Channel_Org_Agent_New_}$PreMonthF,${TOds_Channel_Org_Agent_}$PreMonthF,${TOds_Res_Terminal_Origin_}$PreMonthF,${TOds_Res_Spec_}$PreMonthF,${TOds_Res_Terminal_Used_}$PreMonthF,${TDim_Imei_Termi},${TDim_Termi_Base},${TDwd_Svc_Usr_All_Info_}$PreMonthF,${TOds_Crm_Up_Product_Item_}$PreMonthF,${TOds_Ins_Prod_}$PreMonthF" "" "$miExecMonthF-01 00:00:00" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Check 0 3 3 3 "${TDim_Prty_Oper_Info},${TOds_Db_Ap_Atm_Pcsettingext_}$PreDayF,${TOds_Term_}$PreDayF,${TDim_Prty_Org_Info},${TDim_Svc_Prod},${TOds_Crm_Up_Item_Relat_}$PreDayF" "" "$miExecDayF 00:00:00" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi





#建立组织机构维表临时表
WriteStatusFile 1 3 $$ $StatusFile "" "建立组织机构维表临时表……"
#兜取所有网点信息
if DB2_Check 0 1 0 "" $mTemp_Channel_Node "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Channel_Node "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Channel_Node "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Channel_Node(
              node_id             bigint,
              node_kind           smallint,
              second_node_kind    smallint,
              node_type           smallint,
              node_level          smallint,
              operate_type        smallint,
              valid_date          timestamp,
              expire_date         timestamp,
              node_addr           varchar(255),
              business_start_date timestamp,
              done_date           timestamp,
              done_code           varchar(21),
              rec_status          smallint,
              seq_no              smallint
              ) in $TableSpace partitioning key(node_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Channel_Node activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#按新模型插入渠道网点信息
if ! DB2_Cmd "insert into $mTemp_Channel_Node
                select *
                  from (select node_id,
                               node_kind,
                               second_node_kind,
                               node_type,
                               node_level,
                               null as Operate_Type,
                               valid_date,
                               expire_date,
                               node_addr,
                               business_start_date,
                               done_date,
                               done_code,
                               rec_status,
                               row_number() over(partition by node_id order by done_date desc, done_code desc,case
                                 when rec_status = 1 then
                                  1
                                 else
                                  nvl(rec_status,
                                      1000) + 99
                               end) as Seq_No
                          from ${TOds_Channel_Node_New_}$PreMonthF)
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#支撑老模型
if DB2_Check 0 3 3 3 "${TOds_Channel_Node_}$PreMonthF" "" "$miExecMonthF-01 00:00:00" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "insert into $mTemp_Channel_Node
	                select a.*
	                  from (select node_id,
	                               null as Node_Kind,
	                               null as Second_Node_Kind,
	                               node_type,
	                               node_level,
	                               operate_type,
	                               valid_date,
	                               expire_date,
	                               node_addr,
	                               business_start_date,
	                               done_date,
	                               done_code,
	                               rec_status,
	                               row_number() over(partition by node_id order by done_date desc, done_code desc,case
	                                 when rec_status = 1 then
	                                  1
	                                 else
	                                  nvl(rec_status,
	                                      1000) + 99
	                               end) as Seq_No
	                          from ${TOds_Channel_Node_}$PreMonthF) a
	                  left join $mTemp_Channel_Node b
	                    on a.node_id = b.node_id
	                 where a.seq_no = 1
	                   and b.node_id is null" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "runstats on table $mTemp_Channel_Node" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#兜取所有网点扩展信息
if DB2_Check 0 1 0 "" $mTemp_Node_Extinfo "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Node_Extinfo "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Node_Extinfo "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Node_Extinfo(
              node_id    bigint,
              rec_status smallint,
              seq_no     smallint
              ) in $TableSpace partitioning key(node_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Node_Extinfo activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#按新模型插入渠道网点扩展信息
if ! DB2_Cmd "insert into $mTemp_Node_Extinfo
                select *
                  from (select node_id,
                               rec_status,
                               row_number() over(partition by node_id order by done_date desc, done_code desc,case
                                 when rec_status = 1 then
                                  1
                                 else
                                  nvl(rec_status,
                                      1000) + 99
                               end) as Seq_No
                          from ${TOds_Channel_Node_Extinfo_Self_}$PreMonthF)
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#支撑老模型
if DB2_Check 0 3 3 3 "${TOds_Channel_Node_Extinfo_Self_Transform_}$PreMonthF" "" "$miExecMonthF-01 00:00:00" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "insert into $mTemp_Node_Extinfo
	                select a.*
	                  from (select node_id,
	                               rec_status,
	                               row_number() over(partition by node_id order by done_date desc, done_code desc,case
	                                 when rec_status = 1 then
	                                  1
	                                 else
	                                  nvl(rec_status,
	                                      1000) + 99
	                               end) as Seq_No
	                          from ${TOds_Channel_Node_Extinfo_Self_Transform_}$PreMonthF) a
	                  left join $mTemp_Node_Extinfo b
	                    on a.node_id = b.node_id
	                 where a.seq_no = 1
	                   and b.node_id is null" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "runstats on table $mTemp_Node_Extinfo" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#兜取所有实体信息
if DB2_Check 0 1 0 "" $mTemp_Entity_Basic "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Entity_Basic "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Entity_Basic "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Entity_Basic(
              channel_entity_id     integer,
              channel_entity_name   varchar(128),
              channel_entity_status smallint,
              channel_entity_type   smallint,
              district_id           smallint,
              create_date           timestamp,
              channel_entity_serial varchar(32),
              done_code             varchar(21),
              done_date             timestamp,
              rec_status            smallint,
              seq_no                smallint
              ) in $TableSpace partitioning key(channel_entity_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Entity_Basic activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#按新模型插入渠道实体基础信息
if ! DB2_Cmd "insert into $mTemp_Entity_Basic
                select *
                  from (select channel_entity_id,
                               channel_entity_name,
                               channel_entity_status,
                               channel_entity_type,
                               district_id,
                               create_date,
                               channel_entity_serial,
                               done_code,
                               done_date,
                               rec_status,
                               row_number() over(partition by channel_entity_id order by done_date desc, done_code desc,case
                                 when rec_status = 1 then
                                  1
                                 else
                                  nvl(rec_status,
                                      1000) + 99
                               end, create_date desc) as Seq_No
                          from ${TOds_Channel_Entity_Basic_Info_New_}$PreMonthF)
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#支撑老模型
if DB2_Check 0 3 3 3 "${TOds_Channel_Entity_Basic_Info_}$PreMonthF" "" "$miExecMonthF-01 00:00:00" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "insert into $mTemp_Entity_Basic
	                select a.*
	                  from (select channel_entity_id,
	                               channel_entity_name,
	                               channel_entity_status,
	                               channel_entity_type,
	                               district_id,
	                               done_date as Create_Date,
	                               channel_entity_serial,
	                               done_code,
	                               done_date,
	                               rec_status,
	                               row_number() over(partition by channel_entity_id order by done_date desc, done_code desc,case
	                                 when rec_status = 1 then
	                                  1
	                                 else
	                                  nvl(rec_status,
	                                      1000) + 99
	                               end, done_date desc) as Seq_No
	                          from ${TOds_Channel_Entity_Basic_Info_}$PreMonthF) a
	                  left join $mTemp_Entity_Basic b
	                    on a.channel_entity_id = b.channel_entity_id
	                 where a.seq_no = 1
	                   and b.channel_entity_id is null" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "runstats on table $mTemp_Entity_Basic" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#兜取所有实体关系
if DB2_Check 0 1 0 "" $mTemp_Entity_Rel "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Entity_Rel "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Entity_Rel "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Entity_Rel(
              channel_entity_id integer,
              parent_entity     integer,
              rec_status        smallint,
              seq_no            smallint
              ) in $TableSpace partitioning key(channel_entity_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Entity_Rel activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#按新模型插入渠道实体基础信息
if ! DB2_Cmd "insert into $mTemp_Entity_Rel
                select *
                  from (select channel_entity_id,
                               parent_entity,
                               rec_status,
                               row_number() over(partition by channel_entity_id order by done_date desc, done_code desc,case
                                 when rec_status = 1 then
                                  1
                                 else
                                  nvl(rec_status,
                                      1000) + 99
                               end) as Seq_No
                          from ${TOds_Channel_Entity_Rel_Info_New_}$PreMonthF)
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#支撑老模型
if DB2_Check 0 3 3 3 "${TOds_Channel_Entity_Rel_Info_}$PreMonthF" "" "$miExecMonthF-01 00:00:00" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "insert into $mTemp_Entity_Rel
	                select a.*
	                  from (select channel_entity_id,
	                               parent_entity,
	                               rec_status,
	                               row_number() over(partition by channel_entity_id order by done_date desc, done_code desc,case
	                                 when rec_status = 1 then
	                                  1
	                                 else
	                                  nvl(rec_status,
	                                      1000) + 99
	                               end) as Seq_No
	                          from ${TOds_Channel_Entity_Rel_Info_}$PreMonthF) a
	                  left join $mTemp_Entity_Rel b
	                    on a.channel_entity_id = b.channel_entity_id
	                 where a.seq_no = 1
	                   and b.channel_entity_id is null" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "runstats on table $mTemp_Entity_Rel" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#兜取所有代理商信息
if DB2_Check 0 1 0 "" $mTemp_Channel_Agent "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Channel_Agent "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Channel_Agent "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Channel_Agent(
              agent_id        integer,
              full_name       varchar(128),
              agent_level     smallint,
              agent_type      smallint,
              type            smallint,
              industry_type   smallint,
              sign_begin_date timestamp,
              sign_end_date   timestamp,
              rec_status      smallint,
              done_date       timestamp,
              org_id          bigint,
              op_id           bigint,
              seq_no          smallint
              ) in $TableSpace partitioning key(agent_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Channel_Agent activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#按新模型插入代理商信息
if ! DB2_Cmd "insert into $mTemp_Channel_Agent
                select *
                  from (select agent_id,
                               full_name,
                               agent_level,
                               null as Agent_Type,
                               null as Type,
                               industry_type,
                               sign_begin_date,
                               sign_end_date,
                               rec_status,
                               done_date,
                               org_id,
                               op_id,
                               row_number() over(partition by agent_id order by done_date desc, done_code desc,case
                                 when rec_status = 1 then
                                  1
                                 else
                                  nvl(rec_status,
                                      1000) + 99
                               end) as Seq_No
                          from ${TOds_Channel_Agent_Info_New_}$PreMonthF)
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#支撑老模型
if DB2_Check 0 3 3 3 "${TOds_Channel_Agent_Info_}$PreMonthF" "" "$miExecMonthF-01 00:00:00" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "insert into $mTemp_Channel_Agent
	                select a.*
	                  from (select agent_id,
	                               full_name,
	                               agent_level,
	                               agent_type,
	                               null as Type,
	                               industry_type,
	                               sign_begin_date,
	                               sign_end_date,
	                               rec_status,
	                               done_date,
	                               org_id,
	                               op_id,
	                               row_number() over(partition by agent_id order by done_date desc, done_code desc,case
	                                 when rec_status = 1 then
	                                  1
	                                 else
	                                  nvl(rec_status,
	                                      1000) + 99
	                               end) as Seq_No
	                          from ${TOds_Channel_Agent_Info_}$PreMonthF) a
	                  left join $mTemp_Channel_Agent b
	                    on a.agent_id = b.agent_id
	                 where a.seq_no = 1
	                   and b.agent_id is null" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "runstats on table $mTemp_Channel_Agent" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#兜取所有代理商扩展信息
if DB2_Check 0 1 0 "" $mTemp_Agent_Extinfo "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Agent_Extinfo "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Agent_Extinfo "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Agent_Extinfo(
              agent_id   integer,
              ext4       bigint,
              rec_status smallint,
              seq_no     smallint
              ) in $TableSpace partitioning key(agent_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Agent_Extinfo activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#按新模型插入代理商扩展信息
if ! DB2_Cmd "insert into $mTemp_Agent_Extinfo
                select *
                  from (select agent_id,
                               ext4,
                               rec_status,
                               row_number() over(partition by agent_id order by done_date desc, done_code desc,case
                                 when rec_status = 1 then
                                  1
                                 else
                                  nvl(rec_status,
                                      1000) + 99
                               end) as Seq_No
                          from ${TOds_Channel_Agent_Extinfo_}$PreMonthF)
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#支撑老模型
if DB2_Check 0 3 3 3 "${TOds_Channel_Agent_Extinfo_Transform_}$PreMonthF" "" "$miExecMonthF-01 00:00:00" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "insert into $mTemp_Agent_Extinfo
	                select a.*
	                  from (select agent_id,
	                               ext4,
	                               rec_status,
	                               row_number() over(partition by agent_id order by done_date desc, done_code desc,case
	                                 when rec_status = 1 then
	                                  1
	                                 else
	                                  nvl(rec_status,
	                                      1000) + 99
	                               end) as Seq_No
	                          from ${TOds_Channel_Agent_Extinfo_Transform_}$PreMonthF) a
	                  left join $mTemp_Agent_Extinfo b
	                    on a.agent_id = b.agent_id
	                 where a.seq_no = 1
	                   and b.agent_id is null" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "runstats on table $mTemp_Agent_Extinfo" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#人工稽核信息
if DB2_Check 0 1 0 "" $mTemp_Channel_Man_Check "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Channel_Man_Check "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Channel_Man_Check "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Channel_Man_Check(
              channel_entity_id bigint,
              check_type        smallint,
              rec_status        smallint,
              check_result      integer,
              done_date         date,
              seq_no            smallint
              ) in $TableSpace partitioning key(channel_entity_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Channel_Man_Check activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#按新模型插入代理商信息
if ! DB2_Cmd "insert into $mTemp_Channel_Man_Check
                select *
                  from (select channel_entity_id,
                               check_type,
                               rec_status,
                               check_result,
                               done_date,
                               row_number() over(partition by channel_entity_id order by done_date desc, done_code desc,case
                                 when rec_status = 1 then
                                  1
                                 else
                                  nvl(rec_status,
                                      1000) + 99
                               end, nvl(check_result, 1000) desc) as Seq_No
                          from ${TOds_Channel_Man_Check_}$PreMonthF)
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $mTemp_Channel_Man_Check" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#拼接网点代理商信息
if DB2_Check 0 1 0 "" $mTemp_Node_Agent_Info "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Node_Agent_Info "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Node_Agent_Info "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Node_Agent_Info(
              node_id               bigint,
              node_name             varchar(128),
              node_kind             smallint,
              kind_name             varchar(64),
              kind_name2            varchar(64), -- 预处理
              node_type             smallint,
              node_level            smallint,
              operate_type          smallint,
              node_status           smallint,
              node_entity_type      smallint,
              district_id           smallint,
              valid_date            timestamp,
              expire_date           timestamp,
              create_date           timestamp,
              done_date             timestamp,
              check_date            date,
              channel_entity_serial varchar(32),
              op_id                 bigint,
              self_status           smallint,
              self_status_name      varchar(20),
              node_addr             varchar(255),
              business_start_date   timestamp,
              agent_id              integer,
              agent_short_name      varchar(128),
              agent_name            varchar(128),
              belong_org_id         integer,
              belong_org_name       varchar(50),
              test_busi_flag        integer,
              org_id                bigint,
              org_name              varchar(128),
              agent_type            smallint,
              agent_type_name       varchar(40),
              agent_type_alias      smallint,
              agent_level           smallint,
              agent_level_name      varchar(40),
              agent_status          integer,
              pay_type              smallint,
              pay_type_name         varchar(16),
              agent_valid_date      timestamp,
              agent_expire_date     timestamp,
              agent_create_date     timestamp,
              agent_done_date       timestamp,
              done_code_basic       varchar(21),
              done_date_basic       timestamp,
              done_code_node        varchar(21),
              done_date_node        timestamp
              ) in $TableSpace partitioning key(node_id, op_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Node_Agent_Info activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#按新模型插入渠道网点扩展信息
if ! DB2_Cmd "insert into $mTemp_Node_Agent_Info
                select distinct a.node_id,
                                b.channel_entity_name as Node_Name,
                                a.node_kind,
                                q.code_name as Kind_Name,
                                r.code_name,
                                a.node_type,
                                a.node_level,
                                a.operate_type,
                                b.channel_entity_status as Node_Status,
                                b.channel_entity_type as Node_Entity_Type,
                                b.district_id,
                                a.valid_date,
                                a.expire_date,
                                b.create_date,
                                a.done_date,
                                g.done_date as Check_Date,
                                case
                                  when b.channel_entity_status not in (4, 5) then
                                   substr(upper(b.channel_entity_serial), 1, 11)
                                end as Channel_Entity_Serial,
                                null as Op_id, -- d.op_id
                                case
                                  when p.channel_entity_status in (3, 11) then
                                   0
                                  when p.channel_entity_status in (4, 13) then
                                   1
                                  when p.channel_entity_status in (5, 12) then
                                   2
                                  else
                                   null
                                end as Self_Status,
                                case
                                  when p.channel_entity_status in (3, 11) then
                                   '正常运营'
                                  when p.channel_entity_status in (4, 13) then
                                   '暂停营业'
                                  when p.channel_entity_status in (5, 12) then
                                   '已关店'
                                  else
                                   null
                                end as Self_Status_Name,
                                a.node_addr,
                                a.business_start_date,
                                nvl(d.agent_id, c.parent_entity) as Agent_Id,
                                e.channel_entity_name as Agent_Short_Name,
                                d.full_name as Agent_Name,
                                int(k.ext1) as Belong_Org_Id,
                                nvl(l.code_name, k.code_name) as Belong_Org_Name,
                                case
                                  when substr(a.business_start_date, 1, 7) =
                                       '$miPreMonthF' then
                                   1
                                  when substr(a.business_start_date + 1 month, 1, 7) =
                                       '$miPreMonthF' then
                                   2
                                  else
                                   0
                                end as Test_Busi_Flag,
                                f.parent_entity as Org_Id,
                                h.channel_entity_name as Org_Name,
                                d.agent_type,
                                m.code_name as Agent_Type_Name,
                                e.channel_entity_type as Agent_Type_Alias,
                                d.agent_level as Agent_Level,
                                n.code_name as Agent_Level_Name,
                                e.channel_entity_status as Agent_Status,
                                case
                                  when j.code_name = '自行开票' then
                                   2
                                  else
                                   1
                                end as Pay_Type,
                                nvl(j.code_name, '代扣代缴') as Pay_Type_Name,
                                d.sign_begin_date as Agent_Valid_Date,
                                d.sign_end_date as Agent_Expire_Date,
                                e.create_date as Agent_Create_Date,
                                d.done_date as Agent_Done_date,
                                b.done_code as Done_Code_Basic,
                                b.done_date as Done_Date_Basic,
                                a.done_code as Done_Code_Node,
                                a.done_date as Done_Date_Node
                  from $mTemp_Channel_Node a
                  left outer join $mTemp_Entity_Basic b
                    on a.node_id = b.channel_entity_id
                  left outer join $mTemp_Entity_Rel c
                    on b.channel_entity_id = c.channel_entity_id
                  left outer join $mTemp_Channel_Agent d
                    on c.parent_entity = d.agent_id
                  left outer join $mTemp_Entity_Basic e
                    on d.agent_id = e.channel_entity_id
                  left outer join $mTemp_Entity_Rel f
                    on e.channel_entity_id = f.channel_entity_id
                  left outer join $mTemp_Channel_Man_Check g
                    on d.agent_id = g.channel_entity_id
                   -- and g.rec_status = 1
                   -- and g.check_result = 1
                   -- and g.check_type = 1
                  left outer join $mTemp_Entity_Basic h
                    on f.parent_entity = h.channel_entity_id
                  left outer join $mTemp_Agent_Extinfo i
                    on d.agent_id = i.agent_id
                  left outer join (select code_id, code_name
                                     from ${TOds_Channel_Sys_Base_Type_New_}$PreMonthF
                                    where code_type = 10022) j
                    on i.ext4 = j.code_id
                  left outer join (select code_id, code_name, ext1
                                     from ${TOds_Channel_Sys_Base_Type_New_}$PreMonthF
                                    where code_type = 10002) k
                    on b.district_id = k.code_id
                  left outer join (select code_id, code_name
                                     from ${TOds_Channel_Sys_Base_Type_New_}$PreMonthF
                                    where code_type = 10015) l
                    on int(k.ext1) = l.code_id
                  left outer join (select code_id, code_name
                                     from ${TOds_Channel_Sys_Base_Type_New_}$PreMonthF
                                    where code_type = 10004) m
                    on d.agent_type = m.code_id
                  left outer join (select code_id, code_name
                                     from ${TOds_Channel_Sys_Base_Type_New_}$PreMonthF
								where code_type = 10012) n
                    on d.agent_level = n.code_id
                  left outer join $mTemp_Node_Extinfo o
                    on a.node_id = o.node_id
                  left outer join $mTemp_Entity_Basic p
                    on o.node_id = p.channel_entity_id
                  left outer join (select code_id, code_name
                                     from ${TOds_Channel_Sys_Base_Type_New_}$PreMonthF
                                    where code_type = 10033) q
                    on a.node_kind = q.code_id
                  left outer join (select code_id, code_name
                                     from ${TOds_Channel_Sys_Base_Type_New_}$PreMonthF
                                    where code_type = 82831) r
                    on a.node_type = r.code_id
                   and q.code_name = '直营营业厅'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $mTemp_Node_Agent_Info" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
DB2_Truncate $mTemp_Channel_Node "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Channel_Node "$LogFile"-`date +%Y%m%d`
DB2_Truncate $mTemp_Node_Extinfo "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Node_Extinfo "$LogFile"-`date +%Y%m%d`
DB2_Truncate $mTemp_Channel_Node "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Channel_Node "$LogFile"-`date +%Y%m%d`

#配boss_org_id
if DB2_Check 0 1 0 "" $mTemp_Node_Agent_Info2 "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Node_Agent_Info2 "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Node_Agent_Info2 "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Node_Agent_Info2 like $mTemp_Node_Agent_Info in $TableSpace partitioning key(node_id, org_id, op_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Node_Agent_Info2 add column crm_org_id bigint" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Node_Agent_Info2 activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#插入网点代理商
if ! DB2_Cmd "insert into $mTemp_Node_Agent_Info2
                select distinct a.*, nvl(b.org_id, c.org_id) as Boss_Org_Id
                  from $mTemp_Node_Agent_Info a
                  left outer join ${TOds_Channel_Org_Agent_New_}$PreMonthF b
                    on a.node_id = b.agent_id
                  left outer join ${TOds_Channel_Org_Agent_}$PreMonthF c
                    on a.node_id = c.agent_id
                   and a.node_type = c.type" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#插入未设网点的代理商
if ! DB2_Cmd "insert into $mTemp_Node_Agent_Info2
                (agent_id,
                 agent_short_name,
                 agent_name,
                 org_id,
                 org_name,
                 agent_type,
                 agent_type_name,
                 agent_type_alias,
                 agent_level,
                 agent_level_name,
                 agent_status,
                 pay_type,
                 pay_type_name,
                 channel_entity_serial,
                 agent_valid_date,
                 agent_expire_date,
                 agent_create_date,
                 agent_done_date,
                 check_date)
                select distinct a.agent_id,
                                b.channel_entity_name as Agent_Short_Name,
                                a.full_name as Agent_Name,
                                c.parent_entity as Org_Id,
                                e.channel_entity_name as Org_Name,
                                a.agent_type as Agent_Type,
                                h.code_name as Agent_Type_Name,
                                b.channel_entity_type as Agent_Type_Alias,
                                a.agent_level as Agent_Level,
                                i.code_name as Agent_Level_Name,
                                b.channel_entity_status as Agent_Status,
                                case
                                  when g.code_name = '自行开票' then
                                   2
                                  else
                                   1
                                end as Pay_Type,
                                nvl(g.code_name, '代扣代缴') as Pay_Type_Name,
                                b.channel_entity_serial,
                                a.sign_begin_date as Agent_Valid_Date,
                                a.sign_end_date as Agent_Expire_Date,
                                b.create_date as Agent_Create_Date,
                                a.done_date as Agent_Done_Date,
                                d.done_date as Check_Date
                  from $mTemp_Channel_Agent a
                  left outer join $mTemp_Entity_Basic b
                    on a.agent_id = b.channel_entity_id
                  left outer join $mTemp_Entity_Rel c
                    on b.channel_entity_id = c.channel_entity_id
                  left outer join $mTemp_Channel_Man_Check d
                    on a.agent_id = d.channel_entity_id
                   and d.rec_status = 1
                   and d.check_result = 1
                   and d.check_type = 1
                  left outer join $mTemp_Entity_Basic e
                    on c.parent_entity = e.channel_entity_id
                  left outer join $mTemp_Agent_Extinfo f
                    on a.agent_id = f.agent_id
                  left outer join (select code_id, code_name
                                     from ${TOds_Channel_Sys_Base_Type_New_}$PreMonthF
                                    where code_type = 10022) g
                    on f.ext4 = g.code_id
                  left outer join (select code_id, code_name
                                     from ${TOds_Channel_Sys_Base_Type_New_}$PreMonthF
                                    where code_type = 10004) h
                    on a.agent_type = h.code_id
                  left outer join (select code_id, code_name
                                     from ${TOds_Channel_Sys_Base_Type_New_}$PreMonthF
                                    where code_type = 10012) i
                    on a.agent_level = i.code_id
                  left outer join $mTemp_Node_Agent_Info2 j
                    on a.agent_id = j.agent_id
                 where j.agent_id is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $mTemp_Node_Agent_Info2" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
DB2_Truncate $mTemp_Entity_Basic "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Entity_Basic "$LogFile"-`date +%Y%m%d`
DB2_Truncate $mTemp_Entity_Rel "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Entity_Rel "$LogFile"-`date +%Y%m%d`
DB2_Truncate $mTemp_Channel_Agent "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Channel_Agent "$LogFile"-`date +%Y%m%d`
DB2_Truncate $mTemp_Agent_Extinfo "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Agent_Extinfo "$LogFile"-`date +%Y%m%d`
DB2_Truncate $mTemp_Channel_Man_Check "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Channel_Man_Check "$LogFile"-`date +%Y%m%d`
DB2_Truncate $mTemp_Node_Agent_Info "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Node_Agent_Info "$LogFile"-`date +%Y%m%d`

#兜取隶属BOSS的org_id
if DB2_Check 0 1 0 "" $mTemp_Sys_Operation "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Sys_Operation "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	else
		if ! DB2_Drop $mTemp_Sys_Operation "$LogFile"-`date +%Y%m%d`
		then
			exit 1
		fi
	fi
fi
if ! DB2_Cmd "create table $mTemp_Sys_Operation(
              org_id   bigint,
              org_name varchar(200),
              org_type varchar(50)
              ) in $TableSpace partitioning key(org_id) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Sys_Operation activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#按新模型插入渠道网点扩展信息
if ! DB2_Cmd "insert into $mTemp_Sys_Operation
                select org_id, org_name, 'BOSS' as Org_Type
                  from (select a.org_id,
                               a.org_name,
                               row_number() over(partition by a.org_id order by a.start_date desc, a.end_date desc) as Seq_No
                          from ${TDim_Prty_Oper_Info} a,
                               (select org_id, org_name, count(distinct op_id) as Cnt
                                  from ${TDim_Prty_Oper_Info}
                                 where busi_chl_type_name = 'BOSS'
                                   and start_date < '$miExecMonthF-01'
                                   and end_date > '$miPreMonthF-01'
                                 group by org_id, org_name) b
                         where a.busi_chl_type_name = 'BOSS'
                           and a.start_date < '$miExecMonthF-01'
                           and a.end_date > '$miPreMonthF-01'
                           and a.org_id = b.org_id
                           and nvl(a.org_name, 'NULL') = nvl(b.org_name, 'NULL')
                           and b.cnt = 1)
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#取失效的记录
if ! DB2_Cmd "insert into $mTemp_Sys_Operation
                select org_id, org_name, 'BOSS' as Org_Type
                  from (select a.org_id,
                               a.org_name,
                               row_number() over(partition by a.org_id order by a.start_date desc, a.end_date desc) as Seq_No
                          from ${TDim_Prty_Oper_Info} a,
                               (select b.org_id, b.org_name, count(distinct b.op_id) as Cnt
                                  from ${TDim_Prty_Oper_Info} b
                                  left join $mTemp_Sys_Operation c
                                    on b.org_id = c.org_id
                                 where b.busi_chl_type_name = 'BOSS'
                                   and b.start_date < '$miExecMonthF-01'
                                   and c.org_id is null
                                 group by b.org_id, b.org_name) c
                         where a.busi_chl_type_name = 'BOSS'
                           and a.start_date < '$miExecMonthF-01'
                           and a.org_id = c.org_id
                           and nvl(a.org_name, 'NULL') = nvl(c.org_name, 'NULL')
                           and c.cnt = 1)
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $mTemp_Sys_Operation" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi





WriteStatusFile 1 4 $$ $StatusFile "" "构建组织机构维表……"
if ! DB2_Check 0 1 0 "" $Rpt_Dim_Channel_Org_Op_Info "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Dim_Channel_Org_Op_Info(
	                ORG_CLASS1            VARCHAR(64),
	                ORG_CLASS2            VARCHAR(64),
	                ORG_CLASS3            VARCHAR(64),
	                CRM_ORG_ID            BIGINT,
	                OP_ID                 BIGINT, -- 仅针对自助终端、电子渠道、直销，一般不填
	                CRM_ORG_TYPE          INTEGER,
	                CRM_ORG_TYPE_NAME     VARCHAR(200),
	                CRM_ORG_KIND          VARCHAR(50),
	                CRM_ORG_NAME          VARCHAR(200),
	                OP_NAME               VARCHAR(100),
	                LOGIN_NAME            VARCHAR(100),
	                NODE_ID               BIGINT,
	                NODE_NAME             VARCHAR(128),
	                NODE_KIND             VARCHAR(24),
	                NODE_TYPE             VARCHAR(24),
	                CHL_MODE              VARCHAR(200),
	                NODE_LEVEL            SMALLINT,
	                NODE_STATUS           SMALLINT,
	                OPERATE_TYPE          SMALLINT,
	                NODE_ENTITY_TYPE      SMALLINT,
	                DISTRICT_ID           SMALLINT,
	                VALID_DATE            TIMESTAMP,
	                EXPIRE_DATE           TIMESTAMP,
	                NODE_CREATE_DATE      TIMESTAMP,
	                NODE_DONE_DATE        TIMESTAMP,
	                CHECK_DATE            DATE,
	                CHANNEL_ENTITY_SERIAL VARCHAR(32),
	                SELF_STATUS           SMALLINT,
	                SELF_STATUS_NAME      VARCHAR(20),
	                NODE_ADDR             VARCHAR(255),
	                BUSINESS_START_DATE   TIMESTAMP,
	                AGENT_ID              INTEGER,
	                AGENT_SHORT_NAME      VARCHAR(128),
	                AGENT_NAME            VARCHAR(128),
	                BELONG_ORG_ID         INTEGER,
	                BELONG_ORG_NAME       VARCHAR(50),
	                TEST_BUSI_FLAG        INTEGER,
	                ORG_ID                BIGINT,
	                ORG_NAME              VARCHAR(128),
	                AGENT_TYPE            SMALLINT,
	                AGENT_TYPE_NAME       VARCHAR(40),
	                AGENT_TYPE_ALIAS      SMALLINT,
	                AGENT_LEVEL           SMALLINT,
	                AGENT_LEVEL_NAME      VARCHAR(40),
	                AGENT_STATUS          INTEGER,
	                PAY_TYPE              SMALLINT,
	                PAY_TYPE_NAME         VARCHAR(16),
	                AGENT_VALID_DATE      TIMESTAMP,
	                AGENT_EXPIRE_DATE     TIMESTAMP,
	                AGENT_CREATE_DATE     TIMESTAMP,
	                AGENT_DONE_DATE       TIMESTAMP,
	                IS_VALID              SMALLINT, -- 有效标志:0-无效,1-有效
	                CREATE_DATE           DATE,
	                MODIFY_DATE           DATE
	              ) in $TableSpace partitioning key(CRM_ORG_ID, OP_ID, CREATE_DATE) using hashing" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
	DB2_Cmd "comment on table $Rpt_Dim_Channel_Org_Op_Info IS '渠道组织人员维表'" "$LogFile"-`date +%Y%m%d`
	DB2_Cmd "comment on $Rpt_Dim_Channel_Org_Op_Info (ORG_CLASS1 IS '渠道一级分类:实体渠道,电子渠道,直营渠道',
	                                                  ORG_CLASS2 IS '渠道二级分类:实体渠道-直营店,实体渠道-加盟店,实体渠道-授权店;电子渠道-自营电子渠道,电子渠道-社会电子渠道;直营渠道-自营直销渠道,直营渠道-社会直销渠道',
	                                                  ORG_CLASS3 IS '渠道三级分类:旗舰店、标准店、社区店、手机大卖场,委托经营厅,手机专卖店、授权代理店、手机卖场,网营、短营、热线电话、客户端、网店,外部电商网站、互联网分销,客户经理和社区经理,农村、校园和社区的代办员',
	                                                  CRM_ORG_ID IS 'CRM侧组织编号',
	                                                  OP_ID IS '操作员工号:为空时，以org_id为准。来源db2info.Dim_Sys_Operation_Info.op_id',
	                                                  CRM_ORG_TYPE IS '组织类型:来源db2info.Dim_Org_Info.new_org_type',
	                                                  CRM_ORG_TYPE_NAME IS '组织类型名:来源db2info.Dim_Org_Info.new_org_type_name或org_type_name',
	                                                  CRM_ORG_KIND IS '操作员组织类型:来源db2info.Dim_Sys_Operation_Info.org_type',
	                                                  CRM_ORG_NAME IS '组织名称:来源db2info.Dim_Org_Info.new_org_name或org_name，抑或db2info.Dim_Sys_Operation_Info.org_name',
	                                                  OP_NAME IS '工号姓名:来源db2info.Dim_Sys_Operation_Info.op_name',
	                                                  LOGIN_NAME IS '登录名:来源db2info.Dim_Sys_Operation_Info.login_name',
	                                                  NODE_ID IS '网点编号',
	                                                  NODE_NAME IS '网点名称',
	                                                  NODE_KIND IS '来源db2info.Ods_Channel_Node_New_YYYYMMDD.node_kind或db2info.Dim_Org_Info.chl_kind',
	                                                  NODE_TYPE IS '来源db2info.Ods_Channel_Node_New_YYYYMMDD.node_type或db2info.Dim_Org_Info.chl_type',
	                                                  CHL_MODE IS '来源db2info.Dim_Org_Info.chl_mode',
	                                                  NODE_LEVEL IS '网点级别',
	                                                  NODE_STATUS IS '网点状态',
	                                                  OPERATE_TYPE IS '运转类型',
	                                                  NODE_ENTITY_TYPE IS '网点实体类型',
	                                                  DISTRICT_ID IS '',
	                                                  VALID_DATE IS '网点生效日期',
	                                                  EXPIRE_DATE IS '网点失效日期',
	                                                  NODE_CREATE_DATE IS '网点创建日期',
	                                                  NODE_DONE_DATE IS '网点变更日期',
	                                                  CHECK_DATE IS '人工稽核日期',
	                                                  CHANNEL_ENTITY_SERIAL IS '实体序列号',
	                                                  SELF_STATUS IS '自营状态',
	                                                  SELF_STATUS_NAME IS '自营状态名称',
	                                                  NODE_ADDR IS '网点地址',
	                                                  BUSINESS_START_DATE IS '网点商用起始时间',
	                                                  AGENT_ID IS '代理商编号',
	                                                  AGENT_SHORT_NAME IS '代理商简称',
	                                                  AGENT_NAME IS '代理商全称',
	                                                  BELONG_ORG_ID IS '隶属组织编号',
	                                                  BELONG_ORG_NAME IS '隶属组织名称',
	                                                  TEST_BUSI_FLAG IS '业务测试标志',
	                                                  ORG_ID IS '组织编号:来源shdw.Dim_Org_Info.org_id,shdw.Dim_Sys_Operation_Info.org_id',
	                                                  ORG_NAME IS '组织名称',
	                                                  AGENT_TYPE IS '代理商类型',
	                                                  AGENT_TYPE_NAME IS '代理商类型名称',
	                                                  AGENT_TYPE_ALIAS IS '代理商类型别称',
	                                                  AGENT_LEVEL IS '代理商级别',
	                                                  AGENT_LEVEL_NAME IS '代理商级别名称',
	                                                  AGENT_STATUS IS '代理商状态',
	                                                  PAY_TYPE IS '支付类型',
	                                                  PAY_TYPE_NAME IS '支付类型名称',
	                                                  AGENT_VALID_DATE IS '代理商生效日期',
	                                                  AGENT_EXPIRE_DATE IS '代理商失效日期',
	                                                  AGENT_CREATE_DATE IS '代理商创建日期',
	                                                  AGENT_DONE_DATE IS '代理商变更日期',
	                                                  IS_VALID IS '有效标志:0-无效,1-有效',
	                                                  CREATE_DATE IS '创建日期',
	                                                  MODIFY_DATE IS '修改日期'
	                                                 )" "$LogFile"-`date +%Y%m%d`
fi
if ! DB2_Cmd "delete from $Rpt_Dim_Channel_Org_Op_Info where create_date='$miExecDayF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#插入自助终端相关信息
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                select distinct '电子渠道' as Kind_Name1,
                                '自营电子渠道' as Kind_Name2,
                                '自助终端' as Kind_Name3,
                                b.org_id as Crm_Org_Id,
                                a.op_id,
                                d.bass_org_type as Crm_Org_Type,
                                nvl(d.bass_org_type_name, d.boss_org_type_name) as Crm_Org_Type_Name,
                                b.busi_chl_type_name as Crm_Org_Kind,
                                nvl(d.org_name, b.org_name) as Crm_Org_Name,
                                b.op_name as Op_Name,
                                b.login_name as Login_Name,
                                c.node_id,
                                c.node_name,
                                nvl(c.node_kind || '', d.chl_kind) as Node_Kind,
                                nvl(c.node_type || '', d.chl_type) as Node_Type,
                                d.chl_mode,
                                c.node_level,
                                c.node_status,
                                c.operate_type,
                                c.node_entity_type,
                                c.district_id,
                                c.valid_date,
                                c.expire_date,
                                c.create_date as Node_Create_Date,
                                c.done_date as Node_Done_Date,
                                c.check_date,
                                c.channel_entity_serial,
                                c.self_status,
                                c.self_status_name,
                                c.node_addr,
                                c.business_start_date,
                                c.agent_id,
                                c.agent_short_name,
                                c.agent_name,
                                c.belong_org_id,
                                c.belong_org_name,
                                c.test_busi_flag,
                                c.org_id,
                                c.org_name,
                                c.agent_type,
                                c.agent_type_name,
                                c.agent_type_alias,
                                c.agent_level,
                                c.agent_level_name,
                                c.agent_status,
                                c.pay_type,
                                c.pay_type_name,
                                c.agent_valid_date,
                                c.agent_expire_date,
                                c.agent_create_date,
                                c.agent_done_date,
                                1 as Is_Valid,
                                '$miExecDayF' as Create_Date,
                                '$miExecDayF' as Modify_Date
                  from (select int(terminalopid) as op_id
                          from ${TOds_Db_Ap_Atm_Pcsettingext_}$PreDayF
                         where terminalcode <> '123456789012345' -- 老自助终端
                           and terminalopid is not null
                        union
                        select int(termdesp) as op_id
                          from ${TOds_Term_}$PreDayF -- 新的凯信达机器
                         where substr(termdesp, 1, 1) between '0' and '9') a -- 等同于 termdesp is not null and upper(termdesp) not like '%TEST%' and termdesp <> '周浦营业厅'
                  left join (select org_id,
                                    org_name,
                                    op_id,
                                    op_name,
                                    login_name,
                                    busi_chl_type_name,
                                    row_number() over(partition by op_id order by start_date desc, end_date desc) as Seq_No
                               from ${TDim_Prty_Oper_Info}
                              where busi_chl_type_name = 'BOSS'
                                and start_date < '$miExecMonthF-01') b
                    on a.op_id = b.op_id
                   and b.seq_no = 1
                  left join $mTemp_Node_Agent_Info2 c
                    on b.org_id = c.crm_org_id
                  left join (select org_id,
                                    org_name,
                                    bass_org_type,
                                    bass_org_type_name,
                                    boss_org_type,
                                    boss_org_type_name,
                                    chl_kind,
                                    chl_type,
                                    chl_mode,
                                    row_number() over(partition by org_id order by start_date desc, end_date desc) as Seq_No
                               from ${TDim_Prty_Org_Info}
                              where start_date < '$miExecMonthF-01') d
                    on b.org_id = d.org_id
                   and d.seq_no = 1
                 where b.org_id is not null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#插入直销渠道
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                select distinct '直销渠道' as Kind_Name1,
                                '自营直销渠道' as Kind_Name2,
                                '集团客户经理' as Kind_Name3,
                                a.org_id as Crm_Org_Id,
                                a.op_id,
                                c.bass_org_type as Crm_Org_Type,
                                nvl(c.bass_org_type_name, c.boss_org_type_name) as Crm_Org_Type_Name,
                                a.busi_chl_type_name as Crm_Org_Kind,
                                nvl(c.org_name, a.org_name) as Crm_Org_Name,
                                a.op_name as Op_Name,
                                a.login_name as Login_Name,
                                b.node_id,
                                b.node_name,
                                nvl(b.node_kind || '', c.chl_kind) as Node_Kind,
                                nvl(b.node_type || '', c.chl_type) as Node_Type,
                                c.chl_mode,
                                b.node_level,
                                b.node_status,
                                b.operate_type,
                                b.node_entity_type,
                                b.district_id,
                                b.valid_date,
                                b.expire_date,
                                b.create_date as Node_Create_Date,
                                b.done_date as Node_Done_Date,
                                b.check_date,
                                b.channel_entity_serial,
                                b.self_status,
                                b.self_status_name,
                                b.node_addr,
                                b.business_start_date,
                                b.agent_id,
                                b.agent_short_name,
                                b.agent_name,
                                b.belong_org_id,
                                b.belong_org_name,
                                b.test_busi_flag,
                                b.org_id,
                                b.org_name,
                                b.agent_type,
                                b.agent_type_name,
                                b.agent_type_alias,
                                b.agent_level,
                                b.agent_level_name,
                                b.agent_status,
                                b.pay_type,
                                b.pay_type_name,
                                b.agent_valid_date,
                                b.agent_expire_date,
                                b.agent_create_date,
                                b.agent_done_date,
                                1 as Is_Valid,
                                '$miExecDayF' as Create_Date,
                                '$miExecDayF' as Modify_Date
                  from (select org_id,
                               org_name,
                               op_id,
                               op_name,
                               login_name,
                               busi_chl_type_name,
                               row_number() over(partition by op_id order by start_date desc, end_date desc) as Seq_No
                          from ${TDim_Prty_Oper_Info}
                         where upper(login_name) like '%GSJK%'
                           and start_date < '$miExecMonthF-01') a
                  left join $mTemp_Node_Agent_Info2 b
                    on a.org_id = b.crm_org_id
                  left join (select org_id,
                                    org_name,
                                    bass_org_type,
                                    bass_org_type_name,
                                    boss_org_type,
                                    boss_org_type_name,
                                    chl_kind,
                                    chl_type,
                                    chl_mode,
                                    row_number() over(partition by org_id order by start_date desc, end_date desc) as Seq_No
                               from ${TDim_Prty_Org_Info}
                              where start_date < '$miExecMonthF-01') c
                    on a.org_id = c.org_id
                   and c.seq_no = 1
                 where a.seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#插入电子渠道
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                select distinct '电子渠道' as Kind_Name1,
                                '自营电子渠道' as Kind_Name2,
                                case
                                  when a.op_id = 999990001 or a.org_id = 402852 then
                                   '网上营业厅'
                                  when a.op_id = 999990002 then
                                   'WAP'
                                  when a.op_id in (999990021, 999990101) then
                                   '10086自助'
                                  when a.op_id = 999990024 and a.op_name = '网上商城后台接口' then
                                   '网上商城'
                                  when a.op_id = 999990076 and a.op_name = 'CBOSS' then
                                   'CBOSS'
                                  when a.op_id = 999990077 then
                                   '短信营业厅'
                                  when a.op_id = 999990091 then
                                   '客户端'
                                  when a.op_id = 999990099 and a.op_name = '统一支付平台' then
                                   '统一支付'
                                  when a.busi_chl_type_name = 'CCS' then
                                   '热线电话' -- 10086人工
                                  when a.op_id = 999990121 then
                                   '互联网外链' -- 划入网上营业厅
                                  when a.op_id = 999990122 then
                                   '支付宝' -- 划入网上营业厅
                                  when a.op_id = 999990133 then
                                   '微信营业厅' -- 划入网上营业厅
                                  when a.op_id = 9 and a.op_name = '后台进程' then
                                   null
                                end as Kind_Name3,
                                a.org_id as Crm_Org_Id,
                                a.op_id,
                                c.bass_org_type as Crm_Org_Type,
                                nvl(c.bass_org_type_name, c.boss_org_type_name) as Crm_Org_Type_Name,
                                a.busi_chl_type_name as Crm_Org_Kind,
                                nvl(c.org_name, a.org_name) as Crm_Org_Name,
                                a.op_name as Op_Name,
                                a.login_name as Login_Name,
                                b.node_id,
                                b.node_name,
                                nvl(b.node_kind || '', c.chl_kind) as Node_Kind,
                                nvl(b.node_type || '', c.chl_type) as Node_Type,
                                c.chl_mode,
                                b.node_level,
                                b.node_status,
                                b.operate_type,
                                b.node_entity_type,
                                b.district_id,
                                b.valid_date,
                                b.expire_date,
                                b.create_date as Node_Create_Date,
                                b.done_date as Node_Done_Date,
                                b.check_date,
                                b.channel_entity_serial,
                                b.self_status,
                                b.self_status_name,
                                b.node_addr,
                                b.business_start_date,
                                b.agent_id,
                                b.agent_short_name,
                                b.agent_name,
                                b.belong_org_id,
                                b.belong_org_name,
                                b.test_busi_flag,
                                b.org_id,
                                b.org_name,
                                b.agent_type,
                                b.agent_type_name,
                                b.agent_type_alias,
                                b.agent_level,
                                b.agent_level_name,
                                b.agent_status,
                                b.pay_type,
                                b.pay_type_name,
                                b.agent_valid_date,
                                b.agent_expire_date,
                                b.agent_create_date,
                                b.agent_done_date,
                                1 as Is_Valid,
                                '$miExecDayF' as Create_Date,
                                '$miExecDayF' as Modify_Date
                  from (select org_id,
                               org_name,
                               op_id,
                               op_name,
                               login_name,
                               busi_chl_type_name,
                               row_number() over(partition by op_id order by start_date desc, end_date desc) as Seq_No
                          from ${TDim_Prty_Oper_Info}
                         where upper(nvl(login_name, '-1')) not like '%GSJK%'
                           and start_date < '$miExecMonthF-01') a
                  left join $mTemp_Node_Agent_Info2 b
                    on a.org_id = b.crm_org_id
                  left join (select org_id,
                                    org_name,
                                    bass_org_type,
                                    bass_org_type_name,
                                    boss_org_type,
                                    boss_org_type_name,
                                    chl_kind,
                                    chl_type,
                                    chl_mode,
                                    row_number() over(partition by org_id order by start_date desc, end_date desc) as Seq_No
                               from ${TDim_Prty_Org_Info}
                              where start_date < '$miExecMonthF-01') c
                    on a.org_id = c.org_id
                   and c.seq_no = 1
                 where a.seq_no = 1
                   and (a.op_id in (999990001,
                                    999990002,
                                    999990021,
                                    999990024,
                                    999990076,
                                    999990077,
                                    999990091,
                                    999990099,
                                    999990101,
                                    999990121,
                                    999990122,
                                    999990133) or a.busi_chl_type_name = 'CCS' or
                       a.org_id = 402852 or a.op_id = 9 and a.op_name = '后台进程')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#插入新渠道已划分的
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                select distinct case
                                  when a.kind_name = '自助终端' or a.node_kind = 7 then
                                   '电子渠道'
                                  when a.kind_name = '校园直销队' then
                                   '直销渠道'
                                  when a.crm_org_id is not null and
                                       a.kind_name is not null then
                                   '实体渠道'
                                  when c.org_name = '电商服务支撑部' then
                                   '电子渠道'
                                  when c.bass_org_type in (1, 2, 3, 4, 5, 6, 7, 8, 9) or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('专营店',
                                        '购机中心',
                                        '中国移动购机中心',
                                        '代理商',
                                        '转型网点',
                                        '合作厅',
                                        '外包厅',
                                        '终端代理商',
                                        '自营厅',
                                        '渠道直供店',
                                        '连锁渠道',
                                        '连锁商转型网点',
                                        '井通通信受理权限',
                                        '指定授权店') then -- 1-星级连锁门店,2-渠道直供店,3-专营店,4-购机中心,5-代理商/转型网点,6-自营厅,7-合作厅,8-外包厅,9-终端代理商
                                   '实体渠道'
                                  when c.bass_org_type = 10 or c.org_name = '沪动商城渠道商' then -- 10-互联网代理商
                                   '电子渠道'
                                  when a.kind_name in ('家庭业务代理店', '其它网点') or
                                       a.node_kind in (9, 10) then
                                   '实体渠道'
                                  when nvl(c.org_name, b.org_name) in
                                       ('迪信通渠道商',
                                        '蜂星',
                                        '美承',
                                        '移达',
                                        '茗神渠道商',
                                        '井通',
                                        '盛南',
                                        '本地二码合一') then
                                   '实体渠道'
                                end as Kind_Name1,
                                case
                                  when a.kind_name = '自助终端' or a.node_kind = 7 then
                                   '自营电子渠道'
                                  when a.kind_name = '校园直销队' then
                                   '社会直销渠道'
                                  when a.kind_name = '直营营业厅' or a.node_kind = 1 then
                                   '直营店'
                                  when a.kind_name in ('加盟社会店', '加盟营业厅') or
                                       a.node_kind in (2, 3) then
                                   '加盟店'
                                  when a.kind_name in
                                       ('手机专卖店', '手机卖场', '授权代理店') or
                                       a.node_kind in (4, 5, 6) then
                                   '授权店'
                                  when c.org_name = '电商服务支撑部' then
                                   '自营电子渠道'
                                  when c.bass_org_type = 6 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '自营厅' then
                                   '直营店'
                                  when c.bass_org_type in (1, 2, 3, 4, 5, 9) or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('专营店',
                                        '购机中心',
                                        '中国移动购机中心',
                                        '代理商',
                                        '转型网点',
                                        '终端代理商',
                                        '渠道直供店',
                                        '指定授权店',
                                        '连锁渠道',
                                        '连锁商转型网点',
                                        '井通通信受理权限') then
                                   '授权店'
                                  when c.bass_org_type in (7, 8) or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('合作厅', '外包厅') then
                                   '加盟店'
                                  when c.bass_org_type = 10 then
                                   '社会电子渠道'
                                  when c.org_name = '沪动商城渠道商' then
                                   '自营电子渠道'
                                  when nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '电子渠道' then
                                   '社会电子渠道'
                                  when a.kind_name in ('家庭业务代理店', '其它网点') or
                                       a.node_kind in (9, 10) then
                                   '授权店'
                                  when nvl(c.org_name, b.org_name) in
                                       ('迪信通渠道商',
                                        '蜂星',
                                        '美承',
                                        '移达',
                                        '茗神渠道商',
                                        '井通',
                                        '盛南',
                                        '本地二码合一') then
                                   '授权店'
                                  when nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '电子渠道' then
                                   '社会电子渠道'
                                end as Kind_Name2,
                                case
                                  when a.kind_name = '自助终端' or a.node_kind = 7 then
                                   '自助终端'
                                  when a.kind_name = '校园直销队' then
                                   '校园代办员'
                                  when a.kind_name = '直营营业厅' or a.node_kind = 1 then
                                   a.kind_name2
                                  when a.kind_name in ('加盟社会店',
                                                       '加盟营业厅',
                                                       '手机专卖店',
                                                       '手机卖场',
                                                       '授权代理店') or
                                       a.node_kind in (2, 3, 4, 5, 6) then
                                   a.kind_name
                                  when c.org_name = '电商服务支撑部' then
                                   '网店'
                                  when c.bass_org_type = 6 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '自营厅' then
                                   '标准店'
                                  when c.bass_org_type = 1 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '星级连锁门店' then
                                   '手机卖场'
                                  when c.bass_org_type = 2 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '渠道直供店' then
                                   '手机专卖店+授权代理店'
                                  when c.bass_org_type = 3 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '专营店' then
                                   '手机专卖店'
                                  when c.bass_org_type = 4 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('购机中心', '中国移动购机中心', '指定授权店') then
                                   '授权代理店'
                                  when c.bass_org_type = 5 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('代理商', '转型网点', '井通通信受理权限') then
                                   '授权代理店'
                                  when c.bass_org_type in (7, 8) or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('合作厅', '外包厅') then
                                   '加盟营业厅'
                                  when c.bass_org_type = 9 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('终端代理商', '连锁渠道', '连锁商转型网点') then
                                   '手机卖场'
                                  when c.bass_org_type = 10 then
                                   '互联网分销'
                                  when c.org_name = '沪动商城渠道商' then
                                   '网店'
                                  when a.kind_name in ('家庭业务代理店', '其它网点') or
                                       a.node_kind in (9, 10) then
                                   '授权代理店' -- 财务高爽向市场部确认
                                  when nvl(c.org_name, b.org_name) in
                                       ('迪信通渠道商',
                                        '蜂星',
                                        '美承',
                                        '移达',
                                        '茗神渠道商') then
                                   '手机卖场'
                                  when nvl(c.org_name, b.org_name) in
                                       ('井通', '盛南', '本地二码合一') then
                                   '手机专卖店'
                                end as Kind_Name3,
                                a.crm_org_id,
                                null as Op_Id,
                                c.bass_org_type as Crm_Org_Type,
                                nvl(c.bass_org_type_name, c.boss_org_type_name) as Crm_Org_Type_Name,
                                b.org_type as Crm_Org_Kind,
                                nvl(c.org_name, b.org_name) as Crm_Org_Name,
                                null as Op_Name,
                                null as Login_Name,
                                a.node_id,
                                a.node_name,
                                nvl(a.node_kind || '', c.chl_kind) as Node_Kind,
                                nvl(a.node_type || '', c.chl_type) as Node_Type,
                                c.chl_mode,
                                a.node_level,
                                a.node_status,
                                a.operate_type,
                                a.node_entity_type,
                                a.district_id,
                                a.valid_date,
                                a.expire_date,
                                a.create_date as Node_Create_Date,
                                a.done_date as Node_Done_Date,
                                a.check_date,
                                a.channel_entity_serial,
                                a.self_status,
                                a.self_status_name,
                                a.node_addr,
                                a.business_start_date,
                                a.agent_id,
                                a.agent_short_name,
                                a.agent_name,
                                a.belong_org_id,
                                a.belong_org_name,
                                a.test_busi_flag,
                                a.org_id,
                                a.org_name,
                                a.agent_type,
                                a.agent_type_name,
                                a.agent_type_alias,
                                a.agent_level,
                                a.agent_level_name,
                                a.agent_status,
                                a.pay_type,
                                a.pay_type_name,
                                a.agent_valid_date,
                                a.agent_expire_date,
                                a.agent_create_date,
                                a.agent_done_date,
                                1 as Is_Valid,
                                '$miExecDayF' as Create_Date,
                                '$miExecDayF' as Modify_Date
                  from $mTemp_Node_Agent_Info2 a
                  left join $mTemp_Sys_Operation b
                    on a.org_id = b.org_id
                  left join (select org_id,
                                    org_name,
                                    bass_org_type,
                                    bass_org_type_name,
                                    boss_org_type,
                                    boss_org_type_name,
                                    chl_kind,
                                    chl_type,
                                    chl_mode,
                                    row_number() over(partition by org_id order by start_date desc, end_date desc) as Seq_No
                               from ${TDim_Prty_Org_Info}
                              where start_date < '$miExecMonthF-01') c
                    on a.org_id = c.org_id
                   and c.seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#插入剩余ORG
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                select distinct case
                                  when a.org_name = '电商服务支撑部' then
                                   '电子渠道'
                                  when a.bass_org_type in (1, 2, 3, 4, 5, 6, 7, 8, 9) or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('专营店',
                                        '购机中心',
                                        '中国移动购机中心',
                                        '代理商',
                                        '转型网点',
                                        '合作厅',
                                        '外包厅',
                                        '终端代理商',
                                        '自营厅',
                                        '渠道直供店',
                                        '连锁渠道',
                                        '连锁商转型网点',
                                        '井通通信受理权限',
                                        '指定授权店') then -- 1-星级连锁门店,2-渠道直供店,6-自营厅,8-外包厅
                                   '实体渠道'
                                  when a.bass_org_type = 10 or a.org_name = '沪动商城渠道商' then -- 10-互联网代理商
                                   '电子渠道'
                                  when nvl(a.org_name, b.org_name) in
                                       ('迪信通渠道商',
                                        '蜂星',
                                        '美承',
                                        '移达',
                                        '茗神渠道商',
                                        '井通',
                                        '盛南',
                                        '本地二码合一') then
                                   '实体渠道'
                                end as Kind_Name1,
                                case
                                  when a.org_name = '电商服务支撑部' then
                                   '自营电子渠道'
                                  when a.bass_org_type = 6 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       '自营厅' then
                                   '直营店'
                                  when a.bass_org_type in (1, 2, 3, 4, 5, 9) or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('专营店',
                                        '购机中心',
                                        '中国移动购机中心',
                                        '代理商',
                                        '转型网点',
                                        '终端代理商',
                                        '渠道直供店',
                                        '指定授权店',
                                        '连锁渠道',
                                        '连锁商转型网点',
                                        '井通通信受理权限') then
                                   '授权店'
                                  when a.bass_org_type in (7, 8) or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('合作厅', '外包厅') then
                                   '加盟店'
                                  when a.bass_org_type = 10 then
                                   '社会电子渠道'
                                  when a.org_name = '沪动商城渠道商' then
                                   '自营电子渠道'
                                  when nvl(a.org_name, b.org_name) in
                                       ('迪信通渠道商',
                                        '蜂星',
                                        '美承',
                                        '移达',
                                        '茗神渠道商',
                                        '井通',
                                        '盛南',
                                        '本地二码合一') then
                                   '授权店'
                                  when nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       '电子渠道' then
                                   '社会电子渠道'
                                end as Kind_Name2,
                                case
                                  when a.org_name = '电商服务支撑部' then
                                   '网店'
                                  when a.bass_org_type = 6 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       '自营厅' then
                                   '标准店'
                                  when a.bass_org_type = 1 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       '星级连锁门店' then
                                   '手机卖场'
                                  when a.bass_org_type = 2 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       '渠道直供店' then
                                   '手机专卖店+授权代理店'
                                  when a.bass_org_type = 3 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       '专营店' then
                                   '手机专卖店'
                                  when a.bass_org_type = 4 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('购机中心', '中国移动购机中心', '指定授权店') then
                                   '授权代理店'
                                  when a.bass_org_type = 5 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('代理商', '转型网点', '井通通信受理权限') then
                                   '授权代理店'
                                  when a.bass_org_type in (7, 8) or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('合作厅', '外包厅') then
                                   '加盟营业厅'
                                  when a.bass_org_type = 9 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('终端代理商', '连锁渠道', '连锁商转型网点') then
                                   '手机卖场'
                                  when a.bass_org_type = 10 then
                                   '互联网分销'
                                  when a.org_name = '沪动商城渠道商' then
                                   '网店'
                                  when nvl(a.org_name, b.org_name) in
                                       ('迪信通渠道商',
                                        '蜂星',
                                        '美承',
                                        '移达',
                                        '茗神渠道商') then
                                   '手机卖场'
                                  when nvl(a.org_name, b.org_name) in
                                       ('井通', '盛南', '本地二码合一') then
                                   '手机专卖店'
                                end as Kind_Name3,
                                a.org_id,
                                null as Op_Id,
                                a.bass_org_type as Crm_Org_Type,
                                nvl(a.bass_org_type_name, a.boss_org_type_name) as Crm_Org_Type_Name,
                                b.busi_chl_type_name as Crm_Org_Kind,
                                nvl(a.org_name, b.org_name) as Crm_Org_Name,
                                null as Op_Name,
                                null as Login_Name,
                                null as Node_Id,
                                null as Node_Name,
                                a.chl_kind as Node_Kind,
                                a.chl_type as Node_Type,
                                a.chl_mode,
                                null as Node_Level,
                                null as Node_Status,
                                null as Operate_Type,
                                null as Node_Entity_Type,
                                null as District_Id,
                                null as Valid_Date,
                                null as Expire_Date,
                                null as Node_Create_Date,
                                null as Node_Done_Date,
                                null as Check_Date,
                                null as Channel_Entity_Serial,
                                null as Self_Status,
                                null as Self_Status_Name,
                                null as Node_Addr,
                                null as Business_Start_Date,
                                null as Agent_Id,
                                null as Agent_Short_Name,
                                null as Agent_Name,
                                null as Belong_Org_Id,
                                null as Belong_Org_Name,
                                null as Test_Busi_Flag,
                                null as Org_Id,
                                null as Org_Name,
                                null as Agent_Type,
                                null as Agent_Type_Name,
                                null as Agent_Type_Alias,
                                null as Agent_Level,
                                null as Agent_Level_Name,
                                null as Agent_Status,
                                null as Pay_Type,
                                null as Pay_Type_Name,
                                null as Agent_Valid_Date,
                                null as Agent_Expire_Date,
                                null as Agent_Create_Date,
                                null as Agent_Done_Date,
                                1 as Is_Valid,
                                '$miExecDayF' as Create_Date,
                                '$miExecDayF' as Modify_Date
                  from (select org_id,
                               org_name,
                               bass_org_type,
                               bass_org_type_name,
                               boss_org_type,
                               boss_org_type_name,
                               chl_kind,
                               chl_type,
                               chl_mode,
                               row_number() over(partition by org_id order by start_date desc, end_date desc) as Seq_No
                          from ${TDim_Prty_Org_Info}
                         where start_date < '$miExecMonthF-01') a
                  left join (select org_id,
                                    org_name,
                                    busi_chl_type_name,
                                    row_number() over(partition by org_id order by cnt desc) as Seq_No
                               from (select org_id,
                                            org_name,
                                            busi_chl_type_name,
                                            count(op_id) as Cnt
                                       from (select org_id,
                                                    org_name,
                                                    op_id,
                                                    op_name,
                                                    login_name,
                                                    busi_chl_type_name,
                                                    row_number() over(partition by op_id order by start_date desc, end_date desc) as Seq_No
                                               from ${TDim_Prty_Oper_Info}
                                              where upper(nvl(login_name, '-1')) like
                                                    '%GSJK%'
                                                and start_date < '$miExecMonthF-01'
                                                and org_id not in (99999, 19999))
                                      where seq_no = 1
                                      group by org_id, org_name, busi_chl_type_name)) b
                    on a.org_id = b.org_id
                   and b.seq_no = 1
                  left join (select crm_org_id
                               from $Rpt_Dim_Channel_Org_Op_Info
                              where crm_org_id is not null
                                and op_id is null
                                and create_date = '$miExecDayF') c
                    on a.org_id = c.crm_org_id
                 where a.seq_no = 1
                   and c.crm_org_id is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#自助终端补漏
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                (org_class1,
                 org_class2,
                 org_class3,
                 op_id,
                 op_name,
                 is_valid,
                 create_date,
                 modify_date)
                select '电子渠道',
                       '自营电子渠道',
                       '自助终端',
                       a.op_id,
                       '补漏',
                       1,
                       '$miExecDayF',
                       '$miExecDayF'
                  from (select int(terminalopid) as op_id
                          from ${TOds_Db_Ap_Atm_Pcsettingext_}$PreDayF
                         where terminalcode <> '123456789012345' -- 老自助终端
                           and terminalopid is not null
                        union
                        select int(termdesp) as op_id
                          from ${TOds_Term_}$PreDayF -- 新的凯信达机器
                         where substr(termdesp, 1, 1) between '0' and '9') a
                  left join $Rpt_Dim_Channel_Org_Op_Info b
                    on a.op_id = b.op_id
                   and b.org_class3 = '自助终端'
                 where b.op_id is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#垃圾数据清洗
if ! DB2_Cmd "delete from $Rpt_Dim_Channel_Org_Op_Info
               where op_id in (select op_id
                                 from $Rpt_Dim_Channel_Org_Op_Info
                                where op_id in (select op_id
                                                  from $Rpt_Dim_Channel_Org_Op_Info
                                                 where create_date = '$miExecDayF'
                                                 group by op_id
                                                having count(*) > 1)
                                  and org_class3 = '自助终端'
                                  and create_date = '$miExecDayF')
                 and org_class3 <> '自助终端'
                 and create_date = '$miExecDayF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "delete from $Rpt_Dim_Channel_Org_Op_Info
               where crm_org_id in (select a.crm_org_id
                                      from $Rpt_Dim_Channel_Org_Op_Info a,
                                           (select crm_org_id
                                              from $Rpt_Dim_Channel_Org_Op_Info
                                             where crm_org_id is not null
                                               and op_id is null
                                               and create_date = '$miExecDayF'
                                             group by crm_org_id
                                            having count(*) > 1) b
                                     where a.crm_org_id = b.crm_org_id
                                       and a.op_id is null
                                       and a.org_class1 is null
                                       and a.crm_org_kind = 'BOSS'
                                       and a.create_date = '$miExecDayF')
                 and op_id is null
                 and org_class1 is null
                 and nvl(crm_org_kind, '-1') <> 'BOSS'
                 and create_date = '$miExecDayF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "delete from $Rpt_Dim_Channel_Org_Op_Info
               where crm_org_id in
                     (select crm_org_id
                        from $Rpt_Dim_Channel_Org_Op_Info
                       where crm_org_id in (select crm_org_id
                                              from $Rpt_Dim_Channel_Org_Op_Info
                                             where crm_org_id is not null
                                               and op_id is null
                                               and create_date = '$miExecDayF'
                                             group by crm_org_id
                                            having count(*) > 1)
                         and op_id is null
                         and crm_org_kind = 'BOSS'
                         and create_date = '$miExecDayF')
                 and op_id is null
                 and nvl(crm_org_kind, '-1') <> 'BOSS'
                 and create_date = '$miExecDayF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#数据修复
if ! DB2_Cmd "update $Rpt_Dim_Channel_Org_Op_Info
                 set org_class1 = '实体渠道'
               where org_class1 is null
                 and org_class2 is not null
                 and org_class2 in ('加盟店', '授权店', '直营店')
                 and create_date = '$miExecDayF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#同高爽沟通，终端卖场、校园店、中心店、辅厅全部算在标准店，家庭业务代理店、其它网点（含购机中心）算在授权店
if ! DB2_Cmd "runstats on table $Rpt_Dim_Channel_Org_Op_Info" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
DB2_Truncate $mTemp_Node_Agent_Info2 "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Node_Agent_Info2 "$LogFile"-`date +%Y%m%d`
DB2_Truncate $mTemp_Sys_Operation "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Sys_Operation "$LogFile"-`date +%Y%m%d`





#建立营业侧补充的IMEI对应的终端类型
WriteStatusFile 1 5 $$ $StatusFile "" "兜取营业仓库IMEI规格信息……"
if DB2_Check 0 1 0 "" $mTemp_Imei_Map "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Imei_Map "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
	if ! DB2_Drop $mTemp_Imei_Map "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "create table $mTemp_Imei_Map(
              imei_14     varchar(14),
              imei_8      varchar(8),
              res_spec_id bigint,
              termi_type  smallint
              ) in $TableSpace partitioning key(imei_14) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Imei_Map activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Imei_Map
                select substr(a.imei, 1, 14) as Imei_14, substr(a.imei, 1, 8) as Imei_8, a.res_spec_id, b.termi_type
                  from (select imei,
                               res_spec_id,
                               row_number() over(partition by imei order by done_date desc) as Seq_No
                          from ${TOds_Res_Terminal_Origin_}$PreMonthF
                         where status = '1'
                           and expire_date > '$miPreMonthF-01 00:00:00.000000') a,
                       ${TOds_Res_Spec_}$PreMonthF b
                 where a.seq_no = 1
                   and a.res_spec_id = b.res_spec_id
                   and b.state = 'U'
                   and b.expire_date > '$miPreMonthF-01 00:00:00.000000'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $mTemp_Imei_Map" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if DB2_Check 0 1 0 "" $mTemp_Imei_Map2 "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $mTemp_Imei_Map2 "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
	if ! DB2_Drop $mTemp_Imei_Map2 "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "create table $mTemp_Imei_Map2(
              imei_14     varchar(14),
              imei_8      varchar(8),
              res_spec_id bigint,
              termi_type  smallint
              ) in $TableSpace partitioning key(imei_14) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Imei_Map2 activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Imei_Map2
                select substr(a.imei, 1, 14) as Imei_14, substr(a.imei, 1, 8) as Imei_8, a.res_spec_id, b.termi_type
                  from (select imei,
                               res_spec_id,
                               row_number() over(partition by imei order by done_date desc) as Seq_No
                          from ${TOds_Res_Terminal_Used_}$PreMonthF
                         where status = '1'
                           and expire_date > '$miPreMonthF-01 00:00:00.000000') a,
                       ${TOds_Res_Spec_}$PreMonthF b
                 where a.seq_no = 1
                   and a.res_spec_id = b.res_spec_id
                   and b.state = 'U'
                   and b.expire_date > '$miPreMonthF-01 00:00:00.000000'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Imei_Map2
                select a.*
                  from $mTemp_Imei_Map       a
                  left join $mTemp_Imei_Map2 b
                    on a.imei_14 = b.imei_14
                 where b.imei_14 is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $mTemp_Imei_Map2" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
DB2_Truncate $mTemp_Imei_Map "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Imei_Map "$LogFile"-`date +%Y%m%d`
if ! DB2_Cmd "create table $mTemp_Imei_Map(
              imei_8     varchar(8),
              termi_type smallint
              ) in $TableSpace partitioning key(imei_8) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "alter table $mTemp_Imei_Map activate not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $mTemp_Imei_Map
                select imei_8, termi_type
                  from (select imei_8,
                               termi_type,
                               row_number() over(partition by imei_8 order by cnt desc) as Seq_No
                          from (select imei_8, termi_type, count(*) as Cnt
                                  from $mTemp_Imei_Map2
                                 group by imei_8, termi_type))
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $mTemp_Imei_Map" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
DB2_Truncate $mTemp_Imei_Map2 "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Imei_Map2 "$LogFile"-`date +%Y%m%d`





#定制终端维表
WriteStatusFile 1 6 $$ $StatusFile "" "兜取分析IMEI对应终端类型……"
if ! DB2_Check 0 1 0 "" $Rpt_Dim_Termi "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Dim_Termi(
	              KEY_IMEI          VARCHAR(10), -- 取IMEI前8位
	              MOBILE_FLAG       VARCHAR(20), -- 针对一经的数据
	              MOBILE_TYPE       VARCHAR(40),
	              SRC_FLAG          VARCHAR(10), -- 来源标志:一经,营业
	              CREATE_YEAR_MONTH VARCHAR(10),
	              MODIFY_DATE       DATE
	              ) data capture none in $TableSpace partitioning key(KEY_IMEI,CREATE_YEAR_MONTH) using hashing" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "delete from $Rpt_Dim_Termi where create_year_month='$PreMonthF' or create_year_month<=replace(substr(current date - 6 months,1,7),'-','')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Dim_Termi
                select distinct rtrim(t2.tac) as Key_Imei,
                                 (case
                                   when t1.model4g in ('1', '3') then
                                    'TDLTE'
                                   when t1.model3g in ('3', '5', '6', '7') then
                                    'TDSCDMA'
                                   else
                                    '2G'
                                 end) as Mobile_Flag,
                                 (case
                                   when t1.type_id in ('01', '06') and
                                        t1.model4g in ('1', '3') then
                                    'TDLTE手机'
                                   when t1.type_id in ('01', '06') and
                                        t1.model3g in ('3', '5', '6', '7') then
                                    'TDSCDMA手机'
                                   when t1.type_id in ('02', '07') and
                                        t1.model4g in ('1', '3') then
                                    'TDLTE数据卡'
                                   when t1.type_id in ('02', '07') and
                                        t1.model3g in ('3', '5', '6', '7') then
                                    'TDSCDMA数据卡'
                                   when t1.type_id = '03' and t1.model4g in ('1', '3') then
                                    'TDLTE上网本'
                                   when t1.type_id = '03' and t1.model3g in ('3', '5', '6', '7') then
                                    'TDSCDMA上网本'
                                   when t1.type_id = '04' and t1.model4g in ('1', '3') then
                                    'TDLTEMIFI'
                                   when t1.type_id = '04' and t1.model3g in ('3', '5', '6', '7') then
                                    'TDSCDMAMIFI'
                                   when t1.type_id = '05' and t1.model4g in ('1', '3') then
                                    'TDLTE无线固话'
                                   when t1.type_id = '05' and t1.model3g in ('3', '5', '6', '7') then
                                    'TDSCDMA无线固话'
                                   when t1.type_id = '08' and t1.model4g in ('1', '3') then
                                    'TDLTECPE'
                                   else
                                    '2G终端'
                                 end) as Mobile_Type,
                                 '一经' as Src_Flag,
                                 '$PreMonthF' as Create_Year_Month,
                                 current date as Modify_Date
                   from ${TOds_Bass1_91003_}$PreMonthF t1,
                        ${TOds_Bass1_91002_}$PreMonthF t2
                  where t1.device_id = t2.device_id" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Dim_Termi
                select a.imei_8,
                       (case
                         when a.termi_type in (7, 8) then
                          'TDLTE'
                         when a.termi_type in (2, 3, 4, 5, 6) then
                          'TDSCDMA'
                         else
                          '2G'
                       end) as Mobile_Flag,
                       (case
                         when a.termi_type = 7 then
                          'TDLTE手机'
                         when a.termi_type = 3 then
                          'TDSCDMA手机'
                         when a.termi_type = 4 then
                          'TDSCDMA数据卡'
                         when a.termi_type = 2 then
                          'TDSCDMA上网本'
                         when a.termi_type = 8 then
                          'TDLTEMIFI'
                         when a.termi_type = 6 then
                          'TDSCDMAMIFI'
                         when a.termi_type = 5 then
                          'TDSCDMA无线固话'
                         else
                          '2G终端'
                       end) as Mobile_Type,
                       '营业' as Src_Flag,
                       '$PreMonthF' as Create_Year_Month,
                       current date as Modify_Date
                  from $mTemp_Imei_Map a
                  left join $Rpt_Dim_Termi b
                    on a.imei_8 = b.key_imei
                   and b.create_year_month = '$PreMonthF'
                 where b.key_imei is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Dim_Termi" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
DB2_Truncate $mTemp_Imei_Map "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Imei_Map "$LogFile"-`date +%Y%m%d`





#智能机终端维表
WriteStatusFile 1 7 $$ $StatusFile "" "兜取分析智能终端维表……"
if DB2_Check 0 1 0 "" $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
	if ! DB2_Drop $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "create table $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF(
              KEY_IMEI      VARCHAR(10),
              OS_TYPE       VARCHAR(20),
              OS_TYPE_ALIAS VARCHAR(100), -- 针对一经的数据
              BRAND_NAME    VARCHAR(40),
              TYPE_NAME     VARCHAR(40),
              MAKE_TYPE     VARCHAR(20), -- TD
              MAKE_TYPE2    VARCHAR(20), -- TD-SCDMA,TD-LTE
              SRC_FLAG      SMALLINT     -- 源头标志:1-一经,2-经分
              ) in $TableSpace partitioning key(key_imei) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#先以一经为准
if ! DB2_Cmd "insert into $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF
                select distinct rtrim(b.tac) as Key_Imei,
                                null as Os_Type,
                                rtrim(a.sys_version) as Os_Type_Alias,
                                rtrim(a.plan) as Brand_Name,
                                rtrim(a.model) as Type_Name,
                                (case
                                  when a.type_id in ('01', '06') and
                                       (a.model4g in ('1', '3') or
                                       a.model3g in ('3', '5', '6', '7')) then
                                   'TDSCDMA'
                                  when a.type_id in ('01', '06') and a.model4g = '2' then
                                   '它网4G手机'
                                  when a.type_id in ('01', '06') and
                                       a.model3g in ('1', '2', '4') then
                                   '它网3G手机'
                                  when a.type_id in ('01', '06') and
                                       a.model2g in ('1', '2', '3') then
                                   '2G手机'
                                  when a.type_id = '02' then
                                   '数据卡'
                                  when a.type_id = '03' then
                                   '上网本'
                                  when a.type_id = '04' then
                                   'MIFI'
                                  when a.type_id = '05' then
                                   '无线固话'
                                  when a.type_id = '06' then
                                   '手机阅读'
                                  when a.type_id = '07' then
                                   '平板电脑'
                                  when a.type_id = '08' then
                                   'CPE'
                                  when a.type_id = '00' then
                                   '行业终端'
                                end) as Make_Type,
                                (case
                                  when a.model4g in ('1', '3') then
                                   'TDLTE'
                                  when a.model3g in ('3', '5', '6', '7') then
                                   'TDSCDMA'
                                end) as Make_Type2,
                                1 as Src_Flag
                  from ${TOds_Bass1_91003_}$PreMonthF a, ${TOds_Bass1_91002_}$PreMonthF b
                 where a.device_id = b.device_id
                   and substr(a.system, 1, 1) = 2" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF
                select d.key_imei,
                       upper(d.os_type) as Os_Type,
                       d.os_type as Os_Type_Alias,
                       d.brand_name,
                       d.type_name,
                       d.make_type,
                       'TDSCDMA' as Make_Type2,
                       2 as src_flag
                  from (select distinct b.key_imei,
                                        b.key_length,
                                        a.oper_platform as os_type,
                                        c.brand_name,
                                        c.type_name,
                                        c.product_type,
                                        a.mobile_style,
                                        case
                                          when c.product_type = 1 then
                                           '2G手机'
                                          when c.product_type = 2 then
                                           'TDSCDMA'
                                          when c.product_type = 9 then
                                           '平板电脑'
                                          else
                                           '请维护'
                                        end as make_type
                          from ${TDim_Brandname_Typename_Baseinfo} a,
                               ${TDim_Imei_Termi}                  b,
                               ${TDim_Termi_Base}                  c
                         where a.term_id = b.term_id
                           and b.is_valid = 1
                           and b.term_id = c.handset_type
                           and c.is_valid = 1
                           and upper(a.oper_platform) in ('ANDROID',
                                                          'BADA',
                                                          'BB',
                                                          'BREW',
                                                          'LINUX',
                                                          'MAEMO5',
                                                          'MEEGO',
                                                          'OMS',
                                                          'PALM OS',
                                                          'S60',
                                                          'SYMBIAN3',
                                                          'WINCE',
                                                          'WM',
                                                          'WP7',
                                                          'WP8', -- 2013/8/27 增加
                                                          '其他智能机', -- 2013/9/2 增加
                                                          'IOS')) d
                  left join (select f.tac
                               from ${TOds_Bass1_91003_}$PreMonthF e,
                                    ${TOds_Bass1_91002_}$PreMonthF f
                              where e.device_id = f.device_id) g
                    on d.key_imei = g.tac
                 where d.key_length = 8 -- 2014/2/3 经分的小于5位时，一经的8位有部分不全是智能机，这样的话判断逻辑过于复杂，故简化
                   and g.tac is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#修正操作系统
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='ANDROID' where upper(os_type_alias) like 'ANDROID%' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='ALIYUN' where (upper(os_type_alias) like 'ALIYUN%' or os_type_alias like '阿里云%') and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='BADA' where upper(os_type_alias) like 'BADA%' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='BB' where upper(os_type_alias) like 'BLACKBERRY%' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='IOS' where upper(os_type_alias) like 'IOS%' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='LINUX' where upper(os_type_alias) like 'LINUX%' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='S40' where upper(os_type_alias)='SYMBIAN S40' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='SYMBIAN' where upper(os_type_alias) like 'SYMBIAN%' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='WP8' where upper(os_type_alias)='WINDOWS PHONE 8.0' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='WP7' where upper(os_type_alias)='WINDOWS PHONE 7.5' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='WINCE' where upper(os_type_alias)='WINDOWS' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='WM' where upper(os_type_alias)='WINDOWS 8.0' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='PALM OS' where upper(os_type_alias)='PALM' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='OMS' where upper(os_type_alias)='OMS' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type=upper(os_type) where os_type is null and src_flag=1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#2014/7/28 集团要求剔除塞班系统 2014年0月计费月报14、7、21.xls
if ! DB2_Cmd "delete from $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF where os_type like 'SYMBIAN%' or os_type in ('S40','S60') or upper(os_type_alias) like '%SYMBIAN%'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi





#2014/9/25 增加IMEI对应的RES_SPEC_ID关系
WriteStatusFile 1 8 $$ $StatusFile "" "构建IMEI与规格映射表……"
if DB2_Check 0 1 0 "" $Rpt_Imei_Res_Spec "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Truncate $Rpt_Imei_Res_Spec "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
	if ! DB2_Drop $Rpt_Imei_Res_Spec "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "create table $Rpt_Imei_Res_Spec(
              SRC           VARCHAR(6), -- 来源:origin-仓库,used-出库
              IMEI          VARCHAR(25),
              RES_SPEC_ID   BIGINT, -- 资源规格编号
              TERMI_TYPE    SMALLINT,
              RES_SPEC_NAME VARCHAR(256),
              STATUS        SMALLINT, -- 常见:-1-空,0-无效,1-有效
              EXPIRE_DATE   TIMESTAMP,
              FLAG          SMALLINT -- 标志:0-无效,1-有效
              ) in $TableSpace partitioning key (SRC, IMEI) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Imei_Res_Spec
                select 'used' as Src, imei, res_spec_id, null, null, status, expire_date, 0 as Flag
                  from (select imei,
                               res_spec_id,
                               status,
                               case
                                 when expire_date > sysdate + 20 year then
                                  timestamp(date(sysdate) || ' 00:00:00') + 20 year
                                 else
                                  expire_date
                               end as Expire_Date,
                               row_number() over(partition by imei order by nvl(to_number(status), -1) desc,case
                                 when expire_date >
                                      sysdate + 20 year then
                                  timestamp(date(sysdate) ||
                                            ' 00:00:00') + 20 year
                                 else
                                  expire_date
                               end desc, effective_date desc) as Seq_No
                          from ${TOds_Res_Terminal_Used_}$PreMonthF)
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Imei_Res_Spec
                select 'origin' as Src, imei, res_spec_id, null, null, status, expire_date, 0 as Flag
                  from (select imei,
                               res_spec_id,
                               status,
                               case
                                 when expire_date > sysdate + 20 year then
                                  timestamp(date(sysdate) || ' 00:00:00') + 20 year
                                 else
                                  expire_date
                               end as Expire_Date,
                               row_number() over(partition by imei order by nvl(to_number(status), -1) desc,case
                                 when expire_date >
                                      sysdate + 20 year then
                                  timestamp(date(sysdate) ||
                                            ' 00:00:00') + 20 year
                                 else
                                  expire_date
                               end desc, effective_date desc) as Seq_No
                          from ${TOds_Res_Terminal_Origin_}$PreMonthF)
                 where seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#插入IMEI规格唯一的数据
if ! DB2_Cmd "insert into $Rpt_Imei_Res_Spec
                select a.src,
                       a.imei,
                       a.res_spec_id,
                       c.termi_type,
                       c.res_spec_name,
                       a.status,
                       a.expire_date,
                       1 as Flag
                  from $Rpt_Imei_Res_Spec a
                 inner join (select imei
                               from (select distinct imei, res_spec_id
                                       from $Rpt_Imei_Res_Spec
                                      where flag = 0)
                              group by imei
                             having count(*) = 1) b
                    on a.imei = b.imei
                  left join ${TOds_Res_Spec_}$PreMonthF c
                    on a.res_spec_id = c.res_spec_id
                   and c.state = 'U'
                 where a.flag = 0
                   and a.src = 'used'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Imei_Res_Spec
                select a.src,
                       a.imei,
                       a.res_spec_id,
                       c.termi_type,
                       c.res_spec_name,
                       a.status,
                       a.expire_date,
                       1 as Flag
                  from $Rpt_Imei_Res_Spec a
                 inner join (select imei
                               from (select distinct imei, res_spec_id
                                       from $Rpt_Imei_Res_Spec
                                      where flag = 0)
                              group by imei
                             having count(*) = 1) b
                    on a.imei = b.imei
                  left join ${TOds_Res_Spec_}$PreMonthF c
                    on a.res_spec_id = c.res_spec_id
                   and c.state = 'U'
                  left join $Rpt_Imei_Res_Spec d
                    on a.imei = d.imei
                   and d.flag = 1
                 where a.flag = 0
                   and a.src = 'origin'
                   and d.imei is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#删除已不需要的数据
if ! DB2_Cmd "delete from $Rpt_Imei_Res_Spec a
               where flag = 0
                 and exists (select null
                        from $Rpt_Imei_Res_Spec b
                       where flag = 1
                         and imei = a.imei)" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#遴选唯一的res_spec_id
if ! DB2_Cmd "insert into $Rpt_Imei_Res_Spec
                select b.src,
                       b.imei,
                       b.res_spec_id,
                       c.termi_type,
                       c.res_spec_name,
                       b.status,
                       b.expire_date,
                       1 as Flag
                  from (select a.*,
                               row_number() over(partition by imei order by status desc, expire_date desc, src desc) as Seq_No
                          from $Rpt_Imei_Res_Spec a
                         where flag = 0
                           and res_spec_id is not null) b
                  left join ${TOds_Res_Spec_}$PreMonthF c
                    on b.res_spec_id = c.res_spec_id
                   and c.state = 'U'
                 where b.seq_no = 1" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Imei_Res_Spec" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi





#账户级套餐关系表
WriteStatusFile 1 9 $$ $StatusFile "" "构建账户级套餐关系表……"
if ! DB2_Check 0 1 0 "" "$Rpt_Acc_Plan_Detail_$PreMonthF" "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Acc_Plan_Detail_$PreMonthF(
	                ACCT_ID            VARCHAR(20),
	                USER_ID            VARCHAR(20),
	                CUST_ID            VARCHAR(20),
	                PHONE_NO           VARCHAR(25),
	                OFFER_ID           BIGINT,
	                BOSS_USER_STATE_ID SMALLINT,
	                BASS_USER_STATE_ID SMALLINT,
	                ACTIVE_DATE        DATE,
	                DONE_DATE          DATE
                ) in $TableSpace partitioning key(ACCT_ID) not logged initially" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
	#全量用户表视图
	if ! DB2_Cmd "create or replace view $Rpt_Svc_Usr_Info_$PreMonthF AS
	                select user_id,
	                       acct_id,
	                       cust_id,
	                       phone_no,
	                       active_date,
	                       pre_destory_date,
	                       last_trans_date,
	                       boss_user_state_id,
	                       bass_user_state_id,
	                       bass1_user_state_id,
	                       credit_level,
	                       credit_owe,
	                       boss_user_type,
	                       bass_user_type,
	                       notice_type,
	                       outnet_flag,
	                       done_date,
	                       os_state,
	                       offer_id,
	                       billing_type,
	                       offer_org_id,
	                       imsi,
	                       create_op_id,
	                       create_org_id,
	                       create_date,
	                       exp_date,
	                       join_date,
	                       real_type,
	                       1                   as User_Type
	                  from ${TDwd_Svc_Usr_All_Info_}$PreMonthF
	                union all
	                select user_id,
	                       acct_id,
	                       cust_id,
	                       phone_no,
	                       active_date,
	                       pre_destory_date,
	                       last_trans_date,
	                       boss_user_state_id,
	                       bass_user_state_id,
	                       bass1_user_state_id,
	                       credit_level,
	                       credit_owe,
	                       boss_user_type,
	                       bass_user_type,
	                       notice_type,
	                       outnet_flag,
	                       exp_date            as Done_Date,
	                       os_state,
	                       offer_id,
	                       billing_type,
	                       offer_org_id,
	                       imsi,
	                       op_id,
	                       org_id,
	                       create_date,
	                       exp_date,
	                       null                as Create_Org_Id,
	                       null                as Create_Org_Id,
	                       2                   as User_Type
	                  from ${TDwd_Svc_Usr_Info_Des_Dm_}$YearBeforePreMonth
	                union all
	                select user_id,
	                       acct_id,
	                       cust_id,
	                       phone_no,
	                       active_date,
	                       pre_destory_date,
	                       last_trans_date,
	                       boss_user_state_id,
	                       bass_user_state_id,
	                       bass1_user_state_id,
	                       credit_level,
	                       credit_owe,
	                       boss_user_type,
	                       bass_user_type,
	                       notice_type,
	                       outnet_flag,
	                       exp_date            as Done_Date,
	                       os_state,
	                       offer_id,
	                       billing_type,
	                       offer_org_id,
	                       imsi,
	                       op_id,
	                       org_id,
	                       create_date,
	                       exp_date,
	                       null                as Create_Org_Id,
	                       null                as Create_Org_Id,
	                       2                   as User_Type
	                  from ${TDwd_Svc_Usr_Info_Des_Dm_}$PreMonthinYear
	                 where op_date < '$miPreMonthF-01'" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
#清理数据
if ! DB2_Truncate $Rpt_Acc_Plan_Detail_$PreMonthF "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#对于非销户、冷号的记录取账户对应用户群中激活时间最早的用户对应套餐
#对于已冷号或销户的记录取账户对应用户群中冷号回收时间最近的用户对应套餐
if ! DB2_Cmd "insert into $Rpt_Acc_Plan_Detail_$PreMonthF
                WITH T1
                (ACCT_ID,
                 USER_ID,
                 CUST_ID,
                 PHONE_NO,
                 OFFER_ID,
                 BOSS_USER_STATE_ID,
                 BASS_USER_STATE_ID,
                 ACTIVE_DATE,
                 DONE_DATE) AS
                 (select acct_id,
                         user_id,
                         cust_id,
                         phone_no,
                         offer_id,
                         boss_user_state_id,
                         bass_user_state_id,
                         active_date,
                         done_date
                    from (select acct_id,
                                 user_id,
                                 cust_id,
                                 phone_no,
                                 offer_id,
                                 boss_user_state_id,
                                 bass_user_state_id,
                                 active_date,
                                 done_date,
                                 row_number() over(partition by acct_id order by nvl(join_date, '2099-12-31')) as Row_Num
                            from $Rpt_Svc_Usr_Info_$PreMonthF
                           where bass_user_state_id not in (105, 109)) g
                   where row_num = 1),
                T2
                (ACCT_ID,
                 USER_ID,
                 CUST_ID,
                 PHONE_NO,
                 OFFER_ID,
                 BOSS_USER_STATE_ID,
                 BASS_USER_STATE_ID,
                 ACTIVE_DATE,
                 DONE_DATE) AS
                 (select acct_id,
                         user_id,
                         cust_id,
                         phone_no,
                         offer_id,
                         boss_user_state_id,
                         bass_user_state_id,
                         active_date,
                         done_date
                    from (select acct_id,
                                 user_id,
                                 cust_id,
                                 phone_no,
                                 offer_id,
                                 boss_user_state_id,
                                 bass_user_state_id,
                                 active_date,
                                 done_date,
                                 row_number() over(partition by acct_id order by done_date desc) as Row_Num
                            from $Rpt_Svc_Usr_Info_$PreMonthF
                           where bass_user_state_id in (105, 109)) g
                   where row_num = 1),
                T3
                (ACCT_ID,
                 USER_ID,
                 CUST_ID,
                 PHONE_NO,
                 OFFER_ID,
                 BOSS_USER_STATE_ID,
                 BASS_USER_STATE_ID,
                 ACTIVE_DATE,
                 DONE_DATE) AS
                 (select t2.*
                    from t2
                    left join t1
                      on t2.acct_id = t1.acct_id
                   where t1.acct_id is null)
                select * from t1 union all select * from T3" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Acc_Plan_Detail_$PreMonthF" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi





#更新铁通账户
WriteStatusFile 1 10 $$ $StatusFile "" "更新铁通账户……"
if ! DB2_Check 0 1 0 "" $Rpt_Tietong_Accid_Del "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Tietong_Accid_Del(
	                stat_month varchar(10),
	                acc_id     varchar(20)
	              ) in $TableSpace partitioning key(acc_id) not logged initially" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
if ! DB2_Cmd "delete from $Rpt_Tietong_Accid_Del where stat_month='$PreMonthF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Tietong_Accid_Del
                select distinct '$PreMonthF', acct_id
                  from $Rpt_Svc_Usr_Info_$PreMonthF
                 where offer_id = 340000000964" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Tietong_Accid_Del" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi





#产品维表
WriteStatusFile 1 11 $$ $StatusFile "" "构建产品维表……"
if ! DB2_Check 0 1 0 "" "$Rpt_Svc_Prod_Service" "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Svc_Prod_Service(
	                PROD_ID      BIGINT,
	                BOSS_PROD_ID BIGINT,
	                SERVICE_ID   BIGINT
                ) in $TableSpace partitioning key(PROD_ID) not logged initially" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
#清理数据
if ! DB2_Truncate $Rpt_Svc_Prod_Service "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Svc_Prod_Service
                select a.prod_id, b.extend_id as boss_prod_id, a.service_id
                  from (select prod_id, service_id
                          from ${TDim_Svc_Prod}
                        union
                        select product_item_id       as prod_id,
                               relat_product_item_id as service_id
                          from ${TOds_Crm_Up_Item_Relat_}$PreDayF
                         where prod_item_relat_kind_id = 'SRVC_SINGLE_PRICE_SERVICE') a
                 inner join ${TOds_Crm_Up_Product_Item_}$PreMonthF b
                    on a.prod_id = b.product_item_id" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Svc_Prod_Service" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi





#全量产品订购信息
WriteStatusFile 1 12 $$ $StatusFile "" "构建全量产品订购信息表……"
if ! DB2_Check 0 1 0 "" "$Rpt_Svc_Prod_Inst_$PreMonthF" "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Svc_Prod_Inst_$PreMonthF(
	                USER_ID            VARCHAR(100),
	                PROD_ID            BIGINT,
	                SERVICE_ID         BIGINT,
	                BOSS_USER_STATE_ID SMALLINT,
	                EFFECTIVE_DATE     TIMESTAMP,
	                EXPIRE_DATE        TIMESTAMP,
	                CREATE_DATE        TIMESTAMP
                ) in $TableSpace partitioning key(USER_ID) not logged initially" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
fi
#清理数据
if ! DB2_Truncate $Rpt_Svc_Prod_Inst_$PreMonthF "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "insert into $Rpt_Svc_Prod_Inst_$PreMonthF
                select a.user_id,
                       a.prod_id,
                       c.service_id,
                       b.boss_user_state_id,
                       a.effective_date,
                       a.expire_date,
                       a.create_date
                  from (select *
                          from ${TOds_Ins_Prod_}$PreMonthF
                         where substr(effective_date, 1, 7) <= '$miPreMonthF'
                           and substr(expire_date, 1, 7) > '$miPreMonthF') a
                 inner join (select user_id, boss_user_state_id
                               from ${TDwd_Svc_Usr_All_Info_}$PreMonthF
                              where boss_user_state_id <> 3) b
                    on a.user_id = b.user_id
                  left join (select prod_id, service_id
                               from ${TDim_Svc_Prod}
                             union
                             select product_item_id, relat_product_item_id
                               from ${TOds_Crm_Up_Item_Relat_}$PreDayF
                              where prod_item_relat_kind_id = 'SRVC_SINGLE_PRICE_SERVICE') c
                    on a.prod_id = c.prod_id" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Svc_Prod_Inst_$PreMonthF" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi




WriteStatusFile 0 0 $$ $StatusFile "" "集中维表程序结束……"

