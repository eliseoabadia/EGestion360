SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;

BEGIN TRAN;
BEGIN TRY
    DECLARE @BienId int, @EmpresaId int, @AreaId int, @TipoBajaId int,
            @EstadoDestinoId int, @EstatusInicialId int, @EstatusAplicadaId int,
            @AnioId int, @BajaId int, @PolizaId int, @UsuarioId int = 1,
            @FechaActual date = CONVERT(date, GETDATE());

    SELECT TOP (1)
        @BienId = B.PKIdBien,
        @EmpresaId = B.FKIdEmpresa_SIS,
        @AreaId = B.FKIdArea_SIS
    FROM ALMA.Bien B
    WHERE B.Activo = 1
      AND B.EsContabilizado = 1
      AND NOT EXISTS (SELECT 1 FROM ALMA.Bajas X WHERE X.FKIdBien_ALMA = B.PKIdBien AND X.Activo = 1)
    ORDER BY B.PKIdBien;

    SELECT TOP (1) @TipoBajaId = PKIdTipoBaja, @EstadoDestinoId = FKIdEstadoBienDestino_ALMA
    FROM ALMA.TipoBaja
    WHERE Activo = 1 AND FKIdEstadoBienDestino_ALMA IS NOT NULL
    ORDER BY PKIdTipoBaja;

    SELECT @EstatusInicialId = PKIdEstatusBaja FROM ALMA.EstatusBaja WHERE Activo = 1 AND Descripcion = N'INICIAL';
    SELECT @EstatusAplicadaId = PKIdEstatusBaja FROM ALMA.EstatusBaja WHERE Activo = 1 AND Descripcion = N'APLICADA';
    SELECT @AnioId = PKIdAnio FROM SIS.Anio WHERE Activo = 1 AND Clave = YEAR(GETDATE());

    IF @BienId IS NULL OR @TipoBajaId IS NULL OR @EstatusInicialId IS NULL OR @EstatusAplicadaId IS NULL OR @AnioId IS NULL
        THROW 54900, N'No existen datos base para probar la baja patrimonial.', 1;

    EXEC ALMA.SP_MantenimientoBajas
        @Action = 1,
        @FKIdEmpresa_SIS = @EmpresaId,
        @FKIdArea_SIS = @AreaId,
        @FKIdBien_ALMA = @BienId,
        @FKIdTipoBaja_ALMA = @TipoBajaId,
        @FKIdEstatusBaja_ALMA = @EstatusInicialId,
        @FKIdEstadoBienDestino_ALMA = @EstadoDestinoId,
        @FechaSolicitud = @FechaActual,
        @Cantidad = 1,
        @Motivo = N'PRUEBA AUTOMATIZADA CON ROLLBACK',
        @IdUser = @UsuarioId,
        @Id = @BajaId OUTPUT;

    UPDATE ALMA.Bajas SET FKIdAnio_SIS = @AnioId WHERE PKIdBaja = @BajaId;

    EXEC ALMA.SP_MantenimientoBajas
        @Action = 4,
        @PKIdBaja = @BajaId,
        @FKIdEmpresa_SIS = @EmpresaId,
        @FKIdArea_SIS = @AreaId,
        @FKIdBien_ALMA = @BienId,
        @FKIdTipoBaja_ALMA = @TipoBajaId,
        @FKIdEstatusBaja_ALMA = @EstatusAplicadaId,
        @FKIdEstadoBienDestino_ALMA = @EstadoDestinoId,
        @FechaSolicitud = @FechaActual,
        @FechaBaja = @FechaActual,
        @Cantidad = 1,
        @Motivo = N'PRUEBA AUTOMATIZADA CON ROLLBACK',
        @IdUser = @UsuarioId,
        @Id = @BajaId OUTPUT;

    SELECT @PolizaId = FKIdPoliza_CONTA FROM ALMA.Bajas WHERE PKIdBaja = @BajaId;

    IF @PolizaId IS NULL
        THROW 54901, N'La baja aplicada no genero poliza.', 1;
    IF NOT EXISTS
    (
        SELECT 1 FROM CONTA.Poliza P
        WHERE P.PKIdPoliza = @PolizaId AND P.Activo = 1 AND P.EstaBalanceado = 1
    )
        THROW 54902, N'La poliza de baja no quedo activa y balanceada.', 1;
    IF EXISTS
    (
        SELECT 1 FROM CONTA.PolizaDetalle D
        WHERE D.FKIdPoliza_CONTA = @PolizaId AND D.Activo = 1
        GROUP BY D.FKIdPoliza_CONTA
        HAVING SUM(D.ImporteDebe) <> SUM(D.ImporteHaber)
    )
        THROW 54903, N'Los detalles de la poliza de baja no cuadran.', 1;
    IF EXISTS (SELECT 1 FROM ALMA.Bien WHERE PKIdBien = @BienId AND Activo = 1)
        THROW 54904, N'El bien continuo activo despues de aplicar la baja.', 1;

    SELECT @BienId AS BienProbado, @BajaId AS BajaGenerada, @PolizaId AS PolizaGenerada,
           N'OK - solicitud, aplicacion y poliza validadas; se ejecutara rollback' AS Resultado;

    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
END CATCH;
