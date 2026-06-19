SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'NOM')
    EXEC(N'CREATE SCHEMA [NOM]');
GO

-- Tabla hija faltante para RH_Dependiente. No duplica datos de RH legacy; queda en NOM.
IF OBJECT_ID(N'[NOM].[PersonaDependiente]', N'U') IS NULL
BEGIN
    CREATE TABLE [NOM].[PersonaDependiente] (
        [PKIdDependiente] int IDENTITY(1,1) NOT NULL,
        [FKIdPersona_NOM] int NOT NULL,
        [Nombre] nvarchar(300) NOT NULL,
        [FKIdParentesco_SIS] int NULL,
        [Parentesco] nvarchar(120) NULL,
        [FechaNacimiento] date NULL,
        [UsuarioCreacion] int NULL,
        [FechaCreacion] datetime2(6) NULL,
        [UsuarioModificacion] int NULL,
        [FechaModificacion] datetime2(6) NULL,
        [Activo] bit NOT NULL CONSTRAINT [DF_NOM_PersonaDependiente_Activo] DEFAULT 1,
        CONSTRAINT [PK_NOM_PersonaDependiente] PRIMARY KEY ([PKIdDependiente])
    );
END
GO

-- Llaves foraneas principales RH/NOM. Se agregan solo si los datos ya son consistentes.
IF OBJECT_ID(N'[NOM].[Persona]', N'U') IS NOT NULL
AND COL_LENGTH(N'NOM.Persona', N'FKIdEmpresaNomina_NOM') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_Persona_EmpresaNomina')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[Persona] p
    LEFT JOIN [NOM].[EmpresaNomina] e ON e.[PKIdEmpresaNomina] = p.[FKIdEmpresaNomina_NOM]
    WHERE p.[FKIdEmpresaNomina_NOM] IS NOT NULL
      AND e.[PKIdEmpresaNomina] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[Persona] WITH CHECK
    ADD CONSTRAINT [FK_NOM_Persona_EmpresaNomina]
    FOREIGN KEY ([FKIdEmpresaNomina_NOM]) REFERENCES [NOM].[EmpresaNomina] ([PKIdEmpresaNomina]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_EmpleadoExpediente_Persona')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[EmpleadoExpediente] e
    LEFT JOIN [NOM].[Persona] p ON p.[PKIdPersona] = e.[FKIdPersona_NOM]
    WHERE p.[PKIdPersona] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[EmpleadoExpediente] WITH CHECK
    ADD CONSTRAINT [FK_NOM_EmpleadoExpediente_Persona]
    FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_EmpleadoExpediente_TipoExpediente')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[EmpleadoExpediente] e
    LEFT JOIN [NOM].[CatalogoSimple] c ON c.[PKIdCatalogoSimple] = e.[FKIdTipoExpediente_NOM]
    WHERE e.[FKIdTipoExpediente_NOM] IS NOT NULL
      AND c.[PKIdCatalogoSimple] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[EmpleadoExpediente] WITH CHECK
    ADD CONSTRAINT [FK_NOM_EmpleadoExpediente_TipoExpediente]
    FOREIGN KEY ([FKIdTipoExpediente_NOM]) REFERENCES [NOM].[CatalogoSimple] ([PKIdCatalogoSimple]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_ContratoLaboral_EmpresaNomina')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[ContratoLaboral] c
    LEFT JOIN [NOM].[EmpresaNomina] e ON e.[PKIdEmpresaNomina] = c.[FKIdEmpresaNomina_NOM]
    WHERE e.[PKIdEmpresaNomina] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[ContratoLaboral] WITH CHECK
    ADD CONSTRAINT [FK_NOM_ContratoLaboral_EmpresaNomina]
    FOREIGN KEY ([FKIdEmpresaNomina_NOM]) REFERENCES [NOM].[EmpresaNomina] ([PKIdEmpresaNomina]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_ContratoLaboral_Persona')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[ContratoLaboral] c
    LEFT JOIN [NOM].[Persona] p ON p.[PKIdPersona] = c.[FKIdPersona_NOM]
    WHERE p.[PKIdPersona] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[ContratoLaboral] WITH CHECK
    ADD CONSTRAINT [FK_NOM_ContratoLaboral_Persona]
    FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_ContratoLaboral_Puesto')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[ContratoLaboral] c
    LEFT JOIN [NOM].[Puesto] p ON p.[PKIdPuesto] = c.[FKIdPuesto_NOM]
    WHERE p.[PKIdPuesto] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[ContratoLaboral] WITH CHECK
    ADD CONSTRAINT [FK_NOM_ContratoLaboral_Puesto]
    FOREIGN KEY ([FKIdPuesto_NOM]) REFERENCES [NOM].[Puesto] ([PKIdPuesto]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_ContratoLaboral_Nombramiento')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[ContratoLaboral] c
    LEFT JOIN [NOM].[Nombramiento] n ON n.[PKIdNombramiento] = c.[FKIdNombramiento_NOM]
    WHERE c.[FKIdNombramiento_NOM] IS NOT NULL
      AND n.[PKIdNombramiento] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[ContratoLaboral] WITH CHECK
    ADD CONSTRAINT [FK_NOM_ContratoLaboral_Nombramiento]
    FOREIGN KEY ([FKIdNombramiento_NOM]) REFERENCES [NOM].[Nombramiento] ([PKIdNombramiento]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_PersonaDependiente_Persona')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[PersonaDependiente] d
    LEFT JOIN [NOM].[Persona] p ON p.[PKIdPersona] = d.[FKIdPersona_NOM]
    WHERE p.[PKIdPersona] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[PersonaDependiente] WITH CHECK
    ADD CONSTRAINT [FK_NOM_PersonaDependiente_Persona]
    FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_Incidencia_Persona')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[Incidencia] i
    LEFT JOIN [NOM].[Persona] p ON p.[PKIdPersona] = i.[FKIdPersona_NOM]
    WHERE p.[PKIdPersona] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[Incidencia] WITH CHECK
    ADD CONSTRAINT [FK_NOM_Incidencia_Persona]
    FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_Incidencia_TipoIncidencia')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[Incidencia] i
    LEFT JOIN [NOM].[CatalogoSimple] c ON c.[PKIdCatalogoSimple] = i.[FKIdTipoIncidencia_NOM]
    WHERE i.[FKIdTipoIncidencia_NOM] IS NOT NULL
      AND c.[PKIdCatalogoSimple] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[Incidencia] WITH CHECK
    ADD CONSTRAINT [FK_NOM_Incidencia_TipoIncidencia]
    FOREIGN KEY ([FKIdTipoIncidencia_NOM]) REFERENCES [NOM].[CatalogoSimple] ([PKIdCatalogoSimple]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_Incidencia_TipoJustificacion')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[Incidencia] i
    LEFT JOIN [NOM].[CatalogoSimple] c ON c.[PKIdCatalogoSimple] = i.[FKIdTipoJustificacion_NOM]
    WHERE i.[FKIdTipoJustificacion_NOM] IS NOT NULL
      AND c.[PKIdCatalogoSimple] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[Incidencia] WITH CHECK
    ADD CONSTRAINT [FK_NOM_Incidencia_TipoJustificacion]
    FOREIGN KEY ([FKIdTipoJustificacion_NOM]) REFERENCES [NOM].[CatalogoSimple] ([PKIdCatalogoSimple]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_PersonaPension_Persona')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[PersonaPension] pe
    LEFT JOIN [NOM].[Persona] p ON p.[PKIdPersona] = pe.[FKIdPersona_NOM]
    WHERE p.[PKIdPersona] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[PersonaPension] WITH CHECK
    ADD CONSTRAINT [FK_NOM_PersonaPension_Persona]
    FOREIGN KEY ([FKIdPersona_NOM]) REFERENCES [NOM].[Persona] ([PKIdPersona]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_NOM_PersonaPension_TipoPension')
AND NOT EXISTS (
    SELECT 1
    FROM [NOM].[PersonaPension] pe
    LEFT JOIN [NOM].[TipoPension] tp ON tp.[PKIdTipoPension] = pe.[FKIdTipoPension_NOM]
    WHERE pe.[FKIdTipoPension_NOM] IS NOT NULL
      AND tp.[PKIdTipoPension] IS NULL
)
BEGIN
    ALTER TABLE [NOM].[PersonaPension] WITH CHECK
    ADD CONSTRAINT [FK_NOM_PersonaPension_TipoPension]
    FOREIGN KEY ([FKIdTipoPension_NOM]) REFERENCES [NOM].[TipoPension] ([PKIdTipoPension]);
END
GO

-- Indices para lectura operativa.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NOM_EmpleadoExpediente_Persona' AND object_id = OBJECT_ID(N'[NOM].[EmpleadoExpediente]'))
    CREATE INDEX [IX_NOM_EmpleadoExpediente_Persona] ON [NOM].[EmpleadoExpediente] ([FKIdPersona_NOM], [Activo], [FechaExpedicion] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NOM_Incidencia_PersonaFecha' AND object_id = OBJECT_ID(N'[NOM].[Incidencia]'))
    CREATE INDEX [IX_NOM_Incidencia_PersonaFecha] ON [NOM].[Incidencia] ([FKIdPersona_NOM], [Activo], [Fecha] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NOM_PersonaPension_Persona' AND object_id = OBJECT_ID(N'[NOM].[PersonaPension]'))
    CREATE INDEX [IX_NOM_PersonaPension_Persona] ON [NOM].[PersonaPension] ([FKIdPersona_NOM], [Activo], [FechaInicio] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NOM_PersonaDependiente_PersonaActivo' AND object_id = OBJECT_ID(N'[NOM].[PersonaDependiente]'))
    CREATE INDEX [IX_NOM_PersonaDependiente_PersonaActivo] ON [NOM].[PersonaDependiente] ([FKIdPersona_NOM], [Activo]);
GO

CREATE OR ALTER VIEW [NOM].[Vw_RhEntidadNomina]
AS
SELECT
    N'Persona' AS Entidad,
    p.[PKIdPersona] AS Id,
    p.[PKIdPersona] AS PersonaId,
    p.[FKIdEmpresaNomina_NOM] AS EmpresaId,
    empresa.[RazonSocial] AS Empresa,
    CONCAT_WS(N' ', p.[Nombre], p.[Paterno], p.[Materno]) AS Persona,
    p.[Clave] AS Empleado,
    p.[Clave],
    CONCAT_WS(N' ', p.[Nombre], p.[Paterno], p.[Materno]) AS Titulo,
    p.[PUESTO] AS Descripcion,
    p.[TIPO_CONTRATACION] AS Tipo,
    CASE WHEN p.[Activo] = 1 THEN N'Activo' ELSE N'Inactivo' END AS Estatus,
    CAST(p.[Fecha_de_Inicio] AS datetime2(6)) AS Fecha,
    CAST(p.[Fecha_de_Inicio] AS datetime2(6)) AS FechaInicio,
    CAST(p.[Fecha_Fin] AS datetime2(6)) AS FechaFin,
    CAST(p.[SUELDO_BASE] AS decimal(18,2)) AS Importe,
    CAST(NULL AS decimal(18,4)) AS Porcentaje,
    p.[RFC] AS Documento,
    p.[Curp] AS Referencia,
    CONCAT_WS(N' | ', p.[CORREO_ELECTRONICO], p.[Telefono_movil], p.[REG_IMSS]) AS Observaciones,
    p.[Activo],
    p.[UsuarioCreacion],
    CAST(p.[FechaCreacion] AS datetime2(6)) AS FechaCreacion,
    p.[UsuarioModificacion],
    CAST(p.[FechaModificacion] AS datetime2(6)) AS FechaModificacion
FROM [NOM].[Persona] p
LEFT JOIN [NOM].[EmpresaNomina] empresa ON empresa.[PKIdEmpresaNomina] = p.[FKIdEmpresaNomina_NOM]

UNION ALL
SELECT
    N'Expediente',
    e.[PKIdExpediente],
    e.[FKIdPersona_NOM],
    persona.[FKIdEmpresaNomina_NOM],
    empresa.[RazonSocial],
    CONCAT_WS(N' ', persona.[Nombre], persona.[Paterno], persona.[Materno]),
    persona.[Clave],
    CAST(e.[PKIdExpediente] AS nvarchar(50)),
    e.[NombreDocumento],
    e.[Descripcion],
    tipo.[Descripcion],
    CASE WHEN e.[NecesitaRenovacion] = 1 THEN N'Requiere renovacion' ELSE N'Vigente' END,
    CAST(e.[FechaExpedicion] AS datetime2(6)),
    CAST(e.[FechaExpedicion] AS datetime2(6)),
    CAST(e.[FechaRenovacion] AS datetime2(6)),
    CAST(NULL AS decimal(18,2)),
    CAST(NULL AS decimal(18,4)),
    e.[Ruta],
    tipo.[Descripcion],
    e.[Ruta],
    e.[Activo],
    e.[UsuarioCreacion],
    e.[FechaCreacion],
    e.[UsuarioModificacion],
    e.[FechaModificacion]
FROM [NOM].[EmpleadoExpediente] e
LEFT JOIN [NOM].[Persona] persona ON persona.[PKIdPersona] = e.[FKIdPersona_NOM]
LEFT JOIN [NOM].[EmpresaNomina] empresa ON empresa.[PKIdEmpresaNomina] = persona.[FKIdEmpresaNomina_NOM]
LEFT JOIN [NOM].[CatalogoSimple] tipo ON tipo.[PKIdCatalogoSimple] = e.[FKIdTipoExpediente_NOM]

UNION ALL
SELECT
    N'Contrato',
    c.[PKIdContratoLaboral],
    c.[FKIdPersona_NOM],
    c.[FKIdEmpresaNomina_NOM],
    empresa.[RazonSocial],
    CONCAT_WS(N' ', persona.[Nombre], persona.[Paterno], persona.[Materno]),
    persona.[Clave],
    c.[NumeroContrato],
    CONCAT(N'Contrato ', c.[NumeroContrato]),
    puesto.[Nombre],
    COALESCE(c.[TipoContratacion], nombramiento.[Descripcion]),
    CASE WHEN c.[Activo] = 1 THEN N'Activo' ELSE N'Inactivo' END,
    CAST(c.[FechaInicio] AS datetime2(6)),
    CAST(c.[FechaInicio] AS datetime2(6)),
    CAST(c.[FechaFin] AS datetime2(6)),
    c.[SueldoMensual],
    CAST(NULL AS decimal(18,4)),
    c.[NumeroContrato],
    c.[Departamento],
    c.[Vigencia],
    c.[Activo],
    c.[UsuarioCreacion],
    c.[FechaCreacion],
    c.[UsuarioModificacion],
    c.[FechaModificacion]
FROM [NOM].[ContratoLaboral] c
LEFT JOIN [NOM].[Persona] persona ON persona.[PKIdPersona] = c.[FKIdPersona_NOM]
LEFT JOIN [NOM].[EmpresaNomina] empresa ON empresa.[PKIdEmpresaNomina] = c.[FKIdEmpresaNomina_NOM]
LEFT JOIN [NOM].[Puesto] puesto ON puesto.[PKIdPuesto] = c.[FKIdPuesto_NOM]
LEFT JOIN [NOM].[Nombramiento] nombramiento ON nombramiento.[PKIdNombramiento] = c.[FKIdNombramiento_NOM]

UNION ALL
SELECT
    N'Dependiente',
    d.[PKIdDependiente],
    d.[FKIdPersona_NOM],
    persona.[FKIdEmpresaNomina_NOM],
    empresa.[RazonSocial],
    CONCAT_WS(N' ', persona.[Nombre], persona.[Paterno], persona.[Materno]),
    persona.[Clave],
    CAST(d.[PKIdDependiente] AS nvarchar(50)),
    d.[Nombre],
    d.[Parentesco],
    COALESCE(d.[Parentesco], N'Dependiente'),
    CASE WHEN d.[Activo] = 1 THEN N'Activo' ELSE N'Inactivo' END,
    CAST(d.[FechaNacimiento] AS datetime2(6)),
    CAST(d.[FechaNacimiento] AS datetime2(6)),
    CAST(NULL AS datetime2(6)),
    CAST(NULL AS decimal(18,2)),
    CAST(NULL AS decimal(18,4)),
    CAST(d.[FKIdParentesco_SIS] AS nvarchar(200)),
    d.[Parentesco],
    CAST(NULL AS nvarchar(2000)),
    d.[Activo],
    d.[UsuarioCreacion],
    d.[FechaCreacion],
    d.[UsuarioModificacion],
    d.[FechaModificacion]
FROM [NOM].[PersonaDependiente] d
LEFT JOIN [NOM].[Persona] persona ON persona.[PKIdPersona] = d.[FKIdPersona_NOM]
LEFT JOIN [NOM].[EmpresaNomina] empresa ON empresa.[PKIdEmpresaNomina] = persona.[FKIdEmpresaNomina_NOM]

UNION ALL
SELECT
    N'Incidencia',
    i.[PKIdIncidencia],
    i.[FKIdPersona_NOM],
    persona.[FKIdEmpresaNomina_NOM],
    empresa.[RazonSocial],
    CONCAT_WS(N' ', persona.[Nombre], persona.[Paterno], persona.[Materno]),
    persona.[Clave],
    CAST(i.[PKIdIncidencia] AS nvarchar(50)),
    COALESCE(tipo.[Descripcion], N'Incidencia'),
    i.[Comentario],
    COALESCE(tipo.[Descripcion], N'Incidencia'),
    CASE WHEN i.[AplicaDescuento] = 1 THEN N'Descuenta dia' ELSE N'No descuenta' END,
    CAST(i.[Fecha] AS datetime2(6)),
    CAST(i.[Fecha] AS datetime2(6)),
    CAST(NULL AS datetime2(6)),
    CAST(NULL AS decimal(18,2)),
    CAST(NULL AS decimal(18,4)),
    CAST(i.[FKIdPeriodoQuincenal_SIS] AS nvarchar(200)),
    justificacion.[Descripcion],
    i.[ComentarioJustificacion],
    i.[Activo],
    i.[UsuarioCreacion],
    i.[FechaCreacion],
    i.[UsuarioModificacion],
    i.[FechaModificacion]
FROM [NOM].[Incidencia] i
LEFT JOIN [NOM].[Persona] persona ON persona.[PKIdPersona] = i.[FKIdPersona_NOM]
LEFT JOIN [NOM].[EmpresaNomina] empresa ON empresa.[PKIdEmpresaNomina] = persona.[FKIdEmpresaNomina_NOM]
LEFT JOIN [NOM].[CatalogoSimple] tipo ON tipo.[PKIdCatalogoSimple] = i.[FKIdTipoIncidencia_NOM]
LEFT JOIN [NOM].[CatalogoSimple] justificacion ON justificacion.[PKIdCatalogoSimple] = i.[FKIdTipoJustificacion_NOM]

UNION ALL
SELECT
    N'Pension',
    pe.[PKIdPension],
    pe.[FKIdPersona_NOM],
    persona.[FKIdEmpresaNomina_NOM],
    empresa.[RazonSocial],
    CONCAT_WS(N' ', persona.[Nombre], persona.[Paterno], persona.[Materno]),
    persona.[Clave],
    CAST(pe.[PKIdPension] AS nvarchar(50)),
    pe.[NombreBeneficiario],
    pe.[Documento],
    COALESCE(tp.[Descripcion], N'Pension'),
    CASE WHEN pe.[Activo] = 1 THEN N'Activa' ELSE N'Inactiva' END,
    pe.[FechaInicio],
    pe.[FechaInicio],
    pe.[FechaFin],
    CAST(NULL AS decimal(18,2)),
    pe.[Porcentaje],
    pe.[Documento],
    pe.[Banco],
    CONCAT(N'Cuenta: ', COALESCE(pe.[CuentaBancaria], N''), N' CLABE: ', COALESCE(pe.[Clabe], N''), N' Forma: ', COALESCE(pe.[FormaPago], N'')),
    pe.[Activo],
    pe.[UsuarioCreacion],
    pe.[FechaCreacion],
    pe.[UsuarioModificacion],
    pe.[FechaModificacion]
FROM [NOM].[PersonaPension] pe
LEFT JOIN [NOM].[Persona] persona ON persona.[PKIdPersona] = pe.[FKIdPersona_NOM]
LEFT JOIN [NOM].[EmpresaNomina] empresa ON empresa.[PKIdEmpresaNomina] = persona.[FKIdEmpresaNomina_NOM]
LEFT JOIN [NOM].[TipoPension] tp ON tp.[PKIdTipoPension] = pe.[FKIdTipoPension_NOM];
GO

CREATE OR ALTER VIEW [NOM].[Vw_RhPersona] AS SELECT * FROM [NOM].[Vw_RhEntidadNomina] WHERE [Entidad] = N'Persona';
GO
CREATE OR ALTER VIEW [NOM].[Vw_RhExpediente] AS SELECT * FROM [NOM].[Vw_RhEntidadNomina] WHERE [Entidad] = N'Expediente';
GO
CREATE OR ALTER VIEW [NOM].[Vw_RhContrato] AS SELECT * FROM [NOM].[Vw_RhEntidadNomina] WHERE [Entidad] = N'Contrato';
GO
CREATE OR ALTER VIEW [NOM].[Vw_RhDependiente] AS SELECT * FROM [NOM].[Vw_RhEntidadNomina] WHERE [Entidad] = N'Dependiente';
GO
CREATE OR ALTER VIEW [NOM].[Vw_RhIncidencia] AS SELECT * FROM [NOM].[Vw_RhEntidadNomina] WHERE [Entidad] = N'Incidencia';
GO
CREATE OR ALTER VIEW [NOM].[Vw_RhPension] AS SELECT * FROM [NOM].[Vw_RhEntidadNomina] WHERE [Entidad] = N'Pension';
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhEntidadNomina_List]
    @Entidad nvarchar(40) = N'',
    @PersonaId int = NULL,
    @EmpresaId int = NULL,
    @Page int = 1,
    @PageSize int = 10,
    @Filtro nvarchar(250) = N'',
    @SortLabel nvarchar(80) = N'Fecha',
    @SortDirection nvarchar(20) = N'Descending'
AS
BEGIN
    SET NOCOUNT ON;

    SET @Page = CASE WHEN ISNULL(@Page, 0) <= 0 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) <= 0 THEN 10 ELSE @PageSize END;
    SET @Filtro = LTRIM(RTRIM(ISNULL(@Filtro, N'')));
    SET @Entidad = LTRIM(RTRIM(ISNULL(@Entidad, N'')));
    SET @PersonaId = NULLIF(@PersonaId, 0);
    SET @EmpresaId = NULLIF(@EmpresaId, 0);

    IF @SortLabel NOT IN (N'Entidad', N'Id', N'PersonaId', N'EmpresaId', N'Empresa', N'Persona', N'Empleado', N'Clave', N'Titulo', N'Descripcion', N'Tipo', N'Estatus', N'Fecha', N'FechaInicio', N'FechaFin', N'Importe', N'Porcentaje', N'Documento', N'Referencia', N'Activo')
        SET @SortLabel = N'Fecha';

    IF UPPER(ISNULL(@SortDirection, N'')) NOT IN (N'ASCENDING', N'ASC', N'DESCENDING', N'DESC')
        SET @SortDirection = N'Descending';

    DECLARE @Direction nvarchar(4) = CASE WHEN UPPER(@SortDirection) IN (N'ASCENDING', N'ASC') THEN N'ASC' ELSE N'DESC' END;
    DECLARE @Offset int = (@Page - 1) * @PageSize;
    DECLARE @Sql nvarchar(max) = N'
        SELECT
            Entidad, Id, PersonaId, EmpresaId, Empresa, Persona, Empleado, Clave, Titulo,
            Descripcion, Tipo, Estatus, Fecha, FechaInicio, FechaFin, Importe, Porcentaje,
            Documento, Referencia, Observaciones, Activo, UsuarioCreacion, FechaCreacion,
            UsuarioModificacion, FechaModificacion, COUNT(1) OVER() AS TotalCount
        FROM [NOM].[Vw_RhEntidadNomina]
        WHERE (@Entidad = N'''' OR Entidad = @Entidad)
          AND (@PersonaId IS NULL OR PersonaId = @PersonaId)
          AND (@EmpresaId IS NULL OR EmpresaId = @EmpresaId)
          AND (
                @Filtro = N''''
                OR COALESCE(Empresa, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Persona, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Empleado, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Clave, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Titulo, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Descripcion, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Tipo, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Estatus, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Documento, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Referencia, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Observaciones, N'''') LIKE N''%'' + @Filtro + N''%''
          )
        ORDER BY ' + QUOTENAME(@SortLabel) + N' ' + @Direction + N', Id DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;';

    EXEC sp_executesql
        @Sql,
        N'@Entidad nvarchar(40), @PersonaId int, @EmpresaId int, @Filtro nvarchar(250), @Offset int, @PageSize int',
        @Entidad = @Entidad,
        @PersonaId = @PersonaId,
        @EmpresaId = @EmpresaId,
        @Filtro = @Filtro,
        @Offset = @Offset,
        @PageSize = @PageSize;
END;
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhPersona_List]
    @EmpresaId int = NULL, @Page int = 1, @PageSize int = 10, @Filtro nvarchar(250) = N'', @SortLabel nvarchar(80) = N'Persona', @SortDirection nvarchar(20) = N'Ascending'
AS
BEGIN
    EXEC [NOM].[spRhEntidadNomina_List] N'Persona', NULL, @EmpresaId, @Page, @PageSize, @Filtro, @SortLabel, @SortDirection;
END;
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhExpediente_List]
    @PersonaId int = NULL, @EmpresaId int = NULL, @Page int = 1, @PageSize int = 10, @Filtro nvarchar(250) = N'', @SortLabel nvarchar(80) = N'Fecha', @SortDirection nvarchar(20) = N'Descending'
AS
BEGIN
    EXEC [NOM].[spRhEntidadNomina_List] N'Expediente', @PersonaId, @EmpresaId, @Page, @PageSize, @Filtro, @SortLabel, @SortDirection;
END;
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhContrato_List]
    @PersonaId int = NULL, @EmpresaId int = NULL, @Page int = 1, @PageSize int = 10, @Filtro nvarchar(250) = N'', @SortLabel nvarchar(80) = N'FechaInicio', @SortDirection nvarchar(20) = N'Descending'
AS
BEGIN
    EXEC [NOM].[spRhEntidadNomina_List] N'Contrato', @PersonaId, @EmpresaId, @Page, @PageSize, @Filtro, @SortLabel, @SortDirection;
END;
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhDependiente_List]
    @PersonaId int = NULL, @EmpresaId int = NULL, @Page int = 1, @PageSize int = 10, @Filtro nvarchar(250) = N'', @SortLabel nvarchar(80) = N'Titulo', @SortDirection nvarchar(20) = N'Ascending'
AS
BEGIN
    EXEC [NOM].[spRhEntidadNomina_List] N'Dependiente', @PersonaId, @EmpresaId, @Page, @PageSize, @Filtro, @SortLabel, @SortDirection;
END;
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhIncidencia_List]
    @PersonaId int = NULL, @EmpresaId int = NULL, @Page int = 1, @PageSize int = 10, @Filtro nvarchar(250) = N'', @SortLabel nvarchar(80) = N'Fecha', @SortDirection nvarchar(20) = N'Descending'
AS
BEGIN
    EXEC [NOM].[spRhEntidadNomina_List] N'Incidencia', @PersonaId, @EmpresaId, @Page, @PageSize, @Filtro, @SortLabel, @SortDirection;
END;
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhPension_List]
    @PersonaId int = NULL, @EmpresaId int = NULL, @Page int = 1, @PageSize int = 10, @Filtro nvarchar(250) = N'', @SortLabel nvarchar(80) = N'FechaInicio', @SortDirection nvarchar(20) = N'Descending'
AS
BEGIN
    EXEC [NOM].[spRhEntidadNomina_List] N'Pension', @PersonaId, @EmpresaId, @Page, @PageSize, @Filtro, @SortLabel, @SortDirection;
END;
GO

SELECT [Entidad], COUNT(1) AS [Registros]
FROM [NOM].[Vw_RhEntidadNomina]
GROUP BY [Entidad]
ORDER BY [Entidad];
GO
