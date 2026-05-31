USE [GestionEmpresarial]
GO

IF SCHEMA_ID(N'SIS') IS NULL
    EXEC(N'CREATE SCHEMA SIS');
GO

/* ============================================================
   1. CATALOGO DE EXTENSIONES PERMITIDAS
   ============================================================ */

IF OBJECT_ID(N'SIS.DocumentoExtensionPermitida', N'U') IS NULL
BEGIN
    CREATE TABLE SIS.DocumentoExtensionPermitida
    (
        PkidDocumentoExtensionPermitida INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Extension NVARCHAR(16) NOT NULL,
        TipoMime NVARCHAR(120) NOT NULL,
        EsImagen BIT NOT NULL CONSTRAINT DF_DocumentoExtensionPermitida_EsImagen DEFAULT 0,
        EsPdf BIT NOT NULL CONSTRAINT DF_DocumentoExtensionPermitida_EsPdf DEFAULT 0,
        Activo BIT NOT NULL CONSTRAINT DF_DocumentoExtensionPermitida_Activo DEFAULT 1,
        CT_CreatedBy INT NULL,
        CT_CreatedDate DATETIME2(0) NOT NULL CONSTRAINT DF_DocumentoExtensionPermitida_CreatedDate DEFAULT SYSDATETIME()
    );

    CREATE UNIQUE INDEX UX_DocumentoExtensionPermitida_Extension
    ON SIS.DocumentoExtensionPermitida(Extension);
END
GO

IF NOT EXISTS (SELECT 1 FROM SIS.DocumentoExtensionPermitida WHERE Extension = N'.pdf')
    INSERT INTO SIS.DocumentoExtensionPermitida (Extension, TipoMime, EsPdf, Activo)
    VALUES (N'.pdf', N'application/pdf', 1, 1);

IF NOT EXISTS (SELECT 1 FROM SIS.DocumentoExtensionPermitida WHERE Extension = N'.png')
    INSERT INTO SIS.DocumentoExtensionPermitida (Extension, TipoMime, EsImagen, Activo)
    VALUES (N'.png', N'image/png', 1, 1);

IF NOT EXISTS (SELECT 1 FROM SIS.DocumentoExtensionPermitida WHERE Extension = N'.jpg')
    INSERT INTO SIS.DocumentoExtensionPermitida (Extension, TipoMime, EsImagen, Activo)
    VALUES (N'.jpg', N'image/jpeg', 1, 1);

IF NOT EXISTS (SELECT 1 FROM SIS.DocumentoExtensionPermitida WHERE Extension = N'.jpeg')
    INSERT INTO SIS.DocumentoExtensionPermitida (Extension, TipoMime, EsImagen, Activo)
    VALUES (N'.jpeg', N'image/jpeg', 1, 1);

IF NOT EXISTS (SELECT 1 FROM SIS.DocumentoExtensionPermitida WHERE Extension = N'.webp')
    INSERT INTO SIS.DocumentoExtensionPermitida (Extension, TipoMime, EsImagen, Activo)
    VALUES (N'.webp', N'image/webp', 1, 1);
GO

/* ============================================================
   2. TABLA PRINCIPAL DE DOCUMENTOS
   ============================================================ */

IF OBJECT_ID(N'SIS.Documento', N'U') IS NULL
BEGIN
    CREATE TABLE SIS.Documento
    (
        PkidDocumento BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

        Modulo NVARCHAR(120) NOT NULL,
        SubModulo NVARCHAR(120) NULL,
        Controlador NVARCHAR(160) NULL,
        Servicio NVARCHAR(160) NULL,
        EntidadId BIGINT NOT NULL,
        FkidEmpresaSis INT NULL,

        Titulo NVARCHAR(250) NULL,
        Descripcion NVARCHAR(MAX) NULL,

        NombreOriginal NVARCHAR(260) NOT NULL,
        NombreAlmacenado NVARCHAR(260) NOT NULL,
        Extension NVARCHAR(16) NOT NULL,
        TipoMime NVARCHAR(120) NOT NULL,
        TamanoBytes BIGINT NOT NULL,

        ModoAlmacenamiento NVARCHAR(20) NOT NULL,
        ContenidoArchivo VARBINARY(MAX) NULL,
        RutaRelativa NVARCHAR(700) NULL,

        HashSha256 VARBINARY(32) NULL,
        VersionDocumento INT NOT NULL CONSTRAINT DF_Documento_Version DEFAULT 1,

        EsImagen BIT NOT NULL CONSTRAINT DF_Documento_EsImagen DEFAULT 0,
        EsPdf BIT NOT NULL CONSTRAINT DF_Documento_EsPdf DEFAULT 0,
        Activo BIT NOT NULL CONSTRAINT DF_Documento_Activo DEFAULT 1,

        CT_CreatedBy INT NOT NULL,
        CT_CreatedDate DATETIME2(0) NOT NULL CONSTRAINT DF_Documento_CreatedDate DEFAULT SYSDATETIME(),
        CT_ModifiedBy INT NULL,
        CT_ModifiedDate DATETIME2(0) NULL,
        RowVersion ROWVERSION,

        CONSTRAINT CK_Documento_ModoAlmacenamiento
            CHECK (ModoAlmacenamiento IN (N'DATABASE', N'FILESYSTEM')),

        CONSTRAINT CK_Documento_Storage
            CHECK (
                (ModoAlmacenamiento = N'DATABASE' AND ContenidoArchivo IS NOT NULL)
                OR
                (ModoAlmacenamiento = N'FILESYSTEM' AND RutaRelativa IS NOT NULL)
            )
    );

    CREATE INDEX IX_Documento_Entidad
    ON SIS.Documento(Modulo, SubModulo, Controlador, Servicio, EntidadId, FkidEmpresaSis, Activo);

    CREATE INDEX IX_Documento_Fecha
    ON SIS.Documento(CT_CreatedDate DESC);
END
GO

/* ============================================================
   3. EVENTOS / BITACORA DOCUMENTAL
   ============================================================ */

IF OBJECT_ID(N'SIS.DocumentoEvento', N'U') IS NULL
BEGIN
    CREATE TABLE SIS.DocumentoEvento
    (
        PkidDocumentoEvento BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        FkidDocumento BIGINT NOT NULL,
        Evento NVARCHAR(40) NOT NULL,
        Comentario NVARCHAR(500) NULL,
        CT_CreatedBy INT NOT NULL,
        CT_CreatedDate DATETIME2(0) NOT NULL CONSTRAINT DF_DocumentoEvento_CreatedDate DEFAULT SYSDATETIME(),

        CONSTRAINT FK_DocumentoEvento_Documento
            FOREIGN KEY (FkidDocumento) REFERENCES SIS.Documento(PkidDocumento)
    );

    CREATE INDEX IX_DocumentoEvento_Documento
    ON SIS.DocumentoEvento(FkidDocumento, CT_CreatedDate DESC);
END
GO

/* ============================================================
   4. TIPOS DE ANOTACION
   ============================================================ */

IF OBJECT_ID(N'SIS.DocumentoTipoAnotacion', N'U') IS NULL
BEGIN
    CREATE TABLE SIS.DocumentoTipoAnotacion
    (
        PkidDocumentoTipoAnotacion INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Clave NVARCHAR(30) NOT NULL,
        Descripcion NVARCHAR(120) NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_DocumentoTipoAnotacion_Activo DEFAULT 1,
        CT_CreatedBy INT NULL,
        CT_CreatedDate DATETIME2(0) NOT NULL CONSTRAINT DF_DocumentoTipoAnotacion_CreatedDate DEFAULT SYSDATETIME()
    );

    CREATE UNIQUE INDEX UX_DocumentoTipoAnotacion_Clave
    ON SIS.DocumentoTipoAnotacion(Clave);
END
GO

IF NOT EXISTS (SELECT 1 FROM SIS.DocumentoTipoAnotacion WHERE Clave = N'COMENTARIO')
    INSERT INTO SIS.DocumentoTipoAnotacion (Clave, Descripcion, Activo)
    VALUES (N'COMENTARIO', N'Comentario agregado por usuario', 1);

IF NOT EXISTS (SELECT 1 FROM SIS.DocumentoTipoAnotacion WHERE Clave = N'RESALTADO')
    INSERT INTO SIS.DocumentoTipoAnotacion (Clave, Descripcion, Activo)
    VALUES (N'RESALTADO', N'Resaltado visual sobre documento', 1);
GO

/* ============================================================
   5. ANOTACIONES INMUTABLES
   ============================================================ */

IF OBJECT_ID(N'SIS.DocumentoAnotacion', N'U') IS NULL
BEGIN
    CREATE TABLE SIS.DocumentoAnotacion
    (
        PkidDocumentoAnotacion BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        FkidDocumento BIGINT NOT NULL,
        FkidDocumentoTipoAnotacion INT NOT NULL,

        Comentario NVARCHAR(MAX) NULL,
        TextoSeleccionado NVARCHAR(MAX) NULL,

        Pagina INT NULL,
        PosicionX DECIMAL(9,6) NULL,
        PosicionY DECIMAL(9,6) NULL,
        Ancho DECIMAL(9,6) NULL,
        Alto DECIMAL(9,6) NULL,
        Color NVARCHAR(20) NOT NULL CONSTRAINT DF_DocumentoAnotacion_Color DEFAULT N'#FFE066',

        Activo BIT NOT NULL CONSTRAINT DF_DocumentoAnotacion_Activo DEFAULT 1,
        CT_CreatedBy INT NOT NULL,
        CT_CreatedDate DATETIME2(0) NOT NULL CONSTRAINT DF_DocumentoAnotacion_CreatedDate DEFAULT SYSDATETIME(),
        CT_ModifiedBy INT NULL,
        CT_ModifiedDate DATETIME2(0) NULL,
        RowVersion ROWVERSION,

        CONSTRAINT FK_DocumentoAnotacion_Documento
            FOREIGN KEY (FkidDocumento) REFERENCES SIS.Documento(PkidDocumento),

        CONSTRAINT FK_DocumentoAnotacion_Tipo
            FOREIGN KEY (FkidDocumentoTipoAnotacion) REFERENCES SIS.DocumentoTipoAnotacion(PkidDocumentoTipoAnotacion),

        CONSTRAINT CK_DocumentoAnotacion_Coordenadas
            CHECK (
                (PosicionX IS NULL OR PosicionX BETWEEN 0 AND 1)
                AND (PosicionY IS NULL OR PosicionY BETWEEN 0 AND 1)
                AND (Ancho IS NULL OR Ancho BETWEEN 0 AND 1)
                AND (Alto IS NULL OR Alto BETWEEN 0 AND 1)
            )
    );

    CREATE INDEX IX_DocumentoAnotacion_Documento
    ON SIS.DocumentoAnotacion(FkidDocumento, Activo, CT_CreatedDate DESC);
END
GO

CREATE OR ALTER TRIGGER SIS.trDocumentoAnotacion_NoEditar
ON SIS.DocumentoAnotacion
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(FkidDocumento)
       OR UPDATE(FkidDocumentoTipoAnotacion)
       OR UPDATE(Comentario)
       OR UPDATE(TextoSeleccionado)
       OR UPDATE(Pagina)
       OR UPDATE(PosicionX)
       OR UPDATE(PosicionY)
       OR UPDATE(Ancho)
       OR UPDATE(Alto)
       OR UPDATE(Color)
       OR UPDATE(CT_CreatedBy)
       OR UPDATE(CT_CreatedDate)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 51020, 'Las anotaciones no se pueden editar. Solo se permite eliminación lógica con Activo = 0.', 1;
    END
END
GO

/* ============================================================
   6. VISTAS
   ============================================================ */

CREATE OR ALTER VIEW SIS.Vw_DocumentoEntidad
AS
SELECT
    d.PkidDocumento,
    d.Modulo,
    d.SubModulo,
    d.Controlador,
    d.Servicio,
    d.EntidadId,
    d.FkidEmpresaSis,
    d.Titulo,
    d.Descripcion,
    d.NombreOriginal,
    d.NombreAlmacenado,
    d.Extension,
    d.TipoMime,
    d.TamanoBytes,
    d.ModoAlmacenamiento,
    d.RutaRelativa,
    CONVERT(VARCHAR(64), d.HashSha256, 2) AS HashSha256Hex,
    d.VersionDocumento,
    d.EsImagen,
    d.EsPdf,
    d.Activo,
    d.CT_CreatedBy,
    d.CT_CreatedDate,
    d.CT_ModifiedBy,
    d.CT_ModifiedDate
FROM SIS.Documento d;
GO

CREATE OR ALTER VIEW SIS.Vw_DocumentoResumenEntidad
AS
SELECT
    d.Modulo,
    d.SubModulo,
    d.Controlador,
    d.Servicio,
    d.EntidadId,
    d.FkidEmpresaSis,
    COUNT(1) AS TotalDocumentos,
    SUM(d.TamanoBytes) AS TotalBytes,
    MAX(d.CT_CreatedDate) AS UltimaFechaDocumento
FROM SIS.Documento d
WHERE d.Activo = 1
GROUP BY
    d.Modulo,
    d.SubModulo,
    d.Controlador,
    d.Servicio,
    d.EntidadId,
    d.FkidEmpresaSis;
GO

CREATE OR ALTER VIEW SIS.Vw_DocumentoAnotacion
AS
SELECT
    da.PkidDocumentoAnotacion,
    da.FkidDocumento,
    d.Modulo,
    d.SubModulo,
    d.Controlador,
    d.Servicio,
    d.EntidadId,
    d.FkidEmpresaSis,
    ta.Clave AS TipoAnotacion,
    ta.Descripcion AS TipoAnotacionDescripcion,
    da.Comentario,
    da.TextoSeleccionado,
    da.Pagina,
    da.PosicionX,
    da.PosicionY,
    da.Ancho,
    da.Alto,
    da.Color,
    da.Activo,
    da.CT_CreatedBy,
    da.CT_CreatedDate,
    da.CT_ModifiedBy,
    da.CT_ModifiedDate
FROM SIS.DocumentoAnotacion da
JOIN SIS.Documento d
    ON d.PkidDocumento = da.FkidDocumento
JOIN SIS.DocumentoTipoAnotacion ta
    ON ta.PkidDocumentoTipoAnotacion = da.FkidDocumentoTipoAnotacion;
GO

CREATE OR ALTER VIEW SIS.Vw_DocumentoResumenAnotacion
AS
SELECT
    FkidDocumento,
    COUNT(1) AS TotalAnotaciones,
    SUM(CASE WHEN TipoAnotacion = N'COMENTARIO' THEN 1 ELSE 0 END) AS TotalComentarios,
    SUM(CASE WHEN TipoAnotacion = N'RESALTADO' THEN 1 ELSE 0 END) AS TotalResaltados,
    MAX(CT_CreatedDate) AS UltimaAnotacion
FROM SIS.Vw_DocumentoAnotacion
WHERE Activo = 1
GROUP BY FkidDocumento;
GO

/* ============================================================
   7. SPS DOCUMENTOS
   ============================================================ */

CREATE OR ALTER PROCEDURE SIS.spDocumentoGuardar
    @PkidDocumento BIGINT = NULL OUTPUT,
    @Modulo NVARCHAR(120),
    @SubModulo NVARCHAR(120) = NULL,
    @Controlador NVARCHAR(160) = NULL,
    @Servicio NVARCHAR(160) = NULL,
    @EntidadId BIGINT,
    @FkidEmpresaSis INT = NULL,
    @Titulo NVARCHAR(250) = NULL,
    @Descripcion NVARCHAR(MAX) = NULL,
    @NombreOriginal NVARCHAR(260),
    @NombreAlmacenado NVARCHAR(260) = NULL,
    @Extension NVARCHAR(16),
    @TipoMime NVARCHAR(120),
    @TamanoBytes BIGINT,
    @ModoAlmacenamiento NVARCHAR(20),
    @ContenidoArchivo VARBINARY(MAX) = NULL,
    @RutaRelativa NVARCHAR(700) = NULL,
    @IdUser INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @message NVARCHAR(MAX);
    DECLARE @EsImagen BIT = NULL;
    DECLARE @EsPdf BIT = NULL;

    BEGIN TRY
        SET @ModoAlmacenamiento = UPPER(LTRIM(RTRIM(@ModoAlmacenamiento)));
        SET @Extension = LOWER(LTRIM(RTRIM(@Extension)));

        IF LEFT(@Extension, 1) <> N'.'
            SET @Extension = CONCAT(N'.', @Extension);

        IF NULLIF(LTRIM(RTRIM(ISNULL(@NombreAlmacenado, N''))), N'') IS NULL
            SET @NombreAlmacenado = CONCAT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), @Extension);

        SELECT
            @EsImagen = EsImagen,
            @EsPdf = EsPdf
        FROM SIS.DocumentoExtensionPermitida
        WHERE Extension = @Extension
          AND Activo = 1;

        IF @ModoAlmacenamiento NOT IN (N'DATABASE', N'FILESYSTEM')
            THROW 51000, 'Modo de almacenamiento inválido.', 1;

        IF @EsImagen IS NULL AND @EsPdf IS NULL
            THROW 51001, 'Extensión de documento no permitida.', 1;

        IF @EntidadId IS NULL OR @EntidadId <= 0
            THROW 51002, 'EntidadId inválido.', 1;

        IF @ModoAlmacenamiento = N'DATABASE' AND @PkidDocumento IS NULL AND @ContenidoArchivo IS NULL
            THROW 51003, 'El archivo binario es requerido para almacenamiento en base de datos.', 1;

        IF @ModoAlmacenamiento = N'FILESYSTEM'
           AND (
                NULLIF(LTRIM(RTRIM(ISNULL(@RutaRelativa, N''))), N'') IS NULL
                OR @RutaRelativa LIKE N'%..%'
                OR @RutaRelativa LIKE N'%:%'
           )
            THROW 51004, 'Ruta relativa inválida para almacenamiento en carpeta.', 1;

        BEGIN TRANSACTION;

        IF @PkidDocumento IS NULL OR @PkidDocumento = 0
        BEGIN
            INSERT INTO SIS.Documento
            (
                Modulo, SubModulo, Controlador, Servicio, EntidadId, FkidEmpresaSis,
                Titulo, Descripcion, NombreOriginal, NombreAlmacenado, Extension,
                TipoMime, TamanoBytes, ModoAlmacenamiento, ContenidoArchivo,
                RutaRelativa, HashSha256, EsImagen, EsPdf, Activo,
                CT_CreatedBy, CT_CreatedDate
            )
            VALUES
            (
                @Modulo, @SubModulo, @Controlador, @Servicio, @EntidadId, @FkidEmpresaSis,
                @Titulo, @Descripcion, @NombreOriginal, @NombreAlmacenado, @Extension,
                @TipoMime, @TamanoBytes, @ModoAlmacenamiento, @ContenidoArchivo,
                @RutaRelativa,
                CASE WHEN @ContenidoArchivo IS NOT NULL THEN HASHBYTES('SHA2_256', @ContenidoArchivo) ELSE NULL END,
                @EsImagen, @EsPdf, 1,
                @IdUser, SYSDATETIME()
            );

            SET @PkidDocumento = SCOPE_IDENTITY();

            INSERT INTO SIS.DocumentoEvento (FkidDocumento, Evento, Comentario, CT_CreatedBy)
            VALUES (@PkidDocumento, N'CREADO', N'Documento agregado al soporte documental.', @IdUser);

            SET @message = CONCAT(N'Se agregó correctamente el documento ', @NombreOriginal);
        END
        ELSE
        BEGIN
            UPDATE SIS.Documento
            SET
                Titulo = @Titulo,
                Descripcion = @Descripcion,
                NombreOriginal = @NombreOriginal,
                NombreAlmacenado = @NombreAlmacenado,
                Extension = @Extension,
                TipoMime = @TipoMime,
                TamanoBytes = @TamanoBytes,
                ModoAlmacenamiento = @ModoAlmacenamiento,
                ContenidoArchivo = CASE WHEN @ContenidoArchivo IS NULL THEN ContenidoArchivo ELSE @ContenidoArchivo END,
                RutaRelativa = @RutaRelativa,
                HashSha256 = CASE WHEN @ContenidoArchivo IS NULL THEN HashSha256 ELSE HASHBYTES('SHA2_256', @ContenidoArchivo) END,
                EsImagen = @EsImagen,
                EsPdf = @EsPdf,
                CT_ModifiedBy = @IdUser,
                CT_ModifiedDate = SYSDATETIME()
            WHERE PkidDocumento = @PkidDocumento
              AND Activo = 1;

            INSERT INTO SIS.DocumentoEvento (FkidDocumento, Evento, Comentario, CT_CreatedBy)
            VALUES (@PkidDocumento, N'ACTUALIZADO', N'Documento actualizado.', @IdUser);

            SET @message = CONCAT(N'Se actualizó correctamente el documento ', @NombreOriginal);
        END

        COMMIT TRANSACTION;

        SELECT JSON_QUERY(CONCAT(
            '{',
            '"tipo":"OK",',
            '"mensaje":"', REPLACE(REPLACE(@message, '"', ''), ':', ' '), '",',
            '"id":', @PkidDocumento, ',',
            '"liga":""',
            '}'
        )) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SET @message = CONCAT('Error: ', ERROR_MESSAGE(), ' Linea: ', ERROR_LINE());

        SELECT JSON_QUERY(CONCAT(
            '{',
            '"tipo":"ERROR",',
            '"mensaje":"', REPLACE(REPLACE(@message, '"', ''), ':', ' '), '",',
            '"liga":""',
            '}'
        )) AS ResultJson;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE SIS.spDocumentoObtenerPorEntidad
    @Modulo NVARCHAR(120),
    @SubModulo NVARCHAR(120) = NULL,
    @Controlador NVARCHAR(160) = NULL,
    @Servicio NVARCHAR(160) = NULL,
    @EntidadId BIGINT,
    @FkidEmpresaSis INT = NULL,
    @IncluirInactivos BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM SIS.Vw_DocumentoEntidad
    WHERE Modulo = @Modulo
      AND ISNULL(SubModulo, N'') = ISNULL(@SubModulo, N'')
      AND ISNULL(Controlador, N'') = ISNULL(@Controlador, N'')
      AND ISNULL(Servicio, N'') = ISNULL(@Servicio, N'')
      AND EntidadId = @EntidadId
      AND ISNULL(FkidEmpresaSis, 0) = ISNULL(@FkidEmpresaSis, 0)
      AND (@IncluirInactivos = 1 OR Activo = 1)
    ORDER BY CT_CreatedDate DESC;
END
GO

CREATE OR ALTER PROCEDURE SIS.spDocumentoObtenerContenido
    @PkidDocumento BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PkidDocumento,
        NombreOriginal,
        NombreAlmacenado,
        Extension,
        TipoMime,
        TamanoBytes,
        ModoAlmacenamiento,
        ContenidoArchivo,
        RutaRelativa
    FROM SIS.Documento
    WHERE PkidDocumento = @PkidDocumento
      AND Activo = 1;
END
GO

CREATE OR ALTER PROCEDURE SIS.spDocumentoEliminar
    @PkidDocumento BIGINT,
    @IdUser INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @message NVARCHAR(MAX);

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE SIS.Documento
        SET Activo = 0,
            CT_ModifiedBy = @IdUser,
            CT_ModifiedDate = SYSDATETIME()
        WHERE PkidDocumento = @PkidDocumento
          AND Activo = 1;

        INSERT INTO SIS.DocumentoEvento (FkidDocumento, Evento, Comentario, CT_CreatedBy)
        VALUES (@PkidDocumento, N'ELIMINADO', N'Documento eliminado lógicamente.', @IdUser);

        COMMIT TRANSACTION;

        SET @message = N'Se eliminó correctamente el documento.';

        SELECT JSON_QUERY(CONCAT(
            '{',
            '"tipo":"OK",',
            '"mensaje":"', @message, '",',
            '"liga":""',
            '}'
        )) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SET @message = CONCAT('Error: ', ERROR_MESSAGE(), ' Linea: ', ERROR_LINE());

        SELECT JSON_QUERY(CONCAT(
            '{',
            '"tipo":"ERROR",',
            '"mensaje":"', REPLACE(REPLACE(@message, '"', ''), ':', ' '), '",',
            '"liga":""',
            '}'
        )) AS ResultJson;
    END CATCH
END
GO

/* ============================================================
   8. SPS ANOTACIONES
   ============================================================ */

CREATE OR ALTER PROCEDURE SIS.spDocumentoAnotacionCrear
    @FkidDocumento BIGINT,
    @TipoAnotacion NVARCHAR(30),
    @Comentario NVARCHAR(MAX) = NULL,
    @TextoSeleccionado NVARCHAR(MAX) = NULL,
    @Pagina INT = NULL,
    @PosicionX DECIMAL(9,6) = NULL,
    @PosicionY DECIMAL(9,6) = NULL,
    @Ancho DECIMAL(9,6) = NULL,
    @Alto DECIMAL(9,6) = NULL,
    @Color NVARCHAR(20) = N'#FFE066',
    @IdUser INT,
    @PkidDocumentoAnotacion BIGINT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @message NVARCHAR(MAX);
    DECLARE @FkidDocumentoTipoAnotacion INT;

    BEGIN TRY
        SELECT @FkidDocumentoTipoAnotacion = PkidDocumentoTipoAnotacion
        FROM SIS.DocumentoTipoAnotacion
        WHERE Clave = UPPER(LTRIM(RTRIM(@TipoAnotacion)))
          AND Activo = 1;

        IF @FkidDocumentoTipoAnotacion IS NULL
            THROW 51030, 'Tipo de anotación inválido.', 1;

        IF NOT EXISTS (SELECT 1 FROM SIS.Documento WHERE PkidDocumento = @FkidDocumento AND Activo = 1)
            THROW 51031, 'Documento no encontrado o inactivo.', 1;

        IF UPPER(LTRIM(RTRIM(@TipoAnotacion))) = N'COMENTARIO'
           AND NULLIF(LTRIM(RTRIM(ISNULL(@Comentario, N''))), N'') IS NULL
            THROW 51032, 'El comentario es requerido.', 1;

        IF UPPER(LTRIM(RTRIM(@TipoAnotacion))) = N'RESALTADO'
           AND (
                @Pagina IS NULL
                OR @PosicionX IS NULL
                OR @PosicionY IS NULL
                OR @Ancho IS NULL
                OR @Alto IS NULL
           )
            THROW 51033, 'El resaltado requiere página y coordenadas.', 1;

        BEGIN TRANSACTION;

        INSERT INTO SIS.DocumentoAnotacion
        (
            FkidDocumento,
            FkidDocumentoTipoAnotacion,
            Comentario,
            TextoSeleccionado,
            Pagina,
            PosicionX,
            PosicionY,
            Ancho,
            Alto,
            Color,
            Activo,
            CT_CreatedBy,
            CT_CreatedDate
        )
        VALUES
        (
            @FkidDocumento,
            @FkidDocumentoTipoAnotacion,
            @Comentario,
            @TextoSeleccionado,
            @Pagina,
            @PosicionX,
            @PosicionY,
            @Ancho,
            @Alto,
            ISNULL(@Color, N'#FFE066'),
            1,
            @IdUser,
            SYSDATETIME()
        );

        SET @PkidDocumentoAnotacion = SCOPE_IDENTITY();

        INSERT INTO SIS.DocumentoEvento (FkidDocumento, Evento, Comentario, CT_CreatedBy)
        VALUES (@FkidDocumento, N'ANOTACION_CREADA', N'Se agregó una anotación al documento.', @IdUser);

        COMMIT TRANSACTION;

        SET @message = N'Se agregó correctamente la anotación.';

        SELECT JSON_QUERY(CONCAT(
            '{',
            '"tipo":"OK",',
            '"mensaje":"', @message, '",',
            '"id":', @PkidDocumentoAnotacion, ',',
            '"liga":""',
            '}'
        )) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SET @message = CONCAT('Error: ', ERROR_MESSAGE(), ' Linea: ', ERROR_LINE());

        SELECT JSON_QUERY(CONCAT(
            '{',
            '"tipo":"ERROR",',
            '"mensaje":"', REPLACE(REPLACE(@message, '"', ''), ':', ' '), '",',
            '"liga":""',
            '}'
        )) AS ResultJson;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE SIS.spDocumentoAnotacionObtener
    @FkidDocumento BIGINT,
    @IncluirInactivos BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM SIS.Vw_DocumentoAnotacion
    WHERE FkidDocumento = @FkidDocumento
      AND (@IncluirInactivos = 1 OR Activo = 1)
    ORDER BY CT_CreatedDate ASC;
END
GO

CREATE OR ALTER PROCEDURE SIS.spDocumentoAnotacionEliminar
    @PkidDocumentoAnotacion BIGINT,
    @IdUser INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @message NVARCHAR(MAX);
    DECLARE @FkidDocumento BIGINT;

    BEGIN TRY
        SELECT @FkidDocumento = FkidDocumento
        FROM SIS.DocumentoAnotacion
        WHERE PkidDocumentoAnotacion = @PkidDocumentoAnotacion
          AND Activo = 1;

        IF @FkidDocumento IS NULL
            THROW 51040, 'Anotación no encontrada o inactiva.', 1;

        BEGIN TRANSACTION;

        UPDATE SIS.DocumentoAnotacion
        SET Activo = 0,
            CT_ModifiedBy = @IdUser,
            CT_ModifiedDate = SYSDATETIME()
        WHERE PkidDocumentoAnotacion = @PkidDocumentoAnotacion
          AND Activo = 1;

        INSERT INTO SIS.DocumentoEvento (FkidDocumento, Evento, Comentario, CT_CreatedBy)
        VALUES (@FkidDocumento, N'ANOTACION_ELIMINADA', N'Se eliminó lógicamente una anotación.', @IdUser);

        COMMIT TRANSACTION;

        SET @message = N'Se eliminó correctamente la anotación.';

        SELECT JSON_QUERY(CONCAT(
            '{',
            '"tipo":"OK",',
            '"mensaje":"', @message, '",',
            '"liga":""',
            '}'
        )) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SET @message = CONCAT('Error: ', ERROR_MESSAGE(), ' Linea: ', ERROR_LINE());

        SELECT JSON_QUERY(CONCAT(
            '{',
            '"tipo":"ERROR",',
            '"mensaje":"', REPLACE(REPLACE(@message, '"', ''), ':', ' '), '",',
            '"liga":""',
            '}'
        )) AS ResultJson;
    END CATCH
END
GO


USE [GestionEmpresarial]
GO

CREATE OR ALTER VIEW SIS.Vw_DocumentoResumenEntidad
AS
SELECT
    d.Modulo,
    d.SubModulo,
    d.Controlador,
    d.Servicio,
    d.EntidadId,
    d.FkidEmpresaSis,
    COUNT(1) AS TotalDocumentos,
    SUM(d.TamanoBytes) AS TotalBytes,
    MAX(d.CT_CreatedDate) AS UltimaFechaDocumento
FROM SIS.Documento d
WHERE d.Activo = 1
GROUP BY
    d.Modulo,
    d.SubModulo,
    d.Controlador,
    d.Servicio,
    d.EntidadId,
    d.FkidEmpresaSis;
GO