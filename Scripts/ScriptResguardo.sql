USE [GestionEmpresarial];
GO

IF OBJECT_ID(N'ALMA.Resguardo', N'U') IS NULL
BEGIN
    CREATE TABLE ALMA.Resguardo (
        PKIdResguardo INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Resguardo PRIMARY KEY,
        Folio NVARCHAR(30) NOT NULL,
        FKIdEmpresa_SIS INT NOT NULL,
        FKIdArea_SIS INT NULL,
        FKIdPersona_NOM INT NOT NULL,
        FechaResguardo DATE NOT NULL,
        Observaciones NVARCHAR(1000) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Resguardo_Activo DEFAULT(1),
        FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Resguardo_FechaCreacion DEFAULT(SYSDATETIME()),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2(0) NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT UQ_Resguardo_Folio UNIQUE(Folio),
        CONSTRAINT FK_Resguardo_Empresa FOREIGN KEY(FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
        CONSTRAINT FK_Resguardo_Area FOREIGN KEY(FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
        CONSTRAINT FK_Resguardo_Persona FOREIGN KEY(FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona)
    );
END
GO

IF OBJECT_ID(N'ALMA.ResguardoDetalle', N'U') IS NULL
BEGIN
    CREATE TABLE ALMA.ResguardoDetalle (
        PKIdResguardoDetalle INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ResguardoDetalle PRIMARY KEY,
        FKIdResguardo_ALMA INT NOT NULL,
        FKIdBien_ALMA INT NOT NULL,
        Consecutivo INT NOT NULL,
        FechaAsignacion DATETIME2(0) NOT NULL CONSTRAINT DF_ResguardoDetalle_FechaAsignacion DEFAULT(SYSDATETIME()),
        FechaLiberacion DATETIME2(0) NULL,
        ImprimeEtiqueta BIT NOT NULL CONSTRAINT DF_ResguardoDetalle_ImprimeEtiqueta DEFAULT(1),
        FKIdEstadoBien_ALMA INT NULL,
        Observaciones NVARCHAR(1000) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_ResguardoDetalle_Activo DEFAULT(1),
        FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_ResguardoDetalle_FechaCreacion DEFAULT(SYSDATETIME()),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2(0) NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT FK_ResguardoDetalle_Resguardo FOREIGN KEY(FKIdResguardo_ALMA) REFERENCES ALMA.Resguardo(PKIdResguardo),
        CONSTRAINT FK_ResguardoDetalle_Bien FOREIGN KEY(FKIdBien_ALMA) REFERENCES ALMA.Bien(PKIdBien),
        CONSTRAINT FK_ResguardoDetalle_EstadoBien FOREIGN KEY(FKIdEstadoBien_ALMA) REFERENCES ALMA.EstadoBien(PKIdEstadoBien)
    );
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'UX_ResguardoDetalle_BienActivo'
      AND object_id = OBJECT_ID(N'ALMA.ResguardoDetalle')
)
BEGIN
    CREATE UNIQUE INDEX UX_ResguardoDetalle_BienActivo
    ON ALMA.ResguardoDetalle(FKIdBien_ALMA)
    WHERE Activo = 1;
END
GO

IF OBJECT_ID(N'ALMA.ResguardoMovimiento', N'U') IS NULL
BEGIN
    CREATE TABLE ALMA.ResguardoMovimiento (
        PKIdResguardoMovimiento INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ResguardoMovimiento PRIMARY KEY,
        FKIdResguardoDetalle_ALMA INT NULL,
        FKIdBien_ALMA INT NOT NULL,
        FKIdResguardoOrigen_ALMA INT NULL,
        FKIdResguardoDestino_ALMA INT NULL,
        TipoMovimiento NVARCHAR(30) NOT NULL,
        FechaMovimiento DATETIME2(0) NOT NULL CONSTRAINT DF_ResguardoMovimiento_Fecha DEFAULT(SYSDATETIME()),
        Observaciones NVARCHAR(1000) NULL,
        UsuarioCreacion INT NOT NULL,
        CONSTRAINT CK_ResguardoMovimiento_Tipo CHECK (TipoMovimiento IN (N'ASIGNACION', N'TRASPASO', N'DEVOLUCION', N'BAJA')),
        CONSTRAINT FK_ResguardoMovimiento_Detalle FOREIGN KEY(FKIdResguardoDetalle_ALMA) REFERENCES ALMA.ResguardoDetalle(PKIdResguardoDetalle),
        CONSTRAINT FK_ResguardoMovimiento_Bien FOREIGN KEY(FKIdBien_ALMA) REFERENCES ALMA.Bien(PKIdBien)
    );
END
GO

CREATE OR ALTER VIEW ALMA.Vw_Resguardo AS
SELECT
    r.PKIdResguardo,
    r.Folio,
    r.FKIdEmpresa_SIS,
    e.Nombre AS EmpresaNombre,
    r.FKIdArea_SIS,
    a.Clave AS AreaClave,
    a.Nombre AS AreaNombre,
    r.FKIdPersona_NOM,
    p.Clave AS PersonaClave,
    LTRIM(RTRIM(CONCAT(ISNULL(p.Nombre, ''), ' ', ISNULL(p.Paterno, ''), ' ', ISNULL(p.Materno, '')))) AS PersonaNombre,
    r.FechaResguardo,
    r.Observaciones,
    COUNT(rd.PKIdResguardoDetalle) AS TotalBienes,
    SUM(ISNULL(b.ValorActual, 0)) AS ValorActualResguardado,
    r.Activo,
    r.FechaCreacion,
    r.UsuarioCreacion,
    r.FechaModificacion,
    r.UsuarioModificacion
FROM ALMA.Resguardo r
INNER JOIN SIS.Empresa e ON r.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN SIS.Area a ON r.FKIdArea_SIS = a.PKIdArea
INNER JOIN NOM.Persona p ON r.FKIdPersona_NOM = p.PKIdPersona
LEFT JOIN ALMA.ResguardoDetalle rd ON r.PKIdResguardo = rd.FKIdResguardo_ALMA AND rd.Activo = 1
LEFT JOIN ALMA.Bien b ON rd.FKIdBien_ALMA = b.PKIdBien AND b.Activo = 1
GROUP BY
    r.PKIdResguardo, r.Folio, r.FKIdEmpresa_SIS, e.Nombre,
    r.FKIdArea_SIS, a.Clave, a.Nombre,
    r.FKIdPersona_NOM, p.Clave, p.Nombre, p.Paterno, p.Materno,
    r.FechaResguardo, r.Observaciones, r.Activo,
    r.FechaCreacion, r.UsuarioCreacion, r.FechaModificacion, r.UsuarioModificacion;
GO

CREATE OR ALTER VIEW ALMA.Vw_ResguardoDetalle AS
SELECT
    rd.PKIdResguardoDetalle,
    rd.FKIdResguardo_ALMA,
    r.Folio,
    r.FKIdEmpresa_SIS,
    r.FKIdArea_SIS,
    a.Nombre AS AreaNombre,
    r.FKIdPersona_NOM,
    LTRIM(RTRIM(CONCAT(ISNULL(p.Nombre, ''), ' ', ISNULL(p.Paterno, ''), ' ', ISNULL(p.Materno, '')))) AS PersonaNombre,
    rd.FKIdBien_ALMA,
    b.Clave AS BienClave,
    b.ClaveAnt AS BienClaveAnterior,
    b.Descripcion AS BienDescripcion,
    b.Modelo,
    b.Serie,
    b.Factura,
    b.Costo,
    b.ValorActual,
    b.FKIdTipoBien_ALMA,
    tb.CodigoClave AS TipoBienCodigoClave,
    tb.Descripcion AS TipoBienDescripcion,
    rd.Consecutivo,
    rd.FechaAsignacion,
    rd.FechaLiberacion,
    rd.ImprimeEtiqueta,
    rd.FKIdEstadoBien_ALMA,
    eb.Descripcion_Corta AS EstadoBienDescripcion,
    rd.Observaciones,
    rd.Activo,
    rd.FechaCreacion,
    rd.UsuarioCreacion,
    rd.FechaModificacion,
    rd.UsuarioModificacion
FROM ALMA.ResguardoDetalle rd
INNER JOIN ALMA.Resguardo r ON rd.FKIdResguardo_ALMA = r.PKIdResguardo
INNER JOIN ALMA.Bien b ON rd.FKIdBien_ALMA = b.PKIdBien
LEFT JOIN SIS.Area a ON r.FKIdArea_SIS = a.PKIdArea
LEFT JOIN NOM.Persona p ON r.FKIdPersona_NOM = p.PKIdPersona
LEFT JOIN ALMA.TipoBien tb ON b.FKIdTipoBien_ALMA = tb.PKIdTipoBien
LEFT JOIN ALMA.EstadoBien eb ON rd.FKIdEstadoBien_ALMA = eb.PKIdEstadoBien;
GO