USE [GestionEmpresarial];
GO

/* ============================================================
   MODULO DE NOTIFICACIONES INTERNAS
   Schema sugerido: SIS
   ============================================================ */

CREATE TABLE SIS.NotificacionTipo (
    Pk_IdNotificacionTipo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Clave NVARCHAR(80) NOT NULL UNIQUE,
    Descripcion NVARCHAR(250) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE SIS.NotificacionEstado (
    Pk_IdNotificacionEstado INT NOT NULL PRIMARY KEY,
    Descripcion NVARCHAR(80) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1
);
GO

INSERT INTO SIS.NotificacionEstado
    (Pk_IdNotificacionEstado, Descripcion, Activo)
VALUES
    (1, N'Pendiente', 1),
    (2, N'Leída', 1),
    (3, N'Atendida', 1),
    (4, N'Cancelada', 1);
GO

CREATE TABLE SIS.Notificacion (
    Pk_IdNotificacion BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    Fk_IdNotificacionTipo INT NOT NULL,
    Fk_IdUsuarioOrigen INT NULL,

    Modulo NVARCHAR(120) NOT NULL,
    SubModulo NVARCHAR(120) NULL,
    Evento NVARCHAR(120) NOT NULL,

    Entidad NVARCHAR(150) NULL,
    Fk_IdEntidad BIGINT NULL,

    Titulo NVARCHAR(250) NOT NULL,
    Mensaje NVARCHAR(MAX) NOT NULL,
    Url NVARCHAR(1000) NULL,

    JsonData NVARCHAR(MAX) NULL,

    CT_CreatedBy INT NULL,
    CT_CreatedDate DATETIME2(0) NOT NULL DEFAULT GETDATE(),
    CT_ModifiedBy INT NULL,
    CT_ModifiedDate DATETIME2(0) NULL,
    CT_LIVE BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Notificacion_Tipo
        FOREIGN KEY (Fk_IdNotificacionTipo)
        REFERENCES SIS.NotificacionTipo(Pk_IdNotificacionTipo)
);
GO

CREATE TABLE SIS.NotificacionDestino (
    Pk_IdNotificacionDestino BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    Fk_IdNotificacion BIGINT NOT NULL,
    Fk_IdUsuarioDestino INT NOT NULL,
    Fk_IdNotificacionEstado INT NOT NULL DEFAULT 1,

    FechaLeido DATETIME2(0) NULL,
    FechaAtendido DATETIME2(0) NULL,

    CT_CreatedBy INT NULL,
    CT_CreatedDate DATETIME2(0) NOT NULL DEFAULT GETDATE(),
    CT_ModifiedBy INT NULL,
    CT_ModifiedDate DATETIME2(0) NULL,
    CT_LIVE BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_NotificacionDestino_Notificacion
        FOREIGN KEY (Fk_IdNotificacion)
        REFERENCES SIS.Notificacion(Pk_IdNotificacion),

    CONSTRAINT FK_NotificacionDestino_Estado
        FOREIGN KEY (Fk_IdNotificacionEstado)
        REFERENCES SIS.NotificacionEstado(Pk_IdNotificacionEstado)
);
GO

CREATE TABLE SIS.NotificacionRegla (
    Pk_IdNotificacionRegla INT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    Modulo NVARCHAR(120) NOT NULL,
    SubModulo NVARCHAR(120) NULL,
    Evento NVARCHAR(120) NOT NULL,

    -- Ajustar al modelo real de seguridad.
    -- Puede representar Perfil, Rol, Claim o Permiso.
    TipoDestino NVARCHAR(40) NOT NULL, -- PERFIL, ROL, CLAIM, USUARIO
    ClaveDestino NVARCHAR(150) NOT NULL,

    Activo BIT NOT NULL DEFAULT 1,

    CT_CreatedBy INT NULL,
    CT_CreatedDate DATETIME2(0) NOT NULL DEFAULT GETDATE(),
    CT_ModifiedBy INT NULL,
    CT_ModifiedDate DATETIME2(0) NULL,
    CT_LIVE BIT NOT NULL DEFAULT 1
);
GO

INSERT INTO SIS.NotificacionTipo
    (Clave, Descripcion, Activo)
VALUES
    (N'FIRMA_SOLICITADA', N'Solicitud enviada para firma', 1),
    (N'FIRMA_REALIZADA', N'Documento firmado', 1),
    (N'AUTORIZACION_SOLICITADA', N'Solicitud enviada para autorización', 1),
    (N'AUTORIZACION_REALIZADA', N'Solicitud autorizada', 1),
    (N'SOLICITUD_RECHAZADA', N'Solicitud rechazada', 1);
GO

CREATE OR ALTER VIEW SIS.Vw_UsuarioPerfilNotificacion
AS
SELECT
    u.PkIdUsuario AS Fk_IdUsuario,
    r.Name AS Perfil,
    u.Activo
FROM SIS.Usuario u
INNER JOIN dbo.AspNetUsers au ON u.AspNetUserId = au.Id
INNER JOIN dbo.AspNetUserRoles ur ON au.Id = ur.UserId
INNER JOIN dbo.AspNetRoles r ON ur.RoleId = r.Id
WHERE u.Activo = 1;
GO


CREATE TYPE SIS.NotificacionUsuarioType AS TABLE (
    Fk_IdUsuarioDestino INT NOT NULL
);
GO

CREATE OR ALTER PROCEDURE SIS.sp_NotificacionCrear
(
    @ClaveTipo NVARCHAR(80),
    @Fk_IdUsuarioOrigen INT = NULL,

    @Modulo NVARCHAR(120),
    @SubModulo NVARCHAR(120) = NULL,
    @Evento NVARCHAR(120),

    @Entidad NVARCHAR(150) = NULL,
    @Fk_IdEntidad BIGINT = NULL,

    @Titulo NVARCHAR(250),
    @Mensaje NVARCHAR(MAX),
    @Url NVARCHAR(1000) = NULL,
    @JsonData NVARCHAR(MAX) = NULL,

    @Usuarios SIS.NotificacionUsuarioType READONLY,
    @IdUser INT = NULL,
    @IdNotificacion BIGINT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Fk_IdNotificacionTipo INT;

    SELECT @Fk_IdNotificacionTipo = Pk_IdNotificacionTipo
    FROM SIS.NotificacionTipo
    WHERE Clave = @ClaveTipo
      AND Activo = 1;

    IF @Fk_IdNotificacionTipo IS NULL
    BEGIN
        THROW 51000, 'Tipo de notificación no válido.', 1;
    END;

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO SIS.Notificacion (
            Fk_IdNotificacionTipo,
            Fk_IdUsuarioOrigen,
            Modulo,
            SubModulo,
            Evento,
            Entidad,
            Fk_IdEntidad,
            Titulo,
            Mensaje,
            Url,
            JsonData,
            CT_CreatedBy,
            CT_CreatedDate,
            CT_LIVE
        )
        VALUES (
            @Fk_IdNotificacionTipo,
            @Fk_IdUsuarioOrigen,
            @Modulo,
            @SubModulo,
            @Evento,
            @Entidad,
            @Fk_IdEntidad,
            @Titulo,
            @Mensaje,
            @Url,
            @JsonData,
            @IdUser,
            GETDATE(),
            1
        );

        SET @IdNotificacion = SCOPE_IDENTITY();

        INSERT INTO SIS.NotificacionDestino (
            Fk_IdNotificacion,
            Fk_IdUsuarioDestino,
            Fk_IdNotificacionEstado,
            CT_CreatedBy,
            CT_CreatedDate,
            CT_LIVE
        )
        SELECT DISTINCT
            @IdNotificacion,
            u.Fk_IdUsuarioDestino,
            1,
            @IdUser,
            GETDATE(),
            1
        FROM @Usuarios u
        WHERE u.Fk_IdUsuarioDestino IS NOT NULL;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE SIS.sp_NotificacionCrearPorPerfil
(
    @ClaveTipo NVARCHAR(80),
    @Fk_IdUsuarioOrigen INT = NULL,

    @Modulo NVARCHAR(120),
    @SubModulo NVARCHAR(120) = NULL,
    @Evento NVARCHAR(120),

    @PerfilDestino NVARCHAR(150),

    @Entidad NVARCHAR(150) = NULL,
    @Fk_IdEntidad BIGINT = NULL,

    @Titulo NVARCHAR(250),
    @Mensaje NVARCHAR(MAX),
    @Url NVARCHAR(1000) = NULL,
    @JsonData NVARCHAR(MAX) = NULL,

    @IdUser INT = NULL,
    @IdNotificacion BIGINT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Usuarios SIS.NotificacionUsuarioType;

    INSERT INTO @Usuarios (Fk_IdUsuarioDestino)
    SELECT DISTINCT Fk_IdUsuario
    FROM SIS.Vw_UsuarioPerfilNotificacion
    WHERE Perfil = @PerfilDestino
      AND Activo = 1;

    EXEC SIS.sp_NotificacionCrear
        @ClaveTipo = @ClaveTipo,
        @Fk_IdUsuarioOrigen = @Fk_IdUsuarioOrigen,
        @Modulo = @Modulo,
        @SubModulo = @SubModulo,
        @Evento = @Evento,
        @Entidad = @Entidad,
        @Fk_IdEntidad = @Fk_IdEntidad,
        @Titulo = @Titulo,
        @Mensaje = @Mensaje,
        @Url = @Url,
        @JsonData = @JsonData,
        @Usuarios = @Usuarios,
        @IdUser = @IdUser,
        @IdNotificacion = @IdNotificacion OUTPUT;
END;
GO

CREATE OR ALTER PROCEDURE SIS.sp_NotificacionActualizarEstado
(
    @Pk_IdNotificacionDestino BIGINT,
    @Fk_IdUsuario INT,
    @Fk_IdNotificacionEstado INT,
    @IdUser INT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE SIS.NotificacionDestino
    SET
        Fk_IdNotificacionEstado = @Fk_IdNotificacionEstado,
        FechaLeido = CASE
            WHEN @Fk_IdNotificacionEstado IN (2, 3)
             AND FechaLeido IS NULL THEN GETDATE()
            ELSE FechaLeido
        END,
        FechaAtendido = CASE
            WHEN @Fk_IdNotificacionEstado = 3 THEN GETDATE()
            ELSE FechaAtendido
        END,
        CT_ModifiedBy = @IdUser,
        CT_ModifiedDate = GETDATE()
    WHERE Pk_IdNotificacionDestino = @Pk_IdNotificacionDestino
      AND Fk_IdUsuarioDestino = @Fk_IdUsuario
      AND CT_LIVE = 1;
END;
GO

CREATE OR ALTER VIEW SIS.Vw_NotificacionUsuario
AS
SELECT
    nd.Pk_IdNotificacionDestino,
    n.Pk_IdNotificacion,
    n.Fk_IdUsuarioOrigen,
    nd.Fk_IdUsuarioDestino,
    nt.Clave AS Tipo,
    n.Modulo,
    n.SubModulo,
    n.Evento,
    n.Entidad,
    n.Fk_IdEntidad,
    n.Titulo,
    n.Mensaje,
    n.Url,
    n.JsonData,
    ne.Descripcion AS Estado,
    nd.Fk_IdNotificacionEstado,
    nd.FechaLeido,
    nd.FechaAtendido,
    n.CT_CreatedDate AS FechaNotificacion
FROM SIS.NotificacionDestino nd
JOIN SIS.Notificacion n
    ON n.Pk_IdNotificacion = nd.Fk_IdNotificacion
   AND n.CT_LIVE = 1
JOIN SIS.NotificacionTipo nt
    ON nt.Pk_IdNotificacionTipo = n.Fk_IdNotificacionTipo
JOIN SIS.NotificacionEstado ne
    ON ne.Pk_IdNotificacionEstado = nd.Fk_IdNotificacionEstado
WHERE nd.CT_LIVE = 1;
GO


CREATE INDEX IX_Notificacion_ModuloEvento
ON SIS.Notificacion (Modulo, SubModulo, Evento, Fk_IdEntidad)
INCLUDE (Titulo, CT_CreatedDate);

CREATE INDEX IX_NotificacionDestino_UsuarioEstado
ON SIS.NotificacionDestino (Fk_IdUsuarioDestino, Fk_IdNotificacionEstado, CT_LIVE)
INCLUDE (Fk_IdNotificacion, FechaLeido, FechaAtendido);

CREATE INDEX IX_NotificacionDestino_Notificacion
ON SIS.NotificacionDestino (Fk_IdNotificacion);

CREATE INDEX IX_NotificacionRegla_Evento
ON SIS.NotificacionRegla (Modulo, SubModulo, Evento, TipoDestino, ClaveDestino)
WHERE CT_LIVE = 1 AND Activo = 1;
GO

/*

Ejemplo de integración con firma:

Cuando se manda a firma:

DECLARE @IdNotificacion BIGINT;

EXEC SIS.sp_NotificacionCrearPorPerfil
    @ClaveTipo = N'FIRMA_SOLICITADA',
    @Fk_IdUsuarioOrigen = @IdUser,
    @Modulo = N'FirmaElectronica',
    @SubModulo = N'Polizas',
    @Evento = N'SolicitudFirma',
    @PerfilDestino = N'FIRMA',
    @Entidad = N'FirmaDocumento',
    @Fk_IdEntidad = @Pk_IdDocumento,
    @Titulo = N'Solicitud de firma pendiente',
    @Mensaje = N'Tienes un documento pendiente de firma.',
    @Url = N'/FirmaElectronica/Pendientes',
    @JsonData = NULL,
    @IdUser = @IdUser,
    @IdNotificacion = @IdNotificacion OUTPUT;
Cuando el usuario firma:

DECLARE @Usuarios SIS.NotificacionUsuarioType;
DECLARE @IdNotificacion BIGINT;

INSERT INTO @Usuarios (Fk_IdUsuarioDestino)
VALUES (@Fk_IdUsuarioSolicitante);

EXEC SIS.sp_NotificacionCrear
    @ClaveTipo = N'FIRMA_REALIZADA',
    @Fk_IdUsuarioOrigen = @IdUsuarioFirmante,
    @Modulo = N'FirmaElectronica',
    @SubModulo = N'Polizas',
    @Evento = N'DocumentoFirmado',
    @Entidad = N'FirmaDocumento',
    @Fk_IdEntidad = @Pk_IdDocumento,
    @Titulo = N'Documento firmado',
    @Mensaje = N'El documento solicitado ya fue firmado.',
    @Url = N'/FirmaElectronica/Seguimiento',
    @JsonData = NULL,
    @Usuarios = @Usuarios,
    @IdUser = @IdUsuarioFirmante,
    @IdNotificacion = @IdNotificacion OUTPUT;
Con esto ya tienes una base sólida para notificaciones internas, firma, autorizaciones, rechazos y seguimiento por usuario.

*/