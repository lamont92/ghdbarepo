find /u01/app/oracle/diag/rdbms/cigprod/cigprod2/trace/*.trc  -mtime +10 -exec rm -f {} \;
find /u01/app/oracle/diag/rdbms/cigprod/cigprod2/trace/*.trm  -mtime +10 -exec rm -f {} \;
find /u01/app/oracle/admin/cigprod/adump/ -type f -name '*.aud' -mtime +10 -exec rm -f {} \;
find /u01/app/oracle/diag/rdbms/bc/bc2/trace/*.trc  -mtime +10 -exec rm -f {} \;
find /u01/app/oracle/product/12.1.0.2/db_1/rdbms/audit/  -type f -name '*.aud' -mtime +10 -exec rm -f {} \;
find /u01/app/oracle/diag/rdbms/bc/bc2/trace/*.trm  -mtime +10 -exec rm -f {} \;
find /u01/app/oracle/admin/bc/adump/ -type f -name '*.aud' -mtime +10 -exec rm -f {} \;
find /u01/app/oracle/diag/rdbms/cigpc/cigpc2/trace/*.trc  -mtime +10 -exec rm -f {} \;
find /u01/app/oracle/diag/rdbms/cigpc/cigpc2/trace/*.trm  -mtime +10 -exec rm -f {} \;
find /u01/app/oracle/admin/cigpc/adump/ -type f -name '*.aud' -mtime +10 -exec rm -f {} \;
