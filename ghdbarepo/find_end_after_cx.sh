#!/bin/sh
# Name     :  find_end_after_cx.sh
# Author   :  Raman Paul
# created  :  03/01/10
# Desc     :  This particular shell script is used to locate any decs created on cancelled AQS policies. 
#             This script runs from Monday-Friday at 16:30
# Modified :  00/00/00 - xxxx xxxxxxxxx - xxxxxxxxxx 

ORACLE_SID="prod";export ORACLE_SID
ORACLE_HOME=`sh /db/sw/oracle/scripts/get_oracle_home.sh`;export ORACLE_HOME
ORACLE_TERM="vt100";export ORACLE_TERM
PATH=$ORACLE_HOME/bin:.:$PATH;export PATH

PWD_PATH="/db/sw/oracle/scripts";export PWD_PATH
SCR_PATH="/db/sw/oracle/scripts/ORACLE/DATA_FIXES";export SCR_PATH
LOG_PATH="/db/sw/oracle/scripts/ORACLE/DATA_FIXES/logs";export LOG_PATH

PWD=`sh ${PWD_PATH}/getpopn1.sh`
DBNAME=${ORACLE_SID}
SCHEMA="cigadmin"
RM="/bin/rm"
CURR_DATE=`date "+%x %X"`
S_HOST=`hostname`
U_S_HOST=`echo ${S_HOST} | tr "[a-z]" "[A-Z]"`
U_DBNAME=`echo ${ORACLE_SID} | tr "[a-z]" "[A-Z]"`
U_SCHEMA=`echo ${SCHEMA} | tr "[a-z]" "[A-Z]"`

SCR_FILE="${SCR_PATH}"/"find_end_after_cx.sql"
LOG_FILE="${LOG_PATH}"/"find_end_after_cx_${SCHEMA}_${DBNAME}.lst"
ERR_FILE="${LOG_PATH}"/"find_end_after_cx_${SCHEMA}_${DBNAME}.err"
TXT_FILE="${LOG_PATH}"/"find_end_after_cx_${SCHEMA}_${DBNAME}.txt"
RM_LOG="${LOG_PATH}"/"rm_find_end_after_cx_${S_HOST}.log"

MAIL_LOG_TO_DBA=`sh ${PWD_PATH}/mail_log_to_dba.sh`
MAIL_LOG_TO_DBAGRP=`sh ${PWD_PATH}/mail_log_to_dba.sh`
MAIL_LOG_TO_USER="${MAIL_LOG_TO_DBA} sxiao@ciginsurance.com capsupport@ciginsurance.com"

MAIL_LOG_SUB1="Daily Scripts (${U_S_HOST}): ERROR on find_end_after_cx.sql in ${U_SCHEMA} of ${U_DBNAME}"
MAIL_LOG_SUB2="Daily Scripts (${U_S_HOST}): find_end_after_cx.sql completed in ${U_SCHEMA} of ${U_DBNAME}"
MAIL_LOG_SUB3="Daily Scripts (${U_S_HOST}): DECS on cancelled AQS policies found in ${U_SCHEMA} of ${U_DBNAME}"
RM_ERR="Daily Scripts (${U_S_HOST}): ERROR in removing find_end_after_cx logs."

if [ -f ${LOG_FILE} ]
   then
   $RM ${LOG_FILE} > ${RM_LOG}
   STATUS="$?"
   if [ "${STATUS}" != 0 ]; then
      mailx -s "${RM_ERR}" "${MAIL_LOG_TO_DBA}" < "${RM_LOG}"
      exit 1
   fi
fi

sqlplus -S << END_SQL
${SCHEMA}/${PWD}@${DBNAME}
spool ${LOG_FILE}
prompt Starting FIND ENDORSEMENT AFTER CANCELLATION IN CIGADMIN... 
SELECT TO_CHAR(sysdate,'MM/DD/YY HH24:MI:SS') START_DATE from dual;
show user;
select name database from v\$pdbs;
select name instance_name from cig_instance;
set time on timing on;
set linesize 120
column policy_search_nbr format a20
@${SCR_FILE}
set time off timing off;
SELECT TO_CHAR(sysdate,'MM/DD/YY HH24:MI:SS') END_DATE from dual;
prompt FIND ENDORSEMENT AFTER CANCELLATION IN CIGADMIN complete.
spool off;
END_SQL

if [ -f ${ERR_FILE} ]
   then
   $RM ${ERR_FILE} > ${RM_LOG}
   STATUS="$?"
   if [ "${STATUS}" != 0 ]; then
      mailx -s "${RM_ERR}" "${MAIL_LOG_TO_DBA}" < "${RM_LOG}"
      exit 1
   fi
fi
if [ -f ${TXT_FILE} ]
   then
   $RM ${TXT_FILE} > ${RM_LOG}
   STATUS="$?"
   if [ "${STATUS}" != 0 ]; then
      mailx -s "${RM_ERR}" "${MAIL_LOG_TO_DBA}" < "${RM_LOG}"
      exit 1
   fi
fi

pg ${LOG_FILE}|grep ORA- > ${ERR_FILE}
pg ${ERR_FILE}|egrep -vi 'ORA-00000|ORA-00000' > ${TXT_FILE}
if [ -f ${TXT_FILE} ]
   then
   BY_CNT=`ls -ltr ${TXT_FILE}|awk '{ print $5 }'`
   if [ $BY_CNT != 0 ]
      then
      mailx -s "${MAIL_LOG_SUB1}" "${MAIL_LOG_TO_DBA}" < "${LOG_FILE}"
      exit 1
   else
      pg ${LOG_FILE} |grep "no rows selected" > ${TXT_FILE}
      if [ -f ${TXT_FILE} ]
         then
	 RUN_CHECK=`cut -c1-16 ${TXT_FILE}`
	 if [ "$RUN_CHECK" != "no rows selected" ]
 	    then
	    mailx -s "${MAIL_LOG_SUB3}" "${MAIL_LOG_TO_USER}" < "${LOG_FILE}"
   	    exit 1
         else
#            mailx -s "${MAIL_LOG_SUB2}" "${MAIL_LOG_TO_DBAGRP}" < "${LOG_FILE}"
            exit 1
	 fi
      fi
   fi
fi
