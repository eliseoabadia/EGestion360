USE GestionEmpresarial;
GO

CREATE OR ALTER VIEW PRES.Vw_SolicitudSuficiencia
AS
SELECT
    ss.PKIdSolicitudSuficiencia,
    ss.FKIdEmpresa_SIS,
    emp.Nombre AS EmpresaNombre,
    ss.FKIdRequisicion_ORCO,
    req.FKIdAnio_SIS,
    req.FKIdArea_SIS,
    req.Descripcion AS RequisicionDescripcion,
    req.FechaRequisicion,
    req.Importe AS RequisicionImporte,
    ss.FechaSolicitud,
    ss.Justificacion,
    ss.GastoNoProgramable,
    ss.IdGastoNoProgramable,
    ss.IdCompromisoNomina,
    ss.Estatus,
    CASE ss.Estatus WHEN 1 THEN 'Borrador' WHEN 2 THEN 'Enviada' WHEN 3 THEN 'Autorizada' WHEN 4 THEN 'Rechazada' ELSE 'Sin definir' END AS EstatusDescripcion,
    ss.Activo,
    ss.FechaCreacion,
    ss.UsuarioCreacion,
    ss.FechaModificacion,
    ss.UsuarioModificacion
FROM PRES.SolicitudSuficiencia ss
LEFT JOIN SIS.Empresa emp ON ss.FKIdEmpresa_SIS = emp.PKIdEmpresa AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req ON ss.FKIdRequisicion_ORCO = req.PKIdRequisicion AND req.Activo = 1
WHERE ss.Activo = 1;
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
        LEFT JOIN ORCO.Requisicion r
            ON r.PKIdRequisicion = i.FKIdRequisicion_ORCO AND r.Activo = 1
        WHERE i.Activo = 1
          AND (r.PKIdRequisicion IS NULL
               OR i.FKIdEmpresa_SIS <> r.FKIdEmpresa_SIS
               OR i.FechaSolicitud > CONVERT(date, r.FechaRequisicion))
    )
        THROW 51008, 'La requisicion es invalida, pertenece a otra empresa o la fecha de solicitud es posterior a la requisicion.', 1;

    IF EXISTS (SELECT 1 FROM inserted WHERE Estatus NOT IN (1,2,3,4))
        THROW 51008, 'El estatus de la solicitud de suficiencia no es valido.', 1;

    IF EXISTS (
        SELECT 1 FROM inserted i
        LEFT JOIN deleted d ON d.PKIdSolicitudSuficiencia = i.PKIdSolicitudSuficiencia
        WHERE d.PKIdSolicitudSuficiencia IS NULL AND i.Estatus <> 1
    )
        THROW 51008, 'Una solicitud nueva debe iniciar en borrador.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON d.PKIdSolicitudSuficiencia = i.PKIdSolicitudSuficiencia
        WHERE NOT (
            i.Estatus = d.Estatus OR
            (i.Estatus = 2 AND EXISTS (
                SELECT 1 FROM PRES.AutorizacionSuficiencia a
                WHERE a.FKIdSolicitudSuficiencia_PRES=i.PKIdSolicitudSuficiencia
                  AND a.Activo=1 AND a.Estatus=1
            )) OR
            (i.Estatus = 3 AND EXISTS (
                SELECT 1 FROM PRES.AutorizacionSuficiencia a
                WHERE a.FKIdSolicitudSuficiencia_PRES=i.PKIdSolicitudSuficiencia
                  AND a.Activo=1 AND a.Estatus=2
            )) OR
            (i.Estatus = 1 AND NOT EXISTS (
                SELECT 1 FROM PRES.AutorizacionSuficiencia a
                WHERE a.FKIdSolicitudSuficiencia_PRES=i.PKIdSolicitudSuficiencia
                  AND a.Activo=1 AND a.Estatus<>3
            ))
        )
    )
        THROW 51008, 'La transicion de estatus de la solicitud no esta permitida.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON d.PKIdSolicitudSuficiencia = i.PKIdSolicitudSuficiencia
        WHERE d.Activo = 1 AND i.Activo = 0 AND d.Estatus <> 1
    )
        THROW 51008, 'Solo se puede eliminar una solicitud en borrador.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON d.PKIdSolicitudSuficiencia = i.PKIdSolicitudSuficiencia
        WHERE d.Estatus <> 1
          AND (i.FKIdEmpresa_SIS <> d.FKIdEmpresa_SIS
               OR i.FKIdRequisicion_ORCO <> d.FKIdRequisicion_ORCO
               OR i.FechaSolicitud <> d.FechaSolicitud
               OR ISNULL(i.Justificacion,'') <> ISNULL(d.Justificacion,'')
               OR ISNULL(i.GastoNoProgramable,'') <> ISNULL(d.GastoNoProgramable,'')
               OR ISNULL(i.IdGastoNoProgramable,-1) <> ISNULL(d.IdGastoNoProgramable,-1)
               OR ISNULL(i.IdCompromisoNomina,-1) <> ISNULL(d.IdCompromisoNomina,-1))
    )
        THROW 51008, 'Despues de enviar la solicitud solo puede cambiar su estatus.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN ORCO.Requisicion r ON r.PKIdRequisicion = i.FKIdRequisicion_ORCO AND r.Activo = 1
        WHERE i.Activo = 1 AND ISNULL(r.CompraDirecta,0) = 0
          AND (
              SELECT COUNT(DISTINCT c.FKIdProveedor_SIS)
              FROM ORCO.Cotizacion c
              WHERE c.FKIdRequisicion_ORCO = r.PKIdRequisicion AND c.Activo = 1
                AND NOT EXISTS (
                    SELECT 1
                    FROM ORCO.RequisicionDetalle rd
                    WHERE rd.FKIdRequisicion_ORCO = r.PKIdRequisicion AND rd.Activo = 1
                      AND NOT EXISTS (
                          SELECT 1 FROM ORCO.CotizacionDetalle cd
                          WHERE cd.FKIdCotizacion_ORCO = c.PKIdCotizacion
                            AND cd.FKIdRequisicionDetalle_ORCO = rd.PKIdRequisicionDetalle
                            AND cd.Activo = 1 AND cd.PrecioUnitario > 0
                      )
                )
          ) < 3
    )
        THROW 51008, 'La suficiencia requiere tres cotizaciones completas de proveedores distintos o compra directa autorizada.', 1;
END;
GO

CREATE OR ALTER TRIGGER PRES.TR_AutorizacionSuficiencia_ControlFlujo
ON PRES.AutorizacionSuficiencia
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted WHERE Estatus NOT IN (1,2,3))
        THROW 51011, 'El estatus de la autorizacion de suficiencia no es valido.', 1;

    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN deleted d ON d.PKIdAutorizacionSuficiencia=i.PKIdAutorizacionSuficiencia
        WHERE NOT (i.Estatus=d.Estatus OR (d.Estatus=1 AND i.Estatus IN (2,3)) OR (d.Estatus=2 AND i.Estatus=3))
    )
        THROW 51011, 'La transicion de la autorizacion de suficiencia no esta permitida.', 1;

    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN deleted d ON d.PKIdAutorizacionSuficiencia=i.PKIdAutorizacionSuficiencia
        WHERE (i.Activo=0 OR i.Estatus=3)
          AND EXISTS (SELECT 1 FROM PRES.Contrato c WHERE c.FKIdAutorizacionSuficiencia_PRES=i.PKIdAutorizacionSuficiencia AND c.Activo=1)
    )
        THROW 51011, 'El contrato vigente debe cancelarse o eliminarse antes de regresar a la autorizacion.', 1;

    UPDATE ss
       SET Estatus = CASE WHEN i.Activo=0 OR i.Estatus=3 THEN 1 WHEN i.Estatus=1 THEN 2 ELSE 3 END,
           FechaModificacion=SYSDATETIME(),
           UsuarioModificacion=i.UsuarioModificacion
    FROM PRES.SolicitudSuficiencia ss
    JOIN inserted i ON i.FKIdSolicitudSuficiencia_PRES=ss.PKIdSolicitudSuficiencia
    WHERE ss.Activo=1;
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
        JOIN PRES.SolicitudSuficiencia ss
          ON ss.PKIdSolicitudSuficiencia = i.FKIdSolicitudSuficiencia_PRES AND ss.Activo = 1
        JOIN ORCO.RequisicionDetalle rd
          ON rd.PKIdRequisicionDetalle = i.FKIdRequisicionDetalle_ORCO AND rd.Activo = 1
        JOIN ALMA.TipoBien tb
          ON tb.PKIdTipoBien = rd.FKIdTipoBien_ALMA AND tb.Activo = 1
        LEFT JOIN ORCO.RequisicionPartida rp
          ON rp.FKIdRequisicion_ORCO = ss.FKIdRequisicion_ORCO
         AND rp.FKIdPartida_CONTA = tb.FKIdPartida_CONTA AND rp.Activo = 1
        WHERE rd.FKIdRequisicion_ORCO <> ss.FKIdRequisicion_ORCO
           OR rp.PKIdRequisicionPartida IS NULL
           OR rp.FKIdEgresoAutorizado_PRES IS NULL
           OR i.FKIdEmpresa_SIS <> ss.FKIdEmpresa_SIS
    )
        THROW 51009, 'El detalle no pertenece a la requisicion o no tiene posicion presupuestal.', 1;

    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN PRES.SolicitudSuficiencia ss
          ON ss.PKIdSolicitudSuficiencia = i.FKIdSolicitudSuficiencia_PRES
        WHERE i.Activo = 1 AND ss.Estatus <> 1
    )
        THROW 51009, 'Solo se pueden modificar detalles de solicitudes en borrador.', 1;

    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN PRES.SolicitudSuficiencia ss
          ON ss.PKIdSolicitudSuficiencia = i.FKIdSolicitudSuficiencia_PRES
        WHERE i.Activo = 1 AND (
            ISNULL(i.Enero,0)+ISNULL(i.Febrero,0)+ISNULL(i.Marzo,0)+ISNULL(i.Abril,0)+
            ISNULL(i.Mayo,0)+ISNULL(i.Junio,0)+ISNULL(i.Julio,0)+ISNULL(i.Agosto,0)+
            ISNULL(i.Septiembre,0)+ISNULL(i.Octubre,0)+ISNULL(i.Noviembre,0)+ISNULL(i.Diciembre,0) <= 0
            OR ISNULL(i.Enero,0)<0 OR ISNULL(i.Febrero,0)<0 OR ISNULL(i.Marzo,0)<0 OR ISNULL(i.Abril,0)<0
            OR ISNULL(i.Mayo,0)<0 OR ISNULL(i.Junio,0)<0 OR ISNULL(i.Julio,0)<0 OR ISNULL(i.Agosto,0)<0
            OR ISNULL(i.Septiembre,0)<0 OR ISNULL(i.Octubre,0)<0 OR ISNULL(i.Noviembre,0)<0 OR ISNULL(i.Diciembre,0)<0
            OR (MONTH(ss.FechaSolicitud)>1 AND ISNULL(i.Enero,0)<>0)
            OR (MONTH(ss.FechaSolicitud)>2 AND ISNULL(i.Febrero,0)<>0)
            OR (MONTH(ss.FechaSolicitud)>3 AND ISNULL(i.Marzo,0)<>0)
            OR (MONTH(ss.FechaSolicitud)>4 AND ISNULL(i.Abril,0)<>0)
            OR (MONTH(ss.FechaSolicitud)>5 AND ISNULL(i.Mayo,0)<>0)
            OR (MONTH(ss.FechaSolicitud)>6 AND ISNULL(i.Junio,0)<>0)
            OR (MONTH(ss.FechaSolicitud)>7 AND ISNULL(i.Julio,0)<>0)
            OR (MONTH(ss.FechaSolicitud)>8 AND ISNULL(i.Agosto,0)<>0)
            OR (MONTH(ss.FechaSolicitud)>9 AND ISNULL(i.Septiembre,0)<>0)
            OR (MONTH(ss.FechaSolicitud)>10 AND ISNULL(i.Octubre,0)<>0)
            OR (MONTH(ss.FechaSolicitud)>11 AND ISNULL(i.Noviembre,0)<>0)
        )
    )
        THROW 51009, 'El detalle debe tener importe positivo y no puede afectar meses anteriores a la solicitud.', 1;

    UPDATE sd
       SET FKIdPartida_CONTA = tb.FKIdPartida_CONTA
    FROM PRES.SolicitudSuficienciaDetalle sd
    JOIN inserted i ON i.PKIdSolicitudSuficienciaDetalle = sd.PKIdSolicitudSuficienciaDetalle
    JOIN ORCO.RequisicionDetalle rd ON rd.PKIdRequisicionDetalle = i.FKIdRequisicionDetalle_ORCO
    JOIN ALMA.TipoBien tb ON tb.PKIdTipoBien = rd.FKIdTipoBien_ALMA;

    ;WITH Solicitudes AS (
        SELECT DISTINCT FKIdSolicitudSuficiencia_PRES FROM inserted WHERE Activo = 1
    ), Solicitado AS (
        SELECT sd.FKIdSolicitudSuficiencia_PRES, rp.FKIdEgresoAutorizado_PRES,
               SUM(ISNULL(sd.Enero,0)) Enero, SUM(ISNULL(sd.Febrero,0)) Febrero,
               SUM(ISNULL(sd.Marzo,0)) Marzo, SUM(ISNULL(sd.Abril,0)) Abril,
               SUM(ISNULL(sd.Mayo,0)) Mayo, SUM(ISNULL(sd.Junio,0)) Junio,
               SUM(ISNULL(sd.Julio,0)) Julio, SUM(ISNULL(sd.Agosto,0)) Agosto,
               SUM(ISNULL(sd.Septiembre,0)) Septiembre, SUM(ISNULL(sd.Octubre,0)) Octubre,
               SUM(ISNULL(sd.Noviembre,0)) Noviembre, SUM(ISNULL(sd.Diciembre,0)) Diciembre
        FROM Solicitudes s
        JOIN PRES.SolicitudSuficiencia ss ON ss.PKIdSolicitudSuficiencia=s.FKIdSolicitudSuficiencia_PRES
        JOIN PRES.SolicitudSuficienciaDetalle sd ON sd.FKIdSolicitudSuficiencia_PRES=ss.PKIdSolicitudSuficiencia AND sd.Activo=1
        JOIN ORCO.RequisicionPartida rp ON rp.FKIdRequisicion_ORCO=ss.FKIdRequisicion_ORCO
             AND rp.FKIdPartida_CONTA=sd.FKIdPartida_CONTA AND rp.Activo=1
        GROUP BY sd.FKIdSolicitudSuficiencia_PRES, rp.FKIdEgresoAutorizado_PRES
    )
    SELECT 1 AS Dummy INTO #Sobregiro
    FROM Solicitado s
    LEFT JOIN PRES.Vw_EgresoDisponible d ON d.PKIdEgresoAutorizado=s.FKIdEgresoAutorizado_PRES
    WHERE d.PKIdEgresoAutorizado IS NULL
       OR s.Enero>ISNULL(d.Enero,0) OR s.Febrero>ISNULL(d.Febrero,0)
       OR s.Marzo>ISNULL(d.Marzo,0) OR s.Abril>ISNULL(d.Abril,0)
       OR s.Mayo>ISNULL(d.Mayo,0) OR s.Junio>ISNULL(d.Junio,0)
       OR s.Julio>ISNULL(d.Julio,0) OR s.Agosto>ISNULL(d.Agosto,0)
       OR s.Septiembre>ISNULL(d.Septiembre,0) OR s.Octubre>ISNULL(d.Octubre,0)
       OR s.Noviembre>ISNULL(d.Noviembre,0) OR s.Diciembre>ISNULL(d.Diciembre,0);

    IF EXISTS (SELECT 1 FROM #Sobregiro)
        THROW 51010, 'La solicitud de suficiencia sobregira el presupuesto disponible de uno o mas meses.', 1;
END;
GO

PRINT N'Fix de suficiencia y matrices aplicado correctamente.';
GO
