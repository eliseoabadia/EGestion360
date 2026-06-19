-- Stored procedures de lectura para vistas importantes de Nomina.
-- Ejecutar despues de Scripts/Nomina/04_Vistas_NOM.sql.

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'NOM')
    EXEC(N'CREATE SCHEMA [NOM]');
GO

CREATE OR ALTER PROCEDURE [NOM].[spConceptos_List]
    @Page int = 1,
    @PageSize int = 50,
    @Filtro nvarchar(200) = NULL,
    @Activo bit = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Page = CASE WHEN @Page IS NULL OR @Page < 1 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN @PageSize IS NULL OR @PageSize < 1 THEN 50 WHEN @PageSize > 500 THEN 500 ELSE @PageSize END;
    SET @Filtro = NULLIF(LTRIM(RTRIM(@Filtro)), N'');

    ;WITH Base AS
    (
        SELECT
            v.*,
            COUNT(1) OVER() AS [TotalCount]
        FROM [NOM].[Vw_NOM_Concepto] v
        WHERE (@Activo IS NULL OR v.[Activo] = @Activo)
          AND (
                @Filtro IS NULL
                OR v.[Clave] LIKE N'%' + @Filtro + N'%'
                OR v.[SubClave] LIKE N'%' + @Filtro + N'%'
                OR v.[Nombre] LIKE N'%' + @Filtro + N'%'
                OR v.[TipoMovimiento] LIKE N'%' + @Filtro + N'%'
          )
    )
    SELECT *
    FROM Base
    ORDER BY [Clave], [SubClave], [PKIdConcepto]
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spPeriodosActivos_List]
    @EmpresaId int = NULL,
    @PeriodoId int = NULL,
    @Page int = 1,
    @PageSize int = 50,
    @Filtro nvarchar(200) = NULL,
    @Activo bit = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Page = CASE WHEN @Page IS NULL OR @Page < 1 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN @PageSize IS NULL OR @PageSize < 1 THEN 50 WHEN @PageSize > 500 THEN 500 ELSE @PageSize END;
    SET @Filtro = NULLIF(LTRIM(RTRIM(@Filtro)), N'');

    ;WITH Base AS
    (
        SELECT
            v.*,
            COUNT(1) OVER() AS [TotalCount]
        FROM [NOM].[Vw_PeriodoActivoResumen] v
        WHERE (@EmpresaId IS NULL OR v.[EmpresaId] = @EmpresaId)
          AND (@PeriodoId IS NULL OR v.[PeriodoId] = @PeriodoId)
          AND (@Activo IS NULL OR v.[Activo] = @Activo)
          AND (
                @Filtro IS NULL
                OR CONVERT(nvarchar(20), v.[PeriodoId]) LIKE N'%' + @Filtro + N'%'
                OR CONVERT(nvarchar(20), v.[EmpresaId]) LIKE N'%' + @Filtro + N'%'
                OR v.[EmpresaNombre] LIKE N'%' + @Filtro + N'%'
          )
    )
    SELECT *
    FROM Base
    ORDER BY [PeriodoId] DESC, [EmpresaId]
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spMovimientosNomina_List]
    @EmpresaId int = NULL,
    @PeriodoId int = NULL,
    @PersonaId int = NULL,
    @TipoNomina nvarchar(40) = NULL,
    @Page int = 1,
    @PageSize int = 50,
    @Filtro nvarchar(200) = NULL,
    @Activo bit = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Page = CASE WHEN @Page IS NULL OR @Page < 1 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN @PageSize IS NULL OR @PageSize < 1 THEN 50 WHEN @PageSize > 500 THEN 500 ELSE @PageSize END;
    SET @Filtro = NULLIF(LTRIM(RTRIM(@Filtro)), N'');
    SET @TipoNomina = NULLIF(LTRIM(RTRIM(@TipoNomina)), N'');

    ;WITH Base AS
    (
        SELECT
            v.*,
            COUNT(1) OVER() AS [TotalCount]
        FROM [NOM].[Vw_MovimientosNomina] v
        WHERE (@EmpresaId IS NULL OR v.[EmpresaId] = @EmpresaId)
          AND (@PeriodoId IS NULL OR v.[PeriodoId] = @PeriodoId)
          AND (@PersonaId IS NULL OR v.[PersonaId] = @PersonaId)
          AND (@TipoNomina IS NULL OR v.[TipoNomina] = @TipoNomina)
          AND (@Activo IS NULL OR v.[Activo] = @Activo)
          AND (
                @Filtro IS NULL
                OR v.[ConceptoClave] LIKE N'%' + @Filtro + N'%'
                OR v.[ConceptoNombre] LIKE N'%' + @Filtro + N'%'
                OR v.[Referencia] LIKE N'%' + @Filtro + N'%'
                OR CONVERT(nvarchar(20), v.[PersonaId]) LIKE N'%' + @Filtro + N'%'
          )
    )
    SELECT *
    FROM Base
    ORDER BY [PeriodoId] DESC, [PersonaId], [ConceptoClave], [IdMovimiento]
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spResumenPeriodo_List]
    @EmpresaId int = NULL,
    @PeriodoId int = NULL,
    @Page int = 1,
    @PageSize int = 50,
    @Filtro nvarchar(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Page = CASE WHEN @Page IS NULL OR @Page < 1 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN @PageSize IS NULL OR @PageSize < 1 THEN 50 WHEN @PageSize > 500 THEN 500 ELSE @PageSize END;
    SET @Filtro = NULLIF(LTRIM(RTRIM(@Filtro)), N'');

    ;WITH Base AS
    (
        SELECT
            v.*,
            COUNT(1) OVER() AS [TotalCount]
        FROM [NOM].[Vw_ResumenPeriodo] v
        WHERE (@EmpresaId IS NULL OR v.[EmpresaId] = @EmpresaId)
          AND (@PeriodoId IS NULL OR v.[PeriodoId] = @PeriodoId)
          AND (
                @Filtro IS NULL
                OR CONVERT(nvarchar(20), v.[PeriodoId]) LIKE N'%' + @Filtro + N'%'
                OR CONVERT(nvarchar(20), v.[EmpresaId]) LIKE N'%' + @Filtro + N'%'
          )
    )
    SELECT *
    FROM Base
    ORDER BY [PeriodoId] DESC, [EmpresaId]
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spCreditos_List]
    @PersonaId int = NULL,
    @ContratoTerceroId int = NULL,
    @Page int = 1,
    @PageSize int = 50,
    @Filtro nvarchar(200) = NULL,
    @Activo bit = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Page = CASE WHEN @Page IS NULL OR @Page < 1 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN @PageSize IS NULL OR @PageSize < 1 THEN 50 WHEN @PageSize > 500 THEN 500 ELSE @PageSize END;
    SET @Filtro = NULLIF(LTRIM(RTRIM(@Filtro)), N'');

    ;WITH Base AS
    (
        SELECT
            v.*,
            COUNT(1) OVER() AS [TotalCount]
        FROM [NOM].[Vw_Credito] v
        WHERE (@PersonaId IS NULL OR v.[PersonaId] = @PersonaId)
          AND (@ContratoTerceroId IS NULL OR v.[ContratoTerceroId] = @ContratoTerceroId)
          AND (@Activo IS NULL OR v.[Activo] = @Activo)
          AND (
                @Filtro IS NULL
                OR v.[MotivoCredito] LIKE N'%' + @Filtro + N'%'
                OR v.[NombreContrato] LIKE N'%' + @Filtro + N'%'
                OR CONVERT(nvarchar(20), v.[PersonaId]) LIKE N'%' + @Filtro + N'%'
          )
    )
    SELECT *
    FROM Base
    ORDER BY [PKIdCredito] DESC
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spInfonavit_List]
    @PersonaId int = NULL,
    @Page int = 1,
    @PageSize int = 50,
    @Filtro nvarchar(200) = NULL,
    @Activo bit = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Page = CASE WHEN @Page IS NULL OR @Page < 1 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN @PageSize IS NULL OR @PageSize < 1 THEN 50 WHEN @PageSize > 500 THEN 500 ELSE @PageSize END;
    SET @Filtro = NULLIF(LTRIM(RTRIM(@Filtro)), N'');

    ;WITH Base AS
    (
        SELECT
            v.*,
            COUNT(1) OVER() AS [TotalCount]
        FROM [NOM].[Vw_Infonavit] v
        WHERE (@PersonaId IS NULL OR v.[PersonaId] = @PersonaId)
          AND (@Activo IS NULL OR v.[Activo] = @Activo)
          AND (
                @Filtro IS NULL
                OR v.[MotivoInfonavit] LIKE N'%' + @Filtro + N'%'
                OR CONVERT(nvarchar(20), v.[PersonaId]) LIKE N'%' + @Filtro + N'%'
          )
    )
    SELECT *
    FROM Base
    ORDER BY [PKIdInfonavit] DESC
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[spConceptoConfiguracion_List]
    @EmpresaId int = NULL,
    @PersonaId int = NULL,
    @PuestoId int = NULL,
    @PeriodoId int = NULL,
    @TipoConfiguracion nvarchar(40) = NULL,
    @Page int = 1,
    @PageSize int = 50,
    @Filtro nvarchar(200) = NULL,
    @Activo bit = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Page = CASE WHEN @Page IS NULL OR @Page < 1 THEN 1 ELSE @Page END;
    SET @PageSize = CASE WHEN @PageSize IS NULL OR @PageSize < 1 THEN 50 WHEN @PageSize > 500 THEN 500 ELSE @PageSize END;
    SET @Filtro = NULLIF(LTRIM(RTRIM(@Filtro)), N'');
    SET @TipoConfiguracion = NULLIF(LTRIM(RTRIM(@TipoConfiguracion)), N'');

    ;WITH Base AS
    (
        SELECT
            v.*,
            COUNT(1) OVER() AS [TotalCount]
        FROM [NOM].[Vw_ConceptoConfiguracion] v
        WHERE (@EmpresaId IS NULL OR v.[EmpresaId] = @EmpresaId)
          AND (@PersonaId IS NULL OR v.[PersonaId] = @PersonaId)
          AND (@PuestoId IS NULL OR v.[PuestoId] = @PuestoId)
          AND (@PeriodoId IS NULL OR v.[PeriodoId] = @PeriodoId)
          AND (@TipoConfiguracion IS NULL OR v.[TipoConfiguracion] = @TipoConfiguracion)
          AND (@Activo IS NULL OR v.[Activo] = @Activo)
          AND (
                @Filtro IS NULL
                OR v.[ConceptoClave] LIKE N'%' + @Filtro + N'%'
                OR v.[ConceptoNombre] LIKE N'%' + @Filtro + N'%'
                OR v.[TipoConfiguracion] LIKE N'%' + @Filtro + N'%'
          )
    )
    SELECT *
    FROM Base
    ORDER BY [TipoConfiguracion], [ConceptoClave], [IdConfiguracion]
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO
