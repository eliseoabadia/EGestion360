SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRANSACTION;

DECLARE @Ahora datetime2 = SYSDATETIME();
DECLARE @PolizaAutorizado int;
DECLARE @PolizaCompromiso int;
DECLARE @PolizaDevengado int;

SELECT @PolizaAutorizado = PKIdPoliza FROM CONTA.Poliza WHERE ClavePoliza = N'MANAUT001';
IF @PolizaAutorizado IS NULL
BEGIN
    INSERT CONTA.Poliza
        (FKIdAnio_SIS, FKIdMes_SIS, FKIdTipoPoliza_SIS, ClavePoliza, NombrePoliza,
         FechaPoliza, EstaBalanceado, Activo, FechaCreacion, UsuarioCreacion,
         PermitirModificar, Autorizado, FechaSolicitud, FechaAutorizacion)
    VALUES
        (2026, 8, 4, N'MANAUT001', N'Presupuesto autorizado: papel bond - Área ALMACÉN TULTITLÁN',
         '2026-08-10', 1, 1, @Ahora, 1, 0, 1, @Ahora, @Ahora);
    SET @PolizaAutorizado = SCOPE_IDENTITY();

    INSERT CONTA.PolizaDetalle
        (FKIdCuentaContable_CONTA, FKIdPoliza_CONTA, Descripcion, ImporteDebe, ImporteHaber,
         FKIdReferencia, FKIdTipoDetallePoliza_SIS, Activo, FechaCreacion, UsuarioCreacion)
    VALUES
        (266618, @PolizaAutorizado, N'Presupuesto de egresos aprobado - partida 21101', 12000, 0, 12, 1, 1, @Ahora, 1),
        (266960, @PolizaAutorizado, N'Presupuesto de egresos por ejercer - partida 21101', 0, 12000, 12, 2, 1, @Ahora, 1);
END;

SELECT @PolizaCompromiso = PKIdPoliza FROM CONTA.Poliza WHERE ClavePoliza = N'MANCOM001';
IF @PolizaCompromiso IS NULL
BEGIN
    INSERT CONTA.Poliza
        (FKIdAnio_SIS, FKIdMes_SIS, FKIdTipoPoliza_SIS, ClavePoliza, NombrePoliza,
         FechaPoliza, EstaBalanceado, Activo, FechaCreacion, UsuarioCreacion,
         PermitirModificar, Autorizado, FechaSolicitud, FechaAutorizacion)
    VALUES
        (2026, 8, 4, N'MANCOM001', N'Compromiso de la orden OC-2026-0001',
         '2026-08-10', 1, 1, @Ahora, 1, 0, 1, @Ahora, @Ahora);
    SET @PolizaCompromiso = SCOPE_IDENTITY();

    INSERT CONTA.PolizaDetalle
        (FKIdCuentaContable_CONTA, FKIdPoliza_CONTA, Descripcion, ImporteDebe, ImporteHaber,
         FKIdReferencia, FKIdTipoDetallePoliza_SIS, Activo, FechaCreacion, UsuarioCreacion)
    VALUES
        (266960, @PolizaCompromiso, N'Presupuesto por ejercer - OC-2026-0001', 2400, 0, 6, 1, 1, @Ahora, 1),
        (267661, @PolizaCompromiso, N'Presupuesto comprometido - OC-2026-0001', 0, 2400, 6, 2, 1, @Ahora, 1);
END;

SELECT @PolizaDevengado = PKIdPoliza FROM CONTA.Poliza WHERE ClavePoliza = N'MANDEV001';
IF @PolizaDevengado IS NULL
BEGIN
    INSERT CONTA.Poliza
        (FKIdAnio_SIS, FKIdMes_SIS, FKIdTipoPoliza_SIS, ClavePoliza, NombrePoliza,
         FechaPoliza, EstaBalanceado, Activo, FechaCreacion, UsuarioCreacion,
         PermitirModificar, Autorizado, FechaSolicitud, FechaAutorizacion)
    VALUES
        (2026, 8, 4, N'MANDEV001', N'Devengado por recepción de OC-2026-0001',
         '2026-08-10', 1, 1, @Ahora, 1, 0, 1, @Ahora, @Ahora);
    SET @PolizaDevengado = SCOPE_IDENTITY();

    INSERT CONTA.PolizaDetalle
        (FKIdCuentaContable_CONTA, FKIdPoliza_CONTA, Descripcion, ImporteDebe, ImporteHaber,
         FKIdReferencia, FKIdTipoDetallePoliza_SIS, Activo, FechaCreacion, UsuarioCreacion)
    VALUES
        (267661, @PolizaDevengado, N'Presupuesto comprometido - recepción OC-2026-0001', 2400, 0, 6, 1, 1, @Ahora, 1),
        (268008, @PolizaDevengado, N'Presupuesto devengado - recepción OC-2026-0001', 0, 2400, 6, 2, 1, @Ahora, 1);
END;

UPDATE PRES.EgresoAutorizado SET FKIdPoliza_CONTA = @PolizaAutorizado WHERE PKIdEgresoAutorizado = 12;
UPDATE ORCO.OrdenCompra
SET FKIdPoliza_CONTA = @PolizaCompromiso,
    FKIdEstatusOrdenCompra_ORCO = 2,
    FechaModificacion = @Ahora,
    UsuarioModificacion = 1
WHERE PKIdOrdenCompra = 6;

IF NOT EXISTS (SELECT 1 FROM ALMA.Almacen WHERE FKIdDetalleOrdenCompra_ORCO = 6 AND Activo = 1)
BEGIN
    INSERT ALMA.Almacen
        (FKIdEmpresa_SIS, FKIdArea_SIS, FKIdTipoBien_ALMA, FKIdUnidades_ALMA,
         FKIdDetalleOrdenCompra_ORCO, Clave, Cantidad, CostoUnitario, Costo,
         Factura, Remision, Lote, FechaEntrada, AplicaAlmacen, InventarioCerrado,
         EsContabilizado, Activo, FechaCreacion, UsuarioCreacion, FKIdAnio_SIS)
    VALUES
        (1, 1025, 421, 12, 6, N'ENT-OC-2026-0001', 10, 240, 2400,
         N'FAC-MANUAL-001', N'REM-MANUAL-001', N'LOTE-MANUAL-001', '2026-08-10',
         1, 0, 1, 1, @Ahora, 1, 2026);
END;

UPDATE ORCO.OrdenCompraDetalle
SET CantidadRecibida = 10,
    FechaModificacion = @Ahora,
    UsuarioModificacion = 1
WHERE PKIdOrdenCompraDetalle = 6;

COMMIT TRANSACTION;

SELECT @PolizaAutorizado AS PolizaAutorizado,
       @PolizaCompromiso AS PolizaCompromiso,
       @PolizaDevengado AS PolizaDevengado;
