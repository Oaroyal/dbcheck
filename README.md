# dbcheck

A database health check scripts

需要以sysdba权限执行，或者具备以下权限
dbms_workload_repository
dbms_advisor
DBMS_LOB

GRANT EXECUTE ON "SYS"."DBMS_WORKLOAD_REPOSITORY" TO "PYCLE";
GRANT EXECUTE ON "SYS"."DBMS_ADVISOR" TO "PYCLE";
GRANT EXECUTE ON "SYS"."DBMS_LOB" TO "PYCLE";