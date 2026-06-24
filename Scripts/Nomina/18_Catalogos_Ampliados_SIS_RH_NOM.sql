-- Catalogos adicionales SIS/RH migrados desde BD_GRP_INVEA.
-- Complementa entidades legacy como Sexo con tablas hermanas que no estaban
-- visibles aun en el menu/configuracion de Nomina.

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;

IF SCHEMA_ID(N'NOM') IS NULL
    EXEC(N'CREATE SCHEMA NOM');

IF OBJECT_ID(N'NOM.CatalogoSimple', N'U') IS NULL
    THROW 51000, 'Falta NOM.CatalogoSimple. Ejecute primero 09_Catalogos_Simples_SIS.sql.', 1;

IF DB_ID(N'BD_GRP_INVEA') IS NULL
BEGIN
    PRINT N'No existe BD_GRP_INVEA; se omite la carga ampliada de catalogos SIS/RH.';
END
ELSE
BEGIN

DECLARE @Now DATETIME2(6) = SYSDATETIME();

IF OBJECT_ID('tempdb..#CatalogoSimpleSeedAmpliado') IS NOT NULL
    DROP TABLE #CatalogoSimpleSeedAmpliado;

CREATE TABLE #CatalogoSimpleSeedAmpliado
(
    Catalogo NVARCHAR(80) NOT NULL,
    LegacyTable NVARCHAR(128) NOT NULL,
    LegacyId INT NOT NULL,
    Clave NVARCHAR(50) NULL,
    Descripcion NVARCHAR(250) NOT NULL,
    DescripcionCorta NVARCHAR(120) NULL,
    ValorDecimal1 DECIMAL(18,4) NULL,
    ValorDecimal2 DECIMAL(18,4) NULL,
    ValorEntero1 INT NULL,
    ValorEntero2 INT NULL,
    FechaInicio DATE NULL,
    FechaFin DATE NULL,
    DatoExtra1 NVARCHAR(500) NULL,
    DatoExtra2 NVARCHAR(500) NULL,
    Orden INT NULL,
    UsuarioCreacion INT NULL,
    FechaCreacion DATETIME2(6) NULL,
    UsuarioModificacion INT NULL,
    FechaModificacion DATETIME2(6) NULL,
    Activo BIT NOT NULL
);

INSERT INTO #CatalogoSimpleSeedAmpliado
    (Catalogo, LegacyTable, LegacyId, Clave, Descripcion, Orden, UsuarioCreacion, FechaCreacion, UsuarioModificacion, FechaModificacion, Activo)
SELECT N'Tipo_Sangre', N'SIS_TipoSangre', src.Pk_IdTipoSangre, NULL, COALESCE(src.Descripcion, N''), src.Pk_IdTipoSangre, NULL, @Now, src.CT_ModifiedBy, src.CT_ModifiedDate, 1
FROM [BD_GRP_INVEA].dbo.SIS_TipoSangre AS src
UNION ALL
SELECT N'Profesion', N'SIS_Profesion', src.Pk_IdProfesion, NULL, COALESCE(src.Descripcion, N''), src.Pk_IdProfesion, NULL, @Now, src.CT_ModifiedBy, src.CT_ModifiedDate, 1
FROM [BD_GRP_INVEA].dbo.SIS_Profesion AS src
UNION ALL
SELECT N'Regimen_Fiscal', N'SIS_RegimenFiscal', src.Pk_IdRegimenFiscal, CONVERT(NVARCHAR(50), src.Clave), COALESCE(src.Nombre, N''), src.Pk_IdRegimenFiscal, NULL, @Now, src.CT_ModifiedBy, src.CT_ModifiedDate, 1
FROM [BD_GRP_INVEA].dbo.SIS_RegimenFiscal AS src
UNION ALL
SELECT N'Periodo_Pago', N'SIS_PeriodoPago', src.Pk_IdPeriodoPago, NULL, COALESCE(src.Descripcion, N''), src.Pk_IdPeriodoPago, NULL, @Now, NULL, NULL, 1
FROM [BD_GRP_INVEA].dbo.SIS_PeriodoPago AS src
UNION ALL
SELECT N'Tipo_Documento', N'SIS_TipoDocumento', src.Pk_IdTipoDocumento, NULL, COALESCE(src.Descripcion, N''), src.Pk_IdTipoDocumento, NULL, @Now, src.CT_ModifiedBy, src.CT_ModifiedDate, 1
FROM [BD_GRP_INVEA].dbo.SIS_TipoDocumento AS src
UNION ALL
SELECT N'Tipo_Expediente', N'SIS_TipoExpediente', src.Pk_IdTipoExpediente, NULL, COALESCE(src.Descripcion, N''), src.Pk_IdTipoExpediente, NULL, @Now, src.CT_ModifiedBy, src.CT_ModifiedDate, 1
FROM [BD_GRP_INVEA].dbo.SIS_TipoExpediente AS src;

INSERT INTO #CatalogoSimpleSeedAmpliado
    (Catalogo, LegacyTable, LegacyId, Clave, Descripcion, DescripcionCorta, DatoExtra1, DatoExtra2, Orden, UsuarioCreacion, FechaCreacion, UsuarioModificacion, FechaModificacion, Activo)
SELECT
    N'Pais',
    N'SIS_Pais',
    src.Pk_IdPais,
    CONVERT(NVARCHAR(50), src.Clave),
    COALESCE(src.Nombre, N''),
    src.NombreOficial,
    src.Alfa2,
    CONCAT(COALESCE(src.Alfa3, N''), N'|', COALESCE(src.Denominacion, N'')),
    src.Pk_IdPais,
    src.CT_CreatedBy,
    COALESCE(src.CT_CreatedDate, @Now),
    src.CT_ModifiedBy,
    src.CT_ModifiedDate,
    COALESCE(src.CT_LIVE, 1)
FROM [BD_GRP_INVEA].dbo.SIS_Pais AS src
UNION ALL
SELECT N'Opcion_Jubilacion', N'RH_OpcionJubilacion', src.Pk_IdOpcionJubilacion, NULL, COALESCE(src.Descripcion, N''), NULL, NULL, NULL, src.Pk_IdOpcionJubilacion, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
FROM [BD_GRP_INVEA].dbo.RH_OpcionJubilacion AS src
UNION ALL
SELECT N'Tipo_Documento_RH', N'RH_TipoDocumento', src.Pk_IdTipoDocumento, NULL, COALESCE(src.Descripcion, N''), NULL, NULL, NULL, src.Pk_IdTipoDocumento, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
FROM [BD_GRP_INVEA].dbo.RH_TipoDocumento AS src
UNION ALL
SELECT N'Situacion_Persona', N'RH_SituacionPersona', src.Pk_IdSituacionPersona, NULL, COALESCE(src.Descripcion, N''), NULL, NULL, NULL, src.Pk_IdSituacionPersona, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
FROM [BD_GRP_INVEA].dbo.RH_SituacionPersona AS src
UNION ALL
SELECT N'Situacion_Plaza', N'RH_SituacionPlaza', src.Pk_IdSituacionPlaza, NULL, COALESCE(src.Descripcion, N''), NULL, NULL, NULL, src.Pk_IdSituacionPlaza, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
FROM [BD_GRP_INVEA].dbo.RH_SituacionPlaza AS src
UNION ALL
SELECT N'Situacion_Movimiento', N'RH_SituacionMovimiento', src.Pk_IdSituacionMovimiento, NULL, COALESCE(src.Descripcion, N''), NULL, NULL, NULL, src.Pk_IdSituacionMovimiento, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
FROM [BD_GRP_INVEA].dbo.RH_SituacionMovimiento AS src
UNION ALL
SELECT N'Clase_Movimiento', N'RH_ClaseMovto', src.Pk_IdClaseMovto, NULL, COALESCE(src.Descripcion, N''), NULL, NULL, NULL, src.Pk_IdClaseMovto, src.CT_CreatedBy, COALESCE(src.CT_CreatedDate, @Now), src.CT_ModifiedBy, src.CT_ModifiedDate, COALESCE(src.CT_LIVE, 1)
FROM [BD_GRP_INVEA].dbo.RH_ClaseMovto AS src;

INSERT INTO #CatalogoSimpleSeedAmpliado
    (Catalogo, LegacyTable, LegacyId, Clave, Descripcion, DescripcionCorta, ValorEntero1, Orden, UsuarioCreacion, FechaCreacion, UsuarioModificacion, FechaModificacion, Activo)
SELECT
    N'Movimiento_RH',
    N'RH_Movimiento',
    src.Pk_IdMovimiento,
    CONVERT(NVARCHAR(50), src.Clave),
    COALESCE(src.Descripcion, N''),
    src.Abreviatura,
    CONVERT(INT, COALESCE(src.AplicaHistorico, 0)),
    src.Pk_IdMovimiento,
    src.CT_CreatedBy,
    COALESCE(src.CT_CreatedDate, @Now),
    src.CT_ModifiedBy,
    src.CT_ModifiedDate,
    COALESCE(src.CT_LIVE, 1)
FROM [BD_GRP_INVEA].dbo.RH_Movimiento AS src;

MERGE NOM.CatalogoSimple AS TARGET
USING #CatalogoSimpleSeedAmpliado AS SOURCE
ON TARGET.Catalogo = SOURCE.Catalogo
AND TARGET.LegacyTable = SOURCE.LegacyTable
AND TARGET.LegacyId = SOURCE.LegacyId
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Clave = SOURCE.Clave,
        TARGET.Descripcion = SOURCE.Descripcion,
        TARGET.DescripcionCorta = SOURCE.DescripcionCorta,
        TARGET.ValorDecimal1 = SOURCE.ValorDecimal1,
        TARGET.ValorDecimal2 = SOURCE.ValorDecimal2,
        TARGET.ValorEntero1 = SOURCE.ValorEntero1,
        TARGET.ValorEntero2 = SOURCE.ValorEntero2,
        TARGET.FechaInicio = SOURCE.FechaInicio,
        TARGET.FechaFin = SOURCE.FechaFin,
        TARGET.DatoExtra1 = SOURCE.DatoExtra1,
        TARGET.DatoExtra2 = SOURCE.DatoExtra2,
        TARGET.Orden = SOURCE.Orden,
        TARGET.UsuarioCreacion = COALESCE(TARGET.UsuarioCreacion, SOURCE.UsuarioCreacion),
        TARGET.FechaCreacion = COALESCE(TARGET.FechaCreacion, SOURCE.FechaCreacion),
        TARGET.UsuarioModificacion = SOURCE.UsuarioModificacion,
        TARGET.FechaModificacion = SOURCE.FechaModificacion,
        TARGET.Activo = SOURCE.Activo
WHEN NOT MATCHED BY TARGET THEN
    INSERT
    (
        Catalogo,
        LegacyTable,
        LegacyId,
        Clave,
        Descripcion,
        DescripcionCorta,
        ValorDecimal1,
        ValorDecimal2,
        ValorEntero1,
        ValorEntero2,
        FechaInicio,
        FechaFin,
        DatoExtra1,
        DatoExtra2,
        Orden,
        UsuarioCreacion,
        FechaCreacion,
        UsuarioModificacion,
        FechaModificacion,
        Activo
    )
    VALUES
    (
        SOURCE.Catalogo,
        SOURCE.LegacyTable,
        SOURCE.LegacyId,
        SOURCE.Clave,
        SOURCE.Descripcion,
        SOURCE.DescripcionCorta,
        SOURCE.ValorDecimal1,
        SOURCE.ValorDecimal2,
        SOURCE.ValorEntero1,
        SOURCE.ValorEntero2,
        SOURCE.FechaInicio,
        SOURCE.FechaFin,
        SOURCE.DatoExtra1,
        SOURCE.DatoExtra2,
        SOURCE.Orden,
        SOURCE.UsuarioCreacion,
        SOURCE.FechaCreacion,
        SOURCE.UsuarioModificacion,
        SOURCE.FechaModificacion,
        SOURCE.Activo
    );

IF OBJECT_ID('tempdb..#VistasCatalogoSimpleAmpliado') IS NOT NULL
    DROP TABLE #VistasCatalogoSimpleAmpliado;

CREATE TABLE #VistasCatalogoSimpleAmpliado
(
    Vista SYSNAME NOT NULL PRIMARY KEY,
    Catalogo NVARCHAR(80) NOT NULL UNIQUE
);

INSERT INTO #VistasCatalogoSimpleAmpliado (Vista, Catalogo)
VALUES
    (N'Vw_TipoSangre', N'Tipo_Sangre'),
    (N'Vw_Profesion', N'Profesion'),
    (N'Vw_RegimenFiscal', N'Regimen_Fiscal'),
    (N'Vw_Pais', N'Pais'),
    (N'Vw_PeriodoPago', N'Periodo_Pago'),
    (N'Vw_TipoDocumento', N'Tipo_Documento'),
    (N'Vw_TipoDocumentoRh', N'Tipo_Documento_RH'),
    (N'Vw_TipoExpediente', N'Tipo_Expediente'),
    (N'Vw_OpcionJubilacion', N'Opcion_Jubilacion'),
    (N'Vw_SituacionPersona', N'Situacion_Persona'),
    (N'Vw_SituacionPlaza', N'Situacion_Plaza'),
    (N'Vw_SituacionMovimiento', N'Situacion_Movimiento'),
    (N'Vw_ClaseMovimiento', N'Clase_Movimiento'),
    (N'Vw_MovimientoRh', N'Movimiento_RH');

DECLARE @Vista SYSNAME;
DECLARE @Catalogo NVARCHAR(80);
DECLARE @Sql NVARCHAR(MAX);

DECLARE vistas_catalogo_ampliado_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT Vista, Catalogo
FROM #VistasCatalogoSimpleAmpliado
ORDER BY Vista;

OPEN vistas_catalogo_ampliado_cursor;
FETCH NEXT FROM vistas_catalogo_ampliado_cursor INTO @Vista, @Catalogo;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Sql = N'
CREATE OR ALTER VIEW NOM.' + QUOTENAME(@Vista) + N'
AS
SELECT
    c.PKIdCatalogoSimple,
    c.LegacyId,
    c.Clave,
    c.Descripcion,
    c.DescripcionCorta,
    c.FKIdCatalogoPadre_NOM,
    padre.Descripcion AS CatalogoPadreDescripcion,
    c.ValorDecimal1,
    c.ValorDecimal2,
    c.ValorEntero1,
    c.ValorEntero2,
    c.FechaInicio,
    c.FechaFin,
    c.DatoExtra1,
    c.DatoExtra2,
    c.Orden,
    c.UsuarioCreacion,
    c.FechaCreacion,
    c.UsuarioModificacion,
    c.FechaModificacion,
    c.Activo
FROM NOM.CatalogoSimple AS c
LEFT JOIN NOM.CatalogoSimple AS padre
    ON padre.PKIdCatalogoSimple = c.FKIdCatalogoPadre_NOM
WHERE c.Catalogo = N''' + REPLACE(@Catalogo, N'''', N'''''') + N''';';

    EXEC sys.sp_executesql @Sql;
    FETCH NEXT FROM vistas_catalogo_ampliado_cursor INTO @Vista, @Catalogo;
END;

CLOSE vistas_catalogo_ampliado_cursor;
DEALLOCATE vistas_catalogo_ampliado_cursor;

SELECT
    seed.Catalogo,
    COUNT(c.PKIdCatalogoSimple) AS Registros
FROM (SELECT DISTINCT Catalogo FROM #CatalogoSimpleSeedAmpliado) AS seed
LEFT JOIN NOM.CatalogoSimple AS c
    ON c.Catalogo = seed.Catalogo
GROUP BY seed.Catalogo
ORDER BY seed.Catalogo;

DROP TABLE #VistasCatalogoSimpleAmpliado;
DROP TABLE #CatalogoSimpleSeedAmpliado;

PRINT N'Catalogos ampliados SIS/RH migrados correctamente.';
END;
