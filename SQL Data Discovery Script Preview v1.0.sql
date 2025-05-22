
--------------------------------------------------------------------------------------

Declare @SearchTerm varchar(max)    set @SearchTerm    = ''             --Term or Number to search for
Declare @ShowRows varchar(1)        set @ShowRows      = 'Y'            --Keep as 'Y' unless you want one table with each query with matching data

Declare @DataType varchar(10)       set @DataType      = 'ALL'          --Varchar, Number or ALL							    				   
Declare @Schema varchar(max)        set @Schema        = 'ALL'          --'ALL' if all schemas
Declare @Table varchar(max)         set @Table         = 'ALL'          --'ALL' if all Tables
Declare @Column varchar(max)        set @Column        = 'ALL'          --'ALL' if all Columns
													     
Declare @ExactMatch varchar(1)      set @ExactMatch    = 'N'            --Excludes partial matches
													   
Declare @SearchViews varchar(1)     set @SearchViews   = 'N'            --To search both BASE TABLES and VIEWS
Declare @UseAllDBs varchar(1)       set @UseAllDBs     = 'N'            --If 'N', specify the DBs Below 

IF OBJECT_ID('tempdb..#Databases_to_Search') IS NOT NULL
BEGIN
    DROP TABLE #Databases_to_Search
END 
select [name] into #Databases_to_Search from sys.databases where [name] in ('') --SPECIFY DATABASES TO SEARCH HERE

/*
--------------------------------------------------------------------------------------
FULL VERSION INCLUDES:

Declare @RowLimit varchar(max)      set @RowLimit      = '5'            --Number of rows returned per table when @ShowRows = 'Y'

Declare @Criteria varchar(max)      set @Criteria      = 'ALL'          --Column to act as criteria for the search
Declare @CriteriaValue varchar(max) set @CriteriaValue = 'ALL'          --Value for the criteria column specified
Declare @CrDateColumn varchar(max)  set @CrDateColumn  = 'ALL'          --Date Column to act as criteria for the search
Declare @CrDateValue varchar(max)   set @CrDateValue   = 'ALL'          --Date format '2020-01-15'

Declare @ExactTable varchar(1)      set @ExactTable    = 'N'            --If unwanted tables are coming up
Declare @ExactColumn varchar(1)     set @ExactColumn   = 'N'			--If unwanted columns are coming up

--------------------------------------------------------------------------------------

© 2025 BRB. All rights reserved.

--------------------------------------------------------------------------------------

select * from #DatabasesChecked
select * from #TablesChecked
select * from #ColumnsChecked

--------------------------------------------------------------------------------------
*/

--Declare Variables
Declare @DatabaseName nvarchar(max)
Declare @TableName nvarchar(max)
Declare @ColumnName nvarchar(max)
Declare @DataFinder nvarchar(max)
Declare @RowCheck int
Declare @TABLESQL nvarchar(max)
Declare @COLUMNSQL nvarchar(max)
Declare @FILTERTABLES nvarchar(max)
Declare @SchemaSQL nvarchar(max)
declare @FilterColumn nvarchar(max)
declare @FilterTableName nvarchar(max)
declare @FoundData int set @FoundData = 0
declare @DatabasesChecked int set @DatabasesChecked = 0
declare @TablesChecked int set @TablesChecked = 0
declare @ColumnsChecked int set @ColumnsChecked = 0


--Make sure Cursors are closed and temp tables are dropped
IF CURSOR_STATUS('global', 'DatabaseCursor') >= 0
BEGIN
    CLOSE DatabaseCursor
    DEALLOCATE DatabaseCursor
END

IF CURSOR_STATUS('global', 'TableCursor') >= 0
BEGIN
    CLOSE TableCursor
    DEALLOCATE TableCursor
END

IF CURSOR_STATUS('global', 'ColumnCursor') >= 0
BEGIN
    CLOSE ColumnCursor
    DEALLOCATE ColumnCursor
END

IF OBJECT_ID('tempdb..#DatabasesChecked') IS NOT NULL
BEGIN
    DROP TABLE #DatabasesChecked
END
create table #DatabasesChecked(
[Database] varchar(max))

IF OBJECT_ID('tempdb..#TablesChecked') IS NOT NULL
BEGIN
    DROP TABLE #TablesChecked
END
create table #TablesChecked(
[Database] varchar(max),
[Table] varchar(max))

IF OBJECT_ID('tempdb..#ColumnsChecked') IS NOT NULL
BEGIN
    DROP TABLE #ColumnsChecked
END
create table #ColumnsChecked(
[Database] varchar(max),
[Table] varchar(max),
[Column] varchar(max))


IF OBJECT_ID('tempdb..#FinalDBTable') IS NOT NULL
BEGIN
    DROP TABLE #FinalDBTable
END

--Create table for the database cursor
create table #FinalDBTable(
[name] varchar(max))

IF @UseAllDBs = 'Y'
BEGIN
	insert into #FinalDBTable
	select [name] from sys.databases where [name] not in ('master' ,'tempdb' ,'model' ,'msdb')
END

IF @UseAllDBs = 'N'
BEGIN
	insert into #FinalDBTable
	select [name] from sys.databases where [name] in (select * from #Databases_to_Search) and [name] not in ('master' ,'tempdb' ,'model' ,'msdb')
END


--Create table for datatypes
IF OBJECT_ID('tempdb..#DataTypes') IS NOT NULL
BEGIN
    DROP TABLE #DataTypes
END

create table #DataTypes(
DATA_TYPE varchar(max))

if @DataType = 'Varchar'
BEGIN
	insert into #DataTypes select 'char'
	insert into #DataTypes select 'varchar'
	insert into #DataTypes select 'text'
	insert into #DataTypes select 'nchar'
	insert into #DataTypes select 'nvarchar'
	insert into #DataTypes select 'ntext'
	insert into #DataTypes select 'uniqueidentifier'
END

if @DataType = 'Number'
BEGIN
	insert into #DataTypes select 'int'
	insert into #DataTypes select 'tinyint'
	insert into #DataTypes select 'smallint'
	insert into #DataTypes select 'bigint'
	insert into #DataTypes select 'bit'
	insert into #DataTypes select 'decimal'
	insert into #DataTypes select 'numeric'
	insert into #DataTypes select 'money'
	insert into #DataTypes select 'smallmoney'
	insert into #DataTypes select 'float'
	insert into #DataTypes select 'real'
END

--if @DataType = 'Date'
--BEGIN
--	insert into #DataTypes select 'date'
--	insert into #DataTypes select 'time'
--	insert into #DataTypes select 'datetime2'
--	insert into #DataTypes select 'datetimeoffset'
--	insert into #DataTypes select 'datetime'
--	insert into #DataTypes select 'smalldatetime'
--END

if @DataType = 'ALL'
BEGIN
	--insert into #DataTypes select 'date'
	--insert into #DataTypes select 'time'
	--insert into #DataTypes select 'datetime2'
	--insert into #DataTypes select 'datetimeoffset'
	--insert into #DataTypes select 'datetime'
	--insert into #DataTypes select 'smalldatetime'
	insert into #DataTypes select 'int'
	insert into #DataTypes select 'tinyint'
	insert into #DataTypes select 'smallint'
	insert into #DataTypes select 'bigint'
	insert into #DataTypes select 'bit'
	insert into #DataTypes select 'decimal'
	insert into #DataTypes select 'numeric'
	insert into #DataTypes select 'money'
	insert into #DataTypes select 'smallmoney'
	insert into #DataTypes select 'float'
	insert into #DataTypes select 'real'
	insert into #DataTypes select 'char'
	insert into #DataTypes select 'varchar'
	insert into #DataTypes select 'text'
	insert into #DataTypes select 'nchar'
	insert into #DataTypes select 'nvarchar'
	insert into #DataTypes select 'ntext'
	insert into #DataTypes select 'uniqueidentifier'
END

--Edit Datatypes
if @ExactMatch = 'Y' and @SearchTerm like '%.%'
BEGIN
	delete a 
	--select *
	from #DataTypes a
	where DATA_TYPE in ('bit', 'int', 'tinyint', 'smallint', 'bigint', 'date', 'time', 'datetime2', 'datetimeoffset', 'datetime', 'smalldatetime', 'uniqueidentifier', 'text')
END

if @ExactMatch = 'Y' and len(@SearchTerm)>3 
BEGIN
	delete a 
	--select *
	from #DataTypes a
	where DATA_TYPE in ('bit', 'tinyint', 'smallint')
END

if @ExactMatch = 'Y' 
BEGIN
	delete a 
	--select *
	from #DataTypes a
	where DATA_TYPE in ('bit', 'date', 'time', 'datetime2', 'datetimeoffset', 'datetime', 'smalldatetime', 'decimal', 'uniqueidentifier')
END

--select * from #DataTypes


--Create final table for cursor
IF OBJECT_ID('tempdb..#DatabaseTableColumn') IS NOT NULL
BEGIN
    DROP TABLE #DatabaseTableColumn
END

create table #DatabaseTableColumn(
[Database] varchar(max),
[Table] varchar(max),
[Column] varchar(max),
[Query] varchar(max))

insert into #DatabasesChecked
Select [name] from sys.databases where [name] in (select * from #FinalDBTable)

Declare DatabaseCursor cursor for
Select [name] from sys.databases 
where [name] in (select * from #FinalDBTable)

Open DatabaseCursor 

Fetch next from DatabaseCursor into @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN
	IF HAS_DBACCESS(@DatabaseName) = 1
	BEGIN

	--Create Schema Table
	IF OBJECT_ID('tempdb..#Schemas') IS NOT NULL
	BEGIN
	    DROP TABLE #Schemas
	END

	create table #Schemas(
	UseSchema varchar(max))

	IF @Schema = 'ALL'
	BEGIN
		set @SchemaSQL = 'SELECT DISTINCT TABLE_SCHEMA FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.TABLES'

		insert into #Schemas
		EXEC sp_executesql @SchemaSQL
	END

	IF @Schema <> 'ALL'
	BEGIN
		set @SchemaSQL = 'SELECT DISTINCT TABLE_SCHEMA FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA IN (''' + @Schema + ''')'

		insert into #Schemas
		EXEC sp_executesql @SchemaSQL
	END
		

	--select * from #Schemas


	--Create Column Table
	IF OBJECT_ID('tempdb..#FilteredColumns') IS NOT NULL
	BEGIN
	    DROP TABLE #FilteredColumns
	END

	create table #FilteredColumns(
	UseTable varchar(max),
	UseColumn varchar(max))

	IF @Column = 'All'
	BEGIN
		set @FilterColumn = 'SELECT DISTINCT concat(''['', TABLE_SCHEMA COLLATE SQL_Latin1_General_CP1_CI_AS, ''].['', TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS, '']''), COLUMN_NAME FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.COLUMNS WHERE DATA_TYPE COLLATE SQL_Latin1_General_CP1_CI_AS in (select DATA_TYPE COLLATE SQL_Latin1_General_CP1_CI_AS from #DataTypes)'
		--select @FilterColumn
		insert into #FilteredColumns
		EXEC sp_executesql @FilterColumn
	END

	IF @Column <> 'All'
	BEGIN
		set @FilterColumn = 'SELECT DISTINCT concat(''['', TABLE_SCHEMA COLLATE SQL_Latin1_General_CP1_CI_AS, ''].['', TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS, '']''), COLUMN_NAME FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE (''%' + @Column + '%'') AND DATA_TYPE COLLATE SQL_Latin1_General_CP1_CI_AS in (select DATA_TYPE COLLATE SQL_Latin1_General_CP1_CI_AS from #DataTypes)'

		insert into #FilteredColumns
		EXEC sp_executesql @FilterColumn
	END
	--select * from #FilteredColumns


	--Create Table Name Table
	IF OBJECT_ID('tempdb..#FilteredTableName') IS NOT NULL
	BEGIN
	    DROP TABLE #FilteredTableName
	END

	create table #FilteredTableName(
	UseTable varchar(max),
	UseColumn varchar(max))
	
	IF @Table = 'ALL'
	BEGIN
		set @FilterTableName = 'SELECT DISTINCT concat(''['', TABLE_SCHEMA COLLATE SQL_Latin1_General_CP1_CI_AS, ''].['', TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS, '']''), TABLE_NAME FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.COLUMNS'
		--select @FilterTableName
		insert into #FilteredTableName
		EXEC sp_executesql @FilterTableName
	END

	IF @Table <> 'ALL'
	BEGIN
		set @FilterTableName = 'SELECT DISTINCT concat(''['', TABLE_SCHEMA COLLATE SQL_Latin1_General_CP1_CI_AS, ''].['', TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS, '']''), TABLE_NAME FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE (''%' + @Table + '%'')'

		insert into #FilteredTableName
		EXEC sp_executesql @FilterTableName
	END

	--select * from #FilteredTableName

	IF @SearchViews = 'Y'
	BEGIN
		set @TABLESQL = 'SELECT concat(''['', TABLE_SCHEMA COLLATE SQL_Latin1_General_CP1_CI_AS, ''].['', TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS, '']'') FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA COLLATE SQL_Latin1_General_CP1_CI_AS IN (select UseSchema COLLATE SQL_Latin1_General_CP1_CI_AS from #Schemas)'
	END
	IF @SearchViews = 'N'
	BEGIN
		set @TABLESQL = 'SELECT concat(''['', TABLE_SCHEMA COLLATE SQL_Latin1_General_CP1_CI_AS, ''].['', TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS, '']'') FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.TABLES where TABLE_TYPE = ''BASE TABLE'' and TABLE_SCHEMA COLLATE SQL_Latin1_General_CP1_CI_AS IN (select UseSchema COLLATE SQL_Latin1_General_CP1_CI_AS from #Schemas)'
	END
	--select @TABLESQL


	--Grab all tables in Database
	IF OBJECT_ID('tempdb..#DatabaseTables') IS NOT NULL
	BEGIN
	    DROP TABLE #DatabaseTables
	END

	create table #DatabaseTables(
	SchemaTable varchar(max))

	insert into #DatabaseTables
	EXEC sp_executesql @TABLESQL
	
	--select * from #DatabaseTables

	set @FILTERTABLES = 'SELECT distinct * FROM #DatabaseTables where SchemaTable in (select concat(''['', TABLE_SCHEMA COLLATE SQL_Latin1_General_CP1_CI_AS, ''].['', TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS, '']'') from [' + @DatabaseName + '].INFORMATION_SCHEMA.COLUMNS where DATA_TYPE COLLATE SQL_Latin1_General_CP1_CI_AS in (select DATA_TYPE COLLATE SQL_Latin1_General_CP1_CI_AS from #DataTypes))'

	--select @FILTERTABLES

	--Filter out tables based on Criteria
	IF OBJECT_ID('tempdb..#FilteredTables') IS NOT NULL
	BEGIN
	    DROP TABLE #FilteredTables
	END

	create table #FilteredTables (
	SchemaTable varchar(max))

	insert into #FilteredTables
	EXEC sp_executesql @FILTERTABLES


	--select @DatabaseName
	--select * from #FilteredTables
	IF @Column <> 'ALL'
	BEGIN
		delete 
		--select *
		from #FilteredTables where SchemaTable not in (select Usetable from #FilteredColumns)
	END

	IF @Table <> 'ALL'
	BEGIN
		delete 
		--select *
		from #FilteredTables where SchemaTable not in (select Usetable from #FilteredTableName)
	END
	--select * from #FilteredTables

	--Create Table Cursor
	insert into #TablesChecked
	select @DatabaseName, SchemaTable from #FilteredTables

	Declare TableCursor cursor for
	select * from #FilteredTables


	Open TableCursor

	Fetch next from TableCursor into @TableName


	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Find Columns to Search
		IF @Column <> 'ALL'	
		BEGIN
			set @COLUMNSQL = 'SELECT COLUMN_NAME FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.COLUMNS where concat(''['', TABLE_SCHEMA COLLATE SQL_Latin1_General_CP1_CI_AS, ''].['', TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS, '']'') = ''' + @TableName + ''' AND DATA_TYPE COLLATE SQL_Latin1_General_CP1_CI_AS in (select DATA_TYPE COLLATE SQL_Latin1_General_CP1_CI_AS from #DataTypes) and COLUMN_NAME like (''%' + @Column + '%'')'
		END

		IF @Column = 'ALL'
		BEGIN
			set @COLUMNSQL = 'SELECT COLUMN_NAME FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.COLUMNS where concat(''['', TABLE_SCHEMA COLLATE SQL_Latin1_General_CP1_CI_AS, ''].['', TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS, '']'') = ''' + @TableName + ''' AND DATA_TYPE COLLATE SQL_Latin1_General_CP1_CI_AS in (select DATA_TYPE COLLATE SQL_Latin1_General_CP1_CI_AS from #DataTypes)'
			--select @COLUMNSQL
		END

		--select @COLUMNSQL
		IF OBJECT_ID('tempdb..#Columns') IS NOT NULL
		BEGIN
		    DROP TABLE #Columns
		END

		create table #Columns(
		COLUMN_NAME varchar(max))

		insert into #Columns
		EXEC sp_executesql @COLUMNSQL

		insert into #ColumnsChecked
		select @DatabaseName, @TableName, COLUMN_NAME from #Columns
    
		Declare ColumnCursor cursor for    --This cycles through the columns in the current table in @Tablename
		Select COLUMN_NAME from #Columns

		Open ColumnCursor

		Fetch next from ColumnCursor into @ColumnName

		WHILE @@FETCH_STATUS = 0
		BEGIN
			Set @RowCheck = 0
			--Select 'TABLE: ' + @TableName + '    COLUMN: ' + QUOTENAME(@ColumnName) 
			IF @ExactMatch = 'N'
			BEGIN
				SET @DataFinder = 'SELECT TOP 1 @RowCheck = 1 FROM [' + @DatabaseName + '].' +  @TableName + ' WHERE [' + @ColumnName + '] LIKE ''%' + REPLACE(@SearchTerm, '''', '''''') + '%'''

				--select @DataFinder
				EXEC sp_executesql @Datafinder, N'@RowCheck INT OUTPUT', @RowCheck OUTPUT
				--Select @DatabaseName as [Database], @TableName as [Table], @ColumnName as [Column]
				IF @RowCheck > 0
				BEGIN
					set @FoundData = @FoundData + 1
					--Select 'TABLE: ' + QUOTENAME(@TableName) + '    COLUMN: ' + QUOTENAME(@ColumnName)
					IF @ShowRows = 'Y'
					BEGIN
						Select @DatabaseName as [Database], @TableName as [Table], @ColumnName as [Column], concat('SELECT * FROM [', @DatabaseName, '].', @TableName, ' WHERE [', @ColumnName, '] like ''%', @SearchTerm, '%''') as 'Query'
						Set @DataFinder = 'SELECT TOP 5 * FROM [' + @DatabaseName + '].' + @TableName + ' WHERE [' + @ColumnName + '] LIKE ''%' + REPLACE(@SearchTerm, '''', '''''') + '%'''
						EXEC sp_executesql @Datafinder
					END
					IF @ShowRows = 'N'
					BEGIN
						insert into #DatabaseTableColumn
						Select @DatabaseName as [Database], @TableName as [Table], @ColumnName as [Column], concat('SELECT * FROM [', @DatabaseName, '].', @TableName, ' WHERE [', @ColumnName, '] like ''%', @SearchTerm, '%''') as 'Query'
					END
				END
			END

			IF @ExactMatch = 'Y'
			BEGIN
				SET @DataFinder = 'SELECT TOP 1 @RowCheck = 1 FROM [' + @DatabaseName + '].' +  @TableName + ' WHERE [' + @ColumnName + '] = ''' + REPLACE(@SearchTerm, '''', '''''') + ''''		
				--select @DataFinder
				EXEC sp_executesql @Datafinder, N'@RowCheck INT OUTPUT', @RowCheck OUTPUT
				--Select @DatabaseName as [Database], @TableName as [Table], @ColumnName as [Column]
				IF @RowCheck > 0
				BEGIN
					set @FoundData = @FoundData + 1
					--Select 'TABLE: ' + QUOTENAME(@TableName) + '    COLUMN: ' + QUOTENAME(@ColumnName)
					IF @ShowRows = 'Y'
					BEGIN
						Select @DatabaseName as [Database], @TableName as [Table], @ColumnName as [Column], concat('SELECT * FROM [', @DatabaseName, '].', @TableName, ' WHERE [', @ColumnName, '] = ''', @SearchTerm, '''') as 'Query'
						Set @DataFinder = 'SELECT TOP 5 * FROM [' + @DatabaseName + '].' + @TableName + ' WHERE [' + @ColumnName + '] = ''' + REPLACE(@SearchTerm, '''', '''''') + ''''
						EXEC sp_executesql @Datafinder
					END
					IF @ShowRows = 'N'
					BEGIN
						insert into #DatabaseTableColumn
						Select @DatabaseName as [Database], @TableName as [Table], @ColumnName as [Column], concat('SELECT * FROM [', @DatabaseName, '].', @TableName, ' WHERE [', @ColumnName, '] = ''', @SearchTerm, '''') as 'Query'
					END
				END
			END
			set @ColumnsChecked = @ColumnsChecked + 1
			Fetch next from ColumnCursor INTO @ColumnName
		END

		Close ColumnCursor
		Deallocate ColumnCursor

		set @TablesChecked = @TablesChecked + 1
		Fetch next from TableCursor into @TableName
	END

	Close TableCursor
	Deallocate TableCursor

	END

	set @DatabasesChecked = @DatabasesChecked + 1
	Fetch next from DatabaseCursor into @DatabaseName

END

Close DatabaseCursor
Deallocate DatabaseCursor


if @ShowRows = 'N' and @FoundData > 0
BEGIN
	select * from #DatabaseTableColumn order by [Database], [Table], [Column]
END

if @FoundData = 0
BEGIN
	select 'No Data Found with this Criteria' as 'Result'
END

select @DatabasesChecked as 'Databases Checked', @TablesChecked as 'Tables Checked', @ColumnsChecked as 'Columns Checked', @FoundData as 'Columns With Matching Data'

