#!/bin/bash

LOG_FILE="sysbench_test_$(date +%Y%m%d_%H%M%S).log"

print_line() {
  echo "========================================" | tee -a $LOG_FILE
}

log_and_run() {
  echo "$@" | tee -a $LOG_FILE  
  $@ >> $LOG_FILE 2>&1          
}

read -p "Enter number of tables (default: 10): " TABLES
TABLES=${TABLES:-10}

read -p "Enter number of rows per table (default: 1000000): " TABLE_SIZE
TABLE_SIZE=${TABLE_SIZE:-1000000}

read -p "Enter number of threads (default: 4): " THREADS
THREADS=${THREADS:-4}

read -p "Enter test duration in seconds (default: 300): " TIME
TIME=${TIME:-300}

read -p "Enter report interval in seconds (default: 10): " REPORT_INTERVAL
REPORT_INTERVAL=${REPORT_INTERVAL:-10}

print_line
echo "Sysbench Test Parameters:" | tee -a $LOG_FILE
echo "TABLES=$TABLES, TABLE_SIZE=$TABLE_SIZE, THREADS=$THREADS, TIME=$TIME, REPORT_INTERVAL=$REPORT_INTERVAL" | tee -a $LOG_FILE
print_line

echo "[1/3] Preparing data..." | tee -a $LOG_FILE
log_and_run sysbench /usr/share/sysbench/oltp_read_write.lua \
  --db-driver=pgsql \
  --pgsql-host=127.0.0.1 \
  --pgsql-port=5434 \
  --pgsql-user=postgres \
  --pgsql-password='postgres' \
  --pgsql-db=postgres \
  --tables=$TABLES \
  --table-size=$TABLE_SIZE \
  prepare

echo "[2/3] Running benchmark..." | tee -a $LOG_FILE
log_and_run sysbench /usr/share/sysbench/oltp_read_write.lua \
  --db-driver=pgsql \
  --pgsql-host=127.0.0.1 \
  --pgsql-port=5434 \
  --pgsql-user=postgres \
  --pgsql-password='postgres' \
  --pgsql-db=postgres \
  --tables=$TABLES \
  --table-size=$TABLE_SIZE \
  --threads=$THREADS \
  --time=$TIME \
  --report-interval=$REPORT_INTERVAL \
  run


echo "[3/3] Cleaning up..." | tee -a $LOG_FILE
log_and_run sysbench /usr/share/sysbench/oltp_read_write.lua \
  --db-driver=pgsql \
  --pgsql-host=127.0.0.1 \
  --pgsql-port=5434 \
  --pgsql-user=postgres \
  --pgsql-password='postgres' \
  --pgsql-db=postgres \
  --tables=$TABLES \
  --table-size=$TABLE_SIZE \
  cleanup


print_line
echo "Sysbench full test completed. Results saved to $LOG_FILE" | tee -a $LOG_FILE
