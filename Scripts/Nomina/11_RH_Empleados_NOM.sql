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

IF COL_LENGTH(N'NOM.Persona', N'FKIdEmpresaNomina_NOM') IS NULL
    ALTER TABLE [NOM].[Persona] ADD [FKIdEmpresaNomina_NOM] int NULL;
GO

IF COL_LENGTH(N'NOM.ContratoLaboral', N'FKIdDepartamento_SIS') IS NULL
    ALTER TABLE [NOM].[ContratoLaboral] ADD [FKIdDepartamento_SIS] int NULL;
GO

IF COL_LENGTH(N'NOM.ContratoLaboral', N'FKIdTipoContratacion_SIS') IS NULL
    ALTER TABLE [NOM].[ContratoLaboral] ADD [FKIdTipoContratacion_SIS] int NULL;
GO

IF COL_LENGTH(N'NOM.ContratoLaboral', N'Departamento') IS NULL
    ALTER TABLE [NOM].[ContratoLaboral] ADD [Departamento] nvarchar(200) NULL;
GO

IF COL_LENGTH(N'NOM.ContratoLaboral', N'TipoContratacion') IS NULL
    ALTER TABLE [NOM].[ContratoLaboral] ADD [TipoContratacion] nvarchar(200) NULL;
GO

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

IF DB_ID(N'BD_GRP_INVEA') IS NOT NULL
BEGIN
    UPDATE p
    SET
        p.[FKIdEmpresaNomina_NOM] = COALESCE(p.[FKIdEmpresaNomina_NOM], src.[Fk_IdEmpresa__EMP]),
        p.[Sexo] = LEFT(COALESCE(NULLIF(LTRIM(RTRIM(p.[Sexo])), N''), sexo.[Descripcion]), 10),
        p.[ESTADO_CIVIL] = LEFT(COALESCE(NULLIF(LTRIM(RTRIM(p.[ESTADO_CIVIL])), N''), edoCivil.[Descripcion]), 20),
        p.[Municipio] = LEFT(COALESCE(NULLIF(LTRIM(RTRIM(p.[Municipio])), N''), municipio.[Nombre]), 20),
        p.[BANCO] = LEFT(COALESCE(NULLIF(LTRIM(RTRIM(p.[BANCO])), N''), banco.[Nombre]), 100)
    FROM [NOM].[Persona] p
    INNER JOIN [BD_GRP_INVEA].[dbo].[RH_Persona] src ON src.[Pk_IdPersona] = p.[PKIdPersona]
    LEFT JOIN [BD_GRP_INVEA].[dbo].[SIS_Sexo] sexo ON sexo.[Pk_IdSexo] = src.[Fk_IdSexo__SIS]
    LEFT JOIN [BD_GRP_INVEA].[dbo].[SIS_EstadoCivil] edoCivil ON edoCivil.[Pk_IdEstadoCivil] = src.[Fk_IdEstadoCivil__SIS]
    LEFT JOIN [BD_GRP_INVEA].[dbo].[SIS_Municipio] municipio ON municipio.[Pk_IdMunicipio] = src.[Fk_IdMunicipio__SIS]
    LEFT JOIN [BD_GRP_INVEA].[dbo].[SIS_Banco] banco ON banco.[Pk_IdBanco] = src.[Fk_IdBanco__SIS];

    UPDATE c
    SET
        c.[FKIdDepartamento_SIS] = src.[Fk_IdDepartamento__EMP],
        c.[FKIdTipoContratacion_SIS] = src.[Fk_IdTipoContratacion__SIS],
        c.[Departamento] = departamento.[Nombre],
        c.[TipoContratacion] = COALESCE(tipoContratacion.[Tipo], tipoContratacion.[Descripcion])
    FROM [NOM].[ContratoLaboral] c
    INNER JOIN [BD_GRP_INVEA].[dbo].[RH_Contrato] src ON src.[Pk_IdContrato] = c.[PKIdContratoLaboral]
    LEFT JOIN [BD_GRP_INVEA].[dbo].[EMP_Departamento] departamento ON departamento.[Pk_IdDepartamento] = src.[Fk_IdDepartamento__EMP]
    LEFT JOIN [BD_GRP_INVEA].[dbo].[SIS_TipoContratacion] tipoContratacion ON tipoContratacion.[Pk_IdTipoContratacion] = src.[Fk_IdTipoContratacion__SIS];

    UPDATE p
    SET
        p.[TIPO_CONTRATACION] = LEFT(COALESCE(NULLIF(LTRIM(RTRIM(p.[TIPO_CONTRATACION])), N''), c.[TipoContratacion]), 50),
        p.[PUESTO] = LEFT(COALESCE(NULLIF(LTRIM(RTRIM(p.[PUESTO])), N''), puesto.[Nombre]), 100)
    FROM [NOM].[Persona] p
    OUTER APPLY (
        SELECT TOP (1) cl.[TipoContratacion], cl.[FKIdPuesto_NOM]
        FROM [NOM].[ContratoLaboral] cl
        WHERE cl.[FKIdPersona_NOM] = p.[PKIdPersona]
        ORDER BY cl.[FechaInicio] DESC, cl.[PKIdContratoLaboral] DESC
    ) c
    LEFT JOIN [NOM].[Puesto] puesto ON puesto.[PKIdPuesto] = c.[FKIdPuesto_NOM];

    SET IDENTITY_INSERT [NOM].[PersonaDependiente] ON;

    MERGE [NOM].[PersonaDependiente] AS target
    USING (
        SELECT
            dep.[Pk_IdDependiente],
            dep.[Fk_IdPersona__RH],
            LEFT(COALESCE(NULLIF(LTRIM(RTRIM(dep.[Nombre])), N''), N'Sin nombre'), 300) AS [Nombre],
            dep.[Fk_IdParentesco__SIS],
            parentesco.[Descripcion] AS [Parentesco],
            dep.[FechaNacimiento],
            dep.[CT_CreatedBy],
            dep.[CT_CreatedDate],
            dep.[CT_ModifiedBy],
            dep.[CT_ModifiedDate],
            CONVERT(bit, CASE WHEN COALESCE(dep.[CT_LIVE], 1) <> 0 THEN 1 ELSE 0 END) AS [Activo]
        FROM [BD_GRP_INVEA].[dbo].[RH_Dependiente] dep
        LEFT JOIN [BD_GRP_INVEA].[dbo].[SIS_Parentesco] parentesco ON parentesco.[Pk_IdParentesco] = dep.[Fk_IdParentesco__SIS]
    ) AS source
    ON target.[PKIdDependiente] = source.[Pk_IdDependiente]
    WHEN MATCHED THEN UPDATE SET
        [FKIdPersona_NOM] = source.[Fk_IdPersona__RH],
        [Nombre] = source.[Nombre],
        [FKIdParentesco_SIS] = source.[Fk_IdParentesco__SIS],
        [Parentesco] = source.[Parentesco],
        [FechaNacimiento] = source.[FechaNacimiento],
        [UsuarioCreacion] = source.[CT_CreatedBy],
        [FechaCreacion] = source.[CT_CreatedDate],
        [UsuarioModificacion] = source.[CT_ModifiedBy],
        [FechaModificacion] = source.[CT_ModifiedDate],
        [Activo] = source.[Activo]
    WHEN NOT MATCHED THEN INSERT
        ([PKIdDependiente], [FKIdPersona_NOM], [Nombre], [FKIdParentesco_SIS], [Parentesco], [FechaNacimiento], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo])
        VALUES (source.[Pk_IdDependiente], source.[Fk_IdPersona__RH], source.[Nombre], source.[Fk_IdParentesco__SIS], source.[Parentesco], source.[FechaNacimiento], source.[CT_CreatedBy], source.[CT_CreatedDate], source.[CT_ModifiedBy], source.[CT_ModifiedDate], source.[Activo]);

    SET IDENTITY_INSERT [NOM].[PersonaDependiente] OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NOM_Persona_EmpresaActivo' AND object_id = OBJECT_ID(N'[NOM].[Persona]'))
    CREATE INDEX [IX_NOM_Persona_EmpresaActivo] ON [NOM].[Persona] ([FKIdEmpresaNomina_NOM], [Activo]) INCLUDE ([Clave], [Nombre], [Paterno], [Materno], [RFC], [Curp]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NOM_ContratoLaboral_PersonaEmpresa' AND object_id = OBJECT_ID(N'[NOM].[ContratoLaboral]'))
    CREATE INDEX [IX_NOM_ContratoLaboral_PersonaEmpresa] ON [NOM].[ContratoLaboral] ([FKIdPersona_NOM], [FKIdEmpresaNomina_NOM], [Activo], [FechaInicio] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NOM_PersonaDependiente_Persona' AND object_id = OBJECT_ID(N'[NOM].[PersonaDependiente]'))
    CREATE INDEX [IX_NOM_PersonaDependiente_Persona] ON [NOM].[PersonaDependiente] ([FKIdPersona_NOM], [Activo]);
GO

CREATE OR ALTER VIEW [NOM].[VwRhEmpleado]
AS
SELECT
    p.[PKIdPersona] AS [Id],
    COALESCE(c.[FKIdEmpresaNomina_NOM], p.[FKIdEmpresaNomina_NOM]) AS [EmpresaId],
    empresa.[RazonSocial] AS [Empresa],
    p.[Clave] AS [Empleado],
    p.[Iniciales],
    p.[Nombre],
    p.[Paterno],
    p.[Materno],
    CONCAT_WS(N' ', p.[Nombre], p.[Paterno], p.[Materno]) AS [NombreCompleto],
    p.[RFC] AS [Rfc],
    p.[Curp],
    p.[Sexo],
    CAST(p.[FechaNacimiento] AS date) AS [FechaNacimiento],
    CAST(p.[Fecha_de_Inicio] AS date) AS [FechaIngreso],
    CAST(p.[Fecha_Fin] AS date) AS [FechaFin],
    COALESCE(c.[TipoContratacion], p.[TIPO_CONTRATACION]) AS [TipoContratacion],
    COALESCE(puesto.[Nombre], p.[PUESTO]) AS [Puesto],
    c.[Departamento],
    c.[NumeroContrato] AS [Contrato],
    CAST(c.[SueldoMensual] AS decimal(18,2)) AS [SueldoMensual],
    CAST(p.[SUELDO_BASE] AS decimal(18,2)) AS [SueldoBase],
    CAST(p.[COMPENSACION_GARANTIZADA] AS decimal(18,2)) AS [CompensacionGarantizada],
    p.[BANCO] AS [Banco],
    p.[NUMERO_CUENTA] AS [NumeroCuenta],
    p.[CLABE],
    p.[CORREO_ELECTRONICO] AS [Email],
    p.[Telefono_particular] AS [Telefono],
    p.[Telefono_movil] AS [Celular],
    CONCAT_WS(N' ', p.[Calle], p.[Num_exterior], p.[Num_interior], p.[Colonia], p.[CP]) AS [Direccion],
    p.[Calle],
    p.[Num_exterior] AS [NumExterior],
    p.[Num_interior] AS [NumInterior],
    p.[Colonia],
    p.[CP],
    p.[Municipio],
    p.[Estado],
    p.[ESTADO_CIVIL] AS [EstadoCivil],
    p.[REG_IMSS] AS [RegImss],
    p.[NoCartilla],
    p.[NoLicencia],
    p.[NoPasaporte],
    p.[NoCredencialElector],
    p.[Gafete],
    CAST(CASE WHEN EXISTS (SELECT 1 FROM [NOM].[PersonaPension] pp WHERE pp.[FKIdPersona_NOM] = p.[PKIdPersona] AND pp.[Activo] = 1) THEN 1 ELSE 0 END AS bit) AS [TienePension],
    (SELECT COUNT(1) FROM [NOM].[EmpleadoExpediente] e WHERE e.[FKIdPersona_NOM] = p.[PKIdPersona] AND e.[Activo] = 1) AS [TotalExpedientes],
    (SELECT COUNT(1) FROM [NOM].[Incidencia] i WHERE i.[FKIdPersona_NOM] = p.[PKIdPersona] AND i.[Activo] = 1) AS [TotalIncidencias],
    p.[Activo],
    p.[UsuarioCreacion],
    p.[FechaCreacion],
    p.[UsuarioModificacion],
    p.[FechaModificacion]
FROM [NOM].[Persona] p
OUTER APPLY (
    SELECT TOP (1) cl.*
    FROM [NOM].[ContratoLaboral] cl
    WHERE cl.[FKIdPersona_NOM] = p.[PKIdPersona]
      AND cl.[Activo] = 1
    ORDER BY cl.[FechaInicio] DESC, cl.[PKIdContratoLaboral] DESC
) c
LEFT JOIN [NOM].[EmpresaNomina] empresa ON empresa.[PKIdEmpresaNomina] = COALESCE(c.[FKIdEmpresaNomina_NOM], p.[FKIdEmpresaNomina_NOM])
LEFT JOIN [NOM].[Puesto] puesto ON puesto.[PKIdPuesto] = c.[FKIdPuesto_NOM]
WHERE p.[Activo] = 1;
GO

CREATE OR ALTER VIEW [NOM].[VwRhEmpleadoDetalle]
AS
SELECT
    N'contratos' AS [Seccion],
    c.[PKIdContratoLaboral] AS [Id],
    c.[FKIdPersona_NOM] AS [PersonaId],
    c.[FKIdEmpresaNomina_NOM] AS [EmpresaId],
    c.[NumeroContrato] AS [Clave],
    CONCAT(N'Contrato ', c.[NumeroContrato]) AS [Titulo],
    COALESCE(puesto.[Nombre], N'Contrato laboral') AS [Descripcion],
    COALESCE(c.[TipoContratacion], nombramiento.[Descripcion]) AS [Tipo],
    CASE WHEN c.[Activo] = 1 THEN N'Activo' ELSE N'Inactivo' END AS [Estatus],
    CAST(c.[FechaInicio] AS datetime2(6)) AS [Fecha],
    CAST(c.[FechaInicio] AS datetime2(6)) AS [FechaInicio],
    CAST(c.[FechaFin] AS datetime2(6)) AS [FechaFin],
    CAST(c.[SueldoMensual] AS decimal(18,2)) AS [Importe],
    CAST(NULL AS decimal(18,4)) AS [Porcentaje],
    c.[NumeroContrato] AS [Documento],
    c.[Departamento] AS [Referencia],
    c.[Vigencia] AS [Observaciones],
    c.[Activo],
    c.[UsuarioCreacion],
    c.[FechaCreacion],
    c.[UsuarioModificacion],
    c.[FechaModificacion]
FROM [NOM].[ContratoLaboral] c
LEFT JOIN [NOM].[Puesto] puesto ON puesto.[PKIdPuesto] = c.[FKIdPuesto_NOM]
LEFT JOIN [NOM].[Nombramiento] nombramiento ON nombramiento.[PKIdNombramiento] = c.[FKIdNombramiento_NOM]

UNION ALL
SELECT
    N'expedientes',
    e.[PKIdExpediente],
    e.[FKIdPersona_NOM],
    emp.[EmpresaId],
    CAST(e.[PKIdExpediente] AS nvarchar(50)),
    e.[NombreDocumento],
    e.[Descripcion],
    COALESCE(tipo.[Descripcion], N'Expediente'),
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
LEFT JOIN [NOM].[CatalogoSimple] tipo ON tipo.[PKIdCatalogoSimple] = e.[FKIdTipoExpediente_NOM]
LEFT JOIN [NOM].[VwRhEmpleado] emp ON emp.[Id] = e.[FKIdPersona_NOM]

UNION ALL
SELECT
    N'dependientes',
    d.[PKIdDependiente],
    d.[FKIdPersona_NOM],
    emp.[EmpresaId],
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
LEFT JOIN [NOM].[VwRhEmpleado] emp ON emp.[Id] = d.[FKIdPersona_NOM]

UNION ALL
SELECT
    N'incidencias',
    i.[PKIdIncidencia],
    i.[FKIdPersona_NOM],
    emp.[EmpresaId],
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
LEFT JOIN [NOM].[CatalogoSimple] tipo ON tipo.[PKIdCatalogoSimple] = i.[FKIdTipoIncidencia_NOM]
LEFT JOIN [NOM].[CatalogoSimple] justificacion ON justificacion.[PKIdCatalogoSimple] = i.[FKIdTipoJustificacion_NOM]
LEFT JOIN [NOM].[VwRhEmpleado] emp ON emp.[Id] = i.[FKIdPersona_NOM]

UNION ALL
SELECT
    N'pensiones',
    pe.[PKIdPension],
    pe.[FKIdPersona_NOM],
    emp.[EmpresaId],
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
    CONCAT(N'Cuenta: ', COALESCE(pe.[CuentaBancaria], N''), N' CLABE: ', COALESCE(pe.[Clabe], N'')),
    pe.[Activo],
    pe.[UsuarioCreacion],
    pe.[FechaCreacion],
    pe.[UsuarioModificacion],
    pe.[FechaModificacion]
FROM [NOM].[PersonaPension] pe
LEFT JOIN [NOM].[TipoPension] tp ON tp.[PKIdTipoPension] = pe.[FKIdTipoPension_NOM]
LEFT JOIN [NOM].[VwRhEmpleado] emp ON emp.[Id] = pe.[FKIdPersona_NOM];
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhEmpleado_List]
    @EmpresaId int = NULL,
    @Page int = 1,
    @PageSize int = 10,
    @Filtro nvarchar(250) = N'',
    @SortLabel nvarchar(80) = N'NombreCompleto',
    @SortDirection nvarchar(20) = N'Ascending'
AS
BEGIN
    SET NOCOUNT ON;

    SET @Page = CASE WHEN ISNULL(@Page, 0) <= 0 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) <= 0 THEN 10 ELSE @PageSize END;
    SET @Filtro = LTRIM(RTRIM(ISNULL(@Filtro, N'')));
    SET @EmpresaId = NULLIF(@EmpresaId, 0);

    IF @SortLabel NOT IN (N'Id', N'EmpresaId', N'Empresa', N'Empleado', N'Nombre', N'Paterno', N'Materno', N'NombreCompleto', N'Rfc', N'Curp', N'Sexo', N'FechaNacimiento', N'FechaIngreso', N'TipoContratacion', N'Puesto', N'Departamento', N'Contrato', N'SueldoMensual', N'Activo')
        SET @SortLabel = N'NombreCompleto';

    IF UPPER(ISNULL(@SortDirection, N'')) NOT IN (N'ASCENDING', N'ASC', N'DESCENDING', N'DESC')
        SET @SortDirection = N'Ascending';

    DECLARE @Direction nvarchar(4) = CASE WHEN UPPER(@SortDirection) IN (N'DESCENDING', N'DESC') THEN N'DESC' ELSE N'ASC' END;
    DECLARE @Offset int = (@Page - 1) * @PageSize;
    DECLARE @Sql nvarchar(max) = N'
        SELECT
            Id, EmpresaId, Empresa, Empleado, Iniciales, Nombre, Paterno, Materno, NombreCompleto,
            Rfc, Curp, Sexo, FechaNacimiento, FechaIngreso, FechaFin, TipoContratacion,
            Puesto, Departamento, Contrato, SueldoMensual, SueldoBase, CompensacionGarantizada,
            Banco, NumeroCuenta, Clabe, Email, Telefono, Celular, Direccion, Calle, NumExterior,
            NumInterior, Colonia, CP, Municipio, Estado, EstadoCivil, RegImss, NoCartilla,
            NoLicencia, NoPasaporte, NoCredencialElector, Gafete, TienePension,
            TotalExpedientes, TotalIncidencias, Activo, UsuarioCreacion, FechaCreacion,
            UsuarioModificacion, FechaModificacion,
            COUNT(1) OVER() AS TotalCount
        FROM [NOM].[VwRhEmpleado]
        WHERE (@EmpresaId IS NULL OR EmpresaId = @EmpresaId)
          AND (
                @Filtro = N''''
                OR COALESCE(Empleado, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(NombreCompleto, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Rfc, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Curp, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Puesto, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Departamento, N'''') LIKE N''%'' + @Filtro + N''%''
                OR COALESCE(Contrato, N'''') LIKE N''%'' + @Filtro + N''%''
          )
        ORDER BY ' + QUOTENAME(@SortLabel) + N' ' + @Direction + N', Id DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;';

    EXEC sp_executesql
        @Sql,
        N'@EmpresaId int, @Filtro nvarchar(250), @Offset int, @PageSize int',
        @EmpresaId = @EmpresaId,
        @Filtro = @Filtro,
        @Offset = @Offset,
        @PageSize = @PageSize;
END;
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhEmpleado_GetById]
    @Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        Id, EmpresaId, Empresa, Empleado, Iniciales, Nombre, Paterno, Materno, NombreCompleto,
        Rfc, Curp, Sexo, FechaNacimiento, FechaIngreso, FechaFin, TipoContratacion,
        Puesto, Departamento, Contrato, SueldoMensual, SueldoBase, CompensacionGarantizada,
        Banco, NumeroCuenta, Clabe, Email, Telefono, Celular, Direccion, Calle, NumExterior,
        NumInterior, Colonia, CP, Municipio, Estado, EstadoCivil, RegImss, NoCartilla,
        NoLicencia, NoPasaporte, NoCredencialElector, Gafete, TienePension,
        TotalExpedientes, TotalIncidencias, Activo, UsuarioCreacion, FechaCreacion,
        UsuarioModificacion, FechaModificacion,
        1 AS TotalCount
    FROM [NOM].[VwRhEmpleado]
    WHERE [Id] = @Id;
END;
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhEmpleado_Save]
    @Id int = NULL OUTPUT,
    @EmpresaId int = NULL,
    @Empleado nvarchar(30) = NULL,
    @Iniciales nvarchar(6) = NULL,
    @Nombre nvarchar(100),
    @Paterno nvarchar(100) = N'',
    @Materno nvarchar(100) = N'',
    @Rfc nvarchar(30) = N'',
    @Curp nvarchar(36) = N'',
    @Sexo nvarchar(20) = NULL,
    @FechaNacimiento datetime = NULL,
    @FechaIngreso datetime = NULL,
    @FechaFin datetime = NULL,
    @TipoContratacion nvarchar(100) = NULL,
    @Puesto nvarchar(200) = NULL,
    @SueldoBase decimal(18,2) = NULL,
    @CompensacionGarantizada decimal(18,2) = NULL,
    @Banco nvarchar(200) = NULL,
    @NumeroCuenta nvarchar(50) = NULL,
    @Clabe nvarchar(100) = NULL,
    @Email nvarchar(500) = NULL,
    @Telefono nvarchar(30) = NULL,
    @Celular nvarchar(30) = NULL,
    @Calle nvarchar(80) = NULL,
    @NumExterior nvarchar(20) = NULL,
    @NumInterior nvarchar(20) = NULL,
    @Colonia nvarchar(80) = NULL,
    @CP nvarchar(12) = NULL,
    @Municipio nvarchar(40) = NULL,
    @Estado nvarchar(60) = NULL,
    @EstadoCivil nvarchar(40) = NULL,
    @RegImss nvarchar(24) = NULL,
    @NoCartilla nvarchar(32) = NULL,
    @NoLicencia nvarchar(32) = NULL,
    @NoPasaporte nvarchar(32) = NULL,
    @NoCredencialElector nvarchar(64) = NULL,
    @Gafete nvarchar(22) = NULL,
    @Activo bit = 1,
    @UsuarioActual int
AS
BEGIN
    SET NOCOUNT ON;

    SET @Empleado = LEFT(COALESCE(NULLIF(LTRIM(RTRIM(@Empleado)), N''), CONCAT(N'EMP', FORMAT(SYSDATETIME(), N'yyMMddHHmmss'))), 15);
    SET @Iniciales = LEFT(COALESCE(LTRIM(RTRIM(@Iniciales)), N''), 3);
    SET @Nombre = LEFT(COALESCE(NULLIF(LTRIM(RTRIM(@Nombre)), N''), N'Sin nombre'), 50);
    SET @Paterno = LEFT(COALESCE(LTRIM(RTRIM(@Paterno)), N''), 50);
    SET @Materno = LEFT(COALESCE(LTRIM(RTRIM(@Materno)), N''), 50);
    SET @Rfc = LEFT(COALESCE(LTRIM(RTRIM(@Rfc)), N''), 15);
    SET @Curp = LEFT(COALESCE(LTRIM(RTRIM(@Curp)), N''), 18);
    SET @Sexo = LEFT(COALESCE(LTRIM(RTRIM(@Sexo)), N''), 10);
    SET @EstadoCivil = LEFT(COALESCE(LTRIM(RTRIM(@EstadoCivil)), N''), 20);
    SET @RegImss = LEFT(COALESCE(LTRIM(RTRIM(@RegImss)), N''), 12);
    SET @Email = LEFT(COALESCE(LTRIM(RTRIM(@Email)), N''), 250);
    SET @Telefono = LEFT(COALESCE(LTRIM(RTRIM(@Telefono)), N''), 15);
    SET @Celular = LEFT(COALESCE(LTRIM(RTRIM(@Celular)), N''), 15);
    SET @Calle = LEFT(COALESCE(LTRIM(RTRIM(@Calle)), N''), 40);
    SET @NumExterior = LEFT(COALESCE(LTRIM(RTRIM(@NumExterior)), N''), 10);
    SET @NumInterior = LEFT(COALESCE(LTRIM(RTRIM(@NumInterior)), N''), 10);
    SET @Colonia = LEFT(COALESCE(LTRIM(RTRIM(@Colonia)), N''), 40);
    SET @CP = LEFT(COALESCE(LTRIM(RTRIM(@CP)), N''), 6);
    SET @Municipio = LEFT(COALESCE(LTRIM(RTRIM(@Municipio)), N''), 20);
    SET @Estado = LEFT(COALESCE(LTRIM(RTRIM(@Estado)), N''), 30);
    SET @TipoContratacion = LEFT(COALESCE(LTRIM(RTRIM(@TipoContratacion)), N''), 50);
    SET @Puesto = LEFT(COALESCE(LTRIM(RTRIM(@Puesto)), N''), 100);
    SET @Banco = LEFT(COALESCE(LTRIM(RTRIM(@Banco)), N''), 100);
    SET @NumeroCuenta = LEFT(COALESCE(LTRIM(RTRIM(@NumeroCuenta)), N''), 25);
    SET @Clabe = LEFT(COALESCE(LTRIM(RTRIM(@Clabe)), N''), 50);
    SET @FechaNacimiento = COALESCE(@FechaNacimiento, '19000101');
    SET @FechaIngreso = COALESCE(@FechaIngreso, SYSDATETIME());
    SET @UsuarioActual = COALESCE(NULLIF(@UsuarioActual, 0), 1);

    IF ISNULL(@Id, 0) <= 0
    BEGIN
        INSERT INTO [NOM].[Persona] (
            [Clave], [Iniciales], [Nombre], [Paterno], [Materno], [Sexo], [FechaNacimiento], [ESTADO_CIVIL],
            [RFC], [Curp], [REG_IMSS], [NoCartilla], [NoLicencia], [NoPasaporte], [NoCredencialElector], [Gafete],
            [CORREO_ELECTRONICO], [Telefono_particular], [Telefono_movil],
            [Calle], [Num_exterior], [Num_interior], [Colonia], [CP], [Municipio], [Estado],
            [Fecha_de_Inicio], [Fecha_Fin], [TIPO_CONTRATACION], [PUESTO], [SUELDO_BASE],
            [COMPENSACION_GARANTIZADA], [BANCO], [NUMERO_CUENTA], [CLABE], [FKIdEmpresaNomina_NOM],
            [Activo], [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion])
        VALUES (
            @Empleado, @Iniciales, @Nombre, @Paterno, @Materno, @Sexo, @FechaNacimiento, @EstadoCivil,
            @Rfc, @Curp, @RegImss, @NoCartilla, @NoLicencia, @NoPasaporte, @NoCredencialElector, @Gafete,
            @Email, @Telefono, @Celular,
            @Calle, @NumExterior, @NumInterior, @Colonia, @CP, @Municipio, @Estado,
            @FechaIngreso, @FechaFin, @TipoContratacion, @Puesto, @SueldoBase,
            @CompensacionGarantizada, @Banco, @NumeroCuenta, @Clabe, @EmpresaId,
            COALESCE(@Activo, 1), @UsuarioActual, SYSDATETIME(), NULL, NULL);

        SET @Id = CONVERT(int, SCOPE_IDENTITY());
    END
    ELSE
    BEGIN
        UPDATE [NOM].[Persona]
        SET
            [Clave] = @Empleado,
            [Iniciales] = @Iniciales,
            [Nombre] = @Nombre,
            [Paterno] = @Paterno,
            [Materno] = @Materno,
            [Sexo] = @Sexo,
            [FechaNacimiento] = @FechaNacimiento,
            [ESTADO_CIVIL] = @EstadoCivil,
            [RFC] = @Rfc,
            [Curp] = @Curp,
            [REG_IMSS] = @RegImss,
            [NoCartilla] = @NoCartilla,
            [NoLicencia] = @NoLicencia,
            [NoPasaporte] = @NoPasaporte,
            [NoCredencialElector] = @NoCredencialElector,
            [Gafete] = @Gafete,
            [CORREO_ELECTRONICO] = @Email,
            [Telefono_particular] = @Telefono,
            [Telefono_movil] = @Celular,
            [Calle] = @Calle,
            [Num_exterior] = @NumExterior,
            [Num_interior] = @NumInterior,
            [Colonia] = @Colonia,
            [CP] = @CP,
            [Municipio] = @Municipio,
            [Estado] = @Estado,
            [Fecha_de_Inicio] = @FechaIngreso,
            [Fecha_Fin] = @FechaFin,
            [TIPO_CONTRATACION] = @TipoContratacion,
            [PUESTO] = @Puesto,
            [SUELDO_BASE] = @SueldoBase,
            [COMPENSACION_GARANTIZADA] = @CompensacionGarantizada,
            [BANCO] = @Banco,
            [NUMERO_CUENTA] = @NumeroCuenta,
            [CLABE] = @Clabe,
            [FKIdEmpresaNomina_NOM] = @EmpresaId,
            [Activo] = COALESCE(@Activo, [Activo]),
            [UsuarioModificacion] = @UsuarioActual,
            [FechaModificacion] = SYSDATETIME()
        WHERE [PKIdPersona] = @Id;
    END

    EXEC [NOM].[spRhEmpleado_GetById] @Id = @Id;
END;
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhEmpleado_Delete]
    @Id int,
    @UsuarioActual int
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [NOM].[Persona]
    SET
        [Activo] = 0,
        [UsuarioModificacion] = COALESCE(NULLIF(@UsuarioActual, 0), 1),
        [FechaModificacion] = SYSDATETIME()
    WHERE [PKIdPersona] = @Id;

    SELECT CONVERT(bit, CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END) AS [Resultado];
END;
GO

CREATE OR ALTER PROCEDURE [NOM].[spRhEmpleadoDetalle_List]
    @Seccion nvarchar(40),
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
    SET @Seccion = LTRIM(RTRIM(ISNULL(@Seccion, N'')));
    SET @PersonaId = NULLIF(@PersonaId, 0);
    SET @EmpresaId = NULLIF(@EmpresaId, 0);

    IF @SortLabel NOT IN (N'Seccion', N'Id', N'PersonaId', N'EmpresaId', N'Clave', N'Titulo', N'Descripcion', N'Tipo', N'Estatus', N'Fecha', N'FechaInicio', N'FechaFin', N'Importe', N'Porcentaje', N'Documento', N'Referencia', N'Activo')
        SET @SortLabel = N'Fecha';

    IF UPPER(ISNULL(@SortDirection, N'')) NOT IN (N'ASCENDING', N'ASC', N'DESCENDING', N'DESC')
        SET @SortDirection = N'Descending';

    DECLARE @Direction nvarchar(4) = CASE WHEN UPPER(@SortDirection) IN (N'ASCENDING', N'ASC') THEN N'ASC' ELSE N'DESC' END;
    DECLARE @Offset int = (@Page - 1) * @PageSize;
    DECLARE @Sql nvarchar(max) = N'
        SELECT
            Seccion, Id, PersonaId, EmpresaId, Clave, Titulo, Descripcion, Tipo, Estatus,
            Fecha, FechaInicio, FechaFin, Importe, Porcentaje, Documento, Referencia,
            Observaciones, Activo, UsuarioCreacion, FechaCreacion, UsuarioModificacion,
            FechaModificacion, COUNT(1) OVER() AS TotalCount
        FROM [NOM].[VwRhEmpleadoDetalle]
        WHERE (@Seccion = N'''' OR Seccion = @Seccion)
          AND (@PersonaId IS NULL OR PersonaId = @PersonaId)
          AND (@EmpresaId IS NULL OR EmpresaId = @EmpresaId)
          AND (
                @Filtro = N''''
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
        N'@Seccion nvarchar(40), @PersonaId int, @EmpresaId int, @Filtro nvarchar(250), @Offset int, @PageSize int',
        @Seccion = @Seccion,
        @PersonaId = @PersonaId,
        @EmpresaId = @EmpresaId,
        @Filtro = @Filtro,
        @Offset = @Offset,
        @PageSize = @PageSize;
END;
GO

SELECT N'Empleados RH' AS [Proceso], COUNT(1) AS [Registros]
FROM [NOM].[VwRhEmpleado];
GO
