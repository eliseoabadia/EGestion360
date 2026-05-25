USE [GestionEmpresarial];
GO

-- =============================================
-- STORED PROCEDURES DEL SISTEMA GestionEmpresarial
-- =============================================

-- =============================================
-- ALMA
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [ALMA].[SP_CargaInicialConteo]
    @P_Partida INT = NULL,
    @P_Periodo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ResultJson NVARCHAR(MAX);
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM [ALMA].[ConteoDetalle];
        DELETE FROM [ALMA].[Conteo];

        IF @P_Partida IS NULL
        BEGIN
            INSERT INTO [ALMA].[Conteo]
                ([FKIdTipoBien_ALMA]
                ,[CantidadInventario]
                ,[Descripcion]
                ,[FechaInicio]
                ,[Activo]
                ,[FechaCreacion]
                ,[UsuarioCreacion]
                ,FKIdPeriodoConteo_ALMA)
            SELECT
                CI.PKIdTipoBien,
                CI.Existencias,
                CI.Descripcion,
                GETDATE(),
                1,
                GETDATE(),
                1,
                @P_Periodo
            FROM
                [ALMA].[VW_Existencias] CI
                INNER JOIN [ALMA].[TipoBien] TB ON CI.PKIdTipoBien = TB.[PKIdTipoBien]
            WHERE
                TB.[FKIdPartida_CONTA] > 20000
                AND TB.[FKIdPartida_CONTA] < 30000
                AND TB.[Activo] = 1;
        END
        ELSE
        BEGIN
            IF @P_Partida <= 20000 OR @P_Partida >= 30000
            BEGIN
                SET @ResultJson = '{"tipo":"ERROR","mensaje":"Solo se permiten conteos del cap�tulo 20000. Partida no permitida: ' + CAST(@P_Partida AS NVARCHAR) + '","liga":""}';
                SELECT JSON_QUERY(@ResultJson) AS ResultJson;
                RETURN;
            END

            INSERT INTO [ALMA].[Conteo]
                ([FKIdTipoBien_ALMA]
                ,[CantidadInventario]
                ,[Descripcion]
                ,[FechaInicio]
                ,[Activo]
                ,[FechaCreacion]
                ,[UsuarioCreacion]
                ,FKIdPeriodoConteo_ALMA)
            SELECT
                CI.PKIdTipoBien,
                CI.Existencias,
                CI.Descripcion,
                GETDATE(),
                1,
                GETDATE(),
                1,
                @P_Periodo
            FROM
                [ALMA].[VW_Existencias] CI
                INNER JOIN [ALMA].[TipoBien] TB ON CI.PKIdTipoBien = TB.[PKIdTipoBien]
            WHERE
                TB.[FKIdPartida_CONTA] = @P_Partida
                AND TB.[Activo] = 1;
        END

        COMMIT TRANSACTION;

        SET @ResultJson = '{"tipo":"EXITO","mensaje":"Conteo generado correctamente","liga":""}';
        SELECT JSON_QUERY(@ResultJson) AS ResultJson;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        SET @ResultJson = '{"tipo":"ERROR","mensaje":"' + REPLACE(@ErrorMessage, '"', '\"') + '","liga":""}';
        SELECT JSON_QUERY(@ResultJson) AS ResultJson;

    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [PRES].[SP_MantenimientoAutorizacionSuficiencia] (
    @Action INT,
    @PKIdAutorizacionSuficiencia INT = NULL,
    @PKIdAutorizacionSuficienciaDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdSolicitudSuficiencia_PRES INT = NULL,
    @FechaAutorizacion DATE = NULL,
    @Justificacion NVARCHAR(1000) = NULL,
    @GastoNoProgramable VARCHAR(3) = NULL,
    @IdGastoNoProgramable INT = NULL,
    @IdCompromisoNomina INT = NULL,
    @AutorizadoPor_NOM INT = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @Estatus INT = NULL,
    @FKIdSolicitudSuficienciaDetalle_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @Enero DECIMAL(20,4) = NULL,
    @Febrero DECIMAL(20,4) = NULL,
    @Marzo DECIMAL(20,4) = NULL,
    @Abril DECIMAL(20,4) = NULL,
    @Mayo DECIMAL(20,4) = NULL,
    @Junio DECIMAL(20,4) = NULL,
    @Julio DECIMAL(20,4) = NULL,
    @Agosto DECIMAL(20,4) = NULL,
    @Septiembre DECIMAL(20,4) = NULL,
    @Octubre DECIMAL(20,4) = NULL,
    @Noviembre DECIMAL(20,4) = NULL,
    @Diciembre DECIMAL(20,4) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoAutorizacionSuficiencia]', ' @Estatus ', @Estatus);
    SET @Parameters = CONCAT(
        'Action=', @Action,
        ', PKIdAutorizacionSuficiencia=', ISNULL(CONVERT(NVARCHAR(30), @PKIdAutorizacionSuficiencia), 'NULL'),
        ', PKIdAutorizacionSuficienciaDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdAutorizacionSuficienciaDetalle), 'NULL'),
        ', FKIdSolicitudSuficiencia_PRES=', ISNULL(CONVERT(NVARCHAR(30), @FKIdSolicitudSuficiencia_PRES), 'NULL'),
        ', FechaAutorizacion=', ISNULL(CONVERT(NVARCHAR(30), @FechaAutorizacion, 126), 'NULL'),
        ', AutorizadoPor_NOM=', ISNULL(CONVERT(NVARCHAR(30), @AutorizadoPor_NOM), 'NULL'),
        ', Estatus=', ISNULL(CONVERT(NVARCHAR(30), @Estatus), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'PRES.SP_MantenimientoAutorizacionSuficiencia',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'PRES.SP_MantenimientoAutorizacionSuficiencia',
        @Parameters = @Parameters,
        @ExecutionTime = '0';
    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action IN (1, 2, 10)
        BEGIN
            IF @FKIdSolicitudSuficiencia_PRES IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.SolicitudSuficiencia WHERE PKIdSolicitudSuficiencia = @FKIdSolicitudSuficiencia_PRES AND Activo = 1)
                THROW 51000, 'Solicitud de suficiencia no encontrada.', 1;
            IF @AutorizadoPor_NOM IS NULL OR NOT EXISTS (SELECT 1 FROM NOM.Persona WHERE PKIdPersona = @AutorizadoPor_NOM AND Activo = 1)
                THROW 51000, 'La persona autorizadora no existe o esta inactiva.', 1;
        END

        IF @Action = 1
        BEGIN
            INSERT INTO PRES.AutorizacionSuficiencia (
                FKIdEmpresa_SIS, FKIdSolicitudSuficiencia_PRES, FechaAutorizacion, Justificacion,
                GastoNoProgramable, IdGastoNoProgramable, IdCompromisoNomina, AutorizadoPor_NOM,
                Observaciones, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, ss.FKIdEmpresa_SIS), ss.PKIdSolicitudSuficiencia, ISNULL(@FechaAutorizacion, CONVERT(DATE, GETDATE())),
                   ISNULL(@Justificacion, ss.Justificacion), ISNULL(@GastoNoProgramable, ss.GastoNoProgramable),
                   ISNULL(@IdGastoNoProgramable, ss.IdGastoNoProgramable), ISNULL(@IdCompromisoNomina, ss.IdCompromisoNomina),
                   @AutorizadoPor_NOM, @Observaciones, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            FROM PRES.SolicitudSuficiencia ss
            WHERE ss.PKIdSolicitudSuficiencia = @FKIdSolicitudSuficiencia_PRES;

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Autorizacion de suficiencia creada correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficiencia:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdAutorizacionSuficiencia IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.AutorizacionSuficiencia WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia AND Activo = 1)
                THROW 51000, 'Autorizacion de suficiencia no encontrada.', 1;

            UPDATE aus
            SET FKIdEmpresa_SIS = ISNULL(@FKIdEmpresa_SIS, ss.FKIdEmpresa_SIS),
                FKIdSolicitudSuficiencia_PRES = @FKIdSolicitudSuficiencia_PRES,
                FechaAutorizacion = ISNULL(@FechaAutorizacion, aus.FechaAutorizacion),
                Justificacion = ISNULL(@Justificacion, ss.Justificacion),
                GastoNoProgramable = ISNULL(@GastoNoProgramable, ss.GastoNoProgramable),
                IdGastoNoProgramable = ISNULL(@IdGastoNoProgramable, ss.IdGastoNoProgramable),
                IdCompromisoNomina = ISNULL(@IdCompromisoNomina, ss.IdCompromisoNomina),
                AutorizadoPor_NOM = @AutorizadoPor_NOM,
                Observaciones = @Observaciones,
                Estatus = ISNULL(NULLIF(@Estatus, 0), aus.Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.AutorizacionSuficiencia aus
            INNER JOIN PRES.SolicitudSuficiencia ss ON ss.PKIdSolicitudSuficiencia = @FKIdSolicitudSuficiencia_PRES
            WHERE aus.PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia;

            SET @Id = @PKIdAutorizacionSuficiencia;
            SET @message = 'Autorizacion de suficiencia actualizada correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficiencia:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdAutorizacionSuficiencia IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.AutorizacionSuficiencia WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia AND Activo = 1)
                THROW 51000, 'Autorizacion de suficiencia no encontrada.', 1;
            IF EXISTS (SELECT 1 FROM PRES.Contrato WHERE FKIdAutorizacionSuficiencia_PRES = @PKIdAutorizacionSuficiencia AND Activo = 1)
                THROW 51000, 'No se puede eliminar la autorizacion porque ya tiene contrato activo. Elimine primero el registro comprometido.', 1;

            DECLARE @FKIdSolicitudSuficienciaReactivar INT;
            SELECT @FKIdSolicitudSuficienciaReactivar = FKIdSolicitudSuficiencia_PRES
            FROM PRES.AutorizacionSuficiencia
            WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia;

            UPDATE PRES.AutorizacionSuficienciaDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdAutorizacionSuficiencia_PRES = @PKIdAutorizacionSuficiencia AND Activo = 1;
            UPDATE PRES.AutorizacionSuficiencia SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia;
            UPDATE PRES.SolicitudSuficiencia
            SET Estatus = 1, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE PKIdSolicitudSuficiencia = @FKIdSolicitudSuficienciaReactivar AND Activo = 1;

            SET @Id = @PKIdAutorizacionSuficiencia;
            SET @message = 'Autorizacion de suficiencia eliminada correctamente. La solicitud regreso a la etapa anterior.';
            SET @liga = CONCAT('idAutorizacionSuficiencia:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT * FROM PRES.Vw_AutorizacionSuficiencia WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia;
            SET @message = 'Autorizacion de suficiencia consultada correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficiencia:', @PKIdAutorizacionSuficiencia);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdAutorizacionSuficiencia IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.AutorizacionSuficiencia WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia AND Activo = 1)
                THROW 51000, 'Autorizacion de suficiencia no encontrada.', 1;
            IF @FKIdSolicitudSuficienciaDetalle_PRES IS NULL OR NOT EXISTS (
                SELECT 1
                FROM PRES.SolicitudSuficienciaDetalle ssd
                INNER JOIN PRES.AutorizacionSuficiencia aus ON aus.PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia
                WHERE ssd.PKIdSolicitudSuficienciaDetalle = @FKIdSolicitudSuficienciaDetalle_PRES
                  AND ssd.FKIdSolicitudSuficiencia_PRES = aus.FKIdSolicitudSuficiencia_PRES
                  AND ssd.Activo = 1
            )
                THROW 51000, 'Detalle de solicitud de suficiencia no encontrado o no pertenece a la autorizacion.', 1;

            INSERT INTO PRES.AutorizacionSuficienciaDetalle (
                FKIdEmpresa_SIS, FKIdAutorizacionSuficiencia_PRES, FKIdSolicitudSuficienciaDetalle_PRES, FKIdPartida_CONTA,
                Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
                Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, aus.FKIdEmpresa_SIS), @PKIdAutorizacionSuficiencia, @FKIdSolicitudSuficienciaDetalle_PRES, @FKIdPartida_CONTA,
                   ISNULL(@Enero, 0), ISNULL(@Febrero, 0), ISNULL(@Marzo, 0), ISNULL(@Abril, 0), ISNULL(@Mayo, 0), ISNULL(@Junio, 0),
                   ISNULL(@Julio, 0), ISNULL(@Agosto, 0), ISNULL(@Septiembre, 0), ISNULL(@Octubre, 0), ISNULL(@Noviembre, 0), ISNULL(@Diciembre, 0),
                   @Observaciones, 1, @today, @IdUser
            FROM PRES.AutorizacionSuficiencia aus
            WHERE aus.PKIdAutorizacionSuficiencia = @PKIdAutorizacionSuficiencia;

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Detalle de autorizacion de suficiencia creado correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficienciaDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdAutorizacionSuficienciaDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.AutorizacionSuficienciaDetalle WHERE PKIdAutorizacionSuficienciaDetalle = @PKIdAutorizacionSuficienciaDetalle AND Activo = 1)
                THROW 51000, 'Detalle de autorizacion de suficiencia no encontrado.', 1;
            IF EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE FKIdAutorizacionSuficienciaDetalle_PRES = @PKIdAutorizacionSuficienciaDetalle AND Activo = 1)
                THROW 51000, 'No se puede modificar el detalle porque ya esta ligado a un contrato.', 1;

            UPDATE PRES.AutorizacionSuficienciaDetalle
            SET FKIdSolicitudSuficienciaDetalle_PRES = @FKIdSolicitudSuficienciaDetalle_PRES,
                FKIdPartida_CONTA = @FKIdPartida_CONTA,
                Enero = ISNULL(@Enero, 0), Febrero = ISNULL(@Febrero, 0), Marzo = ISNULL(@Marzo, 0), Abril = ISNULL(@Abril, 0),
                Mayo = ISNULL(@Mayo, 0), Junio = ISNULL(@Junio, 0), Julio = ISNULL(@Julio, 0), Agosto = ISNULL(@Agosto, 0),
                Septiembre = ISNULL(@Septiembre, 0), Octubre = ISNULL(@Octubre, 0), Noviembre = ISNULL(@Noviembre, 0), Diciembre = ISNULL(@Diciembre, 0),
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdAutorizacionSuficienciaDetalle = @PKIdAutorizacionSuficienciaDetalle;

            SET @Id = @PKIdAutorizacionSuficienciaDetalle;
            SET @message = 'Detalle de autorizacion de suficiencia actualizado correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficienciaDetalle:', @Id);
        END
        ELSE IF @Action = 7
        BEGIN
            IF @PKIdAutorizacionSuficienciaDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.AutorizacionSuficienciaDetalle WHERE PKIdAutorizacionSuficienciaDetalle = @PKIdAutorizacionSuficienciaDetalle AND Activo = 1)
                THROW 51000, 'Detalle de autorizacion de suficiencia no encontrado.', 1;
            IF EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE FKIdAutorizacionSuficienciaDetalle_PRES = @PKIdAutorizacionSuficienciaDetalle AND Activo = 1)
                THROW 51000, 'No se puede eliminar el detalle porque ya esta ligado a un contrato.', 1;

            UPDATE PRES.AutorizacionSuficienciaDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdAutorizacionSuficienciaDetalle = @PKIdAutorizacionSuficienciaDetalle;
            SET @Id = @PKIdAutorizacionSuficienciaDetalle;
            SET @message = 'Detalle de autorizacion de suficiencia eliminado correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficienciaDetalle:', @Id);
        END
        ELSE IF @Action = 8
        BEGIN
            SELECT * FROM PRES.Vw_AutorizacionSuficienciaDetalle WHERE PKIdAutorizacionSuficienciaDetalle = @PKIdAutorizacionSuficienciaDetalle;
            SET @message = 'Detalle de autorizacion de suficiencia consultado correctamente.';
            SET @liga = CONCAT('idAutorizacionSuficienciaDetalle:', @PKIdAutorizacionSuficienciaDetalle);
        END
        ELSE IF @Action = 10
        BEGIN
            IF EXISTS (SELECT 1 FROM PRES.AutorizacionSuficiencia WHERE FKIdSolicitudSuficiencia_PRES = @FKIdSolicitudSuficiencia_PRES AND Activo = 1)
                THROW 51000, 'Ya existe una autorizacion de suficiencia activa para esta solicitud.', 1;
            IF NOT EXISTS (SELECT 1 FROM PRES.SolicitudSuficienciaDetalle WHERE FKIdSolicitudSuficiencia_PRES = @FKIdSolicitudSuficiencia_PRES AND Activo = 1)
                THROW 51000, 'La solicitud no tiene detalle para autorizar.', 1;

            INSERT INTO PRES.AutorizacionSuficiencia (
                FKIdEmpresa_SIS, FKIdSolicitudSuficiencia_PRES, FechaAutorizacion, Justificacion,
                GastoNoProgramable, IdGastoNoProgramable, IdCompromisoNomina, AutorizadoPor_NOM,
                Observaciones, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, ss.FKIdEmpresa_SIS), ss.PKIdSolicitudSuficiencia, ISNULL(@FechaAutorizacion, CONVERT(DATE, GETDATE())),
                   ISNULL(@Justificacion, ss.Justificacion), ISNULL(@GastoNoProgramable, ss.GastoNoProgramable),
                   ISNULL(@IdGastoNoProgramable, ss.IdGastoNoProgramable), ISNULL(@IdCompromisoNomina, ss.IdCompromisoNomina),
                   @AutorizadoPor_NOM, ISNULL(@Observaciones, CONCAT('Autorizada desde solicitud ', ss.PKIdSolicitudSuficiencia)),
                   ISNULL(NULLIF(@Estatus, 0), 2), 1, @today, @IdUser
            FROM PRES.SolicitudSuficiencia ss
            WHERE ss.PKIdSolicitudSuficiencia = @FKIdSolicitudSuficiencia_PRES;

            SET @Id = SCOPE_IDENTITY();

            INSERT INTO PRES.AutorizacionSuficienciaDetalle (
                FKIdEmpresa_SIS, FKIdAutorizacionSuficiencia_PRES, FKIdSolicitudSuficienciaDetalle_PRES, FKIdPartida_CONTA,
                Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
                Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ssd.FKIdEmpresa_SIS, @Id, ssd.PKIdSolicitudSuficienciaDetalle, ssd.FKIdPartida_CONTA,
                   ISNULL(ssd.Enero, 0), ISNULL(ssd.Febrero, 0), ISNULL(ssd.Marzo, 0), ISNULL(ssd.Abril, 0),
                   ISNULL(ssd.Mayo, 0), ISNULL(ssd.Junio, 0), ISNULL(ssd.Julio, 0), ISNULL(ssd.Agosto, 0),
                   ISNULL(ssd.Septiembre, 0), ISNULL(ssd.Octubre, 0), ISNULL(ssd.Noviembre, 0), ISNULL(ssd.Diciembre, 0),
                   ssd.Observaciones, 1, @today, @IdUser
            FROM PRES.SolicitudSuficienciaDetalle ssd
            WHERE ssd.FKIdSolicitudSuficiencia_PRES = @FKIdSolicitudSuficiencia_PRES
              AND ssd.Activo = 1;

            UPDATE PRES.SolicitudSuficiencia
            SET Estatus = 3,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdSolicitudSuficiencia = @FKIdSolicitudSuficiencia_PRES;

            SET @message = 'Autorizacion de suficiencia generada correctamente desde solicitud.';
            SET @liga = CONCAT('idAutorizacionSuficiencia:', @Id);
        END
        ELSE
            THROW 51000, 'Accion no valida para autorizacion de suficiencia.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [PRES].[SP_MantenimientoContrato] (
    @Action INT,
    @PKIdContrato INT = NULL,
    @PKIdContratoDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdAutorizacionSuficiencia_PRES INT = NULL,
    @FKIdProveedor_SIS INT = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @NumeroContrato NVARCHAR(50) = NULL,
    @Descripcion NVARCHAR(500) = NULL,
    @FechaContrato DATE = NULL,
    @FechaInicioVigencia DATE = NULL,
    @FechaFinVigencia DATE = NULL,
    @MontoTotal DECIMAL(20,4) = NULL,
    @PlazoEjecucion NVARCHAR(100) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @Estatus INT = NULL,
    @FKIdAutorizacionSuficienciaDetalle_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @Enero DECIMAL(20,4) = NULL,
    @Febrero DECIMAL(20,4) = NULL,
    @Marzo DECIMAL(20,4) = NULL,
    @Abril DECIMAL(20,4) = NULL,
    @Mayo DECIMAL(20,4) = NULL,
    @Junio DECIMAL(20,4) = NULL,
    @Julio DECIMAL(20,4) = NULL,
    @Agosto DECIMAL(20,4) = NULL,
    @Septiembre DECIMAL(20,4) = NULL,
    @Octubre DECIMAL(20,4) = NULL,
    @Noviembre DECIMAL(20,4) = NULL,
    @Diciembre DECIMAL(20,4) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoContrato]', ' @PKIdContrato ', @PKIdContrato);
    SET @Parameters = CONCAT('Action=', @Action, ', PKIdContrato=', ISNULL(CONVERT(NVARCHAR(30), @PKIdContrato), 'NULL'), ', PKIdContratoDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdContratoDetalle), 'NULL'), ', NumeroContrato=', ISNULL(@NumeroContrato, 'NULL'), ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL'));
    EXEC [SIS].[WriteSystemLog] @FK_IdOrigenLogMessage__SIS = 1, @Date = @today, @_Type = 1, @ProgName = 'PRES.SP_MantenimientoContrato', @EmployeeNo = @IdUser, @Category = NULL, @IPClient = NULL, @HostName = NULL, @Thread = NULL, @Level = 'INFO', @Logger = NULL, @Message = @message, @Exception = NULL, @Context = NULL, @MethodName = 'PRES.SP_MantenimientoContrato', @Parameters = @Parameters, @ExecutionTime = '0';
    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF @FechaFinVigencia IS NOT NULL AND @FechaInicioVigencia IS NOT NULL AND @FechaFinVigencia < @FechaInicioVigencia
                THROW 51000, 'La fecha fin de vigencia no puede ser anterior al inicio.', 1;

            INSERT INTO PRES.Contrato (
                FKIdEmpresa_SIS, FKIdAutorizacionSuficiencia_PRES, FKIdProveedor_SIS, FKIdPoliza_CONTA,
                NumeroContrato, Descripcion, FechaContrato, FechaInicioVigencia, FechaFinVigencia,
                MontoTotal, PlazoEjecucion, Observaciones, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdAutorizacionSuficiencia_PRES, @FKIdProveedor_SIS, @FKIdPoliza_CONTA,
                @NumeroContrato, @Descripcion, ISNULL(@FechaContrato, CONVERT(DATE, GETDATE())), @FechaInicioVigencia, @FechaFinVigencia,
                ISNULL(@MontoTotal, 0), @PlazoEjecucion, @Observaciones, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            );
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Contrato creado correctamente.';
            SET @liga = CONCAT('idContrato:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdContrato IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Contrato WHERE PKIdContrato = @PKIdContrato AND Activo = 1)
                THROW 51000, 'Contrato no encontrado.', 1;
            IF @FechaFinVigencia IS NOT NULL AND @FechaInicioVigencia IS NOT NULL AND @FechaFinVigencia < @FechaInicioVigencia
                THROW 51000, 'La fecha fin de vigencia no puede ser anterior al inicio.', 1;

            UPDATE PRES.Contrato
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdAutorizacionSuficiencia_PRES = @FKIdAutorizacionSuficiencia_PRES,
                FKIdProveedor_SIS = @FKIdProveedor_SIS,
                FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                NumeroContrato = @NumeroContrato,
                Descripcion = @Descripcion,
                FechaContrato = ISNULL(@FechaContrato, FechaContrato),
                FechaInicioVigencia = @FechaInicioVigencia,
                FechaFinVigencia = @FechaFinVigencia,
                MontoTotal = ISNULL(@MontoTotal, 0),
                PlazoEjecucion = @PlazoEjecucion,
                Observaciones = @Observaciones,
                Estatus = ISNULL(NULLIF(@Estatus, 0), Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdContrato = @PKIdContrato;
            SET @Id = @PKIdContrato;
            SET @message = 'Contrato actualizado correctamente.';
            SET @liga = CONCAT('idContrato:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdContrato IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Contrato WHERE PKIdContrato = @PKIdContrato AND Activo = 1)
                THROW 51000, 'Contrato no encontrado.', 1;
            IF EXISTS (SELECT 1 FROM PRES.Factura WHERE FKIdContrato_PRES = @PKIdContrato AND Activo = 1)
                THROW 51000, 'No se puede eliminar el contrato porque ya tiene factura activa. Elimine primero la recepcion de factura.', 1;

            DECLARE @FKIdAutorizacionReactivar INT;
            SELECT @FKIdAutorizacionReactivar = FKIdAutorizacionSuficiencia_PRES
            FROM PRES.Contrato
            WHERE PKIdContrato = @PKIdContrato;

            UPDATE PRES.ContratoDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdContrato_PRES = @PKIdContrato AND Activo = 1;
            UPDATE PRES.Contrato SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdContrato = @PKIdContrato;
            UPDATE PRES.AutorizacionSuficiencia
            SET Estatus = 2, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE PKIdAutorizacionSuficiencia = @FKIdAutorizacionReactivar AND Activo = 1;

            SET @Id = @PKIdContrato;
            SET @message = 'Contrato eliminado correctamente. La autorizacion regreso a la etapa anterior.';
            SET @liga = CONCAT('idContrato:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT * FROM PRES.Vw_Contrato WHERE PKIdContrato = @PKIdContrato;
            SET @message = 'Contrato consultado correctamente.';
            SET @liga = CONCAT('idContrato:', @PKIdContrato);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdContrato IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Contrato WHERE PKIdContrato = @PKIdContrato AND Activo = 1)
                THROW 51000, 'Contrato no encontrado.', 1;

            INSERT INTO PRES.ContratoDetalle (
                FKIdEmpresa_SIS, FKIdContrato_PRES, FKIdAutorizacionSuficienciaDetalle_PRES, FKIdPartida_CONTA,
                Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
                Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, c.FKIdEmpresa_SIS), @PKIdContrato, @FKIdAutorizacionSuficienciaDetalle_PRES, @FKIdPartida_CONTA,
                   ISNULL(@Enero,0), ISNULL(@Febrero,0), ISNULL(@Marzo,0), ISNULL(@Abril,0), ISNULL(@Mayo,0), ISNULL(@Junio,0),
                   ISNULL(@Julio,0), ISNULL(@Agosto,0), ISNULL(@Septiembre,0), ISNULL(@Octubre,0), ISNULL(@Noviembre,0), ISNULL(@Diciembre,0),
                   @Observaciones, 1, @today, @IdUser
            FROM PRES.Contrato c
            WHERE c.PKIdContrato = @PKIdContrato;
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Detalle de contrato creado correctamente.';
            SET @liga = CONCAT('idContratoDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdContratoDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE PKIdContratoDetalle = @PKIdContratoDetalle AND Activo = 1)
                THROW 51000, 'Detalle de contrato no encontrado.', 1;

            UPDATE PRES.ContratoDetalle
            SET FKIdAutorizacionSuficienciaDetalle_PRES = @FKIdAutorizacionSuficienciaDetalle_PRES,
                FKIdPartida_CONTA = @FKIdPartida_CONTA,
                Enero = ISNULL(@Enero,0), Febrero = ISNULL(@Febrero,0), Marzo = ISNULL(@Marzo,0), Abril = ISNULL(@Abril,0),
                Mayo = ISNULL(@Mayo,0), Junio = ISNULL(@Junio,0), Julio = ISNULL(@Julio,0), Agosto = ISNULL(@Agosto,0),
                Septiembre = ISNULL(@Septiembre,0), Octubre = ISNULL(@Octubre,0), Noviembre = ISNULL(@Noviembre,0), Diciembre = ISNULL(@Diciembre,0),
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdContratoDetalle = @PKIdContratoDetalle;
            SET @Id = @PKIdContratoDetalle;
            SET @message = 'Detalle de contrato actualizado correctamente.';
            SET @liga = CONCAT('idContratoDetalle:', @Id);
        END
        ELSE IF @Action = 7
        BEGIN
            IF @PKIdContratoDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE PKIdContratoDetalle = @PKIdContratoDetalle AND Activo = 1)
                THROW 51000, 'Detalle de contrato no encontrado.', 1;
            UPDATE PRES.ContratoDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdContratoDetalle = @PKIdContratoDetalle;
            SET @Id = @PKIdContratoDetalle;
            SET @message = 'Detalle de contrato eliminado correctamente.';
            SET @liga = CONCAT('idContratoDetalle:', @Id);
        END
        ELSE IF @Action = 8
        BEGIN
            SELECT * FROM PRES.Vw_ContratoDetalle WHERE PKIdContratoDetalle = @PKIdContratoDetalle;
            SET @message = 'Detalle de contrato consultado correctamente.';
            SET @liga = CONCAT('idContratoDetalle:', @PKIdContratoDetalle);
        END
        ELSE
            THROW 51000, 'Accion no valida para contrato.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [PRES].[SP_MantenimientoFactura] (
    @Action INT,
    @PKIdFactura INT = NULL,
    @PKIdFacturaDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdContrato_PRES INT = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @NumFactura NVARCHAR(250) = NULL,
    @SerieFactura NVARCHAR(20) = NULL,
    @FechaEmision DATE = NULL,
    @FechaRecepcion DATE = NULL,
    @Subtotal DECIMAL(20,4) = NULL,
    @IVA DECIMAL(20,4) = NULL,
    @Retencion DECIMAL(20,4) = NULL,
    @Total DECIMAL(20,4) = NULL,
    @UUID NVARCHAR(36) = NULL,
    @FL_Docto NVARCHAR(1000) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @Estatus INT = NULL,
    @FKIdContratoDetalle_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @MontoAplicado DECIMAL(20,4) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoFactura]', ' @PKIdFactura ', @PKIdFactura);
    SET @Parameters = CONCAT('Action=', @Action, ', PKIdFactura=', ISNULL(CONVERT(NVARCHAR(30), @PKIdFactura), 'NULL'), ', PKIdFacturaDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdFacturaDetalle), 'NULL'), ', NumFactura=', ISNULL(@NumFactura, 'NULL'), ', Total=', ISNULL(CONVERT(NVARCHAR(30), @Total), 'NULL'), ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL'));
    EXEC [SIS].[WriteSystemLog] @FK_IdOrigenLogMessage__SIS = 1, @Date = @today, @_Type = 1, @ProgName = 'PRES.SP_MantenimientoFactura', @EmployeeNo = @IdUser, @Category = NULL, @IPClient = NULL, @HostName = NULL, @Thread = NULL, @Level = 'INFO', @Logger = NULL, @Message = @message, @Exception = NULL, @Context = NULL, @MethodName = 'PRES.SP_MantenimientoFactura', @Parameters = @Parameters, @ExecutionTime = '0';
    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF @Total IS NULL
                SET @Total = ISNULL(@Subtotal, 0) + ISNULL(@IVA, 0) - ISNULL(@Retencion, 0);

            INSERT INTO PRES.Factura (
                FKIdEmpresa_SIS, FKIdContrato_PRES, FKIdPoliza_CONTA, NumFactura, SerieFactura,
                FechaEmision, FechaRecepcion, Subtotal, IVA, Retencion, Total, UUID, FL_Docto,
                Observaciones, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdContrato_PRES, @FKIdPoliza_CONTA, @NumFactura, @SerieFactura,
                ISNULL(@FechaEmision, CONVERT(DATE, GETDATE())), @FechaRecepcion, ISNULL(@Subtotal, 0),
                ISNULL(@IVA, 0), ISNULL(@Retencion, 0), @Total, @UUID, @FL_Docto,
                @Observaciones, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            );
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Factura creada correctamente.';
            SET @liga = CONCAT('idFactura:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdFactura IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Factura WHERE PKIdFactura = @PKIdFactura AND Activo = 1)
                THROW 51000, 'Factura no encontrada.', 1;
            IF @Total IS NULL
                SET @Total = ISNULL(@Subtotal, 0) + ISNULL(@IVA, 0) - ISNULL(@Retencion, 0);

            UPDATE PRES.Factura
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdContrato_PRES = @FKIdContrato_PRES,
                FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                NumFactura = @NumFactura,
                SerieFactura = @SerieFactura,
                FechaEmision = ISNULL(@FechaEmision, FechaEmision),
                FechaRecepcion = @FechaRecepcion,
                Subtotal = ISNULL(@Subtotal, 0),
                IVA = ISNULL(@IVA, 0),
                Retencion = ISNULL(@Retencion, 0),
                Total = @Total,
                UUID = @UUID,
                FL_Docto = @FL_Docto,
                Observaciones = @Observaciones,
                Estatus = ISNULL(NULLIF(@Estatus, 0), Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdFactura = @PKIdFactura;
            SET @Id = @PKIdFactura;
            SET @message = 'Factura actualizada correctamente.';
            SET @liga = CONCAT('idFactura:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdFactura IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Factura WHERE PKIdFactura = @PKIdFactura AND Activo = 1)
                THROW 51000, 'Factura no encontrada.', 1;
            IF EXISTS (
                SELECT 1
                FROM PRES.CLCFactura cf
                INNER JOIN PRES.CLC c ON c.PKIdCLC = cf.FKIdCLC_PRES AND c.Activo = 1
                WHERE cf.FKIdFactura_PRES = @PKIdFactura AND cf.Activo = 1
            )
                THROW 51000, 'No se puede eliminar la factura porque ya tiene provision de pago activa. Elimine primero la CLC.', 1;

            DECLARE @FKIdContratoReactivar INT;
            SELECT @FKIdContratoReactivar = FKIdContrato_PRES
            FROM PRES.Factura
            WHERE PKIdFactura = @PKIdFactura;

            UPDATE PRES.FacturaDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdFactura_PRES = @PKIdFactura AND Activo = 1;
            UPDATE PRES.Factura SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdFactura = @PKIdFactura;
            UPDATE PRES.Contrato
            SET Estatus = 1, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE PKIdContrato = @FKIdContratoReactivar AND Activo = 1;

            SET @Id = @PKIdFactura;
            SET @message = 'Factura eliminada correctamente. El contrato regreso a la etapa anterior.';
            SET @liga = CONCAT('idFactura:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT * FROM PRES.Vw_Factura WHERE PKIdFactura = @PKIdFactura;
            SET @message = 'Factura consultada correctamente.';
            SET @liga = CONCAT('idFactura:', @PKIdFactura);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdFactura IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Factura WHERE PKIdFactura = @PKIdFactura AND Activo = 1)
                THROW 51000, 'Factura no encontrada.', 1;
            IF @FKIdContratoDetalle_PRES IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE PKIdContratoDetalle = @FKIdContratoDetalle_PRES AND Activo = 1)
                THROW 51000, 'Detalle de contrato no encontrado.', 1;
            IF ISNULL(@MontoAplicado, 0) <= 0
                THROW 51000, 'El monto aplicado debe ser mayor a cero.', 1;

            INSERT INTO PRES.FacturaDetalle (
                FKIdEmpresa_SIS, FKIdFactura_PRES, FKIdContratoDetalle_PRES, FKIdPartida_CONTA,
                MontoAplicado, Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, f.FKIdEmpresa_SIS), @PKIdFactura, @FKIdContratoDetalle_PRES,
                   ISNULL(@FKIdPartida_CONTA, cd.FKIdPartida_CONTA), @MontoAplicado, @Observaciones, 1, @today, @IdUser
            FROM PRES.Factura f
            INNER JOIN PRES.ContratoDetalle cd ON cd.PKIdContratoDetalle = @FKIdContratoDetalle_PRES
            WHERE f.PKIdFactura = @PKIdFactura;
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Detalle de factura creado correctamente.';
            SET @liga = CONCAT('idFacturaDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdFacturaDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.FacturaDetalle WHERE PKIdFacturaDetalle = @PKIdFacturaDetalle AND Activo = 1)
                THROW 51000, 'Detalle de factura no encontrado.', 1;
            IF ISNULL(@MontoAplicado, 0) <= 0
                THROW 51000, 'El monto aplicado debe ser mayor a cero.', 1;

            UPDATE fd
            SET FKIdContratoDetalle_PRES = @FKIdContratoDetalle_PRES,
                FKIdPartida_CONTA = ISNULL(@FKIdPartida_CONTA, cd.FKIdPartida_CONTA),
                MontoAplicado = @MontoAplicado,
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.FacturaDetalle fd
            INNER JOIN PRES.ContratoDetalle cd ON cd.PKIdContratoDetalle = @FKIdContratoDetalle_PRES AND cd.Activo = 1
            WHERE fd.PKIdFacturaDetalle = @PKIdFacturaDetalle;
            SET @Id = @PKIdFacturaDetalle;
            SET @message = 'Detalle de factura actualizado correctamente.';
            SET @liga = CONCAT('idFacturaDetalle:', @Id);
        END
        ELSE IF @Action = 7
        BEGIN
            IF @PKIdFacturaDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.FacturaDetalle WHERE PKIdFacturaDetalle = @PKIdFacturaDetalle AND Activo = 1)
                THROW 51000, 'Detalle de factura no encontrado.', 1;
            UPDATE PRES.FacturaDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdFacturaDetalle = @PKIdFacturaDetalle;
            SET @Id = @PKIdFacturaDetalle;
            SET @message = 'Detalle de factura eliminado correctamente.';
            SET @liga = CONCAT('idFacturaDetalle:', @Id);
        END
        ELSE IF @Action = 8
        BEGIN
            SELECT * FROM PRES.Vw_FacturaDetalle WHERE PKIdFacturaDetalle = @PKIdFacturaDetalle;
            SET @message = 'Detalle de factura consultado correctamente.';
            SET @liga = CONCAT('idFacturaDetalle:', @PKIdFacturaDetalle);
        END
        ELSE
            THROW 51000, 'Accion no valida para factura.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [PRES].[SP_MantenimientoCLC] (
    @Action INT,
    @PKIdCLC INT = NULL,
    @PKIdCLCDetalle INT = NULL,
    @PKIdCLCFactura INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdContrato_PRES INT = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @NumCLC NVARCHAR(20) = NULL,
    @FechaSolicitud DATE = NULL,
    @FechaAutorizacion DATE = NULL,
    @ImporteTotal DECIMAL(20,4) = NULL,
    @Observaciones NVARCHAR(500) = NULL,
    @Estatus INT = NULL,
    @FKIdContratoDetalle_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @Enero DECIMAL(20,4) = NULL,
    @Febrero DECIMAL(20,4) = NULL,
    @Marzo DECIMAL(20,4) = NULL,
    @Abril DECIMAL(20,4) = NULL,
    @Mayo DECIMAL(20,4) = NULL,
    @Junio DECIMAL(20,4) = NULL,
    @Julio DECIMAL(20,4) = NULL,
    @Agosto DECIMAL(20,4) = NULL,
    @Septiembre DECIMAL(20,4) = NULL,
    @Octubre DECIMAL(20,4) = NULL,
    @Noviembre DECIMAL(20,4) = NULL,
    @Diciembre DECIMAL(20,4) = NULL,
    @FKIdFactura_PRES INT = NULL,
    @FKIdFacturaDetalle_PRES INT = NULL,
    @MontoAplicado DECIMAL(20,4) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoCLC]', ' @PKIdCLC ', @PKIdCLC);
    SET @Parameters = CONCAT('Action=', @Action, ', PKIdCLC=', ISNULL(CONVERT(NVARCHAR(30), @PKIdCLC), 'NULL'), ', PKIdCLCDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdCLCDetalle), 'NULL'), ', PKIdCLCFactura=', ISNULL(CONVERT(NVARCHAR(30), @PKIdCLCFactura), 'NULL'), ', NumCLC=', ISNULL(@NumCLC, 'NULL'), ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL'));
    EXEC [SIS].[WriteSystemLog] @FK_IdOrigenLogMessage__SIS = 1, @Date = @today, @_Type = 1, @ProgName = 'PRES.SP_MantenimientoCLC', @EmployeeNo = @IdUser, @Category = NULL, @IPClient = NULL, @HostName = NULL, @Thread = NULL, @Level = 'INFO', @Logger = NULL, @Message = @message, @Exception = NULL, @Context = NULL, @MethodName = 'PRES.SP_MantenimientoCLC', @Parameters = @Parameters, @ExecutionTime = '0';
    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            INSERT INTO PRES.CLC (
                FKIdEmpresa_SIS, FKIdContrato_PRES, FKIdPoliza_CONTA, NumCLC, FechaSolicitud,
                FechaAutorizacion, ImporteTotal, Observaciones, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdContrato_PRES, @FKIdPoliza_CONTA, @NumCLC, ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE())),
                @FechaAutorizacion, ISNULL(@ImporteTotal, 0), @Observaciones, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            );
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'CLC creada correctamente.';
            SET @liga = CONCAT('idCLC:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdCLC IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLC WHERE PKIdCLC = @PKIdCLC AND Activo = 1)
                THROW 51000, 'CLC no encontrada.', 1;

            UPDATE PRES.CLC
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdContrato_PRES = @FKIdContrato_PRES,
                FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                NumCLC = @NumCLC,
                FechaSolicitud = ISNULL(@FechaSolicitud, FechaSolicitud),
                FechaAutorizacion = @FechaAutorizacion,
                ImporteTotal = ISNULL(@ImporteTotal, 0),
                Observaciones = @Observaciones,
                Estatus = ISNULL(NULLIF(@Estatus, 0), Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdCLC = @PKIdCLC;
            SET @Id = @PKIdCLC;
            SET @message = 'CLC actualizada correctamente.';
            SET @liga = CONCAT('idCLC:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdCLC IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLC WHERE PKIdCLC = @PKIdCLC AND Activo = 1)
                THROW 51000, 'CLC no encontrada.', 1;
            IF EXISTS (SELECT 1 FROM PRES.Cheque WHERE FKIdCLC_PRES = @PKIdCLC AND Activo = 1)
                THROW 51000, 'No se puede eliminar la CLC porque ya tiene cheque o transferencia activa. Elimine primero el cheque o transferencia.', 1;

            DECLARE @FacturasReactivar TABLE (PKIdFactura INT PRIMARY KEY);
            INSERT INTO @FacturasReactivar (PKIdFactura)
            SELECT DISTINCT FKIdFactura_PRES
            FROM PRES.CLCFactura
            WHERE FKIdCLC_PRES = @PKIdCLC AND Activo = 1 AND FKIdFactura_PRES IS NOT NULL;

            UPDATE PRES.CLCFactura SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdCLC_PRES = @PKIdCLC AND Activo = 1;
            UPDATE PRES.CLCDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdCLC_PRES = @PKIdCLC AND Activo = 1;
            UPDATE PRES.CLC SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdCLC = @PKIdCLC;
            UPDATE f
            SET Estatus = 1, FechaModificacion = @today, UsuarioModificacion = @IdUser
            FROM PRES.Factura f
            INNER JOIN @FacturasReactivar fr ON fr.PKIdFactura = f.PKIdFactura
            WHERE f.Activo = 1;

            SET @Id = @PKIdCLC;
            SET @message = 'CLC eliminada correctamente. La factura regreso a la etapa anterior.';
            SET @liga = CONCAT('idCLC:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT * FROM PRES.Vw_CLC WHERE PKIdCLC = @PKIdCLC;
            SET @message = 'CLC consultada correctamente.';
            SET @liga = CONCAT('idCLC:', @PKIdCLC);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdCLC IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLC WHERE PKIdCLC = @PKIdCLC AND Activo = 1)
                THROW 51000, 'CLC no encontrada.', 1;
            IF @FKIdContratoDetalle_PRES IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ContratoDetalle WHERE PKIdContratoDetalle = @FKIdContratoDetalle_PRES AND Activo = 1)
                THROW 51000, 'Detalle de contrato no encontrado.', 1;

            INSERT INTO PRES.CLCDetalle (
                FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdContratoDetalle_PRES, FKIdPartida_CONTA,
                Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
                Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, clc.FKIdEmpresa_SIS), @PKIdCLC, @FKIdContratoDetalle_PRES,
                   ISNULL(@FKIdPartida_CONTA, cd.FKIdPartida_CONTA), ISNULL(@Enero,0), ISNULL(@Febrero,0), ISNULL(@Marzo,0),
                   ISNULL(@Abril,0), ISNULL(@Mayo,0), ISNULL(@Junio,0), ISNULL(@Julio,0), ISNULL(@Agosto,0),
                   ISNULL(@Septiembre,0), ISNULL(@Octubre,0), ISNULL(@Noviembre,0), ISNULL(@Diciembre,0),
                   @Observaciones, 1, @today, @IdUser
            FROM PRES.CLC clc
            INNER JOIN PRES.ContratoDetalle cd ON cd.PKIdContratoDetalle = @FKIdContratoDetalle_PRES
            WHERE clc.PKIdCLC = @PKIdCLC;
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Detalle de CLC creado correctamente.';
            SET @liga = CONCAT('idCLCDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdCLCDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLCDetalle WHERE PKIdCLCDetalle = @PKIdCLCDetalle AND Activo = 1)
                THROW 51000, 'Detalle de CLC no encontrado.', 1;

            UPDATE cd
            SET FKIdContratoDetalle_PRES = @FKIdContratoDetalle_PRES,
                FKIdPartida_CONTA = ISNULL(@FKIdPartida_CONTA, ctd.FKIdPartida_CONTA),
                Enero = ISNULL(@Enero,0), Febrero = ISNULL(@Febrero,0), Marzo = ISNULL(@Marzo,0), Abril = ISNULL(@Abril,0),
                Mayo = ISNULL(@Mayo,0), Junio = ISNULL(@Junio,0), Julio = ISNULL(@Julio,0), Agosto = ISNULL(@Agosto,0),
                Septiembre = ISNULL(@Septiembre,0), Octubre = ISNULL(@Octubre,0), Noviembre = ISNULL(@Noviembre,0), Diciembre = ISNULL(@Diciembre,0),
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.CLCDetalle cd
            INNER JOIN PRES.ContratoDetalle ctd ON ctd.PKIdContratoDetalle = @FKIdContratoDetalle_PRES AND ctd.Activo = 1
            WHERE cd.PKIdCLCDetalle = @PKIdCLCDetalle;
            SET @Id = @PKIdCLCDetalle;
            SET @message = 'Detalle de CLC actualizado correctamente.';
            SET @liga = CONCAT('idCLCDetalle:', @Id);
        END
        ELSE IF @Action = 7
        BEGIN
            IF @PKIdCLCDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLCDetalle WHERE PKIdCLCDetalle = @PKIdCLCDetalle AND Activo = 1)
                THROW 51000, 'Detalle de CLC no encontrado.', 1;
            UPDATE PRES.CLCDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdCLCDetalle = @PKIdCLCDetalle;
            SET @Id = @PKIdCLCDetalle;
            SET @message = 'Detalle de CLC eliminado correctamente.';
            SET @liga = CONCAT('idCLCDetalle:', @Id);
        END
        ELSE IF @Action = 8
        BEGIN
            SELECT * FROM PRES.Vw_CLCDetalle WHERE PKIdCLCDetalle = @PKIdCLCDetalle;
            SET @message = 'Detalle de CLC consultado correctamente.';
            SET @liga = CONCAT('idCLCDetalle:', @PKIdCLCDetalle);
        END
        ELSE IF @Action = 9
        BEGIN
            IF @PKIdCLC IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLC WHERE PKIdCLC = @PKIdCLC AND Activo = 1)
                THROW 51000, 'CLC no encontrada.', 1;
            IF @FKIdFacturaDetalle_PRES IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.FacturaDetalle WHERE PKIdFacturaDetalle = @FKIdFacturaDetalle_PRES AND Activo = 1)
                THROW 51000, 'Detalle de factura no encontrado.', 1;
            IF ISNULL(@MontoAplicado, 0) <= 0
                THROW 51000, 'El monto aplicado debe ser mayor a cero.', 1;

            INSERT INTO PRES.CLCFactura (
                FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdFactura_PRES, FKIdFacturaDetalle_PRES,
                MontoAplicado, Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, clc.FKIdEmpresa_SIS), @PKIdCLC, ISNULL(@FKIdFactura_PRES, fd.FKIdFactura_PRES),
                   @FKIdFacturaDetalle_PRES, @MontoAplicado, @Observaciones, 1, @today, @IdUser
            FROM PRES.CLC clc
            INNER JOIN PRES.FacturaDetalle fd ON fd.PKIdFacturaDetalle = @FKIdFacturaDetalle_PRES
            WHERE clc.PKIdCLC = @PKIdCLC;
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Factura de CLC creada correctamente.';
            SET @liga = CONCAT('idCLCFactura:', @Id);
        END
        ELSE IF @Action = 10
        BEGIN
            IF @PKIdCLCFactura IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLCFactura WHERE PKIdCLCFactura = @PKIdCLCFactura AND Activo = 1)
                THROW 51000, 'Factura de CLC no encontrada.', 1;
            IF ISNULL(@MontoAplicado, 0) <= 0
                THROW 51000, 'El monto aplicado debe ser mayor a cero.', 1;

            UPDATE cf
            SET FKIdFactura_PRES = ISNULL(@FKIdFactura_PRES, fd.FKIdFactura_PRES),
                FKIdFacturaDetalle_PRES = @FKIdFacturaDetalle_PRES,
                MontoAplicado = @MontoAplicado,
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.CLCFactura cf
            INNER JOIN PRES.FacturaDetalle fd ON fd.PKIdFacturaDetalle = @FKIdFacturaDetalle_PRES AND fd.Activo = 1
            WHERE cf.PKIdCLCFactura = @PKIdCLCFactura;
            SET @Id = @PKIdCLCFactura;
            SET @message = 'Factura de CLC actualizada correctamente.';
            SET @liga = CONCAT('idCLCFactura:', @Id);
        END
        ELSE IF @Action = 11
        BEGIN
            IF @PKIdCLCFactura IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLCFactura WHERE PKIdCLCFactura = @PKIdCLCFactura AND Activo = 1)
                THROW 51000, 'Factura de CLC no encontrada.', 1;
            UPDATE PRES.CLCFactura SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdCLCFactura = @PKIdCLCFactura;
            SET @Id = @PKIdCLCFactura;
            SET @message = 'Factura de CLC eliminada correctamente.';
            SET @liga = CONCAT('idCLCFactura:', @Id);
        END
        ELSE IF @Action = 12
        BEGIN
            SELECT * FROM PRES.Vw_CLCFactura WHERE PKIdCLCFactura = @PKIdCLCFactura;
            SET @message = 'Factura de CLC consultada correctamente.';
            SET @liga = CONCAT('idCLCFactura:', @PKIdCLCFactura);
        END
        ELSE
            THROW 51000, 'Accion no valida para CLC.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [PRES].[SP_MantenimientoCheque] (
    @Action INT,
    @PKIdCheque INT = NULL,
    @PKIdChequePartida INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdCLC_PRES INT = NULL,
    @FKIdCuentaBancaria_TES INT = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @FechaEmision DATE = NULL,
    @NumeroCheque NVARCHAR(50) = NULL,
    @Concepto NVARCHAR(150) = NULL,
    @ImporteTotal DECIMAL(20,4) = NULL,
    @Observaciones NVARCHAR(500) = NULL,
    @Estatus INT = NULL,
    @FKIdCLCDetalle_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @MontoPagado DECIMAL(20,4) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoCheque]', ' @PKIdCheque ', @PKIdCheque);
    SET @Parameters = CONCAT('Action=', @Action, ', PKIdCheque=', ISNULL(CONVERT(NVARCHAR(30), @PKIdCheque), 'NULL'), ', PKIdChequePartida=', ISNULL(CONVERT(NVARCHAR(30), @PKIdChequePartida), 'NULL'), ', NumeroCheque=', ISNULL(@NumeroCheque, 'NULL'), ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL'));
    EXEC [SIS].[WriteSystemLog] @FK_IdOrigenLogMessage__SIS = 1, @Date = @today, @_Type = 1, @ProgName = 'PRES.SP_MantenimientoCheque', @EmployeeNo = @IdUser, @Category = NULL, @IPClient = NULL, @HostName = NULL, @Thread = NULL, @Level = 'INFO', @Logger = NULL, @Message = @message, @Exception = NULL, @Context = NULL, @MethodName = 'PRES.SP_MantenimientoCheque', @Parameters = @Parameters, @ExecutionTime = '0';
    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            INSERT INTO PRES.Cheque (
                FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdCuentaBancaria_TES, FKIdPoliza_CONTA,
                FechaEmision, NumeroCheque, Concepto, ImporteTotal, Observaciones, Estatus,
                Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdCLC_PRES, @FKIdCuentaBancaria_TES, @FKIdPoliza_CONTA,
                ISNULL(@FechaEmision, CONVERT(DATE, GETDATE())), @NumeroCheque, @Concepto, ISNULL(@ImporteTotal, 0),
                @Observaciones, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            );
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Cheque creado correctamente.';
            SET @liga = CONCAT('idCheque:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdCheque IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Cheque WHERE PKIdCheque = @PKIdCheque AND Activo = 1)
                THROW 51000, 'Cheque no encontrado.', 1;

            UPDATE PRES.Cheque
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdCLC_PRES = @FKIdCLC_PRES,
                FKIdCuentaBancaria_TES = @FKIdCuentaBancaria_TES,
                FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                FechaEmision = ISNULL(@FechaEmision, FechaEmision),
                NumeroCheque = @NumeroCheque,
                Concepto = @Concepto,
                ImporteTotal = ISNULL(@ImporteTotal, 0),
                Observaciones = @Observaciones,
                Estatus = ISNULL(NULLIF(@Estatus, 0), Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdCheque = @PKIdCheque;
            SET @Id = @PKIdCheque;
            SET @message = 'Cheque actualizado correctamente.';
            SET @liga = CONCAT('idCheque:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdCheque IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Cheque WHERE PKIdCheque = @PKIdCheque AND Activo = 1)
                THROW 51000, 'Cheque no encontrado.', 1;

            DECLARE @FKIdCLCReactivar INT;
            SELECT @FKIdCLCReactivar = FKIdCLC_PRES
            FROM PRES.Cheque
            WHERE PKIdCheque = @PKIdCheque;

            UPDATE PRES.ChequePartidas SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdCheque_PRES = @PKIdCheque AND Activo = 1;
            UPDATE PRES.Cheque SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdCheque = @PKIdCheque;
            UPDATE PRES.CLC
            SET Estatus = 1, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE PKIdCLC = @FKIdCLCReactivar AND Activo = 1;

            SET @Id = @PKIdCheque;
            SET @message = 'Cheque eliminado correctamente. La CLC regreso a la etapa anterior.';
            SET @liga = CONCAT('idCheque:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT * FROM PRES.Vw_Cheque WHERE PKIdCheque = @PKIdCheque;
            SET @message = 'Cheque consultado correctamente.';
            SET @liga = CONCAT('idCheque:', @PKIdCheque);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdCheque IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Cheque WHERE PKIdCheque = @PKIdCheque AND Activo = 1)
                THROW 51000, 'Cheque no encontrado.', 1;
            IF @FKIdCLCDetalle_PRES IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.CLCDetalle WHERE PKIdCLCDetalle = @FKIdCLCDetalle_PRES AND Activo = 1)
                THROW 51000, 'Detalle de CLC no encontrado.', 1;
            IF ISNULL(@MontoPagado, 0) <= 0
                THROW 51000, 'El monto pagado debe ser mayor a cero.', 1;

            INSERT INTO PRES.ChequePartidas (
                FKIdEmpresa_SIS, FKIdCheque_PRES, FKIdCLCDetalle_PRES, FKIdPartida_CONTA,
                MontoPagado, Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT ISNULL(@FKIdEmpresa_SIS, ch.FKIdEmpresa_SIS), @PKIdCheque, @FKIdCLCDetalle_PRES,
                   ISNULL(@FKIdPartida_CONTA, cd.FKIdPartida_CONTA), @MontoPagado, @Observaciones, 1, @today, @IdUser
            FROM PRES.Cheque ch
            INNER JOIN PRES.CLCDetalle cd ON cd.PKIdCLCDetalle = @FKIdCLCDetalle_PRES
            WHERE ch.PKIdCheque = @PKIdCheque;
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Partida de cheque creada correctamente.';
            SET @liga = CONCAT('idChequePartida:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdChequePartida IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ChequePartidas WHERE PKIdChequePartida = @PKIdChequePartida AND Activo = 1)
                THROW 51000, 'Partida de cheque no encontrada.', 1;
            IF ISNULL(@MontoPagado, 0) <= 0
                THROW 51000, 'El monto pagado debe ser mayor a cero.', 1;

            UPDATE cp
            SET FKIdCLCDetalle_PRES = @FKIdCLCDetalle_PRES,
                FKIdPartida_CONTA = ISNULL(@FKIdPartida_CONTA, cd.FKIdPartida_CONTA),
                MontoPagado = @MontoPagado,
                Observaciones = @Observaciones,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.ChequePartidas cp
            INNER JOIN PRES.CLCDetalle cd ON cd.PKIdCLCDetalle = @FKIdCLCDetalle_PRES AND cd.Activo = 1
            WHERE cp.PKIdChequePartida = @PKIdChequePartida;
            SET @Id = @PKIdChequePartida;
            SET @message = 'Partida de cheque actualizada correctamente.';
            SET @liga = CONCAT('idChequePartida:', @Id);
        END
        ELSE IF @Action = 7
        BEGIN
            IF @PKIdChequePartida IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.ChequePartidas WHERE PKIdChequePartida = @PKIdChequePartida AND Activo = 1)
                THROW 51000, 'Partida de cheque no encontrada.', 1;
            UPDATE PRES.ChequePartidas SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdChequePartida = @PKIdChequePartida;
            SET @Id = @PKIdChequePartida;
            SET @message = 'Partida de cheque eliminada correctamente.';
            SET @liga = CONCAT('idChequePartida:', @Id);
        END
        ELSE IF @Action = 8
        BEGIN
            SELECT * FROM PRES.Vw_ChequePartidas WHERE PKIdChequePartida = @PKIdChequePartida;
            SET @message = 'Partida de cheque consultada correctamente.';
            SET @liga = CONCAT('idChequePartida:', @PKIdChequePartida);
        END
        ELSE
            THROW 51000, 'Accion no valida para cheque.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [ALMA].[SP_MantenimientoTipoBien] (
    @Action INT,
    @PKIdTipoBien INT = NULL,
    @FKIdGrupoBien_ALMA INT = NULL,
    @FKIdNivel_ALMA INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @FKIdCuentaContable_CONTA INT = NULL,
    @FKIdUnidades_ALMA INT = NULL,
    @FKIdLocalizacion_ALMA INT = NULL,
    @FKIdUnidades_Equivalente INT = NULL,
    @CodigoClave NVARCHAR(200) = NULL,
    @Descripcion NVARCHAR(1200) = NULL,
    @DepreciacionAnual DECIMAL(18,4) = NULL,
    @Consecutivo INT = NULL,
    @CABMS NVARCHAR(50) = NULL,
    @Identificador NVARCHAR(50) = NULL,
    @ExistenciaMinima DECIMAL(18,4) = NULL,
    @ExistenciaMaxima DECIMAL(18,4) = NULL,
    @TiempoVida INT = NULL,
    @Pk_IdTratadoInt INT = NULL,
    @Cuota NUMERIC(8,2) = NULL,
    @ProveeduriaNac BIT = NULL,
    @CatalogoBasico BIT = NULL,
    @CUCOP_PLUS VARCHAR(25) = NULL,
    @Cantidad_Equivalente INT = NULL,
    @IdUser INT = NULL,
    @Id INT = NULL OUTPUT
)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(4000);
    DECLARE @Parameters NVARCHAR(4000) = '';
    DECLARE @errorMessage NVARCHAR(MAX);
    DECLARE @today DATETIME2 = SYSDATETIME();

    SET @message = CONCAT('Iniciando el SP [ALMA].[SP_MantenimientoTipoBien]', ' @PKIdTipoBien ', @PKIdTipoBien);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdTipoBien=', ISNULL(CONVERT(NVARCHAR(30), @PKIdTipoBien), 'NULL'),
        ', FKIdGrupoBien_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdGrupoBien_ALMA), 'NULL'),
        ', FKIdNivel_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdNivel_ALMA), 'NULL'),
        ', FKIdPartida_CONTA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPartida_CONTA), 'NULL'),
        ', FKIdCuentaContable_CONTA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdCuentaContable_CONTA), 'NULL'),
        ', FKIdUnidades_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdUnidades_ALMA), 'NULL'),
        ', CodigoClave=', ISNULL(@CodigoClave, 'NULL'),
        ', Descripcion=', ISNULL(LEFT(@Descripcion, 300), 'NULL'),
        ', Consecutivo=', ISNULL(CONVERT(NVARCHAR(30), @Consecutivo), 'NULL'),
        ', CABMS=', ISNULL(@CABMS, 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'ALMA.SP_MantenimientoTipoBien',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'ALMA.SP_MantenimientoTipoBien',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            DECLARE @FKIdPartidaCalculada INT = @FKIdPartida_CONTA;
            DECLARE @CABMSCalculada VARCHAR(50) = @CABMS;

            INSERT INTO ALMA.TipoBien (
                FKIdGrupoBien_ALMA, FKIdNivel_ALMA,
                FKIdPartida_CONTA, FKIdCuentaContable_CONTA,
                FKIdUnidades_ALMA, FKIdLocalizacion_ALMA,
                FKIdUnidades_Equivalente,
                CodigoClave, Descripcion,
                DepreciacionAnual, Consecutivo, CABMS,
                Identificador, ExistenciaMinima, ExistenciaMaxima,
                TiempoVida, Pk_IdTratadoInt, Cuota,
                ProveeduriaNac, CatalogoBasico, CUCOP_PLUS,
                Cantidad_Equivalente,
                Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdGrupoBien_ALMA, @FKIdNivel_ALMA,
                @FKIdPartidaCalculada, @FKIdCuentaContable_CONTA,
                @FKIdUnidades_ALMA, @FKIdLocalizacion_ALMA,
                @FKIdUnidades_Equivalente,
                @CodigoClave, @Descripcion,
                @DepreciacionAnual, @Consecutivo, @CABMSCalculada,
                @Identificador, @ExistenciaMinima, @ExistenciaMaxima,
                @TiempoVida, @Pk_IdTratadoInt, @Cuota,
                @ProveeduriaNac, @CatalogoBasico, @CUCOP_PLUS,
                @Cantidad_Equivalente,
                1, @today, @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @tipo = 'OK';
            SET @message = 'Tipo de bien creado correctamente.';
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdTipoBien IS NULL OR NOT EXISTS (SELECT 1 FROM ALMA.TipoBien WHERE PKIdTipoBien = @PKIdTipoBien AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'Tipo de bien no encontrado';
                GOTO ERR_HANDLER;
            END

            UPDATE ALMA.TipoBien
            SET
                FKIdGrupoBien_ALMA = ISNULL(@FKIdGrupoBien_ALMA, FKIdGrupoBien_ALMA),
                FKIdNivel_ALMA = ISNULL(@FKIdNivel_ALMA, FKIdNivel_ALMA),
                FKIdPartida_CONTA = ISNULL(@FKIdPartida_CONTA, FKIdPartida_CONTA),
                FKIdCuentaContable_CONTA = ISNULL(@FKIdCuentaContable_CONTA, FKIdCuentaContable_CONTA),
                FKIdUnidades_ALMA = ISNULL(@FKIdUnidades_ALMA, FKIdUnidades_ALMA),
                FKIdLocalizacion_ALMA = ISNULL(@FKIdLocalizacion_ALMA, FKIdLocalizacion_ALMA),
                FKIdUnidades_Equivalente = ISNULL(@FKIdUnidades_Equivalente, FKIdUnidades_Equivalente),
                CodigoClave = ISNULL(@CodigoClave, CodigoClave),
                Descripcion = ISNULL(@Descripcion, Descripcion),
                DepreciacionAnual = ISNULL(@DepreciacionAnual, DepreciacionAnual),
                Consecutivo = ISNULL(@Consecutivo, Consecutivo),
                CABMS = ISNULL(@CABMS, CABMS),
                Identificador = ISNULL(@Identificador, Identificador),
                ExistenciaMinima = ISNULL(@ExistenciaMinima, ExistenciaMinima),
                ExistenciaMaxima = ISNULL(@ExistenciaMaxima, ExistenciaMaxima),
                TiempoVida = ISNULL(@TiempoVida, TiempoVida),
                Pk_IdTratadoInt = ISNULL(@Pk_IdTratadoInt, Pk_IdTratadoInt),
                Cuota = ISNULL(@Cuota, Cuota),
                ProveeduriaNac = ISNULL(@ProveeduriaNac, ProveeduriaNac),
                CatalogoBasico = ISNULL(@CatalogoBasico, CatalogoBasico),
                CUCOP_PLUS = ISNULL(@CUCOP_PLUS, CUCOP_PLUS),
                Cantidad_Equivalente = ISNULL(@Cantidad_Equivalente, Cantidad_Equivalente),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdTipoBien = @PKIdTipoBien;

            SET @Id = @PKIdTipoBien;
            SET @tipo = 'OK';
            SET @message = 'Tipo de bien actualizado correctamente.';
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdTipoBien IS NULL OR NOT EXISTS (SELECT 1 FROM ALMA.TipoBien WHERE PKIdTipoBien = @PKIdTipoBien AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'Tipo de bien no encontrado';
                GOTO ERR_HANDLER;
            END

            UPDATE ALMA.TipoBien
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdTipoBien = @PKIdTipoBien;

            SET @Id = @PKIdTipoBien;
            SET @tipo = 'OK';
            SET @message = 'Tipo de bien eliminado correctamente.';
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT
                tb.PKIdTipoBien,
                tb.FKIdGrupoBien_ALMA,
                gb.Descripcion AS GrupoBien,
                tb.FKIdNivel_ALMA,
                tb.FKIdPartida_CONTA,
                p.Clave AS PartidaClave,
                p.Descripcion AS PartidaDescripcion,
                tb.FKIdCuentaContable_CONTA,
                tb.FKIdUnidades_ALMA,
                u.Descripcion AS UnidadMedida,
                tb.FKIdLocalizacion_ALMA,
                tb.FKIdUnidades_Equivalente,
                tb.CodigoClave,
                tb.Descripcion,
                tb.DepreciacionAnual,
                tb.Consecutivo,
                tb.CABMS,
                tb.Identificador,
                tb.ExistenciaMinima,
                tb.ExistenciaMaxima,
                tb.TiempoVida,
                tb.Pk_IdTratadoInt,
                tb.Cuota,
                tb.ProveeduriaNac,
                tb.CatalogoBasico,
                tb.CUCOP_PLUS,
                tb.Cantidad_Equivalente,
                tb.Activo,
                tb.FechaCreacion,
                tb.UsuarioCreacion,
                tb.FechaModificacion,
                tb.UsuarioModificacion
            FROM ALMA.TipoBien tb
            LEFT JOIN ALMA.GrupoBien gb ON tb.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien
            LEFT JOIN CONTA.Partida p ON tb.FKIdPartida_CONTA = p.PKIdPartida
            LEFT JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades
            WHERE tb.PKIdTipoBien = @PKIdTipoBien;

            SET @tipo = 'OK';
            GOTO FINISH;
        END
        ELSE
        BEGIN
            SET @tipo = 'ERROR';
            SET @message = 'Acci�n no v�lida. Use 1=Insert, 2=Update, 3=Delete, 4=GetById';
            GOTO ERR_HANDLER;
        END

        FINISH:
        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRANSACTION;

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"', @tipo, '","mensaje":"', @message, '","liga":"idTipoBien:', ISNULL(CAST(@Id AS NVARCHAR), ''), '"}')
        ) AS ResultJson;

        RETURN 0;

        ERR_HANDLER:
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END CATCH
END;
GO

-- =============================================
-- dbo
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_RegistrarEntidad]
    @Grupo          NVARCHAR(100),
    @SubGrupo       NVARCHAR(100),
    @NombreMenu     NVARCHAR(150),
    @Ruta           NVARCHAR(200),
    @MenuPadreNombre NVARCHAR(150) = NULL,
    @Icono          NVARCHAR(120) = NULL,
    @Orden          INT = 0,
    @Descripcion    NVARCHAR(200) = NULL,
    @Codigo         NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdMenu INT;
    DECLARE @IdMenuPadre INT = NULL;
    DECLARE @PermisosAdmin    NVARCHAR(100) = 'view,view-menu,delete,new,update,CanExportToExcel';
    DECLARE @PermisosSoporte  NVARCHAR(100) = 'view,view-menu';
    DECLARE @PermisosConfig   NVARCHAR(100) = 'view,view-menu,delete,new,update';

    IF @MenuPadreNombre IS NOT NULL
    BEGIN
        SELECT @IdMenuPadre = PKIdMenu
        FROM SIS.Menu
        WHERE Nombre = @MenuPadreNombre AND Activo = 1;
        
        IF @IdMenuPadre IS NULL
        BEGIN
            PRINT 'Advertencia: No se encontr� el men� padre "' + @MenuPadreNombre + '". Se registrar� como ra�z.';
        END
    END

    IF @Codigo IS NULL
        SET @Codigo = UPPER(LEFT(@Grupo, 2) + LEFT(@SubGrupo, 2) + '001');

    IF NOT EXISTS (SELECT 1 FROM SIS.Menu WHERE Nombre = @NombreMenu AND Ruta = @Ruta AND Activo = 1)
    BEGIN
        INSERT INTO SIS.Menu (
            Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta,
            ImageUrl, Lenguaje, Orden, Activo, CreatedDateTime
        ) VALUES (
            @NombreMenu, 2, @IdMenuPadre, @NombreMenu, @Ruta,
            @Icono, 'ESP', @Orden, 1, GETDATE()
        );
        SET @IdMenu = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SELECT @IdMenu = PKIdMenu FROM SIS.Menu WHERE Nombre = @NombreMenu AND Ruta = @Ruta AND Activo = 1;
    END

    DECLARE @Roles TABLE (Code NVARCHAR(10), Permisos NVARCHAR(100));
    INSERT INTO @Roles VALUES ('10000', @PermisosAdmin), ('20000', @PermisosSoporte), ('30000', @PermisosConfig);

    DECLARE @CodeRole NVARCHAR(10), @PermisosRole NVARCHAR(100), @RoleId NVARCHAR(128);

    DECLARE role_cursor CURSOR FOR
        SELECT r.Code, rp.Permisos
        FROM AspNetRoles r
        INNER JOIN @Roles rp ON r.Code = rp.Code;

    OPEN role_cursor;
    FETCH NEXT FROM role_cursor INTO @CodeRole, @PermisosRole;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @RoleId = (SELECT Id FROM AspNetRoles WHERE Code = @CodeRole);

        IF NOT EXISTS (
            SELECT 1 FROM AspNetClaims
            WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo
        )
        BEGIN
            INSERT INTO AspNetClaims (
                ClaimTypeId, Name, [Group], RoleId, TokenFormat, Created,
                SubGroup, Code, [Description], [Values], ReferenceId
            )
            VALUES (
                2, @Grupo, @Grupo, @RoleId, 'app://{0}/{1}', GETDATE(),
                @SubGrupo, @Codigo, @Descripcion, @PermisosRole,
                ISNULL((SELECT TOP 1 Id FROM AspNetClaims WHERE [Group] = @Grupo AND SubGroup = @SubGrupo), 0)
            );
        END
        ELSE
        BEGIN
            DECLARE @CurrentValues NVARCHAR(MAX);
            SELECT @CurrentValues = [Values] FROM AspNetClaims
            WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo;

            SET @PermisosRole = (
                SELECT STRING_AGG(value, ',') WITHIN GROUP (ORDER BY value)
                FROM (
                    SELECT DISTINCT value FROM STRING_SPLIT(@CurrentValues, ',')
                    UNION
                    SELECT DISTINCT value FROM STRING_SPLIT(@PermisosRole, ',')
                ) AS t
            );

            UPDATE AspNetClaims
            SET [Values] = @PermisosRole,
                [Description] = ISNULL(@Descripcion, [Description])
            WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo;
        END

        DECLARE @ClaimId INT;
        SELECT @ClaimId = Id FROM AspNetClaims
        WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo;

        INSERT INTO AspNetClaimValues (ClaimId, Value, Created)
        SELECT @ClaimId, TRIM(value), GETDATE()
        FROM STRING_SPLIT(@PermisosRole, ',')
        WHERE NOT EXISTS (
            SELECT 1 FROM AspNetClaimValues
            WHERE ClaimId = @ClaimId AND Value = TRIM(value)
        );

        IF EXISTS (SELECT 1 FROM STRING_SPLIT(@PermisosRole, ',') WHERE value = 'view-menu')
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SIS.MenuRole WHERE FKIdMenu_SIS = @IdMenu AND RoleId = @RoleId)
            BEGIN
                INSERT INTO SIS.MenuRole (FKIdMenu_SIS, RoleId, Activo, CreatedDateTime)
                VALUES (@IdMenu, @RoleId, 1, GETDATE());
            END
        END
        ELSE
        BEGIN
            DELETE FROM SIS.MenuRole WHERE FKIdMenu_SIS = @IdMenu AND RoleId = @RoleId;
        END

        FETCH NEXT FROM role_cursor INTO @CodeRole, @PermisosRole;
    END

    CLOSE role_cursor;
    DEALLOCATE role_cursor;

    PRINT 'Entidad "' + @Grupo + '/' + @SubGrupo + '" registrada correctamente.';
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[spConfiguracionDeRolYClaims]
	@group NVARCHAR(100),
	@subgroup NVARCHAR(100),
	@code NVARCHAR(10),
	@values NVARCHAR(max),
	@description NVARCHAR(200) = NULL,
	@rolName NVARCHAR(256) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @IdRole NVARCHAR(128),
	        @value NVARCHAR(max),
	        @claims NVARCHAr(max),
			@IdReference INT,
			@Cod NVARCHAR(10),
			@IdClaim INT,
			@errorMassage1 NVARCHAR(200),
			@errorMassage2 NVARCHAR(200);

	IF EXISTS(SELECT 1 FROM AspNetRoles WHERE Code = @code)
	BEGIN
    
		SET @IdRole = (SELECT Id FROM AspNetRoles WHERE Code = @code)
		SET @Cod = (SELECT TOP 1 Code FROM AspNetClaims WHERE [Group] = @group)
		SET @IdReference = (SELECT TOP 1 Id FROM AspNetClaims WHERE [Group] = @group AND [SubGroup] = @subgroup)
	
		IF EXISTS(SELECT 1 FROM AspNetClaims WHERE RoleId = @IdRole and [Group] = @group)
		BEGIN

			IF EXISTS(SELECT 1 FROM AspNetClaims WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup)
			BEGIN
			
				SET @claims = (SELECT [Values] FROM AspNetClaims WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup);

				IF EXISTS(SELECT 1 FROM [dbo].[STRING_SPLIT](@claims) WHERE Name = @values)
				BEGIN
					SET @errorMassage1 = 'El Claim ' + @values + ' ya Existe';
				END
				ELSE
				BEGIN
			    
					UPDATE AspNetClaims SET [Values] = @claims + ',' + @values
					WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup

				END
			END
			ELSE
			BEGIN
		    
				IF @Description IS NULL
				BEGIN
					SET @Description=(SELECT TOP 1 Description FROM AspNetClaims WHERE [Group] = @group AND [SubGroup] = @subgroup)
				END

				INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,@group,@group,@IdRole,'app://{0}/{1}',GETDATE(),@subgroup,@Cod,@Description,@values,@IdReference)
				
			END

		END
		ELSE
		BEGIN

			IF @Description IS NULL
			BEGIN
				SET @Description=(SELECT TOP 1 Description FROM AspNetClaims WHERE [Group] = @group AND [SubGroup] = @subgroup)
			END
	    
			INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
			VALUES(2,@group,@group,@IdRole,'app://{0}/{1}',GETDATE(),@subgroup,@Cod,@Description,@values,@IdReference)

		END

	END
	ELSE
	BEGIN
        
		IF @rolName IS NOT NULL
		BEGIN
			SET @IdRole = NEWID();
			SET @Cod = (SELECT TOP 1 Code FROM AspNetClaims WHERE [Group] = @group)
			SET @IdReference = (SELECT TOP 1 Id FROM AspNetClaims WHERE [Group] = @group)

			INSERT INTO AspNetRoles
			VALUES(@IdRole,@rolName,@code)

			INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
			VALUES(2,@group,@group,@IdRole,'app://{0}/{1}',GETDATE(),@subgroup,@Cod,@Description,@values,@IdReference)
		
		END
		ELSE
		BEGIN
		    SET @errorMassage1 = 'Para agregar un rol se necesita el nombre que se le asignara';
		END

	END

	IF @errorMassage1 <> 'Success'
	BEGIN
		SELECT @errorMassage1 AS AspNetClaims;
	END
	
	SET @IdClaim = (SELECT MAX(Id) FROM AspNetClaims WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup);

	IF @IdClaim IS NULL
	BEGIN
	    SET @errorMassage2 = 'Revisar parametros de entrada';
	END
	ELSE
	BEGIN
	    
		IF EXISTS(SELECT 1 FROM AspNetClaimValues WHERE ClaimId = @IdClaim AND Value = @Values)
		BEGIN
	    
			SET @errorMassage2 = 'El valor ya se encuentra registrado';

		END
		ELSE
		BEGIN
	    
			INSERT INTO AspNetClaimValues(ClaimId,Value,Created)
			VALUES(@IdClaim,@values,GETDATE())
		
		END

	END

	IF @errorMassage2 <> 'Success'
	BEGIN
		SELECT @errorMassage2 AS AspNetClaimValues;
	END
END
GO

-- =============================================
-- SIS
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC [SIS].[LoginInformationEmployee] @PayrollID = 'ADMIN001'
CREATE OR ALTER PROCEDURE [SIS].[LoginInformationEmployee](
	@PayrollID NVARCHAR(60)
)
AS BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	SELECT e.PkIdUsuario
    , iif(e.FKIdPersona_NOM IS NULL,0,e.FKIdPersona_NOM) FKIdPersonaNOM
    , e.PayrollID
    , iif(p.Gafete is null,e.PayrollID,p.Gafete) Gafete
    , ANU.PasswordHash
    , rol.Name
    , iif(p.CORREO_ELECTRONICO IS NULL ,'ADMIN@eg.COM',p.CORREO_ELECTRONICO) AS Email
    , NombreUsuario = IIF(p.Nombre IS NULL,'Admin',CONCAT(p.Nombre, ' ', p.Paterno, ' ', p.Materno))
	FROM SIS.Usuario AS e WITH (NOLOCK)
	LEFT JOIN NOM.Persona p ON e.FKIdPersona_NOM = p.PKIdPersona
	INNER JOIN dbo.AspNetUsers AS ANU WITH (NOLOCK) ON ANU.PkIdUsuario = e.PkIdUsuario
	INNER JOIN [dbo].[AspNetUserRoles] AS UR WITH (NOLOCK) ON UR.UserId = ANU.Id
	INNER JOIN AspNetRoles AS rol WITH (NOLOCK) ON UR.RoleId = rol.Id
	WHERE e.PayrollID = @PayrollID AND e.Activo = 1
END;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [SIS].[spEliminarUsuarioSucursal]
    @FkidUsuarioSis INT,
    @FkidSucursalSis INT,
    @UsuarioModificacion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM SIS.UsuarioSucursal 
            WHERE FkidUsuario_Sis = @FkidUsuarioSis 
            AND FkidSucursal_Sis = @FkidSucursalSis
        )
        BEGIN
            SELECT 
                0 AS Success,
                'No se encontr� la asignaci�n especificada' AS Message,
                'NOT_FOUND' AS Code;
            RETURN;
        END

        DELETE FROM SIS.UsuarioSucursal 
        WHERE FkidUsuario_Sis = @FkidUsuarioSis 
        AND FkidSucursal_Sis = @FkidSucursalSis;

        COMMIT TRANSACTION;

        SELECT 
            1 AS Success,
            'Asignaci�n eliminada correctamente' AS Message,
            'SUCCESS' AS Code;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        SELECT 
            0 AS Success,
            @ErrorMessage AS Message,
            'ERROR' AS Code;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [SIS].[spGetClaimsByUser] @PkIdUser = 1, @EsParaLogin = 1
CREATE OR ALTER PROCEDURE [SIS].[spGetClaimsByUser]
    @PkIdUser INT, 
    @EsParaLogin BIT = 0
AS
BEGIN
    ;WITH Claims AS (
        SELECT 
            ANC.[Group], 
            ANC.SubGroup, 
            ANC.[Values]
        FROM SIS.Usuario AS U WITH (NOLOCK)
        INNER JOIN dbo.AspNetUsers AS ANU WITH (NOLOCK) 
            ON U.PkIdUsuario = ANU.PkIdUsuario
        INNER JOIN dbo.AspNetUserRoles AS ANUR WITH (NOLOCK) 
            ON ANUR.UserId = ANU.Id
        INNER JOIN dbo.AspNetRoles AS R WITH (NOLOCK) 
            ON R.Id = ANUR.RoleId
        INNER JOIN dbo.AspNetClaims AS ANC WITH (NOLOCK) 
            ON ANC.RoleId = R.Id
        LEFT JOIN SIS.MenuRole AS MR WITH (NOLOCK) 
            ON MR.RoleId = R.Id
        LEFT JOIN SIS.Menu AS M WITH (NOLOCK) 
            ON M.PKIdMenu = MR.FKIdMenu_SIS
        WHERE 
            U.PkIdUsuario = @PkIdUser
            AND U.Activo = 1
            AND (@EsParaLogin = 0 OR M.Activo = 1)
    )
    SELECT
        [Group], SubGroup, [Values]
    FROM Claims
    GROUP BY [Group], SubGroup, [Values]
    ORDER BY [Group], SubGroup, [Values];
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [SIS].[spNodeMenu] @NoEmploye = 1, @Lenguaje = 'ESP'
CREATE OR ALTER PROCEDURE [SIS].[spNodeMenu]
	@NoEmploye int, 
	@Lenguaje char(3)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	IF (@NoEmploye <= 0)
		set @NoEmploye = 1000
	;with cte as 
	(
		SELECT  [SM].[PKIdMenu],[SM].[Nombre],[SM].[Tipo],[SM].[FKIdMenu_SIS],[SM].[LegacyName],[SM].[Ruta],[SM].[ImageUrl],[SM].[Activo],[SM].[Lenguaje],[R].[UserId], [SM].[Orden]
		FROM SIS.Menu [SM] (NOLOCK)
			INNER JOIN SIS.MenuRole [RM] (NOLOCK) ON [RM].[FKIdMenu_SIS] = [SM].[PKIdMenu]
			INNER JOIN [dbo].[AspNetUserRoles] AS R (NOLOCK) ON R.RoleId = RM.RoleID
			INNER JOIN [dbo].[AspNetUsers] [ANU] (NOLOCK) ON [ANU].[Id] = [R].[UserId]
			INNER JOIN SIS.Usuario [EMP] (NOLOCK) ON [EMP].PkIdUsuario = [ANU].PkIdUsuario
		WHERE  [SM].[Activo] = 1 and [SM].FKIdMenu_SIS is null AND [EMP].PkIdUsuario = @NoEmploye
		union all
		SELECT  [SM].[PKIdMenu],[SM].[Nombre],[SM].[Tipo],[SM].[FKIdMenu_SIS],[SM].[LegacyName],[SM].[Ruta],[SM].[ImageUrl],[SM].[Activo],[SM].[Lenguaje],[R].[UserId], [SM].[Orden]
		FROM cte
		INNER JOIN SIS.Menu [SM] (NOLOCK) on SM.FKIdMenu_SIS = cte.PKIdMenu
		INNER JOIN SIS.MenuRole [RM] (NOLOCK) ON [RM].FKIdMenu_SIS = [SM].[PKIdMenu]
		INNER JOIN [dbo].[AspNetUserRoles] AS R (NOLOCK) ON R.RoleId = RM.RoleID
		INNER JOIN [dbo].[AspNetUsers] [ANU] (NOLOCK) ON [ANU].[Id] = [R].[UserId]
		INNER JOIN SIS.Usuario [EMP] (NOLOCK) ON [EMP].PkIdUsuario = [ANU].PkIdUsuario
		WHERE  [SM].[Activo] = 1 and [SM].FKIdMenu_SIS is not null AND [EMP].PkIdUsuario = @NoEmploye
	)    
	SELECT DISTINCT [SM].[PKIdMenu],[SM].[Nombre],[SM].[Tipo],
		[FKIdMenuSIS] = case when [SM].[FKIdMenu_SIS] IS NULL THEN 0 ELSE  [SM].[FKIdMenu_SIS] END,
		[SM].[LegacyName],[SM].[Ruta],[SM].[ImageUrl],[SM].[Activo],[SM].[Lenguaje],[SM].[UserId], [SM].[Orden] 
	FROM cte [SM]
	Order by [SM].[PKIdMenu] 
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [SIS].[WriteSystemLog] (
	@FK_IdOrigenLogMessage__SIS  nvarchar(24) = NULL
	,@Date nvarchar(24) = NULL 
	,@_Type nvarchar(24) = NULL
	,@ProgName nvarchar(256) = NULL
	,@EmployeeNo nvarchar(24) = NULL
	,@Category nvarchar(24) = NULL
	,@IPClient nvarchar(24) = NULL
	,@HostName nvarchar(32) = NULL
	,@Thread nvarchar(255) = NULL 
	,@Level nvarchar(20) =NULL 
	,@Logger nvarchar(255) =NULL 
	,@Message nvarchar(4000)= NULL
	,@Exception nvarchar(4000) = null
	,@Context nvarchar(10)  =null
	,@MethodName nvarchar(200)  =null
	,@Parameters nvarchar(4000) = null
	,@ExecutionTime nvarchar(32) = null
)
AS
BEGIN
	IF ISNULL(@Logger,'') = 'Microsoft.EntityFrameworkCore.Database.Command'
		return;

	IF EXISTS(SELECT 1
				FROM  SIS.SystemParamCatalog AS c 
					INNER JOIN SIS.SystemParamValue AS t ON c.PKIdSystemParamCatalog = t.FKIdSystemParamCatalog_SIS
				WHERE c.Code = 'SISTEMA'
					AND t.PKIdSystemParamValue = 1
					AND C.Activo = 1
					AND t.Activo = 1
					AND CAST(T.Value  AS INT) = 1)
	BEGIN 

		if @Exception     = '' set @Exception = null;
        if @Context       = '(null)' set @Context = null;
        if @MethodName    = '(null)' set @MethodName = null;
        if @Parameters    = '(null)' set @Parameters = null;        
        if @ExecutionTime = '(null)' set @ExecutionTime = null;

		if (@Date = '' Or @Date = '(null)' Or @Date is null) set @Date = GETDATE();
		
        DECLARE @ETInt int;
		set @ETInt  = IIF(@ExecutionTime IS NULL,0,convert(int, @ExecutionTime));

		INSERT INTO SIS.SystemLog (
				 [FKIdOrigenLogMessage_SIS]
				,[Date]
				,[Type]
				,[ProgName]
				,[EmployeeNo]
				,[Category]
				,[IPClient]
				,[HostName]
				,[Thread]
				,[Level]
				,[Logger]
				,[Message]
				,[Exception]
				,[Context]
				,[MethodName]
				,[Parameters]
			)
		values(  IIF(@FK_IdOrigenLogMessage__SIS IS NULL, 1, @FK_IdOrigenLogMessage__SIS)
				,@Date
				,@_Type
				,@ProgName 
				,@EmployeeNo 
				,@Category 
				,@IPClient 
				,@HostName 
				,@Thread 
				,@Level  
				,@Logger  
				,@Message 
				,@Exception 
				,@Context 
				,@MethodName 
				,@Parameters 
			)
	END
END
GO

-- =============================================
-- CONTA
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Tabla de consecutivos para p�lizas (por a�o, mes y tipo)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ConsecutivoPoliza' AND schema_id = SCHEMA_ID('CONTA'))
BEGIN
    CREATE TABLE CONTA.ConsecutivoPoliza (
        PKIdConsecutivoPoliza INT IDENTITY(1,1) NOT NULL,
        FK_IdAnio__SIS INT NOT NULL,
        FK_IdMes__SIS INT NOT NULL,
        FK_IdTipoPoliza__SIS INT NOT NULL,
        UltimoValor INT NOT NULL CONSTRAINT DF_ConsecutivoPoliza_UltimoValor DEFAULT (0),
        Activo BIT NOT NULL CONSTRAINT DF_ConsecutivoPoliza_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_ConsecutivoPoliza_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_ConsecutivoPoliza PRIMARY KEY (PKIdConsecutivoPoliza),
        CONSTRAINT FK_ConsecutivoPoliza_Anio FOREIGN KEY (FK_IdAnio__SIS) REFERENCES SIS.Anio(PKIdAnio),
        CONSTRAINT FK_ConsecutivoPoliza_TipoPoliza FOREIGN KEY (FK_IdTipoPoliza__SIS) REFERENCES SIS.TipoPoliza(PKIdTipoPoliza),
        CONSTRAINT UQ_ConsecutivoPoliza UNIQUE (FK_IdAnio__SIS, FK_IdMes__SIS, FK_IdTipoPoliza__SIS),
        CONSTRAINT FK_ConsecutivoPoliza_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_ConsecutivoPoliza_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [CONTA].[SP_CREATE_ClavePoliza]
    @FK_IdAnio__SIS INT,
    @FK_IdMesConta__SIS INT,
    @FK_IdTipoPolizaConta__SIS INT,
    @CT_ModifiedBy INT,
    @ClavePoliza NVARCHAR(10) OUTPUT,
    @Error NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Auto-registro: si no existe el consecutivo, lo crea
        IF NOT EXISTS (
            SELECT 1 FROM CONTA.ConsecutivoPoliza
            WHERE FK_IdAnio__SIS = @FK_IdAnio__SIS
              AND FK_IdMes__SIS = @FK_IdMesConta__SIS
              AND FK_IdTipoPoliza__SIS = @FK_IdTipoPolizaConta__SIS
        )
        BEGIN
            INSERT INTO CONTA.ConsecutivoPoliza (
                FK_IdAnio__SIS, FK_IdMes__SIS, FK_IdTipoPoliza__SIS,
                UltimoValor, Activo, FechaCreacion, UsuarioCreacion
            ) VALUES (
                @FK_IdAnio__SIS, @FK_IdMesConta__SIS, @FK_IdTipoPolizaConta__SIS,
                0, 1, GETDATE(), @CT_ModifiedBy
            );
        END

        SELECT @ClavePoliza = CONVERT(NVARCHAR, (CC.FK_IdMes__SIS + CC.UltimoValor + 1))
        FROM CONTA.ConsecutivoPoliza CC WITH (UPDLOCK, ROWLOCK)
        WHERE CC.FK_IdAnio__SIS = @FK_IdAnio__SIS
          AND CC.FK_IdMes__SIS = @FK_IdMesConta__SIS
          AND CC.FK_IdTipoPoliza__SIS = @FK_IdTipoPolizaConta__SIS;

        IF @ClavePoliza IS NULL
        BEGIN
            SET @Error = 'No se pudo generar la clave de p�liza';
            GOTO ERR_HANDLER;
        END

        UPDATE CP
        SET CP.UltimoValor = CP.UltimoValor + 1,
            CP.FechaModificacion = GETDATE(),
            CP.UsuarioModificacion = @CT_ModifiedBy
        FROM CONTA.ConsecutivoPoliza CP
        WHERE CP.FK_IdAnio__SIS = @FK_IdAnio__SIS
          AND CP.FK_IdMes__SIS = @FK_IdMesConta__SIS
          AND CP.FK_IdTipoPoliza__SIS = @FK_IdTipoPolizaConta__SIS;

        IF @@ERROR <> 0
        BEGIN
            SET @Error = CAST(@@ERROR AS NVARCHAR);
            GOTO ERR_HANDLER;
        END

        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRAN;
        RETURN 0;

        ERR_HANDLER:
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK;
        END
        RETURN 1;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK;
        END
        SET @Error = CONCAT('Error: ', ERROR_MESSAGE(), ' Línea: ', ERROR_LINE());
        RETURN 1;
    END CATCH
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [CONTA].[SP_MantenimientoPoliza] (
    @Action INT,
    @PKIdPoliza INT = NULL,
    @FKIdAnio_SIS INT = NULL,
    @FKIdMes_SIS INT = NULL,
    @FKIdTipoPoliza_SIS INT = NULL,
    @NombrePoliza NVARCHAR(1000) = NULL,
    @FechaPoliza DATETIME = NULL,
    @EstaBalanceado BIT = NULL,
    @PermitirModificar BIT = NULL,
    @FKIdAccionAutorizar_SIS INT = NULL,
    @Autorizado BIT = NULL,
    @FechaSolicitud DATETIME = NULL,
    @FechaAutorizacion DATETIME = NULL,
    @IdUser INT = NULL,
    @Id INT = NULL OUTPUT
)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(4000);
    DECLARE @Parameters NVARCHAR(4000) = '';
    DECLARE @errorMessage NVARCHAR(MAX);
    DECLARE @today DATETIME2 = SYSDATETIME();

    SET @message = CONCAT('Iniciando el SP [CONTA].[SP_MantenimientoPoliza]', ' @PKIdPoliza ', @PKIdPoliza);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdPoliza=', ISNULL(CONVERT(NVARCHAR(30), @PKIdPoliza), 'NULL'),
        ', FKIdAnio_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdAnio_SIS), 'NULL'),
        ', FKIdMes_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdMes_SIS), 'NULL'),
        ', FKIdTipoPoliza_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdTipoPoliza_SIS), 'NULL'),
        ', NombrePoliza=', ISNULL(LEFT(@NombrePoliza, 300), 'NULL'),
        ', FechaPoliza=', ISNULL(CONVERT(NVARCHAR(30), @FechaPoliza, 126), 'NULL'),
        ', EstaBalanceado=', ISNULL(CONVERT(NVARCHAR(30), @EstaBalanceado), 'NULL'),
        ', PermitirModificar=', ISNULL(CONVERT(NVARCHAR(30), @PermitirModificar), 'NULL'),
        ', Autorizado=', ISNULL(CONVERT(NVARCHAR(30), @Autorizado), 'NULL'),
        ', FechaSolicitud=', ISNULL(CONVERT(NVARCHAR(30), @FechaSolicitud, 126), 'NULL'),
        ', FechaAutorizacion=', ISNULL(CONVERT(NVARCHAR(30), @FechaAutorizacion, 126), 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'CONTA.SP_MantenimientoPoliza',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'CONTA.SP_MantenimientoPoliza',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            DECLARE @ClavePoliza NVARCHAR(10);
            DECLARE @ErrMsg NVARCHAR(MAX);

            EXEC [CONTA].[SP_CREATE_ClavePoliza]
                @FK_IdAnio__SIS = @FKIdAnio_SIS,
                @FK_IdMesConta__SIS = @FKIdMes_SIS,
                @FK_IdTipoPolizaConta__SIS = @FKIdTipoPoliza_SIS,
                @CT_ModifiedBy = @IdUser,
                @ClavePoliza = @ClavePoliza OUTPUT,
                @Error = @ErrMsg OUTPUT;

            IF @ClavePoliza IS NULL OR @ClavePoliza = ''
            BEGIN
                SET @message = ISNULL(@ErrMsg, 'Error al generar clave de p�liza');
                SET @tipo = 'ERROR';
                GOTO ERR_HANDLER;
            END

            INSERT INTO CONTA.Poliza (
                FKIdAnio_SIS,
                FKIdMes_SIS,
                FKIdTipoPoliza_SIS,
                ClavePoliza,
                NombrePoliza,
                FechaPoliza,
                EstaBalanceado,
                PermitirModificar,
                FKIdAccionAutorizar_SIS,
                Autorizado,
                FechaSolicitud,
                FechaAutorizacion,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            VALUES (
                @FKIdAnio_SIS,
                @FKIdMes_SIS,
                @FKIdTipoPoliza_SIS,
                @ClavePoliza,
                @NombrePoliza,
                @FechaPoliza,
                ISNULL(@EstaBalanceado, 0),
                @PermitirModificar,
                @FKIdAccionAutorizar_SIS,
                @Autorizado,
                @FechaSolicitud,
                @FechaAutorizacion,
                1,
                @today,
                @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @tipo = 'OK';
            SET @message = CONCAT('P�liza creada correctamente. Clave: ', @ClavePoliza);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdPoliza IS NULL OR NOT EXISTS (SELECT 1 FROM CONTA.Poliza WHERE PKIdPoliza = @PKIdPoliza AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'P�liza no encontrada';
                GOTO ERR_HANDLER;
            END

            UPDATE CONTA.Poliza
            SET
                FKIdAnio_SIS = ISNULL(@FKIdAnio_SIS, FKIdAnio_SIS),
                FKIdMes_SIS = ISNULL(@FKIdMes_SIS, FKIdMes_SIS),
                FKIdTipoPoliza_SIS = ISNULL(@FKIdTipoPoliza_SIS, FKIdTipoPoliza_SIS),
                NombrePoliza = ISNULL(@NombrePoliza, NombrePoliza),
                FechaPoliza = ISNULL(@FechaPoliza, FechaPoliza),
                EstaBalanceado = ISNULL(@EstaBalanceado, EstaBalanceado),
                PermitirModificar = ISNULL(@PermitirModificar, PermitirModificar),
                FKIdAccionAutorizar_SIS = ISNULL(@FKIdAccionAutorizar_SIS, FKIdAccionAutorizar_SIS),
                Autorizado = ISNULL(@Autorizado, Autorizado),
                FechaSolicitud = ISNULL(@FechaSolicitud, FechaSolicitud),
                FechaAutorizacion = ISNULL(@FechaAutorizacion, FechaAutorizacion),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @PKIdPoliza;

            SET @Id = @PKIdPoliza;
            SET @tipo = 'OK';
            SET @message = 'P�liza actualizada correctamente.';
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdPoliza IS NULL OR NOT EXISTS (SELECT 1 FROM CONTA.Poliza WHERE PKIdPoliza = @PKIdPoliza AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'P�liza no encontrada';
                GOTO ERR_HANDLER;
            END

            UPDATE CONTA.Poliza
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @PKIdPoliza;

            SET @Id = @PKIdPoliza;
            SET @tipo = 'OK';
            SET @message = 'P�liza eliminada correctamente.';
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT
                p.PKIdPoliza,
                p.FKIdAnio_SIS,
                a.Clave AS AnioClave,
                p.FKIdMes_SIS,
                p.FKIdTipoPoliza_SIS,
                tp.Descripcion AS TipoPoliza,
                p.ClavePoliza,
                p.NombrePoliza,
                p.FechaPoliza,
                p.EstaBalanceado,
                p.PermitirModificar,
                p.FKIdAccionAutorizar_SIS,
                p.Autorizado,
                p.FechaSolicitud,
                p.FechaAutorizacion,
                p.Activo,
                p.FechaCreacion,
                p.UsuarioCreacion,
                p.FechaModificacion,
                p.UsuarioModificacion
            FROM CONTA.Poliza p
            LEFT JOIN SIS.Anio a ON p.FKIdAnio_SIS = a.PKIdAnio
            LEFT JOIN SIS.TipoPoliza tp ON p.FKIdTipoPoliza_SIS = tp.PKIdTipoPoliza
            WHERE p.PKIdPoliza = @PKIdPoliza;

            SET @tipo = 'OK';
            GOTO FINISH;
        END
        ELSE
        BEGIN
            SET @tipo = 'ERROR';
            SET @message = 'Acci�n no v�lida. Use 1=Insert, 2=Update, 3=Delete, 4=GetById';
            GOTO ERR_HANDLER;
        END

        FINISH:
        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRANSACTION;

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"', @tipo, '","mensaje":"', @message, '","liga":"idPoliza:', ISNULL(CAST(@Id AS NVARCHAR), ''), '"}')
        ) AS ResultJson;

        RETURN 0;

        ERR_HANDLER:
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END CATCH
END
GO

PRINT 'Procedimientos de CONTA creados exitosamente.';
GO

CREATE OR ALTER PROCEDURE [ORCO].[SP_MantenimientoPAAAS] (
    @Action INT,
    @PKIdPAAAS INT = NULL,
    @PKIdPAAASPartida INT = NULL,
    @PKIdPAAASDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdAnio_SIS INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @FKIdPersona_NOM INT = NULL,
    @Descripcion NVARCHAR(100) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @Fecha DATETIME = NULL,
    @FKIdProyecto_ORCO INT = NULL,
    @FKIdPrograma_PRES INT = NULL,
    @FKIdFuenteFinanciamiento_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @FKIdTipoBien_ALMA INT = NULL,
    @FKIdUnidades_ALMA INT = NULL,
    @Cantidad NUMERIC(8,2) = NULL,
    @LugarEntrega VARCHAR(200) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK';
    DECLARE @message NVARCHAR(4000) = '';
    DECLARE @Parameters NVARCHAR(4000) = '';
    DECLARE @liga NVARCHAR(100) = '';
    DECLARE @today DATETIME2 = SYSDATETIME();
    DECLARE @Id INT = NULL;

    SET @message = CONCAT('Iniciando el SP [ORCO].[SP_MantenimientoPAAAS]', ' @PKIdPAAAS ', @PKIdPAAAS);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdPAAAS=', ISNULL(CONVERT(NVARCHAR(30), @PKIdPAAAS), 'NULL'),
        ', PKIdPAAASPartida=', ISNULL(CONVERT(NVARCHAR(30), @PKIdPAAASPartida), 'NULL'),
        ', PKIdPAAASDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdPAAASDetalle), 'NULL'),
        ', FKIdEmpresa_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdEmpresa_SIS), 'NULL'),
        ', FKIdAnio_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdAnio_SIS), 'NULL'),
        ', FKIdArea_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdArea_SIS), 'NULL'),
        ', FKIdPersona_NOM=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPersona_NOM), 'NULL'),
        ', Descripcion=', ISNULL(LEFT(@Descripcion, 300), 'NULL'),
        ', Fecha=', ISNULL(CONVERT(NVARCHAR(30), @Fecha, 126), 'NULL'),
        ', FKIdPartida_CONTA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPartida_CONTA), 'NULL'),
        ', FKIdTipoBien_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdTipoBien_ALMA), 'NULL'),
        ', Cantidad=', ISNULL(CONVERT(NVARCHAR(30), @Cantidad), 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'ORCO.SP_MantenimientoPAAAS',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'ORCO.SP_MantenimientoPAAAS',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF EXISTS (SELECT 1 FROM ORCO.PAAAS WHERE FKIdArea_SIS = @FKIdArea_SIS AND FKIdAnio_SIS = @FKIdAnio_SIS AND Activo = 1)
                THROW 51000, 'Ya existe un programa anual activo para el mismo anio y area.', 1;

            INSERT INTO ORCO.PAAAS (
                FKIdEmpresa_SIS, FKIdAnio_SIS, FKIdArea_SIS, FKIdPersona_NOM,
                Descripcion, Observaciones, Fecha, FKIdProyecto_ORCO,
                FKIdPrograma_PRES, FKIdFuenteFinanciamiento_PRES,
                Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdAnio_SIS, @FKIdArea_SIS, @FKIdPersona_NOM,
                @Descripcion, @Observaciones, ISNULL(@Fecha, GETDATE()), @FKIdProyecto_ORCO,
                @FKIdPrograma_PRES, @FKIdFuenteFinanciamiento_PRES,
                1, @today, @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Programa anual creado correctamente.';
            SET @liga = CONCAT('idPAAAS:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdPAAAS IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAAS WHERE PKIdPAAAS = @PKIdPAAAS AND Activo = 1)
                THROW 51000, 'Programa anual no encontrado.', 1;

            IF EXISTS (SELECT 1 FROM ORCO.PAAAS WHERE FKIdArea_SIS = @FKIdArea_SIS AND FKIdAnio_SIS = @FKIdAnio_SIS AND PKIdPAAAS <> @PKIdPAAAS AND Activo = 1)
                THROW 51000, 'Ya existe otro programa anual activo para el mismo anio y area.', 1;

            UPDATE ORCO.PAAAS
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdAnio_SIS = @FKIdAnio_SIS,
                FKIdArea_SIS = @FKIdArea_SIS,
                FKIdPersona_NOM = @FKIdPersona_NOM,
                Descripcion = @Descripcion,
                Observaciones = @Observaciones,
                Fecha = ISNULL(@Fecha, Fecha),
                FKIdProyecto_ORCO = @FKIdProyecto_ORCO,
                FKIdPrograma_PRES = @FKIdPrograma_PRES,
                FKIdFuenteFinanciamiento_PRES = @FKIdFuenteFinanciamiento_PRES,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdPAAAS = @PKIdPAAAS;

            SET @Id = @PKIdPAAAS;
            SET @message = 'Programa anual actualizado correctamente.';
            SET @liga = CONCAT('idPAAAS:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdPAAAS IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAAS WHERE PKIdPAAAS = @PKIdPAAAS AND Activo = 1)
                THROW 51000, 'Programa anual no encontrado.', 1;

            UPDATE d SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            FROM ORCO.PAAASDetalle d
            INNER JOIN ORCO.PAAASPartida p ON d.FKIdPAAASPartida_ORCO = p.PKIdPAAASPartida
            WHERE p.FKIdPAAAS_ORCO = @PKIdPAAAS AND d.Activo = 1;

            UPDATE ORCO.PAAASPartida
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE FKIdPAAAS_ORCO = @PKIdPAAAS AND Activo = 1;

            UPDATE ORCO.PAAAS
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE PKIdPAAAS = @PKIdPAAAS;

            SET @Id = @PKIdPAAAS;
            SET @message = 'Programa anual eliminado correctamente.';
            SET @liga = CONCAT('idPAAAS:', @Id);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdPAAAS IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAAS WHERE PKIdPAAAS = @PKIdPAAAS AND Activo = 1)
                THROW 51000, 'PAAAS no encontrado.', 1;

            IF EXISTS (SELECT 1 FROM ORCO.PAAASPartida WHERE FKIdPAAAS_ORCO = @PKIdPAAAS AND FKIdPartida_CONTA = @FKIdPartida_CONTA AND Activo = 1)
                THROW 51000, 'La partida ya esta agregada en este PAAAS.', 1;

            INSERT INTO ORCO.PAAASPartida (FKIdEmpresa_SIS, FKIdPAAAS_ORCO, FKIdPartida_CONTA, Observaciones, Activo, FechaCreacion, UsuarioCreacion)
            SELECT ISNULL(@FKIdEmpresa_SIS, FKIdEmpresa_SIS), PKIdPAAAS, @FKIdPartida_CONTA, @Observaciones, 1, @today, @IdUser
            FROM ORCO.PAAAS
            WHERE PKIdPAAAS = @PKIdPAAAS;

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Partida creada correctamente.';
            SET @liga = CONCAT('idPAAASPartida:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdPAAASPartida IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAASPartida WHERE PKIdPAAASPartida = @PKIdPAAASPartida AND Activo = 1)
                THROW 51000, 'Partida no encontrada.', 1;

            UPDATE ORCO.PAAASDetalle
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE FKIdPAAASPartida_ORCO = @PKIdPAAASPartida AND Activo = 1;

            UPDATE ORCO.PAAASPartida
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE PKIdPAAASPartida = @PKIdPAAASPartida;

            SET @Id = @PKIdPAAASPartida;
            SET @message = 'Partida eliminada correctamente.';
            SET @liga = CONCAT('idPAAASPartida:', @Id);
        END
        ELSE IF @Action IN (7, 8)
        BEGIN
            DECLARE @PartidaConta INT, @EmpresaPartida INT, @UnidadTipoBien INT, @TipoPartida INT;

            IF @Action = 8 AND (@PKIdPAAASDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAASDetalle WHERE PKIdPAAASDetalle = @PKIdPAAASDetalle AND Activo = 1))
                THROW 51000, 'Detalle no encontrado.', 1;

            SELECT @PartidaConta = pp.FKIdPartida_CONTA, @EmpresaPartida = pp.FKIdEmpresa_SIS
            FROM ORCO.PAAASPartida pp
            WHERE pp.PKIdPAAASPartida = @PKIdPAAASPartida AND pp.Activo = 1;

            IF @PartidaConta IS NULL
                THROW 51000, 'Partida no encontrada.', 1;

            SELECT @UnidadTipoBien = FKIdUnidades_ALMA, @TipoPartida = FKIdPartida_CONTA
            FROM ALMA.TipoBien
            WHERE PKIdTipoBien = @FKIdTipoBien_ALMA AND Activo = 1;

            IF @TipoPartida IS NULL
                THROW 51000, 'Tipo de bien no encontrado.', 1;

            IF @TipoPartida <> @PartidaConta
                THROW 51000, 'El tipo de bien no pertenece a la partida seleccionada.', 1;

            IF ISNULL(@Cantidad, 0) <= 0
                THROW 51000, 'La cantidad debe ser mayor a cero.', 1;

            IF @Action = 7
            BEGIN
                INSERT INTO ORCO.PAAASDetalle (
                    FKIdEmpresa_SIS, FKIdPAAASPartida_ORCO, FKIdTipoBien_ALMA, FKIdUnidades_ALMA,
                    Cantidad, Observaciones, LugarEntrega, Activo, FechaCreacion, UsuarioCreacion
                )
                VALUES (
                    ISNULL(@FKIdEmpresa_SIS, @EmpresaPartida), @PKIdPAAASPartida, @FKIdTipoBien_ALMA, ISNULL(@FKIdUnidades_ALMA, @UnidadTipoBien),
                    @Cantidad, ISNULL(@Observaciones, ''), ISNULL(@LugarEntrega, ''), 1, @today, @IdUser
                );

                SET @Id = SCOPE_IDENTITY();
                SET @message = 'Tipo de bien agregado correctamente.';
            END
            ELSE
            BEGIN
                UPDATE ORCO.PAAASDetalle
                SET FKIdEmpresa_SIS = ISNULL(@FKIdEmpresa_SIS, @EmpresaPartida),
                    FKIdPAAASPartida_ORCO = @PKIdPAAASPartida,
                    FKIdTipoBien_ALMA = @FKIdTipoBien_ALMA,
                    FKIdUnidades_ALMA = ISNULL(@FKIdUnidades_ALMA, @UnidadTipoBien),
                    Cantidad = @Cantidad,
                    Observaciones = ISNULL(@Observaciones, ''),
                    LugarEntrega = ISNULL(@LugarEntrega, ''),
                    FechaModificacion = @today,
                    UsuarioModificacion = @IdUser
                WHERE PKIdPAAASDetalle = @PKIdPAAASDetalle;

                SET @Id = @PKIdPAAASDetalle;
                SET @message = 'Tipo de bien actualizado correctamente.';
            END

            SET @liga = CONCAT('idPAAASDetalle:', @Id);
        END
        ELSE IF @Action = 9
        BEGIN
            IF @PKIdPAAASDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.PAAASDetalle WHERE PKIdPAAASDetalle = @PKIdPAAASDetalle AND Activo = 1)
                THROW 51000, 'Detalle no encontrado.', 1;

            UPDATE ORCO.PAAASDetalle
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            WHERE PKIdPAAASDetalle = @PKIdPAAASDetalle;

            SET @Id = @PKIdPAAASDetalle;
            SET @message = 'Tipo de bien eliminado correctamente.';
            SET @liga = CONCAT('idPAAASDetalle:', @Id);
        END
        ELSE
            THROW 51000, 'Accion no valida para PAAAS.', 1;

        COMMIT TRANSACTION;

        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [ORCO].[SP_MantenimientoEstudioMercado] (
    @Action INT,
    @PKIdEstudioMercado INT = NULL,
    @PKIdEstudioMercadoDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdAnio_SIS INT = NULL,
    @Nombre VARCHAR(80) = NULL,
    @Descripcion NVARCHAR(500) = NULL,
    @FechaSolicitud DATETIME = NULL,
    @FechaCierre DATETIME = NULL,
    @FKIdResponsable_NOM INT = NULL,
    @Estatus INT = NULL,
    @FKIdPAAASDetalle_ORCO INT = NULL,
    @FKIdTipoBien_ALMA INT = NULL,
    @Cantidad NUMERIC(8,2) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL,
    @FKIdProveedor_SIS INT = NULL,
    @CostoUnitario DECIMAL(20,4) = NULL,
    @FechaCompromisoEntrega DATETIME = NULL,
    @Comentarios NVARCHAR(MAX) = NULL,
    @ItemsJson NVARCHAR(MAX) = NULL,
    @ProveedorIdsJson NVARCHAR(MAX) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [ORCO].[SP_MantenimientoEstudioMercado]', ' @PKIdEstudioMercado ', @PKIdEstudioMercado);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdEstudioMercado=', ISNULL(CONVERT(NVARCHAR(30), @PKIdEstudioMercado), 'NULL'),
        ', PKIdEstudioMercadoDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdEstudioMercadoDetalle), 'NULL'),
        ', FKIdEmpresa_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdEmpresa_SIS), 'NULL'),
        ', FKIdAnio_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdAnio_SIS), 'NULL'),
        ', Nombre=', ISNULL(LEFT(@Nombre, 300), 'NULL'),
        ', FechaSolicitud=', ISNULL(CONVERT(NVARCHAR(30), @FechaSolicitud, 126), 'NULL'),
        ', FechaCierre=', ISNULL(CONVERT(NVARCHAR(30), @FechaCierre, 126), 'NULL'),
        ', FKIdResponsable_NOM=', ISNULL(CONVERT(NVARCHAR(30), @FKIdResponsable_NOM), 'NULL'),
        ', Estatus=', ISNULL(CONVERT(NVARCHAR(30), @Estatus), 'NULL'),
        ', FKIdPAAASDetalle_ORCO=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPAAASDetalle_ORCO), 'NULL'),
        ', FKIdTipoBien_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdTipoBien_ALMA), 'NULL'),
        ', Cantidad=', ISNULL(CONVERT(NVARCHAR(30), @Cantidad), 'NULL'),
        ', FKIdProveedor_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdProveedor_SIS), 'NULL'),
        ', CostoUnitario=', ISNULL(CONVERT(NVARCHAR(30), @CostoUnitario), 'NULL'),
        ', FechaCompromisoEntrega=', ISNULL(CONVERT(NVARCHAR(30), @FechaCompromisoEntrega, 126), 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'ORCO.SP_MantenimientoEstudioMercado',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'ORCO.SP_MantenimientoEstudioMercado',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF ISNULL(@FKIdEmpresa_SIS, 0) <= 0 OR ISNULL(@FKIdAnio_SIS, 0) <= 0 OR ISNULL(@FKIdResponsable_NOM, 0) <= 0 OR NULLIF(LTRIM(RTRIM(@Nombre)), '') IS NULL
                THROW 51000, 'Debe capturar empresa, anio, responsable y nombre del estudio.', 1;
            IF @FechaCierre IS NOT NULL AND @FechaCierre < ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE()))
                THROW 51000, 'La fecha de cierre no puede ser anterior a la solicitud.', 1;

            INSERT INTO ORCO.EstudioMercado (
                FKIdEmpresa_SIS, FKIdAnio_SIS, Nombre, Descripcion, FechaSolicitud, FechaCierre,
                FKIdResponsable_NOM, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdAnio_SIS, LTRIM(RTRIM(@Nombre)), @Descripcion, ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE())),
                @FechaCierre, @FKIdResponsable_NOM, ISNULL(NULLIF(@Estatus, 0), 1), 1, @today, @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Estudio de mercado creado correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdEstudioMercado IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercado WHERE PKIdEstudioMercado = @PKIdEstudioMercado AND Activo = 1)
                THROW 51000, 'Estudio de mercado no encontrado.', 1;
            IF @FechaCierre IS NOT NULL AND @FechaCierre < ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE()))
                THROW 51000, 'La fecha de cierre no puede ser anterior a la solicitud.', 1;

            UPDATE ORCO.EstudioMercado
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdAnio_SIS = @FKIdAnio_SIS,
                Nombre = LTRIM(RTRIM(@Nombre)),
                Descripcion = @Descripcion,
                FechaSolicitud = ISNULL(@FechaSolicitud, FechaSolicitud),
                FechaCierre = @FechaCierre,
                FKIdResponsable_NOM = @FKIdResponsable_NOM,
                Estatus = ISNULL(NULLIF(@Estatus, 0), Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdEstudioMercado = @PKIdEstudioMercado;

            SET @Id = @PKIdEstudioMercado;
            SET @message = 'Estudio de mercado actualizado correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdEstudioMercado IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercado WHERE PKIdEstudioMercado = @PKIdEstudioMercado AND Activo = 1)
                THROW 51000, 'Estudio de mercado no encontrado.', 1;

            UPDATE c
            SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser
            FROM ORCO.EstudioMercadoDetalleCosto c
            INNER JOIN ORCO.SolicitudCotizacion sc ON c.FKIdSolicitudCotizacion_ORCO = sc.PKIdSolicitudCotizacion
            WHERE sc.FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND c.Activo = 1;

            UPDATE ORCO.SolicitudCotizacion SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND Activo = 1;
            UPDATE ORCO.EstudioMercadoDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND Activo = 1;
            UPDATE ORCO.EstudioMercado SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdEstudioMercado = @PKIdEstudioMercado;

            SET @Id = @PKIdEstudioMercado;
            SET @message = 'Estudio de mercado eliminado correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @Id);
        END
        ELSE IF @Action IN (4, 5)
        BEGIN
            DECLARE @EstudioEmpresa INT, @EstudioAnio INT, @PaaasEmpresa INT, @PaaasAnio INT, @PaaasTipoBien INT, @PaaasCantidad NUMERIC(8,2), @PaaasObs NVARCHAR(MAX);

            SELECT @EstudioEmpresa = FKIdEmpresa_SIS, @EstudioAnio = FKIdAnio_SIS
            FROM ORCO.EstudioMercado
            WHERE PKIdEstudioMercado = @PKIdEstudioMercado AND Activo = 1;

            IF @EstudioEmpresa IS NULL
                THROW 51000, 'El estudio de mercado no existe o esta inactivo.', 1;

            SELECT @PaaasEmpresa = d.FKIdEmpresa_SIS,
                   @PaaasTipoBien = d.FKIdTipoBien_ALMA,
                   @PaaasCantidad = d.Cantidad,
                   @PaaasObs = d.Observaciones,
                   @PaaasAnio = p.FKIdAnio_SIS
            FROM ORCO.PAAASDetalle d
            INNER JOIN ORCO.PAAASPartida pp ON d.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida AND pp.Activo = 1
            INNER JOIN ORCO.PAAAS p ON pp.FKIdPAAAS_ORCO = p.PKIdPAAAS AND p.Activo = 1
            WHERE d.PKIdPAAASDetalle = @FKIdPAAASDetalle_ORCO AND d.Activo = 1;

            IF @PaaasEmpresa IS NULL
                THROW 51000, 'El bien del PAAAS no existe o esta inactivo.', 1;
            IF @PaaasEmpresa <> @EstudioEmpresa
                THROW 51000, 'Los bienes seleccionados no pertenecen a la empresa del estudio.', 1;
            IF @PaaasAnio <> @EstudioAnio
                THROW 51000, 'Los bienes seleccionados no pertenecen al anio presupuestal del estudio.', 1;
            IF @CostoUnitario IS NOT NULL AND @CostoUnitario <= 0
                THROW 51000, 'El costo unitario debe ser mayor a cero.', 1;
            IF @FKIdProveedor_SIS IS NOT NULL AND NOT EXISTS (SELECT 1 FROM SIS.Proveedor WHERE PKIdProveedor = @FKIdProveedor_SIS AND Activo = 1)
                THROW 51000, 'El proveedor seleccionado no existe o esta inactivo.', 1;

            IF @Action = 4 AND @FKIdProveedor_SIS IS NOT NULL AND EXISTS (
                SELECT 1 FROM ORCO.EstudioMercadoDetalle
                WHERE FKIdEstudioMercado_ORCO = @PKIdEstudioMercado
                  AND FKIdTipoBien_ALMA = @PaaasTipoBien
                  AND FKIdProveedor_SIS = @FKIdProveedor_SIS
                  AND Activo = 1
            )
                THROW 51000, 'Ya existe un precio de mercado para este tipo de bien con el mismo proveedor.', 1;

            IF @Action = 4
            BEGIN
                INSERT INTO ORCO.EstudioMercadoDetalle (
                    FKIdEmpresa_SIS, FKIdEstudioMercado_ORCO, FKIdPAAASDetalle_ORCO, FKIdTipoBien_ALMA,
                    Cantidad, Observaciones, FKIdProveedor_SIS, CostoUnitario, Activo, FechaCreacion, UsuarioCreacion
                )
                VALUES (
                    @EstudioEmpresa, @PKIdEstudioMercado, @FKIdPAAASDetalle_ORCO, @PaaasTipoBien,
                    ISNULL(NULLIF(@Cantidad, 0), @PaaasCantidad), COALESCE(NULLIF(LTRIM(RTRIM(@Observaciones)), ''), @PaaasObs),
                    @FKIdProveedor_SIS, @CostoUnitario, 1, @today, @IdUser
                );
                SET @Id = SCOPE_IDENTITY();
                SET @message = 'Detalle de estudio de mercado creado correctamente.';
            END
            ELSE
            BEGIN
                IF @PKIdEstudioMercadoDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercadoDetalle WHERE PKIdEstudioMercadoDetalle = @PKIdEstudioMercadoDetalle AND Activo = 1)
                    THROW 51000, 'Detalle de estudio de mercado no encontrado.', 1;

                UPDATE ORCO.EstudioMercadoDetalle
                SET FKIdPAAASDetalle_ORCO = @FKIdPAAASDetalle_ORCO,
                    FKIdTipoBien_ALMA = @PaaasTipoBien,
                    Cantidad = ISNULL(NULLIF(@Cantidad, 0), @PaaasCantidad),
                    Observaciones = COALESCE(NULLIF(LTRIM(RTRIM(@Observaciones)), ''), @PaaasObs),
                    FKIdProveedor_SIS = @FKIdProveedor_SIS,
                    CostoUnitario = @CostoUnitario,
                    FechaModificacion = @today,
                    UsuarioModificacion = @IdUser
                WHERE PKIdEstudioMercadoDetalle = @PKIdEstudioMercadoDetalle;

                SET @Id = @PKIdEstudioMercadoDetalle;
                SET @message = 'Detalle de estudio de mercado actualizado correctamente.';
            END
            SET @liga = CONCAT('idEstudioMercadoDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdEstudioMercadoDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercadoDetalle WHERE PKIdEstudioMercadoDetalle = @PKIdEstudioMercadoDetalle AND Activo = 1)
                THROW 51000, 'Detalle de estudio de mercado no encontrado.', 1;
            UPDATE ORCO.EstudioMercadoDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdEstudioMercadoDetalle = @PKIdEstudioMercadoDetalle;
            SET @Id = @PKIdEstudioMercadoDetalle;
            SET @message = 'Detalle de estudio de mercado eliminado correctamente.';
            SET @liga = CONCAT('idEstudioMercadoDetalle:', @Id);
        END
        ELSE IF @Action = 10
        BEGIN
            IF ISJSON(@ItemsJson) <> 1
                THROW 51000, 'Debe seleccionar al menos un detalle PAAAS.', 1;
            IF NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercado WHERE PKIdEstudioMercado = @PKIdEstudioMercado AND Activo = 1)
                THROW 51000, 'El estudio de mercado no existe o esta inactivo.', 1;

            DECLARE @Batch TABLE (FKIdPAAASDetalle_ORCO INT, FKIdProveedor_SIS INT, CostoUnitario DECIMAL(20,4), Observaciones NVARCHAR(MAX));
            INSERT INTO @Batch
            SELECT FKIdPAAASDetalle_ORCO, FKIdProveedor_SIS, CostoUnitario, Observaciones
            FROM OPENJSON(@ItemsJson)
            WITH (
                FKIdPAAASDetalle_ORCO INT '$.FkidPaaasdetalleOrco',
                FKIdProveedor_SIS INT '$.FkidProveedorSis',
                CostoUnitario DECIMAL(20,4) '$.CostoUnitario',
                Observaciones NVARCHAR(MAX) '$.Observaciones'
            )
            WHERE FKIdPAAASDetalle_ORCO > 0;

            IF NOT EXISTS (SELECT 1 FROM @Batch)
                THROW 51000, 'Debe seleccionar al menos un detalle PAAAS.', 1;
            IF EXISTS (SELECT 1 FROM @Batch WHERE ISNULL(FKIdProveedor_SIS, 0) <= 0)
                THROW 51000, 'Debe seleccionar proveedor para todos los detalles.', 1;
            IF EXISTS (SELECT 1 FROM @Batch WHERE ISNULL(CostoUnitario, 0) <= 0)
                THROW 51000, 'Todos los costos unitarios deben ser mayores a cero.', 1;
            IF EXISTS (SELECT 1 FROM @Batch b WHERE NOT EXISTS (SELECT 1 FROM SIS.Proveedor p WHERE p.PKIdProveedor = b.FKIdProveedor_SIS AND p.Activo = 1))
                THROW 51000, 'Uno o mas proveedores no existen o estan inactivos.', 1;

            INSERT INTO ORCO.EstudioMercadoDetalle (
                FKIdEmpresa_SIS, FKIdEstudioMercado_ORCO, FKIdPAAASDetalle_ORCO, FKIdTipoBien_ALMA,
                Cantidad, Observaciones, FKIdProveedor_SIS, CostoUnitario, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT em.FKIdEmpresa_SIS, em.PKIdEstudioMercado, pd.PKIdPAAASDetalle, pd.FKIdTipoBien_ALMA,
                   pd.Cantidad, COALESCE(NULLIF(LTRIM(RTRIM(b.Observaciones)), ''), pd.Observaciones),
                   b.FKIdProveedor_SIS, b.CostoUnitario, 1, @today, @IdUser
            FROM @Batch b
            INNER JOIN ORCO.PAAASDetalle pd ON pd.PKIdPAAASDetalle = b.FKIdPAAASDetalle_ORCO AND pd.Activo = 1
            INNER JOIN ORCO.PAAASPartida pp ON pd.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida AND pp.Activo = 1
            INNER JOIN ORCO.PAAAS p ON pp.FKIdPAAAS_ORCO = p.PKIdPAAAS AND p.Activo = 1
            INNER JOIN ORCO.EstudioMercado em ON em.PKIdEstudioMercado = @PKIdEstudioMercado AND em.Activo = 1
            WHERE pd.FKIdEmpresa_SIS = em.FKIdEmpresa_SIS
              AND p.FKIdAnio_SIS = em.FKIdAnio_SIS
              AND NOT EXISTS (
                  SELECT 1 FROM ORCO.EstudioMercadoDetalle ed
                  WHERE ed.FKIdEstudioMercado_ORCO = em.PKIdEstudioMercado
                    AND ed.FKIdTipoBien_ALMA = pd.FKIdTipoBien_ALMA
                    AND ed.FKIdProveedor_SIS = b.FKIdProveedor_SIS
                    AND ed.Activo = 1
              );

            SET @message = 'Detalles de estudio de mercado creados correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @PKIdEstudioMercado);
        END
        ELSE IF @Action = 20
        BEGIN
            IF ISJSON(@ItemsJson) <> 1 OR ISJSON(@ProveedorIdsJson) <> 1
                THROW 51000, 'Debe seleccionar bienes y proveedores para cotizar.', 1;

            DECLARE @CotItems TABLE (FKIdPAAASDetalle_ORCO INT PRIMARY KEY, Observaciones NVARCHAR(MAX));
            DECLARE @Proveedores TABLE (FKIdProveedor_SIS INT PRIMARY KEY);

            INSERT INTO @CotItems
            SELECT FKIdPAAASDetalle_ORCO, MAX(Observaciones)
            FROM OPENJSON(@ItemsJson)
            WITH (FKIdPAAASDetalle_ORCO INT '$.FkidPaaasdetalleOrco', Observaciones NVARCHAR(MAX) '$.Observaciones')
            WHERE FKIdPAAASDetalle_ORCO > 0
            GROUP BY FKIdPAAASDetalle_ORCO;

            INSERT INTO @Proveedores
            SELECT DISTINCT TRY_CONVERT(INT, value)
            FROM OPENJSON(@ProveedorIdsJson)
            WHERE TRY_CONVERT(INT, value) > 0;

            IF NOT EXISTS (SELECT 1 FROM @CotItems)
                THROW 51000, 'Debe seleccionar al menos un bien del PAAAS.', 1;
            IF NOT EXISTS (SELECT 1 FROM @Proveedores)
                THROW 51000, 'Debe seleccionar al menos un proveedor para cotizar.', 1;
            IF EXISTS (SELECT 1 FROM @Proveedores p WHERE NOT EXISTS (SELECT 1 FROM SIS.Proveedor pr WHERE pr.PKIdProveedor = p.FKIdProveedor_SIS AND pr.Activo = 1))
                THROW 51000, 'Uno o mas proveedores no existen o estan inactivos.', 1;

            DECLARE @DetalleByPaaas TABLE (FKIdPAAASDetalle_ORCO INT PRIMARY KEY, PKIdEstudioMercadoDetalle INT);

            INSERT INTO @DetalleByPaaas
            SELECT ed.FKIdPAAASDetalle_ORCO, ed.PKIdEstudioMercadoDetalle
            FROM ORCO.EstudioMercadoDetalle ed
            INNER JOIN @CotItems i ON ed.FKIdPAAASDetalle_ORCO = i.FKIdPAAASDetalle_ORCO
            WHERE ed.FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND ed.Activo = 1;

            INSERT INTO ORCO.EstudioMercadoDetalle (
                FKIdEmpresa_SIS, FKIdEstudioMercado_ORCO, FKIdPAAASDetalle_ORCO, FKIdTipoBien_ALMA,
                Cantidad, Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            OUTPUT inserted.FKIdPAAASDetalle_ORCO, inserted.PKIdEstudioMercadoDetalle INTO @DetalleByPaaas
            SELECT em.FKIdEmpresa_SIS, em.PKIdEstudioMercado, pd.PKIdPAAASDetalle, pd.FKIdTipoBien_ALMA,
                   pd.Cantidad, COALESCE(NULLIF(LTRIM(RTRIM(i.Observaciones)), ''), pd.Observaciones),
                   1, @today, @IdUser
            FROM @CotItems i
            INNER JOIN ORCO.PAAASDetalle pd ON pd.PKIdPAAASDetalle = i.FKIdPAAASDetalle_ORCO AND pd.Activo = 1
            INNER JOIN ORCO.PAAASPartida pp ON pd.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida AND pp.Activo = 1
            INNER JOIN ORCO.PAAAS p ON pp.FKIdPAAAS_ORCO = p.PKIdPAAAS AND p.Activo = 1
            INNER JOIN ORCO.EstudioMercado em ON em.PKIdEstudioMercado = @PKIdEstudioMercado AND em.Activo = 1
            WHERE pd.FKIdEmpresa_SIS = em.FKIdEmpresa_SIS
              AND p.FKIdAnio_SIS = em.FKIdAnio_SIS
              AND NOT EXISTS (SELECT 1 FROM @DetalleByPaaas d WHERE d.FKIdPAAASDetalle_ORCO = pd.PKIdPAAASDetalle);

            DECLARE @SolicitudByProveedor TABLE (FKIdProveedor_SIS INT PRIMARY KEY, PKIdSolicitudCotizacion INT);

            INSERT INTO @SolicitudByProveedor
            SELECT sc.FKIdProveedor_SIS, sc.PKIdSolicitudCotizacion
            FROM ORCO.SolicitudCotizacion sc
            INNER JOIN @Proveedores p ON sc.FKIdProveedor_SIS = p.FKIdProveedor_SIS
            WHERE sc.FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND sc.Activo = 1;

            INSERT INTO ORCO.SolicitudCotizacion (
                FKIdEmpresa_SIS, FKIdEstudioMercado_ORCO, FKIdProveedor_SIS, FechaSolicitud,
                FechaCompromisoEntrega, Comentarios, Estatus, Activo, FechaCreacion, UsuarioCreacion
            )
            OUTPUT inserted.FKIdProveedor_SIS, inserted.PKIdSolicitudCotizacion INTO @SolicitudByProveedor
            SELECT em.FKIdEmpresa_SIS, em.PKIdEstudioMercado, p.FKIdProveedor_SIS, @today,
                   @FechaCompromisoEntrega, NULLIF(LTRIM(RTRIM(@Comentarios)), ''), 1, 1, @today, @IdUser
            FROM @Proveedores p
            CROSS JOIN ORCO.EstudioMercado em
            WHERE em.PKIdEstudioMercado = @PKIdEstudioMercado
              AND em.Activo = 1
              AND NOT EXISTS (SELECT 1 FROM @SolicitudByProveedor s WHERE s.FKIdProveedor_SIS = p.FKIdProveedor_SIS);

            INSERT INTO ORCO.EstudioMercadoDetalleCosto (
                FKIdEmpresa_SIS, FKIdSolicitudCotizacion_ORCO, FKIdEstudioMercadoDetalle_ORCO,
                Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT em.FKIdEmpresa_SIS, s.PKIdSolicitudCotizacion, d.PKIdEstudioMercadoDetalle,
                   1, @today, @IdUser
            FROM @SolicitudByProveedor s
            CROSS JOIN @DetalleByPaaas d
            INNER JOIN ORCO.EstudioMercado em ON em.PKIdEstudioMercado = @PKIdEstudioMercado
            WHERE NOT EXISTS (
                SELECT 1 FROM ORCO.EstudioMercadoDetalleCosto c
                WHERE c.FKIdSolicitudCotizacion_ORCO = s.PKIdSolicitudCotizacion
                  AND c.FKIdEstudioMercadoDetalle_ORCO = d.PKIdEstudioMercadoDetalle
                  AND c.Activo = 1
            );

            SET @message = 'Solicitudes de cotizacion generadas correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @PKIdEstudioMercado);
        END
        ELSE IF @Action = 30
        BEGIN
            IF ISJSON(@ItemsJson) <> 1
                THROW 51000, 'No hay cotizaciones para guardar.', 1;

            DECLARE @Recepcion TABLE (PKIdEstudioMercadoDetalleCosto INT PRIMARY KEY, PrecioUnitario DECIMAL(20,4) NULL, TiempoEntregaDias INT NULL, Condiciones NVARCHAR(500) NULL);
            INSERT INTO @Recepcion
            SELECT PKIdEstudioMercadoDetalleCosto, PrecioUnitario, TiempoEntregaDias, Condiciones
            FROM OPENJSON(@ItemsJson)
            WITH (
                PKIdEstudioMercadoDetalleCosto INT '$.PkidEstudioMercadoDetalleCosto',
                PrecioUnitario DECIMAL(20,4) '$.PrecioUnitario',
                TiempoEntregaDias INT '$.TiempoEntregaDias',
                Condiciones NVARCHAR(500) '$.Condiciones'
            )
            WHERE PKIdEstudioMercadoDetalleCosto > 0;

            IF NOT EXISTS (SELECT 1 FROM @Recepcion)
                THROW 51000, 'No hay cotizaciones para guardar.', 1;
            IF EXISTS (SELECT 1 FROM @Recepcion WHERE PrecioUnitario <= 0)
                THROW 51000, 'Los precios capturados deben ser mayores a cero.', 1;
            IF EXISTS (SELECT 1 FROM @Recepcion WHERE TiempoEntregaDias < 0)
                THROW 51000, 'El tiempo de entrega no puede ser negativo.', 1;
            IF EXISTS (
                SELECT 1 FROM @Recepcion r
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM ORCO.EstudioMercadoDetalleCosto c
                    INNER JOIN ORCO.SolicitudCotizacion sc ON c.FKIdSolicitudCotizacion_ORCO = sc.PKIdSolicitudCotizacion
                    WHERE c.PKIdEstudioMercadoDetalleCosto = r.PKIdEstudioMercadoDetalleCosto
                      AND c.Activo = 1
                      AND sc.Activo = 1
                      AND sc.FKIdEstudioMercado_ORCO = @PKIdEstudioMercado
                )
            )
                THROW 51000, 'Una o mas cotizaciones no existen o no pertenecen al estudio seleccionado.', 1;

            UPDATE c
            SET PrecioUnitario = r.PrecioUnitario,
                TiempoEntregaDias = CASE WHEN r.PrecioUnitario IS NOT NULL THEN r.TiempoEntregaDias ELSE NULL END,
                Condiciones = CASE WHEN r.PrecioUnitario IS NOT NULL THEN NULLIF(LTRIM(RTRIM(r.Condiciones)), '') ELSE NULL END,
                FechaRespuesta = CASE WHEN r.PrecioUnitario IS NOT NULL THEN ISNULL(c.FechaRespuesta, @today) ELSE NULL END,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM ORCO.EstudioMercadoDetalleCosto c
            INNER JOIN @Recepcion r ON c.PKIdEstudioMercadoDetalleCosto = r.PKIdEstudioMercadoDetalleCosto;

            ;WITH Conteos AS (
                SELECT sc.PKIdSolicitudCotizacion,
                       COUNT(c.PKIdEstudioMercadoDetalleCosto) AS Total,
                       SUM(CASE WHEN c.PrecioUnitario IS NOT NULL THEN 1 ELSE 0 END) AS Recibidas
                FROM ORCO.SolicitudCotizacion sc
                INNER JOIN ORCO.EstudioMercadoDetalleCosto c ON sc.PKIdSolicitudCotizacion = c.FKIdSolicitudCotizacion_ORCO AND c.Activo = 1
                WHERE sc.FKIdEstudioMercado_ORCO = @PKIdEstudioMercado AND sc.Activo = 1
                GROUP BY sc.PKIdSolicitudCotizacion
            )
            UPDATE sc
            SET Estatus = CASE WHEN c.Recibidas = 0 THEN 1 WHEN c.Recibidas < c.Total THEN 2 ELSE 3 END,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM ORCO.SolicitudCotizacion sc
            INNER JOIN Conteos c ON sc.PKIdSolicitudCotizacion = c.PKIdSolicitudCotizacion;

            SET @message = 'Cotizaciones guardadas correctamente.';
            SET @liga = CONCAT('idEstudioMercado:', @PKIdEstudioMercado);
        END
        ELSE
            THROW 51000, 'Accion no valida para estudio de mercado.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO

PRINT 'Procedimientos de adquisiciones creados exitosamente.';
GO

CREATE OR ALTER PROCEDURE [ORCO].[SP_MantenimientoCotizacion] (
    @Action INT,
    @PKIdCotizacion INT = NULL,
    @FKIdRequisicion_ORCO INT = NULL,
    @FKIdProveedor_SIS INT = NULL,
    @FechaSolicitud DATETIME = NULL,
    @FechaProveedorCotiza DATETIME = NULL,
    @FechaProveedorCompromiso DATETIME = NULL,
    @Comentarios NVARCHAR(MAX) = NULL,
    @Servicio BIT = NULL,
    @FL_Documento NVARCHAR(1000) = NULL,
    @Entrega NVARCHAR(MAX) = NULL,
    @Vigencia NVARCHAR(MAX) = NULL,
    @Condiciones NVARCHAR(200) = NULL,
    @FKIdAnio_SIS INT = NULL,
    @FKIdContenedorCot_ORCO INT = NULL,
    @FKIdContenedorMultiCot_ORCO INT = NULL,
    @ItemsJson NVARCHAR(MAX) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;
    DECLARE @Seeded INT = 0;

    SET @message = CONCAT('Iniciando el SP [ORCO].[SP_MantenimientoCotizacion]', ' @PKIdCotizacion ', @PKIdCotizacion);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdCotizacion=', ISNULL(CONVERT(NVARCHAR(30), @PKIdCotizacion), 'NULL'),
        ', FKIdRequisicion_ORCO=', ISNULL(CONVERT(NVARCHAR(30), @FKIdRequisicion_ORCO), 'NULL'),
        ', FKIdProveedor_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdProveedor_SIS), 'NULL'),
        ', FechaSolicitud=', ISNULL(CONVERT(NVARCHAR(30), @FechaSolicitud, 126), 'NULL'),
        ', FechaProveedorCotiza=', ISNULL(CONVERT(NVARCHAR(30), @FechaProveedorCotiza, 126), 'NULL'),
        ', FechaProveedorCompromiso=', ISNULL(CONVERT(NVARCHAR(30), @FechaProveedorCompromiso, 126), 'NULL'),
        ', Servicio=', ISNULL(CONVERT(NVARCHAR(30), @Servicio), 'NULL'),
        ', FKIdAnio_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdAnio_SIS), 'NULL'),
        ', FKIdContenedorCot_ORCO=', ISNULL(CONVERT(NVARCHAR(30), @FKIdContenedorCot_ORCO), 'NULL'),
        ', FKIdContenedorMultiCot_ORCO=', ISNULL(CONVERT(NVARCHAR(30), @FKIdContenedorMultiCot_ORCO), 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'ORCO.SP_MantenimientoCotizacion',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'ORCO.SP_MantenimientoCotizacion',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM ORCO.Requisicion WHERE PKIdRequisicion = @FKIdRequisicion_ORCO AND Activo = 1)
                THROW 51000, 'La requisicion no existe o esta inactiva.', 1;
            IF NOT EXISTS (SELECT 1 FROM SIS.Proveedor WHERE PKIdProveedor = @FKIdProveedor_SIS AND Activo = 1)
                THROW 51000, 'El proveedor no existe o esta inactivo.', 1;
            IF NOT EXISTS (SELECT 1 FROM ORCO.RequisicionDetalle WHERE FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO AND Activo = 1)
                THROW 51000, 'La requisicion debe tener al menos un bien para generar una cotizacion.', 1;

            INSERT INTO ORCO.Cotizacion (
                FKIdRequisicion_ORCO, FKIdProveedor_SIS, FechaSolicitud, FechaProveedorCotiza, FechaProveedorCompromiso,
                Comentarios, Servicio, FL_Documento, Entrega, Vigencia, Condiciones, FKIdAnio_SIS,
                FKIdContenedorCot_ORCO, FKIdContenedorMultiCot_ORCO, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT @FKIdRequisicion_ORCO, @FKIdProveedor_SIS, ISNULL(@FechaSolicitud, GETDATE()), @FechaProveedorCotiza, @FechaProveedorCompromiso,
                   ISNULL(@Comentarios, ''), r.Servicio, ISNULL(@FL_Documento, ''), ISNULL(@Entrega, ''), ISNULL(@Vigencia, ''), ISNULL(@Condiciones, ''),
                   ISNULL(@FKIdAnio_SIS, r.FKIdAnio_SIS), @FKIdContenedorCot_ORCO, @FKIdContenedorMultiCot_ORCO, 1, @today, @IdUser
            FROM ORCO.Requisicion r
            WHERE r.PKIdRequisicion = @FKIdRequisicion_ORCO;

            SET @Id = SCOPE_IDENTITY();

            INSERT INTO ORCO.CotizacionDetalle (FKIdCotizacion_ORCO, FKIdRequisicionDetalle_ORCO, PrecioUnitario, Activo, FechaCreacion, UsuarioCreacion)
            SELECT @Id, rd.PKIdRequisicionDetalle, NULL, 1, @today, @IdUser
            FROM ORCO.RequisicionDetalle rd
            WHERE rd.FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO
              AND rd.Activo = 1;

            SET @Seeded = @@ROWCOUNT;
            SET @message = CONCAT('Cotizacion creada correctamente con ', @Seeded, ' bienes cargados desde la requisicion.');
            SET @liga = CONCAT('idCotizacion:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdCotizacion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Cotizacion WHERE PKIdCotizacion = @PKIdCotizacion AND Activo = 1)
                THROW 51000, 'Cotizacion no encontrada.', 1;
            IF NOT EXISTS (SELECT 1 FROM SIS.Proveedor WHERE PKIdProveedor = @FKIdProveedor_SIS AND Activo = 1)
                THROW 51000, 'El proveedor no existe o esta inactivo.', 1;

            UPDATE ORCO.Cotizacion
            SET FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO,
                FKIdProveedor_SIS = @FKIdProveedor_SIS,
                FechaSolicitud = ISNULL(@FechaSolicitud, FechaSolicitud),
                FechaProveedorCotiza = @FechaProveedorCotiza,
                FechaProveedorCompromiso = @FechaProveedorCompromiso,
                Comentarios = ISNULL(@Comentarios, ''),
                Servicio = ISNULL(@Servicio, Servicio),
                FL_Documento = ISNULL(@FL_Documento, ''),
                Entrega = ISNULL(@Entrega, ''),
                Vigencia = ISNULL(@Vigencia, ''),
                Condiciones = ISNULL(@Condiciones, ''),
                FKIdAnio_SIS = @FKIdAnio_SIS,
                FKIdContenedorCot_ORCO = @FKIdContenedorCot_ORCO,
                FKIdContenedorMultiCot_ORCO = @FKIdContenedorMultiCot_ORCO,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdCotizacion = @PKIdCotizacion;

            SET @Id = @PKIdCotizacion;
            SET @message = 'Cotizacion actualizada correctamente.';
            SET @liga = CONCAT('idCotizacion:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdCotizacion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Cotizacion WHERE PKIdCotizacion = @PKIdCotizacion AND Activo = 1)
                THROW 51000, 'Cotizacion no encontrada.', 1;

            UPDATE ORCO.CotizacionDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdCotizacion_ORCO = @PKIdCotizacion AND Activo = 1;
            UPDATE ORCO.Cotizacion SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdCotizacion = @PKIdCotizacion;

            SET @Id = @PKIdCotizacion;
            SET @message = 'Cotizacion eliminada correctamente.';
            SET @liga = CONCAT('idCotizacion:', @Id);
        END
        ELSE IF @Action = 4
        BEGIN
            IF @PKIdCotizacion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Cotizacion WHERE PKIdCotizacion = @PKIdCotizacion AND Activo = 1)
                THROW 51000, 'Cotizacion no encontrada.', 1;
            IF ISJSON(@ItemsJson) <> 1
                THROW 51000, 'No hay bienes cotizados para guardar.', 1;
            IF EXISTS (SELECT 1 FROM OPENJSON(@ItemsJson) WITH (PrecioUnitario DECIMAL(20,4) '$.PrecioUnitario') WHERE PrecioUnitario <= 0)
                THROW 51000, 'Los precios capturados deben ser mayores a cero.', 1;

            DECLARE @Items TABLE (PKIdCotizacionDetalle INT PRIMARY KEY, PrecioUnitario DECIMAL(20,4) NULL);
            INSERT INTO @Items (PKIdCotizacionDetalle, PrecioUnitario)
            SELECT PKIdCotizacionDetalle, PrecioUnitario
            FROM OPENJSON(@ItemsJson)
            WITH (PKIdCotizacionDetalle INT '$.PkidCotizacionDetalle', PrecioUnitario DECIMAL(20,4) '$.PrecioUnitario')
            WHERE PKIdCotizacionDetalle > 0;

            IF NOT EXISTS (SELECT 1 FROM @Items)
                THROW 51000, 'No hay bienes cotizados para guardar.', 1;
            IF EXISTS (
                SELECT 1 FROM @Items i
                WHERE NOT EXISTS (
                    SELECT 1 FROM ORCO.CotizacionDetalle cd
                    WHERE cd.PKIdCotizacionDetalle = i.PKIdCotizacionDetalle
                      AND cd.FKIdCotizacion_ORCO = @PKIdCotizacion
                      AND cd.Activo = 1
                )
            )
                THROW 51000, 'Uno o mas bienes no pertenecen a la cotizacion seleccionada.', 1;

            UPDATE cd
            SET PrecioUnitario = i.PrecioUnitario,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM ORCO.CotizacionDetalle cd
            INNER JOIN @Items i ON cd.PKIdCotizacionDetalle = i.PKIdCotizacionDetalle;

            IF EXISTS (SELECT 1 FROM @Items WHERE PrecioUnitario IS NOT NULL)
            BEGIN
                UPDATE ORCO.Cotizacion
                SET FechaProveedorCotiza = ISNULL(FechaProveedorCotiza, CONVERT(DATE, GETDATE())),
                    FechaModificacion = @today,
                    UsuarioModificacion = @IdUser
                WHERE PKIdCotizacion = @PKIdCotizacion;
            END

            SET @Id = @PKIdCotizacion;
            SET @message = 'Montos cotizados guardados correctamente.';
            SET @liga = CONCAT('idCotizacion:', @Id);
        END
        ELSE IF @Action = 5
        BEGIN
            IF @PKIdCotizacion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Cotizacion WHERE PKIdCotizacion = @PKIdCotizacion AND Activo = 1)
                THROW 51000, 'Cotizacion no encontrada.', 1;

            INSERT INTO ORCO.CotizacionDetalle (FKIdCotizacion_ORCO, FKIdRequisicionDetalle_ORCO, PrecioUnitario, Activo, FechaCreacion, UsuarioCreacion)
            SELECT c.PKIdCotizacion, rd.PKIdRequisicionDetalle, NULL, 1, @today, @IdUser
            FROM ORCO.Cotizacion c
            INNER JOIN ORCO.RequisicionDetalle rd ON rd.FKIdRequisicion_ORCO = c.FKIdRequisicion_ORCO AND rd.Activo = 1
            WHERE c.PKIdCotizacion = @PKIdCotizacion
              AND NOT EXISTS (
                  SELECT 1 FROM ORCO.CotizacionDetalle cd
                  WHERE cd.FKIdCotizacion_ORCO = c.PKIdCotizacion
                    AND cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle
                    AND cd.Activo = 1
              );

            SET @Seeded = @@ROWCOUNT;
            SET @Id = @PKIdCotizacion;
            SET @message = CONCAT('Detalles de cotizacion sincronizados: ', @Seeded, '.');
            SET @liga = CONCAT('idCotizacion:', @Id);
        END
        ELSE
            THROW 51000, 'Accion no valida para cotizacion.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [PRES].[SP_MantenimientoSolicitudSuficiencia] (
    @Action INT,
    @PKIdSolicitudSuficiencia INT = NULL,
    @FKIdRequisicion_ORCO INT = NULL,
    @FechaSolicitud DATE = NULL,
    @Justificacion NVARCHAR(1000) = NULL,
    @GastoNoProgramable VARCHAR(3) = NULL,
    @IdGastoNoProgramable INT = NULL,
    @IdCompromisoNomina INT = NULL,
    @Estatus INT = NULL,
    @PorcentajeAjuste DECIMAL(10,4) = 0,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '' , @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [PRES].[SP_MantenimientoSolicitudSuficiencia]', ' @Estatus ' ,@Estatus)
    SET @Parameters = CONCAT('Action=', @Action, ', PKIdSolicitudSuficiencia=', @PKIdSolicitudSuficiencia, ', FKIdRequisicion_ORCO=', @FKIdRequisicion_ORCO, ', FechaSolicitud=', ISNULL(CONVERT(NVARCHAR(30), @FechaSolicitud, 126), 'NULL'), ', Justificacion=', ISNULL(@Justificacion, 'NULL'), ', GastoNoProgramable=', ISNULL(@GastoNoProgramable, 'NULL'), ', IdGastoNoProgramable=', ISNULL(CONVERT(NVARCHAR(30), @IdGastoNoProgramable), 'NULL'), ', IdCompromisoNomina=', ISNULL(CONVERT(NVARCHAR(30), @IdCompromisoNomina), 'NULL'), ', Estatus=', ISNULL(CONVERT(NVARCHAR(30), @Estatus), 'NULL'), ', PorcentajeAjuste=', CONVERT(NVARCHAR(30), @PorcentajeAjuste))
    EXEC [SIS].[WriteSystemLog] 
	    @FK_IdOrigenLogMessage__SIS  = 1
	    ,@Date = @today
	    ,@_Type = 1
	    ,@ProgName = 'PRES.SP_MantenimientoSolicitudSuficiencia'
	    ,@EmployeeNo = @IdUser
	    ,@Category  = NULL
	    ,@IPClient  = NULL
	    ,@HostName  = NULL
	    ,@Thread    = NULL 
	    ,@Level = 'INFO' 
	    ,@Logger  =NULL 
	    ,@Message = @message
	    ,@Exception  = null
	    ,@Context   = null
	    ,@MethodName = 'PRES.SP_MantenimientoSolicitudSuficiencia'
	    ,@Parameters = @Parameters
        ,@ExecutionTime = '0'


        SET @message = ''
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action IN (1, 2, 10) AND NOT EXISTS (SELECT 1 FROM ORCO.Requisicion WHERE PKIdRequisicion = @FKIdRequisicion_ORCO AND Activo = 1)
            THROW 51000, 'La requisicion no existe o esta inactiva.', 1;

        IF @Action = 1
        BEGIN
            INSERT INTO PRES.SolicitudSuficiencia (
                FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FechaSolicitud, Justificacion,
                GastoNoProgramable, IdGastoNoProgramable, IdCompromisoNomina, Estatus,
                Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT FKIdEmpresa_SIS, PKIdRequisicion, ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE())), ISNULL(@Justificacion, ''),
                   @GastoNoProgramable, @IdGastoNoProgramable, @IdCompromisoNomina, ISNULL(NULLIF(@Estatus, 0), 1),
                   1, @today, @IdUser
            FROM ORCO.Requisicion
            WHERE PKIdRequisicion = @FKIdRequisicion_ORCO;

            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Solicitud de suficiencia creada correctamente.';
            SET @liga = CONCAT('idSolicitudSuficiencia:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdSolicitudSuficiencia IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.SolicitudSuficiencia WHERE PKIdSolicitudSuficiencia = @PKIdSolicitudSuficiencia AND Activo = 1)
                THROW 51000, 'Solicitud de suficiencia no encontrada.', 1;

            UPDATE ss
            SET FKIdEmpresa_SIS = r.FKIdEmpresa_SIS,
                FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO,
                FechaSolicitud = ISNULL(@FechaSolicitud, ss.FechaSolicitud),
                Justificacion = ISNULL(@Justificacion, ''),
                GastoNoProgramable = @GastoNoProgramable,
                IdGastoNoProgramable = @IdGastoNoProgramable,
                IdCompromisoNomina = @IdCompromisoNomina,
                Estatus = ISNULL(NULLIF(@Estatus, 0), ss.Estatus),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            FROM PRES.SolicitudSuficiencia ss
            INNER JOIN ORCO.Requisicion r ON r.PKIdRequisicion = @FKIdRequisicion_ORCO
            WHERE ss.PKIdSolicitudSuficiencia = @PKIdSolicitudSuficiencia;

            SET @Id = @PKIdSolicitudSuficiencia;
            SET @message = 'Solicitud de suficiencia actualizada correctamente.';
            SET @liga = CONCAT('idSolicitudSuficiencia:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdSolicitudSuficiencia IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.SolicitudSuficiencia WHERE PKIdSolicitudSuficiencia = @PKIdSolicitudSuficiencia AND Activo = 1)
                THROW 51000, 'Solicitud de suficiencia no encontrada.', 1;

            UPDATE PRES.SolicitudSuficienciaDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdSolicitudSuficiencia_PRES = @PKIdSolicitudSuficiencia AND Activo = 1;
            UPDATE PRES.SolicitudSuficiencia SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdSolicitudSuficiencia = @PKIdSolicitudSuficiencia;

            SET @Id = @PKIdSolicitudSuficiencia;
            SET @message = 'Solicitud de suficiencia eliminada correctamente.';
            SET @liga = CONCAT('idSolicitudSuficiencia:', @Id);
        END
        ELSE IF @Action = 10
        BEGIN
            IF @PorcentajeAjuste < 0
                THROW 51000, 'El porcentaje de ajuste no puede ser negativo.', 1;
            IF EXISTS (SELECT 1 FROM PRES.SolicitudSuficiencia WHERE FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO AND Activo = 1)
                THROW 51000, 'Ya existe una solicitud de suficiencia activa para esta requisicion.', 1;
            IF NOT EXISTS (SELECT 1 FROM ORCO.RequisicionDetalle WHERE FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO AND Activo = 1)
                THROW 51000, 'La requisicion debe tener al menos un bien para generar la solicitud.', 1;
            IF EXISTS (
                SELECT 1
                FROM ORCO.RequisicionDetalle rd
                INNER JOIN ALMA.TipoBien tb ON rd.FKIdTipoBien_ALMA = tb.PKIdTipoBien
                WHERE rd.FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO
                  AND rd.Activo = 1
                  AND ISNULL(tb.FKIdPartida_CONTA, 0) <= 0
            )
                THROW 51000, 'Hay bienes sin partida presupuestal configurada.', 1;
            IF EXISTS (SELECT 1 FROM ORCO.RequisicionDetalle WHERE FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO AND Activo = 1 AND Cantidad <= 0)
                THROW 51000, 'Todos los bienes de la requisicion deben tener cantidad mayor a cero.', 1;
            IF EXISTS (
                SELECT 1
                FROM ORCO.RequisicionDetalle rd
                WHERE rd.FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO
                  AND rd.Activo = 1
                  AND NOT EXISTS (
                      SELECT 1
                      FROM ORCO.CotizacionDetalle cd
                      INNER JOIN ORCO.Cotizacion c ON cd.FKIdCotizacion_ORCO = c.PKIdCotizacion
                      WHERE c.FKIdRequisicion_ORCO = @FKIdRequisicion_ORCO
                        AND c.Activo = 1
                        AND cd.Activo = 1
                        AND cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle
                        AND cd.PrecioUnitario > 0
                  )
            )
                THROW 51000, 'Todos los bienes deben tener al menos un monto cotizado.', 1;

            INSERT INTO PRES.SolicitudSuficiencia (
                FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FechaSolicitud, Justificacion,
                GastoNoProgramable, IdGastoNoProgramable, IdCompromisoNomina, Estatus,
                Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT FKIdEmpresa_SIS, PKIdRequisicion, ISNULL(@FechaSolicitud, CONVERT(DATE, GETDATE())), ISNULL(@Justificacion, ''),
                   @GastoNoProgramable, @IdGastoNoProgramable, @IdCompromisoNomina, 1, 1, @today, @IdUser
            FROM ORCO.Requisicion
            WHERE PKIdRequisicion = @FKIdRequisicion_ORCO;

            SET @Id = SCOPE_IDENTITY();

            ;WITH Cotizaciones AS (
                SELECT
                    rd.PKIdRequisicionDetalle,
                    r.FKIdEmpresa_SIS,
                    r.FechaRequisicion,
                    tb.FKIdPartida_CONTA,
                    rd.Cantidad,
                    AVG(CAST(cd.PrecioUnitario * rd.Cantidad AS DECIMAL(20,4))) AS PromedioImporte,
                    COUNT(*) AS Cotizaciones
                FROM ORCO.Requisicion r
                INNER JOIN ORCO.RequisicionDetalle rd ON r.PKIdRequisicion = rd.FKIdRequisicion_ORCO AND rd.Activo = 1
                INNER JOIN ALMA.TipoBien tb ON rd.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
                INNER JOIN ORCO.Cotizacion c ON r.PKIdRequisicion = c.FKIdRequisicion_ORCO AND c.Activo = 1
                INNER JOIN ORCO.CotizacionDetalle cd ON c.PKIdCotizacion = cd.FKIdCotizacion_ORCO AND cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle AND cd.Activo = 1 AND cd.PrecioUnitario > 0
                WHERE r.PKIdRequisicion = @FKIdRequisicion_ORCO
                GROUP BY rd.PKIdRequisicionDetalle, r.FKIdEmpresa_SIS, r.FechaRequisicion, tb.FKIdPartida_CONTA, rd.Cantidad
            ),
            Importes AS (
                SELECT *,
                    ROUND(PromedioImporte * (1 + (@PorcentajeAjuste / 100.0)), 4) AS ImporteAjustado,
                    MONTH(FechaRequisicion) AS Mes
                FROM Cotizaciones
            )
            INSERT INTO PRES.SolicitudSuficienciaDetalle (
                FKIdEmpresa_SIS, FKIdSolicitudSuficiencia_PRES, FKIdRequisicionDetalle_ORCO, FKIdPartida_CONTA,
                Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
                Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            SELECT FKIdEmpresa_SIS, @Id, PKIdRequisicionDetalle, FKIdPartida_CONTA,
                   CASE WHEN Mes = 1 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 2 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 3 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 4 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 5 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 6 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 7 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 8 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 9 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 10 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 11 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN Mes = 12 THEN ImporteAjustado ELSE 0 END,
                   CASE WHEN @PorcentajeAjuste = 0
                        THEN CONCAT('Promedio de ', Cotizaciones, ' cotizacion(es).')
                        ELSE CONCAT('Promedio de ', Cotizaciones, ' cotizacion(es) mas ', CONVERT(VARCHAR(32), CAST(@PorcentajeAjuste AS DECIMAL(10,2))), '% de ajuste.')
                   END,
                   1, @today, @IdUser
            FROM Importes;

            SET @message = 'Solicitud de suficiencia generada correctamente desde la requisicion.';
            SET @liga = CONCAT('idSolicitudSuficiencia:', @Id);
        END
        ELSE
            THROW 51000, 'Accion no valida para solicitud de suficiencia.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [ORCO].[SP_MantenimientoRequisicion] (
    @Action INT,
    @PKIdRequisicion INT = NULL,
    @PKIdRequisicionDetalle INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdPersona_NOM INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @Descripcion NVARCHAR(100) = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @FechaRequisicion DATETIME = NULL,
    @Servicio BIT = NULL,
    @FL_FOTO NVARCHAR(1000) = NULL,
    @FKIdProyecto_ORCO INT = NULL,
    @FechaRequiereInicio DATETIME = NULL,
    @FechaRequiereFin DATETIME = NULL,
    @FKIdPrograma_PRES INT = NULL,
    @Importe DECIMAL(20,4) = NULL,
    @FKIdJefeAlmacen_NOM INT = NULL,
    @FKIdSuficiencia_PRES INT = NULL,
    @FKIdSuperviso_NOM INT = NULL,
    @FKIdAutorizo_NOM INT = NULL,
    @FKIdPSolicita_NOM INT = NULL,
    @FKIdPJefeAlmacen_NOM INT = NULL,
    @FKIdPSuficiencia_NOM INT = NULL,
    @FKIdPSuperviso_NOM INT = NULL,
    @FKIdPAutorizo_NOM INT = NULL,
    @FKIdFuenteFinanciamiento_PRES INT = NULL,
    @FKIdAnio_SIS INT = NULL,
    @FKIdTipoGasto_PRES INT = NULL,
    @FKIdDigitoIdentificador_PRES INT = NULL,
    @FKIdDestinoGasto_PRES INT = NULL,
    @FKIdEgresoAutorizado_PRES INT = NULL,
    @Oficio VARCHAR(120) = NULL,
    @FechaOficio DATETIME = NULL,
    @CompraDirecta BIT = NULL,
    @FKIdTipoBien_ALMA INT = NULL,
    @FKIdUnidades_ALMA INT = NULL,
    @Cantidad NUMERIC(8,2) = NULL,
    @IdUser INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(20) = 'OK', @message NVARCHAR(4000) = '', @Parameters NVARCHAR(4000) = '', @liga NVARCHAR(100) = '', @today DATETIME2 = SYSDATETIME(), @Id INT;

    SET @message = CONCAT('Iniciando el SP [ORCO].[SP_MantenimientoRequisicion]', ' @PKIdRequisicion ', @PKIdRequisicion);
    SET @Parameters = CONCAT(
        'Action=', ISNULL(CONVERT(NVARCHAR(30), @Action), 'NULL'),
        ', PKIdRequisicion=', ISNULL(CONVERT(NVARCHAR(30), @PKIdRequisicion), 'NULL'),
        ', PKIdRequisicionDetalle=', ISNULL(CONVERT(NVARCHAR(30), @PKIdRequisicionDetalle), 'NULL'),
        ', FKIdEmpresa_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdEmpresa_SIS), 'NULL'),
        ', FKIdPersona_NOM=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPersona_NOM), 'NULL'),
        ', FKIdArea_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdArea_SIS), 'NULL'),
        ', Descripcion=', ISNULL(LEFT(@Descripcion, 300), 'NULL'),
        ', FechaRequisicion=', ISNULL(CONVERT(NVARCHAR(30), @FechaRequisicion, 126), 'NULL'),
        ', Servicio=', ISNULL(CONVERT(NVARCHAR(30), @Servicio), 'NULL'),
        ', FKIdProyecto_ORCO=', ISNULL(CONVERT(NVARCHAR(30), @FKIdProyecto_ORCO), 'NULL'),
        ', FKIdPrograma_PRES=', ISNULL(CONVERT(NVARCHAR(30), @FKIdPrograma_PRES), 'NULL'),
        ', Importe=', ISNULL(CONVERT(NVARCHAR(30), @Importe), 'NULL'),
        ', FKIdFuenteFinanciamiento_PRES=', ISNULL(CONVERT(NVARCHAR(30), @FKIdFuenteFinanciamiento_PRES), 'NULL'),
        ', FKIdAnio_SIS=', ISNULL(CONVERT(NVARCHAR(30), @FKIdAnio_SIS), 'NULL'),
        ', Oficio=', ISNULL(@Oficio, 'NULL'),
        ', FechaOficio=', ISNULL(CONVERT(NVARCHAR(30), @FechaOficio, 126), 'NULL'),
        ', CompraDirecta=', ISNULL(CONVERT(NVARCHAR(30), @CompraDirecta), 'NULL'),
        ', FKIdTipoBien_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdTipoBien_ALMA), 'NULL'),
        ', FKIdUnidades_ALMA=', ISNULL(CONVERT(NVARCHAR(30), @FKIdUnidades_ALMA), 'NULL'),
        ', Cantidad=', ISNULL(CONVERT(NVARCHAR(30), @Cantidad), 'NULL'),
        ', IdUser=', ISNULL(CONVERT(NVARCHAR(30), @IdUser), 'NULL')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = 'ORCO.SP_MantenimientoRequisicion',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = 'INFO',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = 'ORCO.SP_MantenimientoRequisicion',
        @Parameters = @Parameters,
        @ExecutionTime = '0';

    SET @message = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action IN (2, 3, 4, 5, 6) AND @PKIdRequisicion IS NOT NULL
           AND EXISTS (SELECT 1 FROM ORCO.Cotizacion WHERE FKIdRequisicion_ORCO = @PKIdRequisicion AND Activo = 1)
            THROW 51000, 'La requisicion ya esta vinculada a una cotizacion activa. Liberala para poder modificarla.', 1;

        IF @Action = 1
        BEGIN
            INSERT INTO ORCO.Requisicion (
                FKIdEmpresa_SIS, FKIdPersona_NOM, FKIdArea_SIS, Descripcion, Observaciones, FechaRequisicion,
                Servicio, FL_FOTO, FKIdProyecto_ORCO, FechaRequiereInicio, FechaRequiereFin, FKIdPrograma_PRES,
                Importe, FKIdJefeAlmacen_NOM, FKIdSuficiencia_PRES, FKIdSuperviso_NOM, FKIdAutorizo_NOM,
                FKIdPSolicita_NOM, FKIdPJefeAlmacen_NOM, FKIdPSuficiencia_NOM, FKIdPSuperviso_NOM, FKIdPAutorizo_NOM,
                FKIdFuenteFinanciamiento_PRES, FKIdAnio_SIS, FKIdTipoGasto_PRES, FKIdDigitoIdentificador_PRES,
                FKIdDestinoGasto_PRES, FKIdEgresoAutorizado_PRES, Oficio, FechaOficio, CompraDirecta,
                Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdEmpresa_SIS, @FKIdPersona_NOM, @FKIdArea_SIS, @Descripcion, @Observaciones, ISNULL(@FechaRequisicion, GETDATE()),
                ISNULL(@Servicio, 0), @FL_FOTO, @FKIdProyecto_ORCO, @FechaRequiereInicio, @FechaRequiereFin, @FKIdPrograma_PRES,
                @Importe, @FKIdJefeAlmacen_NOM, @FKIdSuficiencia_PRES, @FKIdSuperviso_NOM, @FKIdAutorizo_NOM,
                @FKIdPSolicita_NOM, @FKIdPJefeAlmacen_NOM, @FKIdPSuficiencia_NOM, @FKIdPSuperviso_NOM, @FKIdPAutorizo_NOM,
                @FKIdFuenteFinanciamiento_PRES, @FKIdAnio_SIS, @FKIdTipoGasto_PRES, @FKIdDigitoIdentificador_PRES,
                @FKIdDestinoGasto_PRES, @FKIdEgresoAutorizado_PRES, @Oficio, @FechaOficio, @CompraDirecta,
                1, @today, @IdUser
            );
            SET @Id = SCOPE_IDENTITY();
            SET @message = 'Requisicion creada correctamente.';
            SET @liga = CONCAT('idRequisicion:', @Id);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdRequisicion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Requisicion WHERE PKIdRequisicion = @PKIdRequisicion AND Activo = 1)
                THROW 51000, 'Requisicion no encontrada.', 1;

            UPDATE ORCO.Requisicion
            SET FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdPersona_NOM = @FKIdPersona_NOM,
                FKIdArea_SIS = @FKIdArea_SIS,
                Descripcion = @Descripcion,
                Observaciones = @Observaciones,
                FechaRequisicion = ISNULL(@FechaRequisicion, FechaRequisicion),
                Servicio = ISNULL(@Servicio, Servicio),
                FL_FOTO = @FL_FOTO,
                FKIdProyecto_ORCO = @FKIdProyecto_ORCO,
                FechaRequiereInicio = @FechaRequiereInicio,
                FechaRequiereFin = @FechaRequiereFin,
                FKIdPrograma_PRES = @FKIdPrograma_PRES,
                Importe = @Importe,
                FKIdJefeAlmacen_NOM = @FKIdJefeAlmacen_NOM,
                FKIdSuficiencia_PRES = @FKIdSuficiencia_PRES,
                FKIdSuperviso_NOM = @FKIdSuperviso_NOM,
                FKIdAutorizo_NOM = @FKIdAutorizo_NOM,
                FKIdPSolicita_NOM = @FKIdPSolicita_NOM,
                FKIdPJefeAlmacen_NOM = @FKIdPJefeAlmacen_NOM,
                FKIdPSuficiencia_NOM = @FKIdPSuficiencia_NOM,
                FKIdPSuperviso_NOM = @FKIdPSuperviso_NOM,
                FKIdPAutorizo_NOM = @FKIdPAutorizo_NOM,
                FKIdFuenteFinanciamiento_PRES = @FKIdFuenteFinanciamiento_PRES,
                FKIdAnio_SIS = @FKIdAnio_SIS,
                FKIdTipoGasto_PRES = @FKIdTipoGasto_PRES,
                FKIdDigitoIdentificador_PRES = @FKIdDigitoIdentificador_PRES,
                FKIdDestinoGasto_PRES = @FKIdDestinoGasto_PRES,
                FKIdEgresoAutorizado_PRES = @FKIdEgresoAutorizado_PRES,
                Oficio = @Oficio,
                FechaOficio = @FechaOficio,
                CompraDirecta = @CompraDirecta,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdRequisicion = @PKIdRequisicion;

            SET @Id = @PKIdRequisicion;
            SET @message = 'Requisicion actualizada correctamente.';
            SET @liga = CONCAT('idRequisicion:', @Id);
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdRequisicion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Requisicion WHERE PKIdRequisicion = @PKIdRequisicion AND Activo = 1)
                THROW 51000, 'Requisicion no encontrada.', 1;

            UPDATE ORCO.RequisicionDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdRequisicion_ORCO = @PKIdRequisicion AND Activo = 1;
            UPDATE ORCO.RequisicionPartida SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE FKIdRequisicion_ORCO = @PKIdRequisicion AND Activo = 1;
            UPDATE ORCO.Requisicion SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdRequisicion = @PKIdRequisicion;

            SET @Id = @PKIdRequisicion;
            SET @message = 'Requisicion eliminada correctamente.';
            SET @liga = CONCAT('idRequisicion:', @Id);
        END
        ELSE IF @Action IN (4, 5)
        BEGIN
            IF @PKIdRequisicion IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.Requisicion WHERE PKIdRequisicion = @PKIdRequisicion AND Activo = 1)
                THROW 51000, 'Requisicion no encontrada.', 1;

            IF ISNULL(@Cantidad, 0) <= 0
                THROW 51000, 'La cantidad debe ser mayor a cero.', 1;

            IF EXISTS (
                SELECT 1 FROM ORCO.RequisicionDetalle
                WHERE FKIdRequisicion_ORCO = @PKIdRequisicion
                  AND FKIdTipoBien_ALMA = @FKIdTipoBien_ALMA
                  AND Activo = 1
                  AND (@Action = 4 OR PKIdRequisicionDetalle <> @PKIdRequisicionDetalle)
            )
                THROW 51000, 'Ya existe un renglon activo con el mismo bien en esta requisicion.', 1;

            IF @Action = 4
            BEGIN
                INSERT INTO ORCO.RequisicionDetalle (
                    FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FKIdTipoBien_ALMA, FKIdUnidades_ALMA,
                    Cantidad, Observaciones, Activo, FechaCreacion, UsuarioCreacion
                )
                SELECT r.FKIdEmpresa_SIS, r.PKIdRequisicion, @FKIdTipoBien_ALMA, ISNULL(@FKIdUnidades_ALMA, tb.FKIdUnidades_ALMA),
                       @Cantidad, ISNULL(@Observaciones, ''), 1, @today, @IdUser
                FROM ORCO.Requisicion r
                INNER JOIN ALMA.TipoBien tb ON tb.PKIdTipoBien = @FKIdTipoBien_ALMA AND tb.Activo = 1
                WHERE r.PKIdRequisicion = @PKIdRequisicion;

                SET @Id = SCOPE_IDENTITY();
                SET @message = 'Detalle de requisicion creado correctamente.';
            END
            ELSE
            BEGIN
                IF @PKIdRequisicionDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.RequisicionDetalle WHERE PKIdRequisicionDetalle = @PKIdRequisicionDetalle AND Activo = 1)
                    THROW 51000, 'Detalle de requisicion no encontrado.', 1;

                UPDATE rd
                SET FKIdTipoBien_ALMA = @FKIdTipoBien_ALMA,
                    FKIdUnidades_ALMA = ISNULL(@FKIdUnidades_ALMA, tb.FKIdUnidades_ALMA),
                    Cantidad = @Cantidad,
                    Observaciones = ISNULL(@Observaciones, ''),
                    FechaModificacion = @today,
                    UsuarioModificacion = @IdUser
                FROM ORCO.RequisicionDetalle rd
                INNER JOIN ALMA.TipoBien tb ON tb.PKIdTipoBien = @FKIdTipoBien_ALMA AND tb.Activo = 1
                WHERE rd.PKIdRequisicionDetalle = @PKIdRequisicionDetalle;

                SET @Id = @PKIdRequisicionDetalle;
                SET @message = 'Detalle de requisicion actualizado correctamente.';
            END
            SET @liga = CONCAT('idRequisicionDetalle:', @Id);
        END
        ELSE IF @Action = 6
        BEGIN
            IF @PKIdRequisicionDetalle IS NULL OR NOT EXISTS (SELECT 1 FROM ORCO.RequisicionDetalle WHERE PKIdRequisicionDetalle = @PKIdRequisicionDetalle AND Activo = 1)
                THROW 51000, 'Detalle de requisicion no encontrado.', 1;

            UPDATE ORCO.RequisicionDetalle SET Activo = 0, FechaModificacion = @today, UsuarioModificacion = @IdUser WHERE PKIdRequisicionDetalle = @PKIdRequisicionDetalle;
            SET @Id = @PKIdRequisicionDetalle;
            SET @message = 'Detalle de requisicion eliminado correctamente.';
            SET @liga = CONCAT('idRequisicionDetalle:', @Id);
        END
        ELSE
            THROW 51000, 'Accion no valida para requisicion.', 1;

        COMMIT TRANSACTION;
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, @liga AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @tipo = 'ERROR';
        SET @message = CONCAT(ISNULL(PROGRAM_NAME(), ''), CHAR(10), 'Error: ', ERROR_MESSAGE(), CHAR(10), 'Linea: ', ERROR_LINE());
        SELECT (SELECT @tipo AS tipo, @message AS mensaje, '' AS liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
