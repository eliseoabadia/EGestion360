/*
    Aislamiento por empresa y cierre del flujo Anteproyecto -> Autorizado.
    Idempotente para GestionEmpresarial.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF COL_LENGTH('PRES.EgresoProyectado', 'FKIdEmpresa_SIS') IS NULL
    EXEC(N'ALTER TABLE PRES.EgresoProyectado ADD FKIdEmpresa_SIS INT NULL;');

IF COL_LENGTH('PRES.EgresoAutorizado', 'FKIdEmpresa_SIS') IS NULL
    EXEC(N'ALTER TABLE PRES.EgresoAutorizado ADD FKIdEmpresa_SIS INT NULL;');
GO

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE ep
       SET FKIdEmpresa_SIS = u.FKIdEmpresa_SIS
    FROM PRES.EgresoProyectado ep
    INNER JOIN SIS.Usuario u ON u.PkIdUsuario = ep.UsuarioCreacion
    WHERE ep.FKIdEmpresa_SIS IS NULL;

    UPDATE ea
       SET FKIdEmpresa_SIS = COALESCE(ep.FKIdEmpresa_SIS, u.FKIdEmpresa_SIS)
    FROM PRES.EgresoAutorizado ea
    LEFT JOIN PRES.EgresoProyectado ep ON ep.PKIdEgresoProyectado = ea.FKIdEgresoProyectado_PRES
    INNER JOIN SIS.Usuario u ON u.PkIdUsuario = ea.UsuarioCreacion
    WHERE ea.FKIdEmpresa_SIS IS NULL;

    IF EXISTS (SELECT 1 FROM PRES.EgresoProyectado WHERE FKIdEmpresa_SIS IS NULL)
        THROW 51000, 'Existen anteproyectos sin empresa y no se puede completar la migracion.', 1;

    IF EXISTS (SELECT 1 FROM PRES.EgresoAutorizado WHERE FKIdEmpresa_SIS IS NULL)
        THROW 51001, 'Existen presupuestos autorizados sin empresa y no se puede completar la migracion.', 1;

    IF EXISTS
    (
        SELECT 1 FROM sys.columns
        WHERE object_id = OBJECT_ID('PRES.EgresoProyectado')
          AND name = 'FKIdEmpresa_SIS' AND is_nullable = 1
    )
        ALTER TABLE PRES.EgresoProyectado ALTER COLUMN FKIdEmpresa_SIS INT NOT NULL;

    IF EXISTS
    (
        SELECT 1 FROM sys.columns
        WHERE object_id = OBJECT_ID('PRES.EgresoAutorizado')
          AND name = 'FKIdEmpresa_SIS' AND is_nullable = 1
    )
        ALTER TABLE PRES.EgresoAutorizado ALTER COLUMN FKIdEmpresa_SIS INT NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_EgresoProyectado_Empresa')
        ALTER TABLE PRES.EgresoProyectado WITH CHECK
        ADD CONSTRAINT FK_EgresoProyectado_Empresa FOREIGN KEY (FKIdEmpresa_SIS)
        REFERENCES SIS.Empresa(PKIdEmpresa);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_EgresoAutorizado_Empresa')
        ALTER TABLE PRES.EgresoAutorizado WITH CHECK
        ADD CONSTRAINT FK_EgresoAutorizado_Empresa FOREIGN KEY (FKIdEmpresa_SIS)
        REFERENCES SIS.Empresa(PKIdEmpresa);

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('PRES.EgresoProyectado') AND name = 'IX_EgresoProyectado_FKIdEmpresa_SIS')
        CREATE INDEX IX_EgresoProyectado_FKIdEmpresa_SIS
        ON PRES.EgresoProyectado(FKIdEmpresa_SIS, Activo, Fecha);

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('PRES.EgresoAutorizado') AND name = 'IX_EgresoAutorizado_FKIdEmpresa_SIS')
        CREATE INDEX IX_EgresoAutorizado_FKIdEmpresa_SIS
        ON PRES.EgresoAutorizado(FKIdEmpresa_SIS, Activo, Fecha);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

DECLARE @sql NVARCHAR(MAX);

SET @sql = OBJECT_DEFINITION(OBJECT_ID('PRES.Vw_EgresoProyectado'));
IF @sql IS NULL THROW 51002, 'No existe PRES.Vw_EgresoProyectado.', 1;
IF CHARINDEX('ep.[FKIdEmpresa_SIS]', @sql) = 0
BEGIN
    SET @sql = REPLACE(@sql, 'CREATE VIEW', 'CREATE OR ALTER VIEW');
    SET @sql = REPLACE(@sql,
        'ep.[PKIdEgresoProyectado],',
        'ep.[PKIdEgresoProyectado],'+CHAR(13)+CHAR(10)+'    ep.[FKIdEmpresa_SIS],');
    EXEC sys.sp_executesql @sql;
END;

SET @sql = OBJECT_DEFINITION(OBJECT_ID('PRES.Vw_EgresoAutorizado'));
IF @sql IS NULL THROW 51003, 'No existe PRES.Vw_EgresoAutorizado.', 1;
IF CHARINDEX('ea.[FKIdEmpresa_SIS]', @sql) = 0
BEGIN
    SET @sql = REPLACE(@sql, 'CREATE VIEW', 'CREATE OR ALTER VIEW');
    SET @sql = REPLACE(@sql,
        'ea.[PKIdEgresoAutorizado],',
        'ea.[PKIdEgresoAutorizado],'+CHAR(13)+CHAR(10)+'    ea.[FKIdEmpresa_SIS],');
    EXEC sys.sp_executesql @sql;
END;
GO

DECLARE @procedureSql NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('PRES.SP_MantenimientoEgresoAutorizado'));
IF @procedureSql IS NULL THROW 51004, 'No existe PRES.SP_MantenimientoEgresoAutorizado.', 1;

IF @procedureSql NOT LIKE '%@FKIdEmpresa_SIS%'
BEGIN
    SET @procedureSql = REPLACE(@procedureSql, 'CREATE   PROCEDURE', 'CREATE OR ALTER PROCEDURE');
    SET @procedureSql = REPLACE(@procedureSql, 'CREATE PROCEDURE', 'CREATE OR ALTER PROCEDURE');
    SET @procedureSql = REPLACE(@procedureSql,
        '@PKIdEgresoAutorizado INT = NULL,',
        '@PKIdEgresoAutorizado INT = NULL,'+CHAR(13)+CHAR(10)+'    @FKIdEmpresa_SIS INT = NULL,');

    SET @procedureSql = REPLACE(@procedureSql,
        '        IF @Action IN (1, 2)'+CHAR(13)+CHAR(10)+'        BEGIN',
        '        IF @FKIdEmpresa_SIS IS NULL OR @FKIdEmpresa_SIS <= 0'+CHAR(13)+CHAR(10)+
        '        BEGIN'+CHAR(13)+CHAR(10)+
        '            SET @Tipo = N''ERROR'';'+CHAR(13)+CHAR(10)+
        '            SET @Mensaje = N''No se recibio la empresa actual.'';'+CHAR(13)+CHAR(10)+
        '            GOTO Finish;'+CHAR(13)+CHAR(10)+
        '        END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
        '        IF NOT EXISTS ('+CHAR(13)+CHAR(10)+
        '            SELECT 1 FROM SIS.Usuario u'+CHAR(13)+CHAR(10)+
        '            WHERE u.PkIdUsuario = @IdUser AND u.Activo = 1'+CHAR(13)+CHAR(10)+
        '              AND (u.FKIdEmpresa_SIS = @FKIdEmpresa_SIS OR EXISTS ('+CHAR(13)+CHAR(10)+
        '                  SELECT 1 FROM SIS.UsuarioSucursal us'+CHAR(13)+CHAR(10)+
        '                  INNER JOIN SIS.Sucursal s ON s.PKIdSucursal = us.FKIdSucursal_SIS'+CHAR(13)+CHAR(10)+
        '                  WHERE us.FKIdUsuario_SIS = @IdUser AND us.Activo = 1 AND us.PuedeAcceder = 1'+CHAR(13)+CHAR(10)+
        '                    AND s.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND s.Activo = 1))'+CHAR(13)+CHAR(10)+
        '        )'+CHAR(13)+CHAR(10)+
        '        BEGIN'+CHAR(13)+CHAR(10)+
        '            SET @Tipo = N''ERROR'';'+CHAR(13)+CHAR(10)+
        '            SET @Mensaje = N''El usuario no tiene acceso a la empresa indicada.'';'+CHAR(13)+CHAR(10)+
        '            GOTO Finish;'+CHAR(13)+CHAR(10)+
        '        END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
        '        IF @Action = 1 AND ('+CHAR(13)+CHAR(10)+
        '            @FKIdEgresoProyectado_PRES IS NULL OR NOT EXISTS ('+CHAR(13)+CHAR(10)+
        '                SELECT 1 FROM PRES.EgresoProyectado ep'+CHAR(13)+CHAR(10)+
        '                WHERE ep.PKIdEgresoProyectado = @FKIdEgresoProyectado_PRES'+CHAR(13)+CHAR(10)+
        '                  AND ep.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND ep.Activo = 1))'+CHAR(13)+CHAR(10)+
        '        BEGIN'+CHAR(13)+CHAR(10)+
        '            SET @Tipo = N''ERROR'';'+CHAR(13)+CHAR(10)+
        '            SET @Mensaje = N''El presupuesto autorizado debe originarse en un anteproyecto activo de la empresa actual.'';'+CHAR(13)+CHAR(10)+
        '            GOTO Finish;'+CHAR(13)+CHAR(10)+
        '        END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
        '        IF @Action IN (2, 3) AND NOT EXISTS ('+CHAR(13)+CHAR(10)+
        '            SELECT 1 FROM PRES.EgresoAutorizado ea'+CHAR(13)+CHAR(10)+
        '            WHERE ea.PKIdEgresoAutorizado = @PKIdEgresoAutorizado'+CHAR(13)+CHAR(10)+
        '              AND ea.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND ea.Activo = 1)'+CHAR(13)+CHAR(10)+
        '        BEGIN'+CHAR(13)+CHAR(10)+
        '            SET @Tipo = N''ERROR'';'+CHAR(13)+CHAR(10)+
        '            SET @Mensaje = N''El presupuesto no pertenece a la empresa actual.'';'+CHAR(13)+CHAR(10)+
        '            GOTO Finish;'+CHAR(13)+CHAR(10)+
        '        END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
        '        IF @Action IN (1, 2)'+CHAR(13)+CHAR(10)+'        BEGIN');

    SET @procedureSql = REPLACE(@procedureSql,
        '            INSERT INTO PRES.EgresoAutorizado ('+CHAR(13)+CHAR(10)+'                FKIdPrograma_PRES,',
        '            INSERT INTO PRES.EgresoAutorizado ('+CHAR(13)+CHAR(10)+'                FKIdEmpresa_SIS,'+CHAR(13)+CHAR(10)+'                FKIdPrograma_PRES,');
    SET @procedureSql = REPLACE(@procedureSql,
        '            VALUES ('+CHAR(13)+CHAR(10)+'                @FKIdPrograma_PRES,',
        '            VALUES ('+CHAR(13)+CHAR(10)+'                @FKIdEmpresa_SIS,'+CHAR(13)+CHAR(10)+'                @FKIdPrograma_PRES,');
    SET @procedureSql = REPLACE(@procedureSql, '@Fk_IdEmpresa = NULL,', '@Fk_IdEmpresa = @FKIdEmpresa_SIS,');

    EXEC sys.sp_executesql @procedureSql;
END;
GO

DECLARE @guardSql NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('PRES.SP_MantenimientoEgresoAutorizado'));
IF @guardSql NOT LIKE '%El presupuesto autorizado debe originarse en un anteproyecto activo de la empresa actual.%'
BEGIN
    DECLARE @guardPosition INT = CHARINDEX('        IF @Action IN (1, 2)', @guardSql);
    IF @guardPosition = 0 THROW 51006, 'No se encontro el punto de validacion del procedimiento.', 1;

    DECLARE @guard NVARCHAR(MAX) =
        '        IF @FKIdEmpresa_SIS IS NULL OR @FKIdEmpresa_SIS <= 0'+CHAR(13)+CHAR(10)+
        '        BEGIN'+CHAR(13)+CHAR(10)+
        '            SET @Tipo = N''ERROR''; SET @Mensaje = N''No se recibio la empresa actual.''; GOTO Finish;'+CHAR(13)+CHAR(10)+
        '        END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
        '        IF NOT EXISTS ('+CHAR(13)+CHAR(10)+
        '            SELECT 1 FROM SIS.Usuario u WHERE u.PkIdUsuario = @IdUser AND u.Activo = 1'+CHAR(13)+CHAR(10)+
        '              AND (u.FKIdEmpresa_SIS = @FKIdEmpresa_SIS OR EXISTS ('+CHAR(13)+CHAR(10)+
        '                  SELECT 1 FROM SIS.UsuarioSucursal us INNER JOIN SIS.Sucursal s ON s.PKIdSucursal = us.FKIdSucursal_SIS'+CHAR(13)+CHAR(10)+
        '                  WHERE us.FKIdUsuario_SIS = @IdUser AND us.Activo = 1 AND us.PuedeAcceder = 1'+CHAR(13)+CHAR(10)+
        '                    AND s.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND s.Activo = 1)))'+CHAR(13)+CHAR(10)+
        '        BEGIN'+CHAR(13)+CHAR(10)+
        '            SET @Tipo = N''ERROR''; SET @Mensaje = N''El usuario no tiene acceso a la empresa indicada.''; GOTO Finish;'+CHAR(13)+CHAR(10)+
        '        END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
        '        IF @Action = 1 AND (@FKIdEgresoProyectado_PRES IS NULL OR NOT EXISTS ('+CHAR(13)+CHAR(10)+
        '            SELECT 1 FROM PRES.EgresoProyectado ep WHERE ep.PKIdEgresoProyectado = @FKIdEgresoProyectado_PRES'+CHAR(13)+CHAR(10)+
        '              AND ep.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND ep.Activo = 1))'+CHAR(13)+CHAR(10)+
        '        BEGIN'+CHAR(13)+CHAR(10)+
        '            SET @Tipo = N''ERROR''; SET @Mensaje = N''El presupuesto autorizado debe originarse en un anteproyecto activo de la empresa actual.''; GOTO Finish;'+CHAR(13)+CHAR(10)+
        '        END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
        '        IF @Action IN (2, 3) AND NOT EXISTS ('+CHAR(13)+CHAR(10)+
        '            SELECT 1 FROM PRES.EgresoAutorizado ea WHERE ea.PKIdEgresoAutorizado = @PKIdEgresoAutorizado'+CHAR(13)+CHAR(10)+
        '              AND ea.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND ea.Activo = 1)'+CHAR(13)+CHAR(10)+
        '        BEGIN'+CHAR(13)+CHAR(10)+
        '            SET @Tipo = N''ERROR''; SET @Mensaje = N''El presupuesto no pertenece a la empresa actual.''; GOTO Finish;'+CHAR(13)+CHAR(10)+
        '        END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10);

    SET @guardSql = STUFF(@guardSql, @guardPosition, 0, @guard);
    SET @guardSql = REPLACE(@guardSql, 'CREATE   PROCEDURE', 'CREATE OR ALTER PROCEDURE');
    SET @guardSql = REPLACE(@guardSql, 'CREATE PROCEDURE', 'CREATE OR ALTER PROCEDURE');
    EXEC sys.sp_executesql @guardSql;
END;
GO

DECLARE @duplicateSql NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('PRES.SP_MantenimientoEgresoAutorizado'));
IF @duplicateSql NOT LIKE '%Ya existe un presupuesto autorizado activo para el anteproyecto indicado.%'
BEGIN
    DECLARE @duplicatePosition INT = CHARINDEX('        IF @Action IN (1, 2)', @duplicateSql);
    IF @duplicatePosition = 0 THROW 51007, 'No se encontro el punto de control de duplicados.', 1;

    DECLARE @duplicateGuard NVARCHAR(MAX) =
        '        IF @Action = 1 AND EXISTS ('+CHAR(13)+CHAR(10)+
        '            SELECT 1 FROM PRES.EgresoAutorizado ea'+CHAR(13)+CHAR(10)+
        '            WHERE ea.FKIdEgresoProyectado_PRES = @FKIdEgresoProyectado_PRES'+CHAR(13)+CHAR(10)+
        '              AND ea.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND ea.Activo = 1)'+CHAR(13)+CHAR(10)+
        '        BEGIN'+CHAR(13)+CHAR(10)+
        '            SET @Tipo = N''ERROR''; SET @Mensaje = N''Ya existe un presupuesto autorizado activo para el anteproyecto indicado.''; GOTO Finish;'+CHAR(13)+CHAR(10)+
        '        END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10);

    SET @duplicateSql = STUFF(@duplicateSql, @duplicatePosition, 0, @duplicateGuard);
    SET @duplicateSql = REPLACE(@duplicateSql, 'CREATE   PROCEDURE', 'CREATE OR ALTER PROCEDURE');
    SET @duplicateSql = REPLACE(@duplicateSql, 'CREATE PROCEDURE', 'CREATE OR ALTER PROCEDURE');
    EXEC sys.sp_executesql @duplicateSql;
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.parameters
    WHERE object_id = OBJECT_ID('PRES.SP_MantenimientoEgresoAutorizado')
      AND name = '@FKIdEmpresa_SIS'
)
    THROW 51005, 'No se pudo actualizar el procedimiento con empresa.', 1;

SELECT
    (SELECT COUNT(*) FROM PRES.EgresoProyectado WHERE FKIdEmpresa_SIS IS NULL) AS AnteproyectosSinEmpresa,
    (SELECT COUNT(*) FROM PRES.EgresoAutorizado WHERE FKIdEmpresa_SIS IS NULL) AS AutorizadosSinEmpresa;
