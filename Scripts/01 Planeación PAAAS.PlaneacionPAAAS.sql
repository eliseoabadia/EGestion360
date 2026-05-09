-- =============================================
-- SCRIPT DE CREACIÓN DE TABLAS PARA PROCESO DE PLANEACIÓN
-- Base de datos: GestionEmpresarial
-- Módulo: Planeación (PAAAS, Estudios de Mercado, Cotizaciones)
-- Fecha: 2026-05-06
-- =============================================

USE [GestionEmpresarial];
GO

-- =============================================
-- ELIMINAR TABLAS EN ORDEN INVERSO A LAS DEPENDENCIAS
-- =============================================

-- Vista
DROP VIEW IF EXISTS ORCO.VW_ReporteBienesProgramaAnual;
GO



-- Tablas nuevas
DROP TABLE IF EXISTS ORCO.CotizacionDetalle;
DROP TABLE IF EXISTS ORCO.SolicitudCotizacion;
DROP TABLE IF EXISTS ORCO.EstudioMercadoDetalle;
DROP TABLE IF EXISTS ORCO.EstudioMercado;
DROP TABLE IF EXISTS ORCO.PAAASDetalle;
--DROP TABLE IF EXISTS ORCO.DetallePAAAS;
DROP TABLE IF EXISTS ORCO.PAAASPartida;
DROP TABLE IF EXISTS ORCO.PAAAS;
GO

-- =============================================
-- TABLA 1: ORCO.PAAAS (Programa Anual de Adquisiciones)
-- UN REGISTRO POR ÁREA Y AÑO
-- =============================================
CREATE TABLE ORCO.PAAAS (
    PKIdPAAAS INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdAnio_SIS INT NOT NULL,
    FKIdArea_SIS INT NOT NULL,
    FKIdPersona_NOM INT NOT NULL,               -- Responsable del programa
    Descripcion NVARCHAR(100) NOT NULL,
    Observaciones NVARCHAR(1000) NULL,
    Fecha DATETIME NOT NULL,
    FKIdProyecto_ORCO INT NULL,
    FKIdPrograma_PRES INT NULL,
    FKIdFuenteFinanciamiento_PRES INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PAAAS_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_PAAAS_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PAAAS PRIMARY KEY (PKIdPAAAS),
    CONSTRAINT FK_PAAAS_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_PAAAS_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
    CONSTRAINT FK_PAAAS_Area FOREIGN KEY (FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_PAAAS_Persona FOREIGN KEY (FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_PAAAS_Proyecto FOREIGN KEY (FKIdProyecto_ORCO) REFERENCES ORCO.Proyecto(PKIdProyecto),
    CONSTRAINT FK_PAAAS_Programa FOREIGN KEY (FKIdPrograma_PRES) REFERENCES PRES.Programa(PKIdPrograma),
    CONSTRAINT FK_PAAAS_FuenteFinanciamiento FOREIGN KEY (FKIdFuenteFinanciamiento_PRES) REFERENCES PRES.FuenteFinanciamiento(PKIdFuenteFinanciamiento),
    CONSTRAINT UQ_PAAAS_Area_Anio UNIQUE (FKIdArea_SIS, FKIdAnio_SIS)
);
GO

-- Índice para búsquedas por área y año
CREATE INDEX IX_PAAAS_Area_Anio ON ORCO.PAAAS (FKIdArea_SIS, FKIdAnio_SIS) WHERE Activo = 1;
GO

-- =============================================
-- TABLA 2: ORCO.PAAASPartida (Partidas asociadas al PAAAS)
-- TABLA INTERMEDIA PARA MÚLTIPLES PARTIDAS
-- =============================================
CREATE TABLE ORCO.PAAASPartida (
    PKIdPAAASPartida INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdPAAAS_ORCO INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    Observaciones NVARCHAR(1000) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PAAASPartida_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_PAAASPartida_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PAAASPartida PRIMARY KEY (PKIdPAAASPartida),
    CONSTRAINT FK_PAAASPartida_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_PAAASPartida_PAAAS FOREIGN KEY (FKIdPAAAS_ORCO) REFERENCES ORCO.PAAAS(PKIdPAAAS),
    CONSTRAINT FK_PAAASPartida_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida)
);
GO

-- Índice para búsquedas por PAAAS
CREATE INDEX IX_PAAASPartida_PAAAS ON ORCO.PAAASPartida (FKIdPAAAS_ORCO) WHERE Activo = 1;
GO

-- =============================================
-- TABLA 3: ORCO.PAAASDetalle (Bienes solicitados por partida)
-- =============================================
CREATE TABLE ORCO.PAAASDetalle (
    PKIdPAAASDetalle INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdPAAASPartida_ORCO INT NOT NULL,        -- Referencia a la partida dentro del PAAAS
    FKIdTipoBien_ALMA INT NOT NULL,
    FKIdUnidades_ALMA INT NULL,
    Cantidad NUMERIC(8,2) NOT NULL,
    Observaciones NVARCHAR(MAX) NOT NULL,
    LugarEntrega VARCHAR(200) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_PAAASDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_PAAASDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_PAAASDetalle PRIMARY KEY (PKIdPAAASDetalle),
    CONSTRAINT FK_PAAASDetalle_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_PAAASDetalle_PAAASPartida FOREIGN KEY (FKIdPAAASPartida_ORCO) REFERENCES ORCO.PAAASPartida(PKIdPAAASPartida),
    CONSTRAINT FK_PAAASDetalle_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
    CONSTRAINT FK_PAAASDetalle_Unidades FOREIGN KEY (FKIdUnidades_ALMA) REFERENCES ALMA.Unidades(PKIdUnidades)
);
GO

-- Índices para búsquedas frecuentes
CREATE INDEX IX_PAAASDetalle_PAAASPartida ON ORCO.PAAASDetalle (FKIdPAAASPartida_ORCO) WHERE Activo = 1;
CREATE INDEX IX_PAAASDetalle_TipoBien ON ORCO.PAAASDetalle (FKIdTipoBien_ALMA) WHERE Activo = 1;
GO

-- =============================================
-- TABLA 4: ORCO.EstudioMercado (Evento de cotización)
-- =============================================
CREATE TABLE ORCO.EstudioMercado (
    PKIdEstudioMercado INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdAnio_SIS INT NOT NULL,
    Nombre VARCHAR(80) NOT NULL,
    Descripcion NVARCHAR(500) NULL,
    FechaSolicitud DATETIME NOT NULL,
    FechaCierre DATETIME NULL,
    FKIdResponsable_NOM INT NOT NULL,
    Estatus INT NOT NULL CONSTRAINT DF_EstudioMercado_Estatus DEFAULT (1), -- 1: Borrador, 2: En proceso, 3: Completado, 4: Cancelado
    Activo BIT NOT NULL CONSTRAINT DF_EstudioMercado_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_EstudioMercado_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EstudioMercado PRIMARY KEY (PKIdEstudioMercado),
    CONSTRAINT FK_EstudioMercado_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_EstudioMercado_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
    CONSTRAINT FK_EstudioMercado_Responsable FOREIGN KEY (FKIdResponsable_NOM) REFERENCES NOM.Persona(PKIdPersona)
);
GO

-- Índices para búsquedas
CREATE INDEX IX_EstudioMercado_Anio ON ORCO.EstudioMercado (FKIdAnio_SIS, Estatus) WHERE Activo = 1;
CREATE INDEX IX_EstudioMercado_Responsable ON ORCO.EstudioMercado (FKIdResponsable_NOM) WHERE Activo = 1;
GO

-- =============================================
-- TABLA 5: ORCO.EstudioMercadoDetalle (Bienes a cotizar en el estudio)
-- =============================================
CREATE TABLE ORCO.EstudioMercadoDetalle (
    PKIdEstudioMercadoDetalle INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdEstudioMercado_ORCO INT NOT NULL,
    FKIdPAAASDetalle_ORCO INT NOT NULL,        -- Referencia al bien del programa anual
    FKIdTipoBien_ALMA INT NOT NULL,
    Cantidad NUMERIC(8,2) NOT NULL,
    Observaciones NVARCHAR(MAX) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EstudioMercadoDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_EstudioMercadoDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EstudioMercadoDetalle PRIMARY KEY (PKIdEstudioMercadoDetalle),
    CONSTRAINT FK_EstudioMercadoDetalle_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_EstudioMercadoDetalle_EstudioMercado FOREIGN KEY (FKIdEstudioMercado_ORCO) REFERENCES ORCO.EstudioMercado(PKIdEstudioMercado),
    CONSTRAINT FK_EstudioMercadoDetalle_PAAASDetalle FOREIGN KEY (FKIdPAAASDetalle_ORCO) REFERENCES ORCO.PAAASDetalle(PKIdPAAASDetalle),
    CONSTRAINT FK_EstudioMercadoDetalle_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien)
);
GO

-- Índices para búsquedas
CREATE INDEX IX_EstudioMercadoDetalle_Estudio ON ORCO.EstudioMercadoDetalle (FKIdEstudioMercado_ORCO) WHERE Activo = 1;
CREATE INDEX IX_EstudioMercadoDetalle_PAAASDetalle ON ORCO.EstudioMercadoDetalle (FKIdPAAASDetalle_ORCO) WHERE Activo = 1;
GO

-- =============================================
-- TABLA 6: ORCO.SolicitudCotizacion (Solicitudes a proveedores)
-- =============================================
CREATE TABLE ORCO.SolicitudCotizacion (
    PKIdSolicitudCotizacion INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdEstudioMercado_ORCO INT NOT NULL,
    FKIdProveedor_SIS INT NOT NULL,
    FechaSolicitud DATETIME NOT NULL,
    FechaCompromisoEntrega DATETIME NULL,
    Comentarios TEXT NULL,
    FL_Documento NVARCHAR(1000) NULL,
    Estatus INT NOT NULL CONSTRAINT DF_SolicitudCotizacion_Estatus DEFAULT (1), -- 1: Enviada, 2: Respuesta recibida, 3: No respondió
    Activo BIT NOT NULL CONSTRAINT DF_SolicitudCotizacion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_SolicitudCotizacion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_SolicitudCotizacion PRIMARY KEY (PKIdSolicitudCotizacion),
    CONSTRAINT FK_SolicitudCotizacion_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_SolicitudCotizacion_EstudioMercado FOREIGN KEY (FKIdEstudioMercado_ORCO) REFERENCES ORCO.EstudioMercado(PKIdEstudioMercado),
    CONSTRAINT FK_SolicitudCotizacion_Proveedor FOREIGN KEY (FKIdProveedor_SIS) REFERENCES SIS.Proveedor(PKIdProveedor)
);
GO

-- Índices para búsquedas
CREATE INDEX IX_SolicitudCotizacion_Estudio ON ORCO.SolicitudCotizacion (FKIdEstudioMercado_ORCO) WHERE Activo = 1;
CREATE INDEX IX_SolicitudCotizacion_Proveedor ON ORCO.SolicitudCotizacion (FKIdProveedor_SIS) WHERE Activo = 1;
CREATE INDEX IX_SolicitudCotizacion_Estatus ON ORCO.SolicitudCotizacion (Estatus) WHERE Activo = 1;
GO

-- =============================================
-- TABLA 7: ORCO.CotizacionDetalle (Precios por proveedor y bien)
-- =============================================
CREATE TABLE ORCO.CotizacionDetalle (
    PKIdCotizacionDetalle INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdSolicitudCotizacion_ORCO INT NOT NULL,
    FKIdEstudioMercadoDetalle_ORCO INT NOT NULL,
    PrecioUnitario [dbo].[dmoney] NULL,
    TiempoEntregaDias INT NULL,
    Condiciones NVARCHAR(500) NULL,
    FechaRespuesta DATETIME NULL,
    Activo BIT NOT NULL CONSTRAINT DF_CotizacionDetalle_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_CotizacionDetalle_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_CotizacionDetalle PRIMARY KEY (PKIdCotizacionDetalle),
    CONSTRAINT FK_CotizacionDetalle_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_CotizacionDetalle_SolicitudCotizacion FOREIGN KEY (FKIdSolicitudCotizacion_ORCO) REFERENCES ORCO.SolicitudCotizacion(PKIdSolicitudCotizacion),
    CONSTRAINT FK_CotizacionDetalle_EstudioMercadoDetalle FOREIGN KEY (FKIdEstudioMercadoDetalle_ORCO) REFERENCES ORCO.EstudioMercadoDetalle(PKIdEstudioMercadoDetalle)
);
GO

-- Índices para búsquedas y análisis de precios
CREATE INDEX IX_CotizacionDetalle_Solicitud ON ORCO.CotizacionDetalle (FKIdSolicitudCotizacion_ORCO) WHERE Activo = 1;
CREATE INDEX IX_CotizacionDetalle_EstudioDetalle ON ORCO.CotizacionDetalle (FKIdEstudioMercadoDetalle_ORCO) WHERE Activo = 1;
CREATE INDEX IX_CotizacionDetalle_Precio ON ORCO.CotizacionDetalle (PrecioUnitario) WHERE Activo = 1;
GO

-- =============================================
-- VISTA: REPORTE DE BIENES DEL PROGRAMA ANUAL
-- =============================================
CREATE VIEW ORCO.VW_ReporteBienesProgramaAnual AS
WITH 
-- 1. Resumen de áreas solicitantes por bien
AreasPorBien AS (
    SELECT 
        dp.FKIdTipoBien_ALMA,
        COUNT(DISTINCT p.FKIdArea_SIS) AS TotalAreasSolicitantes
    FROM ORCO.PAAASDetalle dp
    INNER JOIN ORCO.PAAASPartida pp ON dp.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida
    INNER JOIN ORCO.PAAAS p ON pp.FKIdPAAAS_ORCO = p.PKIdPAAAS
    WHERE dp.Activo = 1 AND pp.Activo = 1 AND p.Activo = 1
    GROUP BY dp.FKIdTipoBien_ALMA
),

-- 2. Cantidad total solicitada por bien
CantidadTotalPorBien AS (
    SELECT 
        FKIdTipoBien_ALMA,
        SUM(Cantidad) AS CantidadTotalSolicitada
    FROM ORCO.PAAASDetalle
    WHERE Activo = 1
    GROUP BY FKIdTipoBien_ALMA
),

-- 3. Resumen de cotizaciones por bien
CotizacionesPorBien AS (
    SELECT 
        emd.FKIdTipoBien_ALMA,
        COUNT(DISTINCT sc.FKIdProveedor_SIS) AS TotalProveedoresCotizaron,
        COUNT(cd.PKIdCotizacionDetalle) AS TotalCotizacionesRecibidas,
        MIN(cd.PrecioUnitario) AS PrecioMinimo,
        MAX(cd.PrecioUnitario) AS PrecioMaximo,
        AVG(CAST(cd.PrecioUnitario AS DECIMAL(20,4))) AS PrecioPromedio,
        MAX(cd.FechaRespuesta) AS UltimaCotizacion
    FROM ORCO.EstudioMercadoDetalle emd
    INNER JOIN ORCO.CotizacionDetalle cd ON emd.PKIdEstudioMercadoDetalle = cd.FKIdEstudioMercadoDetalle_ORCO
    INNER JOIN ORCO.SolicitudCotizacion sc ON cd.FKIdSolicitudCotizacion_ORCO = sc.PKIdSolicitudCotizacion
    WHERE emd.Activo = 1 AND cd.Activo = 1 AND sc.Activo = 1
    GROUP BY emd.FKIdTipoBien_ALMA
)

-- 4. Vista final consolidada
SELECT 
    tb.PKIdTipoBien,
    tb.Descripcion AS NombreBien,
    tb.CodigoClave AS ClaveBien,
    u.Descripcion AS UnidadMedida,
    
    -- Cantidad de áreas que lo solicitaron
    ISNULL(apb.TotalAreasSolicitantes, 0) AS TotalAreasSolicitantes,
    
    -- Cantidad total de bienes solicitada
    ISNULL(cb.CantidadTotalSolicitada, 0) AS CantidadTotalSolicitada,
    
    -- Estadísticas de cotizaciones
    ISNULL(cpb.TotalProveedoresCotizaron, 0) AS ProveedoresQueCotizaron,
    ISNULL(cpb.TotalCotizacionesRecibidas, 0) AS TotalCotizacionesRecibidas,
    
    -- Precios
    cpb.PrecioMinimo,
    cpb.PrecioMaximo,
    cpb.PrecioPromedio,
    
    -- Fecha de última actualización
    cpb.UltimaCotizacion,
    
    -- Fecha de última modificación del registro del bien
    tb.FechaModificacion AS UltimaActualizacionBien,
    
    -- Indicadores de estado
    CASE 
        WHEN cpb.TotalCotizacionesRecibidas > 0 THEN 'Cotizado'
        WHEN cb.CantidadTotalSolicitada > 0 THEN 'Solicitado sin cotizar'
        ELSE 'Sin actividad'
    END AS Estatus

FROM ALMA.TipoBien tb
LEFT JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades
LEFT JOIN AreasPorBien apb ON tb.PKIdTipoBien = apb.FKIdTipoBien_ALMA
LEFT JOIN CantidadTotalPorBien cb ON tb.PKIdTipoBien = cb.FKIdTipoBien_ALMA
LEFT JOIN CotizacionesPorBien cpb ON tb.PKIdTipoBien = cpb.FKIdTipoBien_ALMA
WHERE tb.Activo = 1;
GO

-- =============================================
-- SCRIPT DE MIGRACIÓN DE DATOS DESDE LA ESTRUCTURA ORIGINAL
-- (BD_PRESUPUESTO)
-- =============================================

-- 1. Migrar PAAAS (agrupando por área y año, eliminando duplicados por partida)
--SET IDENTITY_INSERT ORCO.PAAAS ON;
--INSERT INTO ORCO.PAAAS (
--    PKIdPAAAS, FKIdEmpresa_SIS, FKIdAnio_SIS, FKIdArea_SIS, FKIdPersona_NOM,
--    Descripcion, Observaciones, Fecha, FKIdProyecto_ORCO,
--    FKIdPrograma_PRES, FKIdFuenteFinanciamiento_PRES,
--    Activo, FechaCreacion, UsuarioCreacion
--)
--SELECT DISTINCT
--    p.PK_IdPAAAS,
--    1 AS FKIdEmpresa_SIS,
--    p.FK_IdAnio__SIS,
--    p.FK_IdArea__SIS,
--    p.FK_IdPersona__RHCT,
--    p.Descripcion,
--    p.Observaciones,
--    p.Fecha,
--    p.FK_IdProyecto__ORCO,
--    p.FK_IdPrograma__PRES,
--    p.FK_IdFuenteFinanciamiento__PRES,
--    ISNULL(p.CT_LIVE, 1),
--    ISNULL(p.CT_CreatedDate, GETDATE()),
--    ISNULL(p.CT_CreatedBy, 1)
--FROM BD_PRESUPUESTO.ORCO.PAAAS p
--WHERE NOT EXISTS (
--    SELECT 1 FROM ORCO.PAAAS d 
--    WHERE d.FKIdArea_SIS = p.FK_IdArea__SIS 
--    AND d.FKIdAnio_SIS = p.FK_IdAnio__SIS
--)
--and FK_IdPersona__RHCT in (select PKIdPersona from nom.Persona);
--SET IDENTITY_INSERT ORCO.PAAAS OFF;
--GO

---- 2. Migrar Partidas del PAAAS
--INSERT INTO ORCO.PAAASPartida (
--    FKIdEmpresa_SIS, FKIdPAAAS_ORCO, FKIdPartida_CONTA,
--    Observaciones, Activo, FechaCreacion, UsuarioCreacion
--)
--SELECT DISTINCT
--    1,
--    p.PK_IdPAAAS,
--    p.FK_IdPartida__SIS,
--    NULL,
--    1,
--    GETDATE(),
--    1
--FROM [BD_PRESUPUESTO].ORCO.PAAAS p
--WHERE p.FK_IdPartida__SIS IS NOT NULL;
--GO

---- 3. Migrar PAAASDetalle
--SET IDENTITY_INSERT ORCO.PAAASDetalle ON;
--INSERT INTO ORCO.PAAASDetalle (
--    PKIdPAAASDetalle, FKIdEmpresa_SIS, FKIdPAAASPartida_ORCO, FKIdTipoBien_ALMA,
--    FKIdUnidades_ALMA, Cantidad, Observaciones, LugarEntrega,
--    Activo, FechaCreacion, UsuarioCreacion
--)
--SELECT 
--    d.PK_IdPAAASDetalle,
--    1,
--    pp.PKIdPAAASPartida,
--    d.FK_IdTipoBien__SICOP,
--    d.FK_IdUnidades__ALMA,
--    d.Cantidad,
--    d.Observaciones,
--    d.LugarEntrega,
--    ISNULL(d.CT_LIVE, 1),
--    ISNULL(d.CT_CreatedDate, GETDATE()),
--    ISNULL(d.CT_CreatedBy, 1)
--FROM BD_PRESUPUESTO.ORCO.PAAASDetalle d
--INNER JOIN BD_PRESUPUESTO.ORCO.PAAAS p_orig ON d.FK_IdPAAAS__ORCO = p_orig.PK_IdPAAAS
--INNER JOIN ORCO.PAAAS p_dest ON p_dest.FKIdArea_SIS = p_orig.FK_IdArea__SIS 
--                              AND p_dest.FKIdAnio_SIS = p_orig.FK_IdAnio__SIS
--INNER JOIN ORCO.PAAASPartida pp ON pp.FKIdPAAAS_ORCO = p_dest.PKIdPAAAS
--WHERE NOT EXISTS (SELECT 1 FROM ORCO.PAAASDetalle dest WHERE dest.PKIdPAAASDetalle = d.PK_IdPAAASDetalle);
--SET IDENTITY_INSERT ORCO.PAAASDetalle OFF;
--GO

-- 4. Migrar EstudioMercado
SET IDENTITY_INSERT ORCO.EstudioMercado ON;
INSERT INTO ORCO.EstudioMercado (
    PKIdEstudioMercado, FKIdEmpresa_SIS, FKIdAnio_SIS, Nombre, Descripcion,
    FechaSolicitud, FechaCierre, FKIdResponsable_NOM, Estatus,
    Activo, FechaCreacion, UsuarioCreacion
)
SELECT 
    e.PK_IdEstudioMercado,
    1,
    e.FK_IdAnio,
    e.Nombre,
    NULL,
    e.FechaSolicitud,
    NULL,
    e.CT_CreatedBy,
    3,  -- Completado por defecto
    ISNULL(e.CT_LIVE, 1),
    ISNULL(e.CT_CreatedDate, GETDATE()),
    ISNULL(e.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.EstudioMercado e
WHERE NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercado dest WHERE dest.PKIdEstudioMercado = e.PK_IdEstudioMercado);
SET IDENTITY_INSERT ORCO.EstudioMercado OFF;
GO

-- 5. Migrar EstudioMercadoDetalle
SET IDENTITY_INSERT ORCO.EstudioMercadoDetalle ON;
INSERT INTO ORCO.EstudioMercadoDetalle (
    PKIdEstudioMercadoDetalle, FKIdEmpresa_SIS, FKIdEstudioMercado_ORCO,
    FKIdPAAASDetalle_ORCO, FKIdTipoBien_ALMA, Cantidad, Observaciones,
    Activo, FechaCreacion, UsuarioCreacion
)
SELECT 
    d.PK_IdDet_SolEstudioMercado,
    1,
    d.FK_IdSolEstudioMercado__ORCO,
    d.FK_IdDetallePAAAS__ORCO,
    dp.FKIdTipoBien_ALMA,
    tb.Cantidad_Equivalente,
    NULL,
    1,
    GETDATE(),
    1
FROM BD_PRESUPUESTO.ORCO.Det_SolEstudioMercado d
INNER JOIN ORCO.PAAASDetalle dp ON d.FK_IdDetallePAAAS__ORCO = dp.PKIdPAAASDetalle
INNER JOIN [BD_PRESUPUESTO].SICOP.TipoBien tb ON dp.FKIdTipoBien_ALMA = tb.PK_IdTipoBien
WHERE NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercadoDetalle dest WHERE dest.PKIdEstudioMercadoDetalle = d.PK_IdDet_SolEstudioMercado);
SET IDENTITY_INSERT ORCO.EstudioMercadoDetalle OFF;
GO

-- =============================================
-- PRUEBA DE LA VISTA
-- =============================================
SELECT TOP 100 * FROM ORCO.VW_ReporteBienesProgramaAnual ORDER BY NombreBien;
GO

-- =============================================
-- FIN DEL SCRIPT
-- =============================================