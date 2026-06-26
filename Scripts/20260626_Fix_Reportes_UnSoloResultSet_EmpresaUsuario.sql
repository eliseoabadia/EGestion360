SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @Sql nvarchar(max);

    PRINT N'Limpiando SELECTs de depuracion en CONTA.SPR_EstadoAnaliticoActivo_DevEx';

    SELECT @Sql = OBJECT_DEFINITION(OBJECT_ID(N'[CONTA].[SPR_EstadoAnaliticoActivo_DevEx]'));

    IF @Sql IS NULL
        THROW 51100, N'No existe CONTA.SPR_EstadoAnaliticoActivo_DevEx.', 1;

    SET @Sql = REPLACE(@Sql, N'CREATE   PROCEDURE', N'CREATE OR ALTER PROCEDURE');
    SET @Sql = REPLACE(@Sql, N'CREATE  PROCEDURE', N'CREATE OR ALTER PROCEDURE');
    SET @Sql = REPLACE(@Sql, N'CREATE PROCEDURE', N'CREATE OR ALTER PROCEDURE');

    SET @Sql = REPLACE(@Sql, N'
---EFM MUESTRA CARGOS
SELECT ''MUESTRA CARGOS'' 
SELECT @TMP_Cargos
SELECT * FROM #Cargos WHERE FK_IdCuentaContable__CONTA IN (8,9);', N'
---EFM MUESTRA CARGOS (sin salida de depuracion)');

    SET @Sql = REPLACE(@Sql, N'
---EFM MUESTRA ABONOS
SELECT ''MUESTRA ABONOS'' 
SELECT * FROM #Abonos WHERE FK_IdCuentaContable__CONTA IN (8,9);', N'
---EFM MUESTRA ABONOS (sin salida de depuracion)');

    SET @Sql = REPLACE(@Sql, N'
---EFM CREA AUXILIAR CON LAS 3 CONSULTAS ANTERIORES
SELECT ''MUESTRA #AuxConta'' 
SELECT * FROM #AuxConta WHERE FK_IdCuentaContable__CONTA IN (8,9);;', N'
---EFM CREA AUXILIAR CON LAS 3 CONSULTAS ANTERIORES (sin salida de depuracion)');

    SET @Sql = REPLACE(@Sql, N'
---EFM TEMPORAL DE BALANZA
SELECT ''TABLA #BalanzaComprobacion''
SELECT * FROM #BalanzaComprobacion', N'
---EFM TEMPORAL DE BALANZA (sin salida de depuracion)');

    EXEC sys.sp_executesql @Sql;

    PRINT N'Normalizando CONTA.SPR_RepEndeudamientoNeto a un solo resultset';

    SELECT @Sql = OBJECT_DEFINITION(OBJECT_ID(N'[CONTA].[SPR_RepEndeudamientoNeto]'));

    IF @Sql IS NULL
        THROW 51101, N'No existe CONTA.SPR_RepEndeudamientoNeto.', 1;

    SET @Sql = REPLACE(@Sql, N'CREATE   PROCEDURE', N'CREATE OR ALTER PROCEDURE');
    SET @Sql = REPLACE(@Sql, N'CREATE  PROCEDURE', N'CREATE OR ALTER PROCEDURE');
    SET @Sql = REPLACE(@Sql, N'CREATE PROCEDURE', N'CREATE OR ALTER PROCEDURE');
    SET @Sql = REPLACE(@Sql, N'
	SELECT * FROM #tbRepEndeudamientoResultado2', N'
	-- Segundo resultset retirado: DevExpress/EF deben recibir una sola salida principal.');

    EXEC sys.sp_executesql @Sql;

    PRINT N'Normalizando CONTA.SPR_RepInteresesDeuda a un solo resultset';

    SELECT @Sql = OBJECT_DEFINITION(OBJECT_ID(N'[CONTA].[SPR_RepInteresesDeuda]'));

    IF @Sql IS NULL
        THROW 51102, N'No existe CONTA.SPR_RepInteresesDeuda.', 1;

    SET @Sql = REPLACE(@Sql, N'CREATE   PROCEDURE', N'CREATE OR ALTER PROCEDURE');
    SET @Sql = REPLACE(@Sql, N'CREATE  PROCEDURE', N'CREATE OR ALTER PROCEDURE');
    SET @Sql = REPLACE(@Sql, N'CREATE PROCEDURE', N'CREATE OR ALTER PROCEDURE');
    SET @Sql = REPLACE(@Sql, N'
	SELECT * FROM #tbRepInteresesDeudaResultado2', N'
	-- Segundo resultset retirado: DevExpress/EF deben recibir una sola salida principal.');

    EXEC sys.sp_executesql @Sql;

    PRINT N'Aplanando ALMA.SP_ReporteInventario a un solo resultset';

    EXEC(N'
CREATE OR ALTER PROCEDURE [ALMA].[SP_ReporteInventario]
    @PKIdInventario INT,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        inv.PKIdInventario,
        inv.FKIdEmpresa_SIS,
        inv.EmpresaNombre,
        inv.FKIdCalendarioInventario_ALMA,
        inv.CalendarioFolio,
        inv.FKIdArea_SIS,
        inv.AreaNombre,
        inv.FKIdEstatusInventario_ALMA,
        inv.EstatusDescripcion,
        inv.EstatusColor,
        inv.Folio,
        inv.FechaInventario,
        inv.Responsable,
        inv.Observaciones,
        inv.TotalBienes,
        inv.TotalLocalizados,
        inv.TotalDiferencias,
        inv.Autorizado,
        inv.FechaAutorizacion,
        inv.UsuarioAutorizacion,
        inv.Activo,
        inv.FechaCreacion,
        inv.UsuarioCreacion,
        inv.FechaModificacion,
        inv.UsuarioModificacion,
        det.PKIdInventarioDetalle AS DetallePKIdInventarioDetalle,
        det.FKIdInventario_ALMA AS DetalleFKIdInventario_ALMA,
        det.InventarioFolio AS DetalleInventarioFolio,
        det.FKIdBien_ALMA AS DetalleFKIdBien_ALMA,
        det.BienClave AS DetalleBienClave,
        det.BienDescripcion AS DetalleBienDescripcion,
        det.Modelo AS DetalleModelo,
        det.Serie AS DetalleSerie,
        det.ValorActual AS DetalleValorActual,
        det.ClaveBien AS DetalleClaveBien,
        det.DescripcionBien AS DetalleDescripcionBien,
        det.SerieCapturada AS DetalleSerieCapturada,
        det.UbicacionSistema AS DetalleUbicacionSistema,
        det.UbicacionFisica AS DetalleUbicacionFisica,
        det.Localizado AS DetalleLocalizado,
        det.TieneDiferencia AS DetalleTieneDiferencia,
        det.Observaciones AS DetalleObservaciones,
        det.Activo AS DetalleActivo,
        det.FechaCreacion AS DetalleFechaCreacion,
        det.UsuarioCreacion AS DetalleUsuarioCreacion,
        det.FechaModificacion AS DetalleFechaModificacion,
        det.UsuarioModificacion AS DetalleUsuarioModificacion
    FROM ALMA.Vw_Inventarios inv
    LEFT JOIN ALMA.Vw_InventarioDetalle det
        ON det.FKIdInventario_ALMA = inv.PKIdInventario
    WHERE inv.PKIdInventario = @PKIdInventario
      AND (@IdEmpresa IS NULL OR inv.FKIdEmpresa_SIS = @IdEmpresa)
    ORDER BY det.PKIdInventarioDetalle;
END');

    PRINT N'Aplanando ALMA.SP_ReporteSolicitudSalida a un solo resultset';

    EXEC(N'
CREATE OR ALTER PROCEDURE [ALMA].[SP_ReporteSolicitudSalida]
    @PKIdSolicitudSalida INT,
    @IdEmpresa INT = NULL,
    @IdEmpleado INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        sol.PKIdSolicitudSalida,
        sol.FKIdEmpresa_SIS,
        sol.EmpresaNombre,
        sol.FKIdAreaSolicita_SIS,
        sol.AreaSolicitaNombre,
        sol.FKIdAreaEntrega_SIS,
        sol.AreaEntregaNombre,
        sol.FKIdEstatusSolicitudSalida_ALMA,
        sol.EstatusDescripcion,
        sol.EstatusColor,
        sol.Folio,
        sol.FechaSolicitud,
        sol.FechaRequerida,
        sol.Solicitante,
        sol.Justificacion,
        sol.Observaciones,
        sol.Autorizado,
        sol.FechaAutorizacion,
        sol.UsuarioAutorizacion,
        sol.Activo,
        sol.FechaCreacion,
        sol.UsuarioCreacion,
        sol.FechaModificacion,
        sol.UsuarioModificacion,
        det.PKIdDetalleSolicitudSalida AS DetallePKIdDetalleSolicitudSalida,
        det.FKIdSolicitudSalida_ALMA AS DetalleFKIdSolicitudSalida_ALMA,
        det.SolicitudFolio AS DetalleSolicitudFolio,
        det.FKIdAlmacen_ALMA AS DetalleFKIdAlmacen_ALMA,
        det.AlmacenClave AS DetalleAlmacenClave,
        det.FKIdTipoBien_ALMA AS DetalleFKIdTipoBien_ALMA,
        det.TipoBienClave AS DetalleTipoBienClave,
        det.TipoBienDescripcion AS DetalleTipoBienDescripcion,
        det.FKIdUnidades_ALMA AS DetalleFKIdUnidades_ALMA,
        det.UnidadDescripcion AS DetalleUnidadDescripcion,
        det.CantidadSolicitada AS DetalleCantidadSolicitada,
        det.CantidadAutorizada AS DetalleCantidadAutorizada,
        det.CantidadEntregada AS DetalleCantidadEntregada,
        det.CantidadPendiente AS DetalleCantidadPendiente,
        det.Observaciones AS DetalleObservaciones,
        det.Activo AS DetalleActivo,
        det.FechaCreacion AS DetalleFechaCreacion,
        det.UsuarioCreacion AS DetalleUsuarioCreacion,
        det.FechaModificacion AS DetalleFechaModificacion,
        det.UsuarioModificacion AS DetalleUsuarioModificacion
    FROM ALMA.Vw_SolicitudSalida sol
    LEFT JOIN ALMA.Vw_DetalleSolicitudSalida det
        ON det.FKIdSolicitudSalida_ALMA = sol.PKIdSolicitudSalida
    WHERE sol.PKIdSolicitudSalida = @PKIdSolicitudSalida
      AND (@IdEmpresa IS NULL OR sol.FKIdEmpresa_SIS = @IdEmpresa)
    ORDER BY det.PKIdDetalleSolicitudSalida;
END');

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;

    THROW;
END CATCH;

PRINT N'Validando reportes con mas de un resultset';
