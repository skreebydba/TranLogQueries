USE master;

SELECT DB_NAME(database_id), 
CASE is_percent_growth
	WHEN 0 THEN (growth / 128)
	WHEN 1 THEN growth
END  AS [FileGrowth (mb)], 
CASE is_percent_growth
	WHEN 0 THEN N'Fixed'
	WHEN 1 THEN N'Percent'
END 
FROM sys.master_files
WHERE type_desc = 'LOG'
ORDER BY DB_NAME(database_id);