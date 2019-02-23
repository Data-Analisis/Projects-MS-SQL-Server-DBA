SET CONCAT_NULL_YIELDS_NULL, ANSI_NULLS, ANSI_PADDING, QUOTED_IDENTIFIER, ANSI_WARNINGS, ARITHABORT, XACT_ABORT ON
SET NUMERIC_ROUNDABORT, IMPLICIT_TRANSACTIONS OFF
GO

USE [SRV]
GO

IF DB_NAME() <> N'SRV' SET NOEXEC ON
GO


--
-- Set transaction isolation level
--
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO

--
-- Start Transaction
--
BEGIN TRANSACTION
GO

--
-- Update extended property [MS_Description] on view [srv].[vDelIndexInclude]
--
EXEC sys.sp_updateextendedproperty N'MS_Description', N'����� ���������������(������) ��������', 'SCHEMA', N'srv', 'VIEW', N'vDelIndexInclude'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Create view [inf].[vFunctionStat]
--
GO


CREATE view [inf].[vFunctionStat] as 
select DB_Name(coalesce(QS.[database_id], ST.[dbid], PT.[dbid])) as [DB_Name]
	  ,OBJECT_SCHEMA_NAME(coalesce(QS.[object_id], ST.[objectid], PT.[objectid]), coalesce(QS.[database_id], ST.[dbid], PT.[dbid])) as [Schema_Name]
	  ,object_name(coalesce(QS.[object_id], ST.[objectid], PT.[objectid]), coalesce(QS.[database_id], ST.[dbid], PT.[dbid])) as [Object_Name]
	  ,coalesce(QS.[database_id], ST.[dbid], PT.[dbid]) as [database_id]
	  ,SCHEMA_ID(OBJECT_SCHEMA_NAME(coalesce(QS.[object_id], ST.[objectid], PT.[objectid]), coalesce(QS.[database_id], ST.[dbid], PT.[dbid]))) as [schema_id]
      ,coalesce(QS.[object_id], ST.[objectid], PT.[objectid]) as [object_id]
      ,QS.[type]
      ,QS.[type_desc]
      ,QS.[sql_handle]
      ,QS.[plan_handle]
      ,QS.[cached_time]
      ,QS.[last_execution_time]
      ,QS.[execution_count]
      ,QS.[total_worker_time]
      ,QS.[last_worker_time]
      ,QS.[min_worker_time]
      ,QS.[max_worker_time]
      ,QS.[total_physical_reads]
      ,QS.[last_physical_reads]
      ,QS.[min_physical_reads]
      ,QS.[max_physical_reads]
      ,QS.[total_logical_writes]
      ,QS.[last_logical_writes]
      ,QS.[min_logical_writes]
      ,QS.[max_logical_writes]
      ,QS.[total_logical_reads]
      ,QS.[last_logical_reads]
      ,QS.[min_logical_reads]
      ,QS.[max_logical_reads]
      ,QS.[total_elapsed_time]
      ,QS.[last_elapsed_time]
      ,QS.[min_elapsed_time]
      ,QS.[max_elapsed_time]
	  ,ST.[encrypted]
	  ,ST.[text] as [TSQL]
	  ,PT.[query_plan]
FROM sys.dm_exec_function_stats AS QS
     CROSS APPLY sys.dm_exec_sql_text(QS.[sql_handle]) as ST
	 CROSS APPLY sys.dm_exec_query_plan(QS.[plan_handle]) as PT
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Add extended property [MS_Description] on view [inf].[vFunctionStat]
--
EXEC sys.sp_addextendedproperty N'MS_Description', N'���������� �� ��������', 'SCHEMA', N'inf', 'VIEW', N'vFunctionStat'
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter view [inf].[vRequestDetail]
--
GO





ALTER view [inf].[vRequestDetail] as
/*��������, ������� � ���������� � ��������� �������, � ����� ��, ��� ���� ��������� ������ ������*/
with tbl0 as (
	select ES.[session_id]
	      ,ER.[blocking_session_id]
		  ,ER.[request_id]
	      ,ER.[start_time]
	      ,ER.[status]
		  ,ES.[status] as [status_session]
	      ,ER.[command]
		  ,ER.[percent_complete]
		  ,DB_Name(coalesce(ER.[database_id], ES.[database_id])) as [DBName]
	      ,(select top(1) [text] from sys.dm_exec_sql_text(ER.[sql_handle])) as [TSQL]
		  ,(select top(1) [objectid] from sys.dm_exec_sql_text(ER.[sql_handle])) as [objectid]
		  ,(select top(1) [query_plan] from sys.dm_exec_query_plan(ER.[plan_handle])) as [QueryPlan]
		  ,(select top(1) [event_info] from sys.dm_exec_input_buffer(ES.[session_id], ER.[request_id])) as [event_info]
	      ,ER.[wait_type]
	      ,ES.[login_time]
		  ,ES.[host_name]
		  ,ES.[program_name]
	      ,ER.[wait_time]
	      ,ER.[last_wait_type]
	      ,ER.[wait_resource]
	      ,ER.[open_transaction_count]
	      ,ER.[open_resultset_count]
	      ,ER.[transaction_id]
	      ,ER.[context_info]
	      ,ER.[estimated_completion_time]
	      ,ER.[cpu_time]
	      ,ER.[total_elapsed_time]
	      ,ER.[scheduler_id]
	      ,ER.[task_address]
	      ,ER.[reads]
	      ,ER.[writes]
	      ,ER.[logical_reads]
	      ,ER.[text_size]
	      ,ER.[language]
	      ,ER.[date_format]
	      ,ER.[date_first]
	      ,ER.[quoted_identifier]
	      ,ER.[arithabort]
	      ,ER.[ansi_null_dflt_on]
	      ,ER.[ansi_defaults]
	      ,ER.[ansi_warnings]
	      ,ER.[ansi_padding]
	      ,ER.[ansi_nulls]
	      ,ER.[concat_null_yields_null]
	      ,ER.[transaction_isolation_level]
	      ,ER.[lock_timeout]
	      ,ER.[deadlock_priority]
	      ,ER.[row_count]
	      ,ER.[prev_error]
	      ,ER.[nest_level]
	      ,ER.[granted_query_memory]
	      ,ER.[executing_managed_code]
	      ,ER.[group_id]
	      ,ER.[query_hash]
	      ,ER.[query_plan_hash]
		  ,EC.[most_recent_session_id]
	      ,EC.[connect_time]
	      ,EC.[net_transport]
	      ,EC.[protocol_type]
	      ,EC.[protocol_version]
	      ,EC.[endpoint_id]
	      ,EC.[encrypt_option]
	      ,EC.[auth_scheme]
	      ,EC.[node_affinity]
	      ,EC.[num_reads]
	      ,EC.[num_writes]
	      ,EC.[last_read]
	      ,EC.[last_write]
	      ,EC.[net_packet_size]
	      ,EC.[client_net_address]
	      ,EC.[client_tcp_port]
	      ,EC.[local_net_address]
	      ,EC.[local_tcp_port]
	      ,EC.[parent_connection_id]
	      ,EC.[most_recent_sql_handle]
		  ,ES.[host_process_id]
		  ,ES.[client_version]
		  ,ES.[client_interface_name]
		  ,ES.[security_id]
		  ,ES.[login_name]
		  ,ES.[nt_domain]
		  ,ES.[nt_user_name]
		  ,ES.[memory_usage]
		  ,ES.[total_scheduled_time]
		  ,ES.[last_request_start_time]
		  ,ES.[last_request_end_time]
		  ,ES.[is_user_process]
		  ,ES.[original_security_id]
		  ,ES.[original_login_name]
		  ,ES.[last_successful_logon]
		  ,ES.[last_unsuccessful_logon]
		  ,ES.[unsuccessful_logons]
		  ,ES.[authenticating_database_id]
		  ,ER.[sql_handle]
	      ,ER.[statement_start_offset]
	      ,ER.[statement_end_offset]
	      ,ER.[plan_handle]
		  ,ER.[dop]
	      ,coalesce(ER.[database_id], ES.[database_id]) as [database_id]
	      ,ER.[user_id]
	      ,ER.[connection_id]
	from sys.dm_exec_requests ER with(readuncommitted)
	right join sys.dm_exec_sessions ES with(readuncommitted)
	on ES.session_id = ER.session_id 
	left join sys.dm_exec_connections EC  with(readuncommitted)
	on EC.session_id = ES.session_id
)
, tbl as (
	select [session_id]
	      ,[blocking_session_id]
		  ,[request_id]
	      ,[start_time]
	      ,[status]
		  ,[status_session]
	      ,[command]
		  ,[percent_complete]
		  ,[DBName]
		  ,OBJECT_name([objectid], [database_id]) as [object]
	      ,[TSQL]
		  ,[QueryPlan]
		  ,[event_info]
	      ,[wait_type]
	      ,[login_time]
		  ,[host_name]
		  ,[program_name]
	      ,[wait_time]
	      ,[last_wait_type]
	      ,[wait_resource]
	      ,[open_transaction_count]
	      ,[open_resultset_count]
	      ,[transaction_id]
	      ,[context_info]
	      ,[estimated_completion_time]
	      ,[cpu_time]
	      ,[total_elapsed_time]
	      ,[scheduler_id]
	      ,[task_address]
	      ,[reads]
	      ,[writes]
	      ,[logical_reads]
	      ,[text_size]
	      ,[language]
	      ,[date_format]
	      ,[date_first]
	      ,[quoted_identifier]
	      ,[arithabort]
	      ,[ansi_null_dflt_on]
	      ,[ansi_defaults]
	      ,[ansi_warnings]
	      ,[ansi_padding]
	      ,[ansi_nulls]
	      ,[concat_null_yields_null]
	      ,[transaction_isolation_level]
	      ,[lock_timeout]
	      ,[deadlock_priority]
	      ,[row_count]
	      ,[prev_error]
	      ,[nest_level]
	      ,[granted_query_memory]
	      ,[executing_managed_code]
	      ,[group_id]
	      ,[query_hash]
	      ,[query_plan_hash]
		  ,[most_recent_session_id]
	      ,[connect_time]
	      ,[net_transport]
	      ,[protocol_type]
	      ,[protocol_version]
	      ,[endpoint_id]
	      ,[encrypt_option]
	      ,[auth_scheme]
	      ,[node_affinity]
	      ,[num_reads]
	      ,[num_writes]
	      ,[last_read]
	      ,[last_write]
	      ,[net_packet_size]
	      ,[client_net_address]
	      ,[client_tcp_port]
	      ,[local_net_address]
	      ,[local_tcp_port]
	      ,[parent_connection_id]
	      ,[most_recent_sql_handle]
		  ,[host_process_id]
		  ,[client_version]
		  ,[client_interface_name]
		  ,[security_id]
		  ,[login_name]
		  ,[nt_domain]
		  ,[nt_user_name]
		  ,[memory_usage]
		  ,[total_scheduled_time]
		  ,[last_request_start_time]
		  ,[last_request_end_time]
		  ,[is_user_process]
		  ,[original_security_id]
		  ,[original_login_name]
		  ,[last_successful_logon]
		  ,[last_unsuccessful_logon]
		  ,[unsuccessful_logons]
		  ,[authenticating_database_id]
		  ,[sql_handle]
	      ,[statement_start_offset]
	      ,[statement_end_offset]
	      ,[plan_handle]
		  ,[dop]
	      ,[database_id]
	      ,[user_id]
	      ,[connection_id]
	from tbl0
	where [status] in ('suspended', 'running', 'runnable')
)
, tbl_group as (
	select [blocking_session_id]
	from tbl
	where [blocking_session_id]<>0
	group by [blocking_session_id]
)
, tbl_res_rec as (
	select [session_id]
	      ,[blocking_session_id]
		  ,[request_id]
	      ,[start_time]
	      ,[status]
		  ,[status_session]
	      ,[command]
		  ,[percent_complete]
		  ,[DBName]
		  ,[object]
	      ,[TSQL]
		  ,[QueryPlan]
		  ,[event_info]
	      ,[wait_type]
	      ,[login_time]
		  ,[host_name]
		  ,[program_name]
	      ,[wait_time]
	      ,[last_wait_type]
	      ,[wait_resource]
	      ,[open_transaction_count]
	      ,[open_resultset_count]
	      ,[transaction_id]
	      ,[context_info]
	      ,[estimated_completion_time]
	      ,[cpu_time]
	      ,[total_elapsed_time]
	      ,[scheduler_id]
	      ,[task_address]
	      ,[reads]
	      ,[writes]
	      ,[logical_reads]
	      ,[text_size]
	      ,[language]
	      ,[date_format]
	      ,[date_first]
	      ,[quoted_identifier]
	      ,[arithabort]
	      ,[ansi_null_dflt_on]
	      ,[ansi_defaults]
	      ,[ansi_warnings]
	      ,[ansi_padding]
	      ,[ansi_nulls]
	      ,[concat_null_yields_null]
	      ,[transaction_isolation_level]
	      ,[lock_timeout]
	      ,[deadlock_priority]
	      ,[row_count]
	      ,[prev_error]
	      ,[nest_level]
	      ,[granted_query_memory]
	      ,[executing_managed_code]
	      ,[group_id]
	      ,[query_hash]
	      ,[query_plan_hash]
		  ,[most_recent_session_id]
	      ,[connect_time]
	      ,[net_transport]
	      ,[protocol_type]
	      ,[protocol_version]
	      ,[endpoint_id]
	      ,[encrypt_option]
	      ,[auth_scheme]
	      ,[node_affinity]
	      ,[num_reads]
	      ,[num_writes]
	      ,[last_read]
	      ,[last_write]
	      ,[net_packet_size]
	      ,[client_net_address]
	      ,[client_tcp_port]
	      ,[local_net_address]
	      ,[local_tcp_port]
	      ,[parent_connection_id]
	      ,[most_recent_sql_handle]
		  ,[host_process_id]
		  ,[client_version]
		  ,[client_interface_name]
		  ,[security_id]
		  ,[login_name]
		  ,[nt_domain]
		  ,[nt_user_name]
		  ,[memory_usage]
		  ,[total_scheduled_time]
		  ,[last_request_start_time]
		  ,[last_request_end_time]
		  ,[is_user_process]
		  ,[original_security_id]
		  ,[original_login_name]
		  ,[last_successful_logon]
		  ,[last_unsuccessful_logon]
		  ,[unsuccessful_logons]
		  ,[authenticating_database_id]
		  ,[sql_handle]
	      ,[statement_start_offset]
	      ,[statement_end_offset]
	      ,[plan_handle]
		  ,[dop]
	      ,[database_id]
	      ,[user_id]
	      ,[connection_id]
		  , 0 as [is_blocking_other_session]
from tbl
union all
select tbl0.[session_id]
	      ,tbl0.[blocking_session_id]
		  ,tbl0.[request_id]
	      ,tbl0.[start_time]
	      ,tbl0.[status]
		  ,tbl0.[status_session]
	      ,tbl0.[command]
		  ,tbl0.[percent_complete]
		  ,tbl0.[DBName]
		  ,OBJECT_name(tbl0.[objectid], tbl0.[database_id]) as [object]
	      ,tbl0.[TSQL]
		  ,tbl0.[QueryPlan]
		  ,tbl0.[event_info]
	      ,tbl0.[wait_type]
	      ,tbl0.[login_time]
		  ,tbl0.[host_name]
		  ,tbl0.[program_name]
	      ,tbl0.[wait_time]
	      ,tbl0.[last_wait_type]
	      ,tbl0.[wait_resource]
	      ,tbl0.[open_transaction_count]
	      ,tbl0.[open_resultset_count]
	      ,tbl0.[transaction_id]
	      ,tbl0.[context_info]
	      ,tbl0.[estimated_completion_time]
	      ,tbl0.[cpu_time]
	      ,tbl0.[total_elapsed_time]
	      ,tbl0.[scheduler_id]
	      ,tbl0.[task_address]
	      ,tbl0.[reads]
	      ,tbl0.[writes]
	      ,tbl0.[logical_reads]
	      ,tbl0.[text_size]
	      ,tbl0.[language]
	      ,tbl0.[date_format]
	      ,tbl0.[date_first]
	      ,tbl0.[quoted_identifier]
	      ,tbl0.[arithabort]
	      ,tbl0.[ansi_null_dflt_on]
	      ,tbl0.[ansi_defaults]
	      ,tbl0.[ansi_warnings]
	      ,tbl0.[ansi_padding]
	      ,tbl0.[ansi_nulls]
	      ,tbl0.[concat_null_yields_null]
	      ,tbl0.[transaction_isolation_level]
	      ,tbl0.[lock_timeout]
	      ,tbl0.[deadlock_priority]
	      ,tbl0.[row_count]
	      ,tbl0.[prev_error]
	      ,tbl0.[nest_level]
	      ,tbl0.[granted_query_memory]
	      ,tbl0.[executing_managed_code]
	      ,tbl0.[group_id]
	      ,tbl0.[query_hash]
	      ,tbl0.[query_plan_hash]
		  ,tbl0.[most_recent_session_id]
	      ,tbl0.[connect_time]
	      ,tbl0.[net_transport]
	      ,tbl0.[protocol_type]
	      ,tbl0.[protocol_version]
	      ,tbl0.[endpoint_id]
	      ,tbl0.[encrypt_option]
	      ,tbl0.[auth_scheme]
	      ,tbl0.[node_affinity]
	      ,tbl0.[num_reads]
	      ,tbl0.[num_writes]
	      ,tbl0.[last_read]
	      ,tbl0.[last_write]
	      ,tbl0.[net_packet_size]
	      ,tbl0.[client_net_address]
	      ,tbl0.[client_tcp_port]
	      ,tbl0.[local_net_address]
	      ,tbl0.[local_tcp_port]
	      ,tbl0.[parent_connection_id]
	      ,tbl0.[most_recent_sql_handle]
		  ,tbl0.[host_process_id]
		  ,tbl0.[client_version]
		  ,tbl0.[client_interface_name]
		  ,tbl0.[security_id]
		  ,tbl0.[login_name]
		  ,tbl0.[nt_domain]
		  ,tbl0.[nt_user_name]
		  ,tbl0.[memory_usage]
		  ,tbl0.[total_scheduled_time]
		  ,tbl0.[last_request_start_time]
		  ,tbl0.[last_request_end_time]
		  ,tbl0.[is_user_process]
		  ,tbl0.[original_security_id]
		  ,tbl0.[original_login_name]
		  ,tbl0.[last_successful_logon]
		  ,tbl0.[last_unsuccessful_logon]
		  ,tbl0.[unsuccessful_logons]
		  ,tbl0.[authenticating_database_id]
		  ,tbl0.[sql_handle]
	      ,tbl0.[statement_start_offset]
	      ,tbl0.[statement_end_offset]
	      ,tbl0.[plan_handle]
		  ,tbl0.[dop]
	      ,tbl0.[database_id]
	      ,tbl0.[user_id]
	      ,tbl0.[connection_id]
		  , 1 as [is_blocking_other_session]
	from tbl_group as tg
	inner join tbl0 on tg.blocking_session_id=tbl0.session_id
)
,tbl_res_rec_g as (
	select [plan_handle],
		   [sql_handle],
		   cast([start_time] as date) as [start_time]
	from tbl_res_rec
	group by [plan_handle],
			 [sql_handle],
			 cast([start_time] as date)
)
,tbl_rec_stat_g as (
	select qs.[plan_handle]
		  ,qs.[sql_handle]
		  --,cast(qs.[last_execution_time] as date)	as [last_execution_time]
		  ,min(qs.[creation_time])					as [creation_time]
		  ,max(qs.[execution_count])				as [execution_count]
		  ,max(qs.[total_worker_time])				as [total_worker_time]
		  ,min(qs.[last_worker_time])				as [min_last_worker_time]
		  ,max(qs.[last_worker_time])				as [max_last_worker_time]
		  ,min(qs.[min_worker_time])				as [min_worker_time]
		  ,max(qs.[max_worker_time])				as [max_worker_time]
		  ,max(qs.[total_physical_reads])			as [total_physical_reads]
		  ,min(qs.[last_physical_reads])			as [min_last_physical_reads]
		  ,max(qs.[last_physical_reads])			as [max_last_physical_reads]
		  ,min(qs.[min_physical_reads])				as [min_physical_reads]
		  ,max(qs.[max_physical_reads])				as [max_physical_reads]
		  ,max(qs.[total_logical_writes])			as [total_logical_writes]
		  ,min(qs.[last_logical_writes])			as [min_last_logical_writes]
		  ,max(qs.[last_logical_writes])			as [max_last_logical_writes]
		  ,min(qs.[min_logical_writes])				as [min_logical_writes]
		  ,max(qs.[max_logical_writes])				as [max_logical_writes]
		  ,max(qs.[total_logical_reads])			as [total_logical_reads]
		  ,min(qs.[last_logical_reads])				as [min_last_logical_reads]
		  ,max(qs.[last_logical_reads])				as [max_last_logical_reads]
		  ,min(qs.[min_logical_reads])				as [min_logical_reads]
		  ,max(qs.[max_logical_reads])				as [max_logical_reads]
		  ,max(qs.[total_clr_time])					as [total_clr_time]
		  ,min(qs.[last_clr_time])					as [min_last_clr_time]
		  ,max(qs.[last_clr_time])					as [max_last_clr_time]
		  ,min(qs.[min_clr_time])					as [min_clr_time]
		  ,max(qs.[max_clr_time])					as [max_clr_time]
		  ,max(qs.[total_elapsed_time])				as [total_elapsed_time]
		  ,min(qs.[last_elapsed_time])				as [min_last_elapsed_time]
		  ,max(qs.[last_elapsed_time])				as [max_last_elapsed_time]
		  ,min(qs.[min_elapsed_time])				as [min_elapsed_time]
		  ,max(qs.[max_elapsed_time])				as [max_elapsed_time]
		  ,max(qs.[total_rows])						as [total_rows]
		  ,min(qs.[last_rows])						as [min_last_rows]
		  ,max(qs.[last_rows])						as [max_last_rows]
		  ,min(qs.[min_rows])						as [min_rows]
		  ,max(qs.[max_rows])						as [max_rows]
		  ,max(qs.[total_dop])						as [total_dop]
		  ,min(qs.[last_dop])						as [min_last_dop]
		  ,max(qs.[last_dop])						as [max_last_dop]
		  ,min(qs.[min_dop])						as [min_dop]
		  ,max(qs.[max_dop])						as [max_dop]
		  ,max(qs.[total_grant_kb])					as [total_grant_kb]
		  ,min(qs.[last_grant_kb])					as [min_last_grant_kb]
		  ,max(qs.[last_grant_kb])					as [max_last_grant_kb]
		  ,min(qs.[min_grant_kb])					as [min_grant_kb]
		  ,max(qs.[max_grant_kb])					as [max_grant_kb]
		  ,max(qs.[total_used_grant_kb])			as [total_used_grant_kb]
		  ,min(qs.[last_used_grant_kb])				as [min_last_used_grant_kb]
		  ,max(qs.[last_used_grant_kb])				as [max_last_used_grant_kb]
		  ,min(qs.[min_used_grant_kb])				as [min_used_grant_kb]
		  ,max(qs.[max_used_grant_kb])				as [max_used_grant_kb]
		  ,max(qs.[total_ideal_grant_kb])			as [total_ideal_grant_kb]
		  ,min(qs.[last_ideal_grant_kb])			as [min_last_ideal_grant_kb]
		  ,max(qs.[last_ideal_grant_kb])			as [max_last_ideal_grant_kb]
		  ,min(qs.[min_ideal_grant_kb])				as [min_ideal_grant_kb]
		  ,max(qs.[max_ideal_grant_kb])				as [max_ideal_grant_kb]
		  ,max(qs.[total_reserved_threads])			as [total_reserved_threads]
		  ,min(qs.[last_reserved_threads])			as [min_last_reserved_threads]
		  ,max(qs.[last_reserved_threads])			as [max_last_reserved_threads]
		  ,min(qs.[min_reserved_threads])			as [min_reserved_threads]
		  ,max(qs.[max_reserved_threads])			as [max_reserved_threads]
		  ,max(qs.[total_used_threads])				as [total_used_threads]
		  ,min(qs.[last_used_threads])				as [min_last_used_threads]
		  ,max(qs.[last_used_threads])				as [max_last_used_threads]
		  ,min(qs.[min_used_threads])				as [min_used_threads]
		  ,max(qs.[max_used_threads])				as [max_used_threads]
	from tbl_res_rec_g as t
	inner join sys.dm_exec_query_stats as qs with(readuncommitted) on t.[plan_handle]=qs.[plan_handle] 
																  and t.[sql_handle]=qs.[sql_handle] 
																  and t.[start_time]=cast(qs.[last_execution_time] as date)
	group by qs.[plan_handle]
			,qs.[sql_handle]
			--,qs.[last_execution_time]
)
select t.[session_id] --������
	      ,t.[blocking_session_id] --������, ������� ���� ��������� ������ [session_id]
		  ,t.[request_id] --������������� �������. �������� � ��������� ������
	      ,t.[start_time] --����� ������� ����������� �������
		  ,DateDiff(second, t.[start_time], GetDate()) as [date_diffSec] --������� � ��� ������ ������� �� ������� ����������� �������
	      ,t.[status] --��������� �������
		  ,t.[status_session] --��������� ������
	      ,t.[command] --��� ����������� � ������ ������ �������
		  , COALESCE(
						CAST(NULLIF(t.[total_elapsed_time] / 1000, 0) as BIGINT)
					   ,CASE WHEN (t.[status_session] <> 'running' and isnull(t.[status], '')  <> 'running') 
								THEN  DATEDIFF(ss,0,getdate() - nullif(t.[last_request_end_time], '1900-01-01T00:00:00.000'))
						END
					) as [total_time, sec] --����� ���� ������ ������� � ���
		  , CAST(NULLIF((CAST(t.[total_elapsed_time] as BIGINT) - CAST(t.[wait_time] AS BIGINT)) / 1000, 0 ) as bigint) as [work_time, sec] --����� ������ ������� � ��� ��� ����� ������� ��������
		  , CASE WHEN (t.[status_session] <> 'running' AND ISNULL(t.[status],'') <> 'running') 
		  			THEN  DATEDIFF(ss,0,getdate() - nullif(t.[last_request_end_time], '1900-01-01T00:00:00.000'))
			END as [sleep_time, sec] --����� ��� � ���
		  , NULLIF( CAST((t.[logical_reads] + t.[writes]) * 8 / 1024 as numeric(38,2)), 0) as [IO, MB] --�������� ������ � ������ � ��
		  , CASE  t.transaction_isolation_level
			WHEN 0 THEN 'Unspecified'
			WHEN 1 THEN 'ReadUncommited'
			WHEN 2 THEN 'ReadCommited'
			WHEN 3 THEN 'Repetable'
			WHEN 4 THEN 'Serializable'
			WHEN 5 THEN 'Snapshot'
			END as [transaction_isolation_level_desc] --������� �������� ���������� (�����������)
		  ,t.[percent_complete] --������� ���������� ������ ��� ��������� ������
		  ,t.[DBName] --��
		  ,t.[object] --������
		  , SUBSTRING(
						t.[TSQL]
					  , t.[statement_start_offset]/2+1
					  ,	(
							CASE WHEN ((t.[statement_start_offset]<0) OR (t.[statement_end_offset]<0))
									THEN DATALENGTH (t.[TSQL])
								 ELSE t.[statement_end_offset]
							END
							- t.[statement_start_offset]
						)/2 +1
					 ) as [CURRENT_REQUEST] --������� ����������� ������ � ������
	      ,t.[TSQL] --������ ����� ������
		  ,t.[QueryPlan] --���� ����� ������
		  ,t.[event_info] --����� ���������� �� �������� ������ ��� ������ ��������������� spid
	      ,t.[wait_type] --���� ������ � ��������� ������ ����������, � ������� ���������� ��� �������� (sys.dm_os_wait_stats)
	      ,t.[login_time] --����� ����������� ������
		  ,t.[host_name] --��� ���������� ������� �������, ��������� � ������. ��� ����������� ������ ��� �������� ����� NULL
		  ,t.[program_name] --��� ���������� ���������, ������� ������������ �����. ��� ����������� ������ ��� �������� ����� NULL
		  ,cast(t.[wait_time]/1000 as decimal(18,3)) as [wait_timeSec] --���� ������ � ��������� ������ ����������, � ������� ���������� ����������������� �������� �������� (� ��������)
	      ,t.[wait_time] --���� ������ � ��������� ������ ����������, � ������� ���������� ����������������� �������� �������� (� �������������)
	      ,t.[last_wait_type] --���� ������ ��� ���������� �����, � ������� ���������� ��� ���������� ��������
	      ,t.[wait_resource] --���� ������ � ��������� ������ ����������, � ������� ������ ������, ������������ �������� ������� ������
	      ,t.[open_transaction_count] --����� ����������, �������� ��� ������� �������
	      ,t.[open_resultset_count] --����� �������������� �������, �������� ��� ������� �������
	      ,t.[transaction_id] --������������� ����������, � ������� ����������� ������
	      ,t.[context_info] --�������� CONTEXT_INFO ������
		  ,cast(t.[estimated_completion_time]/1000 as decimal(18,3)) as [estimated_completion_timeSec] --������ ��� ����������� �������������. �� ��������� �������� NULL
	      ,t.[estimated_completion_time] --������ ��� ����������� �������������. �� ��������� �������� NULL
		  ,cast(t.[cpu_time]/1000 as decimal(18,3)) as [cpu_timeSec] --����� �� (� ��������), ����������� �� ���������� �������
	      ,t.[cpu_time] --����� �� (� �������������), ����������� �� ���������� �������
		  ,cast(t.[total_elapsed_time]/1000 as decimal(18,3)) as [total_elapsed_timeSec] --����� �����, �������� � ������� ����������� ������� (� ��������)
	      ,t.[total_elapsed_time] --����� �����, �������� � ������� ����������� ������� (� �������������)
	      ,t.[scheduler_id] --������������� ������������, ������� ��������� ������ ������
	      ,t.[task_address] --����� ����� ������, ����������� ��� ������, ��������� � ���� ��������
	      ,t.[reads] --����� �������� ������, ����������� ������ ��������
	      ,t.[writes] --����� �������� ������, ����������� ������ ��������
	      ,t.[logical_reads] --����� ���������� �������� ������, ����������� ������ ��������
	      ,t.[text_size] --��������� ��������� TEXTSIZE ��� ������� �������
	      ,t.[language] --��������� ����� ��� ������� �������
	      ,t.[date_format] --��������� ��������� DATEFORMAT ��� ������� �������
	      ,t.[date_first] --��������� ��������� DATEFIRST ��� ������� �������
	      ,t.[quoted_identifier] --1 = �������� QUOTED_IDENTIFIER ��� ������� ������� (ON). � ��������� ������ � 0
	      ,t.[arithabort] --1 = �������� ARITHABORT ��� ������� ������� (ON). � ��������� ������ � 0
	      ,t.[ansi_null_dflt_on] --1 = �������� ANSI_NULL_DFLT_ON ��� ������� ������� (ON). � ��������� ������ � 0
	      ,t.[ansi_defaults] --1 = �������� ANSI_DEFAULTS ��� ������� ������� (ON). � ��������� ������ � 0
	      ,t.[ansi_warnings] --1 = �������� ANSI_WARNINGS ��� ������� ������� (ON). � ��������� ������ � 0
	      ,t.[ansi_padding] --1 = �������� ANSI_PADDING ��� ������� ������� (ON)
	      ,t.[ansi_nulls] --1 = �������� ANSI_NULLS ��� ������� ������� (ON). � ��������� ������ � 0
	      ,t.[concat_null_yields_null] --1 = �������� CONCAT_NULL_YIELDS_NULL ��� ������� ������� (ON). � ��������� ������ � 0
	      ,t.[transaction_isolation_level] --������� ��������, � ������� ������� ���������� ��� ������� �������
		  ,cast(t.[lock_timeout]/1000 as decimal(18,3)) as [lock_timeoutSec] --����� �������� ���������� ��� ������� ������� (� ��������)
		  ,t.[lock_timeout] --����� �������� ���������� ��� ������� ������� (� �������������)
	      ,t.[deadlock_priority] --�������� ��������� DEADLOCK_PRIORITY ��� ������� �������
	      ,t.[row_count] --����� �����, ������������ ������� �� ������� �������
	      ,t.[prev_error] --��������� ������, ����������� ��� ���������� �������
	      ,t.[nest_level] --������� ������� ����������� ����, ������������ ��� ������� �������
	      ,t.[granted_query_memory] --����� �������, ���������� ��� ���������� ������������ ������� (1 ��������-��� �������� 8 ��)
	      ,t.[executing_managed_code] --���������, ��������� �� ������ ������ � ��������� ����� ��� ������� ����� CLR (��������, ���������, ���� ��� ��������).
									  --���� ���� ���������� � ������� ����� �������, ����� ������ ����� CLR ��������� � �����, ���� ����� �� ����� ���������� ��� Transact-SQL
	      
		  ,t.[group_id]	--������������� ������ ������� ��������, ������� ����������� ���� ������
	      ,t.[query_hash] --�������� ���-�������� �������������� ��� ������� � ������������ ��� ������������� �������� � ����������� �������.
						  --����� ������������ ��� ������� ��� ����������� ������������� �������������� �������� ��� ��������, ������� ���������� ������ ������ ������������ ����������
	      
		  ,t.[query_plan_hash] --�������� ���-�������� �������������� ��� ����� ���������� ������� � ������������ ��� ������������� ����������� ������ ���������� ��������.
							   --����� ������������ ��� ����� ������� ��� ���������� ���������� ��������� �������� �� ������� ������� ����������
		  
		  ,t.[most_recent_session_id] --������������ ����� ������������� ������ ������ ���������� �������, ���������� � ������ �����������
	      ,t.[connect_time] --������� ������� ������������ ����������
	      ,t.[net_transport] --�������� �������� ����������� ������������� ���������, ������������� ������ �����������
	      ,t.[protocol_type] --��������� ��� ��������� �������� �������� ������
	      ,t.[protocol_version] --������ ��������� ������� � ������, ���������� � ������ �����������
	      ,t.[endpoint_id] --�������������, ����������� ��� ����������. ���� ������������� endpoint_id ����� �������������� ��� �������� � ������������� sys.endpoints
	      ,t.[encrypt_option] --���������� ��������, �����������, ��������� �� ���������� ��� ������� ����������
	      ,t.[auth_scheme] --��������� ����� �������� ����������� (SQL Server ��� Windows), ������������ � ������ �����������
	      ,t.[node_affinity] --�������������� ���� ������, �������� ������������� ������ ����������
	      ,t.[num_reads] --����� �������, �������� ����������� ������� ����������
	      ,t.[num_writes] --����� �������, ���������� ����������� ������� ����������
	      ,t.[last_read] --������� ������� � ��������� ���������� ������ ������
	      ,t.[last_write] --������� ������� � ��������� ������������ ������ ������
	      ,t.[net_packet_size] --������ �������� ������, ������������ ��� �������� ������
	      ,t.[client_net_address] --������� ����� ���������� �������
	      ,t.[client_tcp_port] --����� ����� �� ���������� ����������, ������� ������������ ��� ������������� ����������
	      ,t.[local_net_address] --IP-����� �������, � ������� ����������� ������ ����������. �������� ������ ��� ����������, ������� � �������� ���������� ������ ���������� �������� TCP
	      ,t.[local_tcp_port] --TCP-���� �������, ���� ���������� ���������� �������� TCP
	      ,t.[parent_connection_id] --�������������� ��������� ����������, ������������ � ������ MARS
	      ,t.[most_recent_sql_handle] --���������� ���������� ������� SQL, ������������ � ������� ������� ����������. ��������� ���������� ������������� ����� �������� most_recent_sql_handle � �������� most_recent_session_id
		  ,t.[host_process_id] --������������� �������� ���������� ���������, ������� ������������ �����. ��� ����������� ������ ��� �������� ����� NULL
		  ,t.[client_version] --������ TDS-��������� ����������, ������� ������������ �������� ��� ����������� � �������. ��� ����������� ������ ��� �������� ����� NULL
		  ,t.[client_interface_name] --��� ���������� ��� �������, ������������ �������� ��� ������ ������� � ��������. ��� ����������� ������ ��� �������� ����� NULL
		  ,t.[security_id] --������������� ������������ Microsoft Windows, ��������� � ������ �����
		  ,t.[login_name] --SQL Server ��� �����, ��� ������� ����������� ������� �����.
						  --����� ������ �������������� ��� �����, � ������� �������� ��� ������ �����, ��. �������� original_login_name.
						  --����� ���� SQL Server �������� ����������� ����� ����� ��� ����� ������������ ������, ���������� �������� ����������� Windows
		  
		  ,t.[nt_domain] --����� Windows ��� �������, ���� �� ����� ������ ����������� �������� ����������� Windows ��� ������������� ����������.
						 --��� ���������� ������� � �������������, �� ������������� � ������, ��� �������� ����� NULL
		  
		  ,t.[nt_user_name] --��� ������������ Windows ��� �������, ���� �� ����� ������ ������������ �������� ����������� Windows ��� ������������� ����������.
							--��� ���������� ������� � �������������, �� ������������� � ������, ��� �������� ����� NULL
		  
		  ,t.[memory_usage] --���������� 8-������������ ������� ������, ������������ ������ �������
		  ,t.[total_scheduled_time] --����� �����, ����������� ������� ������ (������� ��� ��������� �������) ��� ����������, � �������������
		  ,t.[last_request_start_time] --�����, ����� ������� ��������� ������ ������� ������. ��� ����� ���� ������, ������������� � ������ ������
		  ,t.[last_request_end_time] --����� ���������� ���������� ������� � ������ ������� ������
		  ,t.[is_user_process] --0, ���� ����� �������� ���������. � ��������� ������ �������� ����� 1
		  ,t.[original_security_id] --Microsoft ������������� ������������ Windows, ��������� � ���������� original_login_name
		  ,t.[original_login_name] --SQL Server ��� �����, ������� ���������� ������ ������ ������ �����.
								   --��� ����� ���� ��� ����� SQL Server, ��������� �������� �����������, ��� ������������ ������ Windows, 
								   --��������� �������� �����������, ��� ������������ ���������� ���� ������.
								   --�������� ��������, ��� ����� ��������������� ���������� ��� ������ ����� ���� ��������� ����� ������� ��� ����� ������������ ���������.
								   --�������� ���� EXECUTE AS ������������
		  
		  ,t.[last_successful_logon] --����� ���������� ��������� ����� � ������� ��� ����� original_login_name �� ������� �������� ������
		  ,t.[last_unsuccessful_logon] --����� ���������� ����������� ����� � ������� ��� ����� original_login_name �� ������� �������� ������
		  ,t.[unsuccessful_logons] --����� ���������� ������� ����� � ������� ��� ����� original_login_name ����� �������� last_successful_logon � �������� login_time
		  ,t.[authenticating_database_id] --������������� ���� ������, ����������� �������� ����������� ���������.
										  --��� ���� ����� ��� �������� ����� ����� 0.
										  --��� ������������� ���������� ���� ������ ��� �������� ����� ��������� ������������� ���������� ���� ������
		  
		  ,t.[sql_handle] --���-����� ������ SQL-�������
	      ,t.[statement_start_offset] --���������� �������� � ����������� � ��������� ������ ������ ��� �������� ���������, � ������� �������� ������� ����������.
									  --����� ����������� ������ � ��������� ������������� ���������� sql_handle, statement_end_offset � sys.dm_exec_sql_text
									  --��� ���������� ����������� � ��������� ������ ���������� �� �������
	      
		  ,t.[statement_end_offset] --���������� �������� � ����������� � ��������� ������ ������ ��� �������� ���������, � ������� ����������� ������� ����������.
									--����� ����������� ������ � ��������� ������������� ���������� sql_handle, statement_end_offset � sys.dm_exec_sql_text
									--��� ���������� ����������� � ��������� ������ ���������� �� �������
	      
		  ,t.[plan_handle] --���-����� ����� ���������� SQL
	      ,t.[database_id] --������������� ���� ������, � ������� ����������� ������
	      ,t.[user_id] --������������� ������������, ������������ ������ ������
	      ,t.[connection_id] --������������� ����������, �� �������� �������� ������
		  ,t.[is_blocking_other_session] --1-������ ���� ��������� ������ ������, 0-������ ���� �� ��������� ������ ������
		  ,coalesce(t.[dop], mg.[dop]) as [dop] --������� ������������ �������
		  ,mg.[request_time] --���� � ����� ��������� ������� �� ��������������� ������
		  ,mg.[grant_time] --���� � �����, ����� ������� ���� ������������� ������. ���������� �������� NULL, ���� ������ ��� �� ���� �������������
		  ,mg.[requested_memory_kb] --����� ����� ����������� ������ � ����������
		  ,mg.[granted_memory_kb] --����� ����� ���������� ��������������� ������ � ����������.
								  --����� ���� �������� NULL, ���� ������ ��� �� ���� �������������.
								  --������ ��� �������� ������ ���� ���������� � requested_memory_kb.
								  --��� �������� ������� ������ ����� ��������� �������������� �������������� �� ���������� ������,
								  --����� ������� ������� �� ����� ���������� ��������������� ������
		  
		  ,mg.[required_memory_kb] --����������� ����� ������ � ���������� (��), ����������� ��� ���������� ������� �������.
								   --�������� requested_memory_kb ����� ����� ������ ��� ������ ���
		  
		  ,mg.[used_memory_kb] --������������ � ������ ������ ����� ���������� ������ (� ����������)
		  ,mg.[max_used_memory_kb] --������������ ����� ������������ �� ������� ������� ���������� ������ � ����������
		  ,mg.[query_cost] --��������� ��������� �������
		  ,mg.[timeout_sec] --����� �������� ������� ������� � �������� �� ������ �� ��������� �� ��������������� ������
		  ,mg.[resource_semaphore_id] --������������ ������������� �������� �������, �������� ������� ������ ������
		  ,mg.[queue_id] --������������� ��������� �������, � ������� ������ ������ ������� �������������� ������.
						 --�������� NULL, ���� ������ ��� �������������
		  
		  ,mg.[wait_order] --���������������� ������� ��������� �������� � ��������� ������� queue_id.
						   --��� �������� ����� ���������� ��� ��������� �������, ���� ������ ������� ������������ �� �������������� ������ ��� �������� ��.
						   --�������� NULL, ���� ������ ��� �������������
		  
		  ,mg.[is_next_candidate] --�������� ��������� ���������� �� �������������� ������ (1 = ��, 0 = ���, NULL = ������ ��� �������������)
		  ,mg.[wait_time_ms] --����� �������� � �������������. �������� NULL, ���� ������ ��� �������������
		  ,mg.[pool_id] --������������� ���� ��������, � �������� ����������� ������ ������ ������� ��������
		  ,mg.[is_small] --�������� 1 ��������, ��� ��� ������ �������� �������������� ������ ������������ ����� ������� �������.
						 --�������� 0 �������� ������������� �������� ��������
		  
		  ,mg.[ideal_memory_kb] --�����, � ���������� (��), ��������������� ������, ����������� ��� ���������� ���� ������ � ���������� ������.
								--������������ �� ������ ���������� ���������
		  
		  ,mg.[reserved_worker_count] --����� ������� ���������, ����������������� � ������� ������������ ��������, � ����� ����� �������� ������� ���������, ������������ ����� ���������
		  ,mg.[used_worker_count] --����� ������� ���������, ������������ ������������ ��������
		  ,mg.[max_used_worker_count] --???
		  ,mg.[reserved_node_bitmap] --???
		  ,pl.[bucketid] --������������� �������� ����, � ������� ���������� ������.
						 --�������� ��������� �������� �� 0 �� �������� ������� ���-������� ��� ���� ����.
						 --��� ����� SQL Plans � Object Plans ������ ���-������� ����� ��������� 10007 �� 32-��������� ������� ������ � 40009 � �� 64-���������.
						 --��� ���� Bound Trees ������ ���-������� ����� ��������� 1009 �� 32-��������� ������� ������ � 4001 �� 64-���������.
						 --��� ���� ����������� �������� �������� ������ ���-������� ����� ��������� 127 �� 32-��������� � 64-��������� ������� ������
		  
		  ,pl.[refcounts] --����� �������� ����, ����������� �� ������ ������ ����.
						  --�������� refcounts ��� ������ ������ ���� �� ������ 1, ����� ����������� � ����
		  
		  ,pl.[usecounts] --���������� ���������� ������ ������� ����.
						  --�������� ��� ����������, ���� ����������������� ������� ������������ ���� � ����.
						  --����� ���� �������� ��������� ��� ��� ������������� ���������� showplan
		  
		  ,pl.[size_in_bytes] --����� ������, ���������� �������� ����
		  ,pl.[memory_object_address] --����� ������ ������������ ������.
									  --��� �������� ����� ������������ � �������������� sys.dm_os_memory_objects,
									  --����� ���������������� ������������� ������ ������������� �����, 
									  --� � �������������� sys.dm_os_memory_cache_entries ��� ����������� ������ �� ����������� ������
		  
		  ,pl.[cacheobjtype] --��� ������� � ����. �������� ����� ���� ����� �� ���������
		  ,pl.[objtype] --��� �������. �������� ����� ���� ����� �� ���������
		  ,pl.[parent_plan_handle] --������������ ����
		  
		  --������ �� sys.dm_exec_query_stats ������� �� �����, � ������� ���� ���� (������, ����)
		  ,qs.[creation_time] --����� ���������� �����
		  ,qs.[execution_count] --���������� ���������� ����� � ������� ��������� ����������
		  ,qs.[total_worker_time] --����� ����� ��, ����������� �� ���������� ����� � ������� ����������, � ������������� (�� � ��������� �� ������������)
		  ,qs.[min_last_worker_time] --����������� ����� ��, ����������� �� ��������� ���������� �����, � ������������� (�� � ��������� �� ������������)
		  ,qs.[max_last_worker_time] --������������ ����� ��, ����������� �� ��������� ���������� �����, � ������������� (�� � ��������� �� ������������)
		  ,qs.[min_worker_time] --����������� ����� ��, �����-���� ����������� �� ���������� �����, � ������������� (�� � ��������� �� ������������)
		  ,qs.[max_worker_time] --������������ ����� ��, �����-���� ����������� �� ���������� �����, � ������������� (�� � ��������� �� ������������)
		  ,qs.[total_physical_reads] --����� ���������� �������� ����������� ���������� ��� ���������� ����� � ������� ��� ����������.
									 --�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[min_last_physical_reads] --����������� ���������� �������� ����������� ���������� �� ����� ���������� ���������� �����.
										--�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[max_last_physical_reads] --������������ ���������� �������� ����������� ���������� �� ����� ���������� ���������� �����.
										--�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[min_physical_reads] --����������� ���������� �������� ����������� ���������� �� ���� ���������� �����.
								   --�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[max_physical_reads] --������������ ���������� �������� ����������� ���������� �� ���� ���������� �����.
								   --�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[total_logical_writes] --����� ���������� �������� ���������� ������ ��� ���������� ����� � ������� ��� ����������.
									 --�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[min_last_logical_writes] --����������� ���������� ������� � �������� ����, ������������ �� ����� ���������� ���������� �����.
										--���� �������� ��� �������� �������� (�. �. ����������), �������� ������ �� �����������.
										--�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[max_last_logical_writes] --������������ ���������� ������� � �������� ����, ������������ �� ����� ���������� ���������� �����.
										--���� �������� ��� �������� �������� (�. �. ����������), �������� ������ �� �����������.
										--�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[min_logical_writes] --����������� ���������� �������� ���������� ������ �� ���� ���������� �����.
								   --�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[max_logical_writes] --������������ ���������� �������� ���������� ������ �� ���� ���������� �����.
								   --�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[total_logical_reads] --����� ���������� �������� ����������� ���������� ��� ���������� ����� � ������� ��� ����������.
									--�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[min_last_logical_reads] --����������� ���������� �������� ����������� ���������� �� ����� ���������� ���������� �����.
									   --�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[max_last_logical_reads] --������������ ���������� �������� ����������� ���������� �� ����� ���������� ���������� �����.
									   --�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[min_logical_reads]	   --����������� ���������� �������� ����������� ���������� �� ���� ���������� �����.
									   --�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[max_logical_reads]	--������������ ���������� �������� ����������� ���������� �� ���� ���������� �����.
									--�������� ������ ����� 0 ��� ������� ���������������� ��� ������ �������
		  
		  ,qs.[total_clr_time]	--�����, � ������������� (�� � ��������� �� ������������),
								--������ Microsoft .NET Framework ������������ ����� ���������� (CLR) ������� ��� ���������� ����� � ������� ��� ����������.
								--������� ����� CLR ����� ���� ��������� �����������, ���������, ����������, ������ � ��������������� �����������
		  
		  ,qs.[min_last_clr_time] --����������� �����, � ������������� (�� � ��������� �� ������������),
								  --����������� ������ .NET Framework ������� ����� CLR �� ����� ���������� ���������� �����.
								  --������� ����� CLR ����� ���� ��������� �����������, ���������, ����������, ������ � ��������������� �����������
		  
		  ,qs.[max_last_clr_time] --������������ �����, � ������������� (�� � ��������� �� ������������),
								  --����������� ������ .NET Framework ������� ����� CLR �� ����� ���������� ���������� �����.
								  --������� ����� CLR ����� ���� ��������� �����������, ���������, ����������, ������ � ��������������� �����������
		  
		  ,qs.[min_clr_time] --����������� �����, �����-���� ����������� �� ���������� ����� ������ �������� .NET Framework ����� CLR,
							 --� ������������� (�� � ��������� �� ������������).
							 --������� ����� CLR ����� ���� ��������� �����������, ���������, ����������, ������ � ��������������� �����������
		  
		  ,qs.[max_clr_time] --������������ �����, �����-���� ����������� �� ���������� ����� ������ ����� CLR .NET Framework,
							 --� ������������� (�� � ��������� �� ������������).
							 --������� ����� CLR ����� ���� ��������� �����������, ���������, ����������, ������ � ��������������� �����������
		  
		  --,qs.[total_elapsed_time] --����� �����, ����������� �� ���������� �����, � ������������� (�� � ��������� �� ������������)
		  ,qs.[min_last_elapsed_time] --����������� �����, ����������� �� ��������� ���������� �����, � ������������� (�� � ��������� �� ������������)
		  ,qs.[max_last_elapsed_time] --������������ �����, ����������� �� ��������� ���������� �����, � ������������� (�� � ��������� �� ������������)
		  ,qs.[min_elapsed_time] --����������� �����, �����-���� ����������� �� ���������� �����, � ������������� (�� � ��������� �� ������������)
		  ,qs.[max_elapsed_time] --������������ �����, �����-���� ����������� �� ���������� �����, � ������������� (�� � ��������� �� ������������)
		  ,qs.[total_rows] --����� ����� �����, ������������ ��������. �� ����� ����� �������� null.
						   --�������� ������ ����� 0, ���� ���������������� � ����������� ���� �������� ��������� ����������� ���������������� ��� ������ �������
		  
		  ,qs.[min_last_rows] --����������� ����� �����, ������������ ��������� ����������� �������. �� ����� ����� �������� null.
							  --�������� ������ ����� 0, ���� ���������������� � ����������� ���� �������� ��������� ����������� ���������������� ��� ������ �������
		  
		  ,qs.[max_last_rows] --������������ ����� �����, ������������ ��������� ����������� �������. �� ����� ����� �������� null.
							  --�������� ������ ����� 0, ���� ���������������� � ����������� ���� �������� ��������� ����������� ���������������� ��� ������ �������
		  
		  ,qs.[min_rows] --����������� ���������� �����, �����-���� ������������ �� ������� �� ����� ���������� ����
						 --�������� ������ ����� 0, ���� ���������������� � ����������� ���� �������� ��������� ����������� ���������������� ��� ������ �������
		  
		  ,qs.[max_rows] --������������ ����� �����, �����-���� ������������ �� ������� �� ����� ���������� ����
						 --�������� ������ ����� 0, ���� ���������������� � ����������� ���� �������� ��������� ����������� ���������������� ��� ������ �������
		  
		  ,qs.[total_dop] --����� ����� �� ������� ������������ ����� ������������ � ������� ��� ����������.
						  --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_last_dop] --����������� ������� ������������, ���� ����� ���������� ���������� �����.
							 --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_last_dop] --������������ ������� ������������, ���� ����� ���������� ���������� �����.
							 --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_dop] --����������� ������� ������������ ���� ���� �����-���� ������������ �� ����� ������ ����������.
						--�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_dop] --������������ ������� ������������ ���� ���� �����-���� ������������ �� ����� ������ ����������.
						--�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[total_grant_kb] --����� ����� ����������������� ������ � �� ������������ ���� ����, ���������� � ������� ��� ����������.
							   --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_last_grant_kb] --����������� ����� ����������������� ������ ������������� � ��, ����� ����� ���������� ���������� �����.
								  --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_last_grant_kb] --������������ ����� ����������������� ������ ������������� � ��, ����� ����� ���������� ���������� �����.
								  --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_grant_kb] --����������� ����� ����������������� ������ � �� ������������ ������� �� �������� � ���� ������ ���������� �����.
							 --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_grant_kb] --������������ ����� ����������������� ������ � �� ������������ ������� �� �������� � ���� ������ ���������� �����.
							 --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[total_used_grant_kb] --����� ����� ����������������� ������ � �� ������������ ���� ����, ������������ � ������� ��� ����������.
									--�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_last_used_grant_kb] --����������� ����� �������������� ������������ ������ � ��, ���� ����� ���������� ���������� �����.
									   --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_last_used_grant_kb] --������������ ����� �������������� ������������ ������ � ��, ���� ����� ���������� ���������� �����.
									   --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_used_grant_kb] --����������� ����� ������������ ������ � �� ������������ ������� �� ������������ ��� ���������� ������ �����.
								  --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_used_grant_kb] --������������ ����� ������������ ������ � �� ������������ ������� �� ������������ ��� ���������� ������ �����.
								  --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[total_ideal_grant_kb] --����� ����� ��������� ������ � ��, ������ ����� � ������� ��� ����������.
									 --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_last_ideal_grant_kb] --����������� ����� ������, ��������� ������������� � ��, ����� ����� ���������� ���������� �����.
										--�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_last_ideal_grant_kb] --������������ ����� ������, ��������� ������������� � ��, ����� ����� ���������� ���������� �����.
										--�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_ideal_grant_kb] --����������� ����� ������ ��������� �������������� � ���� ���� �����-���� ������ �� ����� ���������� ���� ��.
								   --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_ideal_grant_kb] --������������ ����� ������ ��������� �������������� � ���� ���� �����-���� ������ �� ����� ���������� ���� ��.
								   --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[total_reserved_threads] --����� ����� �� ����������������� ������������� ������� ���� ���� �����-���� ����������������� � ������� ��� ����������.
									   --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_last_reserved_threads] --����������� ����� ����������������� ������������ �������, ����� ����� ���������� ���������� �����.
										  --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_last_reserved_threads] --������������ ����� ����������������� ������������ �������, ����� ����� ���������� ���������� �����.
										  --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_reserved_threads] --����������� ����� ����������������� ������������� �������, �����-���� ������������ ��� ���������� ������ �����.
									 --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_reserved_threads] --������������ ����� ����������������� ������������� ������� ������� �� ������������ ��� ���������� ������ �����.
									 --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[total_used_threads] --����� ����� ������������ ������������ ������� ���� ���� �����-���� ����������������� � ������� ��� ����������.
								   --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_last_used_threads] --����������� ����� ������������ ������������ �������, ����� ����� ���������� ���������� �����.
									  --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_last_used_threads] --������������ ����� ������������ ������������ �������, ����� ����� ���������� ���������� �����.
									  --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[min_used_threads] --����������� ����� ������������ ������������ �������, ��� ���������� ������ ����� ������������.
								 --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
		  
		  ,qs.[max_used_threads] --������������ ����� ������������ ������������ �������, ��� ���������� ������ ����� ������������.
								 --�� ������ ����� ����� 0 ��� ������� � �������, ���������������� ��� ������
from tbl_res_rec as t
left outer join sys.dm_exec_query_memory_grants as mg on t.[plan_handle]=mg.[plan_handle] and t.[sql_handle]=mg.[sql_handle]
left outer join sys.dm_exec_cached_plans as pl on t.[plan_handle]=pl.[plan_handle]
left outer join tbl_rec_stat_g as qs on t.[plan_handle]=qs.[plan_handle] and t.[sql_handle]=qs.[sql_handle] --and qs.[last_execution_time]=cast(t.[start_time] as date)
;
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Alter view [inf].[vQueryStat]
--
GO


ALTER view [inf].[vQueryStat] as 
select DB_Name(coalesce(ST.[dbid], PT.[dbid])) as [DB_Name]
	   ,OBJECT_SCHEMA_NAME(coalesce(ST.[objectid], PT.[objectid]), coalesce(ST.[dbid], PT.[dbid])) as [Schema_Name]
	   ,object_name(coalesce(ST.[objectid], PT.[objectid]), coalesce(ST.[dbid], PT.[dbid])) as [Trigger_Name]
	  ,QS.[sql_handle]
      ,QS.[statement_start_offset]
      ,QS.[statement_end_offset]
      ,QS.[plan_generation_num]
      ,QS.[plan_handle]
      ,QS.[creation_time]
      ,QS.[last_execution_time]
      ,QS.[execution_count]
      ,QS.[total_worker_time]
      ,QS.[last_worker_time]
      ,QS.[min_worker_time]
      ,QS.[max_worker_time]
      ,QS.[total_physical_reads]
      ,QS.[last_physical_reads]
      ,QS.[min_physical_reads]
      ,QS.[max_physical_reads]
      ,QS.[total_logical_writes]
      ,QS.[last_logical_writes]
      ,QS.[min_logical_writes]
      ,QS.[max_logical_writes]
      ,QS.[total_logical_reads]
      ,QS.[last_logical_reads]
      ,QS.[min_logical_reads]
      ,QS.[max_logical_reads]
      ,QS.[total_clr_time]
      ,QS.[last_clr_time]
      ,QS.[min_clr_time]
      ,QS.[max_clr_time]
      ,QS.[total_elapsed_time]
      ,QS.[last_elapsed_time]
      ,QS.[min_elapsed_time]
      ,QS.[max_elapsed_time]
      ,QS.[query_hash]
      ,QS.[query_plan_hash]
      ,QS.[total_rows]
      ,QS.[last_rows]
      ,QS.[min_rows]
      ,QS.[max_rows]
      ,QS.[statement_sql_handle]
      ,QS.[statement_context_id]
      ,QS.[total_dop]
      ,QS.[last_dop]
      ,QS.[min_dop]
      ,QS.[max_dop]
      ,QS.[total_grant_kb]
      ,QS.[last_grant_kb]
      ,QS.[min_grant_kb]
      ,QS.[max_grant_kb]
      ,QS.[total_used_grant_kb]
      ,QS.[last_used_grant_kb]
      ,QS.[min_used_grant_kb]
      ,QS.[max_used_grant_kb]
      ,QS.[total_ideal_grant_kb]
      ,QS.[last_ideal_grant_kb]
      ,QS.[min_ideal_grant_kb]
      ,QS.[max_ideal_grant_kb]
      ,QS.[total_reserved_threads]
      ,QS.[last_reserved_threads]
      ,QS.[min_reserved_threads]
      ,QS.[max_reserved_threads]
      ,QS.[total_used_threads]
      ,QS.[last_used_threads]
      ,QS.[min_used_threads]
      ,QS.[max_used_threads]
      ,NULL as [total_columnstore_segment_reads]
      ,NULL as [last_columnstore_segment_reads]
      ,NULL as [min_columnstore_segment_reads]
      ,NULL as [max_columnstore_segment_reads]
      ,NULL as [total_columnstore_segment_skips]
      ,NULL as [last_columnstore_segment_skips]
      ,NULL as [min_columnstore_segment_skips]
      ,NULL as [max_columnstore_segment_skips]
	  ,coalesce(ST.[dbid], PT.[dbid]) as [dbid]
	  ,SCHEMA_ID(OBJECT_SCHEMA_NAME(coalesce(ST.[objectid], PT.[objectid]), coalesce(ST.[dbid], PT.[dbid]))) as [schema_id]
	  ,coalesce(ST.[objectid], PT.[objectid]) as [objectid]
	  ,ST.[encrypted]
	  ,ST.[text] as [TSQL]
	  ,PT.[query_plan]
FROM sys.dm_exec_query_stats AS QS
     CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST
	 CROSS APPLY sys.dm_exec_query_plan(QS.[plan_handle]) as PT
GO
IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

--
-- Commit Transaction
--
IF @@TRANCOUNT>0 COMMIT TRANSACTION
GO

--
-- Set NOEXEC to off
--
SET NOEXEC OFF
GO