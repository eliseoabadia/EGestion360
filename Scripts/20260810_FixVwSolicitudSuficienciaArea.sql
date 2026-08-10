SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

ALTER VIEW PRES.Vw_SolicitudSuficiencia
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
    CASE ss.Estatus
        WHEN 1 THEN 'Borrador'
        WHEN 2 THEN 'Enviada'
        WHEN 3 THEN 'Autorizada'
        WHEN 4 THEN 'Rechazada'
        ELSE 'Sin definir'
    END AS EstatusDescripcion,
    ss.Activo,
    ss.FechaCreacion,
    ss.UsuarioCreacion,
    ss.FechaModificacion,
    ss.UsuarioModificacion
FROM PRES.SolicitudSuficiencia ss
LEFT JOIN SIS.Empresa emp
    ON ss.FKIdEmpresa_SIS = emp.PKIdEmpresa
   AND emp.Activo = 1
LEFT JOIN ORCO.Requisicion req
    ON ss.FKIdRequisicion_ORCO = req.PKIdRequisicion
   AND req.Activo = 1
WHERE ss.Activo = 1;
GO
