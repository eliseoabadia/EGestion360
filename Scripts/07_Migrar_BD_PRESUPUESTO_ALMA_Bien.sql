/*
    Migracion: BD_PRESUPUESTO.SICOP.Bien -> GestionEmpresarial.ALMA.Bien

    Reglas:
      - Conserva PK_IdBien mediante IDENTITY_INSERT.
      - No modifica registros que ya existen en el destino con el mismo PKIdBien.
      - Conserva una FK opcional solamente si el registro relacionado existe en
        GestionEmpresarial; en caso contrario inserta NULL.
      - FKIdTipoBien_ALMA es obligatoria: si no existe el TipoBien, el Bien se omite
        y se muestra en el reporte previo.
      - UsuarioCreacion es obligatorio: si el usuario de origen no existe, se usa
        @UsuarioMigracion. UsuarioModificacion invalido se convierte en NULL.
      - Las columnas antiguas sin equivalente (foto, color, persona, etc.) no se migran.

    Uso:
      1. Ejecutar primero con @SoloValidar = 1.
      2. Revisar los tres resultados.
      3. Cambiar @SoloValidar a 0 para confirmar la insercion.
*/

USE [GestionEmpresarial];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @SoloValidar bit = 0;
DECLARE @UsuarioMigracion int = 1;

IF DB_ID(N'BD_PRESUPUESTO') IS NULL
    THROW 50001, 'No existe la base de origen BD_PRESUPUESTO.', 1;

IF OBJECT_ID(N'[ALMA].[Bien]', N'U') IS NULL
    THROW 50002, 'No existe la tabla destino GestionEmpresarial.ALMA.Bien.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM [SIS].[Usuario]
    WHERE [PkIdUsuario] = @UsuarioMigracion
)
    THROW 50003, 'El @UsuarioMigracion no existe en GestionEmpresarial.SIS.Usuario.', 1;

DECLARE @TotalOrigen bigint;
DECLARE @YaExistentes bigint;
DECLARE @SinTipoBien bigint;
DECLARE @Candidatos bigint;
DECLARE @Insertados bigint = 0;

SELECT @TotalOrigen = COUNT_BIG(*)
FROM [BD_PRESUPUESTO].[SICOP].[Bien];

SELECT @YaExistentes = COUNT_BIG(*)
FROM [BD_PRESUPUESTO].[SICOP].[Bien] AS o
WHERE EXISTS
(
    SELECT 1
    FROM [ALMA].[Bien] AS d
    WHERE d.[PKIdBien] = o.[PK_IdBien]
);

SELECT @SinTipoBien = COUNT_BIG(*)
FROM [BD_PRESUPUESTO].[SICOP].[Bien] AS o
WHERE NOT EXISTS
      (
          SELECT 1
          FROM [ALMA].[Bien] AS d
          WHERE d.[PKIdBien] = o.[PK_IdBien]
      )
  AND NOT EXISTS
      (
          SELECT 1
          FROM [ALMA].[TipoBien] AS tb
          WHERE tb.[PKIdTipoBien] = o.[FK_IdTipoBien__SICOP]
      );

SELECT @Candidatos = COUNT_BIG(*)
FROM [BD_PRESUPUESTO].[SICOP].[Bien] AS o
WHERE NOT EXISTS
      (
          SELECT 1
          FROM [ALMA].[Bien] AS d
          WHERE d.[PKIdBien] = o.[PK_IdBien]
      )
  AND EXISTS
      (
          SELECT 1
          FROM [ALMA].[TipoBien] AS tb
          WHERE tb.[PKIdTipoBien] = o.[FK_IdTipoBien__SICOP]
      );

-- Resultado 1: resumen de lo que se insertaria.
SELECT
    @TotalOrigen  AS [TotalOrigen],
    @YaExistentes AS [Omitidos_PkYaExiste],
    @SinTipoBien  AS [Omitidos_TipoBienObligatorioNoExiste],
    @Candidatos   AS [CandidatosAInsertar],
    @UsuarioMigracion AS [UsuarioMigracion];

-- Resultado 2: cantidades de referencias que se convertiran a NULL o al usuario de migracion.
SELECT
    COUNT_BIG(*) AS [Candidatos],
    SUM(CASE WHEN o.[FK_IdGrupoBien__SICOP] IS NOT NULL AND gb.[PKIdGrupoBien] IS NULL THEN 1 ELSE 0 END) AS [GrupoBien_A_NULL],
    SUM(CASE WHEN o.[FK_IdArea__SIS] IS NOT NULL AND a.[PKIdArea] IS NULL THEN 1 ELSE 0 END) AS [Area_A_NULL],
    SUM(CASE WHEN o.[FK_IdProveedor__SIS] IS NOT NULL AND p.[PKIdProveedor] IS NULL THEN 1 ELSE 0 END) AS [Proveedor_A_NULL],
    SUM(CASE WHEN o.[FK_IdEstadoBien__SICOP] IS NOT NULL AND eb.[PKIdEstadoBien] IS NULL THEN 1 ELSE 0 END) AS [EstadoBien_A_NULL],
    SUM(CASE WHEN o.[FK_IdTipoPatrimonio__SICOP] IS NOT NULL AND tp.[PKIdTipoPatrimonio] IS NULL THEN 1 ELSE 0 END) AS [TipoPatrimonio_A_NULL],
    SUM(CASE WHEN o.[FK_IdMarca__SICOP] IS NOT NULL AND m.[PKIdMarca] IS NULL THEN 1 ELSE 0 END) AS [Marca_A_NULL],
    SUM(CASE WHEN o.[FK_IdMaterial__SICOP] IS NOT NULL AND ma.[PKIdMaterial] IS NULL THEN 1 ELSE 0 END) AS [Material_A_NULL],
    SUM(CASE WHEN o.[FK_IdTipoAdq__SICOP] IS NOT NULL AND ta.[PKIdTipoAdq] IS NULL THEN 1 ELSE 0 END) AS [TipoAdq_A_NULL],
    SUM(CASE WHEN o.[FK_IdPartida__SIS] IS NOT NULL AND pa.[PKIdPartida] IS NULL THEN 1 ELSE 0 END) AS [Partida_A_NULL],
    SUM(CASE WHEN uc.[PkIdUsuario] IS NULL THEN 1 ELSE 0 END) AS [UsuarioCreacion_A_UsuarioMigracion],
    SUM(CASE WHEN o.[CT_ModifiedBy] IS NOT NULL AND um.[PkIdUsuario] IS NULL THEN 1 ELSE 0 END) AS [UsuarioModificacion_A_NULL]
FROM [BD_PRESUPUESTO].[SICOP].[Bien] AS o
INNER JOIN [ALMA].[TipoBien] AS tb
    ON tb.[PKIdTipoBien] = o.[FK_IdTipoBien__SICOP]
LEFT JOIN [ALMA].[Bien] AS d
    ON d.[PKIdBien] = o.[PK_IdBien]
LEFT JOIN [ALMA].[GrupoBien] AS gb
    ON gb.[PKIdGrupoBien] = o.[FK_IdGrupoBien__SICOP]
LEFT JOIN [SIS].[Area] AS a
    ON a.[PKIdArea] = o.[FK_IdArea__SIS]
LEFT JOIN [SIS].[Proveedor] AS p
    ON p.[PKIdProveedor] = o.[FK_IdProveedor__SIS]
LEFT JOIN [ALMA].[EstadoBien] AS eb
    ON eb.[PKIdEstadoBien] = o.[FK_IdEstadoBien__SICOP]
LEFT JOIN [ALMA].[TipoPatrimonio] AS tp
    ON tp.[PKIdTipoPatrimonio] = o.[FK_IdTipoPatrimonio__SICOP]
LEFT JOIN [ALMA].[Marca] AS m
    ON m.[PKIdMarca] = o.[FK_IdMarca__SICOP]
LEFT JOIN [ALMA].[Material] AS ma
    ON ma.[PKIdMaterial] = o.[FK_IdMaterial__SICOP]
LEFT JOIN [ALMA].[TipoAdquisicion] AS ta
    ON ta.[PKIdTipoAdq] = o.[FK_IdTipoAdq__SICOP]
LEFT JOIN [CONTA].[Partida] AS pa
    ON pa.[PKIdPartida] = o.[FK_IdPartida__SIS]
LEFT JOIN [SIS].[Usuario] AS uc
    ON uc.[PkIdUsuario] = o.[CT_CreatedBy]
LEFT JOIN [SIS].[Usuario] AS um
    ON um.[PkIdUsuario] = o.[CT_ModifiedBy]
WHERE d.[PKIdBien] IS NULL;

-- Resultado 3: bienes omitidos porque la FK obligatoria TipoBien no existe.
SELECT
    o.[PK_IdBien],
    o.[Clave],
    o.[FK_IdTipoBien__SICOP] AS [TipoBienOrigenNoExistente]
FROM [BD_PRESUPUESTO].[SICOP].[Bien] AS o
WHERE NOT EXISTS
      (
          SELECT 1
          FROM [ALMA].[Bien] AS d
          WHERE d.[PKIdBien] = o.[PK_IdBien]
      )
  AND NOT EXISTS
      (
          SELECT 1
          FROM [ALMA].[TipoBien] AS tb
          WHERE tb.[PKIdTipoBien] = o.[FK_IdTipoBien__SICOP]
      )
ORDER BY o.[PK_IdBien];

IF @SoloValidar = 1
BEGIN
    PRINT 'SOLO VALIDACION: no se inserto ningun registro. Cambie @SoloValidar a 0 para ejecutar.';
    RETURN;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [ALMA].[Bien] ON;

    INSERT INTO [ALMA].[Bien]
    (
        [PKIdBien],
        [FKIdGrupoBien_ALMA],
        [FKIdTipoBien_ALMA],
        [FKIdArea_SIS],
        [FKIdProveedor_SIS],
        [FKIdEstadoBien_ALMA],
        [FKIdTipoPatrimonio_ALMA],
        [FKIdMarca_ALMA],
        [FKIdMaterial_ALMA],
        [FKIdTipoAdq_ALMA],
        [FKIdPartida_CONTA],
        [FKIdDetalleOrdenCompra_ORCO],
        [Clave],
        [ClaveAnt],
        [Descripcion],
        [Modelo],
        [Serie],
        [Requisicion],
        [Factura],
        [Costo],
        [FechaAdq],
        [Referencia],
        [Notas],
        [Ubicacion],
        [AAdquisicion],
        [Frente],
        [Fondo],
        [Altura],
        [Diametro],
        [VerificacionesDias],
        [MantenimientoDias],
        [Mantenimiento],
        [Calibracion],
        [Rango],
        [Resolucion],
        [FechaUltInv],
        [FechaReqscn],
        [Estatus],
        [Caracteristicas],
        [Resguardo],
        [ResguardoAnterior],
        [RelId],
        [ValorRescate],
        [ValorActual],
        [Antiguedad],
        [Progresivo],
        [Consecutivo],
        [ClaveHist],
        [EstaResguardado],
        [FechaResguardado],
        [Localizado],
        [esContabilizado],
        [Activo],
        [FechaCreacion],
        [UsuarioCreacion],
        [FechaModificacion],
        [UsuarioModificacion]
    )
    SELECT
        o.[PK_IdBien],
        gb.[PKIdGrupoBien],
        tb.[PKIdTipoBien],
        a.[PKIdArea],
        p.[PKIdProveedor],
        eb.[PKIdEstadoBien],
        tp.[PKIdTipoPatrimonio],
        m.[PKIdMarca],
        ma.[PKIdMaterial],
        ta.[PKIdTipoAdq],
        pa.[PKIdPartida],
        o.[FK_IdDetalleOrdenCompra__ORCO],
        o.[Clave],
        o.[ClaveAnt],
        o.[Descripcion],
        o.[Modelo],
        o.[Serie],
        o.[Requisicion],
        o.[Factura],
        o.[Costo],
        o.[FechaAdq],
        o.[Referencia],
        o.[Notas],
        o.[Ubicacion],
        o.[AAdquisicion],
        o.[Frente],
        o.[Fondo],
        o.[Altura],
        o.[Diametro],
        o.[VerificacionesDias],
        o.[MantenimientoDias],
        o.[Mantenimiento],
        o.[Calibracion],
        o.[Rango],
        o.[Resolucion],
        o.[FechaUltInv],
        o.[FechaReqscn],
        o.[Estatus],
        o.[Caracteristicas],
        o.[Resguardo],
        o.[ResguardoAnterior],
        o.[RelId],
        o.[ValorRescate],
        o.[ValorActual],
        o.[Antiguedad],
        o.[Progresivo],
        o.[Consecutivo],
        o.[ClaveHist],
        o.[EstaResguardado],
        o.[FechaResguardado],
        o.[Localizado],
        o.[esContabilizado],
        o.[CT_LIVE],
        o.[CT_CreatedDate],
        COALESCE(uc.[PkIdUsuario], @UsuarioMigracion),
        o.[CT_ModifiedDate],
        um.[PkIdUsuario]
    FROM [BD_PRESUPUESTO].[SICOP].[Bien] AS o
    INNER JOIN [ALMA].[TipoBien] AS tb
        ON tb.[PKIdTipoBien] = o.[FK_IdTipoBien__SICOP]
    LEFT JOIN [ALMA].[GrupoBien] AS gb
        ON gb.[PKIdGrupoBien] = o.[FK_IdGrupoBien__SICOP]
    LEFT JOIN [SIS].[Area] AS a
        ON a.[PKIdArea] = o.[FK_IdArea__SIS]
    LEFT JOIN [SIS].[Proveedor] AS p
        ON p.[PKIdProveedor] = o.[FK_IdProveedor__SIS]
    LEFT JOIN [ALMA].[EstadoBien] AS eb
        ON eb.[PKIdEstadoBien] = o.[FK_IdEstadoBien__SICOP]
    LEFT JOIN [ALMA].[TipoPatrimonio] AS tp
        ON tp.[PKIdTipoPatrimonio] = o.[FK_IdTipoPatrimonio__SICOP]
    LEFT JOIN [ALMA].[Marca] AS m
        ON m.[PKIdMarca] = o.[FK_IdMarca__SICOP]
    LEFT JOIN [ALMA].[Material] AS ma
        ON ma.[PKIdMaterial] = o.[FK_IdMaterial__SICOP]
    LEFT JOIN [ALMA].[TipoAdquisicion] AS ta
        ON ta.[PKIdTipoAdq] = o.[FK_IdTipoAdq__SICOP]
    LEFT JOIN [CONTA].[Partida] AS pa
        ON pa.[PKIdPartida] = o.[FK_IdPartida__SIS]
    LEFT JOIN [SIS].[Usuario] AS uc
        ON uc.[PkIdUsuario] = o.[CT_CreatedBy]
    LEFT JOIN [SIS].[Usuario] AS um
        ON um.[PkIdUsuario] = o.[CT_ModifiedBy]
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [ALMA].[Bien] AS d WITH (UPDLOCK, HOLDLOCK)
        WHERE d.[PKIdBien] = o.[PK_IdBien]
    );

    SET @Insertados = @@ROWCOUNT;

    SET IDENTITY_INSERT [ALMA].[Bien] OFF;

    COMMIT TRANSACTION;

    SELECT
        N'MIGRACION CONFIRMADA' AS [Estado],
        @Insertados AS [Insertados],
        @YaExistentes AS [Omitidos_PkYaExiste],
        @SinTipoBien AS [Omitidos_TipoBienObligatorioNoExiste];
END TRY
BEGIN CATCH
print 'aqui'
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    BEGIN TRY
        SET IDENTITY_INSERT [ALMA].[Bien] OFF;
    END TRY
    BEGIN CATCH
        -- Evita ocultar el error original si IDENTITY_INSERT nunca llego a activarse.
    END CATCH;

    THROW;
END CATCH;
