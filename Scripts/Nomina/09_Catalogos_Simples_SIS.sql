-- Catalogos simples de Nomina/RH migrados desde BD_GRP_INVEA.dbo.SIS_*.
-- Centraliza catalogos con estructura equivalente y evita crear una tabla por cada lista maestra.

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

IF SCHEMA_ID(N'NOM') IS NULL
    EXEC(N'CREATE SCHEMA NOM');

IF OBJECT_ID(N'NOM.CatalogoSimple', N'U') IS NULL
BEGIN
    CREATE TABLE NOM.CatalogoSimple
    (
        PKIdCatalogoSimple INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_NOM_CatalogoSimple PRIMARY KEY,
        Catalogo NVARCHAR(80) NOT NULL,
        LegacyTable NVARCHAR(128) NULL,
        LegacyId INT NULL,
        Clave NVARCHAR(50) NULL,
        Descripcion NVARCHAR(250) NOT NULL,
        DescripcionCorta NVARCHAR(120) NULL,
        FKIdCatalogoPadre_NOM INT NULL,
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
        Activo BIT NOT NULL CONSTRAINT DF_NOM_CatalogoSimple_Activo DEFAULT (1)
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_NOM_CatalogoSimple_Legacy' AND object_id = OBJECT_ID(N'NOM.CatalogoSimple'))
BEGIN
    CREATE UNIQUE INDEX UX_NOM_CatalogoSimple_Legacy
        ON NOM.CatalogoSimple (Catalogo, LegacyTable, LegacyId)
        WHERE LegacyId IS NOT NULL;
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NOM_CatalogoSimple_CatalogoClave' AND object_id = OBJECT_ID(N'NOM.CatalogoSimple'))
BEGIN
    CREATE INDEX IX_NOM_CatalogoSimple_CatalogoClave
        ON NOM.CatalogoSimple (Catalogo, Clave);
END;

IF OBJECT_ID('tempdb..#CatalogoSimpleSeed') IS NOT NULL
    DROP TABLE #CatalogoSimpleSeed;

CREATE TABLE #CatalogoSimpleSeed
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

DECLARE @Now DATETIME2(6) = SYSDATETIME();

INSERT INTO #CatalogoSimpleSeed
    (Catalogo, LegacyTable, LegacyId, Clave, Descripcion, Orden, UsuarioCreacion, FechaCreacion, UsuarioModificacion, FechaModificacion, Activo)
SELECT N'Sexo', N'SIS_Sexo', Pk_IdSexo, NULL, Descripcion, Pk_IdSexo, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_Sexo
UNION ALL
SELECT N'Estado_Civil', N'SIS_EstadoCivil', Pk_IdEstadoCivil, NULL, Descripcion, Pk_IdEstadoCivil, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_EstadoCivil
UNION ALL
SELECT N'Escolaridad', N'SIS_Escolaridad', Pk_IdEscolaridad, NULL, Descripcion, Pk_IdEscolaridad, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_Escolaridad
UNION ALL
SELECT N'Tipo_Parentesco', N'SIS_Parentesco', Pk_IdParentesco, NULL, Descripcion, Pk_IdParentesco, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_Parentesco
UNION ALL
SELECT N'Base_Pago', N'SIS_BasePago', Pk_IdBasePago, NULL, COALESCE(Descripcion, N''), Pk_IdBasePago, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_BasePago
UNION ALL
SELECT N'Metodo_Pago', N'SIS_MedodoPago', Pk_IdMetodoPago, NULL, Descripcion, Pk_IdMetodoPago, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_MedodoPago
UNION ALL
SELECT N'Tipo_Regimen', N'SIS_TipoRegimen', Pk_IdTipoRegimen, NULL, Descripcion, Pk_IdTipoRegimen, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_TipoRegimen
UNION ALL
SELECT N'Base_Cotizacion', N'SIS_BaseCotizacion', Pk_IdBaseCotizacion, NULL, Descripcion, Pk_IdBaseCotizacion, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_BaseCotizacion
UNION ALL
SELECT N'Zona_Geografica', N'SIS_ZonaGeografica', Pk_IdZonaGeografica, NULL, COALESCE(Descripcion, N''), Pk_IdZonaGeografica, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_ZonaGeografica
UNION ALL
SELECT N'Dia_Semana', N'SIS_DiaSemana', Pk_IdDiaSemana, NULL, COALESCE(Descripcion, N''), Pk_IdDiaSemana, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_DiaSemana
UNION ALL
SELECT N'Tipo_Nomina', N'SIS_TipoNominaEspecial', Pk_IdTipoNominaEspecial, NULL, Descripcion, Pk_IdTipoNominaEspecial, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_TipoNominaEspecial
UNION ALL
SELECT N'Tipo_Descanso', N'SIS_TipoDescanso', Pk_IdTipoDescanso, NULL, Descripcion, Pk_IdTipoDescanso, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_TipoDescanso
UNION ALL
SELECT N'Tipo_Justificacion', N'SIS_TipoJustificacion', Pk_IdTipoJustificacion, NULL, Descripcion, Pk_IdTipoJustificacion, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_TipoJustificacion
UNION ALL
SELECT N'Forma_Calculo', N'SIS_FormaCalculo', Pk_IdFormaCalculo, NULL, Descripcion, Pk_IdFormaCalculo, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_FormaCalculo;

INSERT INTO #CatalogoSimpleSeed
    (Catalogo, LegacyTable, LegacyId, Clave, Descripcion, DescripcionCorta, ValorEntero1, DatoExtra1, DatoExtra2, Orden, UsuarioCreacion, FechaCreacion, UsuarioModificacion, FechaModificacion, Activo)
SELECT N'Banco', N'SIS_Banco', Pk_IdBanco, Clave, Nombre, Cuenta, Fk_IdCuenta, Contacto, Telefono, Pk_IdBanco, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_Banco
UNION ALL
SELECT N'Estado', N'SIS_Estado', Pk_IdEstado, Clave, Nombre, NULL, Fk_IdPais__SIS, NULL, NULL, Pk_IdEstado, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_Estado
UNION ALL
SELECT N'Municipio', N'SIS_Municipio', Pk_IdMunicipio, Clave, Nombre, NULL, Fk_IdEstado__SIS, NULL, NULL, Pk_IdMunicipio, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_Municipio
UNION ALL
SELECT N'Capitulos', N'SIS_Capitulo', Pk_IdCapitulo, Clave, COALESCE(Descripcion, N''), NULL, NULL, NULL, NULL, Pk_IdCapitulo, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_Capitulo;

INSERT INTO #CatalogoSimpleSeed
    (Catalogo, LegacyTable, LegacyId, Clave, Descripcion, DescripcionCorta, ValorDecimal1, ValorDecimal2, FechaInicio, FechaFin, Orden, UsuarioCreacion, FechaCreacion, UsuarioModificacion, FechaModificacion, Activo)
SELECT N'Cuotas_IMSS', N'SIS_CuotasImss', Pk_IdCuotaImss, NULL, Concepto, Alias, ValorEmp, ValorPat, FechaIni, FechaFin, Pk_IdCuotaImss, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_CuotasImss
UNION ALL
SELECT N'UMA', N'SIS_UMA', Pk_IdUma, NULL, CONCAT(N'UMA ', CONVERT(NVARCHAR(10), F_Inicio, 120)), NULL, ValorUma, NULL, F_Inicio, F_Fin, Pk_IdUma, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_UMA
UNION ALL
SELECT N'Unidad_Infonavit', N'SIS_UnidadInfonavit', Pk_IdUnidadInfonavit, NULL, NombreUnidad, NULL, CAST(ValorActual AS DECIMAL(18,4)), NULL, NULL, NULL, Pk_IdUnidadInfonavit, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_UnidadInfonavit;

INSERT INTO #CatalogoSimpleSeed
    (Catalogo, LegacyTable, LegacyId, Clave, Descripcion, ValorDecimal1, DatoExtra1, DatoExtra2, Orden, UsuarioCreacion, FechaCreacion, UsuarioModificacion, FechaModificacion, Activo)
SELECT N'Tipo_Contratacion', N'SIS_TipoContratacion', Pk_IdTipoContratacion, Tipo, Descripcion, NULL, Explicacion, RelacionLaboral, Pk_IdTipoContratacion, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_TipoContratacion
UNION ALL
SELECT N'Tipo_Incidencia', N'SIS_TipoIncidencia', Pk_IdTipoIncidencia, NULL, Descripcion, CAST(DiasPenalizacion AS DECIMAL(18,4)), NULL, NULL, Pk_IdTipoIncidencia, CT_CreatedBy, COALESCE(CT_CreatedDate, @Now), CT_ModifiedBy, CT_ModifiedDate, CT_LIVE
FROM [BD_GRP_INVEA].dbo.SIS_TipoIncidencia;

MERGE NOM.CatalogoSimple AS TARGET
USING #CatalogoSimpleSeed AS SOURCE
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

UPDATE municipio
SET FKIdCatalogoPadre_NOM = estado.PKIdCatalogoSimple
FROM NOM.CatalogoSimple municipio
INNER JOIN NOM.CatalogoSimple estado
    ON estado.Catalogo = N'Estado'
    AND estado.LegacyId = municipio.ValorEntero1
WHERE municipio.Catalogo = N'Municipio'
  AND municipio.LegacyTable = N'SIS_Municipio';

EXEC(N'
CREATE OR ALTER VIEW NOM.Vw_CatalogoSimple
AS
SELECT
    catalogo.PKIdCatalogoSimple,
    catalogo.Catalogo,
    catalogo.LegacyTable,
    catalogo.LegacyId,
    catalogo.Clave,
    catalogo.Descripcion,
    catalogo.DescripcionCorta,
    catalogo.FKIdCatalogoPadre_NOM,
    padre.Descripcion AS CatalogoPadreDescripcion,
    catalogo.ValorDecimal1,
    catalogo.ValorDecimal2,
    catalogo.ValorEntero1,
    catalogo.ValorEntero2,
    catalogo.FechaInicio,
    catalogo.FechaFin,
    catalogo.DatoExtra1,
    catalogo.DatoExtra2,
    catalogo.Orden,
    catalogo.UsuarioCreacion,
    catalogo.FechaCreacion,
    catalogo.UsuarioModificacion,
    catalogo.FechaModificacion,
    catalogo.Activo
FROM NOM.CatalogoSimple catalogo
LEFT JOIN NOM.CatalogoSimple padre
    ON padre.PKIdCatalogoSimple = catalogo.FKIdCatalogoPadre_NOM;
');

EXEC(N'
CREATE OR ALTER PROCEDURE NOM.spCatalogoSimplePorCatalogo
    @Catalogo NVARCHAR(80),
    @SoloActivos BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM NOM.Vw_CatalogoSimple
    WHERE Catalogo = @Catalogo
      AND (@SoloActivos = 0 OR Activo = 1)
    ORDER BY COALESCE(Orden, PKIdCatalogoSimple), Descripcion;
END;
');

SELECT Catalogo, COUNT(1) AS Total
FROM NOM.CatalogoSimple
GROUP BY Catalogo
ORDER BY Catalogo;
