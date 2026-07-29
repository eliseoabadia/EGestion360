/*
    Prueba transaccional: crea un flujo completo y siempre hace ROLLBACK.
    En cada detalle se intenta enviar la partida 56701. Los triggers deben
    heredar 21101 desde la requisicion y conservarla hasta el cheque.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM ORCO.Proyecto WHERE PKIdProyecto = 10006)
    BEGIN
        SET IDENTITY_INSERT ORCO.Proyecto ON;
        INSERT ORCO.Proyecto
            (PKIdProyecto, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
        VALUES
            (10006, N'PY prueba flujo', 1, SYSDATETIME(), 1);
        SET IDENTITY_INSERT ORCO.Proyecto OFF;
    END;

    INSERT PRES.EgresoAutorizado (
        FKIdPrograma_PRES, FKIdPartida_CONTA, FKIdArea_SIS, Descripcion,
        Fecha, FKIdPoliza_CONTA, Activo, FechaCreacion, UsuarioCreacion,
        FKIdEgresoProyectado_PRES, Enero, Febrero, Marzo, Abril, Mayo,
        Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
        FechaAutorizacion, UsuarioAutorizacion,
        FKIdFuenteFinanciamiento_PRES, FKIdTipoGasto_PRES,
        FKIdDigitoIdentificador_PRES, FKIdDestinoGasto_PRES, FKIdPY_PRES
    )
    SELECT
        FKIdPrograma_PRES, 21101, FKIdArea_SIS, N'Posicion prueba transaccional',
        Fecha, FKIdPoliza_CONTA, 1, SYSDATETIME(), 1,
        FKIdEgresoProyectado_PRES, 100, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        FechaAutorizacion, UsuarioAutorizacion,
        FKIdFuenteFinanciamiento_PRES, FKIdTipoGasto_PRES,
        FKIdDigitoIdentificador_PRES, FKIdDestinoGasto_PRES, FKIdPY_PRES
    FROM PRES.EgresoAutorizado
    WHERE PKIdEgresoAutorizado = 1;
    DECLARE @EgresoId int = SCOPE_IDENTITY();

    INSERT ORCO.Requisicion (
        FKIdEmpresa_SIS, FKIdPersona_NOM, FKIdArea_SIS, Descripcion,
        Observaciones, FechaRequisicion, Servicio, FKIdProyecto_ORCO,
        FechaRequiereInicio, FechaRequiereFin, FKIdPrograma_PRES, Importe,
        FKIdFuenteFinanciamiento_PRES, FKIdAnio_SIS, FKIdTipoGasto_PRES,
        FKIdDigitoIdentificador_PRES, FKIdDestinoGasto_PRES,
        FKIdEgresoAutorizado_PRES, CompraDirecta, Activo,
        FechaCreacion, UsuarioCreacion
    )
    SELECT
        1, 3, FKIdArea_SIS, N'', N'Prueba flujo rollback',
        GETDATE(), 0, 10006, GETDATE(), DATEADD(day, 1, GETDATE()),
        FKIdPrograma_PRES, 100, FKIdFuenteFinanciamiento_PRES, FKIdAnio_SIS,
        FKIdTipoGasto_PRES, FKIdDigitoIdentificador_PRES,
        FKIdDestinoGasto_PRES, @EgresoId, 0, 1, SYSDATETIME(), 1
    FROM PRES.Vw_EgresoAutorizado
    WHERE PKIdEgresoAutorizado = @EgresoId;
    DECLARE @RequisicionId int = SCOPE_IDENTITY();

    INSERT ORCO.RequisicionPartida (
        FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FKIdPartida_CONTA,
        FKIdEgresoAutorizado_PRES, Monto, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @RequisicionId, 21101, @EgresoId, 100, 1, SYSDATETIME(), 1);

    INSERT ORCO.RequisicionDetalle (
        FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FKIdTipoBien_ALMA,
        FKIdUnidades_ALMA, Cantidad, Observaciones, Activo,
        FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @RequisicionId, 5, 15, 1, N'Prueba', 1, SYSDATETIME(), 1);
    DECLARE @RequisicionDetalleId int = SCOPE_IDENTITY();

    INSERT ORCO.Cotizacion (
        FKIdRequisicion_ORCO, FKIdProveedor_SIS, FechaSolicitud,
        Servicio, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (@RequisicionId, 1, GETDATE(), 0, 1, SYSDATETIME(), 1);
    DECLARE @CotizacionId int = SCOPE_IDENTITY();

    INSERT ORCO.CotizacionDetalle (
        FKIdCotizacion_ORCO, FKIdRequisicionDetalle_ORCO,
        PrecioUnitario, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (@CotizacionId, @RequisicionDetalleId, 100, 1, SYSDATETIME(), 1);

    INSERT ORCO.Cotizacion (
        FKIdRequisicion_ORCO, FKIdProveedor_SIS, FechaSolicitud,
        Servicio, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (@RequisicionId, 2, GETDATE(), 0, 1, SYSDATETIME(), 1);
    DECLARE @CotizacionId2 int = SCOPE_IDENTITY();

    INSERT ORCO.CotizacionDetalle (
        FKIdCotizacion_ORCO, FKIdRequisicionDetalle_ORCO,
        PrecioUnitario, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (@CotizacionId2, @RequisicionDetalleId, 105, 1, SYSDATETIME(), 1);

    INSERT ORCO.Cotizacion (
        FKIdRequisicion_ORCO, FKIdProveedor_SIS, FechaSolicitud,
        Servicio, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (@RequisicionId, 3, GETDATE(), 0, 1, SYSDATETIME(), 1);
    DECLARE @CotizacionId3 int = SCOPE_IDENTITY();

    INSERT ORCO.CotizacionDetalle (
        FKIdCotizacion_ORCO, FKIdRequisicionDetalle_ORCO,
        PrecioUnitario, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (@CotizacionId3, @RequisicionDetalleId, 110, 1, SYSDATETIME(), 1);

    INSERT PRES.SolicitudSuficiencia (
        FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FechaSolicitud,
        Estatus, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @RequisicionId, GETDATE(), 3, 1, SYSDATETIME(), 1);
    DECLARE @SolicitudId int = SCOPE_IDENTITY();

    INSERT PRES.SolicitudSuficienciaDetalle (
        FKIdEmpresa_SIS, FKIdSolicitudSuficiencia_PRES,
        FKIdRequisicionDetalle_ORCO, FKIdPartida_CONTA,
        Enero, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @SolicitudId, @RequisicionDetalleId, 56701,
         100, 1, SYSDATETIME(), 1);
    DECLARE @SolicitudDetalleId int = SCOPE_IDENTITY();

    INSERT PRES.AutorizacionSuficiencia (
        FKIdEmpresa_SIS, FKIdSolicitudSuficiencia_PRES, FechaAutorizacion,
        Justificacion, AutorizadoPor_NOM, Estatus, Activo,
        FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @SolicitudId, GETDATE(), N'Prueba', 3, 2, 1, SYSDATETIME(), 1);
    DECLARE @AutorizacionId int = SCOPE_IDENTITY();

    INSERT PRES.AutorizacionSuficienciaDetalle (
        FKIdEmpresa_SIS, FKIdAutorizacionSuficiencia_PRES,
        FKIdSolicitudSuficienciaDetalle_PRES, FKIdPartida_CONTA,
        Enero, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @AutorizacionId, @SolicitudDetalleId, 56701,
         100, 1, SYSDATETIME(), 1);
    DECLARE @AutorizacionDetalleId int = SCOPE_IDENTITY();

    INSERT ORCO.OrdenCompra (
        FKIdEmpresa_SIS, FKIdRequisicion_ORCO, FKIdProveedor_SIS,
        FKIdEstatusOrdenCompra_ORCO, NumeroOrdenCompra, Descripcion,
        FechaOrdenCompra, Subtotal, Iva, Total, CompraDirecta,
        Activo, FechaCreacion, UsuarioCreacion, FKIdCotizacion_ORCO
    )
    VALUES (
        1, @RequisicionId, 1, 1, N'OC-PRUEBA-ROLLBACK',
        N'Orden adjudicada para prueba', GETDATE(), 100, 0, 100, 0,
        1, SYSDATETIME(), 1, @CotizacionId
    );
    DECLARE @OrdenCompraId int = SCOPE_IDENTITY();

    INSERT ORCO.OrdenCompraDetalle (
        FKIdOrdenCompra_ORCO, FKIdRequisicionDetalle_ORCO,
        FKIdCotizacionDetalle_ORCO, FKIdTipoBien_ALMA, FKIdUnidades_ALMA,
        CantidadSolicitada, CantidadRecibida, PrecioUnitario, Iva,
        Activo, FechaCreacion, UsuarioCreacion
    )
    SELECT
        @OrdenCompraId, @RequisicionDetalleId, cd.PKIdCotizacionDetalle,
        5, 15, 1, 0, 100, 0, 1, SYSDATETIME(), 1
    FROM ORCO.CotizacionDetalle cd
    WHERE cd.FKIdCotizacion_ORCO = @CotizacionId
      AND cd.FKIdRequisicionDetalle_ORCO = @RequisicionDetalleId
      AND cd.Activo = 1;

    UPDATE ORCO.OrdenCompra
    SET FKIdEstatusOrdenCompra_ORCO = 2
    WHERE PKIdOrdenCompra = @OrdenCompraId;

    INSERT ORCO.Contratos (
        FKIdEmpresa_SIS, FKIdOrdenCompra_ORCO, FKIdTipoContrato_ORCO,
        FKIdTipoDocumento_ORCO, FKIdArea_SIS, FKIdTipoGarantia_ORCO,
        FKIdProcedimientoContratacion_ORCO, FundamentoJuridico, Numero,
        Descripcion, FechaContrato, FechaRecepcion, FKIdModalidad_ORCO,
        MontoMaximo, MontoMinimo, Penalizacion, PlazoEjecucion,
        FKIdEstatusContrato_ORCO, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES (
        1, @OrdenCompraId, 1, 2, 1, 2, 3, N'Prueba',
        N'COMP-PRUEBA-ROLLBACK', N'Compromiso ligado a la orden',
        GETDATE(), GETDATE(), 2, 100, 0,
        N'Pena convencional conforme a contrato', N'Entrega inmediata',
        1, 1, SYSDATETIME(), 1
    );
    DECLARE @CompromisoOrcoId int = SCOPE_IDENTITY();

    IF NOT EXISTS (
        SELECT 1
        FROM ORCO.Contratos
        WHERE PKIdContrato = @CompromisoOrcoId
          AND FKIdOrdenCompra_ORCO = @OrdenCompraId
          AND Penalizacion = N'Pena convencional conforme a contrato'
    )
        THROW 51049, 'La orden, el compromiso ORCO o la penalizacion textual no se guardaron correctamente.', 1;

    INSERT PRES.Contrato (
        FKIdEmpresa_SIS, FKIdAutorizacionSuficiencia_PRES,
        FKIdProveedor_SIS, FKIdPoliza_CONTA, NumeroContrato,
        Descripcion, FechaContrato, MontoTotal, Estatus, Activo,
        FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @AutorizacionId, 1, 1, N'PRUEBA-ROLLBACK',
         N'Prueba', GETDATE(), 100, 1, 1, SYSDATETIME(), 1);
    DECLARE @ContratoId int = SCOPE_IDENTITY();

    INSERT PRES.ContratoDetalle (
        FKIdEmpresa_SIS, FKIdContrato_PRES,
        FKIdAutorizacionSuficienciaDetalle_PRES, FKIdPartida_CONTA,
        Enero, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @ContratoId, @AutorizacionDetalleId, 56701,
         100, 1, SYSDATETIME(), 1);
    DECLARE @ContratoDetalleId int = SCOPE_IDENTITY();

    INSERT PRES.Factura (
        FKIdEmpresa_SIS, FKIdContrato_PRES, FKIdPoliza_CONTA,
        NumFactura, FechaEmision, Subtotal, IVA, Retencion, Total,
        Estatus, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @ContratoId, 1, N'FACT-ROLLBACK', GETDATE(),
         100, 0, 0, 100, 1, 1, SYSDATETIME(), 1);
    DECLARE @FacturaId int = SCOPE_IDENTITY();

    INSERT PRES.FacturaDetalle (
        FKIdEmpresa_SIS, FKIdFactura_PRES, FKIdContratoDetalle_PRES,
        FKIdPartida_CONTA, MontoAplicado, Activo,
        FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @FacturaId, @ContratoDetalleId, 21101,
         100, 1, SYSDATETIME(), 1);
    DECLARE @FacturaDetalleId int = SCOPE_IDENTITY();

    INSERT PRES.CLC (
        FKIdEmpresa_SIS, FKIdContrato_PRES, FKIdPoliza_CONTA,
        NumCLC, FechaSolicitud, ImporteTotal, Estatus, Activo,
        FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @ContratoId, 1, N'CLC-ROLLBACK', GETDATE(),
         100, 1, 1, SYSDATETIME(), 1);
    DECLARE @ClcId int = SCOPE_IDENTITY();

    INSERT PRES.CLCDetalle (
        FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdContratoDetalle_PRES,
        FKIdPartida_CONTA, Enero, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @ClcId, @ContratoDetalleId, 56701,
         100, 1, SYSDATETIME(), 1);
    DECLARE @ClcDetalleId int = SCOPE_IDENTITY();

    INSERT PRES.CLCFactura (
        FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdFactura_PRES,
        FKIdFacturaDetalle_PRES, MontoAplicado, Activo,
        FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @ClcId, @FacturaId, @FacturaDetalleId,
         100, 1, SYSDATETIME(), 1);

    INSERT PRES.Cheque (
        FKIdEmpresa_SIS, FKIdCLC_PRES, FKIdCuentaBancaria_TES,
        FKIdPoliza_CONTA, FechaEmision, NumeroCheque, Concepto,
        ImporteTotal, Estatus, Activo, FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @ClcId, 1, 1, GETDATE(), N'CH-ROLLBACK',
         N'Prueba', 100, 1, 1, SYSDATETIME(), 1);
    DECLARE @ChequeId int = SCOPE_IDENTITY();

    INSERT PRES.ChequePartidas (
        FKIdEmpresa_SIS, FKIdCheque_PRES, FKIdCLCDetalle_PRES,
        FKIdPartida_CONTA, MontoPagado, Activo,
        FechaCreacion, UsuarioCreacion
    )
    VALUES
        (1, @ChequeId, @ClcDetalleId, 56701,
         100, 1, SYSDATETIME(), 1);

    DECLARE
        @PartidaSuficiencia int,
        @PartidaAutorizacion int,
        @PartidaContrato int,
        @PartidaClc int,
        @PartidaCheque int;

    SELECT @PartidaSuficiencia = FKIdPartida_CONTA
    FROM PRES.SolicitudSuficienciaDetalle
    WHERE PKIdSolicitudSuficienciaDetalle = @SolicitudDetalleId;

    SELECT @PartidaAutorizacion = FKIdPartida_CONTA
    FROM PRES.AutorizacionSuficienciaDetalle
    WHERE PKIdAutorizacionSuficienciaDetalle = @AutorizacionDetalleId;

    SELECT @PartidaContrato = FKIdPartida_CONTA
    FROM PRES.ContratoDetalle
    WHERE PKIdContratoDetalle = @ContratoDetalleId;

    SELECT @PartidaClc = FKIdPartida_CONTA
    FROM PRES.CLCDetalle
    WHERE PKIdCLCDetalle = @ClcDetalleId;

    SELECT @PartidaCheque = FKIdPartida_CONTA
    FROM PRES.ChequePartidas
    WHERE FKIdCheque_PRES = @ChequeId;

    SELECT
        @PartidaSuficiencia PartidaSuficiencia,
        @PartidaAutorizacion PartidaAutorizacion,
        @PartidaContrato PartidaContrato,
        @PartidaClc PartidaCLC,
        @PartidaCheque PartidaCheque;

    IF @PartidaSuficiencia <> 21101 OR
       @PartidaAutorizacion <> 21101 OR
       @PartidaContrato <> 21101 OR
       @PartidaClc <> 21101 OR
       @PartidaCheque <> 21101
        THROW 51050, 'La partida no se heredo correctamente hasta cheque.', 1;

    ROLLBACK TRANSACTION;
    PRINT 'PRUEBA CORRECTA: partida 21101 heredada hasta cheque. Sin cambios persistidos.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
