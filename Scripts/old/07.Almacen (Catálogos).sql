USE [GestionEmpresarial];
GO

-- =============================================
-- 1. ALMA.MotivoES (Motivo de Entradas y Salidas)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MotivoES' AND schema_id = SCHEMA_ID('ALMA'))
BEGIN
    CREATE TABLE ALMA.MotivoES (
        PKIdMotivoES INT IDENTITY(1,1) NOT NULL,
        Descripcion NVARCHAR(50) NOT NULL,
        AplicaEntrada BIT NOT NULL,
        AplicaSalida BIT NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_MotivoES_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_MotivoES_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_MotivoES PRIMARY KEY (PKIdMotivoES),
        CONSTRAINT FK_MotivoES_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_MotivoES_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT ALMA.MotivoES ON;
INSERT INTO ALMA.MotivoES (PKIdMotivoES, Descripcion, AplicaEntrada, AplicaSalida, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdMotivoES, Descripcion, AplicaEntrada, AplicaSalida, 
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ALMA.MotivoES
WHERE NOT EXISTS (SELECT 1 FROM ALMA.MotivoES WHERE PKIdMotivoES = PK_IdMotivoES);
SET IDENTITY_INSERT ALMA.MotivoES OFF;
GO

-- =============================================
-- 2. ALMA.Unidades (Unidades de medida)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Unidades' AND schema_id = SCHEMA_ID('ALMA'))
BEGIN
    CREATE TABLE ALMA.Unidades (
        PKIdUnidades INT IDENTITY(1,1) NOT NULL,
        Descripcion NVARCHAR(50) NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Unidades_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_Unidades_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_Unidades PRIMARY KEY (PKIdUnidades),
        CONSTRAINT FK_Unidades_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_Unidades_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT ALMA.Unidades ON;
INSERT INTO ALMA.Unidades (PKIdUnidades, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdUnidades, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ALMA.Unidades
WHERE NOT EXISTS (SELECT 1 FROM ALMA.Unidades WHERE PKIdUnidades = PK_IdUnidades);
SET IDENTITY_INSERT ALMA.Unidades OFF;
GO

-- =============================================
-- 3. ALMA.EstatusSolicitud (Estatus de las solicitudes)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EstatusSolicitud' AND schema_id = SCHEMA_ID('ALMA'))
BEGIN
    CREATE TABLE ALMA.EstatusSolicitud (
        PKIdEstatusSolicitud INT IDENTITY(1,1) NOT NULL,
        Descripcion NVARCHAR(150) NOT NULL,
        Color NVARCHAR(8) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_EstatusSolicitud_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_EstatusSolicitud_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_EstatusSolicitud PRIMARY KEY (PKIdEstatusSolicitud),
        CONSTRAINT FK_EstatusSolicitud_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_EstatusSolicitud_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET IDENTITY_INSERT ALMA.EstatusSolicitud ON;
INSERT INTO ALMA.EstatusSolicitud (PKIdEstatusSolicitud, Descripcion, Color, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdEstatusSolicitud, Descripcion, Color, 
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ALMA.EstatusSolicitud
WHERE NOT EXISTS (SELECT 1 FROM ALMA.EstatusSolicitud WHERE PKIdEstatusSolicitud = PK_IdEstatusSolicitud);
SET IDENTITY_INSERT ALMA.EstatusSolicitud OFF;
GO

PRINT 'Tablas ALMA.MotivoES, ALMA.Unidades y ALMA.EstatusSolicitud creadas y migradas exitosamente.';