SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;

DECLARE @BaseEsperada sysname = N'GestionEmpresarial';

IF DB_NAME() <> @BaseEsperada
    THROW 51000, 'Seguridad: el script solo puede ejecutarse en GestionEmpresarial.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    /* Hijos del flujo de pago/recepcion. */
    DELETE FROM ALMA.DetalleSolicitudSalida;
    DELETE FROM ALMA.Almacen;

    DELETE FROM PRES.CLCFactura;
    DELETE FROM PRES.CLCDetalle;
    DELETE FROM PRES.CLC;
    DELETE FROM PRES.FacturaDetalle;
    DELETE FROM PRES.Factura;
    DELETE FROM PRES.ContratoDetalle;
    DELETE FROM PRES.Contrato;

    DELETE FROM PRES.RegresoChequeSuficienciaPoliza;
    DELETE FROM PRES.RegresoChequeSuficiencia;
    DELETE FROM PRES.ChequePartidas;
    DELETE FROM PRES.Cheque;

    /* Compra y suficiencia. */
    DELETE FROM ORCO.Contratos;
    DELETE FROM ORCO.OrdenCompraDetalle;
    DELETE FROM ORCO.OrdenCompraPartida;
    DELETE FROM ORCO.OrdenCompra;

    DELETE FROM PRES.AutorizacionSuficienciaDetalle;
    DELETE FROM PRES.AutorizacionSuficiencia;
    DELETE FROM PRES.SolicitudSuficienciaDetalle;
    DELETE FROM PRES.SolicitudSuficiencia;

    DELETE FROM ORCO.CotizacionDetalle;
    DELETE FROM ORCO.Cotizacion;
    DELETE FROM ORCO.RequisicionDetalle;
    DELETE FROM ORCO.RequisicionPartida;
    DELETE FROM ORCO.Requisicion;

    /* Presupuesto creado para la prueba. */
    DELETE FROM PRES.EgreAdecuacionDetalle;
    DELETE FROM PRES.EgresoAutorizado;
    DELETE FROM PRES.EgresoProyectado;

    /* Polizas generadas por el flujo ya desvinculado. */
    DELETE FROM CONTA.PolizaDetalle;
    DELETE FROM CONTA.Poliza;

    /* Reiniciar solo tablas transaccionales que realmente usan IDENTITY. */
    DECLARE @Tabla nvarchar(300);
    DECLARE tablas CURSOR LOCAL FAST_FORWARD FOR
        SELECT QUOTENAME(s.name) + N'.' + QUOTENAME(t.name)
        FROM sys.tables t
        JOIN sys.schemas s ON s.schema_id = t.schema_id
        WHERE t.object_id IN
        (
            OBJECT_ID(N'ALMA.Almacen'),
            OBJECT_ID(N'ORCO.Cotizacion'), OBJECT_ID(N'ORCO.CotizacionDetalle'),
            OBJECT_ID(N'ORCO.Requisicion'), OBJECT_ID(N'ORCO.RequisicionDetalle'),
            OBJECT_ID(N'ORCO.RequisicionPartida'), OBJECT_ID(N'ORCO.OrdenCompra'),
            OBJECT_ID(N'ORCO.OrdenCompraDetalle'), OBJECT_ID(N'ORCO.OrdenCompraPartida'),
            OBJECT_ID(N'PRES.SolicitudSuficiencia'), OBJECT_ID(N'PRES.SolicitudSuficienciaDetalle'),
            OBJECT_ID(N'PRES.AutorizacionSuficiencia'), OBJECT_ID(N'PRES.AutorizacionSuficienciaDetalle'),
            OBJECT_ID(N'PRES.Contrato'), OBJECT_ID(N'PRES.ContratoDetalle'),
            OBJECT_ID(N'PRES.Factura'), OBJECT_ID(N'PRES.FacturaDetalle'),
            OBJECT_ID(N'PRES.EgresoProyectado'), OBJECT_ID(N'PRES.EgresoAutorizado'),
            OBJECT_ID(N'CONTA.Poliza'), OBJECT_ID(N'CONTA.PolizaDetalle')
        )
        AND EXISTS (SELECT 1 FROM sys.identity_columns i WHERE i.object_id = t.object_id);

    OPEN tablas;
    FETCH NEXT FROM tablas INTO @Tabla;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DBCC CHECKIDENT (@Tabla, RESEED, 0) WITH NO_INFOMSGS;
        FETCH NEXT FROM tablas INTO @Tabla;
    END;
    CLOSE tablas;
    DEALLOCATE tablas;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT N'Limpieza completada' AS Resultado, DB_NAME() AS BaseDatos, SYSDATETIME() AS Fecha;
