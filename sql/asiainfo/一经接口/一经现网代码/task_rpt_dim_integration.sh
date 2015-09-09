#!/data/rpt/changtaihua_shell/bin/bash

#��������:���ֲƱ��ն�ά����
#��������:�ϱ������౨��
#ͳ������:ÿ��5��
#����:
#����:���н�������DW�������ݻ��ܳ���Ӧά��
#     1��������֯ά��
#     2���ն�����ά��
#     3�������ն�ά���£�
#     4���ն�IMEI����ӳ���
#     5����ͨ�ʻ���
#     6���ʻ��ײ�ӳ����£�


#����:      ����
#����ʱ��:  2014/03/03
#�޸�ʱ��:  2015/03/05
#SQL�ṩ��: ����


#��׼���������޸�!!!
ScriptDir=`dirname "$0"`
ScriptName=`basename "$0"`
ScriptDir=`pwd | awk -v value="$ScriptDir" 'BEGIN {if (value==".") value=""; else {if (substr(value,1,2)=="./") value=substr(value,3)}} {if (substr(value,1,1)!="/") print $0"/"value; else print value}'`
OS=`uname -a | awk '{print $1}'`

#��������
AwkPath=../awkset                               #��Ŵ������ű�
SqlPath=../sqlset                               #���sql�ӽű�
PerlPath=../perlset                             #���perl�ӽű�
CfgPath=../cfg                                  #����Ŀ¼
TmpDir=/tmp/TaskSchedule                        #����ǰ����ʱĿ¼
CleanLogFlag=0                                  #�����־��־:0-����,1-ɾ��
BreakFlag=0                                     #�ϵ�ִ�б�־:0-������,1-ֻ�ܴ��ϴζϵ���ִ��
PreLoadDefaultProfile=0                         #Ԥװ��Ĭ�������ļ�:0-Ԥ����,1-������
DefaultProfile=../cfg/finance-common.cfg        #ȱʡԤװ�����ļ�
IncludePath=../include                          #�ⲿ����·��
MsgMaxLen=1024                                  #��Ϣ�ı���󳤶�
NormalAccDate=3                                 #��ʾ����1-3�ų���
SimulatedDate=10                                #��ʾģ����˵��ʼʱ��
TempTablePrefix=Temp_Fetch_                     #��ʱ������������˳�ʱȫ��ɾ��

#�������ݣ��ǿ�����Ա�����޸�
ReadIni=$AwkPath/read_ini_file.awk
ConfigFile=$CfgPath/`basename $0 | awk -F. '{print $1".cfg"}'`
TmpEnvFile=$TmpDir/.$$.env

########################################   ������   ########################################

USAGE="usage: `basename $0` -u <UserName> -p <Password> -i <InstanceName> -o <SchemaName> -f <IniFileName> -l <CleanLogFlag> -t <TableSpace> -d <ExecDate> -n <StepNo> -r <ResultPath> -m <Mode> -s <StatMode>\n\n"

#����ʱ��ʱ�ļ�Ŀ¼����
if [ ! -d "$TmpDir" ]
then
	mkdir -p "$TmpDir"
fi

#������ϵͳ�Դ�awk�Ƿ�֧��ENVIRON����
case $OS in
AIX|Linux)
  #�Դ�awk֧��ENVIRON����
  AwkOS=""
  printf "\n"
  ;;
*)
  #��ȡ������������ʱδ֧�ֺ�������
  set | awk '{if ((index($1,"=")>0)&&(substr($0,1,1)!=" ")&&(substr($0,1,1)!="\t")) {a=substr($1,1,index($1,"=")-1); gsub(/[0-9a-zA-Z_]/,"",a); if (a=="") print $0}}' > $TmpDir/.$$.env-ref
  AwkOS=$OS
  printf "\n"
  ;;
esac

#��ȡ�������
while getopts u:p:i:o:f:l:t:d:n:r:m:s:H OPTION
do
	case "$OPTION" in
	f) #ָ�������ļ����Ĭ������
		myValue="$OPTARG"
		if [ ! -f "$myValue" ]
		then
			printf "File [%s] is not exists!!!\n\n" "$myValue"
			exit 1
		else
			ConfigFile="$myValue"
		fi
		;;
	i) #���ݿ�����ʵ��
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
	u) #���ݿ������û���:�û���������ĸ��ͷ����ֻ����������ĸ���»���
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
	p) #���ݿ�����:ע������������ַ���������Ҫ�޸Ĵ���
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
	o) #���ݿ⽨����û���:�û���������ĸ��ͷ����ֻ����������ĸ���»���
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
	l) #���ݿ���־:
		myValue="$OPTARG"
		myValue=`echo $myValue | awk '{a=$0; gsub(/[[:digit:]]/,"",a); if (a=="") print $0+0; else {print $0; exit 1}}'`
		if [ $? -ne 0 ]
		then
			printf "Invalid mode for cleaning log : %s !!!\n\n" "$myValue"
			exit 1
		fi
		_CleanLogFlag=$myValue
		;;
	t) #ָ����ռ���:������ĸ��ͷ����ֻ����������ĸ���»���
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
	d) #ָ�����������:�뵱ǰ��һ��ʱʹ�ã��������»��գ���ʽ��2013-05,2013-05-21,201305,20130521��ֻ�����жϣ�����
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
	n) #�ϵ�ִ�е����:���Դ�״̬�ļ��л�ȡ��Ҳ����ͨ���ű�����ָ��
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
	r) #����ָ�����·��:��������ԭ���Ƿ�ֹ����ָ���Ĵ�ռ�ר�÷���
		myValue="$OPTARG"
		if [ ! -d "$myValue" ]
		then
			printf "Directory [%s] is not exists!!!\n\n" "$myValue"
			exit 1
		else
			_ResultPath="$myValue"
		fi
		;;
	m) #2014/1/25 ���ӡ�����Ա���ģʽ
		myValue="$OPTARG"
		if [ "$myValue" != "newtest" ]
		then
			printf "Only support [%s]!!!\n\n" "$myValue"
			exit 1
		else
			_TestMode="$myValue"
		fi
		;;
	s) #2014/9/30 ͳ��ģʽ��0-����ִ�У�1-ģ����������Ա�����2-ִ�зǵ������ݣ��ձ���õ�ǰϵͳ����3-���տ���ԣ�ָʱ���ϸ���ָ����ʱ�䣬�������ձ�
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

#����Ĭ���û�����δ����
_DefaultUser=$USER

#����ʱ�����
. $IncludePath/time_variable.profile

#װ���ⲿ����
. $IncludePath/common_func.sh
. $IncludePath/database_forDB2.sh

exportTimeVar "${_StatMode}" "${_ExecDate}"

LANG1=$LANG
MyShellNamePre=`echo $ScriptName | awk '{if (index($0,".")>0) print substr($0,1,index($0,".")-1); else print $0}'`
rm -f "$TmpDir/$MyShellNamePre.log"
#��ȡȱʡ�����ļ�
if [ $PreLoadDefaultProfile = 0 ] && [ -f $DefaultProfile ]
then
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Preload default configure file [%s] ... " " " `basename "$DefaultProfile"`
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s ��ȡԤ���������ļ�[%s] ... " " " `basename "$DefaultProfile"` >> "$TmpDir/$MyShellNamePre.log"
	rm -f $TmpEnvFile
	export LANG=c
	awk -f $ReadIni $DefaultProfile > $TmpEnvFile
	export LANG=$LANG1
	cat $TmpEnvFile >> "$TmpDir/$MyShellNamePre.log"
	. $TmpEnvFile
	rm -f $TmpEnvFile
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Preload is finished!\n\n" " "
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s ��ȡԤ���ؽ���!\n\n" " " >> "$TmpDir/$MyShellNamePre.log"
fi

#��������ļ��Ƿ���ڣ���������ڣ����˳�
printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Read configure file [%s] ... " " " `basename "$ConfigFile"`
printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s ��ȡ�����ļ�[%s] ... " " " `basename "$ConfigFile"` >> "$TmpDir/$MyShellNamePre.log"
rm -f $TmpEnvFile

#������뻹�зֺţ���ô������Ҫ�޸ļ����
if [ -f $ConfigFile ]
then
	export LANG=c
	awk -v ReadOnlyList=";SchemaUser;${_SchemaName};DB2_User;${_DBName};DB2_Password;${_DBPwd};DB2_Instance;${_InstanceName};TableSpace;${_DBTabspace}" -f $ReadIni $ConfigFile > $TmpEnvFile
	export LANG=$LANG1
	cat $TmpEnvFile >> "$TmpDir/$MyShellNamePre.log"
	. $TmpEnvFile
	rm -f $TmpEnvFile
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Reading is finished!\n\n" " "
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s ��ȡ����!\n\n" " " >> "$TmpDir/$MyShellNamePre.log"
else
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s Reading Skipped!\n\n" " "
	printf "\n\n`date +\"%Y/%m/%d %H:%M:%S>\"`%-3s δ����[%s]��������ȡ!!!\n\n" " " `basename "$ConfigFile"` >> "$TmpDir/$MyShellNamePre.log"
fi

#������־�ļ���״̬�ļ�
LogFile="$LogPath/$MyShellNamePre.log"
StatusFile="$StatPath/$MyShellNamePre.status"

#������־Ŀ¼
if [ ! -d "$LogPath" ]
then
	mkdir -p "$LogPath"
fi
#����״̬Ŀ¼
if [ ! -d "$StatPath" ]
then
	mkdir -p "$StatPath"
fi
#��������Ŀ¼
if [ ! -d "$ProcPath" ]
then
	mkdir -p "$ProcPath"
fi
#������ʱ�ļ���
if [ ! -d "$TmpPath" ]
then
	mkdir -p "$TmpPath"
fi
#�����Ϣ�ļ�Ŀ¼�Ƿ����
MsgDir=`dirname "${ResultFile_NewMsg}"`
if [ ! -d "$MsgDir" ]
then
	mkdir -p "$MsgDir"
fi


#���⴦����־�ļ�
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

#���״̬�ļ�:�ϵ�֧�֣���ģ��ʵ���ò���
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

##################################�˲��ִ�����Ը���ʵ����Ҫ��д##################################


#��������
WriteStatusFile 2 0 $$ $StatusFile "" "����ά�������������"





#���ݿ�����
WriteStatusFile 1 1 $$ $StatusFile "" "��ʼ���ݿ����ӡ���"
if ! DB2_Connect $DB2_User $DB2_Password $DB2_Instance "$LogFile"-`date +%Y%m%d`
then
  exit 1
fi





#�������
WriteStatusFile 1 2 $$ $StatusFile "" "�����������"
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





#������֯����ά����ʱ��
WriteStatusFile 1 3 $$ $StatusFile "" "������֯����ά����ʱ����"
#��ȡ����������Ϣ
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
#����ģ�Ͳ�������������Ϣ
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
#֧����ģ��
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
#��ȡ����������չ��Ϣ
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
#����ģ�Ͳ�������������չ��Ϣ
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
#֧����ģ��
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
#��ȡ����ʵ����Ϣ
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
#����ģ�Ͳ�������ʵ�������Ϣ
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
#֧����ģ��
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
#��ȡ����ʵ���ϵ
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
#����ģ�Ͳ�������ʵ�������Ϣ
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
#֧����ģ��
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
#��ȡ���д�������Ϣ
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
#����ģ�Ͳ����������Ϣ
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
#֧����ģ��
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
#��ȡ���д�������չ��Ϣ
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
#����ģ�Ͳ����������չ��Ϣ
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
#֧����ģ��
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
#�˹�������Ϣ
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
#����ģ�Ͳ����������Ϣ
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
#ƴ�������������Ϣ
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
              kind_name2            varchar(64), -- Ԥ����
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
#����ģ�Ͳ�������������չ��Ϣ
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
                                   '������Ӫ'
                                  when p.channel_entity_status in (4, 13) then
                                   '��ͣӪҵ'
                                  when p.channel_entity_status in (5, 12) then
                                   '�ѹص�'
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
                                  when j.code_name = '���п�Ʊ' then
                                   2
                                  else
                                   1
                                end as Pay_Type,
                                nvl(j.code_name, '���۴���') as Pay_Type_Name,
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
                   and q.code_name = 'ֱӪӪҵ��'" "$LogFile"-`date +%Y%m%d`
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

#��boss_org_id
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
#�������������
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
#����δ������Ĵ�����
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
                                  when g.code_name = '���п�Ʊ' then
                                   2
                                  else
                                   1
                                end as Pay_Type,
                                nvl(g.code_name, '���۴���') as Pay_Type_Name,
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

#��ȡ����BOSS��org_id
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
#����ģ�Ͳ�������������չ��Ϣ
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
#ȡʧЧ�ļ�¼
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





WriteStatusFile 1 4 $$ $StatusFile "" "������֯����ά����"
if ! DB2_Check 0 1 0 "" $Rpt_Dim_Channel_Org_Op_Info "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Dim_Channel_Org_Op_Info(
	                ORG_CLASS1            VARCHAR(64),
	                ORG_CLASS2            VARCHAR(64),
	                ORG_CLASS3            VARCHAR(64),
	                CRM_ORG_ID            BIGINT,
	                OP_ID                 BIGINT, -- ����������նˡ�����������ֱ����һ�㲻��
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
	                IS_VALID              SMALLINT, -- ��Ч��־:0-��Ч,1-��Ч
	                CREATE_DATE           DATE,
	                MODIFY_DATE           DATE
	              ) in $TableSpace partitioning key(CRM_ORG_ID, OP_ID, CREATE_DATE) using hashing" "$LogFile"-`date +%Y%m%d`
	then
		exit 1
	fi
	DB2_Cmd "comment on table $Rpt_Dim_Channel_Org_Op_Info IS '������֯��Աά��'" "$LogFile"-`date +%Y%m%d`
	DB2_Cmd "comment on $Rpt_Dim_Channel_Org_Op_Info (ORG_CLASS1 IS '����һ������:ʵ������,��������,ֱӪ����',
	                                                  ORG_CLASS2 IS '������������:ʵ������-ֱӪ��,ʵ������-���˵�,ʵ������-��Ȩ��;��������-��Ӫ��������,��������-����������;ֱӪ����-��Ӫֱ������,ֱӪ����-���ֱ������',
	                                                  ORG_CLASS3 IS '������������:�콢�ꡢ��׼�ꡢ�����ꡢ�ֻ�������,ί�о�Ӫ��,�ֻ�ר���ꡢ��Ȩ����ꡢ�ֻ�����,��Ӫ����Ӫ�����ߵ绰���ͻ��ˡ�����,�ⲿ������վ������������,�ͻ��������������,ũ�塢У԰�������Ĵ���Ա',
	                                                  CRM_ORG_ID IS 'CRM����֯���',
	                                                  OP_ID IS '����Ա����:Ϊ��ʱ����org_idΪ׼����Դdb2info.Dim_Sys_Operation_Info.op_id',
	                                                  CRM_ORG_TYPE IS '��֯����:��Դdb2info.Dim_Org_Info.new_org_type',
	                                                  CRM_ORG_TYPE_NAME IS '��֯������:��Դdb2info.Dim_Org_Info.new_org_type_name��org_type_name',
	                                                  CRM_ORG_KIND IS '����Ա��֯����:��Դdb2info.Dim_Sys_Operation_Info.org_type',
	                                                  CRM_ORG_NAME IS '��֯����:��Դdb2info.Dim_Org_Info.new_org_name��org_name���ֻ�db2info.Dim_Sys_Operation_Info.org_name',
	                                                  OP_NAME IS '��������:��Դdb2info.Dim_Sys_Operation_Info.op_name',
	                                                  LOGIN_NAME IS '��¼��:��Դdb2info.Dim_Sys_Operation_Info.login_name',
	                                                  NODE_ID IS '������',
	                                                  NODE_NAME IS '��������',
	                                                  NODE_KIND IS '��Դdb2info.Ods_Channel_Node_New_YYYYMMDD.node_kind��db2info.Dim_Org_Info.chl_kind',
	                                                  NODE_TYPE IS '��Դdb2info.Ods_Channel_Node_New_YYYYMMDD.node_type��db2info.Dim_Org_Info.chl_type',
	                                                  CHL_MODE IS '��Դdb2info.Dim_Org_Info.chl_mode',
	                                                  NODE_LEVEL IS '���㼶��',
	                                                  NODE_STATUS IS '����״̬',
	                                                  OPERATE_TYPE IS '��ת����',
	                                                  NODE_ENTITY_TYPE IS '����ʵ������',
	                                                  DISTRICT_ID IS '',
	                                                  VALID_DATE IS '������Ч����',
	                                                  EXPIRE_DATE IS '����ʧЧ����',
	                                                  NODE_CREATE_DATE IS '���㴴������',
	                                                  NODE_DONE_DATE IS '����������',
	                                                  CHECK_DATE IS '�˹���������',
	                                                  CHANNEL_ENTITY_SERIAL IS 'ʵ�����к�',
	                                                  SELF_STATUS IS '��Ӫ״̬',
	                                                  SELF_STATUS_NAME IS '��Ӫ״̬����',
	                                                  NODE_ADDR IS '�����ַ',
	                                                  BUSINESS_START_DATE IS '����������ʼʱ��',
	                                                  AGENT_ID IS '�����̱��',
	                                                  AGENT_SHORT_NAME IS '�����̼��',
	                                                  AGENT_NAME IS '������ȫ��',
	                                                  BELONG_ORG_ID IS '������֯���',
	                                                  BELONG_ORG_NAME IS '������֯����',
	                                                  TEST_BUSI_FLAG IS 'ҵ����Ա�־',
	                                                  ORG_ID IS '��֯���:��Դshdw.Dim_Org_Info.org_id,shdw.Dim_Sys_Operation_Info.org_id',
	                                                  ORG_NAME IS '��֯����',
	                                                  AGENT_TYPE IS '����������',
	                                                  AGENT_TYPE_NAME IS '��������������',
	                                                  AGENT_TYPE_ALIAS IS '���������ͱ��',
	                                                  AGENT_LEVEL IS '�����̼���',
	                                                  AGENT_LEVEL_NAME IS '�����̼�������',
	                                                  AGENT_STATUS IS '������״̬',
	                                                  PAY_TYPE IS '֧������',
	                                                  PAY_TYPE_NAME IS '֧����������',
	                                                  AGENT_VALID_DATE IS '��������Ч����',
	                                                  AGENT_EXPIRE_DATE IS '������ʧЧ����',
	                                                  AGENT_CREATE_DATE IS '�����̴�������',
	                                                  AGENT_DONE_DATE IS '�����̱������',
	                                                  IS_VALID IS '��Ч��־:0-��Ч,1-��Ч',
	                                                  CREATE_DATE IS '��������',
	                                                  MODIFY_DATE IS '�޸�����'
	                                                 )" "$LogFile"-`date +%Y%m%d`
fi
if ! DB2_Cmd "delete from $Rpt_Dim_Channel_Org_Op_Info where create_date='$miExecDayF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#���������ն������Ϣ
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                select distinct '��������' as Kind_Name1,
                                '��Ӫ��������' as Kind_Name2,
                                '�����ն�' as Kind_Name3,
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
                         where terminalcode <> '123456789012345' -- �������ն�
                           and terminalopid is not null
                        union
                        select int(termdesp) as op_id
                          from ${TOds_Term_}$PreDayF -- �µĿ��Ŵ����
                         where substr(termdesp, 1, 1) between '0' and '9') a -- ��ͬ�� termdesp is not null and upper(termdesp) not like '%TEST%' and termdesp <> '����Ӫҵ��'
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
#����ֱ������
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                select distinct 'ֱ������' as Kind_Name1,
                                '��Ӫֱ������' as Kind_Name2,
                                '���ſͻ�����' as Kind_Name3,
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
#�����������
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                select distinct '��������' as Kind_Name1,
                                '��Ӫ��������' as Kind_Name2,
                                case
                                  when a.op_id = 999990001 or a.org_id = 402852 then
                                   '����Ӫҵ��'
                                  when a.op_id = 999990002 then
                                   'WAP'
                                  when a.op_id in (999990021, 999990101) then
                                   '10086����'
                                  when a.op_id = 999990024 and a.op_name = '�����̳Ǻ�̨�ӿ�' then
                                   '�����̳�'
                                  when a.op_id = 999990076 and a.op_name = 'CBOSS' then
                                   'CBOSS'
                                  when a.op_id = 999990077 then
                                   '����Ӫҵ��'
                                  when a.op_id = 999990091 then
                                   '�ͻ���'
                                  when a.op_id = 999990099 and a.op_name = 'ͳһ֧��ƽ̨' then
                                   'ͳһ֧��'
                                  when a.busi_chl_type_name = 'CCS' then
                                   '���ߵ绰' -- 10086�˹�
                                  when a.op_id = 999990121 then
                                   '����������' -- ��������Ӫҵ��
                                  when a.op_id = 999990122 then
                                   '֧����' -- ��������Ӫҵ��
                                  when a.op_id = 999990133 then
                                   '΢��Ӫҵ��' -- ��������Ӫҵ��
                                  when a.op_id = 9 and a.op_name = '��̨����' then
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
                       a.org_id = 402852 or a.op_id = 9 and a.op_name = '��̨����')" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#�����������ѻ��ֵ�
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                select distinct case
                                  when a.kind_name = '�����ն�' or a.node_kind = 7 then
                                   '��������'
                                  when a.kind_name = 'У԰ֱ����' then
                                   'ֱ������'
                                  when a.crm_org_id is not null and
                                       a.kind_name is not null then
                                   'ʵ������'
                                  when c.org_name = '���̷���֧�Ų�' then
                                   '��������'
                                  when c.bass_org_type in (1, 2, 3, 4, 5, 6, 7, 8, 9) or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('רӪ��',
                                        '��������',
                                        '�й��ƶ���������',
                                        '������',
                                        'ת������',
                                        '������',
                                        '�����',
                                        '�ն˴�����',
                                        '��Ӫ��',
                                        '����ֱ����',
                                        '��������',
                                        '������ת������',
                                        '��ͨͨ������Ȩ��',
                                        'ָ����Ȩ��') then -- 1-�Ǽ������ŵ�,2-����ֱ����,3-רӪ��,4-��������,5-������/ת������,6-��Ӫ��,7-������,8-�����,9-�ն˴�����
                                   'ʵ������'
                                  when c.bass_org_type = 10 or c.org_name = '�����̳�������' then -- 10-������������
                                   '��������'
                                  when a.kind_name in ('��ͥҵ������', '��������') or
                                       a.node_kind in (9, 10) then
                                   'ʵ������'
                                  when nvl(c.org_name, b.org_name) in
                                       ('����ͨ������',
                                        '����',
                                        '����',
                                        '�ƴ�',
                                        '����������',
                                        '��ͨ',
                                        'ʢ��',
                                        '���ض����һ') then
                                   'ʵ������'
                                end as Kind_Name1,
                                case
                                  when a.kind_name = '�����ն�' or a.node_kind = 7 then
                                   '��Ӫ��������'
                                  when a.kind_name = 'У԰ֱ����' then
                                   '���ֱ������'
                                  when a.kind_name = 'ֱӪӪҵ��' or a.node_kind = 1 then
                                   'ֱӪ��'
                                  when a.kind_name in ('��������', '����Ӫҵ��') or
                                       a.node_kind in (2, 3) then
                                   '���˵�'
                                  when a.kind_name in
                                       ('�ֻ�ר����', '�ֻ�����', '��Ȩ�����') or
                                       a.node_kind in (4, 5, 6) then
                                   '��Ȩ��'
                                  when c.org_name = '���̷���֧�Ų�' then
                                   '��Ӫ��������'
                                  when c.bass_org_type = 6 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '��Ӫ��' then
                                   'ֱӪ��'
                                  when c.bass_org_type in (1, 2, 3, 4, 5, 9) or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('רӪ��',
                                        '��������',
                                        '�й��ƶ���������',
                                        '������',
                                        'ת������',
                                        '�ն˴�����',
                                        '����ֱ����',
                                        'ָ����Ȩ��',
                                        '��������',
                                        '������ת������',
                                        '��ͨͨ������Ȩ��') then
                                   '��Ȩ��'
                                  when c.bass_org_type in (7, 8) or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('������', '�����') then
                                   '���˵�'
                                  when c.bass_org_type = 10 then
                                   '����������'
                                  when c.org_name = '�����̳�������' then
                                   '��Ӫ��������'
                                  when nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '��������' then
                                   '����������'
                                  when a.kind_name in ('��ͥҵ������', '��������') or
                                       a.node_kind in (9, 10) then
                                   '��Ȩ��'
                                  when nvl(c.org_name, b.org_name) in
                                       ('����ͨ������',
                                        '����',
                                        '����',
                                        '�ƴ�',
                                        '����������',
                                        '��ͨ',
                                        'ʢ��',
                                        '���ض����һ') then
                                   '��Ȩ��'
                                  when nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '��������' then
                                   '����������'
                                end as Kind_Name2,
                                case
                                  when a.kind_name = '�����ն�' or a.node_kind = 7 then
                                   '�����ն�'
                                  when a.kind_name = 'У԰ֱ����' then
                                   'У԰����Ա'
                                  when a.kind_name = 'ֱӪӪҵ��' or a.node_kind = 1 then
                                   a.kind_name2
                                  when a.kind_name in ('��������',
                                                       '����Ӫҵ��',
                                                       '�ֻ�ר����',
                                                       '�ֻ�����',
                                                       '��Ȩ�����') or
                                       a.node_kind in (2, 3, 4, 5, 6) then
                                   a.kind_name
                                  when c.org_name = '���̷���֧�Ų�' then
                                   '����'
                                  when c.bass_org_type = 6 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '��Ӫ��' then
                                   '��׼��'
                                  when c.bass_org_type = 1 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '�Ǽ������ŵ�' then
                                   '�ֻ�����'
                                  when c.bass_org_type = 2 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       '����ֱ����' then
                                   '�ֻ�ר����+��Ȩ�����'
                                  when c.bass_org_type = 3 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) =
                                       'רӪ��' then
                                   '�ֻ�ר����'
                                  when c.bass_org_type = 4 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('��������', '�й��ƶ���������', 'ָ����Ȩ��') then
                                   '��Ȩ�����'
                                  when c.bass_org_type = 5 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('������', 'ת������', '��ͨͨ������Ȩ��') then
                                   '��Ȩ�����'
                                  when c.bass_org_type in (7, 8) or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('������', '�����') then
                                   '����Ӫҵ��'
                                  when c.bass_org_type = 9 or
                                       nvl(c.bass_org_type_name, c.boss_org_type_name) in
                                       ('�ն˴�����', '��������', '������ת������') then
                                   '�ֻ�����'
                                  when c.bass_org_type = 10 then
                                   '����������'
                                  when c.org_name = '�����̳�������' then
                                   '����'
                                  when a.kind_name in ('��ͥҵ������', '��������') or
                                       a.node_kind in (9, 10) then
                                   '��Ȩ�����' -- �����ˬ���г���ȷ��
                                  when nvl(c.org_name, b.org_name) in
                                       ('����ͨ������',
                                        '����',
                                        '����',
                                        '�ƴ�',
                                        '����������') then
                                   '�ֻ�����'
                                  when nvl(c.org_name, b.org_name) in
                                       ('��ͨ', 'ʢ��', '���ض����һ') then
                                   '�ֻ�ר����'
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
#����ʣ��ORG
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                select distinct case
                                  when a.org_name = '���̷���֧�Ų�' then
                                   '��������'
                                  when a.bass_org_type in (1, 2, 3, 4, 5, 6, 7, 8, 9) or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('רӪ��',
                                        '��������',
                                        '�й��ƶ���������',
                                        '������',
                                        'ת������',
                                        '������',
                                        '�����',
                                        '�ն˴�����',
                                        '��Ӫ��',
                                        '����ֱ����',
                                        '��������',
                                        '������ת������',
                                        '��ͨͨ������Ȩ��',
                                        'ָ����Ȩ��') then -- 1-�Ǽ������ŵ�,2-����ֱ����,6-��Ӫ��,8-�����
                                   'ʵ������'
                                  when a.bass_org_type = 10 or a.org_name = '�����̳�������' then -- 10-������������
                                   '��������'
                                  when nvl(a.org_name, b.org_name) in
                                       ('����ͨ������',
                                        '����',
                                        '����',
                                        '�ƴ�',
                                        '����������',
                                        '��ͨ',
                                        'ʢ��',
                                        '���ض����һ') then
                                   'ʵ������'
                                end as Kind_Name1,
                                case
                                  when a.org_name = '���̷���֧�Ų�' then
                                   '��Ӫ��������'
                                  when a.bass_org_type = 6 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       '��Ӫ��' then
                                   'ֱӪ��'
                                  when a.bass_org_type in (1, 2, 3, 4, 5, 9) or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('רӪ��',
                                        '��������',
                                        '�й��ƶ���������',
                                        '������',
                                        'ת������',
                                        '�ն˴�����',
                                        '����ֱ����',
                                        'ָ����Ȩ��',
                                        '��������',
                                        '������ת������',
                                        '��ͨͨ������Ȩ��') then
                                   '��Ȩ��'
                                  when a.bass_org_type in (7, 8) or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('������', '�����') then
                                   '���˵�'
                                  when a.bass_org_type = 10 then
                                   '����������'
                                  when a.org_name = '�����̳�������' then
                                   '��Ӫ��������'
                                  when nvl(a.org_name, b.org_name) in
                                       ('����ͨ������',
                                        '����',
                                        '����',
                                        '�ƴ�',
                                        '����������',
                                        '��ͨ',
                                        'ʢ��',
                                        '���ض����һ') then
                                   '��Ȩ��'
                                  when nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       '��������' then
                                   '����������'
                                end as Kind_Name2,
                                case
                                  when a.org_name = '���̷���֧�Ų�' then
                                   '����'
                                  when a.bass_org_type = 6 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       '��Ӫ��' then
                                   '��׼��'
                                  when a.bass_org_type = 1 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       '�Ǽ������ŵ�' then
                                   '�ֻ�����'
                                  when a.bass_org_type = 2 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       '����ֱ����' then
                                   '�ֻ�ר����+��Ȩ�����'
                                  when a.bass_org_type = 3 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) =
                                       'רӪ��' then
                                   '�ֻ�ר����'
                                  when a.bass_org_type = 4 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('��������', '�й��ƶ���������', 'ָ����Ȩ��') then
                                   '��Ȩ�����'
                                  when a.bass_org_type = 5 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('������', 'ת������', '��ͨͨ������Ȩ��') then
                                   '��Ȩ�����'
                                  when a.bass_org_type in (7, 8) or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('������', '�����') then
                                   '����Ӫҵ��'
                                  when a.bass_org_type = 9 or
                                       nvl(a.bass_org_type_name, a.boss_org_type_name) in
                                       ('�ն˴�����', '��������', '������ת������') then
                                   '�ֻ�����'
                                  when a.bass_org_type = 10 then
                                   '����������'
                                  when a.org_name = '�����̳�������' then
                                   '����'
                                  when nvl(a.org_name, b.org_name) in
                                       ('����ͨ������',
                                        '����',
                                        '����',
                                        '�ƴ�',
                                        '����������') then
                                   '�ֻ�����'
                                  when nvl(a.org_name, b.org_name) in
                                       ('��ͨ', 'ʢ��', '���ض����һ') then
                                   '�ֻ�ר����'
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
#�����ն˲�©
if ! DB2_Cmd "insert into $Rpt_Dim_Channel_Org_Op_Info
                (org_class1,
                 org_class2,
                 org_class3,
                 op_id,
                 op_name,
                 is_valid,
                 create_date,
                 modify_date)
                select '��������',
                       '��Ӫ��������',
                       '�����ն�',
                       a.op_id,
                       '��©',
                       1,
                       '$miExecDayF',
                       '$miExecDayF'
                  from (select int(terminalopid) as op_id
                          from ${TOds_Db_Ap_Atm_Pcsettingext_}$PreDayF
                         where terminalcode <> '123456789012345' -- �������ն�
                           and terminalopid is not null
                        union
                        select int(termdesp) as op_id
                          from ${TOds_Term_}$PreDayF -- �µĿ��Ŵ����
                         where substr(termdesp, 1, 1) between '0' and '9') a
                  left join $Rpt_Dim_Channel_Org_Op_Info b
                    on a.op_id = b.op_id
                   and b.org_class3 = '�����ն�'
                 where b.op_id is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#����������ϴ
if ! DB2_Cmd "delete from $Rpt_Dim_Channel_Org_Op_Info
               where op_id in (select op_id
                                 from $Rpt_Dim_Channel_Org_Op_Info
                                where op_id in (select op_id
                                                  from $Rpt_Dim_Channel_Org_Op_Info
                                                 where create_date = '$miExecDayF'
                                                 group by op_id
                                                having count(*) > 1)
                                  and org_class3 = '�����ն�'
                                  and create_date = '$miExecDayF')
                 and org_class3 <> '�����ն�'
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
#�����޸�
if ! DB2_Cmd "update $Rpt_Dim_Channel_Org_Op_Info
                 set org_class1 = 'ʵ������'
               where org_class1 is null
                 and org_class2 is not null
                 and org_class2 in ('���˵�', '��Ȩ��', 'ֱӪ��')
                 and create_date = '$miExecDayF'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#ͬ��ˬ��ͨ���ն�������У԰�ꡢ���ĵꡢ����ȫ�����ڱ�׼�꣬��ͥҵ�����ꡢ�������㣨���������ģ�������Ȩ��
if ! DB2_Cmd "runstats on table $Rpt_Dim_Channel_Org_Op_Info" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
DB2_Truncate $mTemp_Node_Agent_Info2 "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Node_Agent_Info2 "$LogFile"-`date +%Y%m%d`
DB2_Truncate $mTemp_Sys_Operation "$LogFile"-`date +%Y%m%d`
DB2_Drop $mTemp_Sys_Operation "$LogFile"-`date +%Y%m%d`





#����Ӫҵ�ಹ���IMEI��Ӧ���ն�����
WriteStatusFile 1 5 $$ $StatusFile "" "��ȡӪҵ�ֿ�IMEI�����Ϣ����"
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





#�����ն�ά��
WriteStatusFile 1 6 $$ $StatusFile "" "��ȡ����IMEI��Ӧ�ն����͡���"
if ! DB2_Check 0 1 0 "" $Rpt_Dim_Termi "" "" "$LogFile"-`date +%Y%m%d`
then
	if ! DB2_Cmd "create table $Rpt_Dim_Termi(
	              KEY_IMEI          VARCHAR(10), -- ȡIMEIǰ8λ
	              MOBILE_FLAG       VARCHAR(20), -- ���һ��������
	              MOBILE_TYPE       VARCHAR(40),
	              SRC_FLAG          VARCHAR(10), -- ��Դ��־:һ��,Ӫҵ
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
                                    'TDLTE�ֻ�'
                                   when t1.type_id in ('01', '06') and
                                        t1.model3g in ('3', '5', '6', '7') then
                                    'TDSCDMA�ֻ�'
                                   when t1.type_id in ('02', '07') and
                                        t1.model4g in ('1', '3') then
                                    'TDLTE���ݿ�'
                                   when t1.type_id in ('02', '07') and
                                        t1.model3g in ('3', '5', '6', '7') then
                                    'TDSCDMA���ݿ�'
                                   when t1.type_id = '03' and t1.model4g in ('1', '3') then
                                    'TDLTE������'
                                   when t1.type_id = '03' and t1.model3g in ('3', '5', '6', '7') then
                                    'TDSCDMA������'
                                   when t1.type_id = '04' and t1.model4g in ('1', '3') then
                                    'TDLTEMIFI'
                                   when t1.type_id = '04' and t1.model3g in ('3', '5', '6', '7') then
                                    'TDSCDMAMIFI'
                                   when t1.type_id = '05' and t1.model4g in ('1', '3') then
                                    'TDLTE���߹̻�'
                                   when t1.type_id = '05' and t1.model3g in ('3', '5', '6', '7') then
                                    'TDSCDMA���߹̻�'
                                   when t1.type_id = '08' and t1.model4g in ('1', '3') then
                                    'TDLTECPE'
                                   else
                                    '2G�ն�'
                                 end) as Mobile_Type,
                                 'һ��' as Src_Flag,
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
                          'TDLTE�ֻ�'
                         when a.termi_type = 3 then
                          'TDSCDMA�ֻ�'
                         when a.termi_type = 4 then
                          'TDSCDMA���ݿ�'
                         when a.termi_type = 2 then
                          'TDSCDMA������'
                         when a.termi_type = 8 then
                          'TDLTEMIFI'
                         when a.termi_type = 6 then
                          'TDSCDMAMIFI'
                         when a.termi_type = 5 then
                          'TDSCDMA���߹̻�'
                         else
                          '2G�ն�'
                       end) as Mobile_Type,
                       'Ӫҵ' as Src_Flag,
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





#���ܻ��ն�ά��
WriteStatusFile 1 7 $$ $StatusFile "" "��ȡ���������ն�ά����"
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
              OS_TYPE_ALIAS VARCHAR(100), -- ���һ��������
              BRAND_NAME    VARCHAR(40),
              TYPE_NAME     VARCHAR(40),
              MAKE_TYPE     VARCHAR(20), -- TD
              MAKE_TYPE2    VARCHAR(20), -- TD-SCDMA,TD-LTE
              SRC_FLAG      SMALLINT     -- Դͷ��־:1-һ��,2-����
              ) in $TableSpace partitioning key(key_imei) not logged initially" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#����һ��Ϊ׼
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
                                   '����4G�ֻ�'
                                  when a.type_id in ('01', '06') and
                                       a.model3g in ('1', '2', '4') then
                                   '����3G�ֻ�'
                                  when a.type_id in ('01', '06') and
                                       a.model2g in ('1', '2', '3') then
                                   '2G�ֻ�'
                                  when a.type_id = '02' then
                                   '���ݿ�'
                                  when a.type_id = '03' then
                                   '������'
                                  when a.type_id = '04' then
                                   'MIFI'
                                  when a.type_id = '05' then
                                   '���߹̻�'
                                  when a.type_id = '06' then
                                   '�ֻ��Ķ�'
                                  when a.type_id = '07' then
                                   'ƽ�����'
                                  when a.type_id = '08' then
                                   'CPE'
                                  when a.type_id = '00' then
                                   '��ҵ�ն�'
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
                                           '2G�ֻ�'
                                          when c.product_type = 2 then
                                           'TDSCDMA'
                                          when c.product_type = 9 then
                                           'ƽ�����'
                                          else
                                           '��ά��'
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
                                                          'WP8', -- 2013/8/27 ����
                                                          '�������ܻ�', -- 2013/9/2 ����
                                                          'IOS')) d
                  left join (select f.tac
                               from ${TOds_Bass1_91003_}$PreMonthF e,
                                    ${TOds_Bass1_91002_}$PreMonthF f
                              where e.device_id = f.device_id) g
                    on d.key_imei = g.tac
                 where d.key_length = 8 -- 2014/2/3 ���ֵ�С��5λʱ��һ����8λ�в��ֲ�ȫ�����ܻ��������Ļ��ж��߼����ڸ��ӣ��ʼ�
                   and g.tac is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#��������ϵͳ
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='ANDROID' where upper(os_type_alias) like 'ANDROID%' and os_type is null" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "update $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF set os_type='ALIYUN' where (upper(os_type_alias) like 'ALIYUN%' or os_type_alias like '������%') and os_type is null" "$LogFile"-`date +%Y%m%d`
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
#2014/7/28 ����Ҫ���޳�����ϵͳ 2014��0�¼Ʒ��±�14��7��21.xls
if ! DB2_Cmd "delete from $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF where os_type like 'SYMBIAN%' or os_type in ('S40','S60') or upper(os_type_alias) like '%SYMBIAN%'" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
if ! DB2_Cmd "runstats on table $Rpt_Dim_Capacity_Mobile_Phone_$PreMonthF" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi





#2014/9/25 ����IMEI��Ӧ��RES_SPEC_ID��ϵ
WriteStatusFile 1 8 $$ $StatusFile "" "����IMEI����ӳ�����"
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
              SRC           VARCHAR(6), -- ��Դ:origin-�ֿ�,used-����
              IMEI          VARCHAR(25),
              RES_SPEC_ID   BIGINT, -- ��Դ�����
              TERMI_TYPE    SMALLINT,
              RES_SPEC_NAME VARCHAR(256),
              STATUS        SMALLINT, -- ����:-1-��,0-��Ч,1-��Ч
              EXPIRE_DATE   TIMESTAMP,
              FLAG          SMALLINT -- ��־:0-��Ч,1-��Ч
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
#����IMEI���Ψһ������
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
#ɾ���Ѳ���Ҫ������
if ! DB2_Cmd "delete from $Rpt_Imei_Res_Spec a
               where flag = 0
                 and exists (select null
                        from $Rpt_Imei_Res_Spec b
                       where flag = 1
                         and imei = a.imei)" "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#��ѡΨһ��res_spec_id
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





#�˻����ײ͹�ϵ��
WriteStatusFile 1 9 $$ $StatusFile "" "�����˻����ײ͹�ϵ����"
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
	#ȫ���û�����ͼ
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
#��������
if ! DB2_Truncate $Rpt_Acc_Plan_Detail_$PreMonthF "$LogFile"-`date +%Y%m%d`
then
	exit 1
fi
#���ڷ���������ŵļ�¼ȡ�˻���Ӧ�û�Ⱥ�м���ʱ��������û���Ӧ�ײ�
#��������Ż������ļ�¼ȡ�˻���Ӧ�û�Ⱥ����Ż���ʱ��������û���Ӧ�ײ�
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





#������ͨ�˻�
WriteStatusFile 1 10 $$ $StatusFile "" "������ͨ�˻�����"
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





#��Ʒά��
WriteStatusFile 1 11 $$ $StatusFile "" "������Ʒά����"
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
#��������
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





#ȫ����Ʒ������Ϣ
WriteStatusFile 1 12 $$ $StatusFile "" "����ȫ����Ʒ������Ϣ����"
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
#��������
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




WriteStatusFile 0 0 $$ $StatusFile "" "����ά������������"

