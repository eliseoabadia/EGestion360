/*
    Flujo presupuestal de adquisiciones:
    Requisicion -> Cotizacion -> Suficiencia -> Autorizacion -> Contrato
    -> CLC -> Cheque.

    La posicion autorizada se conserva por partida. Los detalles posteriores
    heredan la partida de su documento origen y no aceptan sustituciones.
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

IF COL_LENGTH('ORCO.RequisicionPartida', 'FKIdEgresoAutorizado_PRES') IS NULL
BEGIN
    ALTER TABLE ORCO.RequisicionPartida
        ADD FKIdEgresoAutorizado_PRES int NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID(N'ORCO.RequisicionPartida')
      AND name = N'FK_RequisicionPartida_EgresoAutorizado'
)
BEGIN
    ALTER TABLE ORCO.RequisicionPartida WITH CHECK
        ADD CONSTRAINT FK_RequisicionPartida_EgresoAutorizado
        FOREIGN KEY (FKIdEgresoAutorizado_PRES)
        REFERENCES PRES.EgresoAutorizado(PKIdEgresoAutorizado);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'ORCO.RequisicionPartida')
      AND name = N'IX_RequisicionPartida_EgresoAutorizado'
)
BEGIN
    CREATE INDEX IX_RequisicionPartida_EgresoAutorizado
        ON ORCO.RequisicionPartida(FKIdEgresoAutorizado_PRES)
        INCLUDE (FKIdRequisicion_ORCO, FKIdPartida_CONTA, Monto, Activo);
END;
GO

IF EXISTS (
    SELECT FKIdRequisicion_ORCO, FKIdPartida_CONTA
    FROM ORCO.RequisicionPartida
    WHERE Activo = 1
    GROUP BY FKIdRequisicion_ORCO, FKIdPartida_CONTA
    HAVING COUNT(*) > 1
)
    THROW 51000, 'Existen partidas activas duplicadas por requisicion. Corrija los datos antes de aplicar el indice unico.', 1;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'ORCO.RequisicionPartida')
      AND name = N'UX_RequisicionPartida_Activa'
)
BEGIN
    CREATE UNIQUE INDEX UX_RequisicionPartida_Activa
        ON ORCO.RequisicionPartida(FKIdRequisicion_ORCO, FKIdPartida_CONTA)
        WHERE Activo = 1;
END;
GO

/* Conserva datos migrados cuando el encabezado ya apunta a la misma partida. */
UPDATE rp
SET FKIdEgresoAutorizado_PRES = r.FKIdEgresoAutorizado_PRES
FROM ORCO.RequisicionPartida rp
INNER JOIN ORCO.Requisicion r
    ON r.PKIdRequisicion = rp.FKIdRequisicion_ORCO
INNER JOIN PRES.EgresoAutorizado ea
    ON ea.PKIdEgresoAutorizado = r.FKIdEgresoAutorizado_PRES
   AND ea.FKIdPartida_CONTA = rp.FKIdPartida_CONTA
WHERE rp.FKIdEgresoAutorizado_PRES IS NULL;
GO

CREATE OR ALTER VIEW ORCO.Vw_RequisicionPartida
AS
SELECT
    rp.PKIdRequisicionPartida,
    rp.FKIdEmpresa_SIS,
    rp.FKIdRequisicion_ORCO,
    rp.FKIdPartida_CONTA,
    rp.FKIdEgresoAutorizado_PRES,
    rp.Monto,
    rp.Observaciones,
    rp.Activo,
    rp.FechaCreacion,
    rp.UsuarioCreacion,
    rp.FechaModificacion,
    rp.UsuarioModificacion,
    emp.Nombre AS EmpresaNombre,
    req.Descripcion AS RequisicionDescripcion,
    req.FechaRequisicion,
    req.Importe AS RequisicionImporte,
    part.Clave AS PartidaClave,
    part.Descripcion AS PartidaDescripcion,
    CONCAT(part.Clave, ' - ', part.Descripcion) AS ClaveNombre,
    ea.Descripcion AS EgresoAutorizadoDescripcion,
    disp.Total AS Disponible
FROM ORCO.RequisicionPartida rp
LEFT JOIN SIS.Empresa emp
    ON emp.PKIdEmpresa = rp.FKIdEmpresa_SIS AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req
    ON req.PKIdRequisicion = rp.FKIdRequisicion_ORCO AND req.Activo = 1
LEFT JOIN CONTA.Partida part
    ON part.PKIdPartida = rp.FKIdPartida_CONTA AND part.Activo = 1
LEFT JOIN PRES.EgresoAutorizado ea
    ON ea.PKIdEgresoAutorizado = rp.FKIdEgresoAutorizado_PRES
LEFT JOIN PRES.Vw_EgresoDisponible disp
    ON disp.PKIdEgresoAutorizado = rp.FKIdEgresoAutorizado_PRES
WHERE rp.Activo = 1;
GO

CREATE OR ALTER VIEW PRES.Vw_EgresoDisponible
AS
WITH AdecXEgreAut AS (
    SELECT
        det.FKIdEgresoAutorizado_PRES,
        SUM(det.Enero) Enero, SUM(det.Febrero) Febrero,
        SUM(det.Marzo) Marzo, SUM(det.Abril) Abril,
        SUM(det.Mayo) Mayo, SUM(det.Junio) Junio,
        SUM(det.Julio) Julio, SUM(det.Agosto) Agosto,
        SUM(det.Septiembre) Septiembre, SUM(det.Octubre) Octubre,
        SUM(det.Noviembre) Noviembre, SUM(det.Diciembre) Diciembre,
        SUM(det.Total) Total
    FROM PRES.EgreAdecuacionDetalle det
    INNER JOIN PRES.EgreAdecuacion enc
        ON enc.PKIdEgreAdecuacion = det.FKIdEgreAdecuacion_PRES
       AND enc.Activo = 1 AND enc.Autorizado = 1
    INNER JOIN PRES.EgresoAutorizado egr
        ON egr.PKIdEgresoAutorizado = det.FKIdEgresoAutorizado_PRES
       AND egr.Activo = 1
    WHERE det.Activo = 1
      AND egr.FKIdFuenteFinanciamiento_PRES <> 6
    GROUP BY det.FKIdEgresoAutorizado_PRES
),
CtoXEgreAut AS (
    SELECT
        COALESCE(rp.FKIdEgresoAutorizado_PRES, req.FKIdEgresoAutorizado_PRES) FKIdEgresoAutorizado_PRES,
        SUM(cd.Enero) Enero, SUM(cd.Febrero) Febrero,
        SUM(cd.Marzo) Marzo, SUM(cd.Abril) Abril,
        SUM(cd.Mayo) Mayo, SUM(cd.Junio) Junio,
        SUM(cd.Julio) Julio, SUM(cd.Agosto) Agosto,
        SUM(cd.Septiembre) Septiembre, SUM(cd.Octubre) Octubre,
        SUM(cd.Noviembre) Noviembre, SUM(cd.Diciembre) Diciembre,
        SUM(cd.Total) Total
    FROM PRES.ContratoDetalle cd
    INNER JOIN PRES.Contrato c
        ON c.PKIdContrato = cd.FKIdContrato_PRES AND c.Activo = 1
    INNER JOIN PRES.AutorizacionSuficiencia au
        ON au.PKIdAutorizacionSuficiencia = c.FKIdAutorizacionSuficiencia_PRES
       AND au.Activo = 1
    INNER JOIN PRES.SolicitudSuficiencia ss
        ON ss.PKIdSolicitudSuficiencia = au.FKIdSolicitudSuficiencia_PRES
       AND ss.Activo = 1
    INNER JOIN ORCO.Requisicion req
        ON req.PKIdRequisicion = ss.FKIdRequisicion_ORCO AND req.Activo = 1
    LEFT JOIN ORCO.RequisicionPartida rp
        ON rp.FKIdRequisicion_ORCO = req.PKIdRequisicion
       AND rp.FKIdPartida_CONTA = cd.FKIdPartida_CONTA
       AND rp.Activo = 1
    INNER JOIN PRES.EgresoAutorizado egr
        ON egr.PKIdEgresoAutorizado =
            COALESCE(rp.FKIdEgresoAutorizado_PRES, req.FKIdEgresoAutorizado_PRES)
       AND egr.Activo = 1
    WHERE cd.Activo = 1
      AND egr.FKIdFuenteFinanciamiento_PRES <> 6
    GROUP BY COALESCE(rp.FKIdEgresoAutorizado_PRES, req.FKIdEgresoAutorizado_PRES)
)
SELECT
    egr.PKIdEgresoAutorizado, egr.FKIdEgresoProyectado_PRES,
    egr.FKIdAnio_SIS, egr.AnioClave,
    egr.FKIdPrograma_PRES, egr.ProgramaClave, egr.ProgramaDescripcion,
    egr.ProgramaClaveNombre, egr.FKIdPartida_CONTA, egr.PartidaClave,
    egr.PartidaDescripcion, egr.PartidaClaveNombre,
    egr.FKIdArea_SIS, egr.AreaClave, egr.AreaNombre,
    egr.FKIdFuenteFinanciamiento_PRES, egr.FuenteFinanciamientoClave,
    egr.FuenteFinanciamientoDescripcion, egr.FuenteFinanciamientoClaveNombre,
    egr.FKIdTipoGasto_PRES, egr.TipoGastoClave, egr.TipoGastoDescripcion,
    egr.TipoGastoClaveNombre, egr.FKIdDigitoIdentificador_PRES,
    egr.DigitoIdentificadorClave, egr.DigitoIdentificadorDescripcion,
    egr.DigitoIdentificadorClaveNombre, egr.FKIdDestinoGasto_PRES,
    egr.DestinoGastoClave, egr.DestinoGastoDescripcion,
    egr.DestinoGastoClaveNombre, egr.FKIdPY_PRES,
    egr.PyClave, egr.PyDescripcion, egr.PyClaveNombre,
    egr.Descripcion, egr.Fecha,
    ISNULL(egr.Enero,0)+ISNULL(ad.Enero,0)-ISNULL(ct.Enero,0) Enero,
    ISNULL(egr.Febrero,0)+ISNULL(ad.Febrero,0)-ISNULL(ct.Febrero,0) Febrero,
    ISNULL(egr.Marzo,0)+ISNULL(ad.Marzo,0)-ISNULL(ct.Marzo,0) Marzo,
    ISNULL(egr.Abril,0)+ISNULL(ad.Abril,0)-ISNULL(ct.Abril,0) Abril,
    ISNULL(egr.Mayo,0)+ISNULL(ad.Mayo,0)-ISNULL(ct.Mayo,0) Mayo,
    ISNULL(egr.Junio,0)+ISNULL(ad.Junio,0)-ISNULL(ct.Junio,0) Junio,
    ISNULL(egr.Julio,0)+ISNULL(ad.Julio,0)-ISNULL(ct.Julio,0) Julio,
    ISNULL(egr.Agosto,0)+ISNULL(ad.Agosto,0)-ISNULL(ct.Agosto,0) Agosto,
    ISNULL(egr.Septiembre,0)+ISNULL(ad.Septiembre,0)-ISNULL(ct.Septiembre,0) Septiembre,
    ISNULL(egr.Octubre,0)+ISNULL(ad.Octubre,0)-ISNULL(ct.Octubre,0) Octubre,
    ISNULL(egr.Noviembre,0)+ISNULL(ad.Noviembre,0)-ISNULL(ct.Noviembre,0) Noviembre,
    ISNULL(egr.Diciembre,0)+ISNULL(ad.Diciembre,0)-ISNULL(ct.Diciembre,0) Diciembre,
    ISNULL(egr.Total,0)+ISNULL(ad.Total,0)-ISNULL(ct.Total,0) Total,
    CAST('' AS varchar(max)) [Message],
    CONCAT(
        egr.PartidaClaveNombre, ' ',
        FORMAT(ISNULL(egr.Total,0)+ISNULL(ad.Total,0)-ISNULL(ct.Total,0), 'C', 'es-MX'),
        ' ', LEFT(ISNULL(egr.Descripcion,''),30)
    ) DescripcionRequisicion
FROM PRES.Vw_EgresoAutorizado egr
LEFT JOIN AdecXEgreAut ad
    ON ad.FKIdEgresoAutorizado_PRES = egr.PKIdEgresoAutorizado
LEFT JOIN CtoXEgreAut ct
    ON ct.FKIdEgresoAutorizado_PRES = egr.PKIdEgresoAutorizado
WHERE egr.Activo = 1
  AND egr.FKIdFuenteFinanciamiento_PRES <> 6;
GO

CREATE OR ALTER TRIGGER ORCO.TR_Requisicion_ValidarYAsignarFolio
ON ORCO.Requisicion
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.PKIdRequisicion = i.PKIdRequisicion
        WHERE (
            ISNULL(i.FKIdEmpresa_SIS,0) <> ISNULL(d.FKIdEmpresa_SIS,0) OR
            ISNULL(i.FKIdPersona_NOM,0) <> ISNULL(d.FKIdPersona_NOM,0) OR
            ISNULL(i.FKIdArea_SIS,0) <> ISNULL(d.FKIdArea_SIS,0) OR
            ISNULL(i.Descripcion,'') <> ISNULL(d.Descripcion,'') OR
            ISNULL(i.Observaciones,'') <> ISNULL(d.Observaciones,'') OR
            i.FechaRequisicion <> d.FechaRequisicion OR
            i.Servicio <> d.Servicio OR
            ISNULL(i.FKIdProyecto_ORCO,0) <> ISNULL(d.FKIdProyecto_ORCO,0) OR
            ISNULL(i.FechaRequiereInicio,'19000101') <> ISNULL(d.FechaRequiereInicio,'19000101') OR
            ISNULL(i.FechaRequiereFin,'19000101') <> ISNULL(d.FechaRequiereFin,'19000101') OR
            ISNULL(i.FKIdPrograma_PRES,0) <> ISNULL(d.FKIdPrograma_PRES,0) OR
            ISNULL(i.Importe,0) <> ISNULL(d.Importe,0) OR
            ISNULL(i.FKIdFuenteFinanciamiento_PRES,0) <> ISNULL(d.FKIdFuenteFinanciamiento_PRES,0) OR
            ISNULL(i.FKIdAnio_SIS,0) <> ISNULL(d.FKIdAnio_SIS,0) OR
            ISNULL(i.FKIdTipoGasto_PRES,0) <> ISNULL(d.FKIdTipoGasto_PRES,0) OR
            ISNULL(i.FKIdDigitoIdentificador_PRES,0) <> ISNULL(d.FKIdDigitoIdentificador_PRES,0) OR
            ISNULL(i.FKIdDestinoGasto_PRES,0) <> ISNULL(d.FKIdDestinoGasto_PRES,0) OR
            ISNULL(i.FKIdEgresoAutorizado_PRES,0) <> ISNULL(d.FKIdEgresoAutorizado_PRES,0) OR
            ISNULL(i.CompraDirecta,0) <> ISNULL(d.CompraDirecta,0) OR
            i.Activo <> d.Activo
        )
        AND (
            EXISTS (
                SELECT 1 FROM ORCO.Cotizacion c
                WHERE c.FKIdRequisicion_ORCO = i.PKIdRequisicion AND c.Activo = 1
            )
            OR EXISTS (
                SELECT 1 FROM PRES.SolicitudSuficiencia ss
                WHERE ss.FKIdRequisicion_ORCO = i.PKIdRequisicion AND ss.Activo = 1
            )
        )
    )
        THROW 51015, 'La requisicion ya avanzo a cotizacion o suficiencia y no puede modificarse.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN PRES.Vw_EgresoAutorizado ea
            ON ea.PKIdEgresoAutorizado = i.FKIdEgresoAutorizado_PRES AND ea.Activo = 1
        WHERE i.Activo = 1
          AND (
              i.Importe IS NULL OR i.Importe <= 0 OR
              i.FechaRequiereInicio IS NULL OR i.FechaRequiereFin IS NULL OR
              CONVERT(date,i.FechaRequisicion) > CONVERT(date,i.FechaRequiereInicio) OR
              CONVERT(date,i.FechaRequiereInicio) > CONVERT(date,i.FechaRequiereFin) OR
              ea.PKIdEgresoAutorizado IS NULL OR
              ea.FKIdAnio_SIS <> i.FKIdAnio_SIS OR
              ea.FKIdArea_SIS <> i.FKIdArea_SIS OR
              ea.FKIdPrograma_PRES <> i.FKIdPrograma_PRES OR
              ISNULL(ea.FKIdFuenteFinanciamiento_PRES,0) <> ISNULL(i.FKIdFuenteFinanciamiento_PRES,0) OR
              ISNULL(ea.FKIdTipoGasto_PRES,0) <> ISNULL(i.FKIdTipoGasto_PRES,0) OR
              ISNULL(ea.FKIdDigitoIdentificador_PRES,0) <> ISNULL(i.FKIdDigitoIdentificador_PRES,0) OR
              ISNULL(ea.FKIdDestinoGasto_PRES,0) <> ISNULL(i.FKIdDestinoGasto_PRES,0) OR
              ISNULL(ea.FKIdPY_PRES,0) <> ISNULL(i.FKIdProyecto_ORCO,0)
          )
    )
        THROW 51016, 'La requisicion tiene fechas, importe o clasificacion incompatibles con la posicion presupuestal.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN ORCO.RequisicionPartida rp
            ON rp.FKIdRequisicion_ORCO = i.PKIdRequisicion AND rp.Activo = 1
        LEFT JOIN PRES.Vw_EgresoAutorizado ea
            ON ea.PKIdEgresoAutorizado = rp.FKIdEgresoAutorizado_PRES AND ea.Activo = 1
        WHERE i.Activo = 1
          AND (
              ea.PKIdEgresoAutorizado IS NULL OR
              ea.FKIdPartida_CONTA <> rp.FKIdPartida_CONTA OR
              ea.FKIdAnio_SIS <> i.FKIdAnio_SIS OR
              ea.FKIdArea_SIS <> i.FKIdArea_SIS OR
              ea.FKIdPrograma_PRES <> i.FKIdPrograma_PRES OR
              ISNULL(ea.FKIdFuenteFinanciamiento_PRES,0) <> ISNULL(i.FKIdFuenteFinanciamiento_PRES,0) OR
              ISNULL(ea.FKIdTipoGasto_PRES,0) <> ISNULL(i.FKIdTipoGasto_PRES,0) OR
              ISNULL(ea.FKIdDigitoIdentificador_PRES,0) <> ISNULL(i.FKIdDigitoIdentificador_PRES,0) OR
              ISNULL(ea.FKIdDestinoGasto_PRES,0) <> ISNULL(i.FKIdDestinoGasto_PRES,0) OR
              ISNULL(ea.FKIdPY_PRES,0) <> ISNULL(i.FKIdProyecto_ORCO,0)
          )
    )
        THROW 51017, 'La clasificacion del encabezado no es compatible con las partidas existentes.', 1;

    UPDATE r
    SET Descripcion = CONCAT(
        'REQ-',
        COALESCE(CONVERT(varchar(4), a.Clave), CONVERT(varchar(4), YEAR(i.FechaRequisicion))),
        '-',
        RIGHT(CONCAT('000000', CONVERT(varchar(10), i.PKIdRequisicion)), 6)
    )
    FROM ORCO.Requisicion r
    INNER JOIN inserted i ON i.PKIdRequisicion = r.PKIdRequisicion
    LEFT JOIN SIS.Anio a ON a.PKIdAnio = i.FKIdAnio_SIS
    WHERE NULLIF(LTRIM(RTRIM(i.Descripcion)), '') IS NULL;
END;
GO

CREATE OR ALTER TRIGGER ORCO.TR_Requisicion_NotificarAlta
ON ORCO.Requisicion
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Id int,
        @Empresa int,
        @Usuario int,
        @Importe decimal(18,4),
        @Folio nvarchar(100),
        @Mensaje nvarchar(max),
        @Notificacion bigint;

    DECLARE altas CURSOR LOCAL FAST_FORWARD FOR
        SELECT PKIdRequisicion, FKIdEmpresa_SIS, UsuarioCreacion, Importe, Descripcion
        FROM inserted
        WHERE Activo = 1;

    OPEN altas;
    FETCH NEXT FROM altas INTO @Id, @Empresa, @Usuario, @Importe, @Folio;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Mensaje = CONCAT(N'Nueva requisicion ', @Folio, N' por ', FORMAT(@Importe, 'C', 'es-MX'));
        EXEC SIS.SP_MantenimientoNotificacion
            @Action = 1,
            @Fk_IdUsuarioOrigen = @Usuario,
            @Fk_IdMenu = 301,
            @Fk_IdAccionSuscrita = 1,
            @Mensaje = @Mensaje,
            @IdUser = @Usuario,
            @Controlador = N'Requisicion',
            @Pk_IdNotificacion = @Notificacion OUTPUT,
            @Fk_IdEmpresa = @Empresa,
            @Importe = @Importe,
            @IdRegistro = @Id;

        FETCH NEXT FROM altas INTO @Id, @Empresa, @Usuario, @Importe, @Folio;
    END;
    CLOSE altas;
    DEALLOCATE altas;
END;
GO

EXEC sys.sp_settriggerorder
    @triggername = N'ORCO.TR_Requisicion_ValidarYAsignarFolio',
    @order = N'First',
    @stmttype = N'INSERT';
EXEC sys.sp_settriggerorder
    @triggername = N'ORCO.TR_Requisicion_NotificarAlta',
    @order = N'Last',
    @stmttype = N'INSERT';
GO

CREATE OR ALTER TRIGGER ORCO.TR_RequisicionPartida_ValidarFlujo
ON ORCO.RequisicionPartida
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.PKIdRequisicionPartida = i.PKIdRequisicionPartida
        WHERE EXISTS (
            SELECT 1 FROM ORCO.Cotizacion c
            WHERE c.FKIdRequisicion_ORCO = i.FKIdRequisicion_ORCO AND c.Activo = 1
        )
        OR EXISTS (
            SELECT 1 FROM PRES.SolicitudSuficiencia ss
            WHERE ss.FKIdRequisicion_ORCO = i.FKIdRequisicion_ORCO AND ss.Activo = 1
        )
    )
        THROW 51001, 'La requisicion ya avanzo a cotizacion o suficiencia; sus partidas estan bloqueadas.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN ORCO.Requisicion r
            ON r.PKIdRequisicion = i.FKIdRequisicion_ORCO AND r.Activo = 1
        LEFT JOIN PRES.Vw_EgresoAutorizado ea
            ON ea.PKIdEgresoAutorizado = i.FKIdEgresoAutorizado_PRES
           AND ea.Activo = 1
        WHERE i.Activo = 1
          AND (
              i.Monto IS NULL OR i.Monto <= 0 OR
              i.FKIdEmpresa_SIS <> r.FKIdEmpresa_SIS OR
              ea.PKIdEgresoAutorizado IS NULL OR
              ea.FKIdPartida_CONTA <> i.FKIdPartida_CONTA OR
              ea.FKIdAnio_SIS <> r.FKIdAnio_SIS OR
              ea.FKIdArea_SIS <> r.FKIdArea_SIS OR
              ea.FKIdPrograma_PRES <> r.FKIdPrograma_PRES OR
              ISNULL(ea.FKIdFuenteFinanciamiento_PRES,0) <> ISNULL(r.FKIdFuenteFinanciamiento_PRES,0) OR
              ISNULL(ea.FKIdTipoGasto_PRES,0) <> ISNULL(r.FKIdTipoGasto_PRES,0) OR
              ISNULL(ea.FKIdDigitoIdentificador_PRES,0) <> ISNULL(r.FKIdDigitoIdentificador_PRES,0) OR
              ISNULL(ea.FKIdDestinoGasto_PRES,0) <> ISNULL(r.FKIdDestinoGasto_PRES,0) OR
              ISNULL(ea.FKIdPY_PRES,0) <> ISNULL(r.FKIdProyecto_ORCO,0)
          )
    )
        THROW 51002, 'La partida, empresa o clasificacion no corresponde a la posicion presupuestal seleccionada.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN ORCO.Requisicion r ON r.PKIdRequisicion = i.FKIdRequisicion_ORCO
        CROSS APPLY (
            SELECT SUM(ISNULL(rp.Monto,0)) Monto
            FROM ORCO.RequisicionPartida rp
            WHERE rp.FKIdRequisicion_ORCO = r.PKIdRequisicion AND rp.Activo = 1
        ) x
        WHERE x.Monto > ISNULL(r.Importe,0)
    )
        THROW 51003, 'La suma de partidas excede el importe de la requisicion.', 1;
END;
GO

CREATE OR ALTER TRIGGER ORCO.TR_RequisicionDetalle_ValidarFlujo
ON ORCO.RequisicionDetalle
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.PKIdRequisicionDetalle = i.PKIdRequisicionDetalle
        WHERE EXISTS (
            SELECT 1 FROM ORCO.Cotizacion c
            WHERE c.FKIdRequisicion_ORCO = i.FKIdRequisicion_ORCO AND c.Activo = 1
        )
        OR EXISTS (
            SELECT 1 FROM PRES.SolicitudSuficiencia ss
            WHERE ss.FKIdRequisicion_ORCO = i.FKIdRequisicion_ORCO AND ss.Activo = 1
        )
    )
        THROW 51004, 'La requisicion ya avanzo a cotizacion o suficiencia; sus bienes estan bloqueados.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN ORCO.Requisicion r
            ON r.PKIdRequisicion = i.FKIdRequisicion_ORCO AND r.Activo = 1
        LEFT JOIN ALMA.TipoBien tb
            ON tb.PKIdTipoBien = i.FKIdTipoBien_ALMA AND tb.Activo = 1
        LEFT JOIN ORCO.RequisicionPartida rp
            ON rp.FKIdRequisicion_ORCO = i.FKIdRequisicion_ORCO
           AND rp.FKIdPartida_CONTA = tb.FKIdPartida_CONTA
           AND rp.Activo = 1
        WHERE i.Activo = 1
          AND (
              i.FKIdEmpresa_SIS <> r.FKIdEmpresa_SIS OR
              i.Cantidad <= 0 OR
              tb.PKIdTipoBien IS NULL OR
              rp.PKIdRequisicionPartida IS NULL
          )
    )
        THROW 51005, 'El bien debe pertenecer a una partida presupuestal activa de la requisicion.', 1;
END;
GO

CREATE OR ALTER TRIGGER ORCO.TR_Cotizacion_ValidarRequisicion
ON ORCO.Cotizacion
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.PKIdCotizacion = i.PKIdCotizacion
        WHERE d.Activo = 1 AND i.Activo = 0
          AND EXISTS (
              SELECT 1 FROM PRES.SolicitudSuficiencia ss
              WHERE ss.FKIdRequisicion_ORCO = i.FKIdRequisicion_ORCO AND ss.Activo = 1
          )
    )
        THROW 51006, 'La cotizacion no puede eliminarse porque la requisicion ya tiene suficiencia.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN ORCO.Requisicion r
            ON r.PKIdRequisicion = i.FKIdRequisicion_ORCO AND r.Activo = 1
        WHERE i.Activo = 1
          AND (
              NOT EXISTS (
                  SELECT 1 FROM ORCO.RequisicionDetalle rd
                  WHERE rd.FKIdRequisicion_ORCO = r.PKIdRequisicion AND rd.Activo = 1
              )
              OR NOT EXISTS (
                  SELECT 1 FROM ORCO.RequisicionPartida rp
                  WHERE rp.FKIdRequisicion_ORCO = r.PKIdRequisicion
                    AND rp.Activo = 1
                    AND rp.FKIdEgresoAutorizado_PRES IS NOT NULL
              )
              OR ISNULL((
                  SELECT SUM(ISNULL(rp.Monto,0))
                  FROM ORCO.RequisicionPartida rp
                  WHERE rp.FKIdRequisicion_ORCO = r.PKIdRequisicion AND rp.Activo = 1
              ),0) <> ISNULL(r.Importe,0)
          )
    )
        THROW 51007, 'La requisicion requiere bienes y partidas con posicion que sumen exactamente su importe antes de cotizar.', 1;
END;
GO

CREATE OR ALTER TRIGGER PRES.TR_SolicitudSuficiencia_ValidarRequisicion
ON PRES.SolicitudSuficiencia
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN ORCO.Requisicion r
            ON r.PKIdRequisicion = i.FKIdRequisicion_ORCO AND r.Activo = 1
        WHERE i.Activo = 1
          AND (
              i.FKIdEmpresa_SIS <> r.FKIdEmpresa_SIS
              OR NOT EXISTS (
                  SELECT 1
                  FROM ORCO.Cotizacion c
                  WHERE c.FKIdRequisicion_ORCO = r.PKIdRequisicion
                    AND c.Activo = 1
                    AND NOT EXISTS (
                        SELECT 1
                        FROM ORCO.RequisicionDetalle rd
                        WHERE rd.FKIdRequisicion_ORCO = r.PKIdRequisicion
                          AND rd.Activo = 1
                          AND NOT EXISTS (
                              SELECT 1 FROM ORCO.CotizacionDetalle cd
                              WHERE cd.FKIdCotizacion_ORCO = c.PKIdCotizacion
                                AND cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle
                                AND cd.Activo = 1
                                AND cd.PrecioUnitario > 0
                          )
                    )
              )
          )
    )
        THROW 51008, 'La suficiencia requiere una cotizacion completa y vigente de la misma requisicion.', 1;
END;
GO

CREATE OR ALTER TRIGGER PRES.TR_SolicitudSuficienciaDetalle_HeredarPartida
ON PRES.SolicitudSuficienciaDetalle
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN PRES.SolicitudSuficiencia ss
            ON ss.PKIdSolicitudSuficiencia = i.FKIdSolicitudSuficiencia_PRES AND ss.Activo = 1
        INNER JOIN ORCO.RequisicionDetalle rd
            ON rd.PKIdRequisicionDetalle = i.FKIdRequisicionDetalle_ORCO AND rd.Activo = 1
        INNER JOIN ALMA.TipoBien tb
            ON tb.PKIdTipoBien = rd.FKIdTipoBien_ALMA AND tb.Activo = 1
        LEFT JOIN ORCO.RequisicionPartida rp
            ON rp.FKIdRequisicion_ORCO = ss.FKIdRequisicion_ORCO
           AND rp.FKIdPartida_CONTA = tb.FKIdPartida_CONTA
           AND rp.Activo = 1
        WHERE rd.FKIdRequisicion_ORCO <> ss.FKIdRequisicion_ORCO
           OR rp.PKIdRequisicionPartida IS NULL
           OR rp.FKIdEgresoAutorizado_PRES IS NULL
           OR i.FKIdEmpresa_SIS <> ss.FKIdEmpresa_SIS
    )
        THROW 51009, 'El detalle de suficiencia no pertenece a la requisicion o no tiene posicion presupuestal.', 1;

    UPDATE sd
    SET FKIdPartida_CONTA = tb.FKIdPartida_CONTA
    FROM PRES.SolicitudSuficienciaDetalle sd
    INNER JOIN inserted i
        ON i.PKIdSolicitudSuficienciaDetalle = sd.PKIdSolicitudSuficienciaDetalle
    INNER JOIN ORCO.RequisicionDetalle rd
        ON rd.PKIdRequisicionDetalle = i.FKIdRequisicionDetalle_ORCO
    INNER JOIN ALMA.TipoBien tb
        ON tb.PKIdTipoBien = rd.FKIdTipoBien_ALMA;
END;
GO

CREATE OR ALTER TRIGGER PRES.TR_AutorizacionSuficienciaDetalle_HeredarPartida
ON PRES.AutorizacionSuficienciaDetalle
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN PRES.AutorizacionSuficiencia a
            ON a.PKIdAutorizacionSuficiencia = i.FKIdAutorizacionSuficiencia_PRES AND a.Activo = 1
        INNER JOIN PRES.SolicitudSuficienciaDetalle sd
            ON sd.PKIdSolicitudSuficienciaDetalle = i.FKIdSolicitudSuficienciaDetalle_PRES AND sd.Activo = 1
        WHERE sd.FKIdSolicitudSuficiencia_PRES <> a.FKIdSolicitudSuficiencia_PRES
           OR i.FKIdEmpresa_SIS <> a.FKIdEmpresa_SIS
    )
        THROW 51010, 'El detalle autorizado no pertenece a la solicitud de suficiencia indicada.', 1;

    UPDATE ad
    SET FKIdPartida_CONTA = sd.FKIdPartida_CONTA
    FROM PRES.AutorizacionSuficienciaDetalle ad
    INNER JOIN inserted i
        ON i.PKIdAutorizacionSuficienciaDetalle = ad.PKIdAutorizacionSuficienciaDetalle
    INNER JOIN PRES.SolicitudSuficienciaDetalle sd
        ON sd.PKIdSolicitudSuficienciaDetalle = i.FKIdSolicitudSuficienciaDetalle_PRES;
END;
GO

CREATE OR ALTER TRIGGER PRES.TR_ContratoDetalle_HeredarPartida
ON PRES.ContratoDetalle
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN PRES.Contrato c
            ON c.PKIdContrato = i.FKIdContrato_PRES AND c.Activo = 1
        INNER JOIN PRES.AutorizacionSuficienciaDetalle ad
            ON ad.PKIdAutorizacionSuficienciaDetalle = i.FKIdAutorizacionSuficienciaDetalle_PRES
           AND ad.Activo = 1
        WHERE ad.FKIdAutorizacionSuficiencia_PRES <> c.FKIdAutorizacionSuficiencia_PRES
           OR i.FKIdEmpresa_SIS <> c.FKIdEmpresa_SIS
    )
        THROW 51011, 'El detalle de contrato no pertenece a la autorizacion seleccionada.', 1;

    UPDATE cd
    SET FKIdPartida_CONTA = ad.FKIdPartida_CONTA
    FROM PRES.ContratoDetalle cd
    INNER JOIN inserted i ON i.PKIdContratoDetalle = cd.PKIdContratoDetalle
    INNER JOIN PRES.AutorizacionSuficienciaDetalle ad
        ON ad.PKIdAutorizacionSuficienciaDetalle = i.FKIdAutorizacionSuficienciaDetalle_PRES;
END;
GO

CREATE OR ALTER TRIGGER PRES.TR_CLCDetalle_HeredarPartida
ON PRES.CLCDetalle
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN PRES.CLC clc
            ON clc.PKIdCLC = i.FKIdCLC_PRES AND clc.Activo = 1
        INNER JOIN PRES.ContratoDetalle cd
            ON cd.PKIdContratoDetalle = i.FKIdContratoDetalle_PRES AND cd.Activo = 1
        WHERE cd.FKIdContrato_PRES <> clc.FKIdContrato_PRES
           OR i.FKIdEmpresa_SIS <> clc.FKIdEmpresa_SIS
    )
        THROW 51012, 'El detalle de CLC no pertenece al contrato seleccionado.', 1;

    UPDATE d
    SET FKIdPartida_CONTA = cd.FKIdPartida_CONTA
    FROM PRES.CLCDetalle d
    INNER JOIN inserted i ON i.PKIdCLCDetalle = d.PKIdCLCDetalle
    INNER JOIN PRES.ContratoDetalle cd
        ON cd.PKIdContratoDetalle = i.FKIdContratoDetalle_PRES;
END;
GO

CREATE OR ALTER TRIGGER PRES.TR_Cheque_ValidarCLC
ON PRES.Cheque
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN PRES.CLC clc ON clc.PKIdCLC = i.FKIdCLC_PRES AND clc.Activo = 1
        WHERE i.Activo = 1
          AND (
              i.FKIdEmpresa_SIS <> clc.FKIdEmpresa_SIS
              OR NOT EXISTS (
                  SELECT 1 FROM PRES.CLCDetalle d
                  WHERE d.FKIdCLC_PRES = clc.PKIdCLC AND d.Activo = 1
              )
              OR NOT EXISTS (
                  SELECT 1 FROM PRES.CLCFactura f
                  WHERE f.FKIdCLC_PRES = clc.PKIdCLC AND f.Activo = 1
              )
          )
    )
        THROW 51013, 'El cheque requiere CLC con detalle y factura aplicada.', 1;
END;
GO

CREATE OR ALTER TRIGGER PRES.TR_ChequePartidas_HeredarPartida
ON PRES.ChequePartidas
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN PRES.Cheque ch
            ON ch.PKIdCheque = i.FKIdCheque_PRES AND ch.Activo = 1
        INNER JOIN PRES.CLCDetalle d
            ON d.PKIdCLCDetalle = i.FKIdCLCDetalle_PRES AND d.Activo = 1
        WHERE d.FKIdCLC_PRES <> ch.FKIdCLC_PRES
           OR i.FKIdEmpresa_SIS <> ch.FKIdEmpresa_SIS
    )
        THROW 51014, 'La partida del cheque no pertenece al CLC seleccionado.', 1;

    UPDATE cp
    SET FKIdPartida_CONTA = d.FKIdPartida_CONTA
    FROM PRES.ChequePartidas cp
    INNER JOIN inserted i ON i.PKIdChequePartida = cp.PKIdChequePartida
    INNER JOIN PRES.CLCDetalle d ON d.PKIdCLCDetalle = i.FKIdCLCDetalle_PRES;
END;
GO

PRINT 'Flujo requisicion-hasta-cheque actualizado correctamente.';
GO
