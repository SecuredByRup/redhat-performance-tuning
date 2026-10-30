#!/bin/bash

echo "=== Database Performance Analysis ==="
echo "Date: $(date)"
echo

echo "=== System Resource Usage ==="
free -h
echo
df -h
echo
uptime
echo

echo "=== Database Cache Hit Ratio ==="
sudo -u postgres psql testdb -c "
    SELECT 
        'Cache Hit Ratio' as metric,
        ROUND(
            (blks_hit::float / NULLIF(blks_hit + blks_read, 0)) * 100, 2
        ) as percentage
    FROM pg_stat_database 
    WHERE datname = 'testdb';
"

echo
echo "=== Table Access Statistics ==="
sudo -u postgres psql testdb -c "
    SELECT 
        schemaname,
        tablename,
        seq_scan,
        seq_tup_read,
        idx_scan,
        idx_tup_fetch
    FROM pg_stat_user_tables 
    ORDER BY seq_scan DESC;
"

echo
echo "=== Top Slow Queries (via pg_stat_statements) ==="
sudo -u postgres psql testdb -c "
    SELECT 
        LEFT(query, 80) as query_snippet,
        calls,
        ROUND(total_exec_time::numeric, 2) as total_time_ms,
        ROUND(mean_exec_time::numeric, 2) as avg_time_ms
    FROM pg_stat_statements 
    ORDER BY total_exec_time DESC 
    LIMIT 10;
"
