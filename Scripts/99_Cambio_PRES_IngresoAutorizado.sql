USE [GestionEmpresarial]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [PRES].[Vw_IngresoAutorizado]
AS
SELECT
    ia.[PKIdIngresoAutorizado],
    ia.[FKIdPrograma_PRES],
    p.[FKIdAnio_SIS],
    p.[Clave] AS [ProgramaClave],
    p.[Descripcion] AS [ProgramaDescripcion],
    CONCAT(p.[Clave], N' - ', p.[Descripcion]) AS [ProgramaClaveNombre],
    p.[Descripcion] AS [AreaFuncional],

    ia.[FKIdOrigen_PRES],
    o.[Clave] AS [OrigenClave],
    o.[Descripcion] AS [OrigenDescripcion],
    CONCAT(CONVERT(nvarchar(20), o.[Clave]), N' - ', o.[Descripcion]) AS [OrigenClaveNombre],
    o.[Descripcion] AS [Origen],

    ia.[FKIdFuenteFinanciamiento_PRES],
    ff.[Clave] AS [FuenteFinanciamientoClave],
    ff.[Descripcion] AS [FuenteFinanciamientoDescripcion],
    CASE
        WHEN ff.[PKIdFuenteFinanciamiento] IS NULL THEN NULL
        ELSE CONCAT(ff.[Clave], N' - ', ff.[Descripcion])
    END AS [FuenteFinanciamientoClaveNombre],
    ff.[Clave] AS [FF],

    ia.[FKIdTipoGasto_PRES],
    tg.[Clave] AS [TipoGastoClave],
    tg.[Descripcion] AS [TipoGastoDescripcion],
    CASE
        WHEN tg.[PKIdTipoGasto] IS NULL THEN NULL
        ELSE CONCAT(CONVERT(nvarchar(20), tg.[Clave]), N' - ', tg.[Descripcion])
    END AS [TipoGastoClaveNombre],
    tg.[Clave] AS [TG],

    ia.[FKIdDigitoIdentificador_PRES],
    di.[Clave] AS [DigitoIdentificadorClave],
    di.[Descripcion] AS [DigitoIdentificadorDescripcion],
    CASE
        WHEN di.[PKIdDigitoIdentificador] IS NULL THEN NULL
        ELSE CONCAT(di.[Clave], N' - ', di.[Descripcion])
    END AS [DigitoIdentificadorClaveNombre],
    di.[Clave] AS [DI],

    ia.[FKIdDestinoGasto_PRES],
    dg.[Clave] AS [DestinoGastoClave],
    dg.[Descripcion] AS [DestinoGastoDescripcion],
    CASE
        WHEN dg.[PKIdDestinoGasto] IS NULL THEN NULL
        ELSE CONCAT(dg.[Clave], N' - ', dg.[Descripcion])
    END AS [DestinoGastoClaveNombre],
    dg.[Clave] AS [DG],

    CONCAT(
        p.[Descripcion],
        N' ',
        ISNULL(ff.[Clave], N''),
        N' ',
        ISNULL(CONVERT(nvarchar(20), tg.[Clave]), N''),
        N' ',
        ISNULL(di.[Clave], N''),
        N' ',
        ISNULL(dg.[Clave], N'')
    ) AS [PosicionPresupuestal],

    ia.[Descripcion],
    ia.[Fecha],
    ia.[FKIdPoliza_CONTA],
    ia.[Enero],
    ia.[Febrero],
    ia.[Marzo],
    ia.[Abril],
    ia.[Mayo],
    ia.[Junio],
    ia.[Julio],
    ia.[Agosto],
    ia.[Septiembre],
    ia.[Octubre],
    ia.[Noviembre],
    ia.[Diciembre],
    ia.[Total],
    ia.[FechaAutorizacion],
    ia.[UsuarioAutorizacion],
    ia.[Activo],
    ia.[FechaCreacion],
    ia.[UsuarioCreacion],
    ia.[FechaModificacion],
    ia.[UsuarioModificacion],

    CAST(N'' AS nvarchar(4000)) AS [Message],
    CAST(
        CONCAT(
            p.[Descripcion],
            N' ',
            ISNULL(ff.[Clave], N''),
            N' ',
            ISNULL(CONVERT(nvarchar(20), tg.[Clave]), N''),
            N' ',
            ISNULL(di.[Clave], N''),
            N' ',
            ISNULL(dg.[Clave], N''),
            N' ',
            ISNULL(ia.[Descripcion], N''),
            N' $',
            CONVERT(varchar(32), CONVERT(money, ISNULL(ia.[Total], 0)), 1)
        ) AS nvarchar(4000)
    ) AS [DescripcionRequisicion]
FROM [PRES].[IngresoAutorizado] ia
INNER JOIN [PRES].[Programa] p
    ON ia.[FKIdPrograma_PRES] = p.[PKIdPrograma]
   AND p.[Activo] = 1
INNER JOIN [PRES].[Origen] o
    ON ia.[FKIdOrigen_PRES] = o.[PKIdOrigen]
   AND o.[Activo] = 1
LEFT JOIN [PRES].[FuenteFinanciamiento] ff
    ON ia.[FKIdFuenteFinanciamiento_PRES] = ff.[PKIdFuenteFinanciamiento]
   AND ff.[Activo] = 1
LEFT JOIN [PRES].[TipoGasto] tg
    ON ia.[FKIdTipoGasto_PRES] = tg.[PKIdTipoGasto]
   AND tg.[Activo] = 1
LEFT JOIN [PRES].[DigitoIdentificador] di
    ON ia.[FKIdDigitoIdentificador_PRES] = di.[PKIdDigitoIdentificador]
   AND di.[Activo] = 1
LEFT JOIN [PRES].[DestinoGasto] dg
    ON ia.[FKIdDestinoGasto_PRES] = dg.[PKIdDestinoGasto]
   AND dg.[Activo] = 1
WHERE ia.[Activo] = 1;
GO

CREATE OR ALTER PROCEDURE [PRES].[sp_MantenimientoIngresoAutorizado]
    @Action int, -- 1=Insert, 2=Update, 3=Delete, 4=Authorize
    @PKIdIngresoAutorizado int = NULL,
    @FKIdPrograma_PRES int = NULL,
    @FKIdOrigen_PRES int = NULL,
    @Descripcion nvarchar(250) = NULL,
    @Fecha date = NULL,
    @FKIdPoliza_CONTA int = NULL,
    @Enero decimal(18, 2) = 0,
    @Febrero decimal(18, 2) = 0,
    @Marzo decimal(18, 2) = 0,
    @Abril decimal(18, 2) = 0,
    @Mayo decimal(18, 2) = 0,
    @Junio decimal(18, 2) = 0,
    @Julio decimal(18, 2) = 0,
    @Agosto decimal(18, 2) = 0,
    @Septiembre decimal(18, 2) = 0,
    @Octubre decimal(18, 2) = 0,
    @Noviembre decimal(18, 2) = 0,
    @Diciembre decimal(18, 2) = 0,
    @FKIdFuenteFinanciamiento_PRES int = NULL,
    @FKIdTipoGasto_PRES int = NULL,
    @FKIdDigitoIdentificador_PRES int = NULL,
    @FKIdDestinoGasto_PRES int = NULL,
    @IdUser int,
    @Id int = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @Now datetime2(7) = SYSDATETIME(),
        @Total decimal(29, 2),
        @FKIdAnio_SIS int,
        @FKIdMes_SIS int,
        @FKIdTipoPoliza_SIS int = 4,
        @FKIdCuentaAutorizado_CONTA int,
        @FKIdCuentaPorEjercer_CONTA int,
        @NombrePoliza nvarchar(1000),
        @ClavePoliza nvarchar(10),
        @Error nvarchar(max),
        @ReturnCode int,
        @PolizaActual int,
        @PolizaAnio int,
        @PolizaMes int,
        @PolizaAutorizada bit,
        @PolizaPermitirModificar bit,
        @IngresoAutorizado bit,
        @DetalleDebeId int,
        @DetalleHaberId int,
        @Message nvarchar(4000),
        @Tipo nvarchar(20) = N'OK';

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3, 4)
            THROW 51020, 'Accion invalida. Use 1=Insert, 2=Update, 3=Delete o 4=Authorize.', 1;

        IF ISNULL(@IdUser, 0) <= 0
            THROW 51021, 'No se recibio un usuario autenticado valido.', 1;

        BEGIN TRANSACTION;

        IF @Action IN (1, 2)
        BEGIN
            SET @Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), N'');

            IF @FKIdPrograma_PRES IS NULL OR @FKIdOrigen_PRES IS NULL OR @Fecha IS NULL OR @Descripcion IS NULL
                THROW 51022, 'Programa, origen, fecha y descripcion son obligatorios.', 1;

            IF @Enero < 0 OR @Febrero < 0 OR @Marzo < 0 OR @Abril < 0 OR
               @Mayo < 0 OR @Junio < 0 OR @Julio < 0 OR @Agosto < 0 OR
               @Septiembre < 0 OR @Octubre < 0 OR @Noviembre < 0 OR @Diciembre < 0
                THROW 51023, 'Los importes mensuales no pueden ser negativos.', 1;

            SET @Total =
                ISNULL(@Enero, 0) + ISNULL(@Febrero, 0) + ISNULL(@Marzo, 0) + ISNULL(@Abril, 0) +
                ISNULL(@Mayo, 0) + ISNULL(@Junio, 0) + ISNULL(@Julio, 0) + ISNULL(@Agosto, 0) +
                ISNULL(@Septiembre, 0) + ISNULL(@Octubre, 0) + ISNULL(@Noviembre, 0) + ISNULL(@Diciembre, 0);

            IF @Total <= 0
                THROW 51024, 'El total autorizado debe ser mayor a cero.', 1;

            SELECT @FKIdAnio_SIS = a.[PKIdAnio]
            FROM [SIS].[Anio] a
            WHERE a.[Clave] = YEAR(@Fecha)
              AND a.[Activo] = 1;

            IF @FKIdAnio_SIS IS NULL
                THROW 51025, 'No existe un anio presupuestal activo para la fecha capturada.', 1;

            IF NOT EXISTS (
                SELECT 1
                FROM [PRES].[Programa] p
                WHERE p.[PKIdPrograma] = @FKIdPrograma_PRES
                  AND p.[FKIdAnio_SIS] = @FKIdAnio_SIS
                  AND p.[Activo] = 1
            )
                THROW 51026, 'El programa no corresponde al anio presupuestal de la fecha.', 1;

            IF NOT EXISTS (
                SELECT 1
                FROM [PRES].[Origen] o
                WHERE o.[PKIdOrigen] = @FKIdOrigen_PRES
                  AND o.[Activo] = 1
            )
                THROW 51027, 'El origen seleccionado no esta activo.', 1;

            IF (
                SELECT COUNT_BIG(1)
                FROM [CONTA].[MatrizIngreso] mi
                WHERE mi.[FK_IdAnio__SIS] = @FKIdAnio_SIS
                  AND mi.[Fk_IdPrograma] = @FKIdPrograma_PRES
                  AND mi.[Fk_IdOrigen] = @FKIdOrigen_PRES
                  AND mi.[Activo] = 1
            ) <> 1
                THROW 51028, 'Debe existir una sola matriz de ingreso activa para el anio, programa y origen.', 1;

            SELECT
                @FKIdCuentaAutorizado_CONTA = mi.[Fk_IdCuentaContableAutorizado],
                @FKIdCuentaPorEjercer_CONTA = mi.[Fk_IdCuentaContablePorEjercer]
            FROM [CONTA].[MatrizIngreso] mi
            WHERE mi.[FK_IdAnio__SIS] = @FKIdAnio_SIS
              AND mi.[Fk_IdPrograma] = @FKIdPrograma_PRES
              AND mi.[Fk_IdOrigen] = @FKIdOrigen_PRES
              AND mi.[Activo] = 1;

            IF @FKIdCuentaAutorizado_CONTA IS NULL OR @FKIdCuentaPorEjercer_CONTA IS NULL
                THROW 51029, 'La matriz de ingreso no tiene configuradas las cuentas autorizado y por ejercer.', 1;

            SET @FKIdMes_SIS = MONTH(@Fecha);
            SET @NombrePoliza = CONCAT(N'Ley de Ingresos Estimados ', YEAR(@Fecha), N' - ', @Descripcion);
        END

        IF @Action = 1
        BEGIN
            IF ISNULL(@FKIdPoliza_CONTA, 0) = 0
            BEGIN
                SET @Error = NULL;
                EXEC @ReturnCode = [CONTA].[SP_CREATE_ClavePoliza]
                    @FK_IdAnio__SIS = @FKIdAnio_SIS,
                    @FK_IdMesConta__SIS = @FKIdMes_SIS,
                    @FK_IdTipoPolizaConta__SIS = @FKIdTipoPoliza_SIS,
                    @CT_ModifiedBy = @IdUser,
                    @ClavePoliza = @ClavePoliza OUTPUT,
                    @Error = @Error OUTPUT;

                IF @ReturnCode <> 0 OR NULLIF(@Error, N'') IS NOT NULL OR NULLIF(@ClavePoliza, N'') IS NULL
                BEGIN
                    SET @Error = COALESCE(NULLIF(@Error, N''), N'No fue posible generar la clave de poliza.');
                    THROW 51030, @Error, 1;
                END

                INSERT INTO [CONTA].[Poliza]
                (
                    [FKIdAnio_SIS], [FKIdMes_SIS], [FKIdTipoPoliza_SIS], [ClavePoliza],
                    [NombrePoliza], [FechaPoliza], [EstaBalanceado], [Activo],
                    [FechaCreacion], [UsuarioCreacion], [PermitirModificar], [Autorizado]
                )
                VALUES
                (
                    @FKIdAnio_SIS, @FKIdMes_SIS, @FKIdTipoPoliza_SIS, @ClavePoliza,
                    @NombrePoliza, @Fecha, 0, 1, @Now, @IdUser, 1, 0
                );

                SET @FKIdPoliza_CONTA = CONVERT(int, SCOPE_IDENTITY());
            END
            ELSE
            BEGIN
                SELECT
                    @PolizaAnio = p.[FKIdAnio_SIS],
                    @PolizaMes = p.[FKIdMes_SIS],
                    @PolizaAutorizada = p.[Autorizado],
                    @PolizaPermitirModificar = p.[PermitirModificar]
                FROM [CONTA].[Poliza] p
                WHERE p.[PKIdPoliza] = @FKIdPoliza_CONTA
                  AND p.[Activo] = 1;

                IF @PolizaAnio IS NULL
                    THROW 51031, 'La poliza seleccionada no existe o esta inactiva.', 1;

                IF @PolizaAnio <> @FKIdAnio_SIS OR @PolizaMes <> @FKIdMes_SIS
                    THROW 51032, 'La poliza debe corresponder al mismo anio y mes del ingreso.', 1;

                IF ISNULL(@PolizaAutorizada, 0) = 1 OR ISNULL(@PolizaPermitirModificar, 1) = 0
                    THROW 51033, 'La poliza seleccionada ya no permite modificaciones.', 1;
            END

            INSERT INTO [PRES].[IngresoAutorizado]
            (
                [FKIdPrograma_PRES], [FKIdOrigen_PRES], [Descripcion], [Fecha], [FKIdPoliza_CONTA],
                [Enero], [Febrero], [Marzo], [Abril], [Mayo], [Junio],
                [Julio], [Agosto], [Septiembre], [Octubre], [Noviembre], [Diciembre],
                [FKIdFuenteFinanciamiento_PRES], [FKIdTipoGasto_PRES],
                [FKIdDigitoIdentificador_PRES], [FKIdDestinoGasto_PRES],
                [Activo], [FechaCreacion], [UsuarioCreacion]
            )
            VALUES
            (
                @FKIdPrograma_PRES, @FKIdOrigen_PRES, @Descripcion, @Fecha, @FKIdPoliza_CONTA,
                @Enero, @Febrero, @Marzo, @Abril, @Mayo, @Junio,
                @Julio, @Agosto, @Septiembre, @Octubre, @Noviembre, @Diciembre,
                @FKIdFuenteFinanciamiento_PRES, @FKIdTipoGasto_PRES,
                @FKIdDigitoIdentificador_PRES, @FKIdDestinoGasto_PRES,
                1, @Now, @IdUser
            );

            SET @Id = CONVERT(int, SCOPE_IDENTITY());

            SET @Error = NULL;
            EXEC @ReturnCode = [CONTA].[SP_CREATE_DetallePolizaWOM]
                @FKIdCuentaContable_CONTA = @FKIdCuentaAutorizado_CONTA,
                @FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                @Descripcion = @NombrePoliza,
                @ImporteDebe = @Total,
                @ImporteHaber = 0,
                @FKIdReferencia = @Id,
                @FKIdTipoDetallePoliza_SIS = 1,
                @IdUser = @IdUser,
                @Error = @Error OUTPUT;

            IF @ReturnCode <> 0 OR NULLIF(@Error, N'') IS NOT NULL
            BEGIN
                SET @Error = COALESCE(NULLIF(@Error, N''), N'No fue posible crear el movimiento Debe.');
                THROW 51034, @Error, 1;
            END

            SET @Error = NULL;
            EXEC @ReturnCode = [CONTA].[SP_CREATE_DetallePolizaWOM]
                @FKIdCuentaContable_CONTA = @FKIdCuentaPorEjercer_CONTA,
                @FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                @Descripcion = @NombrePoliza,
                @ImporteDebe = 0,
                @ImporteHaber = @Total,
                @FKIdReferencia = @Id,
                @FKIdTipoDetallePoliza_SIS = 2,
                @IdUser = @IdUser,
                @Error = @Error OUTPUT;

            IF @ReturnCode <> 0 OR NULLIF(@Error, N'') IS NOT NULL
            BEGIN
                SET @Error = COALESCE(NULLIF(@Error, N''), N'No fue posible crear el movimiento Haber.');
                THROW 51035, @Error, 1;
            END

            SET @Message = CONCAT(N'Ingreso autorizado creado. Poliza ', @ClavePoliza, N'.');
        END
        ELSE IF @Action = 2
        BEGIN
            SELECT
                @PolizaActual = ia.[FKIdPoliza_CONTA],
                @IngresoAutorizado = CASE WHEN ia.[FechaAutorizacion] IS NULL THEN 0 ELSE 1 END
            FROM [PRES].[IngresoAutorizado] ia WITH (UPDLOCK, HOLDLOCK)
            WHERE ia.[PKIdIngresoAutorizado] = @PKIdIngresoAutorizado
              AND ia.[Activo] = 1;

            IF @PolizaActual IS NULL
                THROW 51036, 'El ingreso autorizado no existe o esta inactivo.', 1;

            IF @IngresoAutorizado = 1
                THROW 51037, 'El ingreso ya fue autorizado y no puede modificarse.', 1;

            SELECT
                @PolizaAnio = p.[FKIdAnio_SIS],
                @PolizaMes = p.[FKIdMes_SIS],
                @PolizaAutorizada = p.[Autorizado],
                @PolizaPermitirModificar = p.[PermitirModificar]
            FROM [CONTA].[Poliza] p
            WHERE p.[PKIdPoliza] = @PolizaActual
              AND p.[Activo] = 1;

            IF @PolizaAnio <> @FKIdAnio_SIS OR @PolizaMes <> @FKIdMes_SIS
                THROW 51038, 'La fecha no puede cambiar de periodo despues de generar la poliza.', 1;

            IF ISNULL(@PolizaAutorizada, 0) = 1 OR ISNULL(@PolizaPermitirModificar, 1) = 0
                THROW 51039, 'La poliza ya no permite modificaciones.', 1;

            UPDATE [PRES].[IngresoAutorizado]
            SET
                [FKIdPrograma_PRES] = @FKIdPrograma_PRES,
                [FKIdOrigen_PRES] = @FKIdOrigen_PRES,
                [Descripcion] = @Descripcion,
                [Fecha] = @Fecha,
                [Enero] = @Enero,
                [Febrero] = @Febrero,
                [Marzo] = @Marzo,
                [Abril] = @Abril,
                [Mayo] = @Mayo,
                [Junio] = @Junio,
                [Julio] = @Julio,
                [Agosto] = @Agosto,
                [Septiembre] = @Septiembre,
                [Octubre] = @Octubre,
                [Noviembre] = @Noviembre,
                [Diciembre] = @Diciembre,
                [FKIdFuenteFinanciamiento_PRES] = @FKIdFuenteFinanciamiento_PRES,
                [FKIdTipoGasto_PRES] = @FKIdTipoGasto_PRES,
                [FKIdDigitoIdentificador_PRES] = @FKIdDigitoIdentificador_PRES,
                [FKIdDestinoGasto_PRES] = @FKIdDestinoGasto_PRES,
                [FechaModificacion] = @Now,
                [UsuarioModificacion] = @IdUser
            WHERE [PKIdIngresoAutorizado] = @PKIdIngresoAutorizado;

            UPDATE [CONTA].[Poliza]
            SET
                [NombrePoliza] = @NombrePoliza,
                [FechaPoliza] = @Fecha,
                [FechaModificacion] = @Now,
                [UsuarioModificacion] = @IdUser
            WHERE [PKIdPoliza] = @PolizaActual;

            SELECT @DetalleDebeId = MIN(pd.[PKIdPolizaDetalle])
            FROM [CONTA].[PolizaDetalle] pd
            WHERE pd.[FKIdPoliza_CONTA] = @PolizaActual
              AND pd.[FKIdReferencia] = @PKIdIngresoAutorizado
              AND pd.[FKIdTipoDetallePoliza_SIS] = 1
              AND pd.[Activo] = 1;

            SELECT @DetalleHaberId = MIN(pd.[PKIdPolizaDetalle])
            FROM [CONTA].[PolizaDetalle] pd
            WHERE pd.[FKIdPoliza_CONTA] = @PolizaActual
              AND pd.[FKIdReferencia] = @PKIdIngresoAutorizado
              AND pd.[FKIdTipoDetallePoliza_SIS] = 2
              AND pd.[Activo] = 1;

            UPDATE [CONTA].[PolizaDetalle]
            SET [Activo] = 0, [FechaModificacion] = @Now, [UsuarioModificacion] = @IdUser
            WHERE [FKIdPoliza_CONTA] = @PolizaActual
              AND [FKIdReferencia] = @PKIdIngresoAutorizado
              AND [Activo] = 1
              AND [PKIdPolizaDetalle] NOT IN (ISNULL(@DetalleDebeId, -1), ISNULL(@DetalleHaberId, -1));

            IF @DetalleDebeId IS NULL
            BEGIN
                SET @Error = NULL;
                EXEC @ReturnCode = [CONTA].[SP_CREATE_DetallePolizaWOM]
                    @FKIdCuentaContable_CONTA = @FKIdCuentaAutorizado_CONTA,
                    @FKIdPoliza_CONTA = @PolizaActual,
                    @Descripcion = @NombrePoliza,
                    @ImporteDebe = @Total,
                    @ImporteHaber = 0,
                    @FKIdReferencia = @PKIdIngresoAutorizado,
                    @FKIdTipoDetallePoliza_SIS = 1,
                    @IdUser = @IdUser,
                    @Error = @Error OUTPUT;
                IF @ReturnCode <> 0 OR NULLIF(@Error, N'') IS NOT NULL
                BEGIN
                    SET @Error = COALESCE(NULLIF(@Error, N''), N'No fue posible crear el movimiento Debe.');
                    THROW 51040, @Error, 1;
                END
            END
            ELSE
            BEGIN
                UPDATE [CONTA].[PolizaDetalle]
                SET
                    [FKIdCuentaContable_CONTA] = @FKIdCuentaAutorizado_CONTA,
                    [Descripcion] = @NombrePoliza,
                    [ImporteDebe] = @Total,
                    [ImporteHaber] = 0,
                    [FechaModificacion] = @Now,
                    [UsuarioModificacion] = @IdUser
                WHERE [PKIdPolizaDetalle] = @DetalleDebeId;
            END

            IF @DetalleHaberId IS NULL
            BEGIN
                SET @Error = NULL;
                EXEC @ReturnCode = [CONTA].[SP_CREATE_DetallePolizaWOM]
                    @FKIdCuentaContable_CONTA = @FKIdCuentaPorEjercer_CONTA,
                    @FKIdPoliza_CONTA = @PolizaActual,
                    @Descripcion = @NombrePoliza,
                    @ImporteDebe = 0,
                    @ImporteHaber = @Total,
                    @FKIdReferencia = @PKIdIngresoAutorizado,
                    @FKIdTipoDetallePoliza_SIS = 2,
                    @IdUser = @IdUser,
                    @Error = @Error OUTPUT;
                IF @ReturnCode <> 0 OR NULLIF(@Error, N'') IS NOT NULL
                BEGIN
                    SET @Error = COALESCE(NULLIF(@Error, N''), N'No fue posible crear el movimiento Haber.');
                    THROW 51041, @Error, 1;
                END
            END
            ELSE
            BEGIN
                UPDATE [CONTA].[PolizaDetalle]
                SET
                    [FKIdCuentaContable_CONTA] = @FKIdCuentaPorEjercer_CONTA,
                    [Descripcion] = @NombrePoliza,
                    [ImporteDebe] = 0,
                    [ImporteHaber] = @Total,
                    [FechaModificacion] = @Now,
                    [UsuarioModificacion] = @IdUser
                WHERE [PKIdPolizaDetalle] = @DetalleHaberId;
            END

            SET @FKIdPoliza_CONTA = @PolizaActual;
            SET @Id = @PKIdIngresoAutorizado;
            SET @Message = N'Ingreso autorizado actualizado y poliza recalculada.';
        END
        ELSE IF @Action = 3
        BEGIN
            SELECT
                @PolizaActual = ia.[FKIdPoliza_CONTA],
                @IngresoAutorizado = CASE WHEN ia.[FechaAutorizacion] IS NULL THEN 0 ELSE 1 END
            FROM [PRES].[IngresoAutorizado] ia WITH (UPDLOCK, HOLDLOCK)
            WHERE ia.[PKIdIngresoAutorizado] = @PKIdIngresoAutorizado
              AND ia.[Activo] = 1;

            IF @PolizaActual IS NULL
                THROW 51042, 'El ingreso autorizado no existe o esta inactivo.', 1;

            IF @IngresoAutorizado = 1
                THROW 51043, 'El ingreso ya fue autorizado y no puede eliminarse.', 1;

            UPDATE [PRES].[IngresoAutorizado]
            SET [Activo] = 0, [FechaModificacion] = @Now, [UsuarioModificacion] = @IdUser
            WHERE [PKIdIngresoAutorizado] = @PKIdIngresoAutorizado;

            UPDATE [CONTA].[PolizaDetalle]
            SET [Activo] = 0, [FechaModificacion] = @Now, [UsuarioModificacion] = @IdUser
            WHERE [FKIdPoliza_CONTA] = @PolizaActual
              AND [FKIdReferencia] = @PKIdIngresoAutorizado
              AND [Activo] = 1;

            SET @FKIdPoliza_CONTA = @PolizaActual;
            SET @Id = @PKIdIngresoAutorizado;
            SET @Message = N'Ingreso autorizado eliminado; la poliza se conserva para auditoria.';
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT
                @PolizaActual = ia.[FKIdPoliza_CONTA],
                @Total = ia.[Total],
                @IngresoAutorizado = CASE WHEN ia.[FechaAutorizacion] IS NULL THEN 0 ELSE 1 END
            FROM [PRES].[IngresoAutorizado] ia WITH (UPDLOCK, HOLDLOCK)
            WHERE ia.[PKIdIngresoAutorizado] = @PKIdIngresoAutorizado
              AND ia.[Activo] = 1;

            IF @PolizaActual IS NULL
                THROW 51044, 'El ingreso autorizado no existe o no tiene poliza.', 1;

            IF @IngresoAutorizado = 1
                THROW 51045, 'El ingreso ya se encuentra autorizado.', 1;

            IF ISNULL(@Total, 0) <= 0
                THROW 51046, 'No se puede autorizar un ingreso con total cero.', 1;

            SET @FKIdPoliza_CONTA = @PolizaActual;
            SET @Id = @PKIdIngresoAutorizado;
            SET @Message = N'Ingreso y poliza autorizados correctamente.';
        END

        SET @Error = NULL;
        EXEC @ReturnCode = [CONTA].[SP_UPDATE_PolizaBalanceada]
            @PKIdPoliza = @FKIdPoliza_CONTA,
            @IdUser = @IdUser,
            @Error = @Error OUTPUT;

        IF @ReturnCode <> 0 OR NULLIF(@Error, N'') IS NOT NULL
        BEGIN
            SET @Error = COALESCE(NULLIF(@Error, N''), N'No fue posible recalcular la poliza.');
            THROW 51047, @Error, 1;
        END

        IF @Action = 4
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM [CONTA].[Poliza] p
                WHERE p.[PKIdPoliza] = @FKIdPoliza_CONTA
                  AND p.[Activo] = 1
                  AND p.[EstaBalanceado] = 1
            )
                THROW 51048, 'La poliza no esta balanceada y no puede autorizarse.', 1;

            UPDATE [PRES].[IngresoAutorizado]
            SET
                [FechaAutorizacion] = @Now,
                [UsuarioAutorizacion] = @IdUser,
                [FechaModificacion] = @Now,
                [UsuarioModificacion] = @IdUser
            WHERE [PKIdIngresoAutorizado] = @PKIdIngresoAutorizado;

            UPDATE [CONTA].[Poliza]
            SET
                [Autorizado] = 1,
                [PermitirModificar] = 0,
                [FechaAutorizacion] = @Now,
                [FechaModificacion] = @Now,
                [UsuarioModificacion] = @IdUser
            WHERE [PKIdPoliza] = @FKIdPoliza_CONTA;
        END

        COMMIT TRANSACTION;

        SELECT JSON_QUERY((
            SELECT
                @Tipo AS [tipo],
                @Message AS [mensaje],
                CONCAT(N'idIngresoAutorizado:', @Id) AS [liga]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS [ResultJson];
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @Tipo = N'ERROR';
        SET @Message = CONCAT(ERROR_MESSAGE(), N' Linea: ', ERROR_LINE());

        SELECT JSON_QUERY((
            SELECT @Tipo AS [tipo], @Message AS [mensaje], N'' AS [liga]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS [ResultJson];
    END CATCH
END
GO

EXEC [dbo].[spConfiguracionDeRolYClaims]
    'CuentasXCobrar',
    'Ley_Ingresos_Estimados',
    '10000',
    'view,view-menu,delete,new,update,CanExportToExcel,authorize';
GO

DECLARE @MenuPadreId int = (
    SELECT TOP (1) m.[PKIdMenu]
    FROM [SIS].[Menu] m
    WHERE m.[Activo] = 1
      AND m.[Nombre] IN (N'Cuentas por Cobrar', N'CuentasXCobrar')
    ORDER BY CASE WHEN m.[PKIdMenu] = 121 THEN 0 ELSE 1 END, m.[PKIdMenu]
);

IF @MenuPadreId IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
       FROM [SIS].[Menu]
       WHERE [Ruta] = N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Ingresos_Estimados'
   )
BEGIN
    DECLARE @MenuId int = CASE
        WHEN NOT EXISTS (SELECT 1 FROM [SIS].[Menu] WHERE [PKIdMenu] = 126) THEN 126
        ELSE ISNULL((SELECT MAX([PKIdMenu]) + 1 FROM [SIS].[Menu]), 126)
    END;

    INSERT INTO [SIS].[Menu]
    (
        [PKIdMenu], [Nombre], [Tipo], [FKIdMenu_SIS], [LegacyName], [Ruta],
        [ImageUrl], [Lenguaje], [Orden], [Activo], [CreatedByOperatorId], [CreatedDateTime]
    )
    VALUES
    (
        @MenuId, N'Ley de Ingresos Estimados', 2, @MenuPadreId,
        N'Ley de Ingresos Estimados',
        N'/Presupuesto/Tesoreria/Cuentas_Cobrar/Ingresos_Estimados',
        N'FaHome', N'ESP', 1, 1, 1, GETDATE()
    );
END
GO
