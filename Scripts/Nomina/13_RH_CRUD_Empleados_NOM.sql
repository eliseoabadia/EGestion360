SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/*
    RH de Nomina
    - Alinea las vistas migradas con NOM.CatalogoSimple.
    - Completa el mantenimiento faltante de expedientes.
    - Conserva bajas logicas y campos de auditoria.
*/

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_PersonaDependiente_Parentesco')
AND NOT EXISTS
(
    SELECT 1
    FROM [NOM].[PersonaDependiente] d
    LEFT JOIN [NOM].[CatalogoSimple] c
        ON c.[PKIdCatalogoSimple] = d.[FKIdParentesco_SIS]
       AND c.[Catalogo] = N'Tipo_Parentesco'
    WHERE d.[FKIdParentesco_SIS] IS NOT NULL
      AND c.[PKIdCatalogoSimple] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[PersonaDependiente] WITH CHECK
    ADD CONSTRAINT [FK_NOM_PersonaDependiente_Parentesco]
        FOREIGN KEY ([FKIdParentesco_SIS]) REFERENCES [NOM].[CatalogoSimple] ([PKIdCatalogoSimple]);
END
GO

CREATE OR ALTER VIEW [NOM].[Vw_EmpleadoExpediente]
AS
SELECT
    e.[PKIdExpediente],
    e.[FKIdPersona_NOM],
    e.[NombreDocumento],
    e.[Ruta],
    e.[Descripcion],
    e.[FechaExpedicion],
    e.[NecesitaRenovacion],
    e.[FechaRenovacion],
    e.[FKIdTipoExpediente_NOM],
    e.[UsuarioCreacion],
    e.[FechaCreacion],
    e.[UsuarioModificacion],
    e.[FechaModificacion],
    e.[Activo],
    p.[Clave] AS [ClavePersona],
    CONCAT_WS(N' ', p.[Nombre], p.[Paterno], p.[Materno]) AS [NombreCompleto],
    p.[RFC],
    p.[Curp] AS [CURP],
    tipo.[Descripcion] AS [TipoExpedienteDescripcion],
    tipo.[Activo] AS [TipoExpedienteActivo]
FROM [NOM].[EmpleadoExpediente] e
INNER JOIN [NOM].[Persona] p ON p.[PKIdPersona] = e.[FKIdPersona_NOM] AND p.[Activo] = 1
LEFT JOIN [NOM].[CatalogoSimple] tipo
    ON tipo.[PKIdCatalogoSimple] = e.[FKIdTipoExpediente_NOM]
   AND tipo.[Catalogo] = N'Tipo_Expediente'
WHERE e.[Activo] = 1;
GO

CREATE OR ALTER VIEW [NOM].[Vw_PersonaDependiente]
AS
SELECT
    d.[PKIdDependiente],
    d.[FKIdPersona_NOM],
    d.[Nombre],
    d.[FKIdParentesco_SIS],
    d.[Parentesco],
    d.[FechaNacimiento],
    d.[UsuarioCreacion],
    d.[FechaCreacion],
    d.[UsuarioModificacion],
    d.[FechaModificacion],
    d.[Activo],
    p.[Clave] AS [ClavePersona],
    CONCAT_WS(N' ', p.[Nombre], p.[Paterno], p.[Materno]) AS [NombreCompletoPersona],
    p.[RFC],
    p.[Curp] AS [CURP],
    parentesco.[Descripcion] AS [ParentescoDescripcion],
    parentesco.[Activo] AS [ParentescoActivo]
FROM [NOM].[PersonaDependiente] d
INNER JOIN [NOM].[Persona] p ON p.[PKIdPersona] = d.[FKIdPersona_NOM] AND p.[Activo] = 1
LEFT JOIN [NOM].[CatalogoSimple] parentesco
    ON parentesco.[PKIdCatalogoSimple] = d.[FKIdParentesco_SIS]
   AND parentesco.[Catalogo] = N'Tipo_Parentesco'
WHERE d.[Activo] = 1;
GO

CREATE OR ALTER VIEW [NOM].[Vw_Incidencia]
AS
SELECT
    i.[PKIdIncidencia],
    i.[FKIdPersona_NOM],
    i.[FKIdTipoIncidencia_NOM],
    i.[Fecha],
    i.[Comentario],
    i.[FKIdTipoJustificacion_NOM],
    i.[AplicaDescuento],
    i.[ComentarioJustificacion],
    i.[FKIdPeriodoQuincenal_SIS],
    i.[UsuarioCreacion],
    i.[FechaCreacion],
    i.[UsuarioModificacion],
    i.[FechaModificacion],
    i.[Activo],
    p.[Clave] AS [ClavePersona],
    CONCAT_WS(N' ', p.[Nombre], p.[Paterno], p.[Materno]) AS [NombreCompleto],
    p.[RFC],
    p.[Curp] AS [CURP],
    tipo.[Descripcion] AS [TipoIncidenciaDescripcion],
    CONVERT(float, tipo.[ValorDecimal1]) AS [TipoIncidenciaDiasPenalizacion],
    tipo.[Activo] AS [TipoIncidenciaActivo],
    justificacion.[Descripcion] AS [TipoJustificacionDescripcion],
    justificacion.[Activo] AS [TipoJustificacionActivo]
FROM [NOM].[Incidencia] i
INNER JOIN [NOM].[Persona] p ON p.[PKIdPersona] = i.[FKIdPersona_NOM] AND p.[Activo] = 1
LEFT JOIN [NOM].[CatalogoSimple] tipo
    ON tipo.[PKIdCatalogoSimple] = i.[FKIdTipoIncidencia_NOM]
   AND tipo.[Catalogo] = N'Tipo_Incidencia'
LEFT JOIN [NOM].[CatalogoSimple] justificacion
    ON justificacion.[PKIdCatalogoSimple] = i.[FKIdTipoJustificacion_NOM]
   AND justificacion.[Catalogo] = N'Tipo_Justificacion'
WHERE i.[Activo] = 1;
GO

CREATE OR ALTER PROCEDURE [NOM].[SP_MantenimientoEmpleadoExpediente]
    @Action int,
    @PKIdExpediente int = NULL,
    @FKIdPersona_NOM int = NULL,
    @NombreDocumento nvarchar(255) = NULL,
    @Ruta nvarchar(1000) = NULL,
    @Descripcion nvarchar(1000) = NULL,
    @FechaExpedicion date = NULL,
    @NecesitaRenovacion bit = NULL,
    @FechaRenovacion date = NULL,
    @FKIdTipoExpediente_NOM int = NULL,
    @Activo bit = NULL,
    @IdUser int,
    @Id int = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Mensaje nvarchar(4000);

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3)
            THROW 54100, N'Accion invalida para mantenimiento de expediente.', 1;

        IF @IdUser IS NULL OR @IdUser <= 0
            THROW 54101, N'El usuario es obligatorio.', 1;

        BEGIN TRAN;

        IF @Action IN (1, 2)
        BEGIN
            IF @FKIdPersona_NOM IS NULL OR NOT EXISTS
                (SELECT 1 FROM [NOM].[Persona] WHERE [PKIdPersona] = @FKIdPersona_NOM AND [Activo] = 1)
                THROW 54102, N'El empleado no existe o esta inactivo.', 1;

            IF NULLIF(LTRIM(RTRIM(@NombreDocumento)), N'') IS NULL
                THROW 54103, N'El nombre del documento es obligatorio.', 1;

            IF @FKIdTipoExpediente_NOM IS NOT NULL AND NOT EXISTS
            (
                SELECT 1 FROM [NOM].[CatalogoSimple]
                WHERE [PKIdCatalogoSimple] = @FKIdTipoExpediente_NOM
                  AND [Catalogo] = N'Tipo_Expediente'
                  AND [Activo] = 1
            )
                THROW 54104, N'El tipo de expediente no existe o esta inactivo.', 1;

            IF ISNULL(@NecesitaRenovacion, 0) = 1 AND @FechaRenovacion IS NULL
                THROW 54105, N'La fecha de renovacion es obligatoria.', 1;

            IF @FechaExpedicion IS NOT NULL AND @FechaRenovacion IS NOT NULL AND @FechaRenovacion < @FechaExpedicion
                THROW 54106, N'La fecha de renovacion no puede ser anterior a la expedicion.', 1;
        END

        IF @Action = 1
        BEGIN
            INSERT INTO [NOM].[EmpleadoExpediente]
            (
                [FKIdPersona_NOM], [NombreDocumento], [Ruta], [Descripcion], [FechaExpedicion],
                [NecesitaRenovacion], [FechaRenovacion], [FKIdTipoExpediente_NOM],
                [UsuarioCreacion], [FechaCreacion], [Activo]
            )
            VALUES
            (
                @FKIdPersona_NOM, LTRIM(RTRIM(@NombreDocumento)), NULLIF(LTRIM(RTRIM(@Ruta)), N''),
                NULLIF(LTRIM(RTRIM(@Descripcion)), N''), @FechaExpedicion, ISNULL(@NecesitaRenovacion, 0),
                CASE WHEN ISNULL(@NecesitaRenovacion, 0) = 1 THEN @FechaRenovacion END,
                @FKIdTipoExpediente_NOM, @IdUser, SYSDATETIME(), ISNULL(@Activo, 1)
            );

            SET @Id = CONVERT(int, SCOPE_IDENTITY());
            SET @Mensaje = N'Expediente creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            IF @PKIdExpediente IS NULL OR NOT EXISTS
                (SELECT 1 FROM [NOM].[EmpleadoExpediente] WHERE [PKIdExpediente] = @PKIdExpediente AND [Activo] = 1)
                THROW 54107, N'El expediente no existe o esta inactivo.', 1;

            UPDATE [NOM].[EmpleadoExpediente]
            SET [FKIdPersona_NOM] = @FKIdPersona_NOM,
                [NombreDocumento] = LTRIM(RTRIM(@NombreDocumento)),
                [Ruta] = NULLIF(LTRIM(RTRIM(@Ruta)), N''),
                [Descripcion] = NULLIF(LTRIM(RTRIM(@Descripcion)), N''),
                [FechaExpedicion] = @FechaExpedicion,
                [NecesitaRenovacion] = ISNULL(@NecesitaRenovacion, 0),
                [FechaRenovacion] = CASE WHEN ISNULL(@NecesitaRenovacion, 0) = 1 THEN @FechaRenovacion END,
                [FKIdTipoExpediente_NOM] = @FKIdTipoExpediente_NOM,
                [Activo] = ISNULL(@Activo, [Activo]),
                [UsuarioModificacion] = @IdUser,
                [FechaModificacion] = SYSDATETIME()
            WHERE [PKIdExpediente] = @PKIdExpediente;

            SET @Id = @PKIdExpediente;
            SET @Mensaje = N'Expediente actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            IF @PKIdExpediente IS NULL OR NOT EXISTS
                (SELECT 1 FROM [NOM].[EmpleadoExpediente] WHERE [PKIdExpediente] = @PKIdExpediente AND [Activo] = 1)
                THROW 54107, N'El expediente no existe o ya esta inactivo.', 1;

            UPDATE [NOM].[EmpleadoExpediente]
            SET [Activo] = 0,
                [UsuarioModificacion] = @IdUser,
                [FechaModificacion] = SYSDATETIME()
            WHERE [PKIdExpediente] = @PKIdExpediente;

            SET @Id = @PKIdExpediente;
            SET @Mensaje = N'Expediente eliminado correctamente.';
        END

        COMMIT;

        SELECT [ResultJson] =
        (
            SELECT N'success' AS [Tipo], @Mensaje AS [Mensaje], CONCAT(N'idExpediente:', @Id) AS [Liga]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT [ResultJson] =
        (
            SELECT N'error' AS [Tipo], ERROR_MESSAGE() AS [Mensaje], NULL AS [Liga]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END CATCH
END
GO
