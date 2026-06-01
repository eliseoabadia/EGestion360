SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [ORCO].[SP_ReportePAAAS]
    @PKIdPAAAS INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.PKIdPAAAS,
        p.AnioClave,
        p.AreaNombre,
        p.ResponsableCompleto,
        p.ProgramaClave,
        p.ProgramaDescripcion,
        p.FuenteFinanciamientoClave,
        p.FuenteFinanciamientoDescripcion,
        p.Descripcion,
        p.Observaciones,
        p.Fecha,
        pp.PKIdPAAASPartida,
        pp.PartidaClave,
        pp.PartidaDescripcion,
        d.PKIdPAAASDetalle,
        d.TipoBienCodigoClave,
        d.TipoBienDescripcion,
        d.UnidadMedida,
        d.Cantidad,
        d.LugarEntrega,
        d.Observaciones AS DetalleObservaciones
    FROM ORCO.Vw_PAAAS p
    LEFT JOIN ORCO.Vw_PAAASPartida pp
        ON pp.FKIdPAAAS_ORCO = p.PKIdPAAAS
    LEFT JOIN ORCO.Vw_PAAASDetalle d
        ON d.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida
    WHERE p.PKIdPAAAS = @PKIdPAAAS
    ORDER BY pp.PartidaClave, d.TipoBienDescripcion;
END
GO
