/*
EXUX | Universidad Maya | Propuesta de reestructura SQL Server 2022
Almacen / Controles de persistencia
Generado a partir de metadatos: EmptyProjects (26 tablas) y GestionEmpresarial (309 tablas).
SOLO ARCHIVO GENERADO. NO APLICADO. SIN DATOS, SIN USUARIOS, SIN CREDENCIALES.
FASE C, después de todas las estructuras y relaciones.
CREATE OR ALTER permite revisar y volver a generar las definiciones propuestas.
La aplicación debe crear cabecera BORRADOR, agregar detalle y aplicar/autorizar al final.
No se importan los procedimientos de la aplicación antigua.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
DECLARE @BaseDestino sysname = N'EmptyProjects';
IF DB_NAME() <> @BaseDestino THROW 51000, N'Base incorrecta. Seleccione EmptyProjects o edite @BaseDestino para una copia autorizada.', 1;
IF DB_NAME() IN (N'GestionEmpresarial',N'master',N'model',N'msdb',N'tempdb') THROW 51000, N'Destino protegido: este paquete no se aplica en la base origen.', 1;
IF @@TRANCOUNT <> 0 THROW 51000, N'Ejecute cada archivo fuera de una transacción previa.', 1;
BEGIN TRY
BEGIN TRANSACTION;
EXEC sys.sp_executesql N'CREATE OR ALTER VIEW [ALMA].[vExistenciasPorAlmacen]
AS
WITH Mov AS (
 SELECT d.IdEmpresa,d.IdPartidaStock,SUM(d.Cantidad) Existencia,SUM(d.ImporteValoracion) ValorInventario
 FROM ALMA.MovimientoInventarioDetalle d
 JOIN ALMA.MovimientoInventario m ON m.IdMovimientoInventario=d.IdMovimiento AND m.IdEmpresa=d.IdEmpresa
 WHERE m.Estado=''APLICADO'' GROUP BY d.IdEmpresa,d.IdPartidaStock
), Res AS (
 SELECT IdEmpresa,IdPartidaStock,SUM(Cantidad) Reservado FROM ALMA.ReservaStock
 WHERE Estado=''ACTIVA'' GROUP BY IdEmpresa,IdPartidaStock
)
SELECT p.IdEmpresa,p.IdAlmacen,p.IdPartidaStock,p.IdProductoAlmacen,p.IdTipoBien,p.IdUbicacion,p.IdLote,p.Condicion,
 ISNULL(m.Existencia,0) Existencia,ISNULL(r.Reservado,0) Reservado,
 ISNULL(m.Existencia,0)-ISNULL(r.Reservado,0) Disponible,ISNULL(m.ValorInventario,0) ValorInventario
FROM ALMA.PartidaStock p LEFT JOIN Mov m ON m.IdEmpresa=p.IdEmpresa AND m.IdPartidaStock=p.IdPartidaStock
LEFT JOIN Res r ON r.IdEmpresa=p.IdEmpresa AND r.IdPartidaStock=p.IdPartidaStock;';

EXEC sys.sp_executesql N'CREATE OR ALTER TRIGGER [ALMA].[TR_EXUX_MovimientoInmutable]
ON [ALMA].[MovimientoInventario] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted WHERE Estado=''APLICADO'')
  THROW 51100,N''Un movimiento aplicado es inmutable: registrar reversa, no editar ni eliminar.'',1;
 IF EXISTS(SELECT 1 FROM inserted i WHERE i.Estado=''APLICADO'' AND NOT EXISTS(SELECT 1 FROM ALMA.MovimientoInventarioDetalle d WHERE d.IdMovimiento=i.IdMovimientoInventario))
  THROW 51101,N''No se puede aplicar un movimiento sin partidas.'',1;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventarioDetalle d ON d.IdMovimiento=i.IdMovimientoInventario
   WHERE i.Estado=''APLICADO'' AND ((i.Tipo IN (''ENTRADA'',''SALDO_INICIAL'') AND d.Cantidad<=0) OR (i.Tipo=''SALIDA'' AND d.Cantidad>=0)))
  THROW 51102,N''El signo de cantidad no corresponde a la entrada o salida.'',1;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventario m ON m.IdMovimientoInventario=i.IdMovimientoReversa
   WHERE i.Estado=''APLICADO'' AND i.Tipo=''REVERSA'' AND m.Estado<>''APLICADO'')
  THROW 51103,N''Solo se puede revertir un movimiento aplicado.'',1;
 IF EXISTS(
  SELECT i.IdMovimientoInventario,x.IdPartidaStock FROM inserted i
  CROSS APPLY (
   SELECT d.IdPartidaStock,d.Cantidad,d.ImporteValoracion FROM ALMA.MovimientoInventarioDetalle d WHERE d.IdMovimiento=i.IdMovimientoInventario
   UNION ALL
   SELECT d.IdPartidaStock,d.Cantidad,d.ImporteValoracion FROM ALMA.MovimientoInventarioDetalle d WHERE d.IdMovimiento=i.IdMovimientoReversa
  ) x WHERE i.Estado=''APLICADO'' AND i.Tipo=''REVERSA''
  GROUP BY i.IdMovimientoInventario,x.IdPartidaStock HAVING SUM(x.Cantidad)<>0 OR SUM(x.ImporteValoracion)<>0
 ) THROW 51104,N''La reversa debe compensar cantidades y valoración del original por partida.'',1;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventarioDetalle d ON d.IdMovimiento=i.IdMovimientoInventario
   WHERE i.Estado=''APLICADO'' AND i.Tipo=''TRANSFERENCIA'' AND d.IdTransferenciaDetalle IS NULL)
  THROW 51105,N''Una transferencia necesita origen documental en todas sus partidas.'',1;
 IF EXISTS(SELECT i.IdMovimientoInventario,d.IdTransferenciaDetalle FROM inserted i
   JOIN ALMA.MovimientoInventarioDetalle d ON d.IdMovimiento=i.IdMovimientoInventario
   WHERE i.Estado=''APLICADO'' AND i.Tipo=''TRANSFERENCIA''
   GROUP BY i.IdMovimientoInventario,d.IdTransferenciaDetalle HAVING SUM(d.Cantidad)<>0 OR SUM(d.ImporteValoracion)<>0 OR COUNT(DISTINCT d.IdAlmacen)<2)
  THROW 51106,N''La transferencia debe compensar cantidad y valor entre al menos dos almacenes.'',1;
END;';

EXEC sys.sp_executesql N'CREATE OR ALTER TRIGGER [ALMA].[TR_EXUX_DetalleMovimientoInmutable]
ON [ALMA].[MovimientoInventarioDetalle] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN ALMA.MovimientoInventario m WITH (UPDLOCK,HOLDLOCK) ON m.IdMovimientoInventario=i.IdMovimiento WHERE m.Estado=''APLICADO'')
 OR EXISTS(SELECT 1 FROM deleted d JOIN ALMA.MovimientoInventario m WITH (UPDLOCK,HOLDLOCK) ON m.IdMovimientoInventario=d.IdMovimiento WHERE m.Estado=''APLICADO'')
  THROW 51107,N''Las partidas de un movimiento aplicado son inmutables. Use una reversa.'',1;
END;';

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
 IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
