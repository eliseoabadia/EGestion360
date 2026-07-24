SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;

DECLARE
    @Empresa INT = 1,
    @Usuario INT = 1,
    @Requisicion INT,
    @RequisicionDetalle INT,
    @Persona INT,
    @Proveedor INT,
    @CuentaBancaria INT,
    @Partida INT,
    @CuentaContable INT,
    @Anio INT,
    @Mes INT,
    @TipoPoliza INT,
    @Solicitud INT,
    @SolicitudDetalle INT,
    @Autorizacion INT,
    @AutorizacionDetalle INT,
    @Contrato INT,
    @ContratoDetalle INT,
    @Factura INT,
    @FacturaDetalle INT,
    @CLC INT,
    @CLCDetalle INT,
    @Cheque INT,
    @I INT = 1,
    @Poliza INT;

SELECT TOP (1) @Requisicion = R.PKIdRequisicion
FROM ORCO.Requisicion R
WHERE R.FKIdEmpresa_SIS = @Empresa AND R.Activo = 1;

SELECT TOP (1) @RequisicionDetalle = D.PKIdRequisicionDetalle
FROM ORCO.RequisicionDetalle D
WHERE D.FKIdRequisicion_ORCO = @Requisicion AND D.Activo = 1;

SELECT TOP (1) @Persona = P.PKIdPersona FROM NOM.Persona P WHERE P.Activo = 1;
SELECT TOP (1) @Proveedor = P.PKIdProveedor FROM SIS.Proveedor P WHERE P.Activo = 1;
SELECT TOP (1) @CuentaBancaria = C.PKIdCuentaBancaria
FROM TES.CuentaBancaria C WHERE C.FKIdEmpresa_SIS = @Empresa AND C.Activo = 1;
SELECT TOP (1) @Partida = P.PKIdPartida FROM CONTA.Partida P WHERE P.Activo = 1;
SELECT TOP (1) @CuentaContable = C.PKIdCuentaContable FROM CONTA.CuentaContable C WHERE C.Activo = 1;
SELECT TOP (1) @Anio = P.FKIdAnio_SIS, @Mes = P.FKIdMes_SIS, @TipoPoliza = P.FKIdTipoPoliza_SIS
FROM CONTA.Poliza P;

IF @Requisicion IS NULL OR @RequisicionDetalle IS NULL OR @Persona IS NULL
   OR @Proveedor IS NULL OR @CuentaBancaria IS NULL OR @Partida IS NULL
   OR @CuentaContable IS NULL OR @Anio IS NULL
    THROW 52000, N'No hay catálogos mínimos para ejecutar la prueba de integración.', 1;

BEGIN TRANSACTION;

DECLARE @Polizas TABLE (Etapa INT PRIMARY KEY, PKIdPoliza INT NOT NULL);

WHILE @I <= 4
BEGIN
    INSERT INTO CONTA.Poliza
    (
        FKIdAnio_SIS, FKIdMes_SIS, FKIdTipoPoliza_SIS, ClavePoliza, NombrePoliza,
        FechaPoliza, EstaBalanceado, Activo, FechaCreacion, UsuarioCreacion,
        PermitirModificar, Autorizado
    )
    VALUES
    (
        @Anio, @Mes, @TipoPoliza,
        LEFT(CONCAT(N'ITR-', @@SPID, N'-', @I), 20),
        CONCAT(N'Póliza original prueba regreso etapa ', @I),
        CAST(SYSDATETIME() AS DATE), 1, 1, SYSDATETIME(), @Usuario, 0, 1
    );

    SET @Poliza = SCOPE_IDENTITY();
    INSERT INTO @Polizas VALUES (@I, @Poliza);

    INSERT INTO CONTA.PolizaDetalle
    (
        FKIdCuentaContable_CONTA, FKIdPoliza_CONTA, Descripcion,
        ImporteDebe, ImporteHaber, FKIdTipoDetallePoliza_SIS,
        Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (@CuentaContable, @Poliza, N'Cargo original', 125.00, 0.00, 3, 1, SYSDATETIME(), @Usuario),
        (@CuentaContable, @Poliza, N'Abono original', 0.00, 125.00, 4, 1, SYSDATETIME(), @Usuario);

    SET @I += 1;
END;

INSERT INTO PRES.SolicitudSuficiencia
(
    FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FechaSolicitud, Justificacion,
    Estatus, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @Requisicion, CAST(SYSDATETIME() AS DATE), N'Prueba de regreso', 3, 1, SYSDATETIME(), @Usuario);
SET @Solicitud = SCOPE_IDENTITY();

INSERT INTO PRES.SolicitudSuficienciaDetalle
(
    FKIdEmpresa_SIS, FKIdSolicitudSuficiencia_PRES, FKIdRequisicionDetalle_ORCO,
    FKIdPartida_CONTA, Enero, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @Solicitud, @RequisicionDetalle, @Partida, 125.00, 1, SYSDATETIME(), @Usuario);
SET @SolicitudDetalle = SCOPE_IDENTITY();

INSERT INTO PRES.AutorizacionSuficiencia
(
    FKIdEmpresa_SIS, FKIdSolicitudSuficiencia_PRES, FechaAutorizacion,
    Justificacion, AutorizadoPor_NOM, Estatus, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @Solicitud, CAST(SYSDATETIME() AS DATE), N'Autorización de prueba', @Persona, 3, 1, SYSDATETIME(), @Usuario);
SET @Autorizacion = SCOPE_IDENTITY();

INSERT INTO PRES.AutorizacionSuficienciaDetalle
(
    FKIdEmpresa_SIS, FKIdAutorizacionSuficiencia_PRES, FKIdSolicitudSuficienciaDetalle_PRES,
    FKIdPartida_CONTA, Enero, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @Autorizacion, @SolicitudDetalle, @Partida, 125.00, 1, SYSDATETIME(), @Usuario);
SET @AutorizacionDetalle = SCOPE_IDENTITY();

SELECT @Poliza = PKIdPoliza FROM @Polizas WHERE Etapa = 1;
INSERT INTO PRES.Contrato
(
    FKIdEmpresa_SIS, FKIdAutorizacionSuficiencia_PRES, FKIdProveedor_SIS,
    FKIdPoliza_CONTA, NumeroContrato, Descripcion, FechaContrato, MontoTotal,
    Estatus, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @Autorizacion, @Proveedor, @Poliza, CONCAT(N'IT-C-', @@SPID), N'Contrato prueba',
 CAST(SYSDATETIME() AS DATE), 125.00, 3, 1, SYSDATETIME(), @Usuario);
SET @Contrato = SCOPE_IDENTITY();

INSERT INTO PRES.ContratoDetalle
(
    FKIdEmpresa_SIS, FKIdContrato_PRES, FKIdAutorizacionSuficienciaDetalle_PRES,
    FKIdPartida_CONTA, Enero, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @Contrato, @AutorizacionDetalle, @Partida, 125.00, 1, SYSDATETIME(), @Usuario);
SET @ContratoDetalle = SCOPE_IDENTITY();

SELECT @Poliza = PKIdPoliza FROM @Polizas WHERE Etapa = 2;
INSERT INTO PRES.Factura
(
    FKIdEmpresa_SIS, FKIdContrato_PRES, FKIdPoliza_CONTA, NumFactura,
    FechaEmision, Total, Estatus, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @Contrato, @Poliza, CONCAT(N'IT-F-', @@SPID), CAST(SYSDATETIME() AS DATE),
 125.00, 3, 1, SYSDATETIME(), @Usuario);
SET @Factura = SCOPE_IDENTITY();

INSERT INTO PRES.FacturaDetalle
(
    FKIdEmpresa_SIS, FKIdFactura_PRES, FKIdContratoDetalle_PRES,
    FKIdPartida_CONTA, MontoAplicado, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @Factura, @ContratoDetalle, @Partida, 125.00, 1, SYSDATETIME(), @Usuario);
SET @FacturaDetalle = SCOPE_IDENTITY();

SELECT @Poliza = PKIdPoliza FROM @Polizas WHERE Etapa = 3;
INSERT INTO PRES.CLC
(
    FKIdEmpresa_SIS, FKIdContrato_PRES, FKIdPoliza_CONTA, NumCLC,
    FechaSolicitud, ImporteTotal, Estatus, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @Contrato, @Poliza, CONCAT(N'IT-CLC-', @@SPID), CAST(SYSDATETIME() AS DATE),
 125.00, 3, 1, SYSDATETIME(), @Usuario);
SET @CLC = SCOPE_IDENTITY();

INSERT INTO PRES.CLCDetalle
(
    FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdContratoDetalle_PRES,
    FKIdPartida_CONTA, Enero, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @CLC, @ContratoDetalle, @Partida, 125.00, 1, SYSDATETIME(), @Usuario);
SET @CLCDetalle = SCOPE_IDENTITY();

INSERT INTO PRES.CLCFactura
(
    FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdFactura_PRES, FKIdFacturaDetalle_PRES,
    MontoAplicado, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @CLC, @Factura, @FacturaDetalle, 125.00, 1, SYSDATETIME(), @Usuario);

SELECT @Poliza = PKIdPoliza FROM @Polizas WHERE Etapa = 4;
INSERT INTO PRES.Cheque
(
    FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdCuentaBancaria_TES, FKIdPoliza_CONTA,
    FechaEmision, NumeroCheque, Concepto, ImporteTotal, Estatus,
    Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @CLC, @CuentaBancaria, @Poliza, CAST(SYSDATETIME() AS DATE),
 CONCAT(N'IT-CH-', @@SPID), N'Cheque prueba regreso', 125.00, 3, 1, SYSDATETIME(), @Usuario);
SET @Cheque = SCOPE_IDENTITY();

INSERT INTO PRES.ChequePartidas
(
    FKIdEmpresa_SIS, FKIdCheque_PRES, FKIdCLCDetalle_PRES, FKIdPartida_CONTA,
    MontoPagado, Activo, FechaCreacion, UsuarioCreacion
)
VALUES
(@Empresa, @Cheque, @CLCDetalle, @Partida, 125.00, 1, SYSDATETIME(), @Usuario);

EXEC PRES.SP_RegresarChequeASolicitudSuficiencia
    @PKIdCheque = @Cheque,
    @FKIdEmpresa_SIS = @Empresa,
    @Motivo = N'Prueba integral de regreso hasta suficiencia',
    @IdUser = @Usuario;

IF NOT EXISTS
(
    SELECT 1 FROM PRES.SolicitudSuficiencia
    WHERE PKIdSolicitudSuficiencia = @Solicitud AND Activo = 1 AND Estatus = 1
)
    THROW 52001, N'La solicitud no quedó activa en estatus borrador.', 1;

IF EXISTS (SELECT 1 FROM PRES.Cheque WHERE PKIdCheque = @Cheque AND (Activo = 1 OR Estatus <> 4))
 OR EXISTS (SELECT 1 FROM PRES.CLC WHERE PKIdCLC = @CLC AND (Activo = 1 OR Estatus <> 4))
 OR EXISTS (SELECT 1 FROM PRES.Factura WHERE PKIdFactura = @Factura AND (Activo = 1 OR Estatus <> 4))
 OR EXISTS (SELECT 1 FROM PRES.Contrato WHERE PKIdContrato = @Contrato AND (Activo = 1 OR Estatus <> 4))
 OR EXISTS (SELECT 1 FROM PRES.AutorizacionSuficiencia WHERE PKIdAutorizacionSuficiencia = @Autorizacion AND (Activo = 1 OR Estatus <> 4))
    THROW 52002, N'Una etapa posterior no quedó cancelada lógicamente.', 1;

DECLARE @Regreso INT =
(
    SELECT PKIdRegresoChequeSuficiencia
    FROM PRES.RegresoChequeSuficiencia
    WHERE FKIdCheque_PRES = @Cheque
);

IF (SELECT COUNT(*) FROM PRES.RegresoChequeSuficienciaPoliza WHERE FKIdRegresoChequeSuficiencia_PRES = @Regreso) <> 4
    THROW 52003, N'No se generó una póliza de reversión por cada póliza original.', 1;

IF EXISTS
(
    SELECT 1
    FROM PRES.RegresoChequeSuficienciaPoliza R
    INNER JOIN CONTA.PolizaDetalle D ON D.FKIdPoliza_CONTA = R.FKIdPolizaReversion_CONTA AND D.Activo = 1
    WHERE R.FKIdRegresoChequeSuficiencia_PRES = @Regreso
    GROUP BY R.FKIdPolizaReversion_CONTA
    HAVING ABS(SUM(COALESCE(D.ImporteDebe, 0)) - SUM(COALESCE(D.ImporteHaber, 0))) > 0.01
)
    THROW 52004, N'Una póliza de reversión no quedó balanceada.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM PRES.RegresoChequeSuficienciaPoliza R
    INNER JOIN CONTA.PolizaDetalle D ON D.FKIdPoliza_CONTA = R.FKIdPolizaReversion_CONTA
    WHERE R.FKIdRegresoChequeSuficiencia_PRES = @Regreso
      AND D.ImporteHaber = 125.00 AND D.FKIdTipoDetallePoliza_SIS = 4
)
    THROW 52005, N'No se invirtieron correctamente Debe/Haber y Cargo/Abono.', 1;

DECLARE @ConteoAntes INT =
(
    SELECT COUNT(*) FROM PRES.RegresoChequeSuficienciaPoliza
    WHERE FKIdRegresoChequeSuficiencia_PRES = @Regreso
);

EXEC PRES.SP_RegresarChequeASolicitudSuficiencia
    @PKIdCheque = @Cheque,
    @FKIdEmpresa_SIS = @Empresa,
    @Motivo = N'Reintento idempotente de la misma operación',
    @IdUser = @Usuario;

IF @ConteoAntes <>
(
    SELECT COUNT(*) FROM PRES.RegresoChequeSuficienciaPoliza
    WHERE FKIdRegresoChequeSuficiencia_PRES = @Regreso
)
    THROW 52006, N'El reintento creó pólizas de reversión duplicadas.', 1;

SELECT N'OK' AS Resultado,
       @Cheque AS ChequePrueba,
       @Solicitud AS SolicitudPrueba,
       @ConteoAntes AS PolizasReversion,
       N'Los cambios se revierten al terminar la prueba.' AS Persistencia;

ROLLBACK TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
