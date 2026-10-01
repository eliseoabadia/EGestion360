/*
EXUX | Universidad Maya | Propuesta de reestructura SQL Server 2022
Polizas_Contabilidad / Controles de persistencia
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
EXEC sys.sp_executesql N'CREATE OR ALTER TRIGGER [CONTA].[TR_EXUX_PolizaAutorizada]
ON [CONTA].[Poliza] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted WHERE Autorizado=1)
  THROW 51200,N''Una póliza autorizada es inmutable. Registre una póliza de reversa.'',1;
 IF EXISTS(SELECT i.PKIdPoliza FROM inserted i LEFT JOIN CONTA.PolizaDetalle d ON d.FKIdPoliza_CONTA=i.PKIdPoliza AND d.Activo=1
   WHERE i.Autorizado=1 GROUP BY i.PKIdPoliza
   HAVING COUNT(d.PKIdPolizaDetalle)<2 OR SUM(ISNULL(d.ImporteDebe,0))<>SUM(ISNULL(d.ImporteHaber,0)) OR SUM(ISNULL(d.ImporteDebe,0))<=0)
  THROW 51201,N''Una póliza autorizada necesita al menos dos partidas, debe y haber iguales y monto positivo.'',1;
END;';

EXEC sys.sp_executesql N'CREATE OR ALTER TRIGGER [CONTA].[TR_EXUX_PolizaDetalleAutorizada]
ON [CONTA].[PolizaDetalle] AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN CONTA.Poliza p WITH (UPDLOCK,HOLDLOCK) ON p.PKIdPoliza=i.FKIdPoliza_CONTA WHERE p.Autorizado=1)
 OR EXISTS(SELECT 1 FROM deleted d JOIN CONTA.Poliza p WITH (UPDLOCK,HOLDLOCK) ON p.PKIdPoliza=d.FKIdPoliza_CONTA WHERE p.Autorizado=1)
  THROW 51202,N''No es posible modificar las partidas de una póliza autorizada.'',1;
END;';

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
 IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
