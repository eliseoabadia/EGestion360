update  sis.Menu set Ruta = replace(Ruta,'/~/','/')
select * from sis.Menu
select * from sis.MenuRole
select * from dbo.AspNetClaims
select * from dbo.AspNetClaimValues

truncate table  dbo.aspnetclaimvalues
delete  dbo.AspNetClaims

delete  dbo.AspNetClaims
truncate table  sis.MenuRole
delete   sis.Menu

DECLARE @maxId INT;
SELECT @maxId = ISNULL(MAX(Id), 0) FROM dbo.AspNetClaims;
DBCC CHECKIDENT ('dbo.AspNetClaims', RESEED, @maxId);

DECLARE @maxId2 INT;
SELECT @maxId2 = ISNULL(MAX(PKIdMenu), 0) FROM sis.Menu;
DBCC CHECKIDENT ('sis.Menu', RESEED, @maxId2);


UPDATE SIS.Menu
SET ImageUrl = 'MudBlazorIcons.Filled.FolderSpecial'
WHERE PKIdMenu IN (
    SELECT DISTINCT FKIdMenu_SIS FROM SIS.Menu WHERE FKIdMenu_SIS IS NOT NULL
);



-- Ejemplo para algunos nodos finales (ajusta según tus necesidades)
-- Catálogos de Configuración
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.Settings' WHERE PKIdMenu = 1;
-- Presupuesto
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.AttachMoney' WHERE PKIdMenu = 2;
-- Contabilidad
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.AccountBalance' WHERE PKIdMenu = 3 OR PKIdMenu = 33;
-- Adquisiciones
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.ShoppingCart' WHERE PKIdMenu = 4 OR PKIdMenu = 41;
-- Patrimonio
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.HomeWork' WHERE PKIdMenu = 5 OR PKIdMenu = 50;
-- Almacén
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.Warehouse' WHERE PKIdMenu = 6 OR PKIdMenu = 62 OR PKIdMenu = 63;
-- Reportes CxC
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.Assessment' WHERE PKIdMenu = 7;
-- Usuarios
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.People' WHERE PKIdMenu = 8 OR PKIdMenu = 1211;
-- Ayuda
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.HelpOutline' WHERE PKIdMenu = 9 OR PKIdMenu = 162 OR PKIdMenu = 163 OR PKIdMenu = 164 OR PKIdMenu = 165;
-- Manual de Usuario
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.MenuBook' WHERE PKIdMenu = 162;
-- Reportes
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.BarChart' WHERE Nombre LIKE N'%Reporte%' OR Nombre LIKE N'%Reportes%';

-- Bancos y dinero
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.AccountBalanceWallet' WHERE Nombre LIKE N'%Banco%' OR Nombre LIKE N'%Cuenta Bancaria%';

-- Contratos
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.Description' WHERE Nombre LIKE N'%Contrato%';

-- Proveedores
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.LocalShipping' WHERE Nombre LIKE N'%Proveedor%';

-- Inventarios
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.Inventory' WHERE Nombre LIKE N'%Inventario%' OR Nombre LIKE N'%Inventarios%';

-- Si no se asignó ningún ícono específico, dejar el genérico de descripción
UPDATE SIS.Menu
SET ImageUrl = 'MudBlazorIcons.Filled.Description'
WHERE ImageUrl IS NULL OR ImageUrl = '';


--otro

-- Presupuesto, Egresos, Ingresos
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.AttachMoney'
WHERE Nombre LIKE N'%Presupuesto%' OR Nombre LIKE N'%Egresos%' OR Nombre LIKE N'%Ingresos%' OR Nombre LIKE N'%Modificado%';

-- Contabilidad, Pólizas, Balanza
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.AccountBalance'
WHERE Nombre LIKE N'%Contabilidad%' OR Nombre LIKE N'%Póliza%' OR Nombre LIKE N'%Balanza%' OR Nombre LIKE N'%Auxiliar%' OR Nombre LIKE N'%Mayor%';

-- Adquisiciones, Compra, Requisición, Cotización
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.ShoppingCart'
WHERE Nombre LIKE N'%Adquisicion%' OR Nombre LIKE N'%Requisicion%' OR Nombre LIKE N'%Cotizacion%' OR Nombre LIKE N'%Compra%';

-- Patrimonio, Bienes, Muebles
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.HomeWork'
WHERE Nombre LIKE N'%Patrimonio%' OR Nombre LIKE N'%Bien%' OR Nombre LIKE N'%Mueble%' OR Nombre LIKE N'%Activo%';

-- Almacén, Inventario, Almacenes, Existencia
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.Warehouse'
WHERE Nombre LIKE N'%Almacen%' OR Nombre LIKE N'%Inventario%' OR Nombre LIKE N'%Existencia%' OR Nombre LIKE N'%Pedido%' OR Nombre LIKE N'%Salida%';

-- Reportes, Análisis
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.BarChart'
WHERE Nombre LIKE N'%Reporte%' OR Nombre LIKE N'%Analisis%' OR Nombre LIKE N'%Análisis%' OR Nombre LIKE N'%Estado%' OR Nombre LIKE N'%Informe%';

-- Usuarios, Personas, Empleados
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.People'
WHERE Nombre LIKE N'%Usuario%' OR Nombre LIKE N'%Persona%' OR Nombre LIKE N'%Empleado%' OR Nombre LIKE N'%Personal%';

-- Nómina
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.PaidOutlined'
WHERE Nombre LIKE N'%Nomina%' OR Nombre LIKE N'%Calculo%' OR Nombre LIKE N'%Pago%';

-- Tesorería, Bancos, Cheques
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.LocalAtm'
WHERE Nombre LIKE N'%Tesoreria%' OR Nombre LIKE N'%Banco%' OR Nombre LIKE N'%Cheque%' OR Nombre LIKE N'%Cambio%' OR Nombre LIKE N'%Inversion%';

-- Firma, Autorización, Aprobación
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.CheckCircle'
WHERE Nombre LIKE N'%Firma%' OR Nombre LIKE N'%Autorizacion%' OR Nombre LIKE N'%Autoriza%' OR Nombre LIKE N'%Aprobacion%' OR Nombre LIKE N'%Aprueba%';

-- Proveedores, Tratados
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.LocalShipping'
WHERE Nombre LIKE N'%Proveedor%' OR Nombre LIKE N'%Tratado%';

-- Recursos Humanos, Movimientos, Plazas
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.Engineering'
WHERE Nombre LIKE N'%Recursos Humanos%' OR Nombre LIKE N'%Movimiento%' OR Nombre LIKE N'%Plaza%' OR Nombre LIKE N'%Puesto%' OR Nombre LIKE N'%Nombramiento%';

-- Catálogos, Configuración, Generales, Parámetros
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.Settings'
WHERE Nombre LIKE N'%Catalogo%' OR Nombre LIKE N'%Configuracion%' OR Nombre LIKE N'%General%' OR Nombre LIKE N'%Parametrizacion%' OR Nombre LIKE N'%Parametro%' OR Nombre LIKE N'%Tipo%';

-- Conteo, Inventarios Cíclico, Anual
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.Assignment'
WHERE Nombre LIKE N'%Conteo%' OR Nombre LIKE N'%Ciclico%' OR Nombre LIKE N'%Anual%' OR Nombre LIKE N'%Diferencia%';

-- Fideicomiso
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.BusinessCenter'
WHERE Nombre LIKE N'%Fideicomiso%';

-- Ayuda, Manual, Soporte
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.HelpOutline'
WHERE Nombre LIKE N'%Ayuda%' OR Nombre LIKE N'%Manual%' OR Nombre LIKE N'%Soporte%' OR Nombre LIKE N'%Pregunta%' OR Nombre LIKE N'%Frecuente%' OR Nombre LIKE N'%Acerca%';

-- Planeación, Indicadores, Estrategia
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.Map'
WHERE Nombre LIKE N'%Planeacion%' OR Nombre LIKE N'%Indicador%' OR Nombre LIKE N'%Resumen%' OR Nombre LIKE N'%Narrativo%';

-- Suscripción, Certificados, Documentos
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.CardMembership'
WHERE Nombre LIKE N'%Suscripcion%' OR Nombre LIKE N'%Certificado%' OR Nombre LIKE N'%Documento%';

-- Roles, Privilegios, Seguridad
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.Security'
WHERE Nombre LIKE N'%Rol%' OR Nombre LIKE N'%Privilegio%' OR Nombre LIKE N'%Seguridad%';

-- Investigación de Mercado
UPDATE SIS.Menu SET ImageUrl = 'MudBlazorIcons.Filled.SearchOutlined'
WHERE Nombre LIKE N'%Investigacion%' OR Nombre LIKE N'%Mercado%';

-- Asignar ícono genérico de descripción a todos los que no tengan asignado aún
UPDATE SIS.Menu
SET ImageUrl = 'MudBlazorIcons.Filled.Description'
WHERE ImageUrl IS NULL OR ImageUrl = '';


-- Permitir inserción explícita en columna IDENTITY
SET IDENTITY_INSERT SIS.Menu ON;

-- Insertar los menús raíz
INSERT INTO SIS.Menu (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Lenguaje, Orden, Activo, CreatedByOperatorId, CreatedDateTime)
SELECT 
    m.Pk_IdMenu, p.Nombre, 1, NULL, NULL, 
    CASE 
        WHEN p.Controlador IS NULL OR p.Controlador = '-' OR p.Controlador = '' THEN '/'
        WHEN p.Controlador LIKE '~/%~' THEN SUBSTRING(p.Controlador, CHARINDEX('/', p.Controlador, 2), LEN(p.Controlador))
        ELSE '/' + ISNULL(p.Controlador, '')
    END,
    NULL, 'E', m.Orden, 1, 1, GETDATE()
FROM BD_PRESUPUESTO.SIS.Menu m
INNER JOIN BD_PRESUPUESTO.SIS.Pantalla p ON m.Fk_IdPantalla__SIS = p.Pk_IdPantalla
WHERE m.Fk_IdMenu__SIS IS NULL AND m.CT_LIVE = 1;

-- Insertar los menús hijos recursivamente
;WITH MenuJerarquia AS (
    SELECT 
        m.Pk_IdMenu,
        m.Fk_IdMenu__SIS AS ParentId,
        p.Nombre,
        m.Orden,
        p.Controlador,
        1 AS Nivel
    FROM BD_PRESUPUESTO.SIS.Menu m
    INNER JOIN BD_PRESUPUESTO.SIS.Pantalla p ON m.Fk_IdPantalla__SIS = p.Pk_IdPantalla
    WHERE m.Fk_IdMenu__SIS IS NULL AND m.CT_LIVE = 1

    UNION ALL

    SELECT 
        m.Pk_IdMenu,
        m.Fk_IdMenu__SIS,
        p.Nombre,
        m.Orden,
        p.Controlador,
        h.Nivel + 1
    FROM BD_PRESUPUESTO.SIS.Menu m
    INNER JOIN BD_PRESUPUESTO.SIS.Pantalla p ON m.Fk_IdPantalla__SIS = p.Pk_IdPantalla
    INNER JOIN MenuJerarquia h ON m.Fk_IdMenu__SIS = h.Pk_IdMenu
    WHERE m.CT_LIVE = 1
)
INSERT INTO SIS.Menu (PKIdMenu, Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta, ImageUrl, Lenguaje, Orden, Activo, CreatedByOperatorId, CreatedDateTime)
SELECT 
    mj.Pk_IdMenu, mj.Nombre, 1, mj.ParentId, NULL,
    CASE 
        WHEN mj.Controlador IS NULL OR mj.Controlador = '-' OR mj.Controlador = '' THEN '/'
        WHEN mj.Controlador LIKE '~/%~' THEN SUBSTRING(mj.Controlador, CHARINDEX('/', mj.Controlador, 2), LEN(mj.Controlador))
        ELSE '/' + ISNULL(mj.Controlador, '')
    END,
    NULL, 'E', mj.Orden, 1, 1, GETDATE()
FROM MenuJerarquia mj
WHERE mj.Nivel > 1
    AND NOT EXISTS (SELECT 1 FROM SIS.Menu sm WHERE sm.PKIdMenu = mj.Pk_IdMenu);

-- Desactivar inserción explícita en columna IDENTITY
SET IDENTITY_INSERT SIS.Menu OFF;





---------------------------------------------------------------------------------------------------

WITH MenuRecursivo AS (
    -- Nivel base: todos los menús activos
    SELECT 
        PKIdMenu,
        FKIdMenu_SIS,
        0 AS Nivel
    FROM SIS.Menu
    WHERE Activo = 1

    UNION ALL

    -- Parte recursiva: busca hijos
    SELECT 
        m.PKIdMenu,
        m.FKIdMenu_SIS,
        r.Nivel + 1
    FROM SIS.Menu m
    INNER JOIN MenuRecursivo r ON m.FKIdMenu_SIS = r.PKIdMenu
),
MenusPadre AS (
    -- Menús que tienen al menos un hijo (existe en la columna FKIdMenu_SIS de otro menú)
    SELECT DISTINCT FKIdMenu_SIS AS PKIdMenu
    FROM SIS.Menu
    WHERE FKIdMenu_SIS IS NOT NULL
)
--DELETE cv
--update C set [Values] = 'view,view-menu'
select *
FROM --dbo.AspNetClaimValues cv
--INNER JOIN 
dbo.AspNetClaims c --ON cv.ClaimId = c.Id
INNER JOIN dbo.AspNetRoles r ON c.RoleId = r.Id
INNER JOIN SIS.MenuRole mr ON mr.RoleId = r.Id
INNER JOIN MenusPadre mp ON mr.FKIdMenu_SIS = mp.PKIdMenu
WHERE cv.Value IN ('delete', 'new', 'update', 'CanExportToExcel');


----------------------------------------------------------------------------------------------------

    SELECT *--ANC.[Group], ANC.SubGroup, ANC.[Values],M.*
    --update ANC set [Values] = 'view,view-menu'
    FROM SIS.Usuario AS U (NOLOCK)
    INNER JOIN dbo.AspNetUsers AS ANU (NOLOCK) ON U.PkIdUsuario = ANU.PkIdUsuario
    INNER JOIN dbo.AspNetUserRoles AS ANUR (NOLOCK) ON ANUR.UserId = ANU.Id
    INNER JOIN dbo.AspNetClaims AS ANC (NOLOCK) ON ANC.RoleId = ANUR.RoleId
    INNER JOIN dbo.AspNetRoles AS R (NOLOCK) ON R.Id = ANUR.RoleId
    --INNER JOIN SIS.MenuRole AS MR (NOLOCK) ON MR.RoleId = R.Id
    INNER JOIN SIS.Menu AS M (NOLOCK) ON M.Nombre = ANC.Description
    WHERE M.Tipo = 1
    --U.PkIdUsuario = @PkIdUser 
      AND U.Activo = 1
      AND M.Activo = 1   -- Menú activo
    GROUP BY ANC.[Group], ANC.SubGroup, ANC.[Values]
END
GO

select * from SIS.Menu where nombre like N'%Menu%' or nombre like N'%Pantalla%'
select * from SIS.Menu where PKIdMenu = 1 or FKIdMenu_SIS = 1
select * from SIS.MenuRole

select * from dbo.AspNetClaims AS ANC (NOLOCK) 
    INNER JOIN dbo.AspNetRoles AS R (NOLOCK) ON R.Id = ANC.RoleId


    select * 
    FROM SIS.Usuario AS U (NOLOCK)
    INNER JOIN dbo.AspNetUsers AS ANU (NOLOCK) ON U.PkIdUsuario = ANU.PkIdUsuario
    INNER JOIN dbo.AspNetUserRoles AS ANUR (NOLOCK) ON ANUR.UserId = ANU.Id
    INNER JOIN dbo.AspNetClaims AS ANC (NOLOCK) ON ANC.RoleId = ANUR.RoleId


    INSERT INTO dbo.AspNetClaimValues (ClaimId, [Value], Created)
SELECT 
    c.Id,
    LTRIM(RTRIM(s.[value])) AS [Value],
    GETDATE()
FROM dbo.AspNetClaims c
CROSS APPLY STRING_SPLIT(c.[Values], ',') s
WHERE 
    c.[Values] IS NOT NULL
    AND LTRIM(RTRIM(s.[value])) != ''
    AND NOT EXISTS (
        SELECT 1 
        FROM dbo.AspNetClaimValues cv
        WHERE cv.ClaimId = c.Id 
          AND cv.[Value] = LTRIM(RTRIM(s.[value]))
    );

---------------------------------------------------------------------------------------------------
use [BD_PRESUPUESTO]


DECLARE @sql NVARCHAR(MAX) = '';

WITH MenuJerarquia AS (
    SELECT 
        m.Pk_IdMenu,
        m.Fk_IdMenu__SIS AS ParentId,
        m.Orden,
        m.CT_LIVE,
        p.Nombre AS PantallaNombre,
        p.Controlador,
        p.Clave,
        1 AS Nivel
    FROM SIS.Menu m
    INNER JOIN SIS.Pantalla p ON m.Fk_IdPantalla__SIS = p.Pk_IdPantalla
    WHERE m.Fk_IdMenu__SIS IS NULL AND m.CT_LIVE = 1
    
    UNION ALL
    
    SELECT 
        m.Pk_IdMenu,
        m.Fk_IdMenu__SIS,
        m.Orden,
        m.CT_LIVE,
        p.Nombre,
        p.Controlador,
        p.Clave,
        h.Nivel + 1
    FROM SIS.Menu m
    INNER JOIN SIS.Pantalla p ON m.Fk_IdPantalla__SIS = p.Pk_IdPantalla
    INNER JOIN MenuJerarquia h ON m.Fk_IdMenu__SIS = h.Pk_IdMenu
    WHERE m.CT_LIVE = 1
),
OrdenMenu AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY Nivel, Orden, Pk_IdMenu) AS OrdenGlobal,
        (SELECT Nombre 
         FROM SIS.Pantalla 
         WHERE Pk_IdPantalla = (SELECT Fk_IdPantalla__SIS FROM SIS.Menu WHERE Pk_IdMenu = ParentId)) AS NombrePadre
    FROM MenuJerarquia
)
SELECT 
    'EXEC sp_RegistrarEntidad ' +
    '@Grupo = ''' + LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PantallaNombre, ' ', '-'), 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o')) + ''', ' +
    '@SubGrupo = ''' + LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PantallaNombre, ' ', '-'), 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o')) + ''', ' +
    '@NombreMenu = N''' + REPLACE(PantallaNombre, '''', '''''') + ''', ' +
    '@Ruta = ''' + CASE 
                        WHEN Controlador IS NULL OR Controlador = '-' OR Controlador = '' THEN '/'
                        WHEN Controlador LIKE '~/%~' THEN SUBSTRING(Controlador, CHARINDEX('/', Controlador, 2), LEN(Controlador))
                        ELSE '/' + ISNULL(Controlador, '')
                    END + ''', ' +
    '@MenuPadreNombre = ' + 
        CASE WHEN NombrePadre IS NOT NULL THEN 'N''' + REPLACE(NombrePadre, '''', '''''') + '''' ELSE 'NULL' END + ', ' +
    '@Icono = ''FaRegSun'', ' +
    '@Orden = ' + CAST(Orden AS VARCHAR) + ', ' +
    '@Descripcion = N''' + REPLACE(PantallaNombre, '''', '''''') + ''', ' +
    '@Codigo = ''' + ISNULL(Clave, 'M' + CAST(Pk_IdMenu AS VARCHAR)) + '''' +
    ';' + CHAR(13) + CHAR(10)
FROM OrdenMenu
ORDER BY OrdenGlobal;

SELECT @sql AS [GeneratedScript];



EXEC sp_RegistrarEntidad @Grupo = 'catalogos-de-configuracion', @SubGrupo = 'catalogos-de-configuracion', @NombreMenu = N'Catálogos de Configuración', @Ruta = '/', @MenuPadreNombre = NULL, @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Catálogos de Configuración', @Codigo = 'M001';  
EXEC sp_RegistrarEntidad @Grupo = 'recursos-humanos', @SubGrupo = 'recursos-humanos', @NombreMenu = N'Recursos Humanos', @Ruta = '/', @MenuPadreNombre = NULL, @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Recursos Humanos', @Codigo = 'M201';  
EXEC sp_RegistrarEntidad @Grupo = 'nomina', @SubGrupo = 'nomina', @NombreMenu = N'Nomina', @Ruta = '/', @MenuPadreNombre = NULL, @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Nomina', @Codigo = 'M214';  
EXEC sp_RegistrarEntidad @Grupo = 'presupuesto', @SubGrupo = 'presupuesto', @NombreMenu = N'Presupuesto', @Ruta = '/', @MenuPadreNombre = NULL, @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Presupuesto', @Codigo = 'M002';  
EXEC sp_RegistrarEntidad @Grupo = 'contabilidad', @SubGrupo = 'contabilidad', @NombreMenu = N'Contabilidad', @Ruta = '/', @MenuPadreNombre = NULL, @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Contabilidad', @Codigo = 'M003';  
EXEC sp_RegistrarEntidad @Grupo = 'adquisiciones', @SubGrupo = 'adquisiciones', @NombreMenu = N'Adquisiciones', @Ruta = '/', @MenuPadreNombre = NULL, @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Adquisiciones', @Codigo = 'M004';  
EXEC sp_RegistrarEntidad @Grupo = 'patrimonio', @SubGrupo = 'patrimonio', @NombreMenu = N'Patrimonio', @Ruta = '/', @MenuPadreNombre = NULL, @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Patrimonio', @Codigo = 'M005';  
EXEC sp_RegistrarEntidad @Grupo = 'almacen', @SubGrupo = 'almacen', @NombreMenu = N'Almacén', @Ruta = '/', @MenuPadreNombre = NULL, @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Almacén', @Codigo = 'M006';  
EXEC sp_RegistrarEntidad @Grupo = 'usuarios', @SubGrupo = 'usuarios', @NombreMenu = N'Usuarios', @Ruta = '/', @MenuPadreNombre = NULL, @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Usuarios', @Codigo = 'M008';  
EXEC sp_RegistrarEntidad @Grupo = 'ayuda', @SubGrupo = 'ayuda', @NombreMenu = N'Ayuda', @Ruta = '/', @MenuPadreNombre = NULL, @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Ayuda', @Codigo = 'M009';  
EXEC sp_RegistrarEntidad @Grupo = 'firmas', @SubGrupo = 'firmas', @NombreMenu = N'Firmas', @Ruta = '/', @MenuPadreNombre = NULL, @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Firmas', @Codigo = 'M100';  
EXEC sp_RegistrarEntidad @Grupo = 'catalogos-presupuestales', @SubGrupo = 'catalogos-presupuestales', @NombreMenu = N'Catálogos presupuestales', @Ruta = '/', @MenuPadreNombre = N'Catálogos de Configuración', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Catálogos presupuestales', @Codigo = 'M010';  
EXEC sp_RegistrarEntidad @Grupo = 'submodulo-de-egresos', @SubGrupo = 'submodulo-de-egresos', @NombreMenu = N'Submódulo de Egresos', @Ruta = '/', @MenuPadreNombre = N'Presupuesto', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Submódulo de Egresos', @Codigo = 'M015';  
EXEC sp_RegistrarEntidad @Grupo = 'polizas', @SubGrupo = 'polizas', @NombreMenu = N'Pólizas', @Ruta = '/CONTAVW_Poliza', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Pólizas', @Codigo = '1075';  
EXEC sp_RegistrarEntidad @Grupo = 'programa-anual-de-adquisiciones', @SubGrupo = 'programa-anual-de-adquisiciones', @NombreMenu = N'Programa Anual de Adquisiciones', @Ruta = '/ADQPAAAS', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Programa Anual de Adquisiciones', @Codigo = '1084';  
EXEC sp_RegistrarEntidad @Grupo = 'bienes', @SubGrupo = 'bienes', @NombreMenu = N'Bienes', @Ruta = '/SICOPBien', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Bienes', @Codigo = '1096';  
EXEC sp_RegistrarEntidad @Grupo = 'recepcion-de-pedidos', @SubGrupo = 'recepcion-de-pedidos', @NombreMenu = N'Recepción de Pedidos', @Ruta = '/ORCOVW_OrdenCompra', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Recepción de Pedidos', @Codigo = '1102';  
EXEC sp_RegistrarEntidad @Grupo = 'manual-de-usuario', @SubGrupo = 'manual-de-usuario', @NombreMenu = N'Manual de Usuario', @Ruta = '/#', @MenuPadreNombre = N'Ayuda', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Manual de Usuario', @Codigo = '1133';  
EXEC sp_RegistrarEntidad @Grupo = 'catalogos', @SubGrupo = 'catalogos', @NombreMenu = N'Catálogos', @Ruta = '/', @MenuPadreNombre = N'Recursos Humanos', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Catálogos', @Codigo = 'M202';  
EXEC sp_RegistrarEntidad @Grupo = 'catalogos', @SubGrupo = 'catalogos', @NombreMenu = N'Catalogos', @Ruta = '/', @MenuPadreNombre = N'Nomina', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Catalogos', @Codigo = 'M215';  
EXEC sp_RegistrarEntidad @Grupo = 'adquisiciones', @SubGrupo = 'adquisiciones', @NombreMenu = N'Adquisiciones', @Ruta = '/', @MenuPadreNombre = N'Catálogos de Configuración', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Adquisiciones', @Codigo = 'M011';  
EXEC sp_RegistrarEntidad @Grupo = 'investigacion-de-mercado', @SubGrupo = 'investigacion-de-mercado', @NombreMenu = N'Investigación de Mercado', @Ruta = '/ORCOEstudioMercado', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Investigación de Mercado', @Codigo = '1085';  
EXEC sp_RegistrarEntidad @Grupo = 'entradas-por-ajuste', @SubGrupo = 'entradas-por-ajuste', @NombreMenu = N'Entradas por Ajuste', @Ruta = '/ALMAAlmacen', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Entradas por Ajuste', @Codigo = '1103';  
EXEC sp_RegistrarEntidad @Grupo = 'preguntas-frecuentes', @SubGrupo = 'preguntas-frecuentes', @NombreMenu = N'Preguntas Frecuentes', @Ruta = '/#', @MenuPadreNombre = N'Ayuda', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Preguntas Frecuentes', @Codigo = '1134';  
EXEC sp_RegistrarEntidad @Grupo = 'movimientos-de-plazas', @SubGrupo = 'movimientos-de-plazas', @NombreMenu = N'Movimientos de Plazas', @Ruta = '/', @MenuPadreNombre = N'Recursos Humanos', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Movimientos de Plazas', @Codigo = 'M208';  
EXEC sp_RegistrarEntidad @Grupo = 'calculo', @SubGrupo = 'calculo', @NombreMenu = N'Calculo', @Ruta = '/', @MenuPadreNombre = N'Nomina', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Calculo', @Codigo = 'M222';  
EXEC sp_RegistrarEntidad @Grupo = 'clasificacion-de-bienes-muebles', @SubGrupo = 'clasificacion-de-bienes-muebles', @NombreMenu = N'Clasificación de bienes Muebles', @Ruta = '/ORCOVW_OrdenCompraClasificacionBienes', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Clasificación de bienes Muebles', @Codigo = '2152';  
EXEC sp_RegistrarEntidad @Grupo = 'submodulo-fideicomiso', @SubGrupo = 'submodulo-fideicomiso', @NombreMenu = N'Submódulo Fideicomiso', @Ruta = '/', @MenuPadreNombre = N'Presupuesto', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Submódulo Fideicomiso', @Codigo = 'M032';  
EXEC sp_RegistrarEntidad @Grupo = 'privilegios-por-rol', @SubGrupo = 'privilegios-por-rol', @NombreMenu = N'Privilegios por Rol', @Ruta = '/SISPrivilegiosXrol', @MenuPadreNombre = N'Usuarios', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Privilegios por Rol', @Codigo = 'U001';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-de-polizas', @SubGrupo = 'autorizacion-de-polizas', @NombreMenu = N'Autorización de Pólizas', @Ruta = '/CONTAVW_PolizaAutorizado', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Autorización de Pólizas', @Codigo = '2222';  
EXEC sp_RegistrarEntidad @Grupo = 'patrimonio', @SubGrupo = 'patrimonio', @NombreMenu = N'Patrimonio', @Ruta = '/', @MenuPadreNombre = N'Catálogos de Configuración', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Patrimonio', @Codigo = 'M012';  
EXEC sp_RegistrarEntidad @Grupo = 'submodulo-tesoreria', @SubGrupo = 'submodulo-tesoreria', @NombreMenu = N'Submódulo Tesorería', @Ruta = '/', @MenuPadreNombre = N'Presupuesto', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Submódulo Tesorería', @Codigo = 'M014';  
EXEC sp_RegistrarEntidad @Grupo = 'solicitudes-de-salida', @SubGrupo = 'solicitudes-de-salida', @NombreMenu = N'Solicitudes de Salida', @Ruta = '/ALMAVW_SolicitudSalida', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Solicitudes de Salida', @Codigo = '1104';  
EXEC sp_RegistrarEntidad @Grupo = 'soporte-tecnico', @SubGrupo = 'soporte-tecnico', @NombreMenu = N'Soporte Técnico', @Ruta = '/#', @MenuPadreNombre = N'Ayuda', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Soporte Técnico', @Codigo = '1135';  
EXEC sp_RegistrarEntidad @Grupo = 'registro-y-control-de-personal', @SubGrupo = 'registro-y-control-de-personal', @NombreMenu = N'Registro y Control de Personal', @Ruta = '/', @MenuPadreNombre = N'Recursos Humanos', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Registro y Control de Personal', @Codigo = 'M210';  
EXEC sp_RegistrarEntidad @Grupo = 'reportes', @SubGrupo = 'reportes', @NombreMenu = N'Reportes', @Ruta = '/', @MenuPadreNombre = N'Nomina', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Reportes', @Codigo = 'M223';  
EXEC sp_RegistrarEntidad @Grupo = 'bienes-no-pertenecientes-al-instituto', @SubGrupo = 'bienes-no-pertenecientes-al-instituto', @NombreMenu = N'Bienes No pertenecientes al Instituto', @Ruta = '/SICOPBienNoPropio', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Bienes No pertenecientes al Instituto', @Codigo = '2157';  
EXEC sp_RegistrarEntidad @Grupo = 'roles', @SubGrupo = 'roles', @NombreMenu = N'Roles', @Ruta = '/SISRol', @MenuPadreNombre = N'Usuarios', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Roles', @Codigo = 'U002';  
EXEC sp_RegistrarEntidad @Grupo = 'almacen', @SubGrupo = 'almacen', @NombreMenu = N'Almacén', @Ruta = '/', @MenuPadreNombre = N'Catálogos de Configuración', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Almacén', @Codigo = 'M013';  
EXEC sp_RegistrarEntidad @Grupo = 'balanza-de-comprobacion', @SubGrupo = 'balanza-de-comprobacion', @NombreMenu = N'Balanza de Comprobación', @Ruta = '/ReporteBalanza', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Balanza de Comprobación', @Codigo = '1076';  
EXEC sp_RegistrarEntidad @Grupo = 'bajas', @SubGrupo = 'bajas', @NombreMenu = N'Bajas', @Ruta = '/SICOPBajas', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Bajas', @Codigo = '1097';  
EXEC sp_RegistrarEntidad @Grupo = 'suministro-/-salidas', @SubGrupo = 'suministro-/-salidas', @NombreMenu = N'Suministro / Salidas', @Ruta = '/ALMAVWSolicitudSalida', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Suministro / Salidas', @Codigo = '1105';  
EXEC sp_RegistrarEntidad @Grupo = 'pef-unipartida-adq', @SubGrupo = 'pef-unipartida-adq', @NombreMenu = N'PEF Unipartida ADQ', @Ruta = '/', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'PEF Unipartida ADQ', @Codigo = 'M230';  
EXEC sp_RegistrarEntidad @Grupo = 'acerca-de...', @SubGrupo = 'acerca-de...', @NombreMenu = N'Acerca de...', @Ruta = '/SISAcercaDe', @MenuPadreNombre = N'Ayuda', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Acerca de...', @Codigo = '1136';  
EXEC sp_RegistrarEntidad @Grupo = 'movimiento-de-personal', @SubGrupo = 'movimiento-de-personal', @NombreMenu = N'Movimiento de Personal', @Ruta = '/', @MenuPadreNombre = N'Recursos Humanos', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Movimiento de Personal', @Codigo = 'M211';  
EXEC sp_RegistrarEntidad @Grupo = 'fonac', @SubGrupo = 'fonac', @NombreMenu = N'Fonac', @Ruta = '/', @MenuPadreNombre = N'Nomina', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Fonac', @Codigo = 'M224';  
EXEC sp_RegistrarEntidad @Grupo = 'usuarios', @SubGrupo = 'usuarios', @NombreMenu = N'Usuarios', @Ruta = '/SISUsuario', @MenuPadreNombre = N'Usuarios', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Usuarios', @Codigo = 'U003';  
EXEC sp_RegistrarEntidad @Grupo = 'submodulo-de-nomina', @SubGrupo = 'submodulo-de-nomina', @NombreMenu = N'Submódulo de Nómina', @Ruta = '/', @MenuPadreNombre = N'Presupuesto', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Submódulo de Nómina', @Codigo = 'M228';  
EXEC sp_RegistrarEntidad @Grupo = 'auxiliares', @SubGrupo = 'auxiliares', @NombreMenu = N'Auxiliares', @Ruta = '/RepAuxiliares', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Auxiliares', @Codigo = '1077';  
EXEC sp_RegistrarEntidad @Grupo = 'salidas-por-ajuste', @SubGrupo = 'salidas-por-ajuste', @NombreMenu = N'Salidas por Ajuste', @Ruta = '/ALMAAlmacenSalida', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Salidas por Ajuste', @Codigo = '1106';  
EXEC sp_RegistrarEntidad @Grupo = 'plantilla-de-personal', @SubGrupo = 'plantilla-de-personal', @NombreMenu = N'Plantilla de Personal', @Ruta = '/', @MenuPadreNombre = N'Recursos Humanos', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Plantilla de Personal', @Codigo = 'M213';  
EXEC sp_RegistrarEntidad @Grupo = 'pension-alimenticia', @SubGrupo = 'pension-alimenticia', @NombreMenu = N'Pensión Alimenticia', @Ruta = '/', @MenuPadreNombre = N'Nomina', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Pensión Alimenticia', @Codigo = 'M225';  
EXEC sp_RegistrarEntidad @Grupo = 'persona-por-area', @SubGrupo = 'persona-por-area', @NombreMenu = N'Persona por Área', @Ruta = '/RHCTPersonaArea', @MenuPadreNombre = N'Usuarios', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Persona por Área', @Codigo = 'U004';  
EXEC sp_RegistrarEntidad @Grupo = 'calendario-de-inventarios', @SubGrupo = 'calendario-de-inventarios', @NombreMenu = N'Calendario de Inventarios', @Ruta = '/SICOPCalendario', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Calendario de Inventarios', @Codigo = 'SC01';  
EXEC sp_RegistrarEntidad @Grupo = 'tesoreria', @SubGrupo = 'tesoreria', @NombreMenu = N'Tesorería', @Ruta = '/', @MenuPadreNombre = N'Catálogos de Configuración', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Tesorería', @Codigo = 'T000';  
EXEC sp_RegistrarEntidad @Grupo = 'reportes-contabilidad', @SubGrupo = 'reportes-contabilidad', @NombreMenu = N'Reportes Contabilidad', @Ruta = '/', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Reportes Contabilidad', @Codigo = 'M016';  
EXEC sp_RegistrarEntidad @Grupo = 'inventarios', @SubGrupo = 'inventarios', @NombreMenu = N'Inventarios', @Ruta = '/SICOPInventario', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Inventarios', @Codigo = '1098';  
EXEC sp_RegistrarEntidad @Grupo = 'existencias-registradas', @SubGrupo = 'existencias-registradas', @NombreMenu = N'Existencias Registradas', @Ruta = '/ALMAVWCierreInventario', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Existencias Registradas', @Codigo = '1107';  
EXEC sp_RegistrarEntidad @Grupo = 'tabuladores', @SubGrupo = 'tabuladores', @NombreMenu = N'Tabuladores', @Ruta = '/', @MenuPadreNombre = N'Nomina', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Tabuladores', @Codigo = 'M226';  
EXEC sp_RegistrarEntidad @Grupo = 'bandeja-de-notificaciones', @SubGrupo = 'bandeja-de-notificaciones', @NombreMenu = N'Bandeja de notificaciones', @Ruta = '/SISVW_NotificacionesByUser', @MenuPadreNombre = N'Usuarios', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Bandeja de notificaciones', @Codigo = 'U005';  
EXEC sp_RegistrarEntidad @Grupo = 'bitacora', @SubGrupo = 'bitacora', @NombreMenu = N'Bitácora', @Ruta = '/SISBitacora', @MenuPadreNombre = N'Usuarios', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Bitácora', @Codigo = '2221';  
EXEC sp_RegistrarEntidad @Grupo = 'pef-multipartidas-adq', @SubGrupo = 'pef-multipartidas-adq', @NombreMenu = N'PEF Multipartidas ADQ', @Ruta = '/', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'PEF Multipartidas ADQ', @Codigo = 'M029';  
EXEC sp_RegistrarEntidad @Grupo = 'conteo-ciclico', @SubGrupo = 'conteo-ciclico', @NombreMenu = N'Conteo Cíclico', @Ruta = '/ALMAConteo', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Conteo Cíclico', @Codigo = '1108';  
EXEC sp_RegistrarEntidad @Grupo = 'historico', @SubGrupo = 'historico', @NombreMenu = N'Historico', @Ruta = '/', @MenuPadreNombre = N'Nomina', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Historico', @Codigo = 'M227';  
EXEC sp_RegistrarEntidad @Grupo = 'estados-e-informacion-contable', @SubGrupo = 'estados-e-informacion-contable', @NombreMenu = N'Estados e Información Contable', @Ruta = '/', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Estados e Información Contable', @Codigo = 'M032';  
EXEC sp_RegistrarEntidad @Grupo = 'cedula-diferencias-de-inventario', @SubGrupo = 'cedula-diferencias-de-inventario', @NombreMenu = N'Cédula diferencias de inventario', @Ruta = '/SICOPCedulaDiferencias', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Cédula diferencias de inventario', @Codigo = '2216';  
EXEC sp_RegistrarEntidad @Grupo = 'suscripcion-por-usuario', @SubGrupo = 'suscripcion-por-usuario', @NombreMenu = N'Suscripción por Usuario', @Ruta = '/SISSuscripcionPorUsuario', @MenuPadreNombre = N'Usuarios', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Suscripción por Usuario', @Codigo = '2230';  
EXEC sp_RegistrarEntidad @Grupo = 'resguardos', @SubGrupo = 'resguardos', @NombreMenu = N'Resguardos', @Ruta = '/SICOPResguardo', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Resguardos', @Codigo = '1099';  
EXEC sp_RegistrarEntidad @Grupo = 'conciliacion-ingresos-egresos', @SubGrupo = 'conciliacion-ingresos-egresos', @NombreMenu = N'Conciliación Ingresos-Egresos', @Ruta = '/RepIngEgre', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Conciliación Ingresos-Egresos', @Codigo = '1131';  
EXEC sp_RegistrarEntidad @Grupo = 'reporte-de-diferencias-de-conteo-ciclico', @SubGrupo = 'reporte-de-diferencias-de-conteo-ciclico', @NombreMenu = N'Reporte de Diferencias de Conteo Cíclico', @Ruta = '/ALMAVW_ReporteDiferenciasConteo', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Reporte de Diferencias de Conteo Cíclico', @Codigo = '2151';  
EXEC sp_RegistrarEntidad @Grupo = 'fideicomiso', @SubGrupo = 'fideicomiso', @NombreMenu = N'Fideicomiso', @Ruta = '/FEDISeguimientoFirmas', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Fideicomiso', @Codigo = 'M050';  
EXEC sp_RegistrarEntidad @Grupo = 'certificado', @SubGrupo = 'certificado', @NombreMenu = N'Certificado', @Ruta = '/ConfigurarCertificado', @MenuPadreNombre = N'Usuarios', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Certificado', @Codigo = '2231';  
EXEC sp_RegistrarEntidad @Grupo = 'requisicion', @SubGrupo = 'requisicion', @NombreMenu = N'Requisición', @Ruta = '/ORCOOrdenCompra', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Requisición', @Codigo = '1094';  
EXEC sp_RegistrarEntidad @Grupo = 'firma-de-resguardos', @SubGrupo = 'firma-de-resguardos', @NombreMenu = N'Firma de Resguardos', @Ruta = '/SICOPResguardoFirma', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Firma de Resguardos', @Codigo = '1100';  
EXEC sp_RegistrarEntidad @Grupo = 'estados-e-informes-presupuestarios', @SubGrupo = 'estados-e-informes-presupuestarios', @NombreMenu = N'Estados e Informes Presupuestarios', @Ruta = '/', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Estados e Informes Presupuestarios', @Codigo = 'M020';  
EXEC sp_RegistrarEntidad @Grupo = 'historico-conteo-ciclico', @SubGrupo = 'historico-conteo-ciclico', @NombreMenu = N'Histórico Conteo Cíclico', @Ruta = '/ALMAVW_ReporteDiferenciasConteo', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Histórico Conteo Cíclico', @Codigo = '2186';  
EXEC sp_RegistrarEntidad @Grupo = 'historicos-de-patrimonio', @SubGrupo = 'historicos-de-patrimonio', @NombreMenu = N'Historicos de Patrimonio', @Ruta = '/', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Historicos de Patrimonio', @Codigo = 'M017';  
EXEC sp_RegistrarEntidad @Grupo = 'estados-e-informes-programaticos', @SubGrupo = 'estados-e-informes-programaticos', @NombreMenu = N'Estados e Informes Programaticos', @Ruta = '/', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Estados e Informes Programaticos', @Codigo = 'M019';  
EXEC sp_RegistrarEntidad @Grupo = 'conteo-anual', @SubGrupo = 'conteo-anual', @NombreMenu = N'Conteo Anual', @Ruta = '/ALMAConteoAnual', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Conteo Anual', @Codigo = '2154';  
EXEC sp_RegistrarEntidad @Grupo = 'reporte-de-diferencias-de-conteo-anual', @SubGrupo = 'reporte-de-diferencias-de-conteo-anual', @NombreMenu = N'Reporte de Diferencias de Conteo Anual', @Ruta = '/ALMAVW_ReporteDiferenciasConteoAnual', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Reporte de Diferencias de Conteo Anual', @Codigo = '2155';  
EXEC sp_RegistrarEntidad @Grupo = 'requisicion-fideicomiso', @SubGrupo = 'requisicion-fideicomiso', @NombreMenu = N'Requisición Fideicomiso', @Ruta = '/ORCOOrdenCompra', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Requisición Fideicomiso', @Codigo = '2184';  
EXEC sp_RegistrarEntidad @Grupo = 'indicadores-de-postura-fiscal', @SubGrupo = 'indicadores-de-postura-fiscal', @NombreMenu = N'Indicadores de Postura Fiscal', @Ruta = '/RepIndicadoresPF', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Indicadores de Postura Fiscal', @Codigo = '2188';  
EXEC sp_RegistrarEntidad @Grupo = 'historico-conteo-anual', @SubGrupo = 'historico-conteo-anual', @NombreMenu = N'Histórico Conteo Anual', @Ruta = '/ALMAVW_ReporteDiferenciasConteoAnual', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 12, @Descripcion = N'Histórico Conteo Anual', @Codigo = '2187';  
EXEC sp_RegistrarEntidad @Grupo = 'cierre-mensual', @SubGrupo = 'cierre-mensual', @NombreMenu = N'Cierre Mensual', @Ruta = '/CONTACierreMensual', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 12, @Descripcion = N'Cierre Mensual', @Codigo = '2189';  
EXEC sp_RegistrarEntidad @Grupo = 'contratos', @SubGrupo = 'contratos', @NombreMenu = N'Contratos', @Ruta = '/', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 12, @Descripcion = N'Contratos', @Codigo = '-   ';  
EXEC sp_RegistrarEntidad @Grupo = 'estadisticas', @SubGrupo = 'estadisticas', @NombreMenu = N'Estadísticas', @Ruta = '/', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 13, @Descripcion = N'Estadísticas', @Codigo = 'M018';  
EXEC sp_RegistrarEntidad @Grupo = 'investigacion-de-mercado-personalizada', @SubGrupo = 'investigacion-de-mercado-personalizada', @NombreMenu = N'Investigación de Mercado Personalizada', @Ruta = '/ORCOSolEstudioMercado', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 13, @Descripcion = N'Investigación de Mercado Personalizada', @Codigo = '1146';  
EXEC sp_RegistrarEntidad @Grupo = 'investigacion-de-mercado-(proveedores)', @SubGrupo = 'investigacion-de-mercado-(proveedores)', @NombreMenu = N'Investigación de Mercado (Proveedores)', @Ruta = '/ADQSolEstMercProv', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 14, @Descripcion = N'Investigación de Mercado (Proveedores)', @Codigo = '1147';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-de-solicitudes-de-salida', @SubGrupo = 'autorizacion-de-solicitudes-de-salida', @NombreMenu = N'Autorización de Solicitudes de Salida', @Ruta = '/ALMAVW_AutorizacionSolicitudSalida', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 14, @Descripcion = N'Autorización de Solicitudes de Salida', @Codigo = '2156';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-firma', @SubGrupo = 'tipo-firma', @NombreMenu = N'Tipo Firma', @Ruta = '/SISTipoFirma', @MenuPadreNombre = N'Firmas', @Icono = 'FaRegSun', @Orden = 21, @Descripcion = N'Tipo Firma', @Codigo = '1155';  
EXEC sp_RegistrarEntidad @Grupo = 'reporte', @SubGrupo = 'reporte', @NombreMenu = N'Reporte', @Ruta = '/SISReporte', @MenuPadreNombre = N'Firmas', @Icono = 'FaRegSun', @Orden = 22, @Descripcion = N'Reporte', @Codigo = '1156';  
EXEC sp_RegistrarEntidad @Grupo = 'firma-autorizada', @SubGrupo = 'firma-autorizada', @NombreMenu = N'Firma autorizada', @Ruta = '/SISFirmaAutorizada', @MenuPadreNombre = N'Firmas', @Icono = 'FaRegSun', @Orden = 23, @Descripcion = N'Firma autorizada', @Codigo = '1157';  
EXEC sp_RegistrarEntidad @Grupo = 'seguimiento-a-firmas', @SubGrupo = 'seguimiento-a-firmas', @NombreMenu = N'Seguimiento a Firmas', @Ruta = '/FEDISeguimientoFirmas', @MenuPadreNombre = N'Firmas', @Icono = 'FaRegSun', @Orden = 24, @Descripcion = N'Seguimiento a Firmas', @Codigo = '2215';  
EXEC sp_RegistrarEntidad @Grupo = 'programas-presupuestales-historico', @SubGrupo = 'programas-presupuestales-historico', @NombreMenu = N'Programas Presupuestales Histórico', @Ruta = '/Programa', @MenuPadreNombre = N'Catálogos presupuestales', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Programas Presupuestales Histórico', @Codigo = '1001';  
EXEC sp_RegistrarEntidad @Grupo = 'modalidad', @SubGrupo = 'modalidad', @NombreMenu = N'Modalidad', @Ruta = '/ORCOModalidad', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Modalidad', @Codigo = '1029';  
EXEC sp_RegistrarEntidad @Grupo = 'familia', @SubGrupo = 'familia', @NombreMenu = N'Familia', @Ruta = '/SICOPFamilia', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Familia', @Codigo = '1037';  
EXEC sp_RegistrarEntidad @Grupo = 'almacenes', @SubGrupo = 'almacenes', @NombreMenu = N'Almacenes', @Ruta = '/ALMAAlmacenes', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Almacenes', @Codigo = '1048';  
EXEC sp_RegistrarEntidad @Grupo = 'cuentas-por-cobrar', @SubGrupo = 'cuentas-por-cobrar', @NombreMenu = N'Cuentas por Cobrar', @Ruta = '/', @MenuPadreNombre = N'Submódulo Tesorería', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Cuentas por Cobrar', @Codigo = 'M028';  
EXEC sp_RegistrarEntidad @Grupo = 'libro-diario', @SubGrupo = 'libro-diario', @NombreMenu = N'Libro Diario', @Ruta = '/RepLibroDiario', @MenuPadreNombre = N'Reportes Contabilidad', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Libro Diario', @Codigo = '1081';  
EXEC sp_RegistrarEntidad @Grupo = 'registro-de-contrato', @SubGrupo = 'registro-de-contrato', @NombreMenu = N'Registro de Contrato', @Ruta = '/ORCOContratos', @MenuPadreNombre = N'Contratos', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Registro de Contrato', @Codigo = '1095';  
EXEC sp_RegistrarEntidad @Grupo = 'resguardos-historicos', @SubGrupo = 'resguardos-historicos', @NombreMenu = N'Resguardos Históricos', @Ruta = '/SICOPResguardoHistorico', @MenuPadreNombre = N'Historicos de Patrimonio', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Resguardos Históricos', @Codigo = '1101';  
EXEC sp_RegistrarEntidad @Grupo = 'cierre-inventario', @SubGrupo = 'cierre-inventario', @NombreMenu = N'Cierre Inventario', @Ruta = '/ALMAVWCierreInventario', @MenuPadreNombre = N'Estadísticas', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Cierre Inventario', @Codigo = '1109';  
EXEC sp_RegistrarEntidad @Grupo = 'estados-de-actividades', @SubGrupo = 'estados-de-actividades', @NombreMenu = N'Estados de Actividades', @Ruta = '/RepEstadoActividades', @MenuPadreNombre = N'Estados e Información Contable', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Estados de Actividades', @Codigo = '1113';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-analitico-de-ingresos', @SubGrupo = 'estado-analitico-de-ingresos', @NombreMenu = N'Estado Análitico de Ingresos', @Ruta = '/RepIngreAna', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Estado Análitico de Ingresos', @Codigo = '1120';  
EXEC sp_RegistrarEntidad @Grupo = 'generales', @SubGrupo = 'generales', @NombreMenu = N'Generales', @Ruta = '/', @MenuPadreNombre = N'Catálogos', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Generales', @Codigo = 'M203';  
EXEC sp_RegistrarEntidad @Grupo = 'captura-de-movimientos-plazas', @SubGrupo = 'captura-de-movimientos-plazas', @NombreMenu = N'Captura de Movimientos Plazas', @Ruta = '/', @MenuPadreNombre = N'Movimientos de Plazas', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Captura de Movimientos Plazas', @Codigo = 'M209';  
EXEC sp_RegistrarEntidad @Grupo = 'datos-generales-y-personales', @SubGrupo = 'datos-generales-y-personales', @NombreMenu = N'Datos Generales y Personales', @Ruta = '/RH_Persona', @MenuPadreNombre = N'Registro y Control de Personal', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Datos Generales y Personales', @Codigo = '2065';  
EXEC sp_RegistrarEntidad @Grupo = 'alta-de-empleados', @SubGrupo = 'alta-de-empleados', @NombreMenu = N'Alta de Empleados', @Ruta = '/ErrConf', @MenuPadreNombre = N'Movimiento de Personal', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Alta de Empleados', @Codigo = '2067';  
EXEC sp_RegistrarEntidad @Grupo = 'plaza-de-adscripcion', @SubGrupo = 'plaza-de-adscripcion', @NombreMenu = N'Plaza de Adscripción', @Ruta = '/ErrConf', @MenuPadreNombre = N'Plantilla de Personal', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Plaza de Adscripción', @Codigo = '2070';  
EXEC sp_RegistrarEntidad @Grupo = 'generales', @SubGrupo = 'generales', @NombreMenu = N'Generales', @Ruta = '/', @MenuPadreNombre = N'Catalogos', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Generales', @Codigo = 'M216';  
EXEC sp_RegistrarEntidad @Grupo = 'incremento-general-por-nivel', @SubGrupo = 'incremento-general-por-nivel', @NombreMenu = N'Incremento General por nivel', @Ruta = '/ErrConf', @MenuPadreNombre = N'Calculo', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Incremento General por nivel', @Codigo = '2122';  
EXEC sp_RegistrarEntidad @Grupo = 'catalogo-de-aportaciones', @SubGrupo = 'catalogo-de-aportaciones', @NombreMenu = N'Catálogo de Aportaciones', @Ruta = '/NO_AportacionFONAC', @MenuPadreNombre = N'Fonac', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Catálogo de Aportaciones', @Codigo = '2134';  
EXEC sp_RegistrarEntidad @Grupo = 'pension-alimenticia', @SubGrupo = 'pension-alimenticia', @NombreMenu = N'Pensión Alimenticia', @Ruta = '/NO_PensionAlimenticia', @MenuPadreNombre = N'Pensión Alimenticia', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Pensión Alimenticia', @Codigo = '2138';  
EXEC sp_RegistrarEntidad @Grupo = 'tabulador-por-puesto', @SubGrupo = 'tabulador-por-puesto', @NombreMenu = N'Tabulador por puesto', @Ruta = '/ErrConf', @MenuPadreNombre = N'Tabuladores', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Tabulador por puesto', @Codigo = '2140';  
EXEC sp_RegistrarEntidad @Grupo = 'nomina-historica', @SubGrupo = 'nomina-historica', @NombreMenu = N'Nomina Historica', @Ruta = '/NH_SueldoVertRep', @MenuPadreNombre = N'Historico', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Nomina Historica', @Codigo = '2145';  
EXEC sp_RegistrarEntidad @Grupo = 'presupuesto-autorizado-fideicomiso', @SubGrupo = 'presupuesto-autorizado-fideicomiso', @NombreMenu = N'Presupuesto Autorizado Fideicomiso', @Ruta = '/PRESVW_EgresoAutorizadoFide', @MenuPadreNombre = N'Submódulo Fideicomiso', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Presupuesto Autorizado Fideicomiso', @Codigo = '2163';  
EXEC sp_RegistrarEntidad @Grupo = 'elaboracion-de-especificaciones-tecnicas-fide', @SubGrupo = 'elaboracion-de-especificaciones-tecnicas-fide', @NombreMenu = N'Elaboración de Especificaciones Técnicas FIDE', @Ruta = '/ORCOContenedorReq', @MenuPadreNombre = N'Fideicomiso', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Elaboración de Especificaciones Técnicas FIDE', @Codigo = '2164';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-cambio', @SubGrupo = 'tipo-cambio', @NombreMenu = N'Tipo Cambio', @Ruta = '/TESTipoCambio', @MenuPadreNombre = N'Tesorería', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Tipo Cambio', @Codigo = 'T001';  
EXEC sp_RegistrarEntidad @Grupo = 'procesar-nomina', @SubGrupo = 'procesar-nomina', @NombreMenu = N'Procesar Nómina', @Ruta = '/NOMIVW_DevengaNomina', @MenuPadreNombre = N'Submódulo de Nómina', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Procesar Nómina', @Codigo = '2191';  
EXEC sp_RegistrarEntidad @Grupo = 'elaboracion-de-especificaciones-tecnicas-mp', @SubGrupo = 'elaboracion-de-especificaciones-tecnicas-mp', @NombreMenu = N'Elaboración de Especificaciones Técnicas MP', @Ruta = '/ORCOContenedorMultiReq', @MenuPadreNombre = N'PEF Multipartidas ADQ', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Elaboración de Especificaciones Técnicas MP', @Codigo = '2192';  
EXEC sp_RegistrarEntidad @Grupo = 'planeacion', @SubGrupo = 'planeacion', @NombreMenu = N'Planeación', @Ruta = '/', @MenuPadreNombre = N'Submódulo de Egresos', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Planeación', @Codigo = '2226';  
EXEC sp_RegistrarEntidad @Grupo = 'programas-presupuestales', @SubGrupo = 'programas-presupuestales', @NombreMenu = N'Programas Presupuestales', @Ruta = '/PRESPrograma', @MenuPadreNombre = N'Catálogos presupuestales', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Programas Presupuestales', @Codigo = '1002';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-contrato', @SubGrupo = 'tipo-de-contrato', @NombreMenu = N'Tipo de Contrato', @Ruta = '/ORCOTipoContrato', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Tipo de Contrato', @Codigo = '1030';  
EXEC sp_RegistrarEntidad @Grupo = 'grupo-de-bien', @SubGrupo = 'grupo-de-bien', @NombreMenu = N'Grupo de Bien', @Ruta = '/SICOPGrupoBien', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Grupo de Bien', @Codigo = '1038';  
EXEC sp_RegistrarEntidad @Grupo = 'motivo-de-entradas/salidas', @SubGrupo = 'motivo-de-entradas/salidas', @NombreMenu = N'Motivo de Entradas/Salidas', @Ruta = '/ALMAMotivoES', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Motivo de Entradas/Salidas', @Codigo = '1049';  
EXEC sp_RegistrarEntidad @Grupo = 'cuentas-por-pagar', @SubGrupo = 'cuentas-por-pagar', @NombreMenu = N'Cuentas por Pagar', @Ruta = '/', @MenuPadreNombre = N'Submódulo Tesorería', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Cuentas por Pagar', @Codigo = 'M027';  
EXEC sp_RegistrarEntidad @Grupo = 'libro-mayor', @SubGrupo = 'libro-mayor', @NombreMenu = N'Libro Mayor', @Ruta = '/RepLibroMayor', @MenuPadreNombre = N'Reportes Contabilidad', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Libro Mayor', @Codigo = '1082';  
EXEC sp_RegistrarEntidad @Grupo = 'analisis-de-almacen', @SubGrupo = 'analisis-de-almacen', @NombreMenu = N'Análisis de Almacén', @Ruta = '/ALMACierrePivot', @MenuPadreNombre = N'Estadísticas', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Análisis de Almacén', @Codigo = '1110';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-de-situacion-financiera', @SubGrupo = 'estado-de-situacion-financiera', @NombreMenu = N'Estado de Situación Financiera', @Ruta = '/RepEdoSituacionFin', @MenuPadreNombre = N'Estados e Información Contable', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Estado de Situación Financiera', @Codigo = '1112';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-analitico-de-egresos-con-clasificacion-administrativa', @SubGrupo = 'estado-analitico-de-egresos-con-clasificacion-administrativa', @NombreMenu = N'Estado Análitico de Egresos con Clasificación Administrativa', @Ruta = '/RepClasAdministrativa', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Estado Análitico de Egresos con Clasificación Administrativa', @Codigo = '1121';  
EXEC sp_RegistrarEntidad @Grupo = 'otros', @SubGrupo = 'otros', @NombreMenu = N'Otros', @Ruta = '/', @MenuPadreNombre = N'Catálogos', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Otros', @Codigo = 'M204';  
EXEC sp_RegistrarEntidad @Grupo = 'baja-de-empleados', @SubGrupo = 'baja-de-empleados', @NombreMenu = N'Baja de Empleados', @Ruta = '/ErrConf', @MenuPadreNombre = N'Movimiento de Personal', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Baja de Empleados', @Codigo = '2068';  
EXEC sp_RegistrarEntidad @Grupo = 'movimientos-quincenales', @SubGrupo = 'movimientos-quincenales', @NombreMenu = N'Movimientos quincenales', @Ruta = '/ErrConf', @MenuPadreNombre = N'Plantilla de Personal', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Movimientos quincenales', @Codigo = '2071';  
EXEC sp_RegistrarEntidad @Grupo = 'parametrizacion-generica', @SubGrupo = 'parametrizacion-generica', @NombreMenu = N'Parametrización Genérica', @Ruta = '/', @MenuPadreNombre = N'Catalogos', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Parametrización Genérica', @Codigo = 'M217';  
EXEC sp_RegistrarEntidad @Grupo = 'calculo-de-nomina', @SubGrupo = 'calculo-de-nomina', @NombreMenu = N'Cálculo de Nómina', @Ruta = '/ErrConf', @MenuPadreNombre = N'Calculo', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Cálculo de Nómina', @Codigo = '2123';  
EXEC sp_RegistrarEntidad @Grupo = 'tasa-de-interes-anual-fonac', @SubGrupo = 'tasa-de-interes-anual-fonac', @NombreMenu = N'Tasa de interes Anual Fonac', @Ruta = '/NO_TasaInteresFonacAnual', @MenuPadreNombre = N'Fonac', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Tasa de interes Anual Fonac', @Codigo = '2135';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-pension', @SubGrupo = 'tipo-de-pension', @NombreMenu = N'Tipo de Pensión', @Ruta = '/NO_TipoPension', @MenuPadreNombre = N'Pensión Alimenticia', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Tipo de Pensión', @Codigo = '2139';  
EXEC sp_RegistrarEntidad @Grupo = 'tabulador-por-concepto', @SubGrupo = 'tabulador-por-concepto', @NombreMenu = N'Tabulador por Concepto', @Ruta = '/NO_ConceptoTabulador', @MenuPadreNombre = N'Tabuladores', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Tabulador por Concepto', @Codigo = '2141';  
EXEC sp_RegistrarEntidad @Grupo = 'auditoria', @SubGrupo = 'auditoria', @NombreMenu = N'Auditoria', @Ruta = '/ErrConf', @MenuPadreNombre = N'Historico', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Auditoria', @Codigo = '2146';  
EXEC sp_RegistrarEntidad @Grupo = 'registro-de-contrato-fideicomiso', @SubGrupo = 'registro-de-contrato-fideicomiso', @NombreMenu = N'Registro de Contrato Fideicomiso', @Ruta = '/ORCOContratosFide', @MenuPadreNombre = N'Contratos', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Registro de Contrato Fideicomiso', @Codigo = '2162';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-inversion', @SubGrupo = 'tipo-inversion', @NombreMenu = N'Tipo Inversion', @Ruta = '/TESTipoInversion', @MenuPadreNombre = N'Tesorería', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Tipo Inversion', @Codigo = 'T002';  
EXEC sp_RegistrarEntidad @Grupo = 'investigacion-de-mercado-fide', @SubGrupo = 'investigacion-de-mercado-fide', @NombreMenu = N'Investigación de Mercado FIDE', @Ruta = '/ORCOContenedorCot', @MenuPadreNombre = N'Fideicomiso', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Investigación de Mercado FIDE', @Codigo = '2176';  
EXEC sp_RegistrarEntidad @Grupo = 'presupuesto-disponible-fideicomiso', @SubGrupo = 'presupuesto-disponible-fideicomiso', @NombreMenu = N'Presupuesto Disponible Fideicomiso', @Ruta = '/PRESVW_EgreDispFide', @MenuPadreNombre = N'Submódulo Fideicomiso', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Presupuesto Disponible Fideicomiso', @Codigo = '2185';  
EXEC sp_RegistrarEntidad @Grupo = 'requisicion-para-nomina', @SubGrupo = 'requisicion-para-nomina', @NombreMenu = N'Requisición para Nómina', @Ruta = '/ORCORequisicion_NOM', @MenuPadreNombre = N'Submódulo de Nómina', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Requisición para Nómina', @Codigo = '1086';  
EXEC sp_RegistrarEntidad @Grupo = 'investigacion-de-mercado-mp', @SubGrupo = 'investigacion-de-mercado-mp', @NombreMenu = N'Investigación de Mercado MP', @Ruta = '/ORCOContenedorMultiCot', @MenuPadreNombre = N'PEF Multipartidas ADQ', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Investigación de Mercado MP', @Codigo = '2193';  
EXEC sp_RegistrarEntidad @Grupo = 'clave-del-programa', @SubGrupo = 'clave-del-programa', @NombreMenu = N'Clave del Programa', @Ruta = '/', @MenuPadreNombre = N'Catálogos presupuestales', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Clave del Programa', @Codigo = 'M021';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-documentos', @SubGrupo = 'tipo-de-documentos', @NombreMenu = N'Tipo de Documentos', @Ruta = '/ORCOTipoDocumento', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Tipo de Documentos', @Codigo = '1031';  
EXEC sp_RegistrarEntidad @Grupo = 'catalogo-de-bienes-y-servicios', @SubGrupo = 'catalogo-de-bienes-y-servicios', @NombreMenu = N'Catálogo de Bienes y Servicios', @Ruta = '/SICOPTipoBien', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Catálogo de Bienes y Servicios', @Codigo = '1039';  
EXEC sp_RegistrarEntidad @Grupo = 'estatus-solicitud', @SubGrupo = 'estatus-solicitud', @NombreMenu = N'Estatus Solicitud', @Ruta = '/ALMAEstatusSol', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Estatus Solicitud', @Codigo = '1050';  
EXEC sp_RegistrarEntidad @Grupo = 'libro-inventarios-materiales', @SubGrupo = 'libro-inventarios-materiales', @NombreMenu = N'Libro Inventarios Materiales', @Ruta = '/RepLibroInveMate', @MenuPadreNombre = N'Reportes Contabilidad', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Libro Inventarios Materiales', @Codigo = '1078';  
EXEC sp_RegistrarEntidad @Grupo = 'requisicion-pef', @SubGrupo = 'requisicion-pef', @NombreMenu = N'Requisición PEF', @Ruta = '/ORCORequisicion', @MenuPadreNombre = N'PEF Unipartida ADQ', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Requisición PEF', @Codigo = '1086';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-de-variaciones-en-la-hacienda-pública', @SubGrupo = 'estado-de-variaciones-en-la-hacienda-pública', @NombreMenu = N'Estado de Variaciones en la Hacienda Pública', @Ruta = '/RepVariacionHdaPub', @MenuPadreNombre = N'Estados e Información Contable', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Estado de Variaciones en la Hacienda Pública', @Codigo = '1116';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-analitico-de-egresos-con-clasificacion-economica', @SubGrupo = 'estado-analitico-de-egresos-con-clasificacion-economica', @NombreMenu = N'Estado Análitico de Egresos con Clasificación Económica', @Ruta = '/RepClasEconomica', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Estado Análitico de Egresos con Clasificación Económica', @Codigo = '1122';  
EXEC sp_RegistrarEntidad @Grupo = 'institucion', @SubGrupo = 'institucion', @NombreMenu = N'Institución', @Ruta = '/', @MenuPadreNombre = N'Catálogos', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Institución', @Codigo = 'M205';  
EXEC sp_RegistrarEntidad @Grupo = 'aplicacion-de-movimientos', @SubGrupo = 'aplicacion-de-movimientos', @NombreMenu = N'Aplicación de Movimientos', @Ruta = '/ErrConf', @MenuPadreNombre = N'Movimiento de Personal', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Aplicación de Movimientos', @Codigo = '2069';  
EXEC sp_RegistrarEntidad @Grupo = 'movimientos-quincenales-plaza', @SubGrupo = 'movimientos-quincenales-plaza', @NombreMenu = N'Movimientos quincenales Plaza', @Ruta = '/ErrConf', @MenuPadreNombre = N'Plantilla de Personal', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Movimientos quincenales Plaza', @Codigo = '2072';  
EXEC sp_RegistrarEntidad @Grupo = 'parametrizacion-por-concepto', @SubGrupo = 'parametrizacion-por-concepto', @NombreMenu = N'Parametrización por Concepto', @Ruta = '/', @MenuPadreNombre = N'Catalogos', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Parametrización por Concepto', @Codigo = 'M218';  
EXEC sp_RegistrarEntidad @Grupo = 'generacion-de-productos-de-nomina', @SubGrupo = 'generacion-de-productos-de-nomina', @NombreMenu = N'Generación de productos de nómina', @Ruta = '/ErrConf', @MenuPadreNombre = N'Calculo', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Generación de productos de nómina', @Codigo = '2124';  
EXEC sp_RegistrarEntidad @Grupo = 'tasa-de-interes-mensual-fonac', @SubGrupo = 'tasa-de-interes-mensual-fonac', @NombreMenu = N'Tasa de Interes mensual Fonac', @Ruta = '/NO_TasaInteresFonacMensual', @MenuPadreNombre = N'Fonac', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Tasa de Interes mensual Fonac', @Codigo = '2136';  
EXEC sp_RegistrarEntidad @Grupo = 'tabulador-por-nivel', @SubGrupo = 'tabulador-por-nivel', @NombreMenu = N'Tabulador por Nivel', @Ruta = '/NO_NivelTabulador', @MenuPadreNombre = N'Tabuladores', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Tabulador por Nivel', @Codigo = '2142';  
EXEC sp_RegistrarEntidad @Grupo = 'acumulados', @SubGrupo = 'acumulados', @NombreMenu = N'Acumulados', @Ruta = '/ErrConf', @MenuPadreNombre = N'Historico', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Acumulados', @Codigo = '2147';  
EXEC sp_RegistrarEntidad @Grupo = 'saldo-de-contratos', @SubGrupo = 'saldo-de-contratos', @NombreMenu = N'Saldo de Contratos', @Ruta = '/PRESVW_EgreCompNoDev', @MenuPadreNombre = N'Contratos', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Saldo de Contratos', @Codigo = '1152';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-moneda', @SubGrupo = 'tipo-moneda', @NombreMenu = N'Tipo Moneda', @Ruta = '/TESTipoMoneda', @MenuPadreNombre = N'Tesorería', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Tipo Moneda', @Codigo = 'T003';  
EXEC sp_RegistrarEntidad @Grupo = 'solicitud-suficiencia-presupuestal-fide', @SubGrupo = 'solicitud-suficiencia-presupuestal-fide', @NombreMenu = N'Solicitud Suficiencia Presupuestal FIDE', @Ruta = '/PRESContenedorSolicitudSuficiencia', @MenuPadreNombre = N'Fideicomiso', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Solicitud Suficiencia Presupuestal FIDE', @Codigo = '2166';  
EXEC sp_RegistrarEntidad @Grupo = 'solicitud-de-suficiencia-nomina', @SubGrupo = 'solicitud-de-suficiencia-nomina', @NombreMenu = N'Solicitud de Suficiencia Nómina', @Ruta = '/PRESVW_SolicitudSuficiencia_NOM', @MenuPadreNombre = N'Submódulo de Nómina', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Solicitud de Suficiencia Nómina', @Codigo = '1069';  
EXEC sp_RegistrarEntidad @Grupo = 'solicitud-de-suficiencia-presupuestal-mp-adq', @SubGrupo = 'solicitud-de-suficiencia-presupuestal-mp-adq', @NombreMenu = N'Solicitud de Suficiencia Presupuestal MP ADQ', @Ruta = '/PRESContenedorMultiSolicitudSuficienciaADQ', @MenuPadreNombre = N'PEF Multipartidas ADQ', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Solicitud de Suficiencia Presupuestal MP ADQ', @Codigo = '2194';  
EXEC sp_RegistrarEntidad @Grupo = 'contabilidad', @SubGrupo = 'contabilidad', @NombreMenu = N'Contabilidad', @Ruta = '/', @MenuPadreNombre = N'Catálogos presupuestales', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Contabilidad', @Codigo = 'M022';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-garantias', @SubGrupo = 'tipo-de-garantias', @NombreMenu = N'Tipo de Garantías', @Ruta = '/ORCOTipoGarantia', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Tipo de Garantías', @Codigo = '1032';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-patrimonio', @SubGrupo = 'tipo-de-patrimonio', @NombreMenu = N'Tipo de Patrimonio', @Ruta = '/SICOPTipoPatrimonio', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Tipo de Patrimonio', @Codigo = '1040';  
EXEC sp_RegistrarEntidad @Grupo = 'unidades', @SubGrupo = 'unidades', @NombreMenu = N'Unidades', @Ruta = '/ALMAUnidades', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Unidades', @Codigo = '1051';  
EXEC sp_RegistrarEntidad @Grupo = 'presupuesto-autorizado-de-egresos', @SubGrupo = 'presupuesto-autorizado-de-egresos', @NombreMenu = N'Presupuesto Autorizado de Egresos', @Ruta = '/PRESVW_EgresoAutorizado', @MenuPadreNombre = N'Submódulo de Egresos', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Presupuesto Autorizado de Egresos', @Codigo = '1064';  
EXEC sp_RegistrarEntidad @Grupo = 'libro-almacen-suministros', @SubGrupo = 'libro-almacen-suministros', @NombreMenu = N'Libro Almacén Suministros', @Ruta = '/RepLibroAlmaSumi', @MenuPadreNombre = N'Reportes Contabilidad', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Libro Almacén Suministros', @Codigo = '1079';  
EXEC sp_RegistrarEntidad @Grupo = 'estados-de-cambios-en-la-situacion-financiera', @SubGrupo = 'estados-de-cambios-en-la-situacion-financiera', @NombreMenu = N'Estados de Cambios en la Situación Financiera', @Ruta = '/RepEstadoCambiosSitFin', @MenuPadreNombre = N'Estados e Información Contable', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Estados de Cambios en la Situación Financiera', @Codigo = '1114';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-analitico-de-egresos-con-clasificacion-por-objeto-del-gasto', @SubGrupo = 'estado-analitico-de-egresos-con-clasificacion-por-objeto-del-gasto', @NombreMenu = N'Estado Análitico de Egresos con Clasificación por Objeto del Gasto', @Ruta = '/RepClasObjGasto', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Estado Análitico de Egresos con Clasificación por Objeto del Gasto', @Codigo = '1123';  
EXEC sp_RegistrarEntidad @Grupo = 'movimientos-de-personal', @SubGrupo = 'movimientos-de-personal', @NombreMenu = N'Movimientos de Personal', @Ruta = '/', @MenuPadreNombre = N'Catálogos', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Movimientos de Personal', @Codigo = 'M206';  
EXEC sp_RegistrarEntidad @Grupo = 'kardex', @SubGrupo = 'kardex', @NombreMenu = N'Kardex', @Ruta = '/ErrConf', @MenuPadreNombre = N'Plantilla de Personal', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Kardex', @Codigo = '2073';  
EXEC sp_RegistrarEntidad @Grupo = 'parametrizacion-por-modelo-de-pago', @SubGrupo = 'parametrizacion-por-modelo-de-pago', @NombreMenu = N'Parametrización por módelo de págo', @Ruta = '/', @MenuPadreNombre = N'Catalogos', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Parametrización por módelo de págo', @Codigo = 'M219';  
EXEC sp_RegistrarEntidad @Grupo = 'recibos-y-finiquitos', @SubGrupo = 'recibos-y-finiquitos', @NombreMenu = N'Recibos y Finiquitos', @Ruta = '/NO_PagoReciboFiniquito', @MenuPadreNombre = N'Calculo', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Recibos y Finiquitos', @Codigo = '2125';  
EXEC sp_RegistrarEntidad @Grupo = 'padron-de-empleados-fonac', @SubGrupo = 'padron-de-empleados-fonac', @NombreMenu = N'Padrón de Empleados Fonac', @Ruta = '/NO_PersonaFonac', @MenuPadreNombre = N'Fonac', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Padrón de Empleados Fonac', @Codigo = '2137';  
EXEC sp_RegistrarEntidad @Grupo = 'tabulador-honorarios', @SubGrupo = 'tabulador-honorarios', @NombreMenu = N'Tabulador Honorarios', @Ruta = '/NO_VariableConceptoSueldo', @MenuPadreNombre = N'Tabuladores', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Tabulador Honorarios', @Codigo = '2143';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-pago', @SubGrupo = 'tipo-pago', @NombreMenu = N'Tipo Pago', @Ruta = '/TESTipoPago', @MenuPadreNombre = N'Tesorería', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Tipo Pago', @Codigo = 'T004';  
EXEC sp_RegistrarEntidad @Grupo = 'solicitud-suficiencia-fideicomiso', @SubGrupo = 'solicitud-suficiencia-fideicomiso', @NombreMenu = N'Solicitud Suficiencia Fideicomiso', @Ruta = '/PRESContenedorSolicitudSuficienciaFide', @MenuPadreNombre = N'Submódulo Fideicomiso', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Solicitud Suficiencia Fideicomiso', @Codigo = '2167';  
EXEC sp_RegistrarEntidad @Grupo = 'saldo-de-contratos-fideicomiso', @SubGrupo = 'saldo-de-contratos-fideicomiso', @NombreMenu = N'Saldo de Contratos Fideicomiso', @Ruta = '/PRESEgreCompNoDevFide', @MenuPadreNombre = N'Contratos', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Saldo de Contratos Fideicomiso', @Codigo = '2183';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-de-suficiencia-nomina', @SubGrupo = 'autorizacion-de-suficiencia-nomina', @NombreMenu = N'Autorización de Suficiencia Nómina', @Ruta = '/PRESVW_AutorizacionSuficiencia_NOM', @MenuPadreNombre = N'Submódulo de Nómina', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Autorización de Suficiencia Nómina', @Codigo = '1070';  
EXEC sp_RegistrarEntidad @Grupo = 'procedimientos-de-contratacion', @SubGrupo = 'procedimientos-de-contratacion', @NombreMenu = N'Procedimientos de Contratación', @Ruta = '/ORCOProcedimientoContratacion', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Procedimientos de Contratación', @Codigo = '1033';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-servicio', @SubGrupo = 'tipo-de-servicio', @NombreMenu = N'Tipo de Servicio', @Ruta = '/SICOPTipoServicio', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Tipo de Servicio', @Codigo = '1041';  
EXEC sp_RegistrarEntidad @Grupo = 'consecutivo-de-entradas-de-almacen', @SubGrupo = 'consecutivo-de-entradas-de-almacen', @NombreMenu = N'Consecutivo de Entradas de Almacén', @Ruta = '/ALMAConsecEnt', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Consecutivo de Entradas de Almacén', @Codigo = '1052';  
EXEC sp_RegistrarEntidad @Grupo = 'presupuesto-modificado-de-egresos-(adecuaciones)', @SubGrupo = 'presupuesto-modificado-de-egresos-(adecuaciones)', @NombreMenu = N'Presupuesto Modificado de Egresos (Adecuaciones)', @Ruta = '/', @MenuPadreNombre = N'Submódulo de Egresos', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Presupuesto Modificado de Egresos (Adecuaciones)', @Codigo = 'M025';  
EXEC sp_RegistrarEntidad @Grupo = 'libro-inventarios-muebles', @SubGrupo = 'libro-inventarios-muebles', @NombreMenu = N'Libro Inventarios Muebles', @Ruta = '/ReportLibroInveMue', @MenuPadreNombre = N'Reportes Contabilidad', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Libro Inventarios Muebles', @Codigo = '1080';  
EXEC sp_RegistrarEntidad @Grupo = 'cotizacion-pef', @SubGrupo = 'cotizacion-pef', @NombreMenu = N'Cotización PEF', @Ruta = '/ORCOCotizacion', @MenuPadreNombre = N'PEF Unipartida ADQ', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Cotización PEF', @Codigo = '1087';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-de-flujos-de-efectivo', @SubGrupo = 'estado-de-flujos-de-efectivo', @NombreMenu = N'Estado de Flujos de Efectivo', @Ruta = '/ReporteEdoFlujoEfec', @MenuPadreNombre = N'Estados e Información Contable', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Estado de Flujos de Efectivo', @Codigo = '1115';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-analitico-de-egresos-con-clasificacion-funcional', @SubGrupo = 'estado-analitico-de-egresos-con-clasificacion-funcional', @NombreMenu = N'Estado Análitico de Egresos con Clasificación Funcional', @Ruta = '/RepClasFuncional', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Estado Análitico de Egresos con Clasificación Funcional', @Codigo = '1124';  
EXEC sp_RegistrarEntidad @Grupo = 'licencias-medicas', @SubGrupo = 'licencias-medicas', @NombreMenu = N'Licencias Medicas', @Ruta = '/', @MenuPadreNombre = N'Catálogos', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Licencias Medicas', @Codigo = 'M207';  
EXEC sp_RegistrarEntidad @Grupo = 'kardex-plaza', @SubGrupo = 'kardex-plaza', @NombreMenu = N'Kardex Plaza', @Ruta = '/ErrConf', @MenuPadreNombre = N'Plantilla de Personal', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Kardex Plaza', @Codigo = '2074';  
EXEC sp_RegistrarEntidad @Grupo = 'parametrizacion-por-empleado', @SubGrupo = 'parametrizacion-por-empleado', @NombreMenu = N'Parametrización por Empleado', @Ruta = '/', @MenuPadreNombre = N'Catalogos', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Parametrización por Empleado', @Codigo = 'M220';  
EXEC sp_RegistrarEntidad @Grupo = 'reporte-de-nomina-presupuestal-anual', @SubGrupo = 'reporte-de-nomina-presupuestal-anual', @NombreMenu = N'Reporte de nomina presupuestal anual', @Ruta = '/ErrConf', @MenuPadreNombre = N'Reportes', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Reporte de nomina presupuestal anual', @Codigo = '2130';  
EXEC sp_RegistrarEntidad @Grupo = 'comprometer-nomina', @SubGrupo = 'comprometer-nomina', @NombreMenu = N'Comprometer Nomina', @Ruta = '/PRESVW_Contrato_NOM', @MenuPadreNombre = N'Submódulo de Nómina', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Comprometer Nomina', @Codigo = '1150';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-del-contrato', @SubGrupo = 'estado-del-contrato', @NombreMenu = N'Estado del Contrato', @Ruta = '/PRESVW_ContratoTerminacionAnticipada', @MenuPadreNombre = N'Contratos', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Estado del Contrato', @Codigo = '2148';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-pagosf', @SubGrupo = 'tipo-pagosf', @NombreMenu = N'Tipo PagoSF', @Ruta = '/TESTipoPagoSF', @MenuPadreNombre = N'Tesorería', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Tipo PagoSF', @Codigo = 'T005';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-suficiencia-fideicomiso', @SubGrupo = 'autorizacion-suficiencia-fideicomiso', @NombreMenu = N'Autorización Suficiencia Fideicomiso', @Ruta = '/PRESContenedorAutorizacionSuficiencia', @MenuPadreNombre = N'Submódulo Fideicomiso', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Autorización Suficiencia Fideicomiso', @Codigo = '2165';  
EXEC sp_RegistrarEntidad @Grupo = 'estatus-requisicion', @SubGrupo = 'estatus-requisicion', @NombreMenu = N'Estatus Requisición', @Ruta = '/ORCOEstatusOrdenCompra', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Estatus Requisición', @Codigo = '1034';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-siniestro', @SubGrupo = 'tipo-de-siniestro', @NombreMenu = N'Tipo de Siniestro', @Ruta = '/SICOPTipoSiniestro', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Tipo de Siniestro', @Codigo = '1042';  
EXEC sp_RegistrarEntidad @Grupo = 'consecutivo-de-solicitudes-de-salidas-de-almacen', @SubGrupo = 'consecutivo-de-solicitudes-de-salidas-de-almacen', @NombreMenu = N'Consecutivo de Solicitudes de Salidas de Almacén', @Ruta = '/ALMAConsecSolSal', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Consecutivo de Solicitudes de Salidas de Almacén', @Codigo = '1053';  
EXEC sp_RegistrarEntidad @Grupo = 'presupuesto-disponible-pef', @SubGrupo = 'presupuesto-disponible-pef', @NombreMenu = N'Presupuesto Disponible PEF', @Ruta = '/PRESVW_EgreDisp', @MenuPadreNombre = N'Submódulo de Egresos', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Presupuesto Disponible PEF', @Codigo = '1068';  
EXEC sp_RegistrarEntidad @Grupo = 'polizas', @SubGrupo = 'polizas', @NombreMenu = N'Pólizas', @Ruta = '/ReportePoliza', @MenuPadreNombre = N'Reportes Contabilidad', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Pólizas', @Codigo = '1083';  
EXEC sp_RegistrarEntidad @Grupo = 'solicitud-de-suficiencia-presupuestal-pef-adq', @SubGrupo = 'solicitud-de-suficiencia-presupuestal-pef-adq', @NombreMenu = N'Solicitud de Suficiencia Presupuestal PEF ADQ', @Ruta = '/PRESVW_SolicitudSuficienciaADQ', @MenuPadreNombre = N'PEF Unipartida ADQ', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Solicitud de Suficiencia Presupuestal PEF ADQ', @Codigo = '1088';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-analitico-del-activo', @SubGrupo = 'estado-analitico-del-activo', @NombreMenu = N'Estado Análitico del Activo', @Ruta = '/RepAnaActi', @MenuPadreNombre = N'Estados e Información Contable', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Estado Análitico del Activo', @Codigo = '1111';  
EXEC sp_RegistrarEntidad @Grupo = 'endeudamiento-neto', @SubGrupo = 'endeudamiento-neto', @NombreMenu = N'Endeudamiento Neto', @Ruta = '/RepEndeudamiento', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Endeudamiento Neto', @Codigo = '1125';  
EXEC sp_RegistrarEntidad @Grupo = 'reporteador', @SubGrupo = 'reporteador', @NombreMenu = N'Reporteador', @Ruta = '/ErrConf', @MenuPadreNombre = N'Plantilla de Personal', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Reporteador', @Codigo = '2075';  
EXEC sp_RegistrarEntidad @Grupo = 'imss', @SubGrupo = 'imss', @NombreMenu = N'IMSS', @Ruta = '/', @MenuPadreNombre = N'Catalogos', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'IMSS', @Codigo = 'M221';  
EXEC sp_RegistrarEntidad @Grupo = 'reporte-de-retenciones', @SubGrupo = 'reporte-de-retenciones', @NombreMenu = N'Reporte de Retenciones', @Ruta = '/RepRetenciones', @MenuPadreNombre = N'Reportes Contabilidad', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Reporte de Retenciones', @Codigo = '2126';  
EXEC sp_RegistrarEntidad @Grupo = 'reporte-listado-nomina-historico-personal', @SubGrupo = 'reporte-listado-nomina-historico-personal', @NombreMenu = N'Reporte listado nomina Historico personal', @Ruta = '/ErrConf', @MenuPadreNombre = N'Reportes', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Reporte listado nomina Historico personal', @Codigo = '2131';  
EXEC sp_RegistrarEntidad @Grupo = 'devengar-nomina', @SubGrupo = 'devengar-nomina', @NombreMenu = N'Devengar Nomina', @Ruta = '/PRESVW_Factura_Nom', @MenuPadreNombre = N'Submódulo de Nómina', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Devengar Nomina', @Codigo = '1151';  
EXEC sp_RegistrarEntidad @Grupo = 'registro-compromiso-fideicomiso', @SubGrupo = 'registro-compromiso-fideicomiso', @NombreMenu = N'Registro Compromiso Fideicomiso', @Ruta = '/PRESContenedorContrato', @MenuPadreNombre = N'Submódulo Fideicomiso', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Registro Compromiso Fideicomiso', @Codigo = '2158';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-solicitud-clc', @SubGrupo = 'tipo-solicitud-clc', @NombreMenu = N'Tipo Solicitud CLC', @Ruta = '/TESTipoSolicitudCLC', @MenuPadreNombre = N'Tesorería', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Tipo Solicitud CLC', @Codigo = 'T006';  
EXEC sp_RegistrarEntidad @Grupo = 'consecutivo-elaboracion-de-especificaciones-tecnicas', @SubGrupo = 'consecutivo-elaboracion-de-especificaciones-tecnicas', @NombreMenu = N'Consecutivo Elaboración de Especificaciones Técnicas', @Ruta = '/ORCOConsecutivoRequisicion', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Consecutivo Elaboración de Especificaciones Técnicas', @Codigo = '1035';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-depreciacion', @SubGrupo = 'tipo-de-depreciacion', @NombreMenu = N'Tipo de Depreciación', @Ruta = '/SICOPTipoDepreciacion', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Tipo de Depreciación', @Codigo = '1043';  
EXEC sp_RegistrarEntidad @Grupo = 'consecutivo-de-salidas-de-almacen', @SubGrupo = 'consecutivo-de-salidas-de-almacen', @NombreMenu = N'Consecutivo de Salidas de Almacén', @Ruta = '/ALMAConsecSal', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Consecutivo de Salidas de Almacén', @Codigo = '1054';  
EXEC sp_RegistrarEntidad @Grupo = 'presupuesto-comprometido-unipartida', @SubGrupo = 'presupuesto-comprometido-unipartida', @NombreMenu = N'Presupuesto Comprometido Unipartida', @Ruta = '/', @MenuPadreNombre = N'Submódulo de Egresos', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Presupuesto Comprometido Unipartida', @Codigo = 'M026';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-analitico-de-la-deuda-y-otros-pasivos', @SubGrupo = 'estado-analitico-de-la-deuda-y-otros-pasivos', @NombreMenu = N'Estado Análitico de la Deuda y Otros Pasivos', @Ruta = '/RepEstadoAnaDeuda', @MenuPadreNombre = N'Estados e Información Contable', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Estado Análitico de la Deuda y Otros Pasivos', @Codigo = '1117';  
EXEC sp_RegistrarEntidad @Grupo = 'intereses-de-la-deuda', @SubGrupo = 'intereses-de-la-deuda', @NombreMenu = N'Intereses de la Deuda', @Ruta = '/RepInteresesDeuda', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Intereses de la Deuda', @Codigo = '1126';  
EXEC sp_RegistrarEntidad @Grupo = 'reporte-de-depreciacion-acumulada', @SubGrupo = 'reporte-de-depreciacion-acumulada', @NombreMenu = N'Reporte de Depreciación Acumulada', @Ruta = '/RepDepAcum', @MenuPadreNombre = N'Reportes Contabilidad', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Reporte de Depreciación Acumulada', @Codigo = '2127';  
EXEC sp_RegistrarEntidad @Grupo = 'timbrado', @SubGrupo = 'timbrado', @NombreMenu = N'Timbrado', @Ruta = '/ErrConf', @MenuPadreNombre = N'Reportes', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Timbrado', @Codigo = '2132';  
EXEC sp_RegistrarEntidad @Grupo = 'número-de-conteo', @SubGrupo = 'número-de-conteo', @NombreMenu = N'Número de Conteo', @Ruta = '/ALMANumeroConteo', @MenuPadreNombre = N'Almacén', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Número de Conteo', @Codigo = '2150';  
EXEC sp_RegistrarEntidad @Grupo = 'registro-de-facturas-fideicomiso', @SubGrupo = 'registro-de-facturas-fideicomiso', @NombreMenu = N'Registro de Facturas Fideicomiso', @Ruta = '/PRESContenedorFactura', @MenuPadreNombre = N'Submódulo Fideicomiso', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Registro de Facturas Fideicomiso', @Codigo = '2159';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-documento-clc', @SubGrupo = 'tipo-de-documento-clc', @NombreMenu = N'Tipo de documento CLC', @Ruta = '/SISTipoDoctoCLC', @MenuPadreNombre = N'Tesorería', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Tipo de documento CLC', @Codigo = '2179';  
EXEC sp_RegistrarEntidad @Grupo = 'provision-del-pago-de-nomina', @SubGrupo = 'provision-del-pago-de-nomina', @NombreMenu = N'Provisión del Pago de Nómina', @Ruta = '/PRESVW_Clc_Nom', @MenuPadreNombre = N'Submódulo de Nómina', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Provisión del Pago de Nómina', @Codigo = '2198';  
EXEC sp_RegistrarEntidad @Grupo = 'consecutivo-de-solicitudes-de-compra', @SubGrupo = 'consecutivo-de-solicitudes-de-compra', @NombreMenu = N'Consecutivo de Solicitudes de Compra', @Ruta = '/ORCOConsecutivoOrdenCompra', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Consecutivo de Solicitudes de Compra', @Codigo = '1036';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-adquisicion', @SubGrupo = 'tipo-de-adquisicion', @NombreMenu = N'Tipo de Adquisición', @Ruta = '/SICOPTipoAdq', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Tipo de Adquisición', @Codigo = '1044';  
EXEC sp_RegistrarEntidad @Grupo = 'informe-sobre-pasivos-contingentes', @SubGrupo = 'informe-sobre-pasivos-contingentes', @NombreMenu = N'Informe sobre Pasivos Contingentes', @Ruta = '/RepPasivosContingentes', @MenuPadreNombre = N'Estados e Información Contable', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Informe sobre Pasivos Contingentes', @Codigo = '1119';  
EXEC sp_RegistrarEntidad @Grupo = 'proyecciones-de-egresos', @SubGrupo = 'proyecciones-de-egresos', @NombreMenu = N'Proyecciones de Egresos', @Ruta = '/RepProyEgresos', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Proyecciones de Egresos', @Codigo = '1127';  
EXEC sp_RegistrarEntidad @Grupo = 'reporte-de-activos-fijos', @SubGrupo = 'reporte-de-activos-fijos', @NombreMenu = N'Reporte de Activos Fijos', @Ruta = '/RepActFijos', @MenuPadreNombre = N'Reportes Contabilidad', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Reporte de Activos Fijos', @Codigo = '2128';  
EXEC sp_RegistrarEntidad @Grupo = 'reporte-listado-nomina-historico-personal-retroactivo', @SubGrupo = 'reporte-listado-nomina-historico-personal-retroactivo', @NombreMenu = N'Reporte listado nomina Historico personal Retroactivo', @Ruta = '/ErrConf', @MenuPadreNombre = N'Reportes', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Reporte listado nomina Historico personal Retroactivo', @Codigo = '2133';  
EXEC sp_RegistrarEntidad @Grupo = 'solicitud-de-pagos-fideicomiso', @SubGrupo = 'solicitud-de-pagos-fideicomiso', @NombreMenu = N'Solicitud de Pagos Fideicomiso', @Ruta = '/PRESContenedorCLC', @MenuPadreNombre = N'Submódulo Fideicomiso', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Solicitud de Pagos Fideicomiso', @Codigo = '2160';  
EXEC sp_RegistrarEntidad @Grupo = 'pago-de-nomina', @SubGrupo = 'pago-de-nomina', @NombreMenu = N'Pago de Nómina', @Ruta = '/PRESVW_Cheque_Nom', @MenuPadreNombre = N'Submódulo de Nómina', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Pago de Nómina', @Codigo = '1074';  
EXEC sp_RegistrarEntidad @Grupo = 'presupuesto-comprometido-multipartidas', @SubGrupo = 'presupuesto-comprometido-multipartidas', @NombreMenu = N'Presupuesto Comprometido Multipartidas', @Ruta = '/', @MenuPadreNombre = N'Submódulo de Egresos', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Presupuesto Comprometido Multipartidas', @Codigo = 'M041';  
EXEC sp_RegistrarEntidad @Grupo = 'marca', @SubGrupo = 'marca', @NombreMenu = N'Marca', @Ruta = '/SICOPMarca', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Marca', @Codigo = '1045';  
EXEC sp_RegistrarEntidad @Grupo = 'notas-estados-financieros', @SubGrupo = 'notas-estados-financieros', @NombreMenu = N'Notas Estados Financieros', @Ruta = '/NotasEdosFin', @MenuPadreNombre = N'Estados e Información Contable', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Notas Estados Financieros', @Codigo = '1118';  
EXEC sp_RegistrarEntidad @Grupo = 'proyecciones-de-ingresos', @SubGrupo = 'proyecciones-de-ingresos', @NombreMenu = N'Proyecciones de Ingresos', @Ruta = '/RepProyIngresos', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Proyecciones de Ingresos', @Codigo = '1128';  
EXEC sp_RegistrarEntidad @Grupo = 'egresos-no-planificados', @SubGrupo = 'egresos-no-planificados', @NombreMenu = N'Egresos No Planificados', @Ruta = '/', @MenuPadreNombre = N'Submódulo de Egresos', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Egresos No Planificados', @Codigo = 'M030';  
EXEC sp_RegistrarEntidad @Grupo = 'proveedores', @SubGrupo = 'proveedores', @NombreMenu = N'Proveedores', @Ruta = '/SISProveedor', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Proveedores', @Codigo = '1143';  
EXEC sp_RegistrarEntidad @Grupo = 'reporte-de-facturas-emitidas', @SubGrupo = 'reporte-de-facturas-emitidas', @NombreMenu = N'Reporte de Facturas Emitidas', @Ruta = '/RepFactEmit', @MenuPadreNombre = N'Reportes Contabilidad', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Reporte de Facturas Emitidas', @Codigo = '2129';  
EXEC sp_RegistrarEntidad @Grupo = 'registro-de-pagos-fideicomiso', @SubGrupo = 'registro-de-pagos-fideicomiso', @NombreMenu = N'Registro de Pagos Fideicomiso', @Ruta = '/PRESContenedorCheque', @MenuPadreNombre = N'Submódulo Fideicomiso', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Registro de Pagos Fideicomiso', @Codigo = '2161';  
EXEC sp_RegistrarEntidad @Grupo = 'conceptos-de-nomina', @SubGrupo = 'conceptos-de-nomina', @NombreMenu = N'Conceptos de Nómina', @Ruta = '/NOMIConcepto', @MenuPadreNombre = N'Submódulo de Nómina', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Conceptos de Nómina', @Codigo = '2203';  
EXEC sp_RegistrarEntidad @Grupo = 'material', @SubGrupo = 'material', @NombreMenu = N'Material', @Ruta = '/SICOPMaterial', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Material', @Codigo = '1046';  
EXEC sp_RegistrarEntidad @Grupo = 'indicadores-asociados-a-programas-presupuestarios', @SubGrupo = 'indicadores-asociados-a-programas-presupuestarios', @NombreMenu = N'Indicadores Asociados a Programas Presupuestarios', @Ruta = '/ReporteIAPP', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Indicadores Asociados a Programas Presupuestarios', @Codigo = '1129';  
EXEC sp_RegistrarEntidad @Grupo = 'tratados-internacionales', @SubGrupo = 'tratados-internacionales', @NombreMenu = N'Tratados Internacionales', @Ruta = '/ADQTratadoInt', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Tratados Internacionales', @Codigo = '1144';  
EXEC sp_RegistrarEntidad @Grupo = 'planeacion-de-gastos', @SubGrupo = 'planeacion-de-gastos', @NombreMenu = N'Planeación de gastos', @Ruta = '/ErrConf', @MenuPadreNombre = N'Submódulo Tesorería', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Planeación de gastos', @Codigo = '2169';  
EXEC sp_RegistrarEntidad @Grupo = 'elaboracion-de-cheques', @SubGrupo = 'elaboracion-de-cheques', @NombreMenu = N'Elaboración de Cheques', @Ruta = '/ErrConf', @MenuPadreNombre = N'Submódulo de Egresos', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Elaboración de Cheques', @Codigo = '2174';  
EXEC sp_RegistrarEntidad @Grupo = 'articulo', @SubGrupo = 'articulo', @NombreMenu = N'Artículo', @Ruta = '/ORCOArticulo', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Artículo', @Codigo = '2177';  
EXEC sp_RegistrarEntidad @Grupo = 'reporte-diot', @SubGrupo = 'reporte-diot', @NombreMenu = N'Reporte DIOT', @Ruta = '/RepDIOT', @MenuPadreNombre = N'Reportes Contabilidad', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Reporte DIOT', @Codigo = '2190';  
EXEC sp_RegistrarEntidad @Grupo = 'totales-de-nomina-por-partida', @SubGrupo = 'totales-de-nomina-por-partida', @NombreMenu = N'Totales de Nómina por partida', @Ruta = '/NOMIVW_TotalesNominaXPartida', @MenuPadreNombre = N'Submódulo de Nómina', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Totales de Nómina por partida', @Codigo = '2204';  
EXEC sp_RegistrarEntidad @Grupo = 'color', @SubGrupo = 'color', @NombreMenu = N'Color', @Ruta = '/SICOPColor', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Color', @Codigo = '1047';  
EXEC sp_RegistrarEntidad @Grupo = 'programas-y-proyectos-de-inversion', @SubGrupo = 'programas-y-proyectos-de-inversion', @NombreMenu = N'Programas y proyectos de Inversión', @Ruta = '/ReportePPI', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Programas y proyectos de Inversión', @Codigo = '1130';  
EXEC sp_RegistrarEntidad @Grupo = 'saldos-cuentas', @SubGrupo = 'saldos-cuentas', @NombreMenu = N'Saldos Cuentas', @Ruta = '/TESSaldosCuenta', @MenuPadreNombre = N'Submódulo Tesorería', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Saldos Cuentas', @Codigo = '2170';  
EXEC sp_RegistrarEntidad @Grupo = 'estatus-de-cheques', @SubGrupo = 'estatus-de-cheques', @NombreMenu = N'Estatus de Cheques', @Ruta = '/ErrConf', @MenuPadreNombre = N'Submódulo de Egresos', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Estatus de Cheques', @Codigo = '2175';  
EXEC sp_RegistrarEntidad @Grupo = 'fraccion', @SubGrupo = 'fraccion', @NombreMenu = N'Fracción', @Ruta = '/ORCOFraccion', @MenuPadreNombre = N'Adquisiciones', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Fracción', @Codigo = '2178';  
EXEC sp_RegistrarEntidad @Grupo = 'catalogo-de-personas', @SubGrupo = 'catalogo-de-personas', @NombreMenu = N'Catálogo de Personas', @Ruta = '/RHCTPersona', @MenuPadreNombre = N'Patrimonio', @Icono = 'FaRegSun', @Orden = 12, @Descripcion = N'Catálogo de Personas', @Codigo = '1148';  
EXEC sp_RegistrarEntidad @Grupo = 'solicitud-de-reintegros', @SubGrupo = 'solicitud-de-reintegros', @NombreMenu = N'Solicitud de reintegros', @Ruta = '/ErrConf', @MenuPadreNombre = N'Submódulo Tesorería', @Icono = 'FaRegSun', @Orden = 12, @Descripcion = N'Solicitud de reintegros', @Codigo = '2171';  
EXEC sp_RegistrarEntidad @Grupo = 'resultados-de-ingresos', @SubGrupo = 'resultados-de-ingresos', @NombreMenu = N'Resultados de Ingresos', @Ruta = '/RepResultIngresos', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 12, @Descripcion = N'Resultados de Ingresos', @Codigo = '2201';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizar-solicitud-de-reingresos', @SubGrupo = 'autorizar-solicitud-de-reingresos', @NombreMenu = N'Autorizar solicitud de reingresos', @Ruta = '/ErrConf', @MenuPadreNombre = N'Submódulo Tesorería', @Icono = 'FaRegSun', @Orden = 13, @Descripcion = N'Autorizar solicitud de reingresos', @Codigo = '2172';  
EXEC sp_RegistrarEntidad @Grupo = 'resultados-de-egresos', @SubGrupo = 'resultados-de-egresos', @NombreMenu = N'Resultados de Egresos', @Ruta = '/RepResultEgre', @MenuPadreNombre = N'Estados e Informes Presupuestarios', @Icono = 'FaRegSun', @Orden = 13, @Descripcion = N'Resultados de Egresos', @Codigo = '2202';  
EXEC sp_RegistrarEntidad @Grupo = 'provision-del-pago-(importes)', @SubGrupo = 'provision-del-pago-(importes)', @NombreMenu = N'Provisión del Pago (Importes)', @Ruta = '/PRESVW_CLCFactura_Importe', @MenuPadreNombre = N'Submódulo Tesorería', @Icono = 'FaRegSun', @Orden = 14, @Descripcion = N'Provisión del Pago (Importes)', @Codigo = '-   ';  
EXEC sp_RegistrarEntidad @Grupo = 'sigevi', @SubGrupo = 'sigevi', @NombreMenu = N'SIGEVI', @Ruta = '/', @MenuPadreNombre = N'Submódulo de Egresos', @Icono = 'FaRegSun', @Orden = 15, @Descripcion = N'SIGEVI', @Codigo = '-   ';  
EXEC sp_RegistrarEntidad @Grupo = 'inversiones', @SubGrupo = 'inversiones', @NombreMenu = N'Inversiones', @Ruta = '/', @MenuPadreNombre = N'Submódulo Tesorería', @Icono = 'FaRegSun', @Orden = 16, @Descripcion = N'Inversiones', @Codigo = '2205';  
EXEC sp_RegistrarEntidad @Grupo = 'unidad-responsable', @SubGrupo = 'unidad-responsable', @NombreMenu = N'Unidad Responsable', @Ruta = '/SISArea', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Unidad Responsable', @Codigo = '1003';  
EXEC sp_RegistrarEntidad @Grupo = 'consecutivo-de-polizas', @SubGrupo = 'consecutivo-de-polizas', @NombreMenu = N'Consecutivo de Pólizas', @Ruta = '/CONTAConsecutivoPoliza', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Consecutivo de Pólizas', @Codigo = '1022';  
EXEC sp_RegistrarEntidad @Grupo = 'ley-de-ingresos-estimados', @SubGrupo = 'ley-de-ingresos-estimados', @NombreMenu = N'Ley de Ingresos Estimados', @Ruta = '/PRESVW_IngresoAutorizado', @MenuPadreNombre = N'Cuentas por Cobrar', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Ley de Ingresos Estimados', @Codigo = '1055';  
EXEC sp_RegistrarEntidad @Grupo = 'captura-adecuaciones-compensadas-egre', @SubGrupo = 'captura-adecuaciones-compensadas-egre', @NombreMenu = N'Captura Adecuaciones Compensadas Egre', @Ruta = '/PRESVW_EgreModMastComp', @MenuPadreNombre = N'Presupuesto Modificado de Egresos (Adecuaciones)', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Captura Adecuaciones Compensadas Egre', @Codigo = '1065';  
EXEC sp_RegistrarEntidad @Grupo = 'solicitud-de-suficiencia-presupuestal-pef', @SubGrupo = 'solicitud-de-suficiencia-presupuestal-pef', @NombreMenu = N'Solicitud de Suficiencia Presupuestal PEF', @Ruta = '/PRESVW_SolicitudSuficiencia', @MenuPadreNombre = N'Presupuesto Comprometido Unipartida', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Solicitud de Suficiencia Presupuestal PEF', @Codigo = '1069';  
EXEC sp_RegistrarEntidad @Grupo = 'fondo-revolvente', @SubGrupo = 'fondo-revolvente', @NombreMenu = N'Fondo Revolvente', @Ruta = '/FondoRevolvente', @MenuPadreNombre = N'Egresos No Planificados', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Fondo Revolvente', @Codigo = '1138';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-civil', @SubGrupo = 'estado-civil', @NombreMenu = N'Estado Civil', @Ruta = '/RH_EstadoCivil', @MenuPadreNombre = N'Generales', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Estado Civil', @Codigo = '2001';  
EXEC sp_RegistrarEntidad @Grupo = 'basificado', @SubGrupo = 'basificado', @NombreMenu = N'Basificado', @Ruta = '/RH_Basificado', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Basificado', @Codigo = '2009';  
EXEC sp_RegistrarEntidad @Grupo = 'clase-de-puesto', @SubGrupo = 'clase-de-puesto', @NombreMenu = N'Clase de Puesto', @Ruta = '/RH_ClasePuesto', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Clase de Puesto', @Codigo = '2026';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-personal', @SubGrupo = 'tipo-de-personal', @NombreMenu = N'Tipo de Personal', @Ruta = '/RH_TipoPersonal', @MenuPadreNombre = N'Movimientos de Personal', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Tipo de Personal', @Codigo = '2045';  
EXEC sp_RegistrarEntidad @Grupo = 'motivo-licencia-medica', @SubGrupo = 'motivo-licencia-medica', @NombreMenu = N'Motivo Licencia Medica', @Ruta = '/RH_MotivoLicencia', @MenuPadreNombre = N'Licencias Medicas', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Motivo Licencia Medica', @Codigo = '2054';  
EXEC sp_RegistrarEntidad @Grupo = 'creacion', @SubGrupo = 'creacion', @NombreMenu = N'Creación', @Ruta = '/RH_MovimientoPlaza', @MenuPadreNombre = N'Captura de Movimientos Plazas', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Creación', @Codigo = '2057';  
EXEC sp_RegistrarEntidad @Grupo = 'estructura-programatica', @SubGrupo = 'estructura-programatica', @NombreMenu = N'Estructura Programática', @Ruta = '/NO_EstructProgramatica', @MenuPadreNombre = N'Generales', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Estructura Programática', @Codigo = '2076';  
EXEC sp_RegistrarEntidad @Grupo = 'i.s.p.t.-anual', @SubGrupo = 'i.s.p.t.-anual', @NombreMenu = N'I.S.P.T. Anual', @Ruta = '/NO_ISPTAnual', @MenuPadreNombre = N'Parametrización Genérica', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'I.S.P.T. Anual', @Codigo = '2079';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-por-agrupacion', @SubGrupo = 'concepto-por-agrupacion', @NombreMenu = N'Concepto por Agrupación', @Ruta = '/NO_ConceptoAgrupacion', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Concepto por Agrupación', @Codigo = '2090';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-mando-antigüedad', @SubGrupo = 'concepto-mando-antigüedad', @NombreMenu = N'Concepto mando antigüedad', @Ruta = '/NO_ConcepMandoAntig', @MenuPadreNombre = N'Parametrización por módelo de págo', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Concepto mando antigüedad', @Codigo = '2107';  
EXEC sp_RegistrarEntidad @Grupo = 'horas-extra-por-empleado', @SubGrupo = 'horas-extra-por-empleado', @NombreMenu = N'Horas Extra por Empleado', @Ruta = '/SISTratadoInt', @MenuPadreNombre = N'Parametrización por Empleado', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Horas Extra por Empleado', @Codigo = '2111';  
EXEC sp_RegistrarEntidad @Grupo = 'pagos-imss', @SubGrupo = 'pagos-imss', @NombreMenu = N'Pagos IMSS', @Ruta = '/NO_IMSS', @MenuPadreNombre = N'IMSS', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Pagos IMSS', @Codigo = '2120';  
EXEC sp_RegistrarEntidad @Grupo = 'banco', @SubGrupo = 'banco', @NombreMenu = N'Banco', @Ruta = '/SISBanco', @MenuPadreNombre = N'Inversiones', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Banco', @Codigo = '1153';  
EXEC sp_RegistrarEntidad @Grupo = 'solicitud-de-suficiencia-presupuestal-mp', @SubGrupo = 'solicitud-de-suficiencia-presupuestal-mp', @NombreMenu = N'Solicitud de Suficiencia Presupuestal MP', @Ruta = '/PRESContenedorMultiSolicitudSuficiencia', @MenuPadreNombre = N'Presupuesto Comprometido Multipartidas', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Solicitud de Suficiencia Presupuestal MP', @Codigo = '2197';  
EXEC sp_RegistrarEntidad @Grupo = 'catalogos-planeacion', @SubGrupo = 'catalogos-planeacion', @NombreMenu = N'Catálogos Planeación', @Ruta = '/', @MenuPadreNombre = N'Planeación', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Catálogos Planeación', @Codigo = '2227';  
EXEC sp_RegistrarEntidad @Grupo = 'finalidad', @SubGrupo = 'finalidad', @NombreMenu = N'Finalidad', @Ruta = '/PRESGF', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Finalidad', @Codigo = '1004';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-polizas', @SubGrupo = 'tipo-de-polizas', @NombreMenu = N'Tipo de Pólizas', @Ruta = '/SISTipoPoliza', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Tipo de Pólizas', @Codigo = '1023';  
EXEC sp_RegistrarEntidad @Grupo = 'presupuesto-modificado-de-ingresos(adecuaciones)', @SubGrupo = 'presupuesto-modificado-de-ingresos(adecuaciones)', @NombreMenu = N'Presupuesto Modificado de Ingresos(Adecuaciones)', @Ruta = '/', @MenuPadreNombre = N'Cuentas por Cobrar', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Presupuesto Modificado de Ingresos(Adecuaciones)', @Codigo = 'M023';  
EXEC sp_RegistrarEntidad @Grupo = 'Planeacion', @SubGrupo = 'anteproyecto', @NombreMenu = N'Anteproyecto de Egresos', @Ruta = '/Planeacion/Anteproyecto_Egresos', @MenuPadreNombre = N'Planeación', @Icono = 'FaKey', @Orden = 2, @Descripcion = N'Anteproyecto de Egresos', @Codigo = '1063';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-de-suficiencia-presupuestal-pef', @SubGrupo = 'autorizacion-de-suficiencia-presupuestal-pef', @NombreMenu = N'Autorización de Suficiencia Presupuestal PEF', @Ruta = '/PRESVW_AutorizacionSuficiencia', @MenuPadreNombre = N'Presupuesto Comprometido Unipartida', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Autorización de Suficiencia Presupuestal PEF', @Codigo = '1070';  
EXEC sp_RegistrarEntidad @Grupo = 'gastos-a-comprobar', @SubGrupo = 'gastos-a-comprobar', @NombreMenu = N'Gastos a Comprobar', @Ruta = '/GastoComprobar', @MenuPadreNombre = N'Egresos No Planificados', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Gastos a Comprobar', @Codigo = '1139';  
EXEC sp_RegistrarEntidad @Grupo = 'nacionalidad', @SubGrupo = 'nacionalidad', @NombreMenu = N'Nacionalidad', @Ruta = '/RH_Nacionalidad', @MenuPadreNombre = N'Generales', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Nacionalidad', @Codigo = '2002';  
EXEC sp_RegistrarEntidad @Grupo = 'credencial', @SubGrupo = 'credencial', @NombreMenu = N'Credencial', @Ruta = '/RH_Credencial', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Credencial', @Codigo = '2010';  
EXEC sp_RegistrarEntidad @Grupo = 'clasificador-de-ingreso', @SubGrupo = 'clasificador-de-ingreso', @NombreMenu = N'Clasificador de Ingreso', @Ruta = '/RH_ClasificadorIngreso', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Clasificador de Ingreso', @Codigo = '2027';  
EXEC sp_RegistrarEntidad @Grupo = 'clase-de-movimientos', @SubGrupo = 'clase-de-movimientos', @NombreMenu = N'Clase de Movimientos', @Ruta = '/RH_ClaseMovto', @MenuPadreNombre = N'Movimientos de Personal', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Clase de Movimientos', @Codigo = '2046';  
EXEC sp_RegistrarEntidad @Grupo = 'dias-de-licencia-por-antiguedad', @SubGrupo = 'dias-de-licencia-por-antiguedad', @NombreMenu = N'Dias de licencia por antiguedad', @Ruta = '/RH_PeriodoLicencia', @MenuPadreNombre = N'Licencias Medicas', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Dias de licencia por antiguedad', @Codigo = '2055';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-contrato', @SubGrupo = 'tipo-contrato', @NombreMenu = N'Tipo Contrato', @Ruta = '/NO_TipoContrato', @MenuPadreNombre = N'Generales', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Tipo Contrato', @Codigo = '2077';  
EXEC sp_RegistrarEntidad @Grupo = 'i.s.p.t.-mensual', @SubGrupo = 'i.s.p.t.-mensual', @NombreMenu = N'I.S.P.T. Mensual', @Ruta = '/NO_ISPTMensual', @MenuPadreNombre = N'Parametrización Genérica', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'I.S.P.T. Mensual', @Codigo = '2080';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-por-objeto-del-gasto', @SubGrupo = 'concepto-por-objeto-del-gasto', @NombreMenu = N'Concepto por Objeto del Gasto', @Ruta = '/NO_ConceptoOG', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Concepto por Objeto del Gasto', @Codigo = '2091';  
EXEC sp_RegistrarEntidad @Grupo = 'conceptos-por-centro-de-trabajo-y-puestos', @SubGrupo = 'conceptos-por-centro-de-trabajo-y-puestos', @NombreMenu = N'Conceptos por Centro de Trabajo y Puestos', @Ruta = '/NO_CentroTrabajoPuestoConcepto', @MenuPadreNombre = N'Parametrización por módelo de págo', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Conceptos por Centro de Trabajo y Puestos', @Codigo = '2108';  
EXEC sp_RegistrarEntidad @Grupo = 'empleados-por-concepto-dias', @SubGrupo = 'empleados-por-concepto-dias', @NombreMenu = N'Empleados por Concepto Días', @Ruta = '/NO_ConceptoDias', @MenuPadreNombre = N'Parametrización por Empleado', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Empleados por Concepto Días', @Codigo = '2112';  
EXEC sp_RegistrarEntidad @Grupo = 'dias-de-pago-imss', @SubGrupo = 'dias-de-pago-imss', @NombreMenu = N'Dias de Pago IMSS', @Ruta = '/NO_DiasPagoIMSS', @MenuPadreNombre = N'IMSS', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Dias de Pago IMSS', @Codigo = '2121';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-suficiencia-presupuestal-mp', @SubGrupo = 'autorizacion-suficiencia-presupuestal-mp', @NombreMenu = N'Autorización Suficiencia Presupuestal MP', @Ruta = '/PRESContenedorMultiAutorizacionSuficiencia', @MenuPadreNombre = N'Presupuesto Comprometido Multipartidas', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Autorización Suficiencia Presupuestal MP', @Codigo = '2196';  
EXEC sp_RegistrarEntidad @Grupo = 'cuenta-bancaria', @SubGrupo = 'cuenta-bancaria', @NombreMenu = N'Cuenta Bancaria', @Ruta = '/TESCuentaBancaria', @MenuPadreNombre = N'Inversiones', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Cuenta Bancaria', @Codigo = '2206';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-adecuaciones-compensadas-egre', @SubGrupo = 'autorizacion-adecuaciones-compensadas-egre', @NombreMenu = N'Autorización Adecuaciones Compensadas Egre', @Ruta = '/PRESVW_EgreModMastCompAutorizado', @MenuPadreNombre = N'Presupuesto Modificado de Egresos (Adecuaciones)', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Autorización Adecuaciones Compensadas Egre', @Codigo = '2218';  
EXEC sp_RegistrarEntidad @Grupo = 'funcion', @SubGrupo = 'funcion', @NombreMenu = N'Función', @Ruta = '/PRESFN', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Función', @Codigo = '1005';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-detalles-de-polizas', @SubGrupo = 'tipo-de-detalles-de-polizas', @NombreMenu = N'Tipo de detalles de Pólizas', @Ruta = '/SISTipoDetallePoliza', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Tipo de detalles de Pólizas', @Codigo = '1024';  
EXEC sp_RegistrarEntidad @Grupo = 'ingresos-devengados', @SubGrupo = 'ingresos-devengados', @NombreMenu = N'Ingresos Devengados', @Ruta = '/', @MenuPadreNombre = N'Cuentas por Cobrar', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Ingresos Devengados', @Codigo = 'M024';  
EXEC sp_RegistrarEntidad @Grupo = 'captura-ampliaciones-egre', @SubGrupo = 'captura-ampliaciones-egre', @NombreMenu = N'Captura Ampliaciones Egre', @Ruta = '/PRESAumento', @MenuPadreNombre = N'Presupuesto Modificado de Egresos (Adecuaciones)', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Captura Ampliaciones Egre', @Codigo = '1066';  
EXEC sp_RegistrarEntidad @Grupo = 'registro-de-compromiso-pef', @SubGrupo = 'registro-de-compromiso-pef', @NombreMenu = N'Registro de Compromiso PEF', @Ruta = '/PRESVW_Contrato', @MenuPadreNombre = N'Presupuesto Comprometido Unipartida', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Registro de Compromiso PEF', @Codigo = '1071';  
EXEC sp_RegistrarEntidad @Grupo = 'devoluciones', @SubGrupo = 'devoluciones', @NombreMenu = N'Devoluciones', @Ruta = '/', @MenuPadreNombre = N'Egresos No Planificados', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Devoluciones', @Codigo = 'M031';  
EXEC sp_RegistrarEntidad @Grupo = 'autoriza-/--desautoriza-anteproyecto', @SubGrupo = 'autoriza-/--desautoriza-anteproyecto', @NombreMenu = N'Autoriza /  Desautoriza Anteproyecto', @Ruta = '/PresAutAnteproyecto', @MenuPadreNombre = N'Planeación', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Autoriza /  Desautoriza Anteproyecto', @Codigo = '1145';  
EXEC sp_RegistrarEntidad @Grupo = 'escolaridad', @SubGrupo = 'escolaridad', @NombreMenu = N'Escolaridad', @Ruta = '/RH_Escolaridad', @MenuPadreNombre = N'Generales', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Escolaridad', @Codigo = '2003';  
EXEC sp_RegistrarEntidad @Grupo = 'cuenta-persona', @SubGrupo = 'cuenta-persona', @NombreMenu = N'Cuenta Persona', @Ruta = '/RH_CuentaPersona', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Cuenta Persona', @Codigo = '2011';  
EXEC sp_RegistrarEntidad @Grupo = 'comedor', @SubGrupo = 'comedor', @NombreMenu = N'Comedor', @Ruta = '/RH_Comedor', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Comedor', @Codigo = '2028';  
EXEC sp_RegistrarEntidad @Grupo = 'movimiento', @SubGrupo = 'movimiento', @NombreMenu = N'Movimiento', @Ruta = '/RH_Movimiento', @MenuPadreNombre = N'Movimientos de Personal', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Movimiento', @Codigo = '2047';  
EXEC sp_RegistrarEntidad @Grupo = 'estatus-pago', @SubGrupo = 'estatus-pago', @NombreMenu = N'Estatus Pago', @Ruta = '/No_EstatusPago', @MenuPadreNombre = N'Generales', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Estatus Pago', @Codigo = '2078';  
EXEC sp_RegistrarEntidad @Grupo = 'quincena-de-proceso', @SubGrupo = 'quincena-de-proceso', @NombreMenu = N'Quincena de Proceso', @Ruta = '/NO_Pago', @MenuPadreNombre = N'Parametrización Genérica', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Quincena de Proceso', @Codigo = '2081';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-por-tipo-de-nomina', @SubGrupo = 'concepto-por-tipo-de-nomina', @NombreMenu = N'Concepto por Tipo de Nómina', @Ruta = '/NO_ConceptoTipoNom', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Concepto por Tipo de Nómina', @Codigo = '2092';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-mando', @SubGrupo = 'concepto-mando', @NombreMenu = N'Concepto Mando', @Ruta = '/NO_ConceptoMando', @MenuPadreNombre = N'Parametrización por módelo de págo', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Concepto Mando', @Codigo = '2109';  
EXEC sp_RegistrarEntidad @Grupo = 'quinquenios-y-concepto-de-antigüedad', @SubGrupo = 'quinquenios-y-concepto-de-antigüedad', @NombreMenu = N'Quinquenios y Concepto de Antigüedad', @Ruta = '/NO_ConceptoAntiguedad', @MenuPadreNombre = N'Parametrización por Empleado', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Quinquenios y Concepto de Antigüedad', @Codigo = '2113';  
EXEC sp_RegistrarEntidad @Grupo = 'registro-de-compromiso-mp', @SubGrupo = 'registro-de-compromiso-mp', @NombreMenu = N'Registro de Compromiso MP', @Ruta = '/PRESContenedorMultiContrato', @MenuPadreNombre = N'Presupuesto Comprometido Multipartidas', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Registro de Compromiso MP', @Codigo = '2195';  
EXEC sp_RegistrarEntidad @Grupo = 'saldos-cuentas', @SubGrupo = 'saldos-cuentas', @NombreMenu = N'Saldos Cuentas', @Ruta = '/TESSaldosCuenta', @MenuPadreNombre = N'Inversiones', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Saldos Cuentas', @Codigo = '2207';  
EXEC sp_RegistrarEntidad @Grupo = 'subfuncion', @SubGrupo = 'subfuncion', @NombreMenu = N'SubFunción', @Ruta = '/PRESSF', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'SubFunción', @Codigo = '1006';  
EXEC sp_RegistrarEntidad @Grupo = 'matriz-de-conversion', @SubGrupo = 'matriz-de-conversion', @NombreMenu = N'Matriz de Conversión', @Ruta = '/CONTAMatrizConversion', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Matriz de Conversión', @Codigo = '1025';  
EXEC sp_RegistrarEntidad @Grupo = 'ingresos-por-recaudar', @SubGrupo = 'ingresos-por-recaudar', @NombreMenu = N'Ingresos por Recaudar', @Ruta = '/PRESVW_IngreXEjer', @MenuPadreNombre = N'Cuentas por Cobrar', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Ingresos por Recaudar', @Codigo = '1061';  
EXEC sp_RegistrarEntidad @Grupo = 'caja-chica', @SubGrupo = 'caja-chica', @NombreMenu = N'Caja Chica', @Ruta = '/CajaChica', @MenuPadreNombre = N'Egresos No Planificados', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Caja Chica', @Codigo = '1141';  
EXEC sp_RegistrarEntidad @Grupo = 'parentesco', @SubGrupo = 'parentesco', @NombreMenu = N'Parentesco', @Ruta = '/RH_Parentesco', @MenuPadreNombre = N'Generales', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Parentesco', @Codigo = '2004';  
EXEC sp_RegistrarEntidad @Grupo = 'datos-cedula-registro', @SubGrupo = 'datos-cedula-registro', @NombreMenu = N'Datos Cedula Registro', @Ruta = '/RH_DAtosCedulaRegistro', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Datos Cedula Registro', @Codigo = '2012';  
EXEC sp_RegistrarEntidad @Grupo = 'escala-salarial', @SubGrupo = 'escala-salarial', @NombreMenu = N'Escala Salarial', @Ruta = '/RH_EscalaSalarial', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Escala Salarial', @Codigo = '2029';  
EXEC sp_RegistrarEntidad @Grupo = 'motivo-de-movimiento', @SubGrupo = 'motivo-de-movimiento', @NombreMenu = N'Motivo de Movimiento', @Ruta = '/RH_MotivoMovto', @MenuPadreNombre = N'Movimientos de Personal', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Motivo de Movimiento', @Codigo = '2048';  
EXEC sp_RegistrarEntidad @Grupo = 'salario-minimo-zona-geografica', @SubGrupo = 'salario-minimo-zona-geografica', @NombreMenu = N'Salario Mínimo Zona Geográfica', @Ruta = '/NO_SalarioMinimoZonaGeografica', @MenuPadreNombre = N'Parametrización Genérica', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Salario Mínimo Zona Geográfica', @Codigo = '2082';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-por-periodicidad', @SubGrupo = 'concepto-por-periodicidad', @NombreMenu = N'Concepto por Periodicidad', @Ruta = '/NO_ConceptoPeriodicidad', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Concepto por Periodicidad', @Codigo = '2093';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-nombramiento', @SubGrupo = 'concepto-nombramiento', @NombreMenu = N'Concepto Nombramiento', @Ruta = '/NO_ConceptoNombramiento', @MenuPadreNombre = N'Parametrización por módelo de págo', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Concepto Nombramiento', @Codigo = '2110';  
EXEC sp_RegistrarEntidad @Grupo = 'inasistencias-por-empleado', @SubGrupo = 'inasistencias-por-empleado', @NombreMenu = N'Inasistencias por Empleado', @Ruta = '/NO_PersonaInasistencia', @MenuPadreNombre = N'Parametrización por Empleado', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Inasistencias por Empleado', @Codigo = '2114';  
EXEC sp_RegistrarEntidad @Grupo = 'intermediarios-financieros', @SubGrupo = 'intermediarios-financieros', @NombreMenu = N'Intermediarios Financieros', @Ruta = '/TESIntermediarioFinanciero', @MenuPadreNombre = N'Inversiones', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Intermediarios Financieros', @Codigo = '2208';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-ampliaciones-egre', @SubGrupo = 'autorizacion-ampliaciones-egre', @NombreMenu = N'Autorización Ampliaciones Egre', @Ruta = '/PRESAumentoAutorizado', @MenuPadreNombre = N'Presupuesto Modificado de Egresos (Adecuaciones)', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Autorización Ampliaciones Egre', @Codigo = '2219';  
EXEC sp_RegistrarEntidad @Grupo = 'actividad-institucional', @SubGrupo = 'actividad-institucional', @NombreMenu = N'Actividad Institucional', @Ruta = '/SISActividadInstitucional', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Actividad Institucional', @Codigo = '1007';  
EXEC sp_RegistrarEntidad @Grupo = 'matriz-de-conversion-para-ingresos', @SubGrupo = 'matriz-de-conversion-para-ingresos', @NombreMenu = N'Matriz de Conversión para Ingresos', @Ruta = '/CONTAMatrizIngreso', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Matriz de Conversión para Ingresos', @Codigo = '1026';  
EXEC sp_RegistrarEntidad @Grupo = 'depositos-clc', @SubGrupo = 'depositos-clc', @NombreMenu = N'Depósitos CLC', @Ruta = '/PRESDeposito', @MenuPadreNombre = N'Cuentas por Cobrar', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Depósitos CLC', @Codigo = '1062';  
EXEC sp_RegistrarEntidad @Grupo = 'captura-reducciones-egre', @SubGrupo = 'captura-reducciones-egre', @NombreMenu = N'Captura Reducciones Egre', @Ruta = '/PRESAdecuacion', @MenuPadreNombre = N'Presupuesto Modificado de Egresos (Adecuaciones)', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Captura Reducciones Egre', @Codigo = '1067';  
EXEC sp_RegistrarEntidad @Grupo = 'universo', @SubGrupo = 'universo', @NombreMenu = N'Universo', @Ruta = '/RH_TipoPuesto', @MenuPadreNombre = N'Generales', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Universo', @Codigo = '2005';  
EXEC sp_RegistrarEntidad @Grupo = 'dependencia', @SubGrupo = 'dependencia', @NombreMenu = N'Dependencia', @Ruta = '/RH_Dependencia', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Dependencia', @Codigo = '2013';  
EXEC sp_RegistrarEntidad @Grupo = 'grupo-puesto', @SubGrupo = 'grupo-puesto', @NombreMenu = N'Grupo Puesto', @Ruta = '/RH_GrupoPuesto', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Grupo Puesto', @Codigo = '2030';  
EXEC sp_RegistrarEntidad @Grupo = 'parametrizacion-empleado', @SubGrupo = 'parametrizacion-empleado', @NombreMenu = N'Parametrización Empleado', @Ruta = '/RH_ParametrizacionPersona', @MenuPadreNombre = N'Movimientos de Personal', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Parametrización Empleado', @Codigo = '2049';  
EXEC sp_RegistrarEntidad @Grupo = 'salario-minimo', @SubGrupo = 'salario-minimo', @NombreMenu = N'Salario Mínimo', @Ruta = '/NO_SalarioMinimo', @MenuPadreNombre = N'Parametrización Genérica', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Salario Mínimo', @Codigo = '2083';  
EXEC sp_RegistrarEntidad @Grupo = 'objeto-del-gasto', @SubGrupo = 'objeto-del-gasto', @NombreMenu = N'Objeto del Gasto', @Ruta = '/NO_ObjetoGasto', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Objeto del Gasto', @Codigo = '2094';  
EXEC sp_RegistrarEntidad @Grupo = 'pagos-adicionales', @SubGrupo = 'pagos-adicionales', @NombreMenu = N'Pagos Adicionales', @Ruta = '/NO_PagoAdicional', @MenuPadreNombre = N'Parametrización por Empleado', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Pagos Adicionales', @Codigo = '2115';  
EXEC sp_RegistrarEntidad @Grupo = 'pef-unipartida-tes', @SubGrupo = 'pef-unipartida-tes', @NombreMenu = N'PEF Unipartida TES', @Ruta = '/', @MenuPadreNombre = N'Cuentas por Pagar', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'PEF Unipartida TES', @Codigo = 'M240';  
EXEC sp_RegistrarEntidad @Grupo = 'instrumentos-de-inversion', @SubGrupo = 'instrumentos-de-inversion', @NombreMenu = N'Instrumentos de Inversión', @Ruta = '/TESInstrumento', @MenuPadreNombre = N'Inversiones', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Instrumentos de Inversión', @Codigo = '2209';  
EXEC sp_RegistrarEntidad @Grupo = 'eje', @SubGrupo = 'eje', @NombreMenu = N'Eje', @Ruta = '/PRESEje', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Eje', @Codigo = '1008';  
EXEC sp_RegistrarEntidad @Grupo = 'partidas-presupuestales', @SubGrupo = 'partidas-presupuestales', @NombreMenu = N'Partidas Presupuestales', @Ruta = '/PRESVW_PARTIDAS', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Partidas Presupuestales', @Codigo = '1027';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-carrera', @SubGrupo = 'tipo-de-carrera', @NombreMenu = N'Tipo de Carrera', @Ruta = '/RH_TipoCarrera', @MenuPadreNombre = N'Generales', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Tipo de Carrera', @Codigo = '2006';  
EXEC sp_RegistrarEntidad @Grupo = 'dias-derecho-empleado', @SubGrupo = 'dias-derecho-empleado', @NombreMenu = N'Dias Derecho Empleado', @Ruta = '/RH_DiasDerecho', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Dias Derecho Empleado', @Codigo = '2014';  
EXEC sp_RegistrarEntidad @Grupo = 'rama', @SubGrupo = 'rama', @NombreMenu = N'Rama', @Ruta = '/RH_Rama', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Rama', @Codigo = '2031';  
EXEC sp_RegistrarEntidad @Grupo = 'situacion-empleado', @SubGrupo = 'situacion-empleado', @NombreMenu = N'Situación Empleado', @Ruta = '/RH_SituacionPersona', @MenuPadreNombre = N'Movimientos de Personal', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Situación Empleado', @Codigo = '2050';  
EXEC sp_RegistrarEntidad @Grupo = 'reportes', @SubGrupo = 'reportes', @NombreMenu = N'Reportes', @Ruta = '/ErrConf', @MenuPadreNombre = N'Captura de Movimientos Plazas', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Reportes', @Codigo = '2062';  
EXEC sp_RegistrarEntidad @Grupo = 'subsidio', @SubGrupo = 'subsidio', @NombreMenu = N'Subsidio', @Ruta = '/NO_Subsidio', @MenuPadreNombre = N'Parametrización Genérica', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Subsidio', @Codigo = '2084';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-calculo', @SubGrupo = 'concepto-calculo', @NombreMenu = N'Concepto Cálculo', @Ruta = '/NO_ConceptoCalculo', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Concepto Cálculo', @Codigo = '2095';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-variable-de-pago', @SubGrupo = 'concepto-variable-de-pago', @NombreMenu = N'Concepto Variable de Pago', @Ruta = '/NO_VariableConcepto', @MenuPadreNombre = N'Parametrización por Empleado', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Concepto Variable de Pago', @Codigo = '2116';  
EXEC sp_RegistrarEntidad @Grupo = 'otros-ingresos', @SubGrupo = 'otros-ingresos', @NombreMenu = N'Otros Ingresos', @Ruta = '/IngreIntereses', @MenuPadreNombre = N'Cuentas por Cobrar', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Otros Ingresos', @Codigo = '1149';  
EXEC sp_RegistrarEntidad @Grupo = 'estatus-de-cheques', @SubGrupo = 'estatus-de-cheques', @NombreMenu = N'Estatus de cheques', @Ruta = '/ErrConf', @MenuPadreNombre = N'Cuentas por Pagar', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Estatus de cheques', @Codigo = '2173';  
EXEC sp_RegistrarEntidad @Grupo = 'pef-multipartidas-tes', @SubGrupo = 'pef-multipartidas-tes', @NombreMenu = N'PEF Multipartidas TES', @Ruta = '/', @MenuPadreNombre = N'Cuentas por Pagar', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'PEF Multipartidas TES', @Codigo = 'M229';  
EXEC sp_RegistrarEntidad @Grupo = 'listado-de-inversiones', @SubGrupo = 'listado-de-inversiones', @NombreMenu = N'Listado de Inversiones', @Ruta = '/TESVW_Inversiones', @MenuPadreNombre = N'Inversiones', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Listado de Inversiones', @Codigo = '2210';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-reducciones-egre', @SubGrupo = 'autorizacion-reducciones-egre', @NombreMenu = N'Autorización Reducciones Egre', @Ruta = '/PRESAdecuacionAutorizado', @MenuPadreNombre = N'Presupuesto Modificado de Egresos (Adecuaciones)', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Autorización Reducciones Egre', @Codigo = '2220';  
EXEC sp_RegistrarEntidad @Grupo = 'subeje', @SubGrupo = 'subeje', @NombreMenu = N'SubEje', @Ruta = '/PRESSubEje', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'SubEje', @Codigo = '1009';  
EXEC sp_RegistrarEntidad @Grupo = 'cuentas-contables', @SubGrupo = 'cuentas-contables', @NombreMenu = N'Cuentas Contables', @Ruta = '/SISCuentaContable', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Cuentas Contables', @Codigo = '1028';  
EXEC sp_RegistrarEntidad @Grupo = 'opcion-de-jubilacion', @SubGrupo = 'opcion-de-jubilacion', @NombreMenu = N'Opción de Jubilación', @Ruta = '/RH_OpcionJubilacion', @MenuPadreNombre = N'Generales', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Opción de Jubilación', @Codigo = '2007';  
EXEC sp_RegistrarEntidad @Grupo = 'dias-economicos-anuales', @SubGrupo = 'dias-economicos-anuales', @NombreMenu = N'Dias Economicos Anuales', @Ruta = '/RH_DiasEconomicos', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Dias Economicos Anuales', @Codigo = '2015';  
EXEC sp_RegistrarEntidad @Grupo = 'puesto-valido', @SubGrupo = 'puesto-valido', @NombreMenu = N'Puesto Valido', @Ruta = '/RH_PuestoValido', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Puesto Valido', @Codigo = '2032';  
EXEC sp_RegistrarEntidad @Grupo = 'parametrizacion-plaza', @SubGrupo = 'parametrizacion-plaza', @NombreMenu = N'Parametrización Plaza', @Ruta = '/RH_ParametrizacionPlaza', @MenuPadreNombre = N'Movimientos de Personal', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Parametrización Plaza', @Codigo = '2051';  
EXEC sp_RegistrarEntidad @Grupo = 'aplicar-movimientos-de-plaza', @SubGrupo = 'aplicar-movimientos-de-plaza', @NombreMenu = N'Aplicar Movimientos de Plaza', @Ruta = '/ErrConf', @MenuPadreNombre = N'Captura de Movimientos Plazas', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Aplicar Movimientos de Plaza', @Codigo = '2063';  
EXEC sp_RegistrarEntidad @Grupo = 'tabla-reversa', @SubGrupo = 'tabla-reversa', @NombreMenu = N'Tabla Reversa', @Ruta = '/NO_TablaReversa', @MenuPadreNombre = N'Parametrización Genérica', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Tabla Reversa', @Codigo = '2085';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-dias', @SubGrupo = 'concepto-dias', @NombreMenu = N'Concepto Dias', @Ruta = '/NO_ConceptoDias', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Concepto Dias', @Codigo = '2096';  
EXEC sp_RegistrarEntidad @Grupo = 'notas-buenas', @SubGrupo = 'notas-buenas', @NombreMenu = N'Notas Buenas', @Ruta = '/NO_ConceptoPersona', @MenuPadreNombre = N'Parametrización por Empleado', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Notas Buenas', @Codigo = '2117';  
EXEC sp_RegistrarEntidad @Grupo = 'otros-depositos', @SubGrupo = 'otros-depositos', @NombreMenu = N'Otros depósitos', @Ruta = '/ErrConf', @MenuPadreNombre = N'Cuentas por Cobrar', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Otros depósitos', @Codigo = '2168';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-instrumentos', @SubGrupo = 'tipo-de-instrumentos', @NombreMenu = N'Tipo de Instrumentos', @Ruta = '/', @MenuPadreNombre = N'Inversiones', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Tipo de Instrumentos', @Codigo = '2211';  
EXEC sp_RegistrarEntidad @Grupo = 'carga-masiva-adecuaciones', @SubGrupo = 'carga-masiva-adecuaciones', @NombreMenu = N'Carga masiva adecuaciones', @Ruta = '/NOMIAdecuacionesMasivas', @MenuPadreNombre = N'Presupuesto Modificado de Egresos (Adecuaciones)', @Icono = 'FaRegSun', @Orden = 7, @Descripcion = N'Carga masiva adecuaciones', @Codigo = '2217';  
EXEC sp_RegistrarEntidad @Grupo = 'reportes-cxc', @SubGrupo = 'reportes-cxc', @NombreMenu = N'Reportes CxC', @Ruta = '/', @MenuPadreNombre = N'Cuentas por Cobrar', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Reportes CxC', @Codigo = 'M007';  
EXEC sp_RegistrarEntidad @Grupo = 'subsubeje', @SubGrupo = 'subsubeje', @NombreMenu = N'SubSubEje', @Ruta = '/PRESSubSubEje', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'SubSubEje', @Codigo = '1010';  
EXEC sp_RegistrarEntidad @Grupo = 'formas-de-pago', @SubGrupo = 'formas-de-pago', @NombreMenu = N'Formas de Pago', @Ruta = '/CONTATipoDoctoPago', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Formas de Pago', @Codigo = '1142';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-documentos', @SubGrupo = 'tipo-de-documentos', @NombreMenu = N'Tipo de Documentos', @Ruta = '/RH_TipoDocumento', @MenuPadreNombre = N'Generales', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Tipo de Documentos', @Codigo = '2008';  
EXEC sp_RegistrarEntidad @Grupo = 'dias-laborados-empleado', @SubGrupo = 'dias-laborados-empleado', @NombreMenu = N'Dias Laborados Empleado', @Ruta = '/RH_DiasLaborados', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Dias Laborados Empleado', @Codigo = '2016';  
EXEC sp_RegistrarEntidad @Grupo = 'puesto-alternativo', @SubGrupo = 'puesto-alternativo', @NombreMenu = N'Puesto Alternativo', @Ruta = '/RH_PuestoAlternativo', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Puesto Alternativo', @Codigo = '2033';  
EXEC sp_RegistrarEntidad @Grupo = 'situacion-movimiento', @SubGrupo = 'situacion-movimiento', @NombreMenu = N'Situación movimiento', @Ruta = '/RH_SituacionMovimiento', @MenuPadreNombre = N'Movimientos de Personal', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Situación movimiento', @Codigo = '2052';  
EXEC sp_RegistrarEntidad @Grupo = 'consultas', @SubGrupo = 'consultas', @NombreMenu = N'Consultas', @Ruta = '/ErrConf', @MenuPadreNombre = N'Captura de Movimientos Plazas', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Consultas', @Codigo = '2064';  
EXEC sp_RegistrarEntidad @Grupo = 'calculo', @SubGrupo = 'calculo', @NombreMenu = N'Cálculo', @Ruta = '/NO_Calculo', @MenuPadreNombre = N'Parametrización Genérica', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Cálculo', @Codigo = '2086';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-factor', @SubGrupo = 'concepto-factor', @NombreMenu = N'Concepto Factor', @Ruta = '/NO_ConceptoFactor', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Concepto Factor', @Codigo = '2097';  
EXEC sp_RegistrarEntidad @Grupo = 'empleado-del-mes', @SubGrupo = 'empleado-del-mes', @NombreMenu = N'Empleado del Mes', @Ruta = '/NO_VariableConceptoEM', @MenuPadreNombre = N'Parametrización por Empleado', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Empleado del Mes', @Codigo = '2118';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-plazos', @SubGrupo = 'tipo-de-plazos', @NombreMenu = N'Tipo de Plazos', @Ruta = '/TESTipoPlazo', @MenuPadreNombre = N'Inversiones', @Icono = 'FaRegSun', @Orden = 8, @Descripcion = N'Tipo de Plazos', @Codigo = '2212';  
EXEC sp_RegistrarEntidad @Grupo = 'programa-presupuestal', @SubGrupo = 'programa-presupuestal', @NombreMenu = N'Programa Presupuestal', @Ruta = '/PRESPP', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Programa Presupuestal', @Codigo = '1011';  
EXEC sp_RegistrarEntidad @Grupo = 'dias-no-habiles', @SubGrupo = 'dias-no-habiles', @NombreMenu = N'Dias no habiles', @Ruta = '/RH_DiasNoHabiles', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Dias no habiles', @Codigo = '2017';  
EXEC sp_RegistrarEntidad @Grupo = 'puesto', @SubGrupo = 'puesto', @NombreMenu = N'Puesto', @Ruta = '/RH_Puesto', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Puesto', @Codigo = '2034';  
EXEC sp_RegistrarEntidad @Grupo = 'consecutivo-movimiento-personal', @SubGrupo = 'consecutivo-movimiento-personal', @NombreMenu = N'Consecutivo Movimiento Personal', @Ruta = '/RH_ConsecutivoMovimientoPersonal', @MenuPadreNombre = N'Movimientos de Personal', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Consecutivo Movimiento Personal', @Codigo = '2053';  
EXEC sp_RegistrarEntidad @Grupo = 'tipos-de-nomina', @SubGrupo = 'tipos-de-nomina', @NombreMenu = N'Tipos de Nómina', @Ruta = '/NO_TipoNomina', @MenuPadreNombre = N'Parametrización Genérica', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Tipos de Nómina', @Codigo = '2087';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-importe', @SubGrupo = 'concepto-importe', @NombreMenu = N'Concepto Importe', @Ruta = '/NO_ConceptoImporte', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Concepto Importe', @Codigo = '2098';  
EXEC sp_RegistrarEntidad @Grupo = 'reintegro-inasistencias', @SubGrupo = 'reintegro-inasistencias', @NombreMenu = N'Reintegro Inasistencias', @Ruta = '/NO_PersonaInasistenciaRI', @MenuPadreNombre = N'Parametrización por Empleado', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Reintegro Inasistencias', @Codigo = '2119';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-retiro', @SubGrupo = 'tipo-de-retiro', @NombreMenu = N'Tipo de Retiro', @Ruta = '/TESTipoRetiro', @MenuPadreNombre = N'Inversiones', @Icono = 'FaRegSun', @Orden = 9, @Descripcion = N'Tipo de Retiro', @Codigo = '2213';  
EXEC sp_RegistrarEntidad @Grupo = 'vertiente-de-gasto', @SubGrupo = 'vertiente-de-gasto', @NombreMenu = N'Vertiente de Gasto', @Ruta = '/PRESVertienteGasto', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Vertiente de Gasto', @Codigo = '1012';  
EXEC sp_RegistrarEntidad @Grupo = 'dias-reales-vacaciones-empleado', @SubGrupo = 'dias-reales-vacaciones-empleado', @NombreMenu = N'Dias reales vacaciones empleado', @Ruta = '/RH_DiasRealesVacaciones', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Dias reales vacaciones empleado', @Codigo = '2018';  
EXEC sp_RegistrarEntidad @Grupo = 'radicacion-del-pago', @SubGrupo = 'radicacion-del-pago', @NombreMenu = N'Radicación del Pago', @Ruta = '/RH_RadicacionPago', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Radicación del Pago', @Codigo = '2035';  
EXEC sp_RegistrarEntidad @Grupo = 'referencia-tipo-nomina', @SubGrupo = 'referencia-tipo-nomina', @NombreMenu = N'Referencia tipo Nómina', @Ruta = '/NO_ReferenciaTipoNomina', @MenuPadreNombre = N'Parametrización Genérica', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Referencia tipo Nómina', @Codigo = '2088';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-periodo', @SubGrupo = 'concepto-periodo', @NombreMenu = N'Concepto Periodo', @Ruta = '/NO_ConceptoPeriodo', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Concepto Periodo', @Codigo = '2099';  
EXEC sp_RegistrarEntidad @Grupo = 'simulador', @SubGrupo = 'simulador', @NombreMenu = N'Simulador', @Ruta = '/TESInversionSimulada', @MenuPadreNombre = N'Inversiones', @Icono = 'FaRegSun', @Orden = 10, @Descripcion = N'Simulador', @Codigo = '2214';  
EXEC sp_RegistrarEntidad @Grupo = 'resultado', @SubGrupo = 'resultado', @NombreMenu = N'Resultado', @Ruta = '/PRESResultado', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Resultado', @Codigo = '1013';  
EXEC sp_RegistrarEntidad @Grupo = 'dias-economicos-empleado', @SubGrupo = 'dias-economicos-empleado', @NombreMenu = N'Dias Económicos Empleado', @Ruta = '/RH_DiasEconomicos', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Dias Económicos Empleado', @Codigo = '2019';  
EXEC sp_RegistrarEntidad @Grupo = 'horarios', @SubGrupo = 'horarios', @NombreMenu = N'Horarios', @Ruta = '/RH_Horario', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Horarios', @Codigo = '2036';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-pago', @SubGrupo = 'tipo-de-pago', @NombreMenu = N'Tipo de Pago', @Ruta = '/NO_TipoPago', @MenuPadreNombre = N'Parametrización Genérica', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Tipo de Pago', @Codigo = '2089';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-equivalencia', @SubGrupo = 'concepto-equivalencia', @NombreMenu = N'Concepto Equivalencia', @Ruta = '/NO_ConceptoEquivalencia', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Concepto Equivalencia', @Codigo = '2100';  
EXEC sp_RegistrarEntidad @Grupo = 'sigevi-partidas', @SubGrupo = 'sigevi-partidas', @NombreMenu = N'Sigevi Partidas', @Ruta = '/SIGEVIPartidas', @MenuPadreNombre = N'Contabilidad', @Icono = 'FaRegSun', @Orden = 11, @Descripcion = N'Sigevi Partidas', @Codigo = '2180';  
EXEC sp_RegistrarEntidad @Grupo = 'subresultado', @SubGrupo = 'subresultado', @NombreMenu = N'Subresultado', @Ruta = '/PRESSubresultado', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 12, @Descripcion = N'Subresultado', @Codigo = '1014';  
EXEC sp_RegistrarEntidad @Grupo = 'fecha-ingreso-empleado', @SubGrupo = 'fecha-ingreso-empleado', @NombreMenu = N'Fecha Ingreso Empleado', @Ruta = '/RH_FechasIngreso', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 12, @Descripcion = N'Fecha Ingreso Empleado', @Codigo = '2020';  
EXEC sp_RegistrarEntidad @Grupo = 'mandos', @SubGrupo = 'mandos', @NombreMenu = N'Mandos', @Ruta = '/RH_Mando', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 12, @Descripcion = N'Mandos', @Codigo = '2037';  
EXEC sp_RegistrarEntidad @Grupo = 'puesto-quincena', @SubGrupo = 'puesto-quincena', @NombreMenu = N'Puesto Quincena', @Ruta = '/NO_PuestoQuicena', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 12, @Descripcion = N'Puesto Quincena', @Codigo = '2101';  
EXEC sp_RegistrarEntidad @Grupo = 'presupuesto-reservado', @SubGrupo = 'presupuesto-reservado', @NombreMenu = N'Presupuesto Reservado', @Ruta = '/SIGEVIPresupuestoReservado', @MenuPadreNombre = N'SIGEVI', @Icono = 'FaRegSun', @Orden = 12, @Descripcion = N'Presupuesto Reservado', @Codigo = '2181';  
EXEC sp_RegistrarEntidad @Grupo = 'años', @SubGrupo = 'años', @NombreMenu = N'Años', @Ruta = '/SISAnio', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 13, @Descripcion = N'Años', @Codigo = '1015';  
EXEC sp_RegistrarEntidad @Grupo = 'fecha-vacaciones-empleado', @SubGrupo = 'fecha-vacaciones-empleado', @NombreMenu = N'Fecha Vacaciones Empleado', @Ruta = '/RH_EmpFechaVacSemes', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 13, @Descripcion = N'Fecha Vacaciones Empleado', @Codigo = '2021';  
EXEC sp_RegistrarEntidad @Grupo = 'nombramientos', @SubGrupo = 'nombramientos', @NombreMenu = N'Nombramientos', @Ruta = '/RH_Nombramiento', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 13, @Descripcion = N'Nombramientos', @Codigo = '2038';  
EXEC sp_RegistrarEntidad @Grupo = 'referencia-concepto', @SubGrupo = 'referencia-concepto', @NombreMenu = N'Referencia Concepto', @Ruta = '/NO_ReferenciaConcepto', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 13, @Descripcion = N'Referencia Concepto', @Codigo = '2102';  
EXEC sp_RegistrarEntidad @Grupo = 'presupuesto-disponible-sig', @SubGrupo = 'presupuesto-disponible-sig', @NombreMenu = N'Presupuesto Disponible SIG', @Ruta = '/SIGEVIPresupuestoDisponible', @MenuPadreNombre = N'SIGEVI', @Icono = 'FaRegSun', @Orden = 13, @Descripcion = N'Presupuesto Disponible SIG', @Codigo = '2182';  
EXEC sp_RegistrarEntidad @Grupo = 'sector', @SubGrupo = 'sector', @NombreMenu = N'Sector', @Ruta = '/PRESSector', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 14, @Descripcion = N'Sector', @Codigo = '1016';  
EXEC sp_RegistrarEntidad @Grupo = 'fecha-vacaciones-semestre-empleado', @SubGrupo = 'fecha-vacaciones-semestre-empleado', @NombreMenu = N'Fecha Vacaciones Semestre Empleado', @Ruta = '/RH_EmpFechaVacSemes', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 14, @Descripcion = N'Fecha Vacaciones Semestre Empleado', @Codigo = '2022';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-direccion', @SubGrupo = 'tipo-direccion', @NombreMenu = N'Tipo Dirección', @Ruta = '/RH_TipoDireccion', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 14, @Descripcion = N'Tipo Dirección', @Codigo = '2039';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-digito-sindical', @SubGrupo = 'concepto-digito-sindical', @NombreMenu = N'Concepto Dígito Sindical', @Ruta = '/NO_ConceptoDigSind', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 14, @Descripcion = N'Concepto Dígito Sindical', @Codigo = '2103';  
EXEC sp_RegistrarEntidad @Grupo = 'cuentas-por-liquidar', @SubGrupo = 'cuentas-por-liquidar', @NombreMenu = N'Cuentas por Liquidar', @Ruta = '/SIGEVIVW_CXL', @MenuPadreNombre = N'SIGEVI', @Icono = 'FaRegSun', @Orden = 14, @Descripcion = N'Cuentas por Liquidar', @Codigo = '-   ';  
EXEC sp_RegistrarEntidad @Grupo = 'subsector', @SubGrupo = 'subsector', @NombreMenu = N'SubSector', @Ruta = '/PRESSubSector', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 15, @Descripcion = N'SubSector', @Codigo = '1017';  
EXEC sp_RegistrarEntidad @Grupo = 'tarjeta-observaciones-empleado', @SubGrupo = 'tarjeta-observaciones-empleado', @NombreMenu = N'Tarjeta Observaciones Empleado', @Ruta = '/RH_EmpleadoTarjetaObservaciones', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 15, @Descripcion = N'Tarjeta Observaciones Empleado', @Codigo = '2023';  
EXEC sp_RegistrarEntidad @Grupo = 'turno', @SubGrupo = 'turno', @NombreMenu = N'Turno', @Ruta = '/RH_Turno', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 15, @Descripcion = N'Turno', @Codigo = '2040';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-presupuesto', @SubGrupo = 'concepto-presupuesto', @NombreMenu = N'Concepto Presupuesto', @Ruta = '/NO_ConceptoPresupuesto', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 15, @Descripcion = N'Concepto Presupuesto', @Codigo = '2104';  
EXEC sp_RegistrarEntidad @Grupo = 'tipo-de-recurso', @SubGrupo = 'tipo-de-recurso', @NombreMenu = N'Tipo de Recurso', @Ruta = '/PRESTipoRecurso', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 16, @Descripcion = N'Tipo de Recurso', @Codigo = '1018';  
EXEC sp_RegistrarEntidad @Grupo = 'fecha-vacaciones', @SubGrupo = 'fecha-vacaciones', @NombreMenu = N'Fecha Vacaciones', @Ruta = '/RH_FechaVacaciones', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 16, @Descripcion = N'Fecha Vacaciones', @Codigo = '2024';  
EXEC sp_RegistrarEntidad @Grupo = 'empleados-autorizados-para-firmas', @SubGrupo = 'empleados-autorizados-para-firmas', @NombreMenu = N'Empleados Autorizados para firmas', @Ruta = '/RH_PersonaFirma', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 16, @Descripcion = N'Empleados Autorizados para firmas', @Codigo = '2041';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-de-pago', @SubGrupo = 'concepto-de-pago', @NombreMenu = N'Concepto de Pago', @Ruta = '/NO_ConceptoPago', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 16, @Descripcion = N'Concepto de Pago', @Codigo = '2105';  
EXEC sp_RegistrarEntidad @Grupo = 'fuente-de-financiamiento', @SubGrupo = 'fuente-de-financiamiento', @NombreMenu = N'Fuente de Financiamiento', @Ruta = '/PRESFuenteFinanciamiento', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 17, @Descripcion = N'Fuente de Financiamiento', @Codigo = '1019';  
EXEC sp_RegistrarEntidad @Grupo = 'dias-prima-vacacional', @SubGrupo = 'dias-prima-vacacional', @NombreMenu = N'Dias Prima Vacacional', @Ruta = '/RH_DiasPrimaVacacional', @MenuPadreNombre = N'Otros', @Icono = 'FaRegSun', @Orden = 17, @Descripcion = N'Dias Prima Vacacional', @Codigo = '2025';  
EXEC sp_RegistrarEntidad @Grupo = 'concepto-partida', @SubGrupo = 'concepto-partida', @NombreMenu = N'Concepto Partida', @Ruta = '/NO_ConceptoPartida', @MenuPadreNombre = N'Parametrización por Concepto', @Icono = 'FaRegSun', @Orden = 17, @Descripcion = N'Concepto Partida', @Codigo = '2106';  
EXEC sp_RegistrarEntidad @Grupo = 'pg', @SubGrupo = 'pg', @NombreMenu = N'PG', @Ruta = '/PRESPG', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 18, @Descripcion = N'PG', @Codigo = '1020';  
EXEC sp_RegistrarEntidad @Grupo = 'plazas', @SubGrupo = 'plazas', @NombreMenu = N'Plazas', @Ruta = '/RH_Plaza', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 18, @Descripcion = N'Plazas', @Codigo = '2043';  
EXEC sp_RegistrarEntidad @Grupo = 'ramo', @SubGrupo = 'ramo', @NombreMenu = N'Ramo', @Ruta = '/PRESRamo', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 19, @Descripcion = N'Ramo', @Codigo = '1021';  
EXEC sp_RegistrarEntidad @Grupo = 'nivel', @SubGrupo = 'nivel', @NombreMenu = N'Nivel', @Ruta = '/RH_Nivel', @MenuPadreNombre = N'Institución', @Icono = 'FaRegSun', @Orden = 19, @Descripcion = N'Nivel', @Codigo = '2044';  
EXEC sp_RegistrarEntidad @Grupo = 'proyecto', @SubGrupo = 'proyecto', @NombreMenu = N'Proyecto', @Ruta = '/PRESPY', @MenuPadreNombre = N'Clave del Programa', @Icono = 'FaRegSun', @Orden = 20, @Descripcion = N'Proyecto', @Codigo = '1154';  
EXEC sp_RegistrarEntidad @Grupo = 'captura-adecuaciones-compensadas-ing', @SubGrupo = 'captura-adecuaciones-compensadas-ing', @NombreMenu = N'Captura Adecuaciones Compensadas Ing', @Ruta = '/PRESVW_IngreModMastComp', @MenuPadreNombre = N'Presupuesto Modificado de Ingresos(Adecuaciones)', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Captura Adecuaciones Compensadas Ing', @Codigo = '1056';  
EXEC sp_RegistrarEntidad @Grupo = 'ingresos-(clcs)', @SubGrupo = 'ingresos-(clcs)', @NombreMenu = N'Ingresos (CLCs)', @Ruta = '/PRESVW_CLCFactura', @MenuPadreNombre = N'Ingresos Devengados', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Ingresos (CLCs)', @Codigo = '1059';  
EXEC sp_RegistrarEntidad @Grupo = 'recepcion-de-facturas-y-comprobantes-de-pago-pef', @SubGrupo = 'recepcion-de-facturas-y-comprobantes-de-pago-pef', @NombreMenu = N'Recepción de Facturas y Comprobantes de Pago PEF', @Ruta = '/PRESVW_Factura', @MenuPadreNombre = N'PEF Unipartida TES', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Recepción de Facturas y Comprobantes de Pago PEF', @Codigo = '1072';  
EXEC sp_RegistrarEntidad @Grupo = 'provision-del-pago-pef', @SubGrupo = 'provision-del-pago-pef', @NombreMenu = N'Provisión del Pago PEF', @Ruta = '/PRESVW_Clc', @MenuPadreNombre = N'PEF Unipartida TES', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Provisión del Pago PEF', @Codigo = '1073';  
EXEC sp_RegistrarEntidad @Grupo = 'devolucion-de-fondos-revolventes', @SubGrupo = 'devolucion-de-fondos-revolventes', @NombreMenu = N'Devolución de Fondos Revolventes', @Ruta = '/DevolFondoRev', @MenuPadreNombre = N'Devoluciones', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Devolución de Fondos Revolventes', @Codigo = '1140';  
EXEC sp_RegistrarEntidad @Grupo = 'antigüedad-de-saldos', @SubGrupo = 'antigüedad-de-saldos', @NombreMenu = N'Antigüedad de saldos', @Ruta = '/RepAntigSaldosCuPa', @MenuPadreNombre = N'Reportes CxC', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Antigüedad de saldos', @Codigo = '2042';  
EXEC sp_RegistrarEntidad @Grupo = 'recepcion-de-facturas-y-comprobantes-de-pago-mp', @SubGrupo = 'recepcion-de-facturas-y-comprobantes-de-pago-mp', @NombreMenu = N'Recepción de Facturas y Comprobantes de Pago MP', @Ruta = '/PRESContenedorMultiFactura', @MenuPadreNombre = N'PEF Multipartidas TES', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Recepción de Facturas y Comprobantes de Pago MP', @Codigo = '1072';  
EXEC sp_RegistrarEntidad @Grupo = 'indicadores', @SubGrupo = 'indicadores', @NombreMenu = N'Indicadores', @Ruta = '/PBRIndicadores', @MenuPadreNombre = N'Catálogos Planeación', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Indicadores', @Codigo = '2228';  
EXEC sp_RegistrarEntidad @Grupo = 'resúmen-narrativo', @SubGrupo = 'resúmen-narrativo', @NombreMenu = N'Resúmen Narrativo', @Ruta = '/PBRResumenNarrativo', @MenuPadreNombre = N'Catálogos Planeación', @Icono = 'FaRegSun', @Orden = 1, @Descripcion = N'Resúmen Narrativo', @Codigo = '2229';  
EXEC sp_RegistrarEntidad @Grupo = 'ingresos-propios-(recibos-y-facturas)', @SubGrupo = 'ingresos-propios-(recibos-y-facturas)', @NombreMenu = N'Ingresos Propios (Recibos y Facturas)', @Ruta = '/IngreDevCls', @MenuPadreNombre = N'Ingresos Devengados', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Ingresos Propios (Recibos y Facturas)', @Codigo = '1060';  
EXEC sp_RegistrarEntidad @Grupo = 'integracion-de-saldos', @SubGrupo = 'integracion-de-saldos', @NombreMenu = N'Integración de saldos', @Ruta = '/RepInteSaldosCuPa', @MenuPadreNombre = N'Reportes CxC', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Integración de saldos', @Codigo = '2056';  
EXEC sp_RegistrarEntidad @Grupo = 'provision-del-pago-mp', @SubGrupo = 'provision-del-pago-mp', @NombreMenu = N'Provisión del Pago MP', @Ruta = '/PRESContenedorMultiCLC', @MenuPadreNombre = N'PEF Multipartidas TES', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Provisión del Pago MP', @Codigo = '2199';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-adecuaciones-compensadas-ing', @SubGrupo = 'autorizacion-adecuaciones-compensadas-ing', @NombreMenu = N'Autorización Adecuaciones Compensadas Ing', @Ruta = '/PRESVW_IngreModMastCompAutorizado', @MenuPadreNombre = N'Presupuesto Modificado de Ingresos(Adecuaciones)', @Icono = 'FaRegSun', @Orden = 2, @Descripcion = N'Autorización Adecuaciones Compensadas Ing', @Codigo = '2223';  
EXEC sp_RegistrarEntidad @Grupo = 'captura-ampliaciones-ing', @SubGrupo = 'captura-ampliaciones-ing', @NombreMenu = N'Captura Ampliaciones Ing', @Ruta = '/PRESIngresoAumento', @MenuPadreNombre = N'Presupuesto Modificado de Ingresos(Adecuaciones)', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Captura Ampliaciones Ing', @Codigo = '1057';  
EXEC sp_RegistrarEntidad @Grupo = 'elaboracion-de-cheque-o-transferencia-pef', @SubGrupo = 'elaboracion-de-cheque-o-transferencia-pef', @NombreMenu = N'Elaboración de Cheque o transferencia PEF', @Ruta = '/PRESVW_Cheque', @MenuPadreNombre = N'PEF Unipartida TES', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Elaboración de Cheque o transferencia PEF', @Codigo = '1074';  
EXEC sp_RegistrarEntidad @Grupo = 'estado-de-cuenta', @SubGrupo = 'estado-de-cuenta', @NombreMenu = N'Estado de cuenta', @Ruta = '/RepEstatCuentaCuPa', @MenuPadreNombre = N'Reportes CxC', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Estado de cuenta', @Codigo = '2058';  
EXEC sp_RegistrarEntidad @Grupo = 'elaboracion-de-cheque-o-transferencia-mp', @SubGrupo = 'elaboracion-de-cheque-o-transferencia-mp', @NombreMenu = N'Elaboración de Cheque o transferencia MP', @Ruta = '/PRESContenedorMultiCheque', @MenuPadreNombre = N'PEF Multipartidas TES', @Icono = 'FaRegSun', @Orden = 3, @Descripcion = N'Elaboración de Cheque o transferencia MP', @Codigo = '2200';  
EXEC sp_RegistrarEntidad @Grupo = 'analisis-de-saldos', @SubGrupo = 'analisis-de-saldos', @NombreMenu = N'Análisis de saldos', @Ruta = '/RepAnalisSaldosCuPa', @MenuPadreNombre = N'Reportes CxC', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Análisis de saldos', @Codigo = '2059';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-ampliaciones-ing', @SubGrupo = 'autorizacion-ampliaciones-ing', @NombreMenu = N'Autorización Ampliaciones Ing', @Ruta = '/PRESIngresoAumentoAutorizado', @MenuPadreNombre = N'Presupuesto Modificado de Ingresos(Adecuaciones)', @Icono = 'FaRegSun', @Orden = 4, @Descripcion = N'Autorización Ampliaciones Ing', @Codigo = '2224';  
EXEC sp_RegistrarEntidad @Grupo = 'captura-reducciones-ing', @SubGrupo = 'captura-reducciones-ing', @NombreMenu = N'Captura Reducciones Ing', @Ruta = '/PRESIngresoAdecuacion', @MenuPadreNombre = N'Presupuesto Modificado de Ingresos(Adecuaciones)', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Captura Reducciones Ing', @Codigo = '1058';  
EXEC sp_RegistrarEntidad @Grupo = 'consulta-de-documentos', @SubGrupo = 'consulta-de-documentos', @NombreMenu = N'Consulta de documentos', @Ruta = '/ErrConf', @MenuPadreNombre = N'Reportes CxC', @Icono = 'FaRegSun', @Orden = 5, @Descripcion = N'Consulta de documentos', @Codigo = '2060';  
EXEC sp_RegistrarEntidad @Grupo = 'autorizacion-reducciones-ing', @SubGrupo = 'autorizacion-reducciones-ing', @NombreMenu = N'Autorización Reducciones Ing', @Ruta = '/PRESIngresoAdecuacionAutorizado', @MenuPadreNombre = N'Presupuesto Modificado de Ingresos(Adecuaciones)', @Icono = 'FaRegSun', @Orden = 6, @Descripcion = N'Autorización Reducciones Ing', @Codigo = '2225';  



