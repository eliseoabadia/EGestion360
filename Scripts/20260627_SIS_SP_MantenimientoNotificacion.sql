USE [GestionEmpresarial];
GO

IF SCHEMA_ID(N'SIS') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA SIS');
END
GO

IF OBJECT_ID(N'SIS.NotificacionTipo', N'U') IS NULL
BEGIN
    THROW 51000, 'No existe SIS.NotificacionTipo. Ejecute primero Scripts/Script_Notificaciones.sql.', 1;
END
GO

IF OBJECT_ID(N'SIS.NotificacionEstado', N'U') IS NULL
BEGIN
    THROW 51000, 'No existe SIS.NotificacionEstado. Ejecute primero Scripts/Script_Notificaciones.sql.', 1;
END
GO

IF OBJECT_ID(N'SIS.Notificacion', N'U') IS NULL
BEGIN
    THROW 51000, 'No existe SIS.Notificacion. Ejecute primero Scripts/Script_Notificaciones.sql.', 1;
END
GO

IF OBJECT_ID(N'SIS.NotificacionDestino', N'U') IS NULL
BEGIN
    THROW 51000, 'No existe SIS.NotificacionDestino. Ejecute primero Scripts/Script_Notificaciones.sql.', 1;
END
GO

IF NOT EXISTS (SELECT 1 FROM SIS.NotificacionEstado WHERE Pk_IdNotificacionEstado = 1)
BEGIN
    INSERT INTO SIS.NotificacionEstado (Pk_IdNotificacionEstado, Descripcion, Activo)
    VALUES (1, N'Pendiente', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM SIS.NotificacionEstado WHERE Pk_IdNotificacionEstado = 2)
BEGIN
    INSERT INTO SIS.NotificacionEstado (Pk_IdNotificacionEstado, Descripcion, Activo)
    VALUES (2, N'Leida', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM SIS.NotificacionEstado WHERE Pk_IdNotificacionEstado = 3)
BEGIN
    INSERT INTO SIS.NotificacionEstado (Pk_IdNotificacionEstado, Descripcion, Activo)
    VALUES (3, N'Atendida', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM SIS.NotificacionEstado WHERE Pk_IdNotificacionEstado = 4)
BEGIN
    INSERT INTO SIS.NotificacionEstado (Pk_IdNotificacionEstado, Descripcion, Activo)
    VALUES (4, N'Cancelada', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM SIS.NotificacionTipo WHERE Clave = N'LEGACY')
BEGIN
    INSERT INTO SIS.NotificacionTipo (Clave, Descripcion, Activo)
    VALUES (N'LEGACY', N'Notificacion generada desde procedimientos migrados', 1);
END
GO

CREATE OR ALTER PROCEDURE SIS.SP_MantenimientoNotificacion
(
    @Action INT,
    @Fk_IdUsuarioOrigen INT = NULL,
    @Fk_IdMenu INT = NULL,
    @Fk_IdAccionSuscrita INT = NULL,
    @Mensaje NVARCHAR(MAX) = NULL,
    @IdUser INT = NULL,
    @Controlador NVARCHAR(250) = NULL,
    @Pk_IdNotificacion BIGINT = NULL OUTPUT,
    @Fk_IdNotificacionPadre BIGINT = NULL,
    @Fk_IdUnidades INT = NULL,
    @Fk_IdEstadoNotificacion INT = NULL,
    @Fk_IdCliente INT = NULL,
    @Fk_IdEmpresa INT = NULL,
    @Importe DECIMAL(18, 4) = NULL,
    @IdRegistro INT = NULL,
    @FechaCreacion DATETIME = NULL,
    @FechaRecibido DATETIME = NULL,
    @IntervaloNormal INT = NULL,
    @IntervaloAlerta INT = NULL,
    @IntervaloCritico INT = NULL,
    @Fk_IdUsuarioDestino INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Ahora DATETIME2(0) = COALESCE(CONVERT(DATETIME2(0), @FechaCreacion), SYSDATETIME());
    DECLARE @Modulo NVARCHAR(120) = N'Legacy';
    DECLARE @SubModulo NVARCHAR(120) = NULL;
    DECLARE @Evento NVARCHAR(120) = CONCAT(N'Accion_', COALESCE(CONVERT(NVARCHAR(20), @Fk_IdAccionSuscrita), N'0'));
    DECLARE @Entidad NVARCHAR(150) = COALESCE(NULLIF(@Controlador, N''), N'SP_MantenimientoNotificacion');
    DECLARE @Titulo NVARCHAR(250) = N'Notificacion';
    DECLARE @Url NVARCHAR(1000) = NULL;
    DECLARE @Fk_IdNotificacionTipo INT;
    DECLARE @JsonData NVARCHAR(MAX);

    IF @Action IS NULL
    BEGIN
        THROW 51001, 'El parametro @Action es obligatorio.', 1;
    END;

    SELECT @Fk_IdNotificacionTipo = Pk_IdNotificacionTipo
    FROM SIS.NotificacionTipo
    WHERE Clave = N'LEGACY'
      AND Activo = 1;

    IF @Fk_IdNotificacionTipo IS NULL
    BEGIN
        INSERT INTO SIS.NotificacionTipo (Clave, Descripcion, Activo)
        VALUES (N'LEGACY', N'Notificacion generada desde procedimientos migrados', 1);

        SET @Fk_IdNotificacionTipo = SCOPE_IDENTITY();
    END;

    IF @Fk_IdMenu IS NOT NULL
    BEGIN
        SELECT
            @Modulo = LEFT(COALESCE(NULLIF(m.LegacyName, N''), NULLIF(m.Nombre, N''), @Modulo), 120),
            @SubModulo = LEFT(NULLIF(m.Ruta, N''), 120),
            @Url = NULLIF(m.Ruta, N''),
            @Titulo = LEFT(COALESCE(NULLIF(m.Nombre, N''), @Titulo), 250)
        FROM SIS.Menu m
        WHERE m.PKIdMenu = @Fk_IdMenu;
    END;

    SET @Mensaje = COALESCE(NULLIF(@Mensaje, N''), @Titulo);

    SET @JsonData = (
        SELECT
            @Fk_IdMenu AS Fk_IdMenu,
            @Fk_IdAccionSuscrita AS Fk_IdAccionSuscrita,
            @Fk_IdNotificacionPadre AS Fk_IdNotificacionPadre,
            @Fk_IdUnidades AS Fk_IdUnidades,
            @Fk_IdCliente AS Fk_IdCliente,
            @Fk_IdEmpresa AS Fk_IdEmpresa,
            @Importe AS Importe,
            @IntervaloNormal AS IntervaloNormal,
            @IntervaloAlerta AS IntervaloAlerta,
            @IntervaloCritico AS IntervaloCritico
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    IF @Action = 1
    BEGIN
        DECLARE @Usuarios TABLE
        (
            Fk_IdUsuarioDestino INT NOT NULL PRIMARY KEY
        );

        IF @Fk_IdUsuarioDestino IS NOT NULL
        BEGIN
            INSERT INTO @Usuarios (Fk_IdUsuarioDestino)
            SELECT @Fk_IdUsuarioDestino
            WHERE EXISTS (
                SELECT 1
                FROM SIS.Usuario u
                WHERE u.PKIdUsuario = @Fk_IdUsuarioDestino
                  AND u.Activo = 1
            );
        END;

        IF NOT EXISTS (SELECT 1 FROM @Usuarios) AND @Fk_IdMenu IS NOT NULL
        BEGIN
            INSERT INTO @Usuarios (Fk_IdUsuarioDestino)
            SELECT DISTINCT u.PKIdUsuario
            FROM SIS.MenuRole mr
            INNER JOIN dbo.AspNetUserRoles ur
                ON ur.RoleId = mr.RoleId
            INNER JOIN SIS.Usuario u
                ON u.AspNetUserId = ur.UserId
            WHERE mr.FKIdMenu_SIS = @Fk_IdMenu
              AND mr.Activo = 1
              AND u.Activo = 1
              AND (@Fk_IdUsuarioOrigen IS NULL OR u.PKIdUsuario <> @Fk_IdUsuarioOrigen);
        END;

        IF NOT EXISTS (SELECT 1 FROM @Usuarios) AND @Fk_IdUsuarioOrigen IS NOT NULL
        BEGIN
            INSERT INTO @Usuarios (Fk_IdUsuarioDestino)
            SELECT @Fk_IdUsuarioOrigen
            WHERE EXISTS (
                SELECT 1
                FROM SIS.Usuario u
                WHERE u.PKIdUsuario = @Fk_IdUsuarioOrigen
                  AND u.Activo = 1
            );
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
                @IdRegistro,
                @Titulo,
                @Mensaje,
                @Url,
                @JsonData,
                COALESCE(@IdUser, @Fk_IdUsuarioOrigen),
                @Ahora,
                1
            );

            SET @Pk_IdNotificacion = SCOPE_IDENTITY();

            INSERT INTO SIS.NotificacionDestino (
                Fk_IdNotificacion,
                Fk_IdUsuarioDestino,
                Fk_IdNotificacionEstado,
                FechaLeido,
                FechaAtendido,
                CT_CreatedBy,
                CT_CreatedDate,
                CT_LIVE
            )
            SELECT
                @Pk_IdNotificacion,
                u.Fk_IdUsuarioDestino,
                COALESCE(@Fk_IdEstadoNotificacion, 1),
                CASE WHEN @Fk_IdEstadoNotificacion IN (2, 3) THEN COALESCE(@FechaRecibido, CONVERT(DATETIME, @Ahora)) END,
                CASE WHEN @Fk_IdEstadoNotificacion = 3 THEN COALESCE(@FechaRecibido, CONVERT(DATETIME, @Ahora)) END,
                COALESCE(@IdUser, @Fk_IdUsuarioOrigen),
                @Ahora,
                1
            FROM @Usuarios u;

            COMMIT;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK;
            END;

            THROW;
        END CATCH;

        RETURN;
    END;

    IF @Pk_IdNotificacion IS NULL
    BEGIN
        RETURN;
    END;

    IF @Action IN (2, 3, 4)
    BEGIN
        UPDATE SIS.NotificacionDestino
        SET
            Fk_IdNotificacionEstado = COALESCE(@Fk_IdEstadoNotificacion, CASE WHEN @Action = 3 THEN 4 ELSE 2 END),
            FechaLeido = CASE
                WHEN COALESCE(@Fk_IdEstadoNotificacion, CASE WHEN @Action = 3 THEN 4 ELSE 2 END) IN (2, 3)
                 AND FechaLeido IS NULL THEN COALESCE(@FechaRecibido, CONVERT(DATETIME, @Ahora))
                ELSE FechaLeido
            END,
            FechaAtendido = CASE
                WHEN COALESCE(@Fk_IdEstadoNotificacion, CASE WHEN @Action = 3 THEN 4 ELSE 2 END) = 3
                    THEN COALESCE(@FechaRecibido, CONVERT(DATETIME, @Ahora))
                ELSE FechaAtendido
            END,
            CT_ModifiedBy = @IdUser,
            CT_ModifiedDate = @Ahora,
            CT_LIVE = CASE WHEN @Action = 4 THEN 0 ELSE CT_LIVE END
        WHERE Fk_IdNotificacion = @Pk_IdNotificacion
          AND (@Fk_IdUsuarioDestino IS NULL OR Fk_IdUsuarioDestino = @Fk_IdUsuarioDestino);

        UPDATE SIS.Notificacion
        SET
            CT_ModifiedBy = @IdUser,
            CT_ModifiedDate = @Ahora,
            CT_LIVE = CASE WHEN @Action = 4 THEN 0 ELSE CT_LIVE END
        WHERE Pk_IdNotificacion = @Pk_IdNotificacion;
    END;
END;
GO
