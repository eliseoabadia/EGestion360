/*
    Repara la autorización presupuestal creada sin póliza por la ruta que
    omitía PRES.SP_MantenimientoEgresoAutorizado.

    Caso confirmado:
      PRES.EgresoAutorizado.PKIdEgresoAutorizado = 1

    El script es transaccional e idempotente. Antes de crear la matriz exige
    que todas las matrices activas de la misma anualidad y partida compartan
    exactamente las mismas cuentas contables.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

DECLARE
    @EgresoAutorizadoId INT = 1,
    @ProgramaId INT,
    @PartidaId INT,
    @TipoGastoId INT,
    @AnioId INT,
    @MesId INT,
    @UsuarioId INT,
    @Fecha DATE,
    @Descripcion NVARCHAR(1000),
    @Importe DECIMAL(18, 2),
    @PolizaId INT,
    @MatrizId INT,
    @CuentaAprobado INT,
    @CuentaPorEjercer INT,
    @CuentaModificado INT,
    @CuentaComprometido INT,
    @CuentaDevengado INT,
    @CuentaEjercido INT,
    @CuentaPagado INT,
    @CuentaGasto INT,
    @CantidadConfiguraciones INT,
    @ClavePoliza NVARCHAR(20),
    @ErrorPoliza NVARCHAR(MAX),
    @NombrePoliza NVARCHAR(1000),
    @Ahora DATETIME2(7) = SYSDATETIME();

DECLARE @Configuraciones TABLE
(
    CuentaAprobado INT NOT NULL,
    CuentaPorEjercer INT NOT NULL,
    CuentaModificado INT NOT NULL,
    CuentaComprometido INT NOT NULL,
    CuentaDevengado INT NOT NULL,
    CuentaEjercido INT NOT NULL,
    CuentaPagado INT NOT NULL,
    CuentaGasto INT NOT NULL,
    TipoGastoId INT NOT NULL
);

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT
        @ProgramaId = ea.FKIdPrograma_PRES,
        @PartidaId = ea.FKIdPartida_CONTA,
        @TipoGastoId = ea.FKIdTipoGasto_PRES,
        @Fecha = ea.Fecha,
        @UsuarioId = COALESCE(ea.UsuarioAutorizacion, ea.UsuarioCreacion),
        @Descripcion = ea.Descripcion,
        @Importe =
              ISNULL(ea.Enero, 0)
            + ISNULL(ea.Febrero, 0)
            + ISNULL(ea.Marzo, 0)
            + ISNULL(ea.Abril, 0)
            + ISNULL(ea.Mayo, 0)
            + ISNULL(ea.Junio, 0)
            + ISNULL(ea.Julio, 0)
            + ISNULL(ea.Agosto, 0)
            + ISNULL(ea.Septiembre, 0)
            + ISNULL(ea.Octubre, 0)
            + ISNULL(ea.Noviembre, 0)
            + ISNULL(ea.Diciembre, 0),
        @PolizaId = ea.FKIdPoliza_CONTA
    FROM PRES.EgresoAutorizado AS ea WITH (UPDLOCK, HOLDLOCK)
    WHERE ea.PKIdEgresoAutorizado = @EgresoAutorizadoId
      AND ea.Activo = 1;

    IF @ProgramaId IS NULL
        THROW 51000, 'No existe la autorización presupuestal activa que se desea reparar.', 1;

    IF @UsuarioId IS NULL OR @UsuarioId <= 0
        THROW 51001, 'La autorización no tiene un usuario válido para auditar la reparación.', 1;

    SELECT @AnioId = a.PKIdAnio
    FROM SIS.Anio AS a
    WHERE a.Clave = YEAR(@Fecha)
      AND a.Activo = 1;

    IF @AnioId IS NULL
        THROW 51002, 'No existe una anualidad activa para la fecha de la autorización.', 1;

    SET @MesId = MONTH(@Fecha);

    SELECT @MatrizId = mc.PKIdMatrizConversion
    FROM CONTA.MatrizConversion AS mc WITH (UPDLOCK, HOLDLOCK)
    WHERE mc.FKIdAnio_SIS = @AnioId
      AND mc.FKIdPrograma_PRES = @ProgramaId
      AND mc.FKIdPartida_SIS = @PartidaId
      AND mc.FKIdTipoGasto_PRES = @TipoGastoId
      AND mc.Activo = 1;

    IF @MatrizId IS NULL
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM CONTA.MatrizConversion AS mc WITH (UPDLOCK, HOLDLOCK)
            WHERE mc.FKIdAnio_SIS = @AnioId
              AND mc.FKIdPrograma_PRES = @ProgramaId
              AND mc.FKIdPartida_SIS = @PartidaId
              AND mc.FKIdTipoGasto_PRES = @TipoGastoId
        )
            THROW 51003, 'Existe una matriz inactiva para la combinación; requiere revisión manual.', 1;

        INSERT INTO @Configuraciones
        (
            CuentaAprobado,
            CuentaPorEjercer,
            CuentaModificado,
            CuentaComprometido,
            CuentaDevengado,
            CuentaEjercido,
            CuentaPagado,
            CuentaGasto,
            TipoGastoId
        )
        SELECT DISTINCT
            mc.FKIdCuentaContableAprobado,
            mc.FKIdCuentaContablePorEjercer,
            mc.FKIdCuentaContableModificado,
            mc.FKIdCuentaContableComprometido,
            mc.FKIdCuentaContableDevengado,
            mc.FKIdCuentaContableEjercido,
            mc.FKIdCuentaContablePagado,
            mc.FKIdCuentaContableGasto,
            mc.FKIdTipoGasto_PRES
        FROM CONTA.MatrizConversion AS mc WITH (HOLDLOCK)
        WHERE mc.FKIdAnio_SIS = @AnioId
          AND mc.FKIdPartida_SIS = @PartidaId
          AND mc.FKIdTipoGasto_PRES = @TipoGastoId
          AND mc.Activo = 1;

        SELECT @CantidadConfiguraciones = COUNT(*) FROM @Configuraciones;

        IF @CantidadConfiguraciones <> 1
            THROW 51004, 'No hay una configuración contable única para completar la matriz faltante.', 1;

        SELECT
            @CuentaAprobado = CuentaAprobado,
            @CuentaPorEjercer = CuentaPorEjercer,
            @CuentaModificado = CuentaModificado,
            @CuentaComprometido = CuentaComprometido,
            @CuentaDevengado = CuentaDevengado,
            @CuentaEjercido = CuentaEjercido,
            @CuentaPagado = CuentaPagado,
            @CuentaGasto = CuentaGasto
        FROM @Configuraciones;

        INSERT INTO CONTA.MatrizConversion
        (
            FKIdAnio_SIS,
            FKIdPrograma_PRES,
            FKIdPartida_SIS,
            FKIdCuentaContableAprobado,
            FKIdCuentaContablePorEjercer,
            FKIdCuentaContableModificado,
            FKIdCuentaContableComprometido,
            FKIdCuentaContableDevengado,
            FKIdCuentaContableEjercido,
            FKIdCuentaContablePagado,
            FKIdCuentaContableGasto,
            FKIdTipoGasto_PRES,
            Activo,
            FechaCreacion,
            UsuarioCreacion
        )
        VALUES
        (
            @AnioId,
            @ProgramaId,
            @PartidaId,
            @CuentaAprobado,
            @CuentaPorEjercer,
            @CuentaModificado,
            @CuentaComprometido,
            @CuentaDevengado,
            @CuentaEjercido,
            @CuentaPagado,
            @CuentaGasto,
            @TipoGastoId,
            1,
            @Ahora,
            @UsuarioId
        );

        SET @MatrizId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SELECT
            @CuentaAprobado = mc.FKIdCuentaContableAprobado,
            @CuentaPorEjercer = mc.FKIdCuentaContablePorEjercer
        FROM CONTA.MatrizConversion AS mc
        WHERE mc.PKIdMatrizConversion = @MatrizId;
    END;

    IF @PolizaId IS NULL
    BEGIN
        SET @NombrePoliza = CONCAT(
            N'Presupuesto de Egresos Autorizado: ',
            YEAR(@Fecha),
            N' ',
            ISNULL(@Descripcion, N''));

        EXEC CONTA.SP_CREATE_ClavePoliza
            @FK_IdAnio__SIS = @AnioId,
            @FK_IdMesConta__SIS = @MesId,
            @FK_IdTipoPolizaConta__SIS = 1,
            @CT_ModifiedBy = @UsuarioId,
            @ClavePoliza = @ClavePoliza OUTPUT,
            @Error = @ErrorPoliza OUTPUT;

        IF ISNULL(@ClavePoliza, N'') = N''
            THROW 51005, 'No se pudo generar la clave de la póliza.', 1;

        INSERT INTO CONTA.Poliza
        (
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
        VALUES
        (
            @AnioId,
            @MesId,
            1,
            @ClavePoliza,
            @NombrePoliza,
            @Fecha,
            0,
            1,
            @Ahora,
            @UsuarioId,
            1,
            0
        );

        SET @PolizaId = SCOPE_IDENTITY();

        UPDATE PRES.EgresoAutorizado
        SET FKIdPoliza_CONTA = @PolizaId,
            FechaModificacion = @Ahora,
            UsuarioModificacion = @UsuarioId
        WHERE PKIdEgresoAutorizado = @EgresoAutorizadoId
          AND Activo = 1
          AND FKIdPoliza_CONTA IS NULL;

        IF @@ROWCOUNT <> 1
            THROW 51006, 'La autorización cambió durante la reparación.', 1;

        INSERT INTO CONTA.PolizaDetalle
        (
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
            @PolizaId,
            @NombrePoliza,
            @Importe,
            0,
            @EgresoAutorizadoId,
            1,
            1,
            @Ahora,
            @UsuarioId
        ),
        (
            @CuentaPorEjercer,
            @PolizaId,
            @NombrePoliza,
            0,
            @Importe,
            @EgresoAutorizadoId,
            2,
            1,
            @Ahora,
            @UsuarioId
        );

        UPDATE CONTA.Poliza
        SET EstaBalanceado = 1,
            FechaModificacion = @Ahora,
            UsuarioModificacion = @UsuarioId
        WHERE PKIdPoliza = @PolizaId
          AND Activo = 1;
    END
    ELSE
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM CONTA.Poliza AS p
            WHERE p.PKIdPoliza = @PolizaId
              AND p.Activo = 1
        )
            THROW 51007, 'La autorización apunta a una póliza inexistente o inactiva.', 1;

        IF
        (
            SELECT COUNT(*)
            FROM CONTA.PolizaDetalle AS pd
            WHERE pd.FKIdPoliza_CONTA = @PolizaId
              AND pd.FKIdReferencia = @EgresoAutorizadoId
              AND pd.Activo = 1
        ) <> 2
            THROW 51008, 'La póliza existente no tiene los dos movimientos esperados.', 1;
    END;

    COMMIT TRANSACTION;

    SELECT
        ea.PKIdEgresoAutorizado,
        ea.FKIdPoliza_CONTA AS PKIdPoliza,
        p.ClavePoliza,
        p.EstaBalanceado,
        mc.PKIdMatrizConversion,
        COUNT(pd.PKIdPolizaDetalle) AS Movimientos,
        SUM(pd.ImporteDebe) AS Debe,
        SUM(pd.ImporteHaber) AS Haber
    FROM PRES.EgresoAutorizado AS ea
    INNER JOIN CONTA.Poliza AS p
        ON p.PKIdPoliza = ea.FKIdPoliza_CONTA
       AND p.Activo = 1
    INNER JOIN CONTA.MatrizConversion AS mc
       ON mc.FKIdAnio_SIS = @AnioId
       AND mc.FKIdPrograma_PRES = ea.FKIdPrograma_PRES
       AND mc.FKIdPartida_SIS = ea.FKIdPartida_CONTA
       AND mc.FKIdTipoGasto_PRES = ea.FKIdTipoGasto_PRES
       AND mc.Activo = 1
    INNER JOIN CONTA.PolizaDetalle AS pd
        ON pd.FKIdPoliza_CONTA = p.PKIdPoliza
       AND pd.FKIdReferencia = ea.PKIdEgresoAutorizado
       AND pd.Activo = 1
    WHERE ea.PKIdEgresoAutorizado = @EgresoAutorizadoId
    GROUP BY
        ea.PKIdEgresoAutorizado,
        ea.FKIdPoliza_CONTA,
        p.ClavePoliza,
        p.EstaBalanceado,
        mc.PKIdMatrizConversion;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
