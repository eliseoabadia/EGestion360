USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [CONTA].[SPR_AlmacéndeMateriales]
    @p_FecInicio nvarchar(24),
    @p_FecFin nvarchar(24)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @FechaFin date = TRY_CONVERT(date, @p_FecFin);

    SELECT
        E.[PKIdTipoBien] AS [id],
        ISNULL(CC.[ClaveNombre], 'Configure Cuenta') AS [CODIGO],
        E.[Descripcion] AS [S/PG],
        SUM(E.[Existencias]) AS [CANTIDAD],
        E.[Unidades] AS [UM],
        ISNULL(MAX(E.[CostoPromedio]), 0) AS [CU],
        SUM(E.[Existencias]) * ISNULL(MAX(E.[CostoPromedio]), 0) AS [MONTO],
        CAST('' AS nvarchar(64)) AS [Funcion1],
        CAST('' AS nvarchar(64)) AS [Funcion2],
        CAST('' AS nvarchar(64)) AS [Funcion3],
        CAST('' AS nvarchar(254)) AS [Nombre1],
        CAST('' AS nvarchar(254)) AS [Nombre2],
        CAST('' AS nvarchar(254)) AS [Nombre3],
        CAST('' AS nvarchar(254)) AS [Puesto1],
        CAST('' AS nvarchar(254)) AS [Puesto2],
        CAST('' AS nvarchar(254)) AS [Puesto3],
        CAST(CONCAT('AL ', UPPER(FORMAT(ISNULL(@FechaFin, GETDATE()), 'dd \DE MMMM \DEL yyyy', 'es-MX'))) AS nvarchar(128)) AS [Titulo]
    FROM [ALMA].[Vw_Existencias] AS E
    LEFT JOIN [ALMA].[TipoBien] AS TB ON E.[PKIdTipoBien] = TB.[PKIdTipoBien]
    LEFT JOIN [CONTA].[VW_CUENTAS] AS CC ON TB.[FKIdCuentaContable_CONTA] = CC.[PkIdCuenta]
    GROUP BY
        E.[PKIdTipoBien],
        CC.[ClaveNombre],
        E.[Descripcion],
        E.[Unidades];
END;
GO

CREATE OR ALTER PROCEDURE [ALMA].[SPR_LibroAlmacenSuministros]
    @Error nvarchar(max) OUTPUT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    SET @Error = NULL;

    SELECT
        E.[PKIdTipoBien],
        ISNULL(CC.[ClaveNombre], 'Configure Cuenta') AS [Codigo],
        E.[Descripcion],
        SUM(E.[Existencias]) AS [Cantidad],
        E.[Unidades],
        E.[FK_IdUnidades__ALMA],
        ISNULL(MAX(E.[CostoPromedio]), 0) AS [CostoUnitario],
        SUM(E.[Existencias]) * ISNULL(MAX(E.[CostoPromedio]), 0) AS [Monto]
    FROM [ALMA].[Vw_Existencias] AS E
    LEFT JOIN [ALMA].[TipoBien] AS TB ON E.[PKIdTipoBien] = TB.[PKIdTipoBien]
    LEFT JOIN [CONTA].[VW_CUENTAS] AS CC ON TB.[FKIdCuentaContable_CONTA] = CC.[PkIdCuenta]
    GROUP BY
        E.[PKIdTipoBien],
        CC.[ClaveNombre],
        E.[Descripcion],
        E.[Unidades],
        E.[FK_IdUnidades__ALMA];

    RETURN 0;
END;
GO

CREATE OR ALTER PROCEDURE [ALMA].[SPR_LibroAlmacenSuministros_DevEx]
    @FechaInicio datetime,
    @FechaFin datetime,
    @Error nvarchar(max) OUTPUT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    SET @Error = NULL;

    SELECT
        CAST(NULL AS nvarchar(30)) AS [ClavePersona],
        SS.[Solicitante] AS [Persona],
        CAST(NULL AS nvarchar(50)) AS [NombreAutoriza],
        CAST(NULL AS nvarchar(100)) AS [PuestoAutoriza],
        CAST(NULL AS nvarchar(100)) AS [PuestoSolicita],
        SS.[Observaciones] AS [DescripcionSolicitud],
        RIGHT('00' + CONVERT(varchar(2), DAY(SS.[FechaSolicitud])), 2) AS [Dia],
        DATENAME(month, SS.[FechaSolicitud]) AS [Mes],
        YEAR(SS.[FechaSolicitud]) AS [Anio],
        ROW_NUMBER() OVER (ORDER BY SS.[FechaSolicitud], SS.[PKIdSolicitudSalida]) AS [Consecutivo],
        CONVERT(nvarchar(10), SS.[FechaSolicitud], 103) AS [FechaSolicitud],
        AR.[Clave] AS [ClaveArea],
        AR.[Nombre] AS [Area],
        SS.[Folio] AS [NumeroVale],
        TB.[CodigoClave] AS [ClaveArticulo],
        LEFT(ISNULL(TB.[CABMS], ''), 4) AS [Partida],
        GB.[Descripcion] AS [Subcuenta],
        CAST('PROGRAMA' AS varchar(8)) AS [Programa],
        DS.[CantidadEntregada] AS [Cantidad],
        UN.[Descripcion] AS [Unidad],
        TB.[Descripcion] AS [DesArticulo],
        DS.[CantidadEntregada] AS [Salidas],
        ISNULL(AL.[CostoUnitario], 0) AS [CostoUnitario],
        ISNULL(AL.[CostoUnitario], 0) * ISNULL(DS.[CantidadEntregada], 0) AS [Monto]
    FROM [ALMA].[SolicitudSalida] AS SS
    INNER JOIN [ALMA].[DetalleSolicitudSalida] AS DS ON DS.[FKIdSolicitudSalida_ALMA] = SS.[PKIdSolicitudSalida] AND DS.[Activo] = 1
    LEFT JOIN [ALMA].[Almacen] AS AL ON AL.[PKIdAlmacen] = DS.[FKIdAlmacen_ALMA] AND AL.[Activo] = 1
    LEFT JOIN [ALMA].[TipoBien] AS TB ON TB.[PKIdTipoBien] = DS.[FKIdTipoBien_ALMA] AND TB.[Activo] = 1
    LEFT JOIN [ALMA].[GrupoBien] AS GB ON GB.[PKIdGrupoBien] = TB.[FKIdGrupoBien_ALMA] AND GB.[Activo] = 1
    LEFT JOIN [ALMA].[Unidades] AS UN ON UN.[PKIdUnidades] = DS.[FKIdUnidades_ALMA] AND UN.[Activo] = 1
    LEFT JOIN [SIS].[Area] AS AR ON AR.[PKIdArea] = SS.[FKIdAreaSolicita_SIS]
    WHERE SS.[Activo] = 1
      AND SS.[FechaSolicitud] BETWEEN CONVERT(date, @FechaInicio) AND CONVERT(date, @FechaFin)
    ORDER BY SS.[FechaSolicitud], SS.[PKIdSolicitudSalida];

    RETURN 0;
END;
GO

CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepActFijos]
    @p_FecInicio nvarchar(24)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = TRY_CONVERT(date, @p_FecInicio);

    DECLARE @tablaFirma table (
        id int IDENTITY(1,1) NOT NULL,
        Funcion nvarchar(64) NULL,
        Nombre nvarchar(254) NULL
    );

    INSERT INTO @tablaFirma (Funcion, Nombre)
    SELECT F.[Funcion], CONCAT(P.[Nombre], ' ', P.[Paterno], ' ', P.[Materno])
    FROM [SIS].[Reporte] AS R
    INNER JOIN [SIS].[FirmaAutorizada] AS F ON R.[Pk_IdReporte] = F.[Fk_IdReporte__SIS]
    INNER JOIN [RHCT].[Persona] AS P ON F.[Fk_IdPersona__RHCT] = P.[PK_IdPersona]
    WHERE R.[Controlador] = 'RepLibroInventarioBienes'
      AND R.[Activo] = 1
      AND F.[Activo] = 1;

    DECLARE @Funcion1 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 1), '');
    DECLARE @Funcion2 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 2), '');
    DECLARE @Funcion3 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 3), '');
    DECLARE @Nombre1 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 1), '');
    DECLARE @Nombre2 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 2), '');
    DECLARE @Nombre3 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 3), '');
    DECLARE @Puesto1 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre1 + '%'), '');
    DECLARE @Puesto2 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre2 + '%'), '');
    DECLARE @Puesto3 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre3 + '%'), '');

    SELECT
        bn.[Clave] AS [Codigo],
        bn.[Descripcion],
        bn.[Costo] AS [Valor],
        @Funcion1 AS [Funcion1],
        @Funcion2 AS [Funcion2],
        @Funcion3 AS [Funcion3],
        @Nombre1 AS [Nombre1],
        @Nombre2 AS [Nombre2],
        @Nombre3 AS [Nombre3],
        @Puesto1 AS [Puesto1],
        @Puesto2 AS [Puesto2],
        @Puesto3 AS [Puesto3],
        CAST(CONCAT('AL ', UPPER(FORMAT(ISNULL(@p_FechaInicio, GETDATE()), 'dd \DE MMMM \DEL yyyy', 'es-MX'))) AS nvarchar(128)) AS [Titulo]
    FROM [SICOP].[VW_Bien] AS bn
    INNER JOIN [SICOP].[TipoBien] AS tb ON bn.[FK_IdTipoBien__SICOP] = tb.[PK_IdTipoBien]
    LEFT JOIN [ALMA].[Unidades] AS un ON tb.[FK_IdUnidades_Equivalente] = un.[PKIdUnidades]
    ORDER BY bn.[Clave];
END;
GO

CREATE OR ALTER PROCEDURE [SICOP].[SPR_LibroInventarioBienes]
    @p_FecInicio nvarchar(24)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = TRY_CONVERT(date, @p_FecInicio);

    DECLARE @tablaFirma table (
        id int IDENTITY(1,1) NOT NULL,
        Funcion nvarchar(64) NULL,
        Nombre nvarchar(254) NULL
    );

    INSERT INTO @tablaFirma (Funcion, Nombre)
    SELECT F.[Funcion], CONCAT(P.[Nombre], ' ', P.[Paterno], ' ', P.[Materno])
    FROM [SIS].[Reporte] AS R
    INNER JOIN [SIS].[FirmaAutorizada] AS F ON R.[Pk_IdReporte] = F.[Fk_IdReporte__SIS]
    INNER JOIN [RHCT].[Persona] AS P ON F.[Fk_IdPersona__RHCT] = P.[PK_IdPersona]
    WHERE R.[Controlador] = 'RepLibroInventarioBienes'
      AND R.[Activo] = 1
      AND F.[Activo] = 1;

    DECLARE @Funcion1 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 1), '');
    DECLARE @Funcion2 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 2), '');
    DECLARE @Funcion3 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 3), '');
    DECLARE @Nombre1 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 1), '');
    DECLARE @Nombre2 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 2), '');
    DECLARE @Nombre3 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 3), '');
    DECLARE @Puesto1 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre1 + '%'), '');
    DECLARE @Puesto2 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre2 + '%'), '');
    DECLARE @Puesto3 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre3 + '%'), '');

    SELECT
        bn.[PK_IdBien],
        bn.[Clave] AS [NumeroInventario],
        bn.[Descripcion],
        CAST(1 AS int) AS [Cantidad],
        un.[Descripcion] AS [Unidades],
        bn.[Costo],
        bn.[Costo] AS [Monto],
        @Funcion1 AS [Funcion1],
        @Funcion2 AS [Funcion2],
        @Funcion3 AS [Funcion3],
        @Nombre1 AS [Nombre1],
        @Nombre2 AS [Nombre2],
        @Nombre3 AS [Nombre3],
        @Puesto1 AS [Puesto1],
        @Puesto2 AS [Puesto2],
        @Puesto3 AS [Puesto3],
        CAST(CONCAT('AL ', UPPER(FORMAT(ISNULL(@p_FechaInicio, GETDATE()), 'dd \DE MMMM \DEL yyyy', 'es-MX'))) AS nvarchar(128)) AS [Titulo]
    FROM [SICOP].[VW_Bien] AS bn
    INNER JOIN [SICOP].[TipoBien] AS tb ON bn.[FK_IdTipoBien__SICOP] = tb.[PK_IdTipoBien]
    LEFT JOIN [ALMA].[Unidades] AS un ON tb.[FK_IdUnidades_Equivalente] = un.[PKIdUnidades]
    ORDER BY bn.[Clave];
END;
GO

CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepArtFaltporSurtir]
    @p_FecInicio nvarchar(24),
    @p_FecFin nvarchar(24)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = TRY_CONVERT(date, @p_FecInicio);
    DECLARE @p_FechaFin date = TRY_CONVERT(date, @p_FecFin);

    DECLARE @tablaFirma table (
        id int IDENTITY(1,1) NOT NULL,
        Funcion nvarchar(64) NULL,
        Nombre nvarchar(254) NULL
    );

    INSERT INTO @tablaFirma (Funcion, Nombre)
    SELECT F.[Funcion], CONCAT(P.[Nombre], ' ', P.[Paterno], ' ', P.[Materno])
    FROM [SIS].[Reporte] AS R
    INNER JOIN [SIS].[FirmaAutorizada] AS F ON R.[Pk_IdReporte] = F.[Fk_IdReporte__SIS]
    INNER JOIN [RHCT].[Persona] AS P ON F.[Fk_IdPersona__RHCT] = P.[PK_IdPersona]
    WHERE R.[Controlador] = 'RepArtFaltporSurtir'
      AND R.[Activo] = 1
      AND F.[Activo] = 1;

    DECLARE @Funcion1 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 1), '');
    DECLARE @Funcion2 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 2), '');
    DECLARE @Funcion3 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 3), '');
    DECLARE @Nombre1 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 1), '');
    DECLARE @Nombre2 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 2), '');
    DECLARE @Nombre3 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 3), '');
    DECLARE @Puesto1 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre1 + '%'), '');
    DECLARE @Puesto2 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre2 + '%'), '');
    DECLARE @Puesto3 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre3 + '%'), '');

    SELECT
        od.[PKIdOrdenCompraDetalle] AS [ID],
        CAST(NULL AS int) AS [PP],
        od.[TipoBienCodigoClave] AS [cabmsdf],
        od.[TipoBienDescripcion] AS [concepto],
        od.[CantidadPendiente] AS [exissurtir],
        @Funcion1 AS [Funcion1],
        @Funcion2 AS [Funcion2],
        @Funcion3 AS [Funcion3],
        @Nombre1 AS [Nombre1],
        @Nombre2 AS [Nombre2],
        @Nombre3 AS [Nombre3],
        @Puesto1 AS [Puesto1],
        @Puesto2 AS [Puesto2],
        @Puesto3 AS [Puesto3],
        CAST(CONCAT('PERIODO DEL ', FORMAT(ISNULL(@p_FechaInicio, GETDATE()), 'dd \de MMMM \del yyyy', 'es-MX'), ' AL ', FORMAT(ISNULL(@p_FechaFin, GETDATE()), 'dd \de MMMM \del yyyy', 'es-MX')) AS nvarchar(128)) AS [Titulo]
    FROM [ORCO].[Vw_OrdenCompraDetalle] AS od;
END;
GO

CREATE OR ALTER PROCEDURE [CONTA].[SPR_RepBienLentNulMovPer]
    @p_FecInicio nvarchar(24),
    @p_FecFin nvarchar(24)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @p_FechaInicio date = TRY_CONVERT(date, @p_FecInicio);
    DECLARE @p_FechaFin date = TRY_CONVERT(date, @p_FecFin);

    DECLARE @tablaFirma table (
        id int IDENTITY(1,1) NOT NULL,
        Funcion nvarchar(64) NULL,
        Nombre nvarchar(254) NULL
    );

    INSERT INTO @tablaFirma (Funcion, Nombre)
    SELECT F.[Funcion], CONCAT(P.[Nombre], ' ', P.[Paterno], ' ', P.[Materno])
    FROM [SIS].[Reporte] AS R
    INNER JOIN [SIS].[FirmaAutorizada] AS F ON R.[Pk_IdReporte] = F.[Fk_IdReporte__SIS]
    INNER JOIN [RHCT].[Persona] AS P ON F.[Fk_IdPersona__RHCT] = P.[PK_IdPersona]
    WHERE R.[Controlador] = 'RepBienLentNulMovPer'
      AND R.[Activo] = 1
      AND F.[Activo] = 1;

    DECLARE @Funcion1 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 1), '');
    DECLARE @Funcion2 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 2), '');
    DECLARE @Funcion3 nvarchar(64) = ISNULL((SELECT Funcion FROM @tablaFirma WHERE id = 3), '');
    DECLARE @Nombre1 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 1), '');
    DECLARE @Nombre2 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 2), '');
    DECLARE @Nombre3 nvarchar(254) = ISNULL((SELECT Nombre FROM @tablaFirma WHERE id = 3), '');
    DECLARE @Puesto1 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre1 + '%'), '');
    DECLARE @Puesto2 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre2 + '%'), '');
    DECLARE @Puesto3 nvarchar(254) = ISNULL((SELECT TOP 1 Puesto FROM [RHCT].[Persona] WHERE CONCAT(Nombre, ' ', Paterno, ' ', Materno) LIKE '%' + @Nombre3 + '%'), '');

    SELECT
        E.[PKIdTipoBien] AS [ID],
        E.[FKIdPartida_CONTA] AS [PP],
        E.[CodigoClave] AS [cabmsdf],
        E.[Descripcion] AS [concepto],
        E.[Unidades] AS [um],
        E.[Existencias] AS [cant],
        E.[CostoPromedio] AS [costprom],
        E.[Existencias] * E.[CostoPromedio] AS [total],
        CAST(NULL AS nvarchar(50)) AS [B],
        CAST(NULL AS nvarchar(50)) AS [R],
        CAST(NULL AS nvarchar(50)) AS [BN],
        CAST('Almacen' AS nvarchar(100)) AS [UBBien],
        CAST(NULL AS nvarchar(254)) AS [RespBien],
        @Funcion1 AS [Funcion1],
        @Funcion2 AS [Funcion2],
        @Funcion3 AS [Funcion3],
        @Nombre1 AS [Nombre1],
        @Nombre2 AS [Nombre2],
        @Nombre3 AS [Nombre3],
        @Puesto1 AS [Puesto1],
        @Puesto2 AS [Puesto2],
        @Puesto3 AS [Puesto3],
        CAST(CONCAT('PERIODO DEL ', FORMAT(ISNULL(@p_FechaInicio, GETDATE()), 'dd \de MMMM \del yyyy', 'es-MX'), ' AL ', FORMAT(ISNULL(@p_FechaFin, GETDATE()), 'dd \de MMMM \del yyyy', 'es-MX')) AS nvarchar(128)) AS [Titulo]
    FROM [ALMA].[Vw_Existencias] AS E;
END;
GO
