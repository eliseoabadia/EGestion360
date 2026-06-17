--select * from [dbo].[SIS_Pantalla] where nombre like '%REcurso%'
--select * 
--from [dbo].[SIS_Menu] m
--inner join [dbo].[SIS_Pantalla] p on m.Fk_IdPantalla__SIS = p.Pk_IdPantalla
--where  m.Fk_IdMenu__SIS in ( 4043)


DECLARE @SoloVivos bit = 1;

WITH MenuArbol AS (
    -- Raíces del menú
    SELECT
        m.Pk_IdMenu,
        m.Fk_IdMenu__SIS AS Pk_IdMenuPadre,
        m.Fk_IdPantalla__SIS,
        p.Clave,
        p.Nombre,
        p.Controlador,
        p.Icono,
        m.Orden,
        0 AS Nivel,
        CAST('/' + CAST(m.Pk_IdMenu AS varchar(20)) + '/' AS varchar(max)) AS RutaIds,
        CAST(ISNULL(p.Nombre, '') AS nvarchar(max)) AS RutaNombres,
        CAST(
            RIGHT('000000' + CAST(m.Orden AS varchar(6)), 6)
            + '-' +
            RIGHT('000000' + CAST(m.Pk_IdMenu AS varchar(6)), 6)
            AS varchar(max)
        ) AS RutaOrden
    FROM dbo.SIS_Menu m
    INNER JOIN dbo.SIS_Pantalla p
        ON p.Pk_IdPantalla = m.Fk_IdPantalla__SIS
    WHERE m.Fk_IdMenu__SIS IS NULL
      AND (@SoloVivos = 0 OR m.CT_LIVE = 1)
      AND (@SoloVivos = 0 OR p.CT_LIVE = 1)
      --AND Pk_IdMenu not in (1,10,3,2,4,5,6,4107,161,9,2005,2042,8,2070,4029)

    UNION ALL

    -- Hijos
    SELECT
        h.Pk_IdMenu,
        h.Fk_IdMenu__SIS AS Pk_IdMenuPadre,
        h.Fk_IdPantalla__SIS,
        p.Clave,
        p.Nombre,
        p.Controlador,
        p.Icono,
        h.Orden,
        a.Nivel + 1 AS Nivel,
        CAST(a.RutaIds + CAST(h.Pk_IdMenu AS varchar(20)) + '/' AS varchar(max)) AS RutaIds,
        CAST(a.RutaNombres + N' > ' + ISNULL(p.Nombre, '') AS nvarchar(max)) AS RutaNombres,
        CAST(
            a.RutaOrden
            + '/'
            + RIGHT('000000' + CAST(h.Orden AS varchar(6)), 6)
            + '-' +
            RIGHT('000000' + CAST(h.Pk_IdMenu AS varchar(6)), 6)
            AS varchar(max)
        ) AS RutaOrden
    FROM dbo.SIS_Menu h
    INNER JOIN dbo.SIS_Pantalla p
        ON p.Pk_IdPantalla = h.Fk_IdPantalla__SIS
    INNER JOIN MenuArbol a
        ON a.Pk_IdMenu = h.Fk_IdMenu__SIS
    WHERE (@SoloVivos = 0 OR h.CT_LIVE = 1)
      AND (@SoloVivos = 0 OR p.CT_LIVE = 1)
      -- Evita ciclos accidentales
      AND CHARINDEX('/' + CAST(h.Pk_IdMenu AS varchar(20)) + '/', a.RutaIds) = 0
)
SELECT
    Nivel,
    REPLICATE('    ', Nivel) + ISNULL(Nombre, '') AS Arbol,
    Pk_IdMenu,
    Pk_IdMenuPadre,
    Fk_IdPantalla__SIS AS Pk_IdPantalla,
    LTRIM(RTRIM(Clave)) AS Clave,
    Nombre,
    Controlador,
    Icono,
    Orden,
    RutaIds,
    RutaNombres
FROM MenuArbol

ORDER BY RutaOrden
OPTION (MAXRECURSION 32767);