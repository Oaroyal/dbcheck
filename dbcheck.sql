def author="huangqw"
def script_version="0.1"
def email="john-wong@outlook.com"
def tel='18059869210'

set term on;
set heading on;
set verify off;
set feedback off;
set linesize 2000;
set pagesize 30000;
set long 999999999;
set longchunksize 999999;
set serveroutput on;
set SQLBLANKLINES off;
exec dbms_output.enabled()
clear break compute;
ttitle off;
btitle off;

-- 生成报告名
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

-- set markup html on spool on pre off entmap off -
-- HEAD " -
-- <TITLE>Health Check for DB:&&db_name Inst:&&inst_name</TITLE> -
-- <meta author=&&author version=&&script_version email=&&email tel=&&tel/> -
-- <STYLE type='text/css'> -
-- body {font:bold 10pt Arial,Helvetica,Geneva,sans-serif;color:black; background:White;border-style:none;} -
-- h1 {font:bold 20pt Arial,Helvetica,Geneva,sans-serif;color:#336699;background-color:White;border-bottom:1px solid #cccc99;margin-top:0pt; margin-bottom:0pt;padding:0px 0px 0px 0px;} -
-- h2 {font:bold 18pt Arial,Helvetica,Geneva,sans-serif;color:#336699;background-color:White;margin-top:4pt; margin-bottom:0pt;} -
-- h3 {font:bold 16pt Arial,Helvetica,Geneva,sans-serif;color:#336699;background-color:White;margin-top:4pt; margin-bottom:0pt;} -
-- li {font: 8pt Arial,Helvetica,Geneva,sans-serif; color:black; background:White;} -
-- a {font:bold 8pt Arial,Helvetica,sans-serif;color:#663300; vertical-align:top;margin-top:0pt; margin-bottom:0pt;}
-- th {font:bold 8pt Arial,Helvetica,Geneva,sans-serif; color:white;background:#0066CC;padding-left:4px; padding-right:4px;padding-bottom:2px;border-style:none;} -
-- table { margin-left:0;border-collapse:separate;width:600;font:8pt Arial,Helvetica,sans-serif; border:0px;color:black; background:white;} -
-- tr { border-collapse:separate;font:8pt Arial,Helvetica,sans-serif; border:0px;color:black; background:white;} -
-- td { border-collapse:separate;font:8pt Arial,Helvetica,sans-serif; border:0px;color:black; background:#FFFFCC;} -
-- </STYLE> -
-- "
spool &&fname..html
set markup html off;
prompt <html>
prompt <head>
prompt <TITLE>Health Check for DB:&&db_name Inst:&&inst_name</TITLE>
prompt <meta author=&&author version=&&script_version email=&&email tel=&&tel/>
prompt <STYLE type='text/css'>
prompt body {font:bold 10pt Arial,Helvetica,Geneva,sans-serif;color:black; background:White;border-style:none;}
prompt h1 {font:bold 20pt Arial,Helvetica,Geneva,sans-serif;color:#336699;background-color:White;border-bottom:1px solid #cccc99;margin-top:0pt; margin-bottom:0pt;padding:0px 0px 0px 0px;}
prompt h2 {font:bold 18pt Arial,Helvetica,Geneva,sans-serif;color:#336699;background-color:White;margin-top:4pt; margin-bottom:0pt;}
prompt h3 {font:bold 16pt Arial,Helvetica,Geneva,sans-serif;color:#336699;background-color:White;margin-top:4pt; margin-bottom:0pt;}
prompt li {font: 8pt Arial,Helvetica,Geneva,sans-serif; color:black; background:White;}
prompt a {font:bold 8pt Arial,Helvetica,sans-serif;color:#663300; vertical-align:top;margin-top:0pt; margin-bottom:0pt;}
prompt th {font:bold 8pt Arial,Helvetica,Geneva,sans-serif; color:white;background:#0066CC;padding-left:4px; padding-right:4px;padding-bottom:2px;border-style:none;}
prompt table { margin-left:0;border-collapse:separate;width:600;font:8pt Arial,Helvetica,sans-serif; border:0px;color:black; background:white;}
prompt tr { border-collapse:separate;font:8pt Arial,Helvetica,sans-serif; border:0px;color:black; background:white;}
prompt td { border-collapse:separate;font:8pt Arial,Helvetica,sans-serif; border:0px;color:black; background:#FFFFCC;}
prompt p.desc {font: 8pt Arial,Helvetica,Geneva,sans-serif; color:Crimson; background:White;font-style:italic;}
prompt </STYLE>
prompt </head>
prompt <body>

prompt <h1 id='header'>Health Check for DB:&&db_name Inst:&&inst_name</h1>

--print table of contents
prompt <h2>Table of Contents</h2>
prompt <div class="contents">
prompt <ul>
prompt <li>
prompt <a href="#dbinfo">General Info</a>
prompt </li>
prompt <li>
prompt <a href="#dbspace">Space Info</a>
prompt </li>
prompt <li>
prompt <a href="#logfileinfo">Log Info</a>
prompt </li>
prompt <li>
prompt <a href="#dbschema">Schema Info</a>
prompt </li>
prompt <li>
prompt <a href="#performance">Performance Info</a>
prompt </li>
prompt </ul>
prompt </div>

prompt <h3 id='dbinfo'>General Info</h3>
prompt <br>

set markup html on spool on pre off entmap off;
/* 数据库基本信息 */
--database info
prompt <p>Database Info
col name for a9;
col db_unique_name heading "UNAME" for a10;
col database_role heading "DBROLE" for a10;
col platform_name heading "PLATFORM" for a10;
col version_time heading "PATCH_TIME" 
select d.name,
       d.db_unique_name,
       d.database_role,
       d.created,
       d.log_mode,
       d.open_mode,
       d.version_time patch_time,
       d.force_logging
from v$database d
;

-- instance info
prompt <p>Instance Info
col instance_number heading "INST_NUM" for 99999999;
col value heading "RAC" for a3;
col startup_time heading "STARTUP" for a12;
col database_status heading "STATUS";
select i.host_name,
       i.instance_number,
       i.instance_name,
       i.version,
       i.startup_time,
       i.status,
       i.archiver,
       i.database_status,
       decode(p.value, 'FALSE','No','Yes') "VALUE"
from v$parameter p,
     v$instance i
where p.name = 'cluster_database'
;

--host info
prompt <p>Host OS Info
col "MEMRORY(GB)" for 9999.99
select
    (select HOST_NAME from v$instance ) "HOST_NAME",
    (select PLATFORM_NAME from v$database) "PLATFORM",
    (select value from v$osstat where stat_name='NUM_CPUS') "CPUS",
    (select value from v$osstat where stat_name='NUM_CPU_CORES') "CORES",
    (select value from v$osstat where stat_name='NUM_CPU_SOCKETS') "SOCKETS",
    (select value from v$osstat where stat_name='PHYSICAL_MEMORY_BYTES')/1024/1024/1024 "MEMRORY(GB)"
from dual
;

--database key configuration
prompt <p>Key Parameters
col name for a20;
col value for a10;
col display_value heading "VALUE" for a10;
select p.name,
       p.display_value,
       p.isdefault,
       p.ismodified,
       p.isadjusted,
       p.isbasic
  from v$parameter p
 where p.name in (
                    'cpu_count',
                    'db_cache_size',
                    'db_block_size',
                    'memory_target',
                    'pga_aggregate_target',
                    'sga_max_size',
                    'sga_target',
                    'shared_pool_size',
                    'processes',
                    'sessions')
  order by p.name
;

/* 数据库资源信息 */
--database resource (process & session)
prompt <p>Current Session Info
col status heading "CURRENT SESSION STATUS" for a25;
col count for 999999;
col MAX_VALUE heading "MAX VALUE" for 999999;
select distinct v.STATUS,
                count(v.STATUS) over (partition by v.status) "COUNT",
                (select display_value from v$parameter where name = 'sessions') "MAX_VALUE"
from v$session v
where v.username is not null
order by v.STATUS
;
--如果会话数大于参数值的60%
set markup html off;
declare
scount number;
smax number;
begin
  select count(v.status)
    into scount
    from v$session v
   where v.username is not null;
  select p.value
    into smax
    from v$parameter p
   where p.name = 'sessions';
  if scount/smax < 0.6 then
    dbms_output.put_line('<p class="desc">当前会话利用率小于百分之60');
  else
    dbms_output.put_line('<p class="desc">当前会话利用率大于百分之60');
  end if;
end;
/
set markup html on;

/* 数据库空间信息 */
prompt <h3 id='dbspace'>Space Info</h3>
--tablespace
prompt <p>Tablespace Info
clear column;
column tablespace_name heading "NAME";
column "SIZE(G)" for 999999.999;
column "USED(G)" for 999999.999;
column "MAX(G)" for 999999.999;
with e as (SELECT a.tablespace_name,
                  ROUND(a.bytes_alloc / 1024 / 1024)        "SIZE",
                  ROUND(NVL(b.bytes_free, 0) / 1024 / 1024) "FREE",
                  ROUND((a.bytes_alloc - NVL(b.bytes_free, 0)) / 1024 / 1024)
                                                            "USED",
                  ROUND((NVL(b.bytes_free, 0) / a.bytes_alloc) * 100)
                                                            "FREE%",
                  100 - ROUND((NVL(b.bytes_free, 0) / a.bytes_alloc) * 100)
                                                            "USED%",
                  ROUND(maxbytes / 1048576)                 "MAX"
           FROM (SELECT f.tablespace_name,
                        SUM(f.bytes) bytes_alloc,
                        SUM(
                                DECODE(f.autoextensible,
                                       'YES', f.maxbytes,
                                       'NO', f.bytes))
                                     maxbytes
                 FROM dba_data_files f
                 GROUP BY tablespace_name) a,
                (SELECT f.tablespace_name, SUM(f.bytes) bytes_free
                 FROM dba_free_space f
                 GROUP BY tablespace_name) b
           WHERE a.tablespace_name = b.tablespace_name(+)
           UNION ALL
           SELECT h.tablespace_name,
                  ROUND(SUM(h.bytes_free + h.bytes_used) / 1048576) "SIZE",
                  ROUND(
                              SUM((h.bytes_free + h.bytes_used) - NVL(p.bytes_used, 0))
                              / 1048576)
                                                                    "FREE",
                  ROUND(SUM(NVL(p.bytes_used, 0)) / 1048576)        "USED",
                  ROUND(
                              (SUM((h.bytes_free + h.bytes_used) - NVL(p.bytes_used, 0))
                                  / SUM(h.bytes_used + h.bytes_free))
                              * 100)
                                                                    "FREE%",
                  100
                      - ROUND(
                              (SUM((h.bytes_free + h.bytes_used) - NVL(p.bytes_used, 0))
                                  / SUM(h.bytes_used + h.bytes_free))
                              * 100)
                                                                    "USED%",
                  ROUND(
                          SUM(
                                      DECODE(f.autoextensible, 'YES', f.maxbytes, 'NO', f.bytes)
                                      / 1048576))
                                                                    "MAX"
           FROM sys.v_$temp_space_header h,
                sys.v_$temp_extent_pool p,
                dba_temp_files f
           WHERE p.file_id(+) = h.file_id
             AND p.tablespace_name(+) = h.tablespace_name
             AND f.file_id = h.file_id
             AND f.tablespace_name = h.tablespace_name
           GROUP BY h.tablespace_name)
select t.tablespace_name,
       e."SIZE"/1024 "SIZE(G)",
       e.USED/1024 "USED(G)",
       e."USED%",
      --  e.FREE "FREE(M)",
      --  e."FREE%",
       e.MAX/1024 "MAX(G)",
      --  t.block_size "BLOCK_SIZE(K)",
       t.status,
       t.contents,
       t.logging,
       t.force_logging
      --  t.bigfile
from dba_tablespaces t
         left outer join e
                         on e.tablespace_name = t.tablespace_name
order by tablespace_name
;
clear column;
begin
  dbms_output.put_line('<p class="desc">注意使用率大于百分之80的表空间');
end;
/

--datafile
prompt <p>Data File
SELECT d.tablespace_name,
       d.file_name,
       ROUND(d.bytes/1024/1024/1024) AS "SIZE(G)",
       ROUND(d.maxbytes/1024/1024/1024) AS "MAX(G)",
       d.autoextensible,
       d.status
FROM   dba_data_files d
union
select t.tablespace_name,
       t.FILE_NAME,
       ROUND(t.bytes/1024/1024/1024) AS "SIZE(G)",
       ROUND(t.maxbytes/1024/1024/1024) AS "MAX(G)",
       t.autoextensible,
       t.status
from DBA_TEMP_FILES t
order by tablespace_name
;
begin
  dbms_output.put_line('<p class="desc">注意未使用自动扩展的数据文件的使用情况');
end;
/

--asmdisk
-- declare
--   isasm number;
-- begin
--   select count(*)
--     into isasm
--     from v$asm_disk;
--   if isasm > 0 then
--     dbms_output.put_line('<p>ASM磁盘信息');
--   end if;
-- end;
prompt <p>ASM Disks Info
break on GROUP_NAME skip 1;
compute sum label "Total --------->" of "TOTAL(G)" on GROUP_NAME;
compute sum label "Total --------->" of "FREE(G)" on GROUP_NAME;
column "TOTAL(G)" for 999999.999;
column "FREE(G)" for 999999.999;
select g.NAME "GROUP_NAME",
       d.DISK_NUMBER,
       d.NAME,
       d.CREATE_DATE,
       d.MOUNT_DATE,
       d.STATE,
       d.TOTAL_MB/1024 "TOTAL(G)",
       d.FREE_MB/1024 "FREE(G)"
from V$ASM_DISK d, V$ASM_DISKGROUP g
where d.GROUP_NUMBER = g.GROUP_NUMBER
order by d.GROUP_NUMBER
;
clear column compute;

--fast recovery area使用情况
prompt <p>Flash Recovery Area Info
select substr(name, 1, 30) "NAME",
        space_limit "QUOTA",
        space_used "USED",
        space_reclaimable "RECLAIMABLE",
        number_of_files "FILES"
   from v$recovery_file_dest
;

select * from V$FLASH_RECOVERY_AREA_USAGE
;

prompt <h3 id='logfileinfo'>日志信息</h3>
--近期日志切换情况
prompt <p>Lately Redo Log Switch Info
SELECT SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5) "DAY",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'00',1,0)) "00",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'01',1,0)) "01",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'02',1,0)) "02",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'03',1,0)) "03",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'04',1,0)) "04",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'05',1,0)) "05",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'06',1,0)) "06",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'07',1,0)) "07",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'08',1,0)) "08",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'09',1,0)) "09",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'10',1,0)) "10",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'11',1,0)) "11",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'12',1,0)) "12",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'13',1,0)) "13",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'14',1,0)) "14",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'15',1,0)) "15",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'16',1,0)) "16",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'17',1,0)) "17",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'18',1,0)) "18",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'19',1,0)) "19",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'20',1,0)) "20",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'21',1,0)) "21",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'22',1,0)) "22",
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'23',1,0)) "23",
       COUNT(*) "TOTAL"
FROM v$log_history  a
   where first_time>=to_char(sysdate-11)
GROUP BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
ORDER BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5) DESC
;
begin
  dbms_output.put_line('<p class="desc">日志每小时切换次数越大说明该时间内越繁忙');
end;
/

--日志组大小
prompt <p>Redo Log Info
column "SIZE(G)" for 999999.999;
select group#,
       bytes/1024/1204 "SIZE(G)",
       members,
       archived,
       status
  from v$log
;

/* 对象信息 */
prompt <h3 id='dbschema'>数据库对象信息</h3>
--表有带并行度
prompt <p>Tables with Parallel Degree
select t.owner,
       t.table_name,
       degree
  from dba_tables t
where  trim(t.degree) <>'1'
   and trim(t.degree)<>'0'
   and owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and owner not like 'FLOWS%'
   and owner not like 'WK%'
;

--索引有带并行度
prompt <p>Indexes with Parallel Degree
select t.owner,
       t.table_name,
       index_name,
       degree,
       status
  from dba_indexes t
where  trim(t.degree) <>'1'
   and trim(t.degree)<>'0'
   and owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and owner not like 'FLOWS%'
   and owner not like 'WK%'
;

--失效索引
prompt <p>Invalid Indexes
select t.index_name,
       t.table_name,
       t.blevel,
       t.num_rows,
       t.leaf_blocks,
       t.distinct_keys
  from dba_indexes t
  where status = 'UNUSABLE'
  and  table_owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB')
  and  table_owner not like 'FLOWS%'
;
select t2.owner,
       t1.blevel,
       t1.leaf_blocks,
       t1.INDEX_NAME,
       t2.table_name,
       t1.PARTITION_NAME,
       t1.STATUS
  from dba_ind_partitions t1, dba_indexes t2
where t1.index_name = t2.index_name
   and t1.STATUS = 'UNUSABLE'
;

--失效对象
prompt <p>Invalid Objects
select t.owner,
       t.object_type,
       t.object_name
  from dba_objects t
 where STATUS='INVALID'
order by 1, 2
;

--位图索引和函数索引、反向键索引
prompt <p>Bitmap Index|Function-based Index|Reverse Index
select t.owner,
       t.table_name,
       t.index_name,
       t.index_type,
       t.status,
       t.blevel,
       t.leaf_blocks
  from dba_indexes t
 where index_type in ('BITMAP', 'FUNCTION-BASED NORMAL', 'NORMAL/REV')
   and owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and owner not like 'FLOWS%'
   and owner not like 'WK%'
;

--组合索引组合列超过4个的
prompt <p>Composite Index with 4 or More Columns
select table_owner,
       table_name,
       index_name,
       count(*)
  from dba_ind_columns
where  table_owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and table_owner not like 'FLOWS%'
   and table_owner not like 'WK%'
 group by table_owner,table_name, index_name
having count(*) >= 4
 order by count(*) desc
;

--索引个数字超过5个的表
prompt <p>Tables with 5 or More Index
select owner,
       table_name,
       count(*) "COUNT"
  from dba_indexes
where  owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and owner not like 'FLOWS%'
   and owner not like 'WK%'
 group by owner,table_name
having count(*) >= 5
order by "COUNT" desc
;

--哪些大表从未建过索引
prompt <p>Big Table with no Index
select segment_name,
       bytes / 1024 / 1024 / 1024 "SIZE(G)",
       blocks,
       tablespace_name
  from dba_segments
 where segment_type = 'TABLE'
   and segment_name not in (select table_name from dba_indexes)
   and bytes / 1024 / 1024 / 1024 >= 0.5
 order by "SIZE(G)" desc
;
select segment_name,
       sum(bytes) / 1024 / 1024 / 1024 "SIZE(G)",
       sum(blocks) "BLOCKS"
  from dba_segments
 where segment_type = 'TABLE PARTITION'
   and segment_name not in (select table_name from dba_indexes)
 group by segment_name
having sum(bytes) / 1024 / 1024 / 1024 >= 0.5
 order by "SIZE(G)" desc
;

--哪些表的组合索引与单列索引存在交叉的情况
prompt <p>Composite Index Cross with Single Column Index
select table_name,
       trunc(count(distinct(column_name)) / count(*),2) "CROSS_IDX_RATE"
  from dba_ind_columns
 where table_owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and table_owner not like 'FLOWS%'
   and table_owner not like 'WK%'
 group by table_name
having count(distinct(column_name)) / count(*) < 1 
order by cross_idx_rate desc
;

--哪些对象建在系统表空间上
prompt <p>Objects in SYSTEM|SYSAUX Tablespace
select * from (
select owner, segment_name, tablespace_name, count(*) num
  from dba_segments
 where tablespace_name in('SYSTEM','SYSAUX')
group by owner, segment_name, tablespace_name)
where  owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and owner not like 'FLOWS%'
   and owner not like 'WK%'
;

--TOP 10 对象大小
prompt <p>Top 10 Size Objects
column object_size heading "SIZE(G)" for 999999.999;
select *
  from (select owner,
               segment_name,
               segment_type,
               round(sum(bytes) / 1024 / 1024 / 1024) object_size
          from DBA_segments
         group by owner, segment_name, segment_type
         order by object_size desc)
where rownum <= 10
;

--回收站情况(大小及数量）
prompt <p>Recyclebin Info
column recyb_size heading "SIZE(G)" for 999999.999;
column recyb_cnt heading "COUNT";
select *
  from (select SUM(BYTES) / 1024 / 1024 / 1024 as recyb_size
          from DBA_SEGMENTS
         WHERE SEGMENT_NAME LIKE 'BIN$%') a,
       (select count(*) as recyb_cnt from dba_recyclebin)
;

--查谁占用了undo表空间
prompt <p>UNDO Tablespace Usage
SELECT r.name "roll_segment_name", rssize/1024/1024/1024 "RSSIZE(G)",
       s.sid,
       s.serial#,
       s.username,
       s.status,
       s.sql_hash_value,
       s.SQL_ADDRESS,
       s.MACHINE,
       s.MODULE,
       substr(s.program, 1, 78) "PROGRAM",
       r.usn,
       hwmsize/1024/1024/1024, shrinks ,xacts
FROM sys.v_$session s,sys.v_$transaction t,sys.v_$rollname r, v$rollstat rs
WHERE t.addr = s.taddr and t.xidusn = r.usn and r.usn=rs.USN
Order by rssize desc
;

--查谁占用了temp表空间
prompt <p>TEMP Tablespace Usage
select sql.sql_id,
       t.Blocks * 16 / 1024 / 1024 "BLOCKS",
       s.USERNAME,
       s.SCHEMANAME,
       t.tablespace,
       t.segtype,
       t.extents,
       s.PROGRAM,
       s.OSUSER,
       s.TERMINAL,
       s.sid,
       s.SERIAL#
  from v$sort_usage t, v$session s , v$sql sql
where t.SESSION_ADDR = s.SADDR
  and t.SQLADDR=sql.ADDRESS
  and t.SQLHASH=sql.HASH_VALUE
;

COLUMN temp_used FORMAT 9999999999
SELECT NVL(s.username, '(background)') AS username,
       s.sid,
       s.serial#,
       ROUND(ss.value/1024/1024, 2) AS temp_used_mb
FROM   v$session s
       JOIN v$sesstat ss ON s.sid = ss.sid
       JOIN v$statname sn ON ss.statistic# = sn.statistic#
WHERE  sn.name = 'temp space allocated (bytes)'
AND    ss.value > 0
ORDER BY 1
;

--表大小超过10GB未建分区的
prompt <p>Big Table with no Partition
column object_size heading "SIZE(G)";
select owner,
       segment_name,
       segment_type,
       round(sum(bytes) / 1024 / 1024 / 1024,2) object_size
  from dba_segments
where segment_type = 'TABLE'
  and bytes > 10*1024*1024*1024
group by owner, segment_name, segment_type
order by object_size desc
;

--分区最多的前10个对象
prompt <p>Most Partitions Objects
select *
  from (select table_owner, table_name, count(*) cnt
          from dba_tab_partitions
         group by table_owner, table_name
         order by cnt desc)
where rownum <= 10
;

--分区不均匀的表
prompt <p>Uneven Partition Tables
select *
  from (select table_owner,
               table_name,
               max(num_rows) max_num_rows,
               trunc(avg(num_rows), 0) avg_num_rows,
               sum(num_rows) sum_num_rows,
               case
                 when sum(num_rows) = 0 then
                  0
                 else
                  trunc(max(num_rows) / trunc(avg(num_rows), 0), 2)
               end rate,
			   count(*) part_count
          from dba_tab_partitions
         group by table_owner, table_name)
where rate > 5
;

--列数量超过100个或小于2的表
prompt <p>Table with Less 2 and Greater 100 Columns
select *
  from (select owner, table_name, count(*) col_count
          from dba_tab_cols
         group by owner, table_name)
 where col_count > 100
    or col_count <= 2
 and  owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB')
 and  owner not like 'FLOWS%'
;

--表属性是nologging的
prompt <p>Table with nologging
select owner, table_name, tablespace_name, logging
  from dba_tables
 where logging = 'NO'
 and  owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB')
 and  owner not like 'FLOWS%'
;

--表属性含COMPRESSION的
prompt <p>Table with COMPRESSION
select owner, table_name, tablespace_name, COMPRESSION
  from dba_tables
 where COMPRESSION = 'ENABLED'
 and  owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB')
 and  owner not like 'FLOWS%'
;

--索引属性含COMPRESSION的
prompt <p>Index with COMPRESSION
select owner, index_name, table_name, COMPRESSION
  from dba_indexes
 where COMPRESSION = 'ENABLED'
 and  owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB')
 and  owner not like 'FLOWS%'
;

--将外键未建索引的情况列出
prompt <p>Foreign Key with no Index
select *
  from (select pk.owner PK_OWNER,
               pk.constraint_name PK_NAME,
               pk.table_name PK_TABLE_NAME,
               fk.owner FK_OWNER,
               fk.constraint_name FK_NAME,
               fk.table_name FK_TABLE_NAME,
               fk.delete_rule FK_DELETE_RULE,
               ind_col.INDEX_NAME FK_INDEX_NAME,
               ind.index_type FK_INDEX_TYPE,
               con_col.COLUMN_NAME FK_INDEX_COLUMN_NAME,
               con_col.POSITION FK_INDEX_COLUMN_POSITION,
               decode(ind_col.INDEX_NAME,
                      NULL,
                      NULL,
                      NVL(x_ind.status, 'VALID')) IS_IND_VALID,
               decode(ind_col.INDEX_NAME,
                      NULL,
                      NULL,
                      NVL(x_ind_part.status, 'VALID')) IS_IND_PART_VALID
          from (select * from dba_constraints where constraint_type = 'R') fk,
               (select * from dba_constraints where constraint_type = 'P') pk,
               dba_cons_columns con_col,
               dba_ind_columns ind_col,
               dba_indexes ind,
               (select index_owner, index_name, status
                  from dba_ind_partitions
                 where status <> 'VALID') x_ind_part,
               (select owner as index_owner, index_name, status
                  from dba_indexes
                 where status <> 'VALID') x_ind
         where fk.r_constraint_name = pk.constraint_name
           and pk.owner = fk.owner
           and fk.owner = con_col.owner
           and fk.table_name = con_col.table_name
           and fk.constraint_name = con_col.CONSTRAINT_NAME
           and con_col.owner = ind_col.TABLE_OWNER(+)
           and con_col.TABLE_NAME = ind_col.TABLE_NAME(+)
           and con_col.COLUMN_NAME = ind_col.COLUMN_NAME(+)
           and ind_col.INDEX_OWNER = ind.owner(+)
           and ind_col.INDEX_NAME = ind.index_name(+)
           and ind_col.INDEX_OWNER = x_ind.index_owner(+)
           and ind_col.INDEX_NAME = x_ind.index_name(+)
           and ind_col.INDEX_OWNER = x_ind_part.index_owner(+)
           and ind_col.INDEX_NAME = x_ind_part.index_name(+))
 where FK_INDEX_NAME is null
 order by FK_OWNER ASC
;

/* 性能相关 */
prompt <h3 id='performance'>性能相关</h3>
--逻辑读最多
prompt <p>Physical Read Top 10
select *
  from (select sql_id,
               s.EXECUTIONS,
               s.LAST_LOAD_TIME,
               s.FIRST_LOAD_TIME,
               s.DISK_READS,
               s.BUFFER_GETS
          from v$sql s
         where s.buffer_gets > 300
         order by buffer_gets desc)
where rownum <= 10
;

--物理读最多
prompt <p>Logical Read Top 10
select *
  from (select sql_id,
       s.EXECUTIONS,
       s.LAST_LOAD_TIME,
       s.FIRST_LOAD_TIME,
       s.DISK_READS,
       s.BUFFER_GETS,
       s.PARSE_CALLS
  from v$sql s
where s.disk_reads > 300
order by disk_reads desc)
where rownum<=10
;

--执行次数最多
prompt <p>Execution Top 10
select *
  from (select sql_id,
               s.EXECUTIONS,
               s.LAST_LOAD_TIME,
               s.FIRST_LOAD_TIME,
               s.DISK_READS,
               s.BUFFER_GETS,
               s.PARSE_CALLS
          from v$sql s
         order by s.EXECUTIONS desc)
where rownum <= 10
;

--解析次数最多
prompt <p>Parse Top 10
select *
  from (select sql_id,
               s.EXECUTIONS,
               s.LAST_LOAD_TIME,
               s.FIRST_LOAD_TIME,
               s.DISK_READS,
               s.BUFFER_GETS,
               s.PARSE_CALLS
          from v$sql s
         order by s.PARSE_CALLS desc)
where rownum <= 10
;

--磁盘排序最多
prompt <p>Sorts(disk) Top 10
select sess.username, sql.address, sort1.blocks
  from v$session sess, v$sqlarea sql, v$sort_usage sort1
where sess.serial# = sort1.session_num
   and sort1.sqladdr = sql.address
   and sort1.sqlhash = sql.hash_value
   and sort1.blocks > 200
order by sort1.blocks desc
;

--查询共享内存占有率
prompt <p>Sharable Memory
select count(*),round(sum(sharable_mem)/1024/1024,2)
  from v$db_object_cache a
;

--检查统计信息是否被收集
prompt <p>Optimizer Stats Info
select t.job_name,t.program_name,t.state,t.enabled
  from dba_scheduler_jobs t
where job_name = 'GATHER_STATS_JOB'
;
select client_name,status
  from dba_autotask_client
;
select window_next_time,autotask_status
  from DBA_AUTOTASK_WINDOW_CLIENTS
;

--检查哪些未被收集或者很久没收集
prompt <p>Out-of-date Optimizer Stats
select owner, count(*)
  from dba_tab_statistics t
where (t.last_analyzed is null or t.last_analyzed < sysdate - 100)
   and table_name not like 'BIN$%'
group by owner
order by owner
;

--被收集统计信息的临时表
prompt <p>Temporary Table with Optimizer Stat
select owner, table_name, t.last_analyzed, t.num_rows, t.blocks
  from dba_tables t
where t.temporary = 'Y'
   and last_analyzed is not null
;


prompt </body>
prompt <html>
spool off;


clear column compute;
/* 获取awr、addm、ash */
--以下不使用html标签
SET markup html off spool ON pre off entmap off

set trim on
set trimspool on
set heading off

--查询dbid、instance_number
column dbid new_value awr_dbid
column instance_number new_value awr_inst_num
select dbid from v$database;
select instance_number from v$instance;

--半小时内的ash报告
column ashbegintime new_value ashbegin_str
column ashendtime new_value ashend_str
select to_char(sysdate-3/144,'yyyymmddhh24miss') as ashbegintime, to_char(sysdate,'yyyymmddhh24miss') as ashendtime from dual;

column ashfile_name new_value ashfile
select 'ashrpt_' || to_char(&&awr_inst_num) || '_' || to_char(&&ashbegin_str) || '_' || to_char(&&ashend_str) ashfile_name from dual;
spool &&ashfile..html
select * from table(dbms_workload_repository.ash_report_html(to_char(&&awr_dbid),to_char(&&awr_inst_num),to_date(to_char(&&ashbegin_str),'yyyymmddhh24miss'),to_date(to_char(&&ashend_str),'yyyymmddhh24miss')));
spool off;

--按需创建awr断点
column begin_snap new_value awr_begin_snap
column end_snap new_value awr_end_snap
select max(snap_id) begin_snap
  from dba_hist_snapshot
 where snap_id < (select max(snap_id) from dba_hist_snapshot);
select max(snap_id) end_snap from dba_hist_snapshot;
declare
  snap_maxtime date;
  snap_mintime date;
begin
  select max(end_interval_time) + 0
    into snap_maxtime
    from dba_hist_snapshot
   where snap_id = to_number(&&awr_end_snap);
  select max(end_interval_time) + 0
    into snap_mintime
    from dba_hist_snapshot
   where snap_id = to_number(&&awr_begin_snap);
  if sysdate - snap_maxtime > 10/1445 then
    dbms_workload_repository.create_snapshot();
  end if;
end;
/

--最新两次snap_id间的awr报告
column begin_snap new_value awr_begin_snap
column end_snap new_value awr_end_snap
select max(snap_id) begin_snap
  from dba_hist_snapshot
 where snap_id < (select max(snap_id) from dba_hist_snapshot);
select max(snap_id) end_snap from dba_hist_snapshot;
column awrfile_name new_value awrfile
select 'awrrpt_' || to_char(&&awr_inst_num) || '_' || to_char(&&awr_begin_snap) || '_' || to_char(&&awr_end_snap) awrfile_name from dual;

spool &&awrfile..html
select output from table(dbms_workload_repository.awr_report_html(&&awr_dbid,&&awr_inst_num,&&awr_begin_snap,&&awr_end_snap));
spool off;


--可获取的最长awr报告(一周以来的所有分析)
column begin_snap new_value awr_begin_snap
column end_snap new_value awr_end_snap
select a.begin_snap, a.end_snap
  from (select startup_time, min(snap_id) begin_snap, max(snap_id) end_snap
          from dba_hist_snapshot
         group by startup_time) a,
       (select max(startup_time) startup_time from dba_hist_snapshot) b
 where a.startup_time = b.startup_time
   and rownum = 1;
column awrfile_name new_value awrfile
select 'awrrpt_' || to_char(&&awr_inst_num) || '_' || to_char(&&awr_begin_snap) || '_' || to_char(&&awr_end_snap) ||'_all' awrfile_name from dual;

spool &&awrfile..html
select output from table(dbms_workload_repository.awr_report_html(&&awr_dbid,&&awr_inst_num,&&awr_begin_snap,&&awr_end_snap));
spool off;


--最新addm报告
-- column addmfile_name new_value addmfile
-- select 'addmrpt_' || to_char(&&awr_inst_num) || '_' || to_char(&&awr_begin_snap) || '_' || to_char(&&awr_end_snap) addmfile_name from dual;
-- set serveroutput on
-- spool &&addmfile..txt
-- declare
--   id          number;
--   name		  varchar2(200) := '';
--   descr       varchar2(500) := '';
--   addmrpt     clob;
--   v_ErrorCode number;
-- BEGIN
--   name := '&&addmfile';
--   begin
--     dbms_advisor.create_task('ADDM', id, name, descr, null);
--     dbms_advisor.set_task_parameter(name, 'START_SNAPSHOT', &&awr_begin_snap);
--     dbms_advisor.set_task_parameter(name, 'END_SNAPSHOT', &&awr_end_snap);
--     dbms_advisor.set_task_parameter(name, 'INSTANCE', &&awr_inst_num);
--     dbms_advisor.set_task_parameter(name, 'DB_ID', &&awr_dbid);
--     dbms_advisor.execute_task(name);
--   exception
--     when others then
--       null;
--   end;
--   select dbms_advisor.get_task_report(name, 'TEXT', 'TYPICAL')
--     into addmrpt
--     from sys.dual;
--   dbms_output.enable(20000000000);
--   for i in 1 .. (DBMS_LOB.GETLENGTH(addmrpt) / 2000 + 1) loop
--     dbms_output.put_line(substr(addmrpt, 1900 * (i - 1) + 1, 1900));
--   end loop;
--   dbms_output.put_line('');
--   begin
--     dbms_advisor.delete_task(name);
--   exception
--     when others then
--       null;
--   end;
-- end;
-- /
-- spool off;

exit;