USE master
GO

IF OBJECT_ID('tempdb..#VLF') IS NOT NULL
BEGIN

	DROP TABLE #VLF;

END

IF OBJECT_ID('tempdb..#databases') IS NOT NULL
BEGIN

	DROP TABLE #databases;

END

CREATE TABLE #VLF 
	(
	ServerName sysname NULL DEFAULT @@servername,
	DBName sysname NULL DEFAULT DB_NAME(),
	RecoveryUnitID TINYINT,
	FileId int NOT NULL,
	FileSize bigint,
	StartOffset bigint,
	FSeqNo int,
	Status tinyint,
	Parity int,
	CreateLSN numeric(25,0) --,
--	CollectionDateTime datetime DEFAULT getdate()
	)

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'i1_VLF')
CREATE CLUSTERED INDEX i1_VLF ON #VLF (DBName)
GO

DECLARE @looplimit INT
DECLARE @loopcount INT
DECLARE @dbname SYSNAME
DECLARE @sqlstr VARCHAR(2000)

CREATE TABLE #databases
(rowid INT IDENTITY(1,1)
,[name] SYSNAME)

INSERT INTO #databases
SELECT name FROM sys.databases
WHERE state = 0

SET @looplimit = @@ROWCOUNT
SET @loopcount = 1

WHILE @loopcount <= @looplimit
	BEGIN
	
		SELECT @dbname = [name] FROM #databases WHERE rowid = @loopcount;
		
		SET @sqlstr = 'USE [' + @dbname +
		'] INSERT #VLF (RecoveryUnitID, FileId, FileSize, StartOffset, FSeqNo, Status, Parity, CreateLSN) 
		EXEC (''DBCC LOGINFO()'')'
		
		EXEC(@sqlstr)		
		
		--PRINT @sqlstr
		
		SET @loopcount = @loopcount + 1
		
	END

SELECT DBName, [Status], COUNT(*) AS [VLF Count]
FROM #VLF
GROUP BY DBName, [Status]
ORDER BY DBName, [Status] DESC	
	
		
