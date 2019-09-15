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
prompt </STYLE>
prompt </head>
prompt <body>

prompt <h1 id='header'>数据库巡检报告 DB:&&db_name Inst:&&inst_name</h1>

--print table of contents
prompt <h2>大纲</h2>
prompt <div class="contents">
prompt <ul>
prompt <li>
prompt <a href="#dbinfo">数据库基本信息</a>
prompt </li>
prompt <li>
prompt <a href="#dbspace">数据库空间管理</a>
prompt </li>
prompt <li>
prompt <a href="#dbschema">数据库对象管理</a>
prompt </li>
prompt <li>
prompt <a href="#performance">性能相关</a>
prompt </li>
prompt </ul>
prompt </div>

prompt <h3 id='dbinfo'>数据库基本信息</h3>
prompt <br>

set markup html on spool on pre off entmap off;
/* 数据库基本信息 */
--database info
prompt <p>数据库信息
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
prompt <p>实例信息
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
       decode(p.value, 'FALSE','No','Yes') value
from v$parameter p,
     v$instance i
where p.name = 'cluster_database'
;

--host info
prompt <p>主机信息
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
prompt <p>主要参数
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

/* 数据库资源管理 */
--database resource (process & session)
prompt <p>当前会话信息
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

/* 数据库空间管理 */
prompt <h3 id='dbspace'>数据库空间管理</h3>
--tablespace
prompt <p>表空间信息
clear column;
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
       e."SIZE" "SIZE(M)",
       e.USED "USED(M)",
       e."USED%",
      --  e.FREE "FREE(M)",
      --  e."FREE%",
       e.MAX "MAX(M)",
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

--datafile
prompt <p>数据文件
SELECT d.file_id,
       d.file_name,
       ROUND(d.bytes/1024/1024/1024) AS size_gb,
       ROUND(d.maxbytes/1024/1024/1024) AS max_size_gb,
       d.autoextensible,
       d.status
FROM   dba_data_files d
union
select t.FILE_ID,
       t.FILE_NAME,
       ROUND(t.bytes/1024/1024/1024) AS size_gb,
       ROUND(t.maxbytes/1024/1024/1024) AS max_size_gb,
       t.autoextensible,
       t.status
from DBA_TEMP_FILES t
order by FILE_ID
;

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
prompt <p>ASM磁盘信息
break on GROUP_NUMBER skip 1;
compute sum label Total of TOTAL_MB on GROUP_NUMBER;
compute sum label Total of FREE_MB on GROUP_NUMBER;
select g.NAME "GROUP_NAME",
       d.DISK_NUMBER,
       d.NAME,
       d.CREATE_DATE,
       d.MOUNT_DATE,
       d.STATE,
       d.TOTAL_MB,
       d.FREE_MB
from V$ASM_DISK d, V$ASM_DISKGROUP g
where d.GROUP_NUMBER = g.GROUP_NUMBER
order by d.GROUP_NUMBER
;
clear column compute;

--fast recovery area使用情况
prompt <p>闪回区使用情况
select substr(name, 1, 30) name,
        space_limit as quota,
        space_used as used,
        space_reclaimable as reclaimable,
        number_of_files as files
   from v$recovery_file_dest
;

select * from V$FLASH_RECOVERY_AREA_USAGE
;

prompt <h3 id='logfileinfo'>日志信息</h3>
--近期日志切换情况
prompt <p>近期日志切换情况
SELECT SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5) Day,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'00',1,0)) H00,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'01',1,0)) H01,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'02',1,0)) H02,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'03',1,0)) H03,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'04',1,0)) H04,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'05',1,0)) H05,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'06',1,0)) H06,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'07',1,0)) H07,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'08',1,0)) H08,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'09',1,0)) H09,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'10',1,0)) H10,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'11',1,0)) H11,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'12',1,0)) H12,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'13',1,0)) H13,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'14',1,0)) H14,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'15',1,0)) H15,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'16',1,0)) H16,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'17',1,0)) H17,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'18',1,0)) H18,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'19',1,0)) H19,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'20',1,0)) H20,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'21',1,0)) H21,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'22',1,0)) H22 ,
       SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'23',1,0)) H23,
       COUNT(*) TOTAL
FROM v$log_history  a
   where first_time>=to_char(sysdate-11)
GROUP BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
ORDER BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5) DESC
;

--日志组大小
prompt <p>日志信息
select group#,bytes,status
  from v$log
;

/* 对象管理 */
prompt <h3 id='dbschema'>数据库对象管理</h3>
--表有带并行度
prompt <p>带并行度表
select t.owner, t.table_name, degree
  from dba_tables t
where  trim(t.degree) <>'1'
   and trim(t.degree)<>'0'
   and owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and owner not like 'FLOWS%'
   and owner not like 'WK%'
;

--索引有带并行度
prompt <p>带并行度索引
select t.owner, t.table_name, index_name, degree, status
  from dba_indexes t
where  trim(t.degree) <>'1'
   and trim(t.degree)<>'0'
   and owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and owner not like 'FLOWS%'
   and owner not like 'WK%'
;

--失效索引
prompt <p>失效索引
select t.index_name,
       t.table_name,
       blevel,
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
prompt <p>失效对象
select t.owner,
       t.object_type,
       t.object_name
  from dba_objects t
 where STATUS='INVALID'
order by 1, 2
;

--位图索引和函数索引、反向键索引
prompt <p>位图索引、函数索引、反向索引
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
prompt <p>超过4个列的组合索引
select table_owner,table_name, index_name, count(*)
  from dba_ind_columns
where  table_owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and table_owner not like 'FLOWS%'
   and table_owner not like 'WK%'
 group by table_owner,table_name, index_name
having count(*) >= 4
 order by count(*) desc
;

--索引个数字超过5个的表
prompt <p>超过5个索引的表
select owner,table_name, count(*) cnt
  from dba_indexes
where  owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and owner not like 'FLOWS%'
   and owner not like 'WK%'
 group by owner,table_name
having count(*) >= 5
order by cnt desc
;

--哪些大表从未建过索引
prompt <p>未建索引的大表
select segment_name,
       bytes / 1024 / 1024 / 1024 "GB",
       blocks,
       tablespace_name
  from dba_segments
 where segment_type = 'TABLE'
   and segment_name not in (select table_name from dba_indexes)
   and bytes / 1024 / 1024 / 1024 >= 0.5
 order by GB desc
;
select segment_name, sum(bytes) / 1024 / 1024 / 1024 "GB", sum(blocks)
  from dba_segments
 where segment_type = 'TABLE PARTITION'
   and segment_name not in (select table_name from dba_indexes)
 group by segment_name
having sum(bytes) / 1024 / 1024 / 1024 >= 0.5
 order by GB desc
;

--哪些表的组合索引与单列索引存在交叉的情况
prompt <p>组合索引与单列索引交叉的表
select table_name, trunc(count(distinct(column_name)) / count(*),2) cross_idx_rate
  from dba_ind_columns
 where table_owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','ORDSYS','DBSNMP','OUTLN','TSMSYS')
   and table_owner not like 'FLOWS%'
   and table_owner not like 'WK%'
 group by table_name
having count(distinct(column_name)) / count(*) < 1 
order by cross_idx_rate desc
;

--哪些对象建在系统表空间上
prompt <p>建立在系统表空间的对象
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
prompt <p>对象大小Top 10
select *
  from (select owner,
               segment_name,
               segment_type,
               round(sum(bytes) / 1024 / 1024) object_size
          from DBA_segments
         group by owner, segment_name, segment_type
         order by object_size desc)
where rownum <= 10
;

--回收站情况(大小及数量）
prompt <p>回收站信息
select *
  from (select SUM(BYTES) / 1024 / 1024 / 1024 as recyb_size
          from DBA_SEGMENTS
         WHERE SEGMENT_NAME LIKE 'BIN$%') a,
       (select count(*) as recyb_cnt from dba_recyclebin)
;

--查谁占用了undo表空间
prompt <p>UNDO表空间使用情况
SELECT r.name "roll_segment_name", rssize/1024/1024/1024 "RSSize(G)",
       s.sid,
       s.serial#,
       s.username,
       s.status,
       s.sql_hash_value,
       s.SQL_ADDRESS,
       s.MACHINE,
       s.MODULE,
       substr(s.program, 1, 78) program,
       r.usn,
       hwmsize/1024/1024/1024, shrinks ,xacts
FROM sys.v_$session s,sys.v_$transaction t,sys.v_$rollname r, v$rollstat rs
WHERE t.addr = s.taddr and t.xidusn = r.usn and r.usn=rs.USN
Order by rssize desc
;

--查谁占用了temp表空间
prompt <p>TEMP表空间使用情况
select sql.sql_id,
       t.Blocks * 16 / 1024 / 1024,
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

--表大小超过10GB未建分区的
prompt <p>大于10G未建分区的表
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
prompt <p>分区最多的对象Top 10
select *
  from (select table_owner, table_name, count(*) cnt
          from dba_tab_partitions
         group by table_owner, table_name
         order by cnt desc)
where rownum <= 10
;

--分区不均匀的表
prompt <p>分区不均匀表
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
prompt <p>超过100和小于2个列的表
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
prompt <p>nologging表
select owner, table_name, tablespace_name, logging
  from dba_tables
 where logging = 'NO'
 and  owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB')
 and  owner not like 'FLOWS%'
;

--表属性含COMPRESSION的
prompt <p>compression表
select owner, table_name, tablespace_name, COMPRESSION
  from dba_tables
 where COMPRESSION = 'ENABLED'
 and  owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB')
 and  owner not like 'FLOWS%'
;

--索引属性含COMPRESSION的
prompt <p>compression索引
select owner, index_name, table_name, COMPRESSION
  from dba_indexes
 where COMPRESSION = 'ENABLED'
 and  owner not in ('SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB')
 and  owner not like 'FLOWS%'
;

--将外键未建索引的情况列出
prompt <p>外健未建索引
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
prompt <p>逻辑读SQL Top 10
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
prompt <p>物理读SQL Top 10
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
prompt <p>执行次数SQL Top 10
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
prompt <p>解析次数SQL Top 10
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
prompt <p>磁盘排序大于200
select sess.username, sql.address, sort1.blocks
  from v$session sess, v$sqlarea sql, v$sort_usage sort1
where sess.serial# = sort1.session_num
   and sort1.sqladdr = sql.address
   and sort1.sqlhash = sql.hash_value
   and sort1.blocks > 200
order by sort1.blocks desc
;

--查询共享内存占有率
prompt <p>共享内存占有率
select count(*),round(sum(sharable_mem)/1024/1024,2)
  from v$db_object_cache a
;

--检查统计信息是否被收集
prompt <p>统计信息收集情况
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
prompt <p>统计信息未收集或长时间未更新
select owner, count(*)
  from dba_tab_statistics t
where (t.last_analyzed is null or t.last_analyzed < sysdate - 100)
   and table_name not like 'BIN$%'
group by owner
order by owner
;

--被收集统计信息的临时表
prompt <p>收集统计信息的临时表
select owner, table_name, t.last_analyzed, t.num_rows, t.blocks
  from dba_tables t
where t.temporary = 'Y'
   and last_analyzed is not null
;


prompt </body>
prompt <html>
spool off;
exit;