--//ORCO.Requisicion
-- =============================================
-- SCRIPT DE CREACIÓN DE TABLAS PARA REQUISICIONES
-- Base de datos: GestionEmpresarial
-- Optimizado: Solo tablas transaccionales tienen FKIdEmpresa_SIS
-- =============================================

USE [GestionEmpresarial];
GO


-- Eliminar tablas en orden inverso a las dependencias
DROP TABLE IF EXISTS ORCO.RequisicionPartida;
DROP TABLE IF EXISTS ORCO.DetalleRequisicion;
DROP TABLE IF EXISTS ORCO.Requisicion;
DROP TABLE IF EXISTS PRES.EgresoAutorizado;
DROP TABLE IF EXISTS PRES.Suficiencia;
DROP TABLE IF EXISTS PRES.DestinoGasto;
DROP TABLE IF EXISTS PRES.DigitoIdentificador;
DROP TABLE IF EXISTS PRES.TipoGasto;
DROP TABLE IF EXISTS PRES.FuenteFinanciamiento;
DROP TABLE IF EXISTS PRES.Programa;
DROP TABLE IF EXISTS ORCO.ContenedorMultiReq;
DROP TABLE IF EXISTS ORCO.ContenedorReq;
DROP TABLE IF EXISTS ORCO.Proyecto;
DROP TABLE IF EXISTS SIS.Anio;

-- =============================================
-- SCRIPT DE CREACIÓN DE TABLAS PARA REQUISICIONES
-- Base de datos: GestionEmpresarial
-- Optimizado: Sin contenedores, con tabla intermedia para múltiples partidas
-- =============================================

USE [GestionEmpresarial];
GO

-- =============================================
-- 1. SIS.Anio (genérico, sin empresa)
-- =============================================
IF OBJECT_ID('SIS.Anio', 'U') IS NOT NULL DROP TABLE SIS.Anio;
GO
CREATE TABLE SIS.Anio (
    PKIdAnio INT IDENTITY(1,1) NOT NULL,
    Clave INT NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Anio_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Anio_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Anio PRIMARY KEY (PKIdAnio),
    CONSTRAINT FK_Anio_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Anio_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO


-- Migrar años desde la tabla de origen (asumiendo que existe SIS.Anio en origen)
SET IDENTITY_INSERT SIS.Anio ON;

INSERT INTO SIS.Anio (PKIdAnio, Clave, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    a.PK_IdAnio,
    a.Clave,
    ISNULL(a.CT_LIVE, 1),
    ISNULL(a.CT_CreatedDate, GETDATE()),
    ISNULL(a.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.Anio a
WHERE NOT EXISTS (SELECT 1 FROM SIS.Anio d WHERE d.PKIdAnio = a.PK_IdAnio);

SET IDENTITY_INSERT SIS.Anio OFF;

-- =============================================
-- 2. ORCO.Proyecto
-- =============================================
IF OBJECT_ID('ORCO.Proyecto', 'U') IS NOT NULL DROP TABLE ORCO.Proyecto;
GO
CREATE TABLE ORCO.Proyecto (
    PKIdProyecto INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(MAX) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Proyecto_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Proyecto_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Proyecto PRIMARY KEY (PKIdProyecto),
    CONSTRAINT FK_Proyecto_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Proyecto_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT ORCO.Proyecto ON;

INSERT INTO ORCO.Proyecto (PKIdProyecto, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    p.PK_IdProyecto,
    p.Descripcion,
    ISNULL(p.CT_LIVE, 1),
    ISNULL(p.CT_CreatedDate, GETDATE()),
    ISNULL(p.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.Proyecto p
WHERE NOT EXISTS (SELECT 1 FROM ORCO.Proyecto d WHERE d.PKIdProyecto = p.PK_IdProyecto);

SET IDENTITY_INSERT ORCO.Proyecto OFF;
-- =============================================
-- 3. PRES.Programa
-- =============================================
IF OBJECT_ID('PRES.Programa', 'U') IS NOT NULL DROP TABLE PRES.Programa;
GO
CREATE TABLE PRES.Programa (
    PKIdPrograma INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(50) NOT NULL,
    Descripcion NVARCHAR(255) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Programa_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Programa_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Programa PRIMARY KEY (PKIdPrograma),
    CONSTRAINT FK_Programa_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Programa_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT PRES.Programa ON;

INSERT INTO PRES.Programa (PKIdPrograma, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    p.PK_IdPrograma,
    p.Clave,
    p.Descripcion,
    ISNULL(p.CT_LIVE, 1),
    ISNULL(p.CT_CreatedDate, GETDATE()),
    ISNULL(p.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.Programa p
WHERE NOT EXISTS (SELECT 1 FROM PRES.Programa d WHERE d.PKIdPrograma = p.PK_IdPrograma);

SET IDENTITY_INSERT PRES.Programa OFF;
-- =============================================
-- 4. PRES.FuenteFinanciamiento
-- =============================================
IF OBJECT_ID('PRES.FuenteFinanciamiento', 'U') IS NOT NULL DROP TABLE PRES.FuenteFinanciamiento;
GO
CREATE TABLE PRES.FuenteFinanciamiento (
    PKIdFuenteFinanciamiento INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(6) NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_FuenteFinanciamiento_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_FuenteFinanciamiento_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_FuenteFinanciamiento PRIMARY KEY (PKIdFuenteFinanciamiento),
    CONSTRAINT FK_FuenteFinanciamiento_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_FuenteFinanciamiento_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT PRES.FuenteFinanciamiento ON;

INSERT INTO PRES.FuenteFinanciamiento (PKIdFuenteFinanciamiento, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    f.PK_IdFuenteFinanciamiento,
    f.Clave,
    f.Descripcion,
    ISNULL(f.CT_LIVE, 1),
    ISNULL(f.CT_CreatedDate, GETDATE()),
    ISNULL(f.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.FuenteFinanciamiento f
WHERE NOT EXISTS (SELECT 1 FROM PRES.FuenteFinanciamiento d WHERE d.PKIdFuenteFinanciamiento = f.PK_IdFuenteFinanciamiento);

SET IDENTITY_INSERT PRES.FuenteFinanciamiento OFF;
-- =============================================
-- 5. PRES.TipoGasto
-- =============================================
IF OBJECT_ID('PRES.TipoGasto', 'U') IS NOT NULL DROP TABLE PRES.TipoGasto;
GO
CREATE TABLE PRES.TipoGasto (
    PKIdTipoGasto INT IDENTITY(1,1) NOT NULL,
    Clave INT NOT NULL,
    Descripcion NVARCHAR(200) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_TipoGasto_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_TipoGasto_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_TipoGasto PRIMARY KEY (PKIdTipoGasto),
    CONSTRAINT FK_TipoGasto_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_TipoGasto_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT PRES.TipoGasto ON;

INSERT INTO PRES.TipoGasto (PKIdTipoGasto, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    t.PK_IdTG,
    t.Clave,
    t.Descripcion,
    ISNULL(t.CT_LIVE, 1),
    ISNULL(t.CT_CreatedDate, GETDATE()),
    ISNULL(t.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.TipoGasto t
WHERE NOT EXISTS (SELECT 1 FROM PRES.TipoGasto d WHERE d.PKIdTipoGasto = t.PK_IdTG);

SET IDENTITY_INSERT PRES.TipoGasto OFF;
-- =============================================
-- 6. PRES.DigitoIdentificador
-- =============================================
IF OBJECT_ID('PRES.DigitoIdentificador', 'U') IS NOT NULL DROP TABLE PRES.DigitoIdentificador;
GO
CREATE TABLE PRES.DigitoIdentificador (
    PKIdDigitoIdentificador INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(1) NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_DigitoIdentificador_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_DigitoIdentificador_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_DigitoIdentificador PRIMARY KEY (PKIdDigitoIdentificador),
    CONSTRAINT FK_DigitoIdentificador_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_DigitoIdentificador_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT PRES.DigitoIdentificador ON;

INSERT INTO PRES.DigitoIdentificador (PKIdDigitoIdentificador, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    d.PK_IdDigitoIdentificador,
    d.Clave,
    d.Descripcion,
    ISNULL(d.CT_LIVE, 1),
    ISNULL(d.CT_CreatedDate, GETDATE()),
    ISNULL(d.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.DigitoIdentificador d
WHERE NOT EXISTS (SELECT 1 FROM PRES.DigitoIdentificador dest WHERE dest.PKIdDigitoIdentificador = d.PK_IdDigitoIdentificador);

SET IDENTITY_INSERT PRES.DigitoIdentificador OFF;

-- =============================================
-- 7. PRES.DestinoGasto
-- =============================================
IF OBJECT_ID('PRES.DestinoGasto', 'U') IS NOT NULL DROP TABLE PRES.DestinoGasto;
GO
CREATE TABLE PRES.DestinoGasto (
    PKIdDestinoGasto INT IDENTITY(1,1) NOT NULL,
    Clave NVARCHAR(2) NOT NULL,
    Descripcion NVARCHAR(250) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_DestinoGasto_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_DestinoGasto_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_DestinoGasto PRIMARY KEY (PKIdDestinoGasto),
    CONSTRAINT FK_DestinoGasto_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_DestinoGasto_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT PRES.DestinoGasto ON;

INSERT INTO PRES.DestinoGasto (PKIdDestinoGasto, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    d.PK_IdDestinoGasto,
    d.Clave,
    d.Descripcion,
    ISNULL(d.CT_LIVE, 1),
    ISNULL(d.CT_CreatedDate, GETDATE()),
    ISNULL(d.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.DestinoGasto d
WHERE NOT EXISTS (SELECT 1 FROM PRES.DestinoGasto dest WHERE dest.PKIdDestinoGasto = d.PK_IdDestinoGasto);

SET IDENTITY_INSERT PRES.DestinoGasto OFF;

-- =============================================
-- 8. PRES.Suficiencia
-- =============================================
IF OBJECT_ID('PRES.Suficiencia', 'U') IS NOT NULL DROP TABLE PRES.Suficiencia;
GO
CREATE TABLE PRES.Suficiencia (
    PKIdSuficiencia INT IDENTITY(1,1) NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Suficiencia_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Suficiencia_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Suficiencia PRIMARY KEY (PKIdSuficiencia),
    CONSTRAINT FK_Suficiencia_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Suficiencia_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT PRES.Suficiencia ON;

INSERT INTO PRES.Suficiencia (PKIdSuficiencia, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    s.PK_IdEstatusSolicitud,
    s.Descripcion,
    ISNULL(s.CT_LIVE, 1),
    ISNULL(s.CT_CreatedDate, GETDATE()),
    ISNULL(s.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ALMA.EstatusSolicitud s
WHERE NOT EXISTS (SELECT 1 FROM PRES.Suficiencia d WHERE d.PKIdSuficiencia = s.PK_IdEstatusSolicitud)
and Descripcion not Like '%test%';


SET IDENTITY_INSERT PRES.Suficiencia OFF;
-- =============================================
-- 9. PRES.EgresoAutorizado (sin empresa)
-- =============================================
IF OBJECT_ID('PRES.EgresoAutorizado', 'U') IS NOT NULL DROP TABLE PRES.EgresoAutorizado;
GO
CREATE TABLE PRES.EgresoAutorizado (
    PKIdEgresoAutorizado INT IDENTITY(1,1) NOT NULL,
    FKIdPrograma_PRES INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    FKIdArea_SIS INT NOT NULL,
    Descripcion NVARCHAR(250) NULL,
    Fecha DATE NOT NULL,
    FKIdPoliza_CONTA INT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_EgresoAutorizado_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_EgresoAutorizado_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_EgresoAutorizado PRIMARY KEY (PKIdEgresoAutorizado),
    CONSTRAINT FK_EgresoAutorizado_Programa FOREIGN KEY (FKIdPrograma_PRES) REFERENCES PRES.Programa(PKIdPrograma),
    CONSTRAINT FK_EgresoAutorizado_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_EgresoAutorizado_Area FOREIGN KEY (FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_EgresoAutorizado_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_EgresoAutorizado_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

SET IDENTITY_INSERT PRES.EgresoAutorizado ON;

INSERT INTO PRES.EgresoAutorizado (
    PKIdEgresoAutorizado,
    FKIdPrograma_PRES,
    FKIdPartida_CONTA,
    FKIdArea_SIS,
    Descripcion,
    Fecha,
    FKIdPoliza_CONTA,
    Activo,
    FechaCreacion,
    UsuarioCreacion
)
SELECT 
    e.Pk_IdEgresoAutorizado,
    e.Fk_IdPrograma,
    e.Fk_IdPartida,
    e.Fk_IdArea,
    e.Descripcion,
    e.Fecha,
    e.FK_IdPoliza,
    ISNULL(e.CT_LIVE, 1),
    ISNULL(e.CT_CreatedDate, GETDATE()),
    1
FROM BD_PRESUPUESTO.PRES.EgresoAutorizado e
WHERE NOT EXISTS (SELECT 1 FROM PRES.EgresoAutorizado d WHERE d.PKIdEgresoAutorizado = e.Pk_IdEgresoAutorizado);

SET IDENTITY_INSERT PRES.EgresoAutorizado OFF;

-- =============================================
-- 10. ORCO.Requisicion (sin partida directa, sin contenedores)
-- =============================================
IF OBJECT_ID('ORCO.Requisicion', 'U') IS NOT NULL DROP TABLE ORCO.Requisicion;
GO
CREATE TABLE ORCO.Requisicion (
    PKIdRequisicion INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdPersona_NOM INT NOT NULL,
    FKIdArea_SIS INT NOT NULL,
    Descripcion NVARCHAR(100) NOT NULL,
    Observaciones NVARCHAR(1000) NULL,
    FechaRequisicion DATETIME NOT NULL,
    Servicio BIT NOT NULL,
    FL_FOTO NVARCHAR(1000) NULL,
    FKIdProyecto_ORCO INT NULL,
    FechaRequiereInicio DATETIME NULL,
    FechaRequiereFin DATETIME NULL,
    FKIdPrograma_PRES INT NULL,
    Importe [dbo].[dmoney] NULL,
    FKIdJefeAlmacen_NOM INT NULL,
    FKIdSuficiencia_PRES INT NULL,
    FKIdSuperviso_NOM INT NULL,
    FKIdAutorizo_NOM INT NULL,
    FKIdPSolicita_NOM INT NULL,
    FKIdPJefeAlmacen_NOM INT NULL,
    FKIdPSuficiencia_NOM INT NULL,
    FKIdPSuperviso_NOM INT NULL,
    FKIdPAutorizo_NOM INT NULL,
    FKIdFuenteFinanciamiento_PRES INT NULL,
    FKIdAnio_SIS INT NULL,
    FKIdTipoGasto_PRES INT NULL,
    FKIdDigitoIdentificador_PRES INT NULL,
    FKIdDestinoGasto_PRES INT NULL,
    FKIdEgresoAutorizado_PRES INT NULL,
    Oficio VARCHAR(120) NULL,
    FechaOficio DATETIME NULL,
    CompraDirecta BIT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Requisicion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_Requisicion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_Requisicion PRIMARY KEY (PKIdRequisicion),
    CONSTRAINT FK_Requisicion_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Requisicion_Persona FOREIGN KEY (FKIdPersona_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_Area FOREIGN KEY (FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_Requisicion_Proyecto FOREIGN KEY (FKIdProyecto_ORCO) REFERENCES ORCO.Proyecto(PKIdProyecto),
    CONSTRAINT FK_Requisicion_Programa FOREIGN KEY (FKIdPrograma_PRES) REFERENCES PRES.Programa(PKIdPrograma),
    CONSTRAINT FK_Requisicion_JefeAlmacen FOREIGN KEY (FKIdJefeAlmacen_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_Suficiencia FOREIGN KEY (FKIdSuficiencia_PRES) REFERENCES PRES.Suficiencia(PKIdSuficiencia),
    CONSTRAINT FK_Requisicion_Superviso FOREIGN KEY (FKIdSuperviso_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_Autorizo FOREIGN KEY (FKIdAutorizo_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_PSolicita FOREIGN KEY (FKIdPSolicita_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_PJefeAlmacen FOREIGN KEY (FKIdPJefeAlmacen_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_PSuficiencia FOREIGN KEY (FKIdPSuficiencia_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_PSuperviso FOREIGN KEY (FKIdPSuperviso_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_PAutorizo FOREIGN KEY (FKIdPAutorizo_NOM) REFERENCES NOM.Persona(PKIdPersona),
    CONSTRAINT FK_Requisicion_FuenteFinanciamiento FOREIGN KEY (FKIdFuenteFinanciamiento_PRES) REFERENCES PRES.FuenteFinanciamiento(PKIdFuenteFinanciamiento),
    CONSTRAINT FK_Requisicion_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
    CONSTRAINT FK_Requisicion_TipoGasto FOREIGN KEY (FKIdTipoGasto_PRES) REFERENCES PRES.TipoGasto(PKIdTipoGasto),
    CONSTRAINT FK_Requisicion_DigitoIdentificador FOREIGN KEY (FKIdDigitoIdentificador_PRES) REFERENCES PRES.DigitoIdentificador(PKIdDigitoIdentificador),
    CONSTRAINT FK_Requisicion_DestinoGasto FOREIGN KEY (FKIdDestinoGasto_PRES) REFERENCES PRES.DestinoGasto(PKIdDestinoGasto),
    CONSTRAINT FK_Requisicion_EgresoAutorizado FOREIGN KEY (FKIdEgresoAutorizado_PRES) REFERENCES PRES.EgresoAutorizado(PKIdEgresoAutorizado),
    CONSTRAINT FK_Requisicion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_Requisicion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

-- =============================================
-- 11. ORCO.DetalleRequisicion (detalle de bienes)
-- =============================================
IF OBJECT_ID('ORCO.DetalleRequisicion', 'U') IS NOT NULL DROP TABLE ORCO.DetalleRequisicion;
GO
CREATE TABLE ORCO.DetalleRequisicion (
    PKIdDetalleRequisicion INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdRequisicion_ORCO INT NOT NULL,
    FKIdTipoBien_ALMA INT NOT NULL,
    FKIdUnidades_ALMA INT NULL,
    Cantidad NUMERIC(8,2) NOT NULL,
    Observaciones NVARCHAR(MAX) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_DetalleRequisicion_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_DetalleRequisicion_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_DetalleRequisicion PRIMARY KEY (PKIdDetalleRequisicion),
    CONSTRAINT FK_DetalleRequisicion_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_DetalleRequisicion_Requisicion FOREIGN KEY (FKIdRequisicion_ORCO) REFERENCES ORCO.Requisicion(PKIdRequisicion),
    CONSTRAINT FK_DetalleRequisicion_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
    CONSTRAINT FK_DetalleRequisicion_Unidades FOREIGN KEY (FKIdUnidades_ALMA) REFERENCES ALMA.Unidades(PKIdUnidades),
    CONSTRAINT FK_DetalleRequisicion_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_DetalleRequisicion_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

-- =============================================
-- 12. ORCO.RequisicionPartida (tabla intermedia para múltiples partidas)
-- =============================================
IF OBJECT_ID('ORCO.RequisicionPartida', 'U') IS NOT NULL DROP TABLE ORCO.RequisicionPartida;
GO
CREATE TABLE ORCO.RequisicionPartida (
    PKIdRequisicionPartida INT IDENTITY(1,1) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdRequisicion_ORCO INT NOT NULL,
    FKIdPartida_CONTA INT NOT NULL,
    Monto [dbo].[dmoney] NULL,
    Observaciones NVARCHAR(500) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_RequisicionPartida_Activo DEFAULT (1),
    FechaCreacion DATETIME2 CONSTRAINT DF_RequisicionPartida_FechaCreacion DEFAULT SYSDATETIME(),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2 NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT PK_RequisicionPartida PRIMARY KEY (PKIdRequisicionPartida),
    CONSTRAINT FK_RequisicionPartida_Empresa FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_RequisicionPartida_Requisicion FOREIGN KEY (FKIdRequisicion_ORCO) REFERENCES ORCO.Requisicion(PKIdRequisicion),
    CONSTRAINT FK_RequisicionPartida_Partida FOREIGN KEY (FKIdPartida_CONTA) REFERENCES CONTA.Partida(PKIdPartida),
    CONSTRAINT FK_RequisicionPartida_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
    CONSTRAINT FK_RequisicionPartida_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
);
GO

-- =============================================
-- FIN DEL SCRIPT
-- =============================================