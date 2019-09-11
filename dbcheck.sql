def author="huangqw"
def script_version="0.1"
def email="john-wong@outlook.com"
def tel='18059869210'

-- SET markup html ON spool ON pre off entmap off;
set heading on;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 999 linesize 80 newpage 1 recsep off;
set trimspool on trimout on define "&" concat "." serveroutput on;
set underline on;
clear break compute;
ttitle off;
btitle off;

-- 获得生成报告名
column inst_num  heading "Inst Num"  new_value inst_num;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid;
column check_date heading "Check Date" new_value check_date format a12;

select d.dbid            dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;

select to_char(sysdate, 'yymmddhh24mi') check_date
  from dual;

column fname new_value fname;
select 'dbcheck_&&db_name'||'_'||'&&check_date'||'_'||trim('&&inst_num') as fname from dual;

set markup html on spool on pre off entmap off -
HEAD " -
<TITLE>Health Check for DB:&&db_name Inst:&&inst_name Date:&&check_date</TITLE> -
<meta author=&&author version=&&script_version email=&&email tel=&&tel/> -
<STYLE type='text/css'> -
body {font:bold 10pt Arial,Helvetica,Geneva,sans-serif;color:black; background:White;border-style:none;} -
h1 {font:bold 20pt Arial,Helvetica,Geneva,sans-serif;color:#336699;background-color:White;border-bottom:1px solid #cccc99;margin-top:0pt; margin-bottom:0pt;padding:0px 0px 0px 0px;} -
h2 {font:bold 18pt Arial,Helvetica,Geneva,sans-serif;color:#336699;background-color:White;margin-top:4pt; margin-bottom:0pt;} -
h3 {font:bold 16pt Arial,Helvetica,Geneva,sans-serif;color:#336699;background-color:White;margin-top:4pt; margin-bottom:0pt;} -
li {font: 8pt Arial,Helvetica,Geneva,sans-serif; color:black; background:White;} -
th {font:bold 8pt Arial,Helvetica,Geneva,sans-serif; color:white;background:#0066CC;padding-left:4px; padding-right:4px;padding-bottom:2px;border-style:none;} -
table { margin-left:0;border-collapse:separate;width:600;font:8pt Arial,Helvetica,sans-serif; border:0px;color:black; background:white;} -
tr { border-collapse:separate;font:8pt Arial,Helvetica,sans-serif; border:0px;color:black; background:white;} -
td { border-collapse:separate;font:8pt Arial,Helvetica,sans-serif; border:0px;color:black; background:#FFFFCC;} -
</STYLE> -
"
spool &&fname..html

-- general info
-- database info
col name for a9;
col db_unique_name heading "UNAME" for a10;
col database_role heading "DBROLE" for a10;
col platform_name heading "PLATFORM" for a10;
col version_time heading "Patch Time" 
select d.name,
       d.db_unique_name,
       d.database_role,
       d.created,
       d.log_mode,
       d.open_mode,
       d.version_time patch_time,
       d.force_logging
from v$database d;

-- instance info
col instance_number heading "INST_NUM" for 99999999;
col value heading "RAC" for a3;
select i.host_name,
       i.instance_number,
       i.instance_name,
       i.version,
       i.startup_time,
       i.status,
       i.archiver,
       i.database_status,
       decode(p.value, 'FALSE','No','Yes') value
from v$parameter p,
     v$instance i
where p.name = 'cluster_database';

--host info
col banner heading "Version" for a80;
select banner from v$version;

col "MEMRORY(GB)" for 9999.99
select
    (select HOST_NAME from v$instance ) "HOST_NAME",
    (select PLATFORM_NAME from v$database) "PLATFORM",
    (select value from v$osstat where stat_name='NUM_CPUS') "CPUS",
    (select value from v$osstat where stat_name='NUM_CPU_CORES') "CORES",
    (select value from v$osstat where stat_name='NUM_CPU_SOCKETS') "SOCKETS",
    (select value from v$osstat where stat_name='PHYSICAL_MEMORY_BYTES')/1024/1024/1024 "MEMRORY(GB)"
from dual;

--database key configuration
col name for a20;
col value for a10;
col display_value for a10;
select p.name,
       p.display_value,
       p.isdefault,
       p.ismodified,
       p.isadjusted,
       p.isbasic
  from v$parameter p
 where p.name in (
                    'instance_name',
                    'db_name',
                    'cpu_count',
                    'db_cache_size',
                    'db_block_size',
                    'memory_target',
                    'pga_aggregate_target',
                    'sga_max_size',
                    'sga_target',
                    'shared_pool_size',
                    'processes',
                    'sessions');

--national language support
col parameter for a30;
col value for a40;
select parameter,
       value
  from nls_database_parameters
 order by 1;

--database resource (process & session)
--DBA_HIST_ACTIVE_SESS_HISTORY
--

--database alert history





spool off;
exit;