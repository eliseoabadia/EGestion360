USE [GestionEmpresarial];
GO

/*
    Reglas de notificaciones:
    - El usuario origen/creador no se inserta como destinatario.
    - El creador se conserva en SIS.Notificacion.Fk_IdUsuarioOrigen.
    - Las respuestas viajan al usuario origen de la notificacion recibida.
*/

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
        THROW 51000, 'Tipo de notificacion no valido.', 1;
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
        WHERE u.Fk_IdUsuarioDestino IS NOT NULL
          AND (@Fk_IdUsuarioOrigen IS NULL OR u.Fk_IdUsuarioDestino <> @Fk_IdUsuarioOrigen);

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
      AND Activo = 1
      AND (@Fk_IdUsuarioOrigen IS NULL OR Fk_IdUsuario <> @Fk_IdUsuarioOrigen);

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

CREATE OR ALTER PROCEDURE SIS.sp_NotificacionResponder
(
    @Pk_IdNotificacionDestino BIGINT,
    @Fk_IdUsuarioResponde INT,
    @Mensaje NVARCHAR(MAX),
    @IdUser INT = NULL,
    @IdNotificacion BIGINT = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Fk_IdUsuarioDestino INT,
            @Modulo NVARCHAR(120),
            @SubModulo NVARCHAR(120),
            @Entidad NVARCHAR(150),
            @Fk_IdEntidad BIGINT,
            @Titulo NVARCHAR(250),
            @Url NVARCHAR(1000),
            @JsonData NVARCHAR(MAX),
            @Usuarios SIS.NotificacionUsuarioType;

    BEGIN TRY
        SELECT TOP 1
            @Fk_IdUsuarioDestino = n.Fk_IdUsuarioOrigen,
            @Modulo = n.Modulo,
            @SubModulo = n.SubModulo,
            @Entidad = n.Entidad,
            @Fk_IdEntidad = n.Fk_IdEntidad,
            @Titulo = CONCAT(N'Respuesta: ', n.Titulo),
            @Url = n.Url,
            @JsonData = n.JsonData
        FROM SIS.NotificacionDestino nd
        INNER JOIN SIS.Notificacion n
            ON n.Pk_IdNotificacion = nd.Fk_IdNotificacion
           AND n.CT_LIVE = 1
        WHERE nd.Pk_IdNotificacionDestino = @Pk_IdNotificacionDestino
          AND nd.Fk_IdUsuarioDestino = @Fk_IdUsuarioResponde
          AND nd.CT_LIVE = 1;

        IF @Fk_IdUsuarioDestino IS NULL OR @Fk_IdUsuarioDestino <= 0
        BEGIN
            SELECT JSON_QUERY('{"tipo":"ERROR","mensaje":"La notificacion no tiene usuario origen para responder","liga":""}') AS ResultJson;
            RETURN;
        END;

        IF @Fk_IdUsuarioDestino = @Fk_IdUsuarioResponde
        BEGIN
            SELECT JSON_QUERY('{"tipo":"ERROR","mensaje":"No se puede responder una notificacion propia","liga":""}') AS ResultJson;
            RETURN;
        END;

        INSERT INTO @Usuarios (Fk_IdUsuarioDestino)
        VALUES (@Fk_IdUsuarioDestino);

        EXEC SIS.sp_NotificacionCrear
            @ClaveTipo = N'RESPUESTA_NOTIFICACION',
            @Fk_IdUsuarioOrigen = @Fk_IdUsuarioResponde,
            @Modulo = @Modulo,
            @SubModulo = @SubModulo,
            @Evento = N'Respuesta',
            @Entidad = @Entidad,
            @Fk_IdEntidad = @Fk_IdEntidad,
            @Titulo = @Titulo,
            @Mensaje = @Mensaje,
            @Url = @Url,
            @JsonData = @JsonData,
            @Usuarios = @Usuarios,
            @IdUser = @IdUser,
            @IdNotificacion = @IdNotificacion OUTPUT;

        EXEC SIS.sp_NotificacionActualizarEstado
            @Pk_IdNotificacionDestino = @Pk_IdNotificacionDestino,
            @Fk_IdUsuario = @Fk_IdUsuarioResponde,
            @Fk_IdNotificacionEstado = 3,
            @IdUser = @IdUser;

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"OK","mensaje":"Respuesta enviada correctamente","liga":"',
                   ISNULL(CONVERT(VARCHAR(30), @IdNotificacion), ''),
                   '"}')
        ) AS ResultJson;
    END TRY
    BEGIN CATCH
        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"',
                   REPLACE(REPLACE(ERROR_MESSAGE(), '"', ''), ':', ' '),
                   '","liga":""}')
        ) AS ResultJson;
    END CATCH
END;
GO
