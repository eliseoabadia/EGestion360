:setvar DatabaseName "GestionEmpresarial"
:setvar DefaultFilePrefix "GestionEmpresarial"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\"
GO
:on error exit
GO
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
BEGIN
    PRINT N'El modo SQLCMD debe estar habilitado para ejecutar correctamente este script.';
    SET NOEXEC ON;
END
GO
USE [master];
GO
IF DB_ID(N'$(DatabaseName)') IS NULL
BEGIN
    PRINT N'Creando base de datos $(DatabaseName)...';

    DECLARE @CreateDatabaseSql NVARCHAR(MAX) = N'
CREATE DATABASE [$(DatabaseName)]
ON PRIMARY(NAME = [$(DatabaseName)], FILENAME = N''$(DefaultDataPath)$(DefaultFilePrefix)_Primary.mdf'')
LOG ON (NAME = [$(DatabaseName)_log], FILENAME = N''$(DefaultLogPath)$(DefaultFilePrefix)_Primary.ldf'')
COLLATE Modern_Spanish_CI_AS;';

    EXEC sys.sp_executesql @CreateDatabaseSql;
END
ELSE
BEGIN
    PRINT N'La base de datos $(DatabaseName) ya existe. No se elimina ni se recrea.';
END
GO
USE [$(DatabaseName)];
GO
