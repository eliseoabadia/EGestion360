/*
    Política base de respaldos para SQL Server.
    - FULL diario a las 23:00.
    - DIFERENCIAL cada 6 horas.
    - LOG cada 10 minutos.

    Los archivos se escriben en la carpeta predeterminada de respaldos de la
    instancia. La cuenta del servicio de SQL Server debe tener acceso a ella.
*/
USE [GestionEmpresarial];
GO

CREATE OR ALTER PROCEDURE [SIS].[usp_BackupGestionEmpresarial]
    @BackupType char(1)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @BackupType = UPPER(@BackupType);
    IF @BackupType NOT IN ('D', 'I', 'L')
        THROW 51000, 'Tipo de respaldo inválido. Use D (full), I (diferencial) o L (log).', 1;

    DECLARE @databaseName sysname = DB_NAME();
    DECLARE @backupPath nvarchar(4000) = CONVERT(nvarchar(4000), SERVERPROPERTY('InstanceDefaultBackupPath'));
    DECLARE @separator nchar(1) = CASE WHEN @@VERSION LIKE '%Windows%' THEN N'\' ELSE N'/' END;

    IF NULLIF(@backupPath, N'') IS NULL
        THROW 51001, 'La instancia no tiene configurada una carpeta predeterminada de respaldos.', 1;

    IF RIGHT(@backupPath, 1) NOT IN (N'\', N'/')
        SET @backupPath += @separator;

    DECLARE @timestamp varchar(15) =
        CONVERT(char(8), SYSDATETIME(), 112) + '_' +
        REPLACE(CONVERT(char(8), SYSDATETIME(), 108), ':', '');
    DECLARE @suffix varchar(12) =
        CASE @BackupType WHEN 'D' THEN '_FULL.bak' WHEN 'I' THEN '_DIFF.bak' ELSE '_LOG.trn' END;
    DECLARE @fileName nvarchar(4000) = @backupPath + @databaseName + '_' + @timestamp + @suffix;

    IF @BackupType = 'D'
        BACKUP DATABASE @databaseName TO DISK = @fileName
            WITH CHECKSUM, COMPRESSION, INIT, STATS = 10;
    ELSE IF @BackupType = 'I'
        BACKUP DATABASE @databaseName TO DISK = @fileName
            WITH DIFFERENTIAL, CHECKSUM, COMPRESSION, INIT, STATS = 10;
    ELSE
        BACKUP LOG @databaseName TO DISK = @fileName
            WITH CHECKSUM, COMPRESSION, INIT, STATS = 10;

    RESTORE VERIFYONLY FROM DISK = @fileName WITH CHECKSUM;
END;
GO

USE [msdb];
GO

DECLARE @jobs TABLE
(
    JobName sysname NOT NULL,
    StepCommand nvarchar(max) NOT NULL,
    ScheduleName sysname NOT NULL,
    FrequencyType int NOT NULL,
    FrequencyInterval int NOT NULL,
    FrequencySubdayType int NOT NULL,
    FrequencySubdayInterval int NOT NULL,
    ActiveStartTime int NOT NULL
);

INSERT @jobs
    (JobName, StepCommand, ScheduleName, FrequencyType, FrequencyInterval,
     FrequencySubdayType, FrequencySubdayInterval, ActiveStartTime)
VALUES
    (N'EG360 - Respaldo FULL', N'EXEC [SIS].[usp_BackupGestionEmpresarial] @BackupType = ''D'';',
     N'EG360 - FULL diario 23h', 4, 1, 1, 0, 230000),
    (N'EG360 - Respaldo DIFERENCIAL', N'EXEC [SIS].[usp_BackupGestionEmpresarial] @BackupType = ''I'';',
     N'EG360 - DIF cada 6 horas', 4, 1, 8, 6, 000500),
    (N'EG360 - Respaldo LOG', N'EXEC [SIS].[usp_BackupGestionEmpresarial] @BackupType = ''L'';',
     N'EG360 - LOG cada 10 minutos', 4, 1, 4, 10, 000000);

DECLARE
    @jobName sysname,
    @stepCommand nvarchar(max),
    @scheduleName sysname,
    @frequencyType int,
    @frequencyInterval int,
    @frequencySubdayType int,
    @frequencySubdayInterval int,
    @activeStartTime int;

DECLARE job_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT JobName, StepCommand, ScheduleName, FrequencyType, FrequencyInterval,
       FrequencySubdayType, FrequencySubdayInterval, ActiveStartTime
FROM @jobs;

OPEN job_cursor;
FETCH NEXT FROM job_cursor INTO
    @jobName, @stepCommand, @scheduleName, @frequencyType, @frequencyInterval,
    @frequencySubdayType, @frequencySubdayInterval, @activeStartTime;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = @jobName)
        EXEC dbo.sp_delete_job @job_name = @jobName, @delete_unused_schedule = 1;

    EXEC dbo.sp_add_job
        @job_name = @jobName,
        @enabled = 1,
        @description = N'Respaldo automatizado de GestionEmpresarial con CHECKSUM y verificación.';

    EXEC dbo.sp_add_jobstep
        @job_name = @jobName,
        @step_name = N'Ejecutar respaldo y verificar',
        @subsystem = N'TSQL',
        @database_name = N'GestionEmpresarial',
        @command = @stepCommand,
        @retry_attempts = 3,
        @retry_interval = 5,
        @on_success_action = 1,
        @on_fail_action = 2;

    EXEC dbo.sp_add_schedule
        @schedule_name = @scheduleName,
        @enabled = 1,
        @freq_type = @frequencyType,
        @freq_interval = @frequencyInterval,
        @freq_subday_type = @frequencySubdayType,
        @freq_subday_interval = @frequencySubdayInterval,
        @active_start_date = 20260101,
        @active_start_time = @activeStartTime;

    EXEC dbo.sp_attach_schedule @job_name = @jobName, @schedule_name = @scheduleName;
    EXEC dbo.sp_add_jobserver @job_name = @jobName;

    FETCH NEXT FROM job_cursor INTO
        @jobName, @stepCommand, @scheduleName, @frequencyType, @frequencyInterval,
        @frequencySubdayType, @frequencySubdayInterval, @activeStartTime;
END;

CLOSE job_cursor;
DEALLOCATE job_cursor;
GO

