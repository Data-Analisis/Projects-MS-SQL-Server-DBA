--�� srv.AutoDefragIndex � srv.AutoUpdateStatistics ��������, � � ��� �������� � ���� ������������ T-SQL, � ����������� ������������ �������� ���������
declare @str nvarchar(max);
declare @iscreated bit=0;

set @str=null;
if(not exists(select top(1) 1 from sys.schemas where [name]=N'inf'))
begin
	set @str='CREATE SCHEMA [inf];';
end

if(@str is not null)
begin
	exec sp_executesql @str;
end

if(not exists(select top(1) 1 from sys.schemas where [name]=N'srv'))
begin
	set @str='CREATE SCHEMA [srv];';
end

if(@str is not null)
begin
	exec sp_executesql @str;
end

set @str=null;
set @iscreated=0;
if(not exists(select top(1) 1 from sys.views where [name]=N'vTableSize' and [schema_id]=SCHEMA_ID(N'inf')))
begin
	set @iscreated=1;
	
	set @str='CREATE view [inf].[vTableSize] as
	with pagesizeKB as (
		SELECT low / 1024 as PageSizeKB
		FROM master.dbo.spt_values
		WHERE number = 1 AND type = ''E''
	)
	,f_size as (
		select p.[object_id], 
			   sum([total_pages]) as TotalPageSize,
			   sum([used_pages])  as UsedPageSize,
			   sum([data_pages])  as DataPageSize
		from sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id
		left join sys.internal_tables it on p.object_id = it.object_id
		WHERE OBJECTPROPERTY(p.[object_id], N''IsUserTable'') = 1
		group by p.[object_id]
	)
	,tbl as (
		SELECT
		  t.[schema_id],
		  t.[object_id],
		  i1.rowcnt as CountRows,
		  (COALESCE(SUM(i1.reserved), 0) + COALESCE(SUM(i2.reserved), 0)) * (select top(1) PageSizeKB from pagesizeKB) as ReservedKB,
		  (COALESCE(SUM(i1.dpages), 0) + COALESCE(SUM(i2.used), 0)) * (select top(1) PageSizeKB from pagesizeKB) as DataKB,
		  ((COALESCE(SUM(i1.used), 0) + COALESCE(SUM(i2.used), 0))
		    - (COALESCE(SUM(i1.dpages), 0) + COALESCE(SUM(i2.used), 0))) * (select top(1) PageSizeKB from pagesizeKB) as IndexSizeKB,
		  ((COALESCE(SUM(i1.reserved), 0) + COALESCE(SUM(i2.reserved), 0))
		    - (COALESCE(SUM(i1.used), 0) + COALESCE(SUM(i2.used), 0))) * (select top(1) PageSizeKB from pagesizeKB) as UnusedKB
		FROM sys.tables as t
		LEFT OUTER JOIN sysindexes as i1 ON i1.id = t.[object_id] AND i1.indid < 2
		LEFT OUTER JOIN sysindexes as i2 ON i2.id = t.[object_id] AND i2.indid = 255
		WHERE OBJECTPROPERTY(t.[object_id], N''IsUserTable'') = 1
		OR (OBJECTPROPERTY(t.[object_id], N''IsView'') = 1 AND OBJECTPROPERTY(t.[object_id], N''IsIndexed'') = 1)
		GROUP BY t.[schema_id], t.[object_id], i1.rowcnt
	)
	SELECT
	  @@Servername AS Server,
	  DB_NAME() AS DBName,
	  SCHEMA_NAME(t.[schema_id]) as SchemaName,
	  OBJECT_NAME(t.[object_id]) as TableName,
	  t.CountRows,
	  t.ReservedKB,
	  t.DataKB,
	  t.IndexSizeKB,
	  t.UnusedKB,
	  f.TotalPageSize*(select top(1) PageSizeKB from pagesizeKB) as TotalPageSizeKB,
	  f.UsedPageSize*(select top(1) PageSizeKB from pagesizeKB) as UsedPageSizeKB,
	  f.DataPageSize*(select top(1) PageSizeKB from pagesizeKB) as DataPageSizeKB
	FROM f_size as f
	inner join tbl as t on t.[object_id]=f.[object_id]';
end
else
begin
	set @str='ALTER view [inf].[vTableSize] as
	with pagesizeKB as (
		SELECT low / 1024 as PageSizeKB
		FROM master.dbo.spt_values
		WHERE number = 1 AND type = ''E''
	)
	,f_size as (
		select p.[object_id], 
			   sum([total_pages]) as TotalPageSize,
			   sum([used_pages])  as UsedPageSize,
			   sum([data_pages])  as DataPageSize
		from sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id
		left join sys.internal_tables it on p.object_id = it.object_id
		WHERE OBJECTPROPERTY(p.[object_id], N''IsUserTable'') = 1
		group by p.[object_id]
	)
	,tbl as (
		SELECT
		  t.[schema_id],
		  t.[object_id],
		  i1.rowcnt as CountRows,
		  (COALESCE(SUM(i1.reserved), 0) + COALESCE(SUM(i2.reserved), 0)) * (select top(1) PageSizeKB from pagesizeKB) as ReservedKB,
		  (COALESCE(SUM(i1.dpages), 0) + COALESCE(SUM(i2.used), 0)) * (select top(1) PageSizeKB from pagesizeKB) as DataKB,
		  ((COALESCE(SUM(i1.used), 0) + COALESCE(SUM(i2.used), 0))
		    - (COALESCE(SUM(i1.dpages), 0) + COALESCE(SUM(i2.used), 0))) * (select top(1) PageSizeKB from pagesizeKB) as IndexSizeKB,
		  ((COALESCE(SUM(i1.reserved), 0) + COALESCE(SUM(i2.reserved), 0))
		    - (COALESCE(SUM(i1.used), 0) + COALESCE(SUM(i2.used), 0))) * (select top(1) PageSizeKB from pagesizeKB) as UnusedKB
		FROM sys.tables as t
		LEFT OUTER JOIN sysindexes as i1 ON i1.id = t.[object_id] AND i1.indid < 2
		LEFT OUTER JOIN sysindexes as i2 ON i2.id = t.[object_id] AND i2.indid = 255
		WHERE OBJECTPROPERTY(t.[object_id], N''IsUserTable'') = 1
		OR (OBJECTPROPERTY(t.[object_id], N''IsView'') = 1 AND OBJECTPROPERTY(t.[object_id], N''IsIndexed'') = 1)
		GROUP BY t.[schema_id], t.[object_id], i1.rowcnt
	)
	SELECT
	  @@Servername AS Server,
	  DB_NAME() AS DBName,
	  SCHEMA_NAME(t.[schema_id]) as SchemaName,
	  OBJECT_NAME(t.[object_id]) as TableName,
	  t.CountRows,
	  t.ReservedKB,
	  t.DataKB,
	  t.IndexSizeKB,
	  t.UnusedKB,
	  f.TotalPageSize*(select top(1) PageSizeKB from pagesizeKB) as TotalPageSizeKB,
	  f.UsedPageSize*(select top(1) PageSizeKB from pagesizeKB) as UsedPageSizeKB,
	  f.DataPageSize*(select top(1) PageSizeKB from pagesizeKB) as DataPageSizeKB
	FROM f_size as f
	inner join tbl as t on t.[object_id]=f.[object_id]';
end

if(@str is not null)
begin
	exec sp_executesql @str;

	if(@iscreated=1)
	begin
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������� ������' , @level0type=N'SCHEMA',@level0name=N'inf', @level1type=N'VIEW',@level1name=N'vTableSize';
	end
end

set @str=null;
set @iscreated=0;
if(not exists(select top(1) 1 from sys.views where [name]=N'vIndexDefrag' and [schema_id]=SCHEMA_ID(N'inf')))
begin
	set @iscreated=1;

	set @str='CREATE view [inf].[vIndexDefrag]
	as
	with info as 
	(SELECT
		ps.[object_id],
		ps.database_id,
		ps.index_id,
		ps.index_type_desc,
		ps.index_level,
		ps.fragment_count,
		ps.avg_fragmentation_in_percent,
		ps.avg_fragment_size_in_pages,
		ps.page_count,
		ps.record_count,
		ps.ghost_record_count
		FROM sys.dm_db_index_physical_stats
	    (DB_ID()
		, NULL, NULL, NULL ,
		N''LIMITED'') as ps
		inner join sys.indexes as i on i.[object_id]=ps.[object_id] and i.[index_id]=ps.[index_id]
		where ps.index_level = 0
		and ps.avg_fragmentation_in_percent >= 10
		and ps.index_type_desc <> ''HEAP''
		and ps.page_count>=8 --1 �������
		and i.is_disabled=0
		)
	SELECT
		DB_NAME(i.database_id) as db,
		SCHEMA_NAME(t.[schema_id]) as shema,
		t.name as tb,
		i.index_id as idx,
		i.database_id,
		(select top(1) idx.[name] from [sys].[indexes] as idx where t.[object_id] = idx.[object_id] and idx.[index_id] = i.[index_id]) as index_name,
		i.index_type_desc,i.index_level as [level],
		i.[object_id],
		i.fragment_count as frag_num,
		round(i.avg_fragmentation_in_percent,2) as frag,
		round(i.avg_fragment_size_in_pages,2) as frag_page,
		i.page_count as [page],
		i.record_count as rec,
		i.ghost_record_count as ghost,
		round(i.avg_fragmentation_in_percent*i.page_count,0) as func
	FROM info as i
	inner join [sys].[all_objects]	as t	on i.[object_id] = t.[object_id]';
end
else
begin
	set @str='ALTER view [inf].[vIndexDefrag]
	as
	with info as 
	(SELECT
		ps.[object_id],
		ps.database_id,
		ps.index_id,
		ps.index_type_desc,
		ps.index_level,
		ps.fragment_count,
		ps.avg_fragmentation_in_percent,
		ps.avg_fragment_size_in_pages,
		ps.page_count,
		ps.record_count,
		ps.ghost_record_count
		FROM sys.dm_db_index_physical_stats
	    (DB_ID()
		, NULL, NULL, NULL ,
		N''LIMITED'') as ps
		inner join sys.indexes as i on i.[object_id]=ps.[object_id] and i.[index_id]=ps.[index_id]
		where ps.index_level = 0
		and ps.avg_fragmentation_in_percent >= 10
		and ps.index_type_desc <> ''HEAP''
		and ps.page_count>=8 --1 �������
		and i.is_disabled=0
		)
	SELECT
		DB_NAME(i.database_id) as db,
		SCHEMA_NAME(t.[schema_id]) as shema,
		t.name as tb,
		i.index_id as idx,
		i.database_id,
		(select top(1) idx.[name] from [sys].[indexes] as idx where t.[object_id] = idx.[object_id] and idx.[index_id] = i.[index_id]) as index_name,
		i.index_type_desc,i.index_level as [level],
		i.[object_id],
		i.fragment_count as frag_num,
		round(i.avg_fragmentation_in_percent,2) as frag,
		round(i.avg_fragment_size_in_pages,2) as frag_page,
		i.page_count as [page],
		i.record_count as rec,
		i.ghost_record_count as ghost,
		round(i.avg_fragmentation_in_percent*i.page_count,0) as func
	FROM info as i
	inner join [sys].[all_objects]	as t	on i.[object_id] = t.[object_id];';
end

if(@str is not null)
begin
	exec sp_executesql @str;

	if(@iscreated=1)
	begin
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������� ������������ ��� ��������, ������ ������� �� ����� 1 �������� (8 �������) � ������������ ������� ����� 10% (��������� ����� �����) � ������ ��� ������-�� ��� (� � ��������� ���������� ������). ������� � ������ ������ �������� �������' , @level0type=N'SCHEMA',@level0name=N'inf', @level1type=N'VIEW',@level1name=N'vIndexDefrag';
	end
end

set @str=null;
set @iscreated=0;
if(not exists(select top(1) 1 from sys.views where [name]=N'vCountRows' and [schema_id]=SCHEMA_ID(N'inf')))
begin
	set @iscreated=1;

	set @str='CREATE view [inf].[vCountRows] as
-- ����� ��������� ���������� ������� � �������������� DMV dm_db_partition_stats 
SELECT  @@ServerName AS ServerName ,
        DB_NAME() AS DBName ,
        OBJECT_SCHEMA_NAME(ddps.object_id) AS SchemaName ,
        OBJECT_NAME(ddps.object_id) AS TableName ,
        i.Type_Desc ,
        i.Name AS IndexUsedForCounts ,
        SUM(ddps.row_count) AS Rows
FROM    sys.dm_db_partition_stats ddps
        JOIN sys.indexes i ON i.object_id = ddps.object_id
                              AND i.index_id = ddps.index_id
WHERE   i.type_desc IN ( ''CLUSTERED'', ''HEAP'' )
                              -- This is key (1 index per table) 
        AND OBJECT_SCHEMA_NAME(ddps.object_id) <> ''sys''
GROUP BY ddps.object_id ,
        i.type_desc ,
        i.Name
--ORDER BY SchemaName ,
--        TableName;';
end
else
begin
	set @str='ALTER view [inf].[vCountRows] as
-- ����� ��������� ���������� ������� � �������������� DMV dm_db_partition_stats 
SELECT  @@ServerName AS ServerName ,
        DB_NAME() AS DBName ,
        OBJECT_SCHEMA_NAME(ddps.object_id) AS SchemaName ,
        OBJECT_NAME(ddps.object_id) AS TableName ,
        i.Type_Desc ,
        i.Name AS IndexUsedForCounts ,
        SUM(ddps.row_count) AS Rows
FROM    sys.dm_db_partition_stats ddps
        JOIN sys.indexes i ON i.object_id = ddps.object_id
                              AND i.index_id = ddps.index_id
WHERE   i.type_desc IN ( ''CLUSTERED'', ''HEAP'' )
                              -- This is key (1 index per table) 
        AND OBJECT_SCHEMA_NAME(ddps.object_id) <> ''sys''
GROUP BY ddps.object_id ,
        i.type_desc ,
        i.Name
--ORDER BY SchemaName ,
--        TableName;';
end

if(@str is not null)
begin
	exec sp_executesql @str;

	if(@iscreated=1)
	begin
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����� ��������� ���������� ������� � �������������� DMV dm_db_partition_stats' , @level0type=N'SCHEMA',@level0name=N'inf', @level1type=N'VIEW',@level1name=N'vCountRows';
	end
end