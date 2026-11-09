--Create table ‘table_to_delete’ and fill it with the following query
CREATE TABLE table_to_delete AS
SELECT 'veeeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x;

--Lookup how much space this table consumes with the following query
SELECT *, pg_size_pretty(total_bytes) AS total,
pg_size_pretty(index_bytes) AS INDEX,
pg_size_pretty(toast_bytes) AS toast,
pg_size_pretty(table_bytes) AS TABLE
FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
FROM (SELECT c.oid,nspname AS table_schema,
relname AS TABLE_NAME,
c.reltuples AS row_estimate,
pg_total_relation_size(c.oid) AS total_bytes,
pg_indexes_size(c.oid) AS index_bytes,
pg_total_relation_size(reltoastrelid) AS toast_bytes
FROM pg_class c
LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE relkind = 'r'
) a
) a
WHERE table_name LIKE '%table_to_delete%';


--Result total bytes - 602mb


--Issue the following DELETE operation on ‘table_to_delete’
-- a) result 13s
DELETE FROM table_to_delete
WHERE REPLACE(col, 'veeeeeeeery_long_string','')::int % 3 = 0;

-- b) Lookup how much space this table consumes after previous DELETE
-- result 602mb.

-- c) Perform the following command 
VACUUM FULL VERBOSE table_to_delete;

-- d) Check space consumption of the table once again and make conclusions;
-- result 401mb.

-- e) Recreate ‘table_to_delete’ table
DROP TABLE table_to_delete;

CREATE TABLE table_to_delete AS
SELECT 'veeeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x;

--Issue the following TRUNCATE operation: TRUNCATE table_to_delete;
-- a) Note how much time it takes to perform this TRUNCATE statement
--result 1,1s
TRUNCATE table_to_delete;

-- b) b) Compare with previous results and make conclusion.
--result TRUNCATE works faster
-- c) Check space consumption of the table once again and make conclusions
-- result 8mb


-- task result



--a) Space consumption of 'table_to_delete' 
	--before DELETE: 602 MB
	--after DELETE: 602 MB (не змінилося)
	--after VACUUM FULL: 401 MB
	--after TRUNCATE: 8 mB

--b) Compare DELETE and TRUNCATE

	-- Execution time ): DELETE is slow because it checks every row against a condition.TRUNCATE is very fast.
	-- Disk space usage : DELETE does not free up disk space. TRUNCATE instantly frees up disk space, returning it to the operating system.
	-- Transaction behavior: DELETE — removes individual records without interfering with operations on the rest of the data.TRUNCATE — clears the entire table; consequently, the database temporarily locks it against other operations.
	-- Rollback possibility : DELETE — removes rows but leaves the possibility of restoring them.TRUNCATE — quickly clears the entire table, but also allows the operation to be undone via ROLLBACK.

--c) Explain:
	-- Why DELETE does not free space immediately: PostgreSQL does not remove rows from the disk immediately. It merely marks them as deleted.DELETE removes records from a table but does not necessarily reduce its physical size.
	-- Why VACUUM FULL changes table size: VACUUM FULL effectively creates a new, compact table, copies only the current records into it, and deletes the old table.
	-- Why TRUNCATE behaves differently: TRUNCATE does not delete each row individually. Instead, it clears the entire table at once, freeing up its old data pages.That is why TRUNCATE is much faster when you need to remove all records.
	-- How these operations affect performance and storage: If DELETE is used frequently, a table may occupy a large amount of space, even when few useful records remain in it.For completely clearing large tables, it is more convenient to use TRUNCATE.