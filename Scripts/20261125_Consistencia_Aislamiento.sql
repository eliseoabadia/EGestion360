-- Generado a partir de los modulos actuales; no contiene copias de datos.
SET NOCOUNT ON; SET XACT_ABORT ON; SET LOCK_TIMEOUT 5000;
IF DB_NAME() <> N'GestionEmpresarial' THROW 51200, 'Destino incorrecto.', 1;
IF (SELECT is_read_committed_snapshot_on FROM sys.databases WHERE database_id=DB_ID())<>1 THROW 51201, 'Se requiere RCSI activo.', 1;
BEGIN TRY
BEGIN TRANSACTION;
-- [ALMA].[SP_MantenimientoTipoBien] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1642488930))),2) <> '3DC90020666BFF5F1AFB8C502CDBB271E1A34DFBB3A1A001B498EEE2F19FEF8C' OR OBJECT_DEFINITION(1642488930) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [ALMA].[SP_MantenimientoTipoBien] (
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
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(4000);
    DECLARE @Parameters NVARCHAR(4000) = '''';
    DECLARE @errorMessage NVARCHAR(MAX);
    DECLARE @today DATETIME2 = SYSDATETIME();

    SET @message = CONCAT(''Iniciando el SP [ALMA].[SP_MantenimientoTipoBien]'', '' @PKIdTipoBien '', @PKIdTipoBien);
    SET @Parameters = CONCAT(
        ''Action='', ISNULL(CONVERT(NVARCHAR(30), @Action), ''NULL''),
        '', PKIdTipoBien='', ISNULL(CONVERT(NVARCHAR(30), @PKIdTipoBien), ''NULL''),
        '', FKIdGrupoBien_ALMA='', ISNULL(CONVERT(NVARCHAR(30), @FKIdGrupoBien_ALMA), ''NULL''),
        '', FKIdNivel_ALMA='', ISNULL(CONVERT(NVARCHAR(30), @FKIdNivel_ALMA), ''NULL''),
        '', FKIdPartida_CONTA='', ISNULL(CONVERT(NVARCHAR(30), @FKIdPartida_CONTA), ''NULL''),
        '', FKIdCuentaContable_CONTA='', ISNULL(CONVERT(NVARCHAR(30), @FKIdCuentaContable_CONTA), ''NULL''),
        '', FKIdUnidades_ALMA='', ISNULL(CONVERT(NVARCHAR(30), @FKIdUnidades_ALMA), ''NULL''),
        '', CodigoClave='', ISNULL(@CodigoClave, ''NULL''),
        '', Descripcion='', ISNULL(LEFT(@Descripcion, 300), ''NULL''),
        '', Consecutivo='', ISNULL(CONVERT(NVARCHAR(30), @Consecutivo), ''NULL''),
        '', CABMS='', ISNULL(@CABMS, ''NULL''),
        '', IdUser='', ISNULL(CONVERT(NVARCHAR(30), @IdUser), ''NULL'')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = ''ALMA.SP_MantenimientoTipoBien'',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = ''INFO'',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = ''ALMA.SP_MantenimientoTipoBien'',
        @Parameters = @Parameters,
        @ExecutionTime = ''0'';

    SET @message = '''';

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
            SET @tipo = ''OK'';
            SET @message = ''Tipo de bien creado correctamente.'';
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdTipoBien IS NULL OR NOT EXISTS (SELECT 1 FROM ALMA.TipoBien WHERE PKIdTipoBien = @PKIdTipoBien AND Activo = 1)
            BEGIN
                SET @tipo = ''ERROR'';
                SET @message = ''Tipo de bien no encontrado'';
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
            SET @tipo = ''OK'';
            SET @message = ''Tipo de bien actualizado correctamente.'';
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdTipoBien IS NULL OR NOT EXISTS (SELECT 1 FROM ALMA.TipoBien WHERE PKIdTipoBien = @PKIdTipoBien AND Activo = 1)
            BEGIN
                SET @tipo = ''ERROR'';
                SET @message = ''Tipo de bien no encontrado'';
                GOTO ERR_HANDLER;
            END

            UPDATE ALMA.TipoBien
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdTipoBien = @PKIdTipoBien;

            SET @Id = @PKIdTipoBien;
            SET @tipo = ''OK'';
            SET @message = ''Tipo de bien eliminado correctamente.'';
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

            SET @tipo = ''OK'';
            GOTO FINISH;
        END
        ELSE
        BEGIN
            SET @tipo = ''ERROR'';
            SET @message = ''Acci�n no v�lida. Use 1=Insert, 2=Update, 3=Delete, 4=GetById'';
            GOTO ERR_HANDLER;
        END

        FINISH:
        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRANSACTION;

        SELECT JSON_QUERY(
            CONCAT(''{"tipo":"'', @tipo, ''","mensaje":"'', @message, ''","liga":"idTipoBien:'', ISNULL(CAST(@Id AS NVARCHAR), ''''), ''"}'')
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
            ISNULL(PROGRAM_NAME(), ''''), CHAR(10),
            ''Error: '', ERROR_MESSAGE(), CHAR(10),
            ''Línea: '', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT(''{"tipo":"ERROR","mensaje":"'', @errorMessage, ''","liga":""}'')
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
            ISNULL(PROGRAM_NAME(), ''''), CHAR(10),
            ''Error: '', ERROR_MESSAGE(), CHAR(10),
            ''Línea: '', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT(''{"tipo":"ERROR","mensaje":"'', @errorMessage, ''","liga":""}'')
        ) AS ResultJson;

        RETURN -1;
    END CATCH
END;';
-- [ALMA].[SPR_LibroAlmacenSuministros] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1706489158))),2) <> '3C9D8FACD00F0D14F4BA68155E459A37B0D1D8AC1B8608A99BA2310D7648A0C0' OR OBJECT_DEFINITION(1706489158) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [ALMA].[SPR_LibroAlmacenSuministros]
    @Error nvarchar(max) OUTPUT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    SET @Error = NULL;

    SELECT
        E.[PKIdTipoBien],
        ISNULL(CC.[ClaveNombre], ''Configure Cuenta'') AS [Codigo],
        E.[Descripcion],
        SUM(E.[Existencias]) AS [Cantidad],
        E.[Unidades],
        E.[FK_IdUnidades__ALMA],
        ISNULL(MAX(E.[CostoPromedio]), 0) AS [CostoUnitario],
        SUM(E.[Existencias]) * ISNULL(MAX(E.[CostoPromedio]), 0) AS [Monto]
    FROM [ALMA].[Vw_Existencias] AS E
    LEFT JOIN [ALMA].[TipoBien] AS TB ON E.[PKIdTipoBien] = TB.[PKIdTipoBien]
    LEFT JOIN [CONTA].[VW_CUENTAS] AS CC ON TB.[FKIdCuentaContable_CONTA] = CC.[PkIdCuenta]
    GROUP BY
        E.[PKIdTipoBien],
        CC.[ClaveNombre],
        E.[Descripcion],
        E.[Unidades],
        E.[FK_IdUnidades__ALMA];

    RETURN 0;
END;';
-- [ALMA].[SPR_LibroAlmacenSuministros_DevEx] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1722489215))),2) <> '83DEDE60B9F9C142991D3DD7A83AC191AA39C405C755BE81D199847C641BB6B8' OR OBJECT_DEFINITION(1722489215) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [ALMA].[SPR_LibroAlmacenSuministros_DevEx]
    @FechaInicio datetime,
    @FechaFin datetime,
    @Error nvarchar(max) OUTPUT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    SET @Error = NULL;

    SELECT
        CAST(NULL AS nvarchar(30)) AS [ClavePersona],
        SS.[Solicitante] AS [Persona],
        CAST(NULL AS nvarchar(50)) AS [NombreAutoriza],
        CAST(NULL AS nvarchar(100)) AS [PuestoAutoriza],
        CAST(NULL AS nvarchar(100)) AS [PuestoSolicita],
        SS.[Observaciones] AS [DescripcionSolicitud],
        RIGHT(''00'' + CONVERT(varchar(2), DAY(SS.[FechaSolicitud])), 2) AS [Dia],
        DATENAME(month, SS.[FechaSolicitud]) AS [Mes],
        YEAR(SS.[FechaSolicitud]) AS [Anio],
        ROW_NUMBER() OVER (ORDER BY SS.[FechaSolicitud], SS.[PKIdSolicitudSalida]) AS [Consecutivo],
        CONVERT(nvarchar(10), SS.[FechaSolicitud], 103) AS [FechaSolicitud],
        AR.[Clave] AS [ClaveArea],
        AR.[Nombre] AS [Area],
        SS.[Folio] AS [NumeroVale],
        TB.[CodigoClave] AS [ClaveArticulo],
        LEFT(ISNULL(TB.[CABMS], ''''), 4) AS [Partida],
        GB.[Descripcion] AS [Subcuenta],
        CAST(''PROGRAMA'' AS varchar(8)) AS [Programa],
        DS.[CantidadEntregada] AS [Cantidad],
        UN.[Descripcion] AS [Unidad],
        TB.[Descripcion] AS [DesArticulo],
        DS.[CantidadEntregada] AS [Salidas],
        ISNULL(AL.[CostoUnitario], 0) AS [CostoUnitario],
        ISNULL(AL.[CostoUnitario], 0) * ISNULL(DS.[CantidadEntregada], 0) AS [Monto]
    FROM [ALMA].[SolicitudSalida] AS SS
    INNER JOIN [ALMA].[DetalleSolicitudSalida] AS DS ON DS.[FKIdSolicitudSalida_ALMA] = SS.[PKIdSolicitudSalida] AND DS.[Activo] = 1
    LEFT JOIN [ALMA].[Almacen] AS AL ON AL.[PKIdAlmacen] = DS.[FKIdAlmacen_ALMA] AND AL.[Activo] = 1
    LEFT JOIN [ALMA].[TipoBien] AS TB ON TB.[PKIdTipoBien] = DS.[FKIdTipoBien_ALMA] AND TB.[Activo] = 1
    LEFT JOIN [ALMA].[GrupoBien] AS GB ON GB.[PKIdGrupoBien] = TB.[FKIdGrupoBien_ALMA] AND GB.[Activo] = 1
    LEFT JOIN [ALMA].[Unidades] AS UN ON UN.[PKIdUnidades] = DS.[FKIdUnidades_ALMA] AND UN.[Activo] = 1
    LEFT JOIN [SIS].[Area] AS AR ON AR.[PKIdArea] = SS.[FKIdAreaSolicita_SIS]
    WHERE SS.[Activo] = 1
      AND SS.[FechaSolicitud] BETWEEN CONVERT(date, @FechaInicio) AND CONVERT(date, @FechaFin)
    ORDER BY SS.[FechaSolicitud], SS.[PKIdSolicitudSalida];

    RETURN 0;
END;';
-- [CONTA].[SP_MantenimientoPoliza] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1786489443))),2) <> '5597E84650644CCF304C6B58C4581F9C0AC4635D9B4C57CA4A0DD4B19F0B4550' OR OBJECT_DEFINITION(1786489443) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [CONTA].[SP_MantenimientoPoliza] (
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
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(4000);
    DECLARE @Parameters NVARCHAR(4000) = '''';
    DECLARE @errorMessage NVARCHAR(MAX);
    DECLARE @today DATETIME2 = SYSDATETIME();

    SET @message = CONCAT(''Iniciando el SP [CONTA].[SP_MantenimientoPoliza]'', '' @PKIdPoliza '', @PKIdPoliza);
    SET @Parameters = CONCAT(
        ''Action='', ISNULL(CONVERT(NVARCHAR(30), @Action), ''NULL''),
        '', PKIdPoliza='', ISNULL(CONVERT(NVARCHAR(30), @PKIdPoliza), ''NULL''),
        '', FKIdAnio_SIS='', ISNULL(CONVERT(NVARCHAR(30), @FKIdAnio_SIS), ''NULL''),
        '', FKIdMes_SIS='', ISNULL(CONVERT(NVARCHAR(30), @FKIdMes_SIS), ''NULL''),
        '', FKIdTipoPoliza_SIS='', ISNULL(CONVERT(NVARCHAR(30), @FKIdTipoPoliza_SIS), ''NULL''),
        '', NombrePoliza='', ISNULL(LEFT(@NombrePoliza, 300), ''NULL''),
        '', FechaPoliza='', ISNULL(CONVERT(NVARCHAR(30), @FechaPoliza, 126), ''NULL''),
        '', EstaBalanceado='', ISNULL(CONVERT(NVARCHAR(30), @EstaBalanceado), ''NULL''),
        '', PermitirModificar='', ISNULL(CONVERT(NVARCHAR(30), @PermitirModificar), ''NULL''),
        '', Autorizado='', ISNULL(CONVERT(NVARCHAR(30), @Autorizado), ''NULL''),
        '', FechaSolicitud='', ISNULL(CONVERT(NVARCHAR(30), @FechaSolicitud, 126), ''NULL''),
        '', FechaAutorizacion='', ISNULL(CONVERT(NVARCHAR(30), @FechaAutorizacion, 126), ''NULL''),
        '', IdUser='', ISNULL(CONVERT(NVARCHAR(30), @IdUser), ''NULL'')
    );
    EXEC [SIS].[WriteSystemLog]
        @FK_IdOrigenLogMessage__SIS = 1,
        @Date = @today,
        @_Type = 1,
        @ProgName = ''CONTA.SP_MantenimientoPoliza'',
        @EmployeeNo = @IdUser,
        @Category = NULL,
        @IPClient = NULL,
        @HostName = NULL,
        @Thread = NULL,
        @Level = ''INFO'',
        @Logger = NULL,
        @Message = @message,
        @Exception = NULL,
        @Context = NULL,
        @MethodName = ''CONTA.SP_MantenimientoPoliza'',
        @Parameters = @Parameters,
        @ExecutionTime = ''0'';

    SET @message = '''';

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

            IF @ClavePoliza IS NULL OR @ClavePoliza = ''''
            BEGIN
                SET @message = ISNULL(@ErrMsg, ''Error al generar clave de p�liza'');
                SET @tipo = ''ERROR'';
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
            SET @tipo = ''OK'';
            SET @message = CONCAT(''P�liza creada correctamente. Clave: '', @ClavePoliza);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdPoliza IS NULL OR NOT EXISTS (SELECT 1 FROM CONTA.Poliza WHERE PKIdPoliza = @PKIdPoliza AND Activo = 1)
            BEGIN
                SET @tipo = ''ERROR'';
                SET @message = ''P�liza no encontrada'';
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
            SET @tipo = ''OK'';
            SET @message = ''P�liza actualizada correctamente.'';
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdPoliza IS NULL OR NOT EXISTS (SELECT 1 FROM CONTA.Poliza WHERE PKIdPoliza = @PKIdPoliza AND Activo = 1)
            BEGIN
                SET @tipo = ''ERROR'';
                SET @message = ''P�liza no encontrada'';
                GOTO ERR_HANDLER;
            END

            UPDATE CONTA.Poliza
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @PKIdPoliza;

            SET @Id = @PKIdPoliza;
            SET @tipo = ''OK'';
            SET @message = ''P�liza eliminada correctamente.'';
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

            SET @tipo = ''OK'';
            GOTO FINISH;
        END
        ELSE
        BEGIN
            SET @tipo = ''ERROR'';
            SET @message = ''Acci�n no v�lida. Use 1=Insert, 2=Update, 3=Delete, 4=GetById'';
            GOTO ERR_HANDLER;
        END

        FINISH:
        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRANSACTION;

        SELECT JSON_QUERY(
            CONCAT(''{"tipo":"'', @tipo, ''","mensaje":"'', @message, ''","liga":"idPoliza:'', ISNULL(CAST(@Id AS NVARCHAR), ''''), ''"}'')
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
            ISNULL(PROGRAM_NAME(), ''''), CHAR(10),
            ''Error: '', ERROR_MESSAGE(), CHAR(10),
            ''Línea: '', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT(''{"tipo":"ERROR","mensaje":"'', @errorMessage, ''","liga":""}'')
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
            ISNULL(PROGRAM_NAME(), ''''), CHAR(10),
            ''Error: '', ERROR_MESSAGE(), CHAR(10),
            ''Línea: '', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT(''{"tipo":"ERROR","mensaje":"'', @errorMessage, ''","liga":""}'')
        ) AS ResultJson;

        RETURN -1;
    END CATCH
END';
-- [CONTA].[SPR_AlmacÃ©ndeMateriales] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1850489671))),2) <> '12A712876FD01D7BA03C17B5684B5391B515F9D418197FB1C19ECB3E1A4C8DC0' OR OBJECT_DEFINITION(1850489671) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [CONTA].[SPR_AlmacÃ©ndeMateriales]
    @p_FecInicio nvarchar(24),
    @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    DECLARE @FechaFin date = TRY_CONVERT(date, @p_FecFin);

    SELECT
        E.[PKIdTipoBien] AS [id],
        ISNULL(CC.[ClaveNombre], ''Configure Cuenta'') AS [CODIGO],
        E.[Descripcion] AS [S/PG],
        SUM(E.[Existencias]) AS [CANTIDAD],
        E.[Unidades] AS [UM],
        ISNULL(MAX(E.[CostoPromedio]), 0) AS [CU],
        SUM(E.[Existencias]) * ISNULL(MAX(E.[CostoPromedio]), 0) AS [MONTO],
        CAST('''' AS nvarchar(64)) AS [Funcion1],
        CAST('''' AS nvarchar(64)) AS [Funcion2],
        CAST('''' AS nvarchar(64)) AS [Funcion3],
        CAST('''' AS nvarchar(254)) AS [Nombre1],
        CAST('''' AS nvarchar(254)) AS [Nombre2],
        CAST('''' AS nvarchar(254)) AS [Nombre3],
        CAST('''' AS nvarchar(254)) AS [Puesto1],
        CAST('''' AS nvarchar(254)) AS [Puesto2],
        CAST('''' AS nvarchar(254)) AS [Puesto3],
        CAST(CONCAT(''AL '', UPPER(FORMAT(ISNULL(@FechaFin, GETDATE()), ''dd \DE MMMM \DEL yyyy'', ''es-MX''))) AS nvarchar(128)) AS [Titulo]
    FROM [ALMA].[Vw_Existencias] AS E
    LEFT JOIN [ALMA].[TipoBien] AS TB ON E.[PKIdTipoBien] = TB.[PKIdTipoBien]
    LEFT JOIN [CONTA].[VW_CUENTAS] AS CC ON TB.[FKIdCuentaContable_CONTA] = CC.[PkIdCuenta]
    GROUP BY
        E.[PKIdTipoBien],
        CC.[ClaveNombre],
        E.[Descripcion],
        E.[Unidades];
END;';
-- [CONTA].[SPR_AlmacendeMateriales] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1866489728))),2) <> '486780D8504C624BB6232F6FD3714DF652E56463C096D9C6C01521ACA3E0E60C' OR OBJECT_DEFINITION(1866489728) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [CONTA].[SPR_AlmacendeMateriales]
    @p_FecInicio nvarchar(24),
    @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    DECLARE @FechaFin date = TRY_CONVERT(date, @p_FecFin);

    SELECT
        E.[PKIdTipoBien] AS [id],
        ISNULL(CC.[ClaveNombre], ''Configure Cuenta'') AS [CODIGO],
        E.[Descripcion] AS [S/PG],
        SUM(E.[Existencias]) AS [CANTIDAD],
        E.[Unidades] AS [UM],
        ISNULL(MAX(E.[CostoPromedio]), 0) AS [CU],
        SUM(E.[Existencias]) * ISNULL(MAX(E.[CostoPromedio]), 0) AS [MONTO],
        CAST('''' AS nvarchar(64)) AS [Funcion1],
        CAST('''' AS nvarchar(64)) AS [Funcion2],
        CAST('''' AS nvarchar(64)) AS [Funcion3],
        CAST('''' AS nvarchar(254)) AS [Nombre1],
        CAST('''' AS nvarchar(254)) AS [Nombre2],
        CAST('''' AS nvarchar(254)) AS [Nombre3],
        CAST('''' AS nvarchar(254)) AS [Puesto1],
        CAST('''' AS nvarchar(254)) AS [Puesto2],
        CAST('''' AS nvarchar(254)) AS [Puesto3],
        CAST(CONCAT(''AL '', UPPER(FORMAT(ISNULL(@FechaFin, GETDATE()), ''dd \DE MMMM \DEL yyyy'', ''es-MX''))) AS nvarchar(128)) AS [Titulo]
    FROM [ALMA].[Vw_Existencias] AS E
    LEFT JOIN [ALMA].[TipoBien] AS TB ON E.[PKIdTipoBien] = TB.[PKIdTipoBien]
    LEFT JOIN [CONTA].[VW_CUENTAS] AS CC ON TB.[FKIdCuentaContable_CONTA] = CC.[PkIdCuenta]
    GROUP BY
        E.[PKIdTipoBien],
        CC.[ClaveNombre],
        E.[Descripcion],
        E.[Unidades];
END;';
-- [CONTA].[SPR_AlmacéndeMateriales] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(1882489785))),2) <> '6860AD5FD9069B9776DBDFCDC350978A7D662EF5159945B10DAD7F62C10488F0' OR OBJECT_DEFINITION(1882489785) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [CONTA].[SPR_AlmacéndeMateriales]
    @p_FecInicio nvarchar(24),
    @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    DECLARE @FechaFin date = TRY_CONVERT(date, @p_FecFin);

    SELECT
        E.[PKIdTipoBien] AS [id],
        ISNULL(CC.[ClaveNombre], ''Configure Cuenta'') AS [CODIGO],
        E.[Descripcion] AS [S/PG],
        SUM(E.[Existencias]) AS [CANTIDAD],
        E.[Unidades] AS [UM],
        ISNULL(MAX(E.[CostoPromedio]), 0) AS [CU],
        SUM(E.[Existencias]) * ISNULL(MAX(E.[CostoPromedio]), 0) AS [MONTO],
        CAST('''' AS nvarchar(64)) AS [Funcion1],
        CAST('''' AS nvarchar(64)) AS [Funcion2],
        CAST('''' AS nvarchar(64)) AS [Funcion3],
        CAST('''' AS nvarchar(254)) AS [Nombre1],
        CAST('''' AS nvarchar(254)) AS [Nombre2],
        CAST('''' AS nvarchar(254)) AS [Nombre3],
        CAST('''' AS nvarchar(254)) AS [Puesto1],
        CAST('''' AS nvarchar(254)) AS [Puesto2],
        CAST('''' AS nvarchar(254)) AS [Puesto3],
        CAST(CONCAT(''AL '', UPPER(FORMAT(ISNULL(@FechaFin, GETDATE()), ''dd \DE MMMM \DEL yyyy'', ''es-MX''))) AS nvarchar(128)) AS [Titulo]
    FROM [ALMA].[Vw_Existencias] AS E
    LEFT JOIN [ALMA].[TipoBien] AS TB ON E.[PKIdTipoBien] = TB.[PKIdTipoBien]
    LEFT JOIN [CONTA].[VW_CUENTAS] AS CC ON TB.[FKIdCuentaContable_CONTA] = CC.[PkIdCuenta]
    GROUP BY
        E.[PKIdTipoBien],
        CC.[ClaveNombre],
        E.[Descripcion],
        E.[Unidades];
END;';
-- [CONTA].[SPR_FacturasEmitidas] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(2042490355))),2) <> '53D07D81AA261A6CF5301966BA1FDCBDF68851A2DEBD1E02D78627B527DF542B' OR OBJECT_DEFINITION(2042490355) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [CONTA].[SPR_FacturasEmitidas]
      @p_FecInicio nvarchar(24),
      @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = @p_FecInicio,
            @p_FechaFin date = @p_FecFin;

    DECLARE @Funcion1 nvarchar(64) = N'''',
            @Funcion2 nvarchar(64) = N'''',
            @Funcion3 nvarchar(64) = N'''',
            @Nombre1 nvarchar(254) = N'''',
            @Nombre2 nvarchar(254) = N'''',
            @Nombre3 nvarchar(254) = N'''',
            @Puesto1 nvarchar(254) = N'''',
            @Puesto2 nvarchar(254) = N'''',
            @Puesto3 nvarchar(254) = N'''';

    SELECT f.PKIdFactura AS Id,
           f.NumFactura AS [Número de Factura],
           COALESCE(f.FechaEmision, f.FechaRecepcion) AS Fecha,
           COALESCE(p.RFC, N'''') AS RFC,
           COALESCE(f.ProveedorNombre, p.Nombre, N'''') AS [Emitida a Nombre de],
           COALESCE(fd.Observaciones, f.Observaciones, N'''') AS Concepto,
           ISNULL(f.Subtotal, 0) AS [Importe Neto],
           ISNULL(f.IVA, 0) AS IVA,
           ISNULL(f.Retencion, 0) AS Otros,
           ISNULL(f.Total, 0) AS Total
    INTO #tblFacturasEmitidas
    FROM [PRES].[Vw_Factura] f
    LEFT JOIN [SIS].[Proveedor] p ON p.PKIdProveedor = f.FKIdProveedor_SIS
    OUTER APPLY (
        SELECT TOP (1) d.Observaciones
        FROM [PRES].[Vw_FacturaDetalle] d
        WHERE d.FKIdFactura_PRES = f.PKIdFactura
        ORDER BY d.PKIdFacturaDetalle
    ) fd
    WHERE f.Activo = 1
      AND COALESCE(f.FechaEmision, f.FechaRecepcion) BETWEEN @p_FechaInicio AND @p_FechaFin;

    SELECT *,
           @Funcion1 AS Funcion1,
           @Funcion2 AS Funcion2,
           @Funcion3 AS Funcion3,
           @Nombre1 AS Nombre1,
           @Nombre2 AS Nombre2,
           @Nombre3 AS Nombre3,
           @Puesto1 AS Puesto1,
           @Puesto2 AS Puesto2,
           @Puesto3 AS Puesto3,
           CAST(CONCAT(''PERIODO: DEL '', FORMAT(@p_FechaInicio, ''dd'', ''es-MX''), '' AL '', FORMAT(@p_FechaFin, ''dd'', ''es-MX''), '' DE '', UPPER(FORMAT(@p_FechaFin, ''MMMM'', ''es-MX'')), '' DE '', FORMAT(@p_FechaFin, ''yyyy'', ''es-MX'')) AS nvarchar(128)) AS Titulo
    FROM #tblFacturasEmitidas;
END';
-- [CONTA].[SPR_InventariosdeBienes] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(2074490469))),2) <> '6FDB7377A4CBCFD4786686B46FAA108BA6C617A45CCAC02DE4C8936E5BAA4E24' OR OBJECT_DEFINITION(2074490469) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_InventariosdeBienes] '''',''2025-09-28''
ALTER   PROCEDURE [CONTA].[SPR_InventariosdeBienes]

@p_FecInicio nvarchar(24),
@p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET NOCOUNT ON;

DECLARE @FechaInicio DATE = @p_FecInicio, @FechaFin DATE = @p_FecFin

	SELECT bn.PK_IdBien AS Id
      ,bn.Clave AS NInventario
      ,bn.Descripcion AS [S/PG]
	  ,1 as [CANTIDAD]
	  ,Un.Descripcion as [UM]
      ,bn.Costo AS [CU]
	  , bn.Costo * 1  as [MONTO]
      --,bn.ValorRescate
      --,bn.ValorActual
	  , Titulo = CAST(CONCAT(''AL '', UPPER(FORMAT(@FechaFin, ''dd \DE MMMM \DEL yyyy'', ''es-MX''))) AS NVARCHAR(128))
  FROM [SICOP].[VW_Bien] Bn
  JOIN SICOP.TipoBien TB ON Bn.FK_IdTipoBien__SICOP = TB.PK_IdTipoBien
  JOIN ALMA.Unidades Un ON Tb.FK_IdUnidades_Equivalente = Un.PKIdUnidades
  ORDER BY Bn.Clave
	
END';
-- [CONTA].[SPR_InventariosdeMaterias] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(2090490526))),2) <> '01E436319523D4FFEB5103BF97FF20846781E39639E02290BB104509BCC73476' OR OBJECT_DEFINITION(2090490526) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [CONTA].[SPR_InventariosdeMaterias]
    @p_FecInicio nvarchar(24),
    @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    DECLARE @FechaFin date = TRY_CONVERT(date, NULLIF(@p_FecFin, N''''));

    SELECT
        E.[PKIdTipoBien] AS [id],
        ISNULL(CC.[ClaveNombre], ''Configure Cuenta'') AS [CODIGO],
        E.[Descripcion] AS [S/PG],
        SUM(E.[Existencias]) AS [CANTIDAD],
        E.[Unidades] AS [UM],
        ISNULL(MAX(E.[CostoPromedio]), 0) AS [CU],
        SUM(E.[Existencias]) * ISNULL(MAX(E.[CostoPromedio]), 0) AS [MONTO],
        CAST(''Al: '' + UPPER(FORMAT(ISNULL(@FechaFin, GETDATE()), ''dd \DE MMMM \DEL yyyy'', ''es-MX'')) AS varchar(60)) AS [titulo]
    FROM [ALMA].[Vw_Existencias] AS E
    LEFT JOIN [ALMA].[TipoBien] AS TB ON TB.[PKIdTipoBien] = E.[PKIdTipoBien] AND TB.[Activo] = 1
    LEFT JOIN [CONTA].[VW_CUENTAS] AS CC ON CC.[Pk_IdCuenta] = TB.[FKIdCuentaContable_CONTA]
    GROUP BY
        E.[PKIdTipoBien],
        CC.[ClaveNombre],
        E.[Descripcion],
        E.[Unidades];
END;';
-- [CONTA].[SPR_RepActFijos] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(2138490697))),2) <> '9BDB0D158556A57D43177AA6AF4EA76A172182795CB77F1A974E350E8B689EB2' OR OBJECT_DEFINITION(2138490697) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [CONTA].[SPR_RepActFijos]
    @p_FecInicio nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = TRY_CONVERT(date, @p_FecInicio);

    DECLARE @tablaFirma table (
        id int IDENTITY(1,1) NOT NULL,
        Funcion nvarchar(64) NULL,
        Nombre nvarchar(254) NULL
    );

    INSERT INTO @tablaFirma (Funcion, Nombre)
    SELECT F.[Funcion], CONCAT(P.[Nombre], '' '', P.[Paterno], '' '', P.[Materno])
    FROM [SIS].[Reporte] AS R
    INNER JOIN [SIS].[FirmaAutorizada] AS F ON R.[Pk_IdReporte] = F.[Fk_IdReporte__SIS]
    INNER JOIN [RHCT].[Persona] AS P ON F.[Fk_IdPersona__RHCT] = P.[PK_IdPersona]
    WHERE R.[Controlador] = ''RepLibroInventarioBienes''
      AND R.[Activo] = 1
      AND F.[Activo] = 1;

    DECLARE @Funcion1 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 1), '''');
    DECLARE @Funcion2 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 2), '''');
    DECLARE @Funcion3 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 3), '''');
    DECLARE @Nombre1 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 1), '''');
    DECLARE @Nombre2 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 2), '''');
    DECLARE @Nombre3 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 3), '''');
    DECLARE @Puesto1 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre1 + ''%''), '''');
    DECLARE @Puesto2 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre2 + ''%''), '''');
    DECLARE @Puesto3 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre3 + ''%''), '''');

    SELECT
        bn.[Clave] AS [Codigo],
        bn.[Descripcion],
        bn.[Costo] AS [Valor],
        @Funcion1 AS [Funcion1],
        @Funcion2 AS [Funcion2],
        @Funcion3 AS [Funcion3],
        @Nombre1 AS [Nombre1],
        @Nombre2 AS [Nombre2],
        @Nombre3 AS [Nombre3],
        @Puesto1 AS [Puesto1],
        @Puesto2 AS [Puesto2],
        @Puesto3 AS [Puesto3],
        CAST(CONCAT(''AL '', UPPER(FORMAT(ISNULL(@p_FechaInicio, GETDATE()), ''dd \DE MMMM \DEL yyyy'', ''es-MX''))) AS nvarchar(128)) AS [Titulo]
    FROM [SICOP].[VW_Bien] AS bn
    INNER JOIN [SICOP].[TipoBien] AS tb ON bn.[FK_IdTipoBien__SICOP] = tb.[PK_IdTipoBien]
    LEFT JOIN [ALMA].[Unidades] AS un ON tb.[FK_IdUnidades_Equivalente] = un.[PKIdUnidades]
    ORDER BY bn.[Clave];
END;';
-- [CONTA].[SPR_RepArtFaltporSurtir] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(55007277))),2) <> '9161932757B01AF163A51E3CE21367B95FA3E87E7EAA87DA0DE001686230EAAE' OR OBJECT_DEFINITION(55007277) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [CONTA].[SPR_RepArtFaltporSurtir]
    @p_FecInicio nvarchar(24),
    @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = TRY_CONVERT(date, @p_FecInicio);
    DECLARE @p_FechaFin date = TRY_CONVERT(date, @p_FecFin);

    DECLARE @tablaFirma table (
        id int IDENTITY(1,1) NOT NULL,
        Funcion nvarchar(64) NULL,
        Nombre nvarchar(254) NULL
    );

    INSERT INTO @tablaFirma (Funcion, Nombre)
    SELECT F.[Funcion], CONCAT(P.[Nombre], '' '', P.[Paterno], '' '', P.[Materno])
    FROM [SIS].[Reporte] AS R
    INNER JOIN [SIS].[FirmaAutorizada] AS F ON R.[Pk_IdReporte] = F.[Fk_IdReporte__SIS]
    INNER JOIN [RHCT].[Persona] AS P ON F.[Fk_IdPersona__RHCT] = P.[PK_IdPersona]
    WHERE R.[Controlador] = ''RepArtFaltporSurtir''
      AND R.[Activo] = 1
      AND F.[Activo] = 1;

    DECLARE @Funcion1 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 1), '''');
    DECLARE @Funcion2 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 2), '''');
    DECLARE @Funcion3 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 3), '''');
    DECLARE @Nombre1 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 1), '''');
    DECLARE @Nombre2 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 2), '''');
    DECLARE @Nombre3 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 3), '''');
    DECLARE @Puesto1 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre1 + ''%''), '''');
    DECLARE @Puesto2 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre2 + ''%''), '''');
    DECLARE @Puesto3 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre3 + ''%''), '''');

    SELECT
        od.[PKIdOrdenCompraDetalle] AS [ID],
        CAST(NULL AS int) AS [PP],
        od.[TipoBienCodigoClave] AS [cabmsdf],
        od.[TipoBienDescripcion] AS [concepto],
        od.[CantidadPendiente] AS [exissurtir],
        @Funcion1 AS [Funcion1],
        @Funcion2 AS [Funcion2],
        @Funcion3 AS [Funcion3],
        @Nombre1 AS [Nombre1],
        @Nombre2 AS [Nombre2],
        @Nombre3 AS [Nombre3],
        @Puesto1 AS [Puesto1],
        @Puesto2 AS [Puesto2],
        @Puesto3 AS [Puesto3],
        CAST(CONCAT(''PERIODO DEL '', FORMAT(ISNULL(@p_FechaInicio, GETDATE()), ''dd \de MMMM \del yyyy'', ''es-MX''), '' AL '', FORMAT(ISNULL(@p_FechaFin, GETDATE()), ''dd \de MMMM \del yyyy'', ''es-MX'')) AS nvarchar(128)) AS [Titulo]
    FROM [ORCO].[Vw_OrdenCompraDetalle] AS od;
END;';
-- [CONTA].[SPR_RepBienLentNulMovPer] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(87007391))),2) <> '761FC99257D40D7A520B742CB2F7827E3C6B16BEF3C879515309F934C1F85CCF' OR OBJECT_DEFINITION(87007391) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [CONTA].[SPR_RepBienLentNulMovPer]
    @p_FecInicio nvarchar(24),
    @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = TRY_CONVERT(date, @p_FecInicio);
    DECLARE @p_FechaFin date = TRY_CONVERT(date, @p_FecFin);

    DECLARE @tablaFirma table (
        id int IDENTITY(1,1) NOT NULL,
        Funcion nvarchar(64) NULL,
        Nombre nvarchar(254) NULL
    );

    INSERT INTO @tablaFirma (Funcion, Nombre)
    SELECT F.[Funcion], CONCAT(P.[Nombre], '' '', P.[Paterno], '' '', P.[Materno])
    FROM [SIS].[Reporte] AS R
    INNER JOIN [SIS].[FirmaAutorizada] AS F ON R.[Pk_IdReporte] = F.[Fk_IdReporte__SIS]
    INNER JOIN [RHCT].[Persona] AS P ON F.[Fk_IdPersona__RHCT] = P.[PK_IdPersona]
    WHERE R.[Controlador] = ''RepBienLentNulMovPer''
      AND R.[Activo] = 1
      AND F.[Activo] = 1;

    DECLARE @Funcion1 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 1), '''');
    DECLARE @Funcion2 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 2), '''');
    DECLARE @Funcion3 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 3), '''');
    DECLARE @Nombre1 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 1), '''');
    DECLARE @Nombre2 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 2), '''');
    DECLARE @Nombre3 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 3), '''');
    DECLARE @Puesto1 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre1 + ''%''), '''');
    DECLARE @Puesto2 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre2 + ''%''), '''');
    DECLARE @Puesto3 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre3 + ''%''), '''');

    SELECT
        E.[PKIdTipoBien] AS [ID],
        E.[FKIdPartida_CONTA] AS [PP],
        E.[CodigoClave] AS [cabmsdf],
        E.[Descripcion] AS [concepto],
        E.[Unidades] AS [um],
        E.[Existencias] AS [cant],
        E.[CostoPromedio] AS [costprom],
        E.[Existencias] * E.[CostoPromedio] AS [total],
        CAST(NULL AS nvarchar(50)) AS [B],
        CAST(NULL AS nvarchar(50)) AS [R],
        CAST(NULL AS nvarchar(50)) AS [BN],
        CAST(''Almacen'' AS nvarchar(100)) AS [UBBien],
        CAST(NULL AS nvarchar(254)) AS [RespBien],
        @Funcion1 AS [Funcion1],
        @Funcion2 AS [Funcion2],
        @Funcion3 AS [Funcion3],
        @Nombre1 AS [Nombre1],
        @Nombre2 AS [Nombre2],
        @Nombre3 AS [Nombre3],
        @Puesto1 AS [Puesto1],
        @Puesto2 AS [Puesto2],
        @Puesto3 AS [Puesto3],
        CAST(CONCAT(''PERIODO DEL '', FORMAT(ISNULL(@p_FechaInicio, GETDATE()), ''dd \de MMMM \del yyyy'', ''es-MX''), '' AL '', FORMAT(ISNULL(@p_FechaFin, GETDATE()), ''dd \de MMMM \del yyyy'', ''es-MX'')) AS nvarchar(128)) AS [Titulo]
    FROM [ALMA].[Vw_Existencias] AS E;
END;';
-- [CONTA].[SPR_RepCheques] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(103007448))),2) <> '926AE10494EBD64CA61562C56EA1A915FC9441EB4EBEAFB101F87F1AFDF012B7' OR OBJECT_DEFINITION(103007448) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [CONTA].[SPR_RepCheques]
      @p_FecInicio nvarchar(24),
      @p_FecFin nvarchar(24)
,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = CAST(@p_FecInicio AS date),
            @p_FechaFin date = CAST(@p_FecFin AS date),
            @Funcion1 nvarchar(64) = N'''',
            @Funcion2 nvarchar(64) = N'''',
            @Funcion3 nvarchar(64) = N'''',
            @Nombre1 nvarchar(254) = N'''',
            @Nombre2 nvarchar(254) = N'''',
            @Nombre3 nvarchar(254) = N'''',
            @Puesto1 nvarchar(254) = N'''',
            @Puesto2 nvarchar(254) = N'''',
            @Puesto3 nvarchar(254) = N'''';

    SELECT ch.PKIdCheque AS ID,
           ch.NumeroCheque AS nocheq,
           ch.FechaEmision AS fechaem,
           COALESCE(ch.EmpresaNombre, N'''') AS bene,
           ISNULL(ch.ImporteTotal, 0) AS monto,
           CASE WHEN ch.Estatus = 1 THEN DATEADD(day, 7, ch.FechaEmision) ELSE ch.FechaEmision END AS fechacobes,
           COALESCE(ch.EstatusDescripcion, CASE WHEN ch.Estatus = 1 THEN ''DESCONOCIDO'' ELSE ''COBRADO'' END) AS estado,
           COALESCE(ch.Observaciones, ch.Concepto, N'''') AS obs
    INTO #tblRepCheques
    FROM [PRES].[Vw_Cheque] ch
    WHERE ch.Activo = 1
      AND ch.FechaEmision BETWEEN @p_FechaInicio AND @p_FechaFin;

    SELECT *,
           @Funcion1 AS Funcion1,
           @Funcion2 AS Funcion2,
           @Funcion3 AS Funcion3,
           @Nombre1 AS Nombre1,
           @Nombre2 AS Nombre2,
           @Nombre3 AS Nombre3,
           @Puesto1 AS Puesto1,
           @Puesto2 AS Puesto2,
           @Puesto3 AS Puesto3,
           CAST(CONCAT(''PERIODO DEL '', FORMAT(@p_FechaInicio, ''dd \de MMMM \del yyyy'', ''es-MX''), '' AL '', FORMAT(@p_FechaFin, ''dd \de MMMM \del yyyy'', ''es-MX'')) AS nvarchar(128)) AS Titulo
    FROM #tblRepCheques;
END';
-- [CONTA].[SPR_RepDIOT] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(199007790))),2) <> 'DC8F387F06A05887515B2B1CA91DCAE4F91A124BBCF7D3D00E8CC944DA439A6F' OR OBJECT_DEFINITION(199007790) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'-- exec [CONTA].[SPR_RepDIOT]
ALTER   PROCEDURE [CONTA].[SPR_RepDIOT]

    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET FMTONLY OFF;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	
	SELECT 
	[TTer] = ''04'', [TOp] = ''02'' , [ReFeCon] = ''PES111111QW1'' , [NumIdFis] = '''' , [NomEx] = '''' , [PaJuReFis] = '''' , [EsJuFis] = '''' ,
	[VTAPFN] = ''1000'', [DDBAArfn] = ''10'' , [VtaAaprfs] = ''1000'' , [DDBAAefs] = ''10'' , [VtapAAtpiva] = ''1000'' , [DDBAatpiva] = ''10'' , [VTAPAAPIiva] = ''1000'' ,
	[DDBAAIiva] = ''10'', [VTAAPAAPIbiva] = ''1000'' , [DDBAAPIBiva] = ''10'' , [EAGAAPRFN] = ''10'' , [ASAPAAPRFN] = ''10'' , [EXAGAAPRFS] = ''10'' , [AAAPAAPRFS] = ''10'' ,
	[EAGAATPiva] = ''10'', [ASAPAARiva] = ''10'' , [EXAGAAPIAiva] = ''10'' , [AAAPAAPIAiva] = ''10'' , [EXAGAAPIBiva] = ''10'' , [AAAPAAPIBiva] = ''10'' , [AAAPAAPRFN] = ''1'' , [AANCRAAPRFN] = ''1'' ,
	[AAEAAPRFN] = ''1'', [AANOBAAPRFN] = ''1'' , [AAPAPRAAPRFS] = ''1'' , [AANCRAAPRFS] = ''1'' , [AAEXAAPRFS] = ''1'' , [AANOBAAPRFS] = ''1'' , [AACAPRAATPiva] = ''1'' ,
	[ASANCRAATPiva] = ''1'', [ASAEXAATPiva] = ''1'' , [ASANBAATPiva] = ''1'' , [ASAPCAPAAPIPABiva] = ''1'' , [AANCRAAPIABiva] = ''1'' , [AAEXAAPIPABiva] = ''1'' , [AAPCAPAOAPIBiva] = ''1'' ,
	[ASANCRAAPIBIiva] = ''1'', [ASAEXAAPIBISiva] = ''1'' , [ASANOAAPIBISiva] = ''1'' , [IVARPC] = ''1'' , [AAPIBSPNPIVAEX] = ''100'' , [AAPPNPIVAEX] = ''100'' , [DAAPTCIVA] = ''100'' ,
	[AANOBIVARTN] = ''100'', [AANOIVANCETN] = ''100'' , [MEFCAORPR] = ''01'' 
	INTO #tblRepDiot
	UNION
	SELECT 
	[TTer] = ''04'', [TOp] = ''85'' , [ReFeCon] = ''GUSA620523456'' , [NumIdFis] = ''1'' , [NomEx] = ''Mario Pech Soliz'' , [PaJuReFis] = ''ZZZ'' , [EsJuFis] = ''MiCasa'' ,
	[VTAPFN] = ''1000'', [DDBAArfn] = ''10'' , [VtaAaprfs] = ''1000'' , [DDBAAefs] = ''10'' , [VtapAAtpiva] = ''1000'' , [DDBAatpiva] = ''10'' , [VTAPAAPIiva] = ''1000'' ,
	[DDBAAIiva] = ''10'', [VTAAPAAPIbiva] = ''1000'' , [DDBAAPIBiva] = ''10'' , [EAGAAPRFN] = ''10'' , [ASAPAAPRFN] = ''10'' , [EXAGAAPRFS] = ''10'' , [AAAPAAPRFS] = ''10'' ,
	[EAGAATPiva] = ''10'', [ASAPAARiva] = ''10'' , [EXAGAAPIAiva] = ''10'' , [AAAPAAPIAiva] = ''10'' , [EXAGAAPIBiva] = ''10'' , [AAAPAAPIBiva] = ''10'' , [AAAPAAPRFN] = ''1'' , [AANCRAAPRFN] = ''1'' ,
	[AAEAAPRFN] = ''1'', [AANOBAAPRFN] = ''1'' , [AAPAPRAAPRFS] = ''1'' , [AANCRAAPRFS] = ''1'' , [AAEXAAPRFS] = ''1'' , [AANOBAAPRFS] = ''1'' , [AACAPRAATPiva] = ''1'' ,
	[ASANCRAATPiva] = ''1'', [ASAEXAATPiva] = ''1'' , [ASANBAATPiva] = ''1'' , [ASAPCAPAAPIPABiva] = ''1'' , [AANCRAAPIABiva] = ''1'' , [AAEXAAPIPABiva] = ''1'' , [AAPCAPAOAPIBiva] = ''1'' ,
	[ASANCRAAPIBIiva] = ''1'', [ASAEXAAPIBISiva] = ''1'' , [ASANOAAPIBISiva] = ''1'' , [IVARPC] = ''1'' , [AAPIBSPNPIVAEX] = ''100'' , [AAPPNPIVAEX] = ''100'' , [DAAPTCIVA] = ''100'' ,
	[AANOBIVARTN] = ''100'', [AANOIVANCETN] = ''100'' , [MEFCAORPR] = ''01'' 
	--FIN
	SELECT *
	FROM #tblRepDiot
	
END';
-- [ORCO].[SPR_EstadoActividad] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(51531267))),2) <> 'AE4B770D00FCB0367A805CD8C22AA672D4F87237417A944C570ABF5FA59FA6AF' OR OBJECT_DEFINITION(51531267) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'-- =============================================
-- Author:		JCOL
-- Create date: 01/05/2013
-- Description:	REPORTE DE VALE DE SALIDA
-- =============================================
-- =============================================
-- Editor:		[.0.
-- Create date: 01/05/2013
-- Description:	Se arraglaron firmasAutorizadas,
--				Se corrigieron nombres de los nodos para coincidir con Flex
--				Se agregó CostoPromedio y CostoTotal
-- =============================================
-- =============================================
-- Editor:		[.0.
-- Create date: 14/08/2013
-- Description:	Costo promedio viene ahora de la tabla ALMA.CostoPromedio
-- Nota: Siempre saldrá el costo promedio al momento de llamar al reporte, no el costo promedio a la fecha de la salida
-- =============================================

-- exec [ORCO].[SPR_EstadoActividad] 0
ALTER   PROCEDURE [ORCO].[SPR_EstadoActividad]
	 @PK_Id INT NULL
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET NOCOUNT ON;
	

	SELECT id=1,Concepto = CAST(''INGRESOS Y OTROS BENEFICIOS'' as nvarchar(500)), [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=2,Concepto = ''  Ingresos de Gestión'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=3,Concepto = ''    Impuestos'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=4,Concepto = ''    Cuotas y Aportaciones de Seguridad Social'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=5,Concepto = ''    Contribuciones de Mejoras'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=6,Concepto = ''    Derechos'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=7,Concepto = ''    Productos'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=8,Concepto = ''    Aprovechamientos'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=9,Concepto = ''    Ingresos por Venta de Bienes y Prestación de Servicios'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=10,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--
	UNION
	SELECT id=12,Concepto = ''  Participaciones, Aportaciones, Convenios, Incentivos Derivados de la Colaboración Fiscal, Fondos Distintos de Aportaciones, Transferencias, Asignaciones, Subsidios y Subvenciones, y Pensiones y Jubilaciones'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=13,Concepto = ''    Participaciones, Aportaciones, Convenios, Incentivos Derivados de la Colaboración Fiscal y Fondos Distintos de Aportaciones'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=14,Concepto = ''    Transferencias, Asignaciones, Subsidios y Subvenciones, y Pensiones y Jubilaciones'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=15,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--
	UNION
	SELECT id=16,Concepto = ''  Otros Ingresos y Beneficios'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=17,Concepto = ''    Ingresos Financieros'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=18,Concepto = ''    Incremento por Variación de Inventarios'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=19,Concepto = ''    Disminución del Exceso de Estimaciones por Pérdida o Deterioro u Obsolescencia'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=20,Concepto = ''    Disminución del Exceso de Provisiones'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=21,Concepto = ''    Otros Ingresos y Beneficios Varios'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=22,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--
	UNION
	SELECT id=23,Concepto = ''Total de Ingresos y Otros Beneficios'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=24,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--
	UNION
	SELECT id=25,Concepto = ''GASTOS Y OTRAS PÉRDIDAS'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=26,Concepto = ''  Gastos de Funcionamiento'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=27,Concepto = ''    Servicios Personales'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=28,Concepto = ''    Materiales y Suministros'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=29,Concepto = ''    Servicios Generales'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=30,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--
	UNION
	SELECT id=31,Concepto = ''  Transferencias, Asignaciones, Subsidios y Otras Ayudas'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=32,Concepto = ''    Transferencias Internas y Asignaciones al Sector Público'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=33,Concepto = ''    Transferencias al Resto del Sector Público'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=34,Concepto = ''    Subsidios y Subvenciones'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=35,Concepto = ''    Ayudas Sociales'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=36,Concepto = ''    Pensiones y Jubilaciones'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=37,Concepto = ''    Transferencias a Fideicomisos, Mandatos y Contratos Análogos'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=38,Concepto = ''    Transferencias a la Seguridad Social'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=39,Concepto = ''    Donativos'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=40,Concepto = ''    Transferencias al Exterior'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=41,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--
	UNION
	SELECT id=42,Concepto = ''  Participaciones y Aportaciones'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=43,Concepto = ''    Participaciones'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=44,Concepto = ''    Aportaciones'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=45,Concepto = ''    Convenios'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=46,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--
	UNION
	SELECT id=47,Concepto = ''  Intereses, Comisiones y Otros Gastos de la Deuda Pública'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=48,Concepto = ''    Intereses de la Deuda Pública'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=49,Concepto = ''    Comisiones de la Deuda Pública'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=50,Concepto = ''    Gastos de la Deuda Pública'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=51,Concepto = ''    Costo por Coberturas'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=52,Concepto = ''    Apoyos Financieros'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=53,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--
	UNION
	SELECT id=54,Concepto = ''  Otros Gastos y Pérdidas Extraordinarias'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=55,Concepto = ''    Estimaciones, Depreciaciones, Deterioros, Obsolescencia y Amortizaciones'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=56,Concepto = ''    Provisiones'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=57,Concepto = ''    Disminución de Inventarios'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=58,Concepto = ''    Otros Gastos'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=59,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--
	UNION
	SELECT id=60,Concepto = ''  Inversión Pública'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=61,Concepto = ''    Inversión Pública no Capitalizable'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=62,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--
	UNION
	SELECT id=63,Concepto = ''Total de Gastos y Otras Pérdidas'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=64,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--
	UNION
	SELECT id=65,Concepto = ''Resultados del Ejercicio (Ahorro/Desahorro)'', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	UNION
	SELECT id=66,Concepto = '' '', [20XN] = 0, [20XN1] = 0, Firma1 = ''Eliseo'', Firma2 = ''Yo'', Firma3 = ''otro yo''
	--FIN
END';
-- [PRES].[SP_MantenimientoDeposito] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(163531666))),2) <> 'F682C04FC5922BA17011FA4D2171E57C675C0E0623F801F900DA63D0621C44C3' OR OBJECT_DEFINITION(163531666) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE PRES.SP_MantenimientoDeposito
(
    @Action INT,
    @PKIdDeposito INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdIngresoAutorizado_PRES INT = NULL,
    @FKIdTipoDoctoPago_CONTA INT = NULL,
    @Importe DECIMAL(18,2) = NULL,
    @NumeroReferencia NVARCHAR(50) = NULL,
    @ConceptoCheque NVARCHAR(150) = NULL,
    @FechaEmision DATE = NULL,
    @NombreAportante NVARCHAR(500) = NULL,
    @FKIdCuentaCargo_CONTA INT = NULL,
    @FKIdCuentaAbono_CONTA INT = NULL,
    @FKIdCLCFactura_PRES INT = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @Enero DECIMAL(18,2) = 0,
    @Febrero DECIMAL(18,2) = 0,
    @Marzo DECIMAL(18,2) = 0,
    @Abril DECIMAL(18,2) = 0,
    @Mayo DECIMAL(18,2) = 0,
    @Junio DECIMAL(18,2) = 0,
    @Julio DECIMAL(18,2) = 0,
    @Agosto DECIMAL(18,2) = 0,
    @Septiembre DECIMAL(18,2) = 0,
    @Octubre DECIMAL(18,2) = 0,
    @Noviembre DECIMAL(18,2) = 0,
    @Diciembre DECIMAL(18,2) = 0,
    @Observaciones NVARCHAR(500) = NULL,
    @IdUser INT = NULL,
    @Id INT = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    DECLARE
        @Now DATETIME2(7) = SYSDATETIME(),
        @Tipo NVARCHAR(20) = N''OK'',
        @Message NVARCHAR(4000),
        @Error NVARCHAR(MAX),
        @ReturnCode INT,
        @FKIdAnio_SIS INT,
        @FKIdMes_SIS INT,
        @FKIdTipoPoliza_SIS INT = 3,
        @NombrePoliza NVARCHAR(1000),
        @PolizaNueva INT,
        @ClavePoliza NVARCHAR(10),
        @FechaReferencia DATE,
        @FKIdPrograma_PRES INT,
        @FKIdOrigen_PRES INT,
        @CuentaDevengado INT,
        @CuentaDeposito INT,
        @ImportePoliza DECIMAL(18,2);

    BEGIN TRY
        IF @Action IN (4, 5)
        BEGIN
            IF @Action = 4
                SELECT * FROM PRES.Vw_Deposito WHERE PKIdDeposito = @PKIdDeposito;
            ELSE
                SELECT * FROM PRES.Vw_Deposito ORDER BY FechaEmision DESC, PKIdDeposito DESC;

            RETURN 0;
        END

        IF @Action NOT IN (1, 2, 3)
            THROW 51001, ''Accion invalida. Use 1=Insert, 2=Update, 3=Delete, 4=GetById, 5=GetAll.'', 1;

        IF ISNULL(@IdUser, 0) <= 0
            THROW 51002, ''No se recibio un usuario autenticado valido.'', 1;

        BEGIN TRANSACTION;

        IF @Action = 3
        BEGIN
            SELECT @FKIdPoliza_CONTA = FKIdPoliza_CONTA
            FROM PRES.Deposito
            WHERE PKIdDeposito = @PKIdDeposito AND Activo = 1;

            IF @FKIdPoliza_CONTA IS NULL
                THROW 51003, ''Deposito no encontrado.'', 1;

            UPDATE PRES.Deposito
            SET Activo = 0,
                FechaModificacion = @Now,
                UsuarioModificacion = @IdUser
            WHERE PKIdDeposito = @PKIdDeposito;

            UPDATE CONTA.PolizaDetalle
            SET Activo = 0,
                FechaModificacion = @Now,
                UsuarioModificacion = @IdUser
            WHERE FKIdPoliza_CONTA = @FKIdPoliza_CONTA
              AND FKIdReferencia = @PKIdDeposito
              AND Activo = 1;

            IF OBJECT_ID(N''CONTA.SP_UPDATE_PolizaBalanceada'', N''P'') IS NOT NULL
                EXEC CONTA.SP_UPDATE_PolizaBalanceada
                    @PKIdPoliza = @FKIdPoliza_CONTA,
                    @IdUser = @IdUser,
                    @Error = @Error OUTPUT;

            SET @Id = @PKIdDeposito;
            SET @Message = CONCAT(''Se elimino correctamente el deposito. Verifique poliza '', @FKIdPoliza_CONTA);

            COMMIT TRANSACTION;

            SELECT JSON_QUERY(CONCAT(
                ''{"tipo":"OK","mensaje":"'', STRING_ESCAPE(@Message, ''json''),
                ''","liga":"idPoliza: '', @FKIdPoliza_CONTA, ''"}''
            )) AS ResultJson;

            RETURN 0;
        END

        IF @Action = 2
        BEGIN
            IF @PKIdDeposito IS NULL OR NOT EXISTS (SELECT 1 FROM PRES.Deposito WHERE PKIdDeposito = @PKIdDeposito AND Activo = 1)
                THROW 51004, ''Deposito no encontrado.'', 1;
        END

        IF @FKIdCLCFactura_PRES IS NOT NULL
        BEGIN
            SELECT
                @FKIdEmpresa_SIS = ISNULL(@FKIdEmpresa_SIS, cf.FKIdEmpresa_SIS),
                @FKIdIngresoAutorizado_PRES = ISNULL(@FKIdIngresoAutorizado_PRES, cf.FKIdIngresoAutorizado_PRES),
                @FechaReferencia = cf.Fecha
            FROM PRES.CLCFactura cf
            WHERE cf.PKIdCLCFactura = @FKIdCLCFactura_PRES
              AND cf.Activo = 1;
        END

        IF @FKIdIngresoAutorizado_PRES IS NULL
            THROW 51005, ''Debe indicar FKIdIngresoAutorizado_PRES o un CLCFactura relacionado a un ingreso autorizado.'', 1;

        SELECT
            @FKIdPrograma_PRES = ia.FKIdPrograma_PRES,
            @FKIdOrigen_PRES = ia.FKIdOrigen_PRES,
            @FechaReferencia = ISNULL(@FechaReferencia, ia.Fecha)
        FROM PRES.IngresoAutorizado ia
        WHERE ia.PKIdIngresoAutorizado = @FKIdIngresoAutorizado_PRES
          AND ia.Activo = 1;

        IF @FKIdPrograma_PRES IS NULL OR @FKIdOrigen_PRES IS NULL
            THROW 51006, ''Ingreso autorizado no encontrado o incompleto.'', 1;

        IF @FKIdEmpresa_SIS IS NULL
            THROW 51007, ''Debe indicar FKIdEmpresa_SIS.'', 1;

        IF @FKIdTipoDoctoPago_CONTA IS NULL OR @FechaEmision IS NULL OR @FKIdCuentaCargo_CONTA IS NULL OR @FKIdCuentaAbono_CONTA IS NULL
            THROW 51008, ''Faltan datos obligatorios del deposito.'', 1;

        IF @FechaReferencia IS NOT NULL AND @FechaEmision <= @FechaReferencia
            THROW 51009, ''Fecha Emision debe ser mayor a la Fecha de Ingreso/CLC.'', 1;

        IF @FKIdCLCFactura_PRES IS NOT NULL AND EXISTS
        (
            SELECT 1
            FROM PRES.Deposito
            WHERE FKIdCLCFactura_PRES = @FKIdCLCFactura_PRES
              AND Activo = 1
              AND (@Action = 1 OR PKIdDeposito <> @PKIdDeposito)
        )
            THROW 51010, ''Ya existe un deposito activo para el CLC seleccionado.'', 1;

        SELECT @FKIdAnio_SIS = a.PKIdAnio
        FROM SIS.Anio a
        WHERE a.Clave = YEAR(@FechaEmision)
          AND a.Activo = 1;

        IF @FKIdAnio_SIS IS NULL
            THROW 51011, ''No existe anio presupuestal para la FechaEmision.'', 1;

        SET @FKIdMes_SIS = MONTH(@FechaEmision);

        SELECT
            @CuentaDevengado = mi.Fk_IdCuentaContableDevengado,
            @CuentaDeposito = mi.Fk_IdCuentaContableDeposito
        FROM CONTA.MatrizIngreso mi
        WHERE mi.FK_IdAnio__SIS = @FKIdAnio_SIS
          AND mi.Fk_IdPrograma = @FKIdPrograma_PRES
          AND mi.Fk_IdOrigen = @FKIdOrigen_PRES
          AND mi.Activo = 1;

        IF @CuentaDevengado IS NULL OR @CuentaDeposito IS NULL
            THROW 51012, ''Error en la matriz de ingreso: faltan cuentas Devengado o Deposito para el programa/origen/anio.'', 1;

        SET @ImportePoliza =
            ISNULL(@Enero,0) + ISNULL(@Febrero,0) + ISNULL(@Marzo,0) + ISNULL(@Abril,0) +
            ISNULL(@Mayo,0) + ISNULL(@Junio,0) + ISNULL(@Julio,0) + ISNULL(@Agosto,0) +
            ISNULL(@Septiembre,0) + ISNULL(@Octubre,0) + ISNULL(@Noviembre,0) + ISNULL(@Diciembre,0);

        IF @ImportePoliza = 0
            SET @ImportePoliza = ISNULL(@Importe, 0);

        IF @ImportePoliza <= 0
            THROW 51013, ''El importe del deposito debe ser mayor a cero.'', 1;

        SET @Importe = ISNULL(@Importe, @ImportePoliza);
        SET @ConceptoCheque = NULLIF(LTRIM(RTRIM(@ConceptoCheque)), N'''');
        SET @ConceptoCheque = ISNULL(@ConceptoCheque, N''Deposito de ingreso'');
        SET @NombrePoliza = CONCAT(N''Pres: Recaudado: '', YEAR(@FechaEmision), N'' '', @ConceptoCheque, N'' '', ISNULL(@NumeroReferencia, N''''));

        IF @Action = 1
        BEGIN
            SET @PolizaNueva = ISNULL(@FKIdPoliza_CONTA, 0);

            IF @PolizaNueva = 0 OR ISNULL((SELECT TOP 1 ClavePoliza FROM CONTA.Poliza WHERE PKIdPoliza = @PolizaNueva), N'''') = N''NUEVA''
            BEGIN
                EXEC @ReturnCode = CONTA.SP_MantenimientoPoliza
                    @Action = 1,
                    @PKIdPoliza = NULL,
                    @FKIdAnio_SIS = @FKIdAnio_SIS,
                    @FKIdMes_SIS = @FKIdMes_SIS,
                    @FKIdTipoPoliza_SIS = @FKIdTipoPoliza_SIS,
                    @NombrePoliza = @NombrePoliza,
                    @FechaPoliza = @FechaEmision,
                    @EstaBalanceado = 0,
                    @PermitirModificar = 1,
                    @FKIdAccionAutorizar_SIS = NULL,
                    @Autorizado = 0,
                    @FechaSolicitud = @Now,
                    @FechaAutorizacion = NULL,
                    @IdUser = @IdUser,
                    @Id = @PolizaNueva OUTPUT;

                IF @ReturnCode <> 0 OR ISNULL(@PolizaNueva, 0) = 0
                    THROW 51014, ''No se pudo generar la poliza.'', 1;
            END

            INSERT INTO PRES.Deposito
            (
                FKIdEmpresa_SIS, FKIdIngresoAutorizado_PRES, FKIdTipoDoctoPago_CONTA, Importe,
                NumeroReferencia, ConceptoCheque, FechaEmision, NombreAportante,
                FKIdCuentaCargo_CONTA, FKIdCuentaAbono_CONTA, FKIdCLCFactura_PRES, FKIdPoliza_CONTA,
                Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
                Observaciones, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES
            (
                @FKIdEmpresa_SIS, @FKIdIngresoAutorizado_PRES, @FKIdTipoDoctoPago_CONTA, @Importe,
                @NumeroReferencia, @ConceptoCheque, @FechaEmision, @NombreAportante,
                @FKIdCuentaCargo_CONTA, @FKIdCuentaAbono_CONTA, @FKIdCLCFactura_PRES, @PolizaNueva,
                ISNULL(@Enero,0), ISNULL(@Febrero,0), ISNULL(@Marzo,0), ISNULL(@Abril,0),
                ISNULL(@Mayo,0), ISNULL(@Junio,0), ISNULL(@Julio,0), ISNULL(@Agosto,0),
                ISNULL(@Septiembre,0), ISNULL(@Octubre,0), ISNULL(@Noviembre,0), ISNULL(@Diciembre,0),
                @Observaciones, 1, @Now, @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @FKIdPoliza_CONTA = @PolizaNueva;
        END
        ELSE IF @Action = 2
        BEGIN
            SELECT @FKIdPoliza_CONTA = FKIdPoliza_CONTA
            FROM PRES.Deposito
            WHERE PKIdDeposito = @PKIdDeposito
              AND Activo = 1;

            UPDATE PRES.Deposito
            SET
                FKIdEmpresa_SIS = @FKIdEmpresa_SIS,
                FKIdIngresoAutorizado_PRES = @FKIdIngresoAutorizado_PRES,
                FKIdTipoDoctoPago_CONTA = @FKIdTipoDoctoPago_CONTA,
                Importe = @Importe,
                NumeroReferencia = @NumeroReferencia,
                ConceptoCheque = @ConceptoCheque,
                FechaEmision = @FechaEmision,
                NombreAportante = @NombreAportante,
                FKIdCuentaCargo_CONTA = @FKIdCuentaCargo_CONTA,
                FKIdCuentaAbono_CONTA = @FKIdCuentaAbono_CONTA,
                FKIdCLCFactura_PRES = @FKIdCLCFactura_PRES,
                Enero = ISNULL(@Enero,0),
                Febrero = ISNULL(@Febrero,0),
                Marzo = ISNULL(@Marzo,0),
                Abril = ISNULL(@Abril,0),
                Mayo = ISNULL(@Mayo,0),
                Junio = ISNULL(@Junio,0),
                Julio = ISNULL(@Julio,0),
                Agosto = ISNULL(@Agosto,0),
                Septiembre = ISNULL(@Septiembre,0),
                Octubre = ISNULL(@Octubre,0),
                Noviembre = ISNULL(@Noviembre,0),
                Diciembre = ISNULL(@Diciembre,0),
                Observaciones = @Observaciones,
                FechaModificacion = @Now,
                UsuarioModificacion = @IdUser
            WHERE PKIdDeposito = @PKIdDeposito;

            SET @Id = @PKIdDeposito;
        END

        DECLARE @Detalles TABLE
        (
            FKIdTipoDetallePoliza_SIS INT NOT NULL,
            FKIdCuentaContable_CONTA INT NOT NULL,
            ImporteDebe DECIMAL(18,2) NOT NULL,
            ImporteHaber DECIMAL(18,2) NOT NULL
        );

        INSERT INTO @Detalles
        VALUES
            (1, @CuentaDevengado, @ImportePoliza, 0),
            (2, @CuentaDeposito, 0, @ImportePoliza),
            (3, @FKIdCuentaCargo_CONTA, @ImportePoliza, 0),
            (4, @FKIdCuentaAbono_CONTA, 0, @ImportePoliza);

        MERGE CONTA.PolizaDetalle AS target
        USING @Detalles AS source
            ON target.FKIdPoliza_CONTA = @FKIdPoliza_CONTA
           AND target.FKIdReferencia = @Id
           AND target.FKIdTipoDetallePoliza_SIS = source.FKIdTipoDetallePoliza_SIS
           AND target.Activo = 1
        WHEN MATCHED THEN
            UPDATE SET
                target.FKIdCuentaContable_CONTA = source.FKIdCuentaContable_CONTA,
                target.Descripcion = @ConceptoCheque,
                target.ImporteDebe = source.ImporteDebe,
                target.ImporteHaber = source.ImporteHaber,
                target.FechaModificacion = @Now,
                target.UsuarioModificacion = @IdUser
        WHEN NOT MATCHED THEN
            INSERT
            (
                FKIdCuentaContable_CONTA, FKIdPoliza_CONTA, Descripcion, ImporteDebe, ImporteHaber,
                FKIdReferencia, FKIdTipoDetallePoliza_SIS, Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES
            (
                source.FKIdCuentaContable_CONTA, @FKIdPoliza_CONTA, @ConceptoCheque, source.ImporteDebe, source.ImporteHaber,
                @Id, source.FKIdTipoDetallePoliza_SIS, 1, @Now, @IdUser
            );

        IF OBJECT_ID(N''CONTA.SP_UPDATE_PolizaBalanceada'', N''P'') IS NOT NULL
            EXEC CONTA.SP_UPDATE_PolizaBalanceada
                @PKIdPoliza = @FKIdPoliza_CONTA,
                @IdUser = @IdUser,
                @Error = @Error OUTPUT;

        SET @Message = CONCAT(''Se registro correctamente el deposito. Presupuesto afectado '', @ImportePoliza, ''. Verifique poliza.'');

        COMMIT TRANSACTION;

        SELECT JSON_QUERY(CONCAT(
            ''{"tipo":"OK","mensaje":"'', STRING_ESCAPE(@Message, ''json''),
            ''","liga":"idPoliza: '', @FKIdPoliza_CONTA, ''"}''
        )) AS ResultJson;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Error = CONCAT(ISNULL(PROGRAM_NAME(), ''''), CHAR(10), ''Error: '', ERROR_MESSAGE(), CHAR(10), ''Linea: '', ERROR_LINE());

        SELECT JSON_QUERY(CONCAT(
            ''{"tipo":"ERROR","mensaje":"'', STRING_ESCAPE(@Error, ''json''),
            ''","liga":""}''
        )) AS ResultJson;

        RETURN -1;
    END CATCH
END';
-- [PRES].[SP_MantenimientoEgresoAutorizado] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(195531780))),2) <> 'C93EB3AD96C9D960F32A33ECA3C88FDE94DE4DA89E8267027DD1EA81D4B66DC6' OR OBJECT_DEFINITION(195531780) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER OFF;
EXEC sys.sp_executesql N'ALTER PROCEDURE [PRES].[SP_MantenimientoEgresoAutorizado]
    @Action INT,
    @PKIdEgresoAutorizado INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdPrograma_PRES INT = NULL,
    @FKIdFuenteFinanciamiento_PRES INT = NULL,
    @FKIdTipoGasto_PRES INT = NULL,
    @FKIdDigitoIdentificador_PRES INT = NULL,
    @FKIdDestinoGasto_PRES INT = NULL,
    @FKIdPY_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @Descripcion NVARCHAR(250) = NULL,
    @Fecha DATE = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @Enero DECIMAL(18, 2) = 0,
    @Febrero DECIMAL(18, 2) = 0,
    @Marzo DECIMAL(18, 2) = 0,
    @Abril DECIMAL(18, 2) = 0,
    @Mayo DECIMAL(18, 2) = 0,
    @Junio DECIMAL(18, 2) = 0,
    @Julio DECIMAL(18, 2) = 0,
    @Agosto DECIMAL(18, 2) = 0,
    @Septiembre DECIMAL(18, 2) = 0,
    @Octubre DECIMAL(18, 2) = 0,
    @Noviembre DECIMAL(18, 2) = 0,
    @Diciembre DECIMAL(18, 2) = 0,
    @IdUser INT = NULL,
    @FKIdEgresoProyectado_PRES INT = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @Tipo NVARCHAR(20) = N''OK'',
        @Mensaje NVARCHAR(MAX) = N'''',
        @Liga NVARCHAR(100) = N'''',
        @ErrorMessage NVARCHAR(MAX),
        @Hoy DATETIME2(7) = SYSDATETIME(),
        @IdMenu INT = 83,
        @AccionNotificacion INT = @Action,
        @FKIdAnio_SIS INT,
        @FKIdMes_SIS INT,
        @FKIdTipoPoliza_SIS INT = 1,
        @NombrePoliza NVARCHAR(1000),
        @ClavePoliza NVARCHAR(50),
        @ErrorPoliza NVARCHAR(MAX),
        @PolizaActual INT,
        @PolizaNueva INT,
        @CuentaAprobado INT,
        @CuentaPorEjercer INT,
        @Importe DECIMAL(18, 2),
        @Debe DECIMAL(18, 2),
        @Haber DECIMAL(18, 2);

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3)
        BEGIN
            SET @Tipo = N''ERROR'';
            SET @Mensaje = N''Accion no valida. Use 1=Insert, 2=Update, 3=Delete.'';
            GOTO Finish;
        END

        IF @IdUser IS NULL OR @IdUser <= 0
        BEGIN
            SET @Tipo = N''ERROR'';
            SET @Mensaje = N''No se recibio usuario para aplicar el mantenimiento.'';
            GOTO Finish;
        END

        IF @FKIdEmpresa_SIS IS NULL OR @FKIdEmpresa_SIS <= 0
        BEGIN
            SET @Tipo = N''ERROR''; SET @Mensaje = N''No se recibio la empresa actual.''; GOTO Finish;
        END

        IF NOT EXISTS (
            SELECT 1 FROM SIS.Usuario u WHERE u.PkIdUsuario = @IdUser AND u.Activo = 1
              AND (u.FKIdEmpresa_SIS = @FKIdEmpresa_SIS OR EXISTS (
                  SELECT 1 FROM SIS.UsuarioSucursal us INNER JOIN SIS.Sucursal s ON s.PKIdSucursal = us.FKIdSucursal_SIS
                  WHERE us.FKIdUsuario_SIS = @IdUser AND us.Activo = 1 AND us.PuedeAcceder = 1
                    AND s.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND s.Activo = 1)))
        BEGIN
            SET @Tipo = N''ERROR''; SET @Mensaje = N''El usuario no tiene acceso a la empresa indicada.''; GOTO Finish;
        END

        IF @Action = 1 AND (@FKIdEgresoProyectado_PRES IS NULL OR NOT EXISTS (
            SELECT 1 FROM PRES.EgresoProyectado ep WHERE ep.PKIdEgresoProyectado = @FKIdEgresoProyectado_PRES
              AND ep.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND ep.Activo = 1))
        BEGIN
            SET @Tipo = N''ERROR''; SET @Mensaje = N''El presupuesto autorizado debe originarse en un anteproyecto activo de la empresa actual.''; GOTO Finish;
        END

        IF @Action IN (2, 3) AND NOT EXISTS (
            SELECT 1 FROM PRES.EgresoAutorizado ea WHERE ea.PKIdEgresoAutorizado = @PKIdEgresoAutorizado
              AND ea.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND ea.Activo = 1)
        BEGIN
            SET @Tipo = N''ERROR''; SET @Mensaje = N''El presupuesto no pertenece a la empresa actual.''; GOTO Finish;
        END

        IF @Action = 1 AND EXISTS (
            SELECT 1 FROM PRES.EgresoAutorizado ea
            WHERE ea.FKIdEgresoProyectado_PRES = @FKIdEgresoProyectado_PRES
              AND ea.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND ea.Activo = 1)
        BEGIN
            SET @Tipo = N''ERROR''; SET @Mensaje = N''Ya existe un presupuesto autorizado activo para el anteproyecto indicado.''; GOTO Finish;
        END

        IF @Action IN (1, 2)
        BEGIN
            IF @FKIdPrograma_PRES IS NULL OR @FKIdPartida_CONTA IS NULL OR @FKIdArea_SIS IS NULL OR @Fecha IS NULL
            BEGIN
                SET @Tipo = N''ERROR'';
                SET @Mensaje = N''Faltan datos obligatorios del presupuesto autorizado.'';
                GOTO Finish;
            END

            SELECT @FKIdAnio_SIS = a.PKIdAnio
            FROM SIS.Anio AS a
            WHERE a.Clave = YEAR(@Fecha)
              AND a.Activo = 1;

            IF @FKIdAnio_SIS IS NULL
            BEGIN
                SET @Tipo = N''ERROR'';
                SET @Mensaje = CONCAT(N''No existe anio presupuestal activo para '', YEAR(@Fecha), N''.'');
                GOTO Finish;
            END

            SET @FKIdMes_SIS = MONTH(@Fecha);
            SET @NombrePoliza = CONCAT(N''Presupuesto de Egresos Autorizado: '', YEAR(@Fecha), N'' '', ISNULL(@Descripcion, N''''));
            SET @Importe = ISNULL(@Enero, 0) + ISNULL(@Febrero, 0) + ISNULL(@Marzo, 0) + ISNULL(@Abril, 0)
                + ISNULL(@Mayo, 0) + ISNULL(@Junio, 0) + ISNULL(@Julio, 0) + ISNULL(@Agosto, 0)
                + ISNULL(@Septiembre, 0) + ISNULL(@Octubre, 0) + ISNULL(@Noviembre, 0) + ISNULL(@Diciembre, 0);

            SELECT TOP (1)
                @CuentaAprobado = mc.FKIdCuentaContableAprobado,
                @CuentaPorEjercer = mc.FKIdCuentaContablePorEjercer
            FROM CONTA.MatrizConversion AS mc
            WHERE mc.FKIdAnio_SIS = @FKIdAnio_SIS
              AND mc.FKIdPrograma_PRES = @FKIdPrograma_PRES
              AND mc.FKIdPartida_SIS = @FKIdPartida_CONTA
              AND mc.Activo = 1;

            IF @CuentaAprobado IS NULL OR @CuentaPorEjercer IS NULL
            BEGIN
                SET @Tipo = N''ERROR'';
                SET @Mensaje = CONCAT(
                    N''No existe matriz de conversion activa para programa '',
                    @FKIdPrograma_PRES,
                    N'' y partida '',
                    @FKIdPartida_CONTA,
                    N''.'');
                GOTO Finish;
            END
        END

        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            SET @PolizaNueva = NULLIF(@FKIdPoliza_CONTA, 0);

            IF @PolizaNueva IS NULL
                OR ISNULL((SELECT TOP (1) ClavePoliza FROM CONTA.Poliza WHERE PKIdPoliza = @PolizaNueva), N'''') = N''NUEVA''
            BEGIN
                EXEC CONTA.SP_CREATE_ClavePoliza
                    @FK_IdAnio__SIS = @FKIdAnio_SIS,
                    @FK_IdMesConta__SIS = @FKIdMes_SIS,
                    @FK_IdTipoPolizaConta__SIS = @FKIdTipoPoliza_SIS,
                    @CT_ModifiedBy = @IdUser,
                    @ClavePoliza = @ClavePoliza OUTPUT,
                    @Error = @ErrorPoliza OUTPUT;

                IF ISNULL(@ClavePoliza, N'''') = N''''
                    THROW 51000, ''No se pudo generar la clave de poliza.'', 1;

                INSERT INTO CONTA.Poliza (
                    FKIdAnio_SIS,
                    FKIdMes_SIS,
                    FKIdTipoPoliza_SIS,
                    ClavePoliza,
                    NombrePoliza,
                    FechaPoliza,
                    EstaBalanceado,
                    Activo,
                    FechaCreacion,
                    UsuarioCreacion,
                    PermitirModificar,
                    Autorizado
                )
                VALUES (
                    @FKIdAnio_SIS,
                    @FKIdMes_SIS,
                    @FKIdTipoPoliza_SIS,
                    @ClavePoliza,
                    @NombrePoliza,
                    @Fecha,
                    0,
                    1,
                    @Hoy,
                    @IdUser,
                    1,
                    0
                );

                SET @PolizaNueva = SCOPE_IDENTITY();
            END

            INSERT INTO PRES.EgresoAutorizado (
                FKIdEmpresa_SIS,
                FKIdPrograma_PRES,
                FKIdPartida_CONTA,
                FKIdArea_SIS,
                Descripcion,
                Fecha,
                FKIdPoliza_CONTA,
                Activo,
                FechaCreacion,
                UsuarioCreacion,
                FKIdEgresoProyectado_PRES,
                Enero,
                Febrero,
                Marzo,
                Abril,
                Mayo,
                Junio,
                Julio,
                Agosto,
                Septiembre,
                Octubre,
                Noviembre,
                Diciembre,
                FechaAutorizacion,
                UsuarioAutorizacion,
                FKIdFuenteFinanciamiento_PRES,
                FKIdTipoGasto_PRES,
                FKIdDigitoIdentificador_PRES,
                FKIdDestinoGasto_PRES,
                FKIdPY_PRES
            )
            VALUES (
                @FKIdEmpresa_SIS,
                @FKIdPrograma_PRES,
                @FKIdPartida_CONTA,
                @FKIdArea_SIS,
                @Descripcion,
                @Fecha,
                @PolizaNueva,
                1,
                @Hoy,
                @IdUser,
                @FKIdEgresoProyectado_PRES,
                ISNULL(@Enero, 0),
                ISNULL(@Febrero, 0),
                ISNULL(@Marzo, 0),
                ISNULL(@Abril, 0),
                ISNULL(@Mayo, 0),
                ISNULL(@Junio, 0),
                ISNULL(@Julio, 0),
                ISNULL(@Agosto, 0),
                ISNULL(@Septiembre, 0),
                ISNULL(@Octubre, 0),
                ISNULL(@Noviembre, 0),
                ISNULL(@Diciembre, 0),
                @Hoy,
                @IdUser,
                @FKIdFuenteFinanciamiento_PRES,
                @FKIdTipoGasto_PRES,
                @FKIdDigitoIdentificador_PRES,
                @FKIdDestinoGasto_PRES,
                @FKIdPY_PRES
            );

            SET @PKIdEgresoAutorizado = SCOPE_IDENTITY();
            SET @FKIdPoliza_CONTA = @PolizaNueva;
            SET @Mensaje = CONCAT(N''Se registro correctamente el presupuesto autorizado de egresos '', @PKIdEgresoAutorizado, N''. Presupuesto afectado '', @Importe);
        END
        ELSE IF @Action = 2
        BEGIN
            SELECT @PolizaActual = ea.FKIdPoliza_CONTA
            FROM PRES.EgresoAutorizado AS ea
            WHERE ea.PKIdEgresoAutorizado = @PKIdEgresoAutorizado
              AND ea.Activo = 1;

            IF @PolizaActual IS NULL AND NOT EXISTS (
                SELECT 1 FROM PRES.EgresoAutorizado WHERE PKIdEgresoAutorizado = @PKIdEgresoAutorizado AND Activo = 1
            )
                THROW 51001, ''Presupuesto autorizado no encontrado.'', 1;

            SET @PolizaNueva = COALESCE(NULLIF(@FKIdPoliza_CONTA, 0), @PolizaActual);

            UPDATE CONTA.PolizaDetalle
            SET Activo = 0,
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE FKIdReferencia = @PKIdEgresoAutorizado
              AND FKIdPoliza_CONTA IN (@PolizaActual, @PolizaNueva)
              AND Activo = 1;

            UPDATE PRES.EgresoAutorizado
            SET FKIdPrograma_PRES = @FKIdPrograma_PRES,
                FKIdFuenteFinanciamiento_PRES = @FKIdFuenteFinanciamiento_PRES,
                FKIdTipoGasto_PRES = @FKIdTipoGasto_PRES,
                FKIdDigitoIdentificador_PRES = @FKIdDigitoIdentificador_PRES,
                FKIdDestinoGasto_PRES = @FKIdDestinoGasto_PRES,
                FKIdPY_PRES = @FKIdPY_PRES,
                FKIdPartida_CONTA = @FKIdPartida_CONTA,
                FKIdArea_SIS = @FKIdArea_SIS,
                Descripcion = @Descripcion,
                Fecha = @Fecha,
                FKIdPoliza_CONTA = @PolizaNueva,
                Enero = ISNULL(@Enero, 0),
                Febrero = ISNULL(@Febrero, 0),
                Marzo = ISNULL(@Marzo, 0),
                Abril = ISNULL(@Abril, 0),
                Mayo = ISNULL(@Mayo, 0),
                Junio = ISNULL(@Junio, 0),
                Julio = ISNULL(@Julio, 0),
                Agosto = ISNULL(@Agosto, 0),
                Septiembre = ISNULL(@Septiembre, 0),
                Octubre = ISNULL(@Octubre, 0),
                Noviembre = ISNULL(@Noviembre, 0),
                Diciembre = ISNULL(@Diciembre, 0),
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE PKIdEgresoAutorizado = @PKIdEgresoAutorizado
              AND Activo = 1;

            SET @FKIdPoliza_CONTA = @PolizaNueva;
            SET @Mensaje = CONCAT(N''Se actualizo correctamente el presupuesto autorizado de egresos '', @PKIdEgresoAutorizado, N''. Presupuesto afectado '', @Importe);
        END
        ELSE IF @Action = 3
        BEGIN
            SELECT @PolizaActual = ea.FKIdPoliza_CONTA
            FROM PRES.EgresoAutorizado AS ea
            WHERE ea.PKIdEgresoAutorizado = @PKIdEgresoAutorizado
              AND ea.Activo = 1;

            IF @PolizaActual IS NULL AND NOT EXISTS (
                SELECT 1 FROM PRES.EgresoAutorizado WHERE PKIdEgresoAutorizado = @PKIdEgresoAutorizado AND Activo = 1
            )
                THROW 51002, ''Presupuesto autorizado no encontrado.'', 1;

            UPDATE PRES.EgresoAutorizado
            SET Activo = 0,
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE PKIdEgresoAutorizado = @PKIdEgresoAutorizado;

            UPDATE CONTA.PolizaDetalle
            SET Activo = 0,
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE FKIdPoliza_CONTA = @PolizaActual
              AND FKIdReferencia = @PKIdEgresoAutorizado
              AND Activo = 1;

            SET @FKIdPoliza_CONTA = @PolizaActual;
            SET @Mensaje = CONCAT(N''Se elimino correctamente el presupuesto autorizado de egresos '', @PKIdEgresoAutorizado, N''.'');
        END

        IF @Action IN (1, 2)
        BEGIN
            INSERT INTO CONTA.PolizaDetalle (
                FKIdCuentaContable_CONTA,
                FKIdPoliza_CONTA,
                Descripcion,
                ImporteDebe,
                ImporteHaber,
                FKIdReferencia,
                FKIdTipoDetallePoliza_SIS,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            VALUES
            (
                @CuentaAprobado,
                @FKIdPoliza_CONTA,
                @NombrePoliza,
                @Importe,
                0,
                @PKIdEgresoAutorizado,
                1,
                1,
                @Hoy,
                @IdUser
            ),
            (
                @CuentaPorEjercer,
                @FKIdPoliza_CONTA,
                @NombrePoliza,
                0,
                @Importe,
                @PKIdEgresoAutorizado,
                2,
                1,
                @Hoy,
                @IdUser
            );
        END

        IF @FKIdPoliza_CONTA IS NOT NULL
        BEGIN
            SELECT
                @Debe = ISNULL(SUM(ImporteDebe), 0),
                @Haber = ISNULL(SUM(ImporteHaber), 0)
            FROM CONTA.PolizaDetalle
            WHERE FKIdPoliza_CONTA = @FKIdPoliza_CONTA
              AND Activo = 1;

            UPDATE CONTA.Poliza
            SET EstaBalanceado = CASE WHEN @Debe = @Haber THEN 1 ELSE 0 END,
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @FKIdPoliza_CONTA
              AND Activo = 1;
        END

        IF @PolizaActual IS NOT NULL AND @PolizaActual <> ISNULL(@FKIdPoliza_CONTA, 0)
        BEGIN
            SELECT
                @Debe = ISNULL(SUM(ImporteDebe), 0),
                @Haber = ISNULL(SUM(ImporteHaber), 0)
            FROM CONTA.PolizaDetalle
            WHERE FKIdPoliza_CONTA = @PolizaActual
              AND Activo = 1;

            UPDATE CONTA.Poliza
            SET EstaBalanceado = CASE WHEN @Debe = @Haber THEN 1 ELSE 0 END,
                FechaModificacion = @Hoy,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @PolizaActual
              AND Activo = 1;
        END

        EXEC [SIS].[SP_MantenimientoNotificacion]
            @Action = 1,
            @Fk_IdUsuarioOrigen = @IdUser,
            @Fk_IdMenu = @IdMenu,
            @Fk_IdAccionSuscrita = @AccionNotificacion,
            @Mensaje = @Mensaje,
            @IdUser = @IdUser,
            @Controlador = NULL,
            @Pk_IdNotificacion = NULL,
            @Fk_IdNotificacionPadre = NULL,
            @Fk_IdUnidades = NULL,
            @Fk_IdEstadoNotificacion = NULL,
            @Fk_IdCliente = NULL,
            @Fk_IdEmpresa = @FKIdEmpresa_SIS,
            @Importe = NULL,
            @IdRegistro = @PKIdEgresoAutorizado,
            @FechaCreacion = NULL,
            @FechaRecibido = NULL,
            @IntervaloNormal = NULL,
            @IntervaloAlerta = NULL,
            @IntervaloCritico = NULL,
            @Fk_IdUsuarioDestino = NULL;

        COMMIT TRANSACTION;

        SET @Liga = CONCAT(N''id:'', @PKIdEgresoAutorizado);

Finish:
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT CAST(JSON_QUERY(
            CONCAT(
                N''{"tipo":"'',
                STRING_ESCAPE(@Tipo, ''json''),
                N''","mensaje":"'',
                STRING_ESCAPE(ISNULL(@Mensaje, N''''), ''json''),
                N''","liga":"'',
                STRING_ESCAPE(ISNULL(@Liga, N''''), ''json''),
                N''"}''
            )
        ) AS NVARCHAR(MAX)) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ErrorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), N''''),
            CHAR(10),
            N''Error: '',
            ERROR_MESSAGE(),
            CHAR(10),
            N''Linea: '',
            ERROR_LINE()
        );

        SELECT CAST(JSON_QUERY(
            CONCAT(
                N''{"tipo":"ERROR","mensaje":"'',
                STRING_ESCAPE(@ErrorMessage, ''json''),
                N''","liga":""}''
            )
        ) AS NVARCHAR(MAX)) AS ResultJson;
    END CATCH
END';
-- [SICOP].[SPR_LibroInventarioBienes] : hints retirados=0; XACT_ABORT=False
IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION(323532236))),2) <> '996277A210E439CFE3B6192C4842423102E3A4A56A3EC86CFC186EDB74DBB4DC' OR OBJECT_DEFINITION(323532236) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
EXEC sys.sp_executesql N'ALTER   PROCEDURE [SICOP].[SPR_LibroInventarioBienes]
    @p_FecInicio nvarchar(24)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = TRY_CONVERT(date, @p_FecInicio);

    DECLARE @tablaFirma table (
        id int IDENTITY(1,1) NOT NULL,
        Funcion nvarchar(64) NULL,
        Nombre nvarchar(254) NULL
    );

    INSERT INTO @tablaFirma (Funcion, Nombre)
    SELECT F.[Funcion], CONCAT(P.[Nombre], '' '', P.[Paterno], '' '', P.[Materno])
    FROM [SIS].[Reporte] AS R
    INNER JOIN [SIS].[FirmaAutorizada] AS F ON R.[Pk_IdReporte] = F.[Fk_IdReporte__SIS]
    INNER JOIN [RHCT].[Persona] AS P ON F.[Fk_IdPersona__RHCT] = P.[PK_IdPersona]
    WHERE R.[Controlador] = ''RepLibroInventarioBienes''
      AND R.[Activo] = 1
      AND F.[Activo] = 1;

    DECLARE @Funcion1 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 1), '''');
    DECLARE @Funcion2 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 2), '''');
    DECLARE @Funcion3 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 3), '''');
    DECLARE @Nombre1 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 1), '''');
    DECLARE @Nombre2 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 2), '''');
    DECLARE @Nombre3 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 3), '''');
    DECLARE @Puesto1 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre1 + ''%''), '''');
    DECLARE @Puesto2 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre2 + ''%''), '''');
    DECLARE @Puesto3 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, '' '', Paterno, '' '', Materno) LIKE ''%'' + @Nombre3 + ''%''), '''');

    SELECT
        bn.[PK_IdBien],
        bn.[Clave] AS [NumeroInventario],
        bn.[Descripcion],
        CAST(1 AS int) AS [Cantidad],
        un.[Descripcion] AS [Unidades],
        bn.[Costo],
        bn.[Costo] AS [Monto],
        @Funcion1 AS [Funcion1],
        @Funcion2 AS [Funcion2],
        @Funcion3 AS [Funcion3],
        @Nombre1 AS [Nombre1],
        @Nombre2 AS [Nombre2],
        @Nombre3 AS [Nombre3],
        @Puesto1 AS [Puesto1],
        @Puesto2 AS [Puesto2],
        @Puesto3 AS [Puesto3],
        CAST(CONCAT(''AL '', UPPER(FORMAT(ISNULL(@p_FechaInicio, GETDATE()), ''dd \DE MMMM \DEL yyyy'', ''es-MX''))) AS nvarchar(128)) AS [Titulo]
    FROM [SICOP].[VW_Bien] AS bn
    INNER JOIN [SICOP].[TipoBien] AS tb ON bn.[FK_IdTipoBien__SICOP] = tb.[PK_IdTipoBien]
    LEFT JOIN [ALMA].[Unidades] AS un ON tb.[FK_IdUnidades_Equivalente] = un.[PKIdUnidades]
    ORDER BY bn.[Clave];
END;';
COMMIT TRANSACTION;
END TRY BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK TRANSACTION; THROW; END CATCH;
