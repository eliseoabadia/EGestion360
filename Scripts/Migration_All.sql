-- =============================================
-- SCRIPT DE MIGRACIÓN: BD_PRESUPUESTO → GestionEmpresarial
-- Ordenado por dependencias FK
-- =============================================
USE [GestionEmpresarial];
GO

-- =============================================
-- BOOTSTRAP: datos mínimos para FK constraints
-- Las FK de auditoría (UsuarioCreacion) se
-- agregan al final de GP.Sql vía ALTER TABLE.
-- =============================================

-- SIS.Moneda (sin FK)
INSERT INTO SIS.Moneda (Nombre, CodigoISO4217, Simbolo, Decimales)
VALUES ('Peso Mexicano', 'MXN', '$', 2),
('Dólar Estadounidense', 'USD', 'US$', 2);
GO

-- SIS.Idioma (sin FK)
INSERT INTO SIS.Idioma (Nombre, CodigoISO639_1, NombreNativo)
VALUES ('Español', 'es', 'Español'),
('Inglés', 'en', 'English');
GO

-- SIS.Empresa (FK a Moneda/Idioma)
INSERT INTO SIS.Empresa (Nombre, RFC, RazonSocial, FKIdMonedaBase_SIS,Giro, FKIdIdiomaPreferido_SIS, Activo, FechaCreacion)
VALUES ('IFT', 'IFT110101AAA', 'Instituto Federal de Telecomunicaciones','Tecnología', 1, 1, 1, GETDATE());
GO

-- SIS.Usuario (FK a Empresa; UsuarioCreacion vía ALTER al final de GE.Sql)
SET IDENTITY_INSERT SIS.Usuario ON;
INSERT INTO SIS.Usuario (PkIdUsuario, FKIdEmpresa_SIS, AspNetUserId, PayrollID, FKIdIdiomaPreferido_SIS, FKIdMonedaPreferida_SIS, EsAdministrador, Activo, FechaCreacion)
VALUES (1, 1, 'ADMIN SYSTEM', 'ADMIN001', 1, 1, 1, 1, GETDATE());
SET IDENTITY_INSERT SIS.Usuario OFF;
GO


INSERT INTO [dbo].[AspNetRoles] ([Id], [Name], [Code]) VALUES 
('71804e93-9753-4684-84fd-cf037349c111', 'SYSTEMADMIN', '10000'),
('739CC754-488B-4BB4-B7FB-62F6BF3C26D0', 'SOPORTE', '20000'),
('67A6E679-DBC4-402D-AE6E-7F28DDB11BD8', 'CONFIGURATION', '30000');


INSERT INTO dbo.AspNetClaimTypes (Name, Created) VALUES ('Template', GETDATE()), ('Role', GETDATE());

-- Insertar usuarios principal
INSERT INTO [dbo].[AspNetUsers] (
    [Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber],
    [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled],
    [AccessFailedCount], [ReferenceId], [AccessNumber], [PkIdUsuario]
)
VALUES 
    (NEWID(), '', 1, 'UOxg2B7HCZwZZ/drSkwHrA==', 'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, '0000010000', 1)--,
    --(NEWID(), '', 1, 'UOxg2B7HCZwZZ/drSkwHrA==', 'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, '0000010000', 2),
    --(NEWID(), '', 1, 'UOxg2B7HCZwZZ/drSkwHrA==', 'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, '0000010000', 3);

--update [dbo].[AspNetUsers] set [PasswordHash] = 'UOxg2B7HCZwZZ/drSkwHrA=='

INSERT INTO [dbo].[AspNetUserRoles] ([UserId], [RoleId], [ExpireDate])
SELECT [Id], '71804e93-9753-4684-84fd-cf037349c111', '2027-12-31'
FROM [dbo].[AspNetUsers]
WHERE PkIdUsuario  IN (1,2,3);

-- NOM.Persona (mínima para FK de PAAAS y otras tablas)
-- NOM.Persona
SET IDENTITY_INSERT [NOM].[Persona] ON;
INSERT INTO [NOM].[Persona] (
    [PKIdPersona], [Clave], [Nombre], [Paterno], [Materno],
    [Telefono_particular], [Telefono_movil], [Fecha_de_Inicio], [Fecha_Fin],
    [RFC], [Curp], [FechaNacimiento], [Sexo], [ESTADO_CIVIL], [Municipio],
    [REG_IMSS], [NoCartilla], [NoLicencia], [NoPasaporte], [NoCredencialElector],
    [Calle], [Num_exterior], [Num_interior], [Colonia], [CP], [Estado],
    [CORREO_ELECTRONICO], [TIPO_CONTRATACION], [PUESTO], [SUELDO_BASE], [COMPENSACION_GARANTIZADA],
    [BANCO], [NUMERO_CUENTA], [CLABE], [Activo], [FechaCreacion], [UsuarioCreacion]
)
SELECT
    [PK_IdPersona], [Clave], [Nombre], [Paterno], [Materno],
    [Telefono_particular], [Telefono_movil], [Fecha_de_Inicio], [Fecha_Fin],
    [RFC], [Curp], [FechaNacimiento], [Sexo], [ESTADO_CIVIL], [Municipio],
    [REG_IMSS], [NoCartilla], [NoLicencia], [NoPasaporte], [NoCredencialElector],
    [Calle], [Num_exterior], [Num_interior], [Colonia], [CP], [Estado],
    [CORREO_ELECTRONICO], [TIPO_CONTRATACION], [PUESTO], [SUELDO_BASE], [COMPENSACION_GARANTIZADA],
    [BANCO], [NUMERO_CUENTA], [CLABE], [CT_LIVE], [CT_CreatedDate], [CT_CreatedBy]
FROM [BD_PRESUPUESTO].[RHCT].[Persona];
SET IDENTITY_INSERT [NOM].[Persona] OFF;
GO

-- NOM.PersonaArea
SET IDENTITY_INSERT [NOM].[PersonaArea] ON;
INSERT INTO [NOM].[PersonaArea] (
    [PKIdPersonaArea], [FKIdPersona_NOM], [FKIdArea_SIS], [IsAdscrito],
    [EsSolicitante], [EsAutorizador], [Activo], [FechaCreacion], [UsuarioCreacion]
)
SELECT
    [PK_IdPersonaArea], [FK_IdPersona], [FK_IdArea], [IsAdscrito],
    [EsSolicitante], [EsAutorizador], [CT_LIVE], [CT_CreatedDate], 1
FROM [BD_PRESUPUESTO].[RHCT].[PersonaArea];
SET IDENTITY_INSERT [NOM].[PersonaArea] OFF;
GO

-- =============================================
-- SIS (catálogos base sin dependencias externas)
-- =============================================

-- SIS.OrigenLogMessage (INSERT VALUES)
INSERT INTO SIS.OrigenLogMessage (PKIdOrigenLogMessage, Descripcion, UsuarioCreacion) VALUES
(1, 'Sistema', 1),
(2, 'Aplicación', 1),
(3, 'Seguridad', 1),
(4, 'Base de Datos', 1),
(5, 'Red', 1),
(6, 'Hardware', 1),
(7, 'Usuario', 1),
(8, 'Otro', 1);
GO

-- SIS.SystemParamCatalog (INSERT VALUES)
INSERT INTO SIS.SystemParamCatalog (PKIdSystemParamCatalog, Code, Name, Activo, UsuarioCreacion) VALUES
(1, 'SISTEMA', 'SISTEMA', 1, 1),
(2, 'CATALOGOS', 'CATALOGOS', 1, 1);
GO

-- SIS.SystemParamValue (INSERT VALUES)
INSERT INTO SIS.SystemParamValue (PKIdSystemParamValue, FKIdSystemParamCatalog_SIS, Value, Descripcion, Activo, UsuarioCreacion) VALUES
(1, 1, '1', 'Variable que activa o desactiva el poder insertar en la tabla SystemLog', 1, 1);
GO

-- SIS.ActividadInstitucional
SET IDENTITY_INSERT SIS.ActividadInstitucional ON;
INSERT INTO SIS.ActividadInstitucional (PKIdActividadInstitucional, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdActividadInstitucional, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.ActividadInstitucional
WHERE NOT EXISTS (SELECT 1 FROM SIS.ActividadInstitucional WHERE PKIdActividadInstitucional = PK_IdActividadInstitucional);
SET IDENTITY_INSERT SIS.ActividadInstitucional OFF;
GO

-- SIS.Area
SET IDENTITY_INSERT SIS.Area ON;
INSERT INTO SIS.Area (PKIdArea, FKIdArea_SIS, Clave, Nombre, UltimoInv, ZonaEconomica, Direccion, Colonia, CP, Telefono, Aprovado, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdArea, FK_IdArea__SIS, Clave, Nombre, UltimoInv, ZonaEconomica, Direccion, Colonia, CP, Telefono, Aprovado,
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.Area
WHERE NOT EXISTS (SELECT 1 FROM SIS.Area WHERE PKIdArea = PK_IdArea);
SET IDENTITY_INSERT SIS.Area OFF;
GO

-- SIS.Anio
SET IDENTITY_INSERT SIS.Anio ON;
INSERT INTO SIS.Anio (PKIdAnio, Clave, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    a.PK_IdAnio,
    a.Clave,
    ISNULL(a.CT_LIVE, 1),
    ISNULL(a.CT_CreatedDate, GETDATE()),
    ISNULL(a.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.Anio a
WHERE NOT EXISTS (SELECT 1 FROM SIS.Anio d WHERE d.PKIdAnio = a.PK_IdAnio);
SET IDENTITY_INSERT SIS.Anio OFF;
GO

-- SIS.TipoProveedor (INSERT VALUES)
INSERT INTO [SIS].[TipoProveedor] ([Descripcion], [UsuarioCreacion])
VALUES ('Fabricante', 1),
       ('Distribuidor', 1),
       ('MiPyME', 1);
GO

-- SIS.EstatusProveedor (INSERT VALUES)
INSERT INTO [SIS].[EstatusProveedor] ([Descripcion], [Color], [UsuarioCreacion])
VALUES ('Normal',         '#D3D3D3', 1),
       ('Validado',       '#CBE1E8', 1),
       ('Contrato Marco', '#D1B7EA', 1),
       ('Inhabilitado',   '#F59494', 1);
GO

-- SIS.Capitulo
SET IDENTITY_INSERT SIS.Capitulo ON;
INSERT INTO SIS.Capitulo (PKIdCapitulo, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdCapitulo, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.Capitulo
WHERE NOT EXISTS (SELECT 1 FROM SIS.Capitulo WHERE PKIdCapitulo = PK_IdCapitulo);
SET IDENTITY_INSERT SIS.Capitulo OFF;
GO

-- SIS.Concepto
SET IDENTITY_INSERT SIS.Concepto ON;
INSERT INTO SIS.Concepto (PKIdConcepto, FKIdCapitulo_SIS, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdConcepto, FK_IdCapitulo__SIS, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.Concepto
WHERE NOT EXISTS (SELECT 1 FROM SIS.Concepto WHERE PKIdConcepto = PK_IdConcepto);
SET IDENTITY_INSERT SIS.Concepto OFF;
GO

-- SIS.Partida
SET IDENTITY_INSERT SIS.Partida ON;
INSERT INTO SIS.Partida (PKIdPartida, FKIdConcepto_SIS, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdPartida, FK_IdConcepto__SIS, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.Partida
WHERE NOT EXISTS (SELECT 1 FROM SIS.Partida WHERE PKIdPartida = PK_IdPartida);
SET IDENTITY_INSERT SIS.Partida OFF;
GO

-- SIS.TipoPoliza
SET IDENTITY_INSERT SIS.TipoPoliza ON;
INSERT INTO SIS.TipoPoliza (PKIdTipoPoliza, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoPoliza, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.TipoPoliza
WHERE NOT EXISTS (SELECT 1 FROM SIS.TipoPoliza WHERE PKIdTipoPoliza = PK_IdTipoPoliza);
SET IDENTITY_INSERT SIS.TipoPoliza OFF;
GO

-- SIS.TipoDetallePoliza
SET IDENTITY_INSERT SIS.TipoDetallePoliza ON;
INSERT INTO SIS.TipoDetallePoliza (PkIdTipoDetallePoliza, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT Pk_IdTipoDetallePoliza, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.TipoDetallePoliza
WHERE NOT EXISTS (SELECT 1 FROM SIS.TipoDetallePoliza WHERE PkIdTipoDetallePoliza = Pk_IdTipoDetallePoliza);
SET IDENTITY_INSERT SIS.TipoDetallePoliza OFF;
GO

-- SIS.TipoDoctoCLC
SET IDENTITY_INSERT SIS.TipoDoctoCLC ON;
INSERT INTO SIS.TipoDoctoCLC (PKIdTipoDoctoCLC, Clave, Nombre, TipoRecurso, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoDoctoCLC, Clave, Nombre, TipoRecurso, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SIS.TipoDoctoCLC
WHERE NOT EXISTS (SELECT 1 FROM SIS.TipoDoctoCLC WHERE PKIdTipoDoctoCLC = PK_IdTipoDoctoCLC);
SET IDENTITY_INSERT SIS.TipoDoctoCLC OFF;
GO

-- =============================================
-- CONTA básico (sin dependencias de PRES)
-- =============================================

-- CONTA.TipoCuenta (INSERT VALUES)
INSERT INTO [CONTA].[TipoCuenta] ([Color], [Descripcion], [UsuarioCreacion], [FechaCreacion], [Activo])
VALUES ('1', 'ACREEDORA', 1, GETDATE(), 1),
       ('2', 'DEUDORA',   1, GETDATE(), 1);
GO

-- CONTA.CuentaContable
SET IDENTITY_INSERT [CONTA].[CuentaContable] ON;
INSERT INTO [CONTA].[CuentaContable] (
    [PKIdCuentaContable], [FKIdEmpresa_SIS], [FKIdTipoCuenta_CONTA],
    [Cuenta], [SubCuenta], [SubSubCuenta], [SubSubSubCuenta], [SubSubSubSubCuenta],
    [Saldo], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion],
    [S5], [S6], [S7], [ClaveOrd], [Padre], [Hijo], [NivelCuenta],
    [Cta_Coi], [Desc_Coi], [TipoCuenta], [S8], [S9], [S10]
)
SELECT
    s.[PK_IdCuentaContable], 1, s.[FK_IdTipoCuenta__SIS],
    s.[Cuenta], s.[SubCuenta], s.[SubSubCuenta], s.[SubSubSubCuenta], s.[SubSubSubSubCuenta],
    s.[Saldo], s.[Descripcion], s.[CT_LIVE], s.[CT_CreatedDate], s.[CT_CreatedBy],
    s.[S5], s.[S6], s.[S7], s.[ClaveOrd], s.[Padre], s.[Hijo], s.[NivelCuenta],
    s.[Cta_Coi], s.[Desc_Coi], s.[TipoCuenta], s.[S8], s.[S9], s.[S10]
FROM [BD_PRESUPUESTO].[SIS].[CuentaContable] s
WHERE s.[FK_IdTipoCuenta__SIS] IN (1, 2);
SET IDENTITY_INSERT [CONTA].[CuentaContable] OFF;
GO

-- CONTA.CuentaContable (adicionales con NOT EXISTS)
SET IDENTITY_INSERT CONTA.CuentaContable ON;
INSERT INTO CONTA.CuentaContable (
    PKIdCuentaContable, FKIdEmpresa_SIS, FKIdTipoCuenta_CONTA,
    Cuenta, SubCuenta, SubSubCuenta, SubSubSubCuenta, SubSubSubSubCuenta,
    Saldo, Descripcion, Activo, FechaCreacion, UsuarioCreacion,
    S5, S6, S7, ClaveOrd, Padre, Hijo, NivelCuenta,
    Cta_Coi, Desc_Coi, TipoCuenta, S8, S9, S10
)
SELECT
    s.PK_IdCuentaContable, 1, s.FK_IdTipoCuenta__SIS,
    s.Cuenta, s.SubCuenta, s.SubSubCuenta, s.SubSubSubCuenta, s.SubSubSubSubCuenta,
    s.Saldo, s.Descripcion, s.CT_LIVE, s.CT_CreatedDate, s.CT_CreatedBy,
    s.S5, s.S6, s.S7, s.ClaveOrd, s.Padre, s.Hijo, s.NivelCuenta,
    s.Cta_Coi, s.Desc_Coi, s.TipoCuenta, s.S8, s.S9, s.S10
FROM BD_PRESUPUESTO.SIS.CuentaContable s
WHERE s.FK_IdTipoCuenta__SIS IN (1, 2)
  AND NOT EXISTS (SELECT 1 FROM CONTA.CuentaContable c WHERE c.PKIdCuentaContable = s.PK_IdCuentaContable);
SET IDENTITY_INSERT CONTA.CuentaContable OFF;
GO

-- CONTA.Poliza
SET IDENTITY_INSERT CONTA.Poliza ON;
INSERT INTO CONTA.Poliza (
    PKIdPoliza, FKIdAnio_SIS, FKIdMes_SIS, FKIdTipoPoliza_SIS,
    ClavePoliza, NombrePoliza, FechaPoliza, EstaBalanceado,
    Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion,
    PermitirModificar, FKIdAccionAutorizar_SIS, Autorizado, FechaSolicitud, FechaAutorizacion
)
SELECT
    p.PK_IdPoliza, p.FK_IdAnio__SIS, p.FK_IdMes__SIS, p.FK_IdTipoPoliza__SIS,
    p.ClavePoliza, p.NombrePoliza, p.FechaPoliza, ISNULL(p.EstaBalanceado, 0),
    ISNULL(p.CT_Live, 1), ISNULL(p.CT_CreatedDate, GETDATE()), ISNULL(p.CT_CreatedBy, 1),
    p.CT_ModifiedDate, p.CT_ModifiedBy,
    p.PermitirModificar, p.Fk_IdAccionAutorizar, p.Autorizado, p.FechaSolicitud, p.FechaAutorizacion
FROM BD_PRESUPUESTO.CONTA.Poliza p
INNER JOIN SIS.Anio a ON p.FK_IdAnio__SIS = a.PKIdAnio
INNER JOIN SIS.TipoPoliza tp ON p.FK_IdTipoPoliza__SIS = tp.PKIdTipoPoliza
WHERE NOT EXISTS (SELECT 1 FROM CONTA.Poliza d WHERE d.PKIdPoliza = p.PK_IdPoliza);
SET IDENTITY_INSERT CONTA.Poliza OFF;
GO

-- CONTA.PolizaDetalle (desde BD_PRESUPUESTO.CONTA.DetallePoliza)
SET IDENTITY_INSERT CONTA.PolizaDetalle ON;
INSERT INTO CONTA.PolizaDetalle (
    PKIdPolizaDetalle, FKIdCuentaContable_CONTA, FKIdPoliza_CONTA,
    Descripcion, ImporteDebe, ImporteHaber, FKIdReferencia, FKIdTipoDetallePoliza_SIS,
    Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion
)
SELECT
    d.PK_IdDetallePoliza, d.FK_IdCuentaContable__SIS, d.FK_IdPoliza__CONTA,
    d.Descripcion, d.ImporteDebe, d.ImporteHaber, d.Fk_IdReferencia, d.Fk_IdTipoDetallePoliza,
    ISNULL(d.CT_LIVE, 1), ISNULL(d.CT_CreatedDate, GETDATE()), ISNULL(d.CT_CreatedBy, 1),
    d.CT_ModifiedDate, d.CT_ModifiedBy
FROM BD_PRESUPUESTO.CONTA.DetallePoliza d
INNER JOIN CONTA.CuentaContable cc ON d.FK_IdCuentaContable__SIS = cc.PKIdCuentaContable
INNER JOIN CONTA.Poliza p ON d.FK_IdPoliza__CONTA = p.PKIdPoliza
LEFT JOIN SIS.TipoDetallePoliza tdp ON d.Fk_IdTipoDetallePoliza = tdp.PkIdTipoDetallePoliza
WHERE (d.Fk_IdTipoDetallePoliza IS NULL OR tdp.PkIdTipoDetallePoliza IS NOT NULL)
  AND NOT EXISTS (SELECT 1 FROM CONTA.PolizaDetalle pd WHERE pd.PKIdPolizaDetalle = d.PK_IdDetallePoliza);
SET IDENTITY_INSERT CONTA.PolizaDetalle OFF;
GO

-- CONTA.Capitulo
SET IDENTITY_INSERT [CONTA].[Capitulo] ON;
INSERT INTO [CONTA].[Capitulo] (
    [PKIdCapitulo], [Clave], [Descripcion],
    [UsuarioCreacion], [FechaCreacion], [FechaModificacion], [UsuarioModificacion], [Activo]
)
SELECT
    s.[PK_IdCapitulo], s.[Clave], s.[Descripcion],
    1, ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate], 1, ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SIS].[Capitulo] s
WHERE NOT EXISTS (SELECT 1 FROM [CONTA].[Capitulo] c WHERE c.[PKIdCapitulo] = s.[PK_IdCapitulo]);
SET IDENTITY_INSERT [CONTA].[Capitulo] OFF;
GO

-- CONTA.Concepto
SET IDENTITY_INSERT [CONTA].[Concepto] ON;
INSERT INTO [CONTA].[Concepto] (
    [PKIdConcepto], [FKIdCapitulo_CONTA], [Clave], [Descripcion],
    [Activo], [FechaCreacion], [UsuarioCreacion]
)
SELECT
    s.[PK_IdConcepto], s.[FK_IdCapitulo__SIS], s.[Clave], s.[Descripcion],
    s.[CT_LIVE], s.[CT_CreatedDate], s.[CT_CreatedBy]
FROM [BD_PRESUPUESTO].[SIS].[Concepto] s
WHERE NOT EXISTS (SELECT 1 FROM [CONTA].[Concepto] c WHERE c.[PKIdConcepto] = s.[PK_IdConcepto]);
SET IDENTITY_INSERT [CONTA].[Concepto] OFF;
GO

-- CONTA.Partida
SET IDENTITY_INSERT [CONTA].[Partida] ON;
INSERT INTO [CONTA].[Partida] (
    [PKIdPartida], [FKIdConcepto_SIS], [Clave], [Descripcion],
    [UsuarioCreacion], [FechaCreacion], [UsuarioModificacion], [FechaModificacion], [Activo]
)
SELECT
    s.[PK_IdPartida], s.[FK_IdConcepto__SIS], s.[Clave], s.[Descripcion],
    1, ISNULL(s.[CT_CreatedDate], GETDATE()),
    1, s.[CT_ModifiedDate], ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SIS].[Partida] s
INNER JOIN [CONTA].[Concepto] c ON s.[FK_IdConcepto__SIS] = c.[PKIdConcepto]
LEFT JOIN [CONTA].[Partida] p ON s.[PK_IdPartida] = p.[PKIdPartida]
WHERE p.[PKIdPartida] IS NULL;
SET IDENTITY_INSERT [CONTA].[Partida] OFF;
GO

-- CONTA.TipoDoctoPago
SET IDENTITY_INSERT CONTA.TipoDoctoPago ON;
INSERT INTO CONTA.TipoDoctoPago (PKIdTipoDoctoPago, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdTipoDoctoPago, 
    Descripcion, 
    ISNULL(CT_LIVE, 1), 
    ISNULL(CT_CreatedDate, GETDATE()), 
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.CONTA.TipoDoctoPago
WHERE NOT EXISTS (SELECT 1 FROM CONTA.TipoDoctoPago WHERE PKIdTipoDoctoPago = PK_IdTipoDoctoPago);
SET IDENTITY_INSERT CONTA.TipoDoctoPago OFF;
GO

-- =============================================
-- SIS.Proveedor (después de CONTA.CuentaContable)
-- =============================================

-- SIS.Proveedor
SET IDENTITY_INSERT [SIS].[Proveedor] ON;
INSERT INTO [SIS].[Proveedor] (
    [PKIdProveedor], [FkIdTipoProveedor_SIS], [FKIdEstatusProveedor_SIS], [FKIdCuentaContable_SIS],
    [FKIdMunicipio_SIS], [FKIdEstado_SIS], [FKIdPais_SIS],
    [Nombre], [RFC], [Colonia], [CP], [Ciudad], [EMAIL], [Clave], [Calle], [Numero],
    [FechaAlta], [TelefonoInstitucional], [Notas], [PaginaWeb], [NumeroInt], [CURP],
    [Activo], [FechaCreacion], [UsuarioCreacion]
)
SELECT
    p.[PK_IdProveedor], p.[Fk_IdTipoProveedor], p.[FK_IdEstatusProveedor], tp2.[PKIdCuentaContable],
    p.[FK_IdMunicipio__SIS], p.[FK_IdEstado__SIS], p.[FK_IdPais__SIS],
    p.[Nombre], p.[RFC], p.[Colonia], p.[CP], p.[Ciudad], p.[EMAIL], p.[Clave], p.[Calle], p.[Numero],
    p.[FechaAlta], p.[TelefonoInstitucional], p.[Notas], p.[PaginaWeb], p.[NumeroInt], p.[CURP],
    p.[CT_LIVE], p.[CT_CreatedDate], p.[CT_CreatedBy]
FROM [BD_PRESUPUESTO].[SIS].[Proveedor] p
INNER JOIN [BD_PRESUPUESTO].[SIS].[CuentaContable] c ON p.[FK_IdCuentaContable__SIS] = c.[PK_IdCuentaContable]
INNER JOIN [GestionEmpresarial].[CONTA].[CuentaContable] tp2 ON c.[Descripcion] = tp2.[Descripcion]
WHERE p.[Fk_IdTipoProveedor] IS NOT NULL
  AND p.[FK_IdEstatusProveedor] IS NOT NULL
  AND p.[FK_IdEstado__SIS] IS NOT NULL
  AND p.[FK_IdPais__SIS] IS NOT NULL
  AND p.[FK_IdMunicipio__SIS] IN (SELECT PKIdMunicipio FROM [SIS].[Municipios]);
SET IDENTITY_INSERT [SIS].[Proveedor] OFF;
GO

-- =============================================
-- NOM
-- =============================================



-- =============================================
-- PRES (antes de CONTA.MatrizConversion/MatrizIngreso)
-- =============================================

-- PRES.GF
SET IDENTITY_INSERT PRES.GF ON;
INSERT INTO PRES.GF (PKIdGF, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdGF, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.GF
WHERE NOT EXISTS (SELECT 1 FROM PRES.GF WHERE PKIdGF = PK_IdGF);
SET IDENTITY_INSERT PRES.GF OFF;
GO

-- PRES.FN
SET IDENTITY_INSERT PRES.FN ON;
INSERT INTO PRES.FN (PKIdFN, FKIdGF_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdFN, FK_IdGF__PRES, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.FN
WHERE NOT EXISTS (SELECT 1 FROM PRES.FN WHERE PKIdFN = PK_IdFN);
SET IDENTITY_INSERT PRES.FN OFF;
GO

-- PRES.SF
SET IDENTITY_INSERT PRES.SF ON;
INSERT INTO PRES.SF (PKIdSF, FKIdFN_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdSF, FK_IdFN__PRES, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.SF
WHERE NOT EXISTS (SELECT 1 FROM PRES.SF WHERE PKIdSF = PK_IdSF);
SET IDENTITY_INSERT PRES.SF OFF;
GO

-- PRES.PP
SET IDENTITY_INSERT PRES.PP ON;
INSERT INTO PRES.PP (PKIdPP, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdPP, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.PP
WHERE NOT EXISTS (SELECT 1 FROM PRES.PP WHERE PKIdPP = PK_IdPP);
SET IDENTITY_INSERT PRES.PP OFF;
GO

-- PRES.TipoRecurso
SET IDENTITY_INSERT PRES.TipoRecurso ON;
INSERT INTO PRES.TipoRecurso (PKIdTipoRecurso, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoRecurso, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.TipoRecurso
WHERE NOT EXISTS (SELECT 1 FROM PRES.TipoRecurso WHERE PKIdTipoRecurso = PK_IdTipoRecurso);
SET IDENTITY_INSERT PRES.TipoRecurso OFF;
GO

-- PRES.Sector
SET IDENTITY_INSERT PRES.Sector ON;
INSERT INTO PRES.Sector (PKIdSector, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdSector, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.Sector
WHERE NOT EXISTS (SELECT 1 FROM PRES.Sector WHERE PKIdSector = PK_IdSector);
SET IDENTITY_INSERT PRES.Sector OFF;
GO

-- PRES.GrupoPresupuesto
SET IDENTITY_INSERT PRES.GrupoPresupuesto ON;
INSERT INTO PRES.GrupoPresupuesto (PKIdGrupoPresupuesto, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdGrupoPresupuesto, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.GrupoPresupuesto
WHERE NOT EXISTS (SELECT 1 FROM PRES.GrupoPresupuesto WHERE PKIdGrupoPresupuesto = PK_IdGrupoPresupuesto);
SET IDENTITY_INSERT PRES.GrupoPresupuesto OFF;
GO

-- PRES.UR
SET IDENTITY_INSERT PRES.UR ON;
INSERT INTO PRES.UR (PKIdUR, FKIdGrupoPresupuesto_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdUR, FK_IdGrupoPresupuesto__PRES, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.UR
WHERE NOT EXISTS (SELECT 1 FROM PRES.UR WHERE PKIdUR = PK_IdUR);
SET IDENTITY_INSERT PRES.UR OFF;
GO

-- PRES.Eje
SET IDENTITY_INSERT PRES.Eje ON;
INSERT INTO PRES.Eje (PKIdEje, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdEje, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.Eje
WHERE NOT EXISTS (SELECT 1 FROM PRES.Eje WHERE PKIdEje = PK_IdEje);
SET IDENTITY_INSERT PRES.Eje OFF;
GO

-- PRES.SubEje
SET IDENTITY_INSERT PRES.SubEje ON;
INSERT INTO PRES.SubEje (PKIdSubEje, FKIdEje_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdSubEje, FK_IdEje, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.SubEje
WHERE NOT EXISTS (SELECT 1 FROM PRES.SubEje WHERE PKIdSubEje = PK_IdSubEje);
SET IDENTITY_INSERT PRES.SubEje OFF;
GO

-- PRES.SubSubEje
SET IDENTITY_INSERT PRES.SubSubEje ON;
INSERT INTO PRES.SubSubEje (PKIdSubSubEje, FKIdSubEje_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdSubSubEje, FK_IdSubEje, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.SubSubEje
WHERE NOT EXISTS (SELECT 1 FROM PRES.SubSubEje WHERE PKIdSubSubEje = PK_IdSubSubEje);
SET IDENTITY_INSERT PRES.SubSubEje OFF;
GO

-- PRES.Finalidad
SET IDENTITY_INSERT PRES.Finalidad ON;
INSERT INTO PRES.Finalidad (PKIdFinalidad, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdFinalidad, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.Finalidad
WHERE NOT EXISTS (SELECT 1 FROM PRES.Finalidad WHERE PKIdFinalidad = PK_IdFinalidad);
SET IDENTITY_INSERT PRES.Finalidad OFF;
GO

-- PRES.VertienteGasto
SET IDENTITY_INSERT PRES.VertienteGasto ON;
INSERT INTO PRES.VertienteGasto (PKIdVertienteGasto, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdVertienteGasto, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.VertienteGasto
WHERE NOT EXISTS (SELECT 1 FROM PRES.VertienteGasto WHERE PKIdVertienteGasto = PK_IdVertienteGasto);
SET IDENTITY_INSERT PRES.VertienteGasto OFF;
GO

-- PRES.Resultado
SET IDENTITY_INSERT PRES.Resultado ON;
INSERT INTO PRES.Resultado (PKIdResultado, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdResultado, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.Resultado
WHERE NOT EXISTS (SELECT 1 FROM PRES.Resultado WHERE PKIdResultado = PK_IdResultado);
SET IDENTITY_INSERT PRES.Resultado OFF;
GO

-- PRES.Subresultado
SET IDENTITY_INSERT PRES.Subresultado ON;
INSERT INTO PRES.Subresultado (PKIdSubresultado, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdSubresultado, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.Subresultado
WHERE NOT EXISTS (SELECT 1 FROM PRES.Subresultado WHERE PKIdSubresultado = PK_IdSubresultado);
SET IDENTITY_INSERT PRES.Subresultado OFF;
GO

-- PRES.SubSector
SET IDENTITY_INSERT PRES.SubSector ON;
INSERT INTO PRES.SubSector (PKIdSubSector, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdSubSector, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.SubSector
WHERE NOT EXISTS (SELECT 1 FROM PRES.SubSector WHERE PKIdSubSector = PK_IdSubSector);
SET IDENTITY_INSERT PRES.SubSector OFF;
GO

-- PRES.Ramo
SET IDENTITY_INSERT PRES.Ramo ON;
INSERT INTO PRES.Ramo (PKIdRamo, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdRamo, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.Ramo
WHERE NOT EXISTS (SELECT 1 FROM PRES.Ramo WHERE PKIdRamo = PK_IdRamo);
SET IDENTITY_INSERT PRES.Ramo OFF;
GO

-- PRES.PG
SET IDENTITY_INSERT PRES.PG ON;
INSERT INTO PRES.PG (PKIdPG, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdPG, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.PG
WHERE NOT EXISTS (SELECT 1 FROM PRES.PG WHERE PKIdPG = PK_IdPG);
SET IDENTITY_INSERT PRES.PG OFF;
GO

-- PRES.PY
SET IDENTITY_INSERT PRES.PY ON;
INSERT INTO PRES.PY (
    PKIdPY, Clave, Descripcion, NombreProyecto, InicioProyecto, FinProyecto,
    Plurianual, TieneTICS, EsPAT, AnexosTransversales, ProgramaPresupuestario,
    ProyectoInversion, RecursosAdicionales, Prioridad, FuenteFinanciamiento,
    DescripcionProyecto, ResponsableProyecto, ObjetivoProyecto, LineaEstrategica,
    LineaAccionRegulatoria, TemaAccionRegulatoria, FundamentoLegal, Justificacion,
    Beneficios, Indicador, Meta, Activo, FechaCreacion, UsuarioCreacion
)
SELECT
    PK_IdPY, Clave, Descripcion, NombreProyecto, InicioProyecto, FinProyecto,
    Plurianual, TieneTICS, EsPAT, AnexosTransversales, ProgramaPresupuestario,
    ProyectoInversion, RecursosAdicionales, Prioridad, FuenteFinanciamiento,
    DescripcionProyecto, ResponsableProyecto, ObjetivoProyecto, LineaEstrategica,
    LineaAccionRegulatoria, TemaAccionRegulatoria, FundamentoLegal, Justificacion,
    Beneficios, Indicador, Meta, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.PY
WHERE NOT EXISTS (SELECT 1 FROM PRES.PY WHERE PKIdPY = PK_IdPY);
SET IDENTITY_INSERT PRES.PY OFF;
GO

-- PRES.FuenteFinanciamiento (desde 03 - con columnas extendidas)
SET IDENTITY_INSERT PRES.FuenteFinanciamiento ON;
INSERT INTO PRES.FuenteFinanciamiento (PKIdFuenteFinanciamiento, Clave, Descripcion, FKIdAnio_SIS, FF, FG, FE, AD, ORI, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdFuenteFinanciamiento, Clave, Descripcion, FK_IdAnio__SIS, FF, FG, FE, AD, ORI,
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.FuenteFinanciamiento
WHERE NOT EXISTS (SELECT 1 FROM PRES.FuenteFinanciamiento WHERE PKIdFuenteFinanciamiento = PK_IdFuenteFinanciamiento);
SET IDENTITY_INSERT PRES.FuenteFinanciamiento OFF;
GO

-- PRES.Origen
SET IDENTITY_INSERT PRES.Origen ON;
INSERT INTO PRES.Origen (PKIdOrigen, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdOrigen, Clave, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.Origen
WHERE NOT EXISTS (SELECT 1 FROM PRES.Origen WHERE PKIdOrigen = PK_IdOrigen);
SET IDENTITY_INSERT PRES.Origen OFF;
GO

-- PRES.Programa
SET IDENTITY_INSERT PRES.Programa ON;
INSERT INTO PRES.Programa (
    PKIdPrograma, FKIdUR_PRES, FKIdGF_PRES, FKIdFN_PRES, FKIdSF_PRES,
    FKIdActividadInstitucional_SIS, FKIdEje_PRES, FKIdVertienteGasto_PRES,
    FKIdResultado_PRES, FKIdSubresultado_PRES, FKIdAnio_SIS, FKIdSector_PRES,
    FKIdSubSector_PRES, FKIdTipoRecurso_PRES, FKIdFuenteFinanciamiento_PRES,
    Clave, Objetivo, Descripcion, FKIdSubEje_PRES, FKIdSubSubEje_PRES,
    FKIdFinalidad_PRES, FKIdPP_PRES, Activo, FechaCreacion, UsuarioCreacion,
    FechaModificacion, UsuarioModificacion
)
SELECT 
    p.PK_IdPrograma,
    p.FK_IdUR__PRES,
    p.FK_IdGF__PRES,
    p.FK_IdFN__PRES,
    p.FK_IdSF__PRES,
    p.FK_IdActividadInstitucional__SIS,
    p.FK_IdEje__PRES,
    p.FK_IdVertienteGasto__PRES,
    p.FK_IdResultado__PRES,
    p.FK_IdSubresultado__PRES,
    p.FK_IdAnio__SIS,
    p.FK_IdSector__PRES,
    p.FK_IdSubSector__PRES,
    p.FK_IdTipoRecurso__PRES,
    p.FK_IdFuenteFinanciamiento__PRES,
    p.Clave,
    p.Objetivo,
    p.Descripcion,
    p.FK_IdSubEje_PRES,
    p.FK_IdSubSubEje_PRES,
    p.FK_IdFinalidad_PRES,
    p.FK_IdPP__PRES,
    ISNULL(p.CT_LIVE, 1),
    ISNULL(p.CT_CreatedDate, GETDATE()),
    ISNULL(p.CT_CreatedBy, 1),
    p.CT_ModifiedDate,
    p.CT_ModifiedBy
FROM BD_PRESUPUESTO.PRES.Programa p
WHERE NOT EXISTS (SELECT 1 FROM PRES.Programa d WHERE d.PKIdPrograma = p.PK_IdPrograma);
SET IDENTITY_INSERT PRES.Programa OFF;
GO

UPDATE d
SET
    d.FKIdUR_PRES = p.FK_IdUR__PRES,
    d.FKIdGF_PRES = p.FK_IdGF__PRES,
    d.FKIdFN_PRES = p.FK_IdFN__PRES,
    d.FKIdSF_PRES = p.FK_IdSF__PRES,
    d.FKIdActividadInstitucional_SIS = p.FK_IdActividadInstitucional__SIS,
    d.FKIdEje_PRES = p.FK_IdEje__PRES,
    d.FKIdVertienteGasto_PRES = p.FK_IdVertienteGasto__PRES,
    d.FKIdResultado_PRES = p.FK_IdResultado__PRES,
    d.FKIdSubresultado_PRES = p.FK_IdSubresultado__PRES,
    d.FKIdAnio_SIS = p.FK_IdAnio__SIS,
    d.FKIdSector_PRES = p.FK_IdSector__PRES,
    d.FKIdSubSector_PRES = p.FK_IdSubSector__PRES,
    d.FKIdTipoRecurso_PRES = p.FK_IdTipoRecurso__PRES,
    d.FKIdFuenteFinanciamiento_PRES = p.FK_IdFuenteFinanciamiento__PRES,
    d.Clave = p.Clave,
    d.Objetivo = p.Objetivo,
    d.Descripcion = p.Descripcion,
    d.FKIdSubEje_PRES = p.FK_IdSubEje_PRES,
    d.FKIdSubSubEje_PRES = p.FK_IdSubSubEje_PRES,
    d.FKIdFinalidad_PRES = p.FK_IdFinalidad_PRES,
    d.FKIdPP_PRES = p.FK_IdPP__PRES,
    d.Activo = ISNULL(p.CT_LIVE, 1),
    d.FechaCreacion = ISNULL(p.CT_CreatedDate, GETDATE()),
    d.UsuarioCreacion = ISNULL(p.CT_CreatedBy, 1),
    d.FechaModificacion = p.CT_ModifiedDate,
    d.UsuarioModificacion = p.CT_ModifiedBy
FROM PRES.Programa d
INNER JOIN BD_PRESUPUESTO.PRES.Programa p ON p.PK_IdPrograma = d.PKIdPrograma;
GO

-- PRES.TipoGasto
SET IDENTITY_INSERT PRES.TipoGasto ON;
INSERT INTO PRES.TipoGasto (PKIdTipoGasto, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    t.PK_IdTG,
    t.Clave,
    t.Descripcion,
    ISNULL(t.CT_LIVE, 1),
    ISNULL(t.CT_CreatedDate, GETDATE()),
    ISNULL(t.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.TipoGasto t
WHERE NOT EXISTS (SELECT 1 FROM PRES.TipoGasto d WHERE d.PKIdTipoGasto = t.PK_IdTG);
SET IDENTITY_INSERT PRES.TipoGasto OFF;
GO

-- PRES.DigitoIdentificador
SET IDENTITY_INSERT PRES.DigitoIdentificador ON;
INSERT INTO PRES.DigitoIdentificador (PKIdDigitoIdentificador, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    d.PK_IdDigitoIdentificador,
    d.Clave,
    d.Descripcion,
    ISNULL(d.CT_LIVE, 1),
    ISNULL(d.CT_CreatedDate, GETDATE()),
    ISNULL(d.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.DigitoIdentificador d
WHERE NOT EXISTS (SELECT 1 FROM PRES.DigitoIdentificador dest WHERE dest.PKIdDigitoIdentificador = d.PK_IdDigitoIdentificador);
SET IDENTITY_INSERT PRES.DigitoIdentificador OFF;
GO

-- PRES.DestinoGasto
SET IDENTITY_INSERT PRES.DestinoGasto ON;
INSERT INTO PRES.DestinoGasto (PKIdDestinoGasto, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    d.PK_IdDestinoGasto,
    d.Clave,
    d.Descripcion,
    ISNULL(d.CT_LIVE, 1),
    ISNULL(d.CT_CreatedDate, GETDATE()),
    ISNULL(d.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.PRES.DestinoGasto d
WHERE NOT EXISTS (SELECT 1 FROM PRES.DestinoGasto dest WHERE dest.PKIdDestinoGasto = d.PK_IdDestinoGasto);
SET IDENTITY_INSERT PRES.DestinoGasto OFF;
GO

-- PRES.Suficiencia
SET IDENTITY_INSERT PRES.Suficiencia ON;
INSERT INTO PRES.Suficiencia (PKIdSuficiencia, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    s.PK_IdEstatusSolicitud,
    s.Descripcion,
    ISNULL(s.CT_LIVE, 1),
    ISNULL(s.CT_CreatedDate, GETDATE()),
    ISNULL(s.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ALMA.EstatusSolicitud s
WHERE NOT EXISTS (SELECT 1 FROM PRES.Suficiencia d WHERE d.PKIdSuficiencia = s.PK_IdEstatusSolicitud)
and Descripcion not Like '%test%';
SET IDENTITY_INSERT PRES.Suficiencia OFF;
GO

-- PRES.EgresoProyectado
SET IDENTITY_INSERT PRES.EgresoProyectado ON;
INSERT INTO PRES.EgresoProyectado (
    PKIdEgresoProyectado,
    FKIdPrograma_PRES,
    FKIdPartida_CONTA,
    FKIdArea_SIS,
    Descripcion,
    Fecha,
    FKIdFuenteFinanciamiento_PRES,
    FKIdTipoGasto_PRES,
    FKIdDigitoIdentificador_PRES,
    FKIdDestinoGasto_PRES,
    FKIdPY_PRES,
    Enero,
    Febrero,
    Marzo,
    Abril,
    Mayo,
    Junio,
    Julio,
    Agosto,
    Septiembre,
    Octubre,
    Noviembre,
    Diciembre,
    Activo,
    FechaCreacion,
    UsuarioCreacion,
    FechaModificacion,
    UsuarioModificacion
)
SELECT
    e.Pk_IdEgresoProyectado,
    e.Fk_IdPrograma,
    e.Fk_IdPartida,
    e.Fk_IdArea,
    e.Descripcion,
    e.Fecha,
    e.FK_IdFuenteFinanciamiento,
    e.FK_IdTG,
    e.Fk_IdDigitoIdentificador,
    e.Fk_IdDestinoGasto,
    e.Fk_IdPY,
    ISNULL(e.Ene, 0),
    ISNULL(e.Feb, 0),
    ISNULL(e.Mar, 0),
    ISNULL(e.Abr, 0),
    ISNULL(e.May, 0),
    ISNULL(e.Jun, 0),
    ISNULL(e.Jul, 0),
    ISNULL(e.Ago, 0),
    ISNULL(e.Sep, 0),
    ISNULL(e.Oct, 0),
    ISNULL(e.Nov, 0),
    ISNULL(e.Dic, 0),
    ISNULL(e.CT_LIVE, 1),
    ISNULL(e.CT_CreatedDate, GETDATE()),
    ISNULL(e.CT_CreatedBy, 1),
    e.CT_ModifiedDate,
    e.CT_ModifiedBy
FROM BD_PRESUPUESTO.PRES.EgresoProyectado e
WHERE NOT EXISTS (SELECT 1 FROM PRES.EgresoProyectado d WHERE d.PKIdEgresoProyectado = e.Pk_IdEgresoProyectado);
SET IDENTITY_INSERT PRES.EgresoProyectado OFF;
GO

-- PRES.EgresoAutorizado
SET IDENTITY_INSERT PRES.EgresoAutorizado ON;
INSERT INTO PRES.EgresoAutorizado (
    PKIdEgresoAutorizado,
    FKIdPrograma_PRES,
    FKIdPartida_CONTA,
    FKIdArea_SIS,
    Descripcion,
    Fecha,
    FKIdPoliza_CONTA,
    FKIdFuenteFinanciamiento_PRES,
    FKIdTipoGasto_PRES,
    FKIdDigitoIdentificador_PRES,
    FKIdDestinoGasto_PRES,
    FKIdPY_PRES,
    Enero,
    Febrero,
    Marzo,
    Abril,
    Mayo,
    Junio,
    Julio,
    Agosto,
    Septiembre,
    Octubre,
    Noviembre,
    Diciembre,
    Activo,
    FechaCreacion,
    UsuarioCreacion,
    FechaModificacion,
    UsuarioModificacion
)
SELECT 
    e.Pk_IdEgresoAutorizado,
    e.Fk_IdPrograma,
    e.Fk_IdPartida,
    e.Fk_IdArea,
    e.Descripcion,
    e.Fecha,
    e.FK_IdPoliza,
    e.FK_IdFuenteFinanciamiento,
    e.FK_IdTG,
    e.Fk_IdDigitoIdentificador,
    e.Fk_IdDestinoGasto,
    e.Fk_IdPY,
    ISNULL(e.Ene, 0),
    ISNULL(e.Feb, 0),
    ISNULL(e.Mar, 0),
    ISNULL(e.Abr, 0),
    ISNULL(e.May, 0),
    ISNULL(e.Jun, 0),
    ISNULL(e.Jul, 0),
    ISNULL(e.Ago, 0),
    ISNULL(e.Sep, 0),
    ISNULL(e.Oct, 0),
    ISNULL(e.Nov, 0),
    ISNULL(e.Dic, 0),
    ISNULL(e.CT_LIVE, 1),
    ISNULL(e.CT_CreatedDate, GETDATE()),
    ISNULL(e.CT_CreatedBy, 1),
    e.CT_ModifiedDate,
    e.CT_ModifiedBy
FROM BD_PRESUPUESTO.PRES.EgresoAutorizado e
WHERE NOT EXISTS (SELECT 1 FROM PRES.EgresoAutorizado d WHERE d.PKIdEgresoAutorizado = e.Pk_IdEgresoAutorizado);
SET IDENTITY_INSERT PRES.EgresoAutorizado OFF;
GO

-- =============================================
-- CONTA avanzado (depende de PRES)
-- =============================================

-- CONTA.MatrizConversion
SET IDENTITY_INSERT CONTA.MatrizConversion ON;
INSERT INTO CONTA.MatrizConversion (
    PKIdMatrizConversion, FKIdAnio_SIS, FKIdPrograma_PRES, FKIdPartida_SIS,
    FKIdCuentaContableAprobado, FKIdCuentaContablePorEjercer, FKIdCuentaContableModificado,
    FKIdCuentaContableComprometido, FKIdCuentaContableDevengado, FKIdCuentaContableEjercido,
    FKIdCuentaContablePagado, FKIdCuentaContableGasto,
    Activo, FechaCreacion, UsuarioCreacion
)
SELECT
    PK_IdMatrizConversion, FK_IdAnio__SIS, FK_IdPrograma__PRES, FK_IdPartida__SIS,
    FK_IdCuentaContableAprobado, FK_IdCuentaContablePorEjercer, FK_IdCuentaContableModificado,
    FK_IdCuentaContableComprometido, FK_IdCuentaContableDevengado, FK_IdCuentaContableEjercido,
    FK_IdCuentaContablePagado, FK_IdCuentaContableGasto,
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), 1
FROM BD_PRESUPUESTO.CONTA.MatrizConversion
WHERE NOT EXISTS (SELECT 1 FROM CONTA.MatrizConversion WHERE PKIdMatrizConversion = PK_IdMatrizConversion);
SET IDENTITY_INSERT CONTA.MatrizConversion OFF;
GO

-- CONTA.MatrizIngreso
SET IDENTITY_INSERT CONTA.MatrizIngreso ON;
INSERT INTO CONTA.MatrizIngreso (
    Pk_IdMatrizIngreso, Fk_IdPrograma, Fk_IdOrigen,
    Fk_IdCuentaContableAutorizado, Fk_IdCuentaContablePorEjercer, Fk_IdCuentaContableModificado,
    Fk_IdCuentaContableDevengado, Fk_IdCuentaContableRecaudado, Fk_IdCuentaContableDeposito,
    FK_IdAnio__SIS, Activo, FechaCreacion, UsuarioCreacion
)
SELECT
    Pk_IdMatrizIngreso, Fk_IdPrograma, Fk_IdOrigen,
    Fk_IdCuentaContableAutorizado, Fk_IdCuentaContablePorEjercer, Fk_IdCuentaContableModificado,
    Fk_IdCuentaContableDevengado, Fk_IdCuentaContableRecaudado, Fk_IdCuentaContableDeposito,
    FK_IdAnio__SIS, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()),1
FROM BD_PRESUPUESTO.CONTA.MatrizIngreso
WHERE NOT EXISTS (SELECT 1 FROM CONTA.MatrizIngreso WHERE Pk_IdMatrizIngreso = Pk_IdMatrizIngreso);
SET IDENTITY_INSERT CONTA.MatrizIngreso OFF;
GO

-- =============================================
-- ORCO
-- =============================================

-- ORCO.Proyecto
SET IDENTITY_INSERT ORCO.Proyecto ON;
INSERT INTO ORCO.Proyecto (PKIdProyecto, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    p.PK_IdProyecto,
    p.Descripcion,
    ISNULL(p.CT_LIVE, 1),
    ISNULL(p.CT_CreatedDate, GETDATE()),
    ISNULL(p.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.Proyecto p
WHERE NOT EXISTS (SELECT 1 FROM ORCO.Proyecto d WHERE d.PKIdProyecto = p.PK_IdProyecto);
SET IDENTITY_INSERT ORCO.Proyecto OFF;
GO

-- ORCO.Modalidad
SET IDENTITY_INSERT ORCO.Modalidad ON;
INSERT INTO ORCO.Modalidad (PKIdModalidad, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdModalidad,
    Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.Modalidad
WHERE NOT EXISTS (SELECT 1 FROM ORCO.Modalidad WHERE PKIdModalidad = PK_IdModalidad);
SET IDENTITY_INSERT ORCO.Modalidad OFF;
GO

-- ORCO.TipoContrato
SET IDENTITY_INSERT ORCO.TipoContrato ON;
INSERT INTO ORCO.TipoContrato (PKIdTipoContrato, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdTipoContrato,
    Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.TipoContrato
WHERE NOT EXISTS (SELECT 1 FROM ORCO.TipoContrato WHERE PKIdTipoContrato = PK_IdTipoContrato);
SET IDENTITY_INSERT ORCO.TipoContrato OFF;
GO

-- ORCO.TipoDocumento
SET IDENTITY_INSERT ORCO.TipoDocumento ON;
INSERT INTO ORCO.TipoDocumento (PKIdTipoDocumento, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdTipoDocumento,
    Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    1
FROM BD_PRESUPUESTO.ORCO.TipoDocumento
WHERE NOT EXISTS (SELECT 1 FROM ORCO.TipoDocumento WHERE PKIdTipoDocumento = PK_IdTipoDocumento);
SET IDENTITY_INSERT ORCO.TipoDocumento OFF;
GO

-- ORCO.TipoGarantia
SET IDENTITY_INSERT ORCO.TipoGarantia ON;
INSERT INTO ORCO.TipoGarantia (PKIdTipoGarantia, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdTipoGarantia,
    Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.TipoGarantia
WHERE NOT EXISTS (SELECT 1 FROM ORCO.TipoGarantia WHERE PKIdTipoGarantia = PK_IdTipoGarantia);
SET IDENTITY_INSERT ORCO.TipoGarantia OFF;
GO

-- ORCO.ProcedimientoContratacion
SET IDENTITY_INSERT ORCO.ProcedimientoContratacion ON;
INSERT INTO ORCO.ProcedimientoContratacion (PKIdProcedimientoContratacion, Descripcion, FundamentoJuridico, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdProcedimientoContratacion,
    Descripcion,
    FundamentoJuridico,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.ProcedimientoContratacion
WHERE NOT EXISTS (SELECT 1 FROM ORCO.ProcedimientoContratacion WHERE PKIdProcedimientoContratacion = PK_IdProcedimientoContratacion);
SET IDENTITY_INSERT ORCO.ProcedimientoContratacion OFF;
GO

-- ORCO.Articulo
SET IDENTITY_INSERT ORCO.Articulo ON;
INSERT INTO ORCO.Articulo (PKIdArticulo, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdArticulo, Clave, Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.Articulo
WHERE NOT EXISTS (SELECT 1 FROM ORCO.Articulo WHERE PKIdArticulo = PK_IdArticulo);
SET IDENTITY_INSERT ORCO.Articulo OFF;
GO

-- ORCO.Fraccion
SET IDENTITY_INSERT ORCO.Fraccion ON;
INSERT INTO ORCO.Fraccion (PKIdFraccion, FKIdArticulo_ORCO, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdFraccion, FK_IdArticulo__ORCO, Clave, Descripcion,
    ISNULL(CT_LIVE, 1),
    ISNULL(CT_CreatedDate, GETDATE()),
    ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.Fraccion
WHERE NOT EXISTS (SELECT 1 FROM ORCO.Fraccion WHERE PKIdFraccion = PK_IdFraccion);
SET IDENTITY_INSERT ORCO.Fraccion OFF;
GO

-- ORCO.EstatusRequisicion (INSERT VALUES - datos iniciales)
SET IDENTITY_INSERT ORCO.EstatusRequisicion ON;
INSERT INTO ORCO.EstatusRequisicion (PKIdEstatusRequisicion, Descripcion, Color, Orden, Icono, Activo, FechaCreacion, UsuarioCreacion)
VALUES 
    (1, 'Borrador', '#6c757d', 10, 'edit', 1, GETDATE(), 1),
    (2, 'Enviada', '#007bff', 20, 'send', 1, GETDATE(), 1),
    (3, 'En Revisión', '#ffc107', 30, 'search', 1, GETDATE(), 1),
    (4, 'Suficiencia', '#17a2b8', 40, 'check-circle', 1, GETDATE(), 1),
    (5, 'Autorizada', '#28a745', 50, 'check', 1, GETDATE(), 1),
    (6, 'Rechazada', '#dc3545', 60, 'times', 1, GETDATE(), 1),
    (7, 'Cancelada', '#6c757d', 70, 'ban', 1, GETDATE(), 1);
SET IDENTITY_INSERT ORCO.EstatusRequisicion OFF;
GO

-- =============================================
-- ORCO.PAAAS, PAAASPartida, PAAASDetalle
-- Migración desde BD_PRESUPUESTO
-- =============================================

-- ORCO.PAAAS
SET IDENTITY_INSERT ORCO.PAAAS ON;
INSERT INTO ORCO.PAAAS (
    PKIdPAAAS, FKIdEmpresa_SIS, FKIdAnio_SIS, FKIdArea_SIS, FKIdPersona_NOM,
    Descripcion, Observaciones, Fecha, FKIdProyecto_ORCO,
    FKIdPrograma_PRES, FKIdFuenteFinanciamiento_PRES,
    Activo, FechaCreacion, UsuarioCreacion
)
SELECT DISTINCT
    p.PK_IdPAAAS,
    1,
    p.FK_IdAnio__SIS,
    p.FK_IdArea__SIS,
    1,  -- FKIdPersona_NOM: NOM.Persona migración comentada, usar bootstrap (1)
    p.Descripcion,
    p.Observaciones,
    p.Fecha,
    p.FK_IdProyecto__ORCO,
    p.FK_IdPrograma__PRES,
    p.FK_IdFuenteFinanciamiento__PRES,
    ISNULL(p.CT_LIVE, 1),
    ISNULL(p.CT_CreatedDate, GETDATE()),
    ISNULL(p.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.PAAAS p
WHERE NOT EXISTS (
    SELECT 1 FROM ORCO.PAAAS d 
    WHERE d.FKIdArea_SIS = p.FK_IdArea__SIS 
    AND d.FKIdAnio_SIS = p.FK_IdAnio__SIS
);
SET IDENTITY_INSERT ORCO.PAAAS OFF;
GO

-- ORCO.PAAASPartida
INSERT INTO ORCO.PAAASPartida (
    FKIdEmpresa_SIS, FKIdPAAAS_ORCO, FKIdPartida_CONTA,
    Observaciones, Activo, FechaCreacion, UsuarioCreacion
)
SELECT DISTINCT
    1,
    p_dest.PKIdPAAAS,
    p.FK_IdPartida__SIS,
    NULL,
    1,
    GETDATE(),
    1
FROM [BD_PRESUPUESTO].ORCO.PAAAS p
INNER JOIN ORCO.PAAAS p_dest ON p_dest.FKIdArea_SIS = p.FK_IdArea__SIS 
                              AND p_dest.FKIdAnio_SIS = p.FK_IdAnio__SIS
WHERE p.FK_IdPartida__SIS IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM ORCO.PAAASPartida dest WHERE dest.FKIdPAAAS_ORCO = p_dest.PKIdPAAAS AND dest.FKIdPartida_CONTA = p.FK_IdPartida__SIS);
GO

-- ORCO.PAAASDetalle
SET IDENTITY_INSERT ORCO.PAAASDetalle ON;
INSERT INTO ORCO.PAAASDetalle (
    PKIdPAAASDetalle, FKIdEmpresa_SIS, FKIdPAAASPartida_ORCO, FKIdTipoBien_ALMA,
    FKIdUnidades_ALMA, Cantidad, Observaciones, LugarEntrega,
    Activo, FechaCreacion, UsuarioCreacion
)
SELECT 
    d.PK_IdPAAASDetalle,
    1,
    pp.PKIdPAAASPartida,
    d.FK_IdTipoBien__SICOP,
    d.FK_IdUnidades__ALMA,
    d.Cantidad,
    d.Observaciones,
    d.LugarEntrega,
    ISNULL(d.CT_LIVE, 1),
    ISNULL(d.CT_CreatedDate, GETDATE()),
    ISNULL(d.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.PAAASDetalle d
INNER JOIN BD_PRESUPUESTO.ORCO.PAAAS p_orig ON d.FK_IdPAAAS__ORCO = p_orig.PK_IdPAAAS
INNER JOIN ORCO.PAAAS p_dest ON p_dest.FKIdArea_SIS = p_orig.FK_IdArea__SIS 
                              AND p_dest.FKIdAnio_SIS = p_orig.FK_IdAnio__SIS
INNER JOIN ORCO.PAAASPartida pp ON pp.FKIdPAAAS_ORCO = p_dest.PKIdPAAAS
WHERE NOT EXISTS (SELECT 1 FROM ORCO.PAAASDetalle dest WHERE dest.PKIdPAAASDetalle = d.PK_IdPAAASDetalle);
SET IDENTITY_INSERT ORCO.PAAASDetalle OFF;
GO

-- ORCO.EstudioMercado (migración desde BD_PRESUPUESTO)
SET IDENTITY_INSERT ORCO.EstudioMercado ON;
INSERT INTO ORCO.EstudioMercado (
    PKIdEstudioMercado, FKIdEmpresa_SIS, FKIdAnio_SIS, Nombre, Descripcion,
    FechaSolicitud, FechaCierre, FKIdResponsable_NOM, Estatus,
    Activo, FechaCreacion, UsuarioCreacion
)
SELECT 
    e.PK_IdEstudioMercado,
    1,
    e.FK_IdAnio,
    e.Nombre,
    NULL,
    e.FechaSolicitud,
    NULL,
    e.CT_CreatedBy,
    3,
    ISNULL(e.CT_LIVE, 1),
    ISNULL(e.CT_CreatedDate, GETDATE()),
    ISNULL(e.CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ORCO.EstudioMercado e
WHERE NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercado dest WHERE dest.PKIdEstudioMercado = e.PK_IdEstudioMercado);
SET IDENTITY_INSERT ORCO.EstudioMercado OFF;
GO

-- ORCO.EstudioMercadoDetalle (migración desde BD_PRESUPUESTO)
SET IDENTITY_INSERT ORCO.EstudioMercadoDetalle ON;
INSERT INTO ORCO.EstudioMercadoDetalle (
    PKIdEstudioMercadoDetalle, FKIdEmpresa_SIS, FKIdEstudioMercado_ORCO,
    FKIdPAAASDetalle_ORCO, FKIdTipoBien_ALMA, Cantidad, Observaciones,
    Activo, FechaCreacion, UsuarioCreacion
)
SELECT 
    d.PK_IdDet_SolEstudioMercado,
    1,
    d.FK_IdSolEstudioMercado__ORCO,
    d.FK_IdDetallePAAAS__ORCO,
    dp.FKIdTipoBien_ALMA,
    tb.Cantidad_Equivalente,
    NULL,
    1,
    GETDATE(),
    1
FROM BD_PRESUPUESTO.ORCO.Det_SolEstudioMercado d
INNER JOIN ORCO.PAAASDetalle dp ON d.FK_IdDetallePAAAS__ORCO = dp.PKIdPAAASDetalle
INNER JOIN [BD_PRESUPUESTO].SICOP.TipoBien tb ON dp.FKIdTipoBien_ALMA = tb.PK_IdTipoBien
WHERE NOT EXISTS (SELECT 1 FROM ORCO.EstudioMercadoDetalle dest WHERE dest.PKIdEstudioMercadoDetalle = d.PK_IdDet_SolEstudioMercado);
SET IDENTITY_INSERT ORCO.EstudioMercadoDetalle OFF;
GO

-- =============================================
-- ALMA
-- =============================================

-- ALMA.Unidades (migración desde BD_PRESUPUESTO.alma.Unidades)
INSERT INTO [ALMA].[Unidades] ([Descripcion], [UsuarioCreacion], [FechaCreacion], [Activo])
SELECT [Descripcion], 1, [CT_CreatedDate], 1
FROM [BD_PRESUPUESTO].[alma].[Unidades];
GO

-- ALMA.Unidades (migración desde BD_PRESUPUESTO.ALMA.Unidades con NOT EXISTS)
SET IDENTITY_INSERT ALMA.Unidades ON;
INSERT INTO ALMA.Unidades (PKIdUnidades, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdUnidades, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ALMA.Unidades
WHERE NOT EXISTS (SELECT 1 FROM ALMA.Unidades WHERE PKIdUnidades = PK_IdUnidades);
SET IDENTITY_INSERT ALMA.Unidades OFF;
GO

-- ALMA.Nivel
SET IDENTITY_INSERT [ALMA].[Nivel] ON;
INSERT INTO [ALMA].[Nivel] (
    [PKIdNivel], [Nivel], [Descripcion],
    [UsuarioCreacion], [FechaCreacion], [FechaModificacion], [UsuarioModificacion], [Activo]
)
SELECT
    s.[PK_IdNivel], s.[Nivel], s.[Descipcion],
    1, ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate], 1, ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[Nivel] s
WHERE NOT EXISTS (SELECT 1 FROM [ALMA].[Nivel] n WHERE n.[PKIdNivel] = s.[PK_IdNivel]);
SET IDENTITY_INSERT [ALMA].[Nivel] OFF;
GO

-- ALMA.Familia (desde 01.CONTA.CuentaContable)
SET IDENTITY_INSERT [ALMA].[Familia] ON;
INSERT INTO [ALMA].[Familia] (
    [PKIdFamilia], [Descripcion], [Clave],
    [UsuarioCreacion], [FechaCreacion], [FechaModificacion], [UsuarioModificacion], [Activo]
)
SELECT
    s.[PK_IdFamilia], s.[Descripcion], s.[Clave],
    1, ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate], 1, ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[Familia] s
WHERE NOT EXISTS (SELECT 1 FROM [ALMA].[Familia] f WHERE f.[PKIdFamilia] = s.[PK_IdFamilia]);
SET IDENTITY_INSERT [ALMA].[Familia] OFF;
GO

-- ALMA.Familia (desde 05.Catalogo - Patrimonio)
SET IDENTITY_INSERT ALMA.Familia ON;
INSERT INTO ALMA.Familia (PKIdFamilia, Descripcion, Clave, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdFamilia, Descripcion, Clave, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SICOP.Familia
WHERE NOT EXISTS (SELECT 1 FROM ALMA.Familia WHERE PKIdFamilia = PK_IdFamilia);
SET IDENTITY_INSERT ALMA.Familia OFF;
GO

-- ALMA.GrupoBien (desde 01.CONTA.CuentaContable)
SET IDENTITY_INSERT [ALMA].[GrupoBien] ON;
INSERT INTO [ALMA].[GrupoBien] (
    [PKIdGrupoBien], [FKIdFamilia_ALMA], [Descripcion], [Clave], [ClaveAN], [CABM_ACT], [CLAVE_CUCOP], [MEDIDA],
    [UsuarioCreacion], [FechaCreacion], [FechaModificacion], [UsuarioModificacion], [Activo]
)
SELECT
    s.[PK_IdGrupoBien], s.[FK_IdFamilia__SICOP], s.[Descripcion], s.[Clave], s.[ClaveAN], s.[CABM_ACT], s.[CLAVE_CUCOP], s.[MEDIDA],
    1, ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate], 1, ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[GrupoBien] s
INNER JOIN [ALMA].[Familia] f ON s.[FK_IdFamilia__SICOP] = f.[PKIdFamilia]
WHERE NOT EXISTS (SELECT 1 FROM [ALMA].[GrupoBien] g WHERE g.[PKIdGrupoBien] = s.[PK_IdGrupoBien]);
SET IDENTITY_INSERT [ALMA].[GrupoBien] OFF;
GO

-- ALMA.GrupoBien (desde 05.Catalogo - Patrimonio)
SET IDENTITY_INSERT ALMA.GrupoBien ON;
INSERT INTO ALMA.GrupoBien (
    PKIdGrupoBien, FKIdFamilia_ALMA, Descripcion, Clave, ClaveAN, CABM_ACT, CLAVE_CUCOP, MEDIDA,
    Activo, FechaCreacion, UsuarioCreacion
)
SELECT
    PK_IdGrupoBien, FK_IdFamilia__SICOP, Descripcion, Clave, ClaveAN, CABM_ACT, CLAVE_CUCOP, MEDIDA,
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SICOP.GrupoBien
WHERE NOT EXISTS (SELECT 1 FROM ALMA.GrupoBien WHERE PKIdGrupoBien = PK_IdGrupoBien);
SET IDENTITY_INSERT ALMA.GrupoBien OFF;
GO

-- ALMA.TipoBien
SET IDENTITY_INSERT [ALMA].[TipoBien] ON;
INSERT INTO [ALMA].[TipoBien] (
    [PKIdTipoBien], [FKIdGrupoBien_ALMA], [FKIdNivel_ALMA], [FKIdPartida_CONTA], [FKIdCuentaContable_CONTA],
    [FKIdUnidades_ALMA], [FKIdLocalizacion_ALMA], [CodigoClave], [Descripcion], [DepreciacionAnual], [Consecutivo],
    [CABMS], [Identificador], [ExistenciaMinima], [ExistenciaMaxima], [TiempoVida], [Pk_IdTratadoInt], [Cuota],
    [ProveeduriaNac], [CatalogoBasico], [CUCOP_PLUS], [FKIdUnidades_Equivalente], [Cantidad_Equivalente],
    [UsuarioCreacion], [FechaCreacion], [FechaModificacion], [UsuarioModificacion], [Activo]
)
SELECT
    s.[PK_IdTipoBien], s.[FK_IdGrupoBien__SICOP], s.[FK_IdNivel__SICOP], s.[FK_IdPartida__SIS], s.[FK_IdCuentaContable__SIS],
    s.[FK_IdUnidades__ALMA], s.[FK_IdLocalizacion__ALMA], s.[CodigoClave], s.[Descripcion], s.[DepreciacionAnual], s.[Consecutivo],
    s.[CABMS], s.[Identificador], s.[ExistenciaMinima], s.[ExistenciaMaxima], s.[TiempoVida], s.[Pk_IdTratadoInt], s.[Cuota],
    s.[ProveeduriaNac], s.[CatalogoBasico], s.[CUCOP_PLUS], s.[FK_IdUnidades_Equivalente], s.[Cantidad_Equivalente],
    1, ISNULL(s.[CT_CreatedDate], GETDATE()),
    s.[CT_ModifiedDate], 1, ISNULL(s.[CT_LIVE], 1)
FROM [BD_PRESUPUESTO].[SICOP].[TipoBien] s
INNER JOIN [ALMA].[GrupoBien] g ON s.[FK_IdGrupoBien__SICOP] = g.[PKIdGrupoBien]
INNER JOIN [ALMA].[Nivel] n ON s.[FK_IdNivel__SICOP] = n.[PKIdNivel]
INNER JOIN [CONTA].[Partida] p ON s.[FK_IdPartida__SIS] = p.[PKIdPartida]
LEFT JOIN [CONTA].[CuentaContable] c ON s.[FK_IdCuentaContable__SIS] = c.[PKIdCuentaContable]
INNER JOIN [ALMA].[Unidades] u1 ON s.[FK_IdUnidades__ALMA] = u1.[PKIdUnidades]
LEFT JOIN [ALMA].[Unidades] u2 ON s.[FK_IdUnidades_Equivalente] = u2.[PKIdUnidades] 
WHERE NOT EXISTS (SELECT 1 FROM [ALMA].[TipoBien] t WHERE t.[PKIdTipoBien] = s.[PK_IdTipoBien])
and s.FK_IdUnidades__ALMA in (select PKIdUnidades from alma.Unidades)
and s.FK_IdUnidades_Equivalente in (select PKIdUnidades from alma.Unidades)
SET IDENTITY_INSERT [ALMA].[TipoBien] OFF;
GO

-- ALMA.EstatusPeriodo (INSERT VALUES)
INSERT INTO [ALMA].[EstatusPeriodo] ([Nombre], [Descripcion], [Activo])
VALUES ('Pendiente',   'Periodo de conteo pendiente de iniciar', 1),
       ('En Proceso',  'Periodo de conteo en proceso',           1),
       ('Completado',  'Periodo de conteo completado',           1),
       ('Cerrado',     'Periodo de conteo cerrado',              1);
GO

-- ALMA.TipoConteo (INSERT VALUES)
INSERT INTO [ALMA].[TipoConteo] ([Nombre], [Descripcion], [Activo])
VALUES ('Cíclico',   'Conteo cíclico programado',       1),
       ('Anual',     'Conteo anual de inventario',      1),
       ('Auditoría', 'Conteo por auditoría externa',    1),
       ('Aleatorio', 'Conteo aleatorio no programado',  1);
GO

-- ALMA.EstatusArticuloConteo (INSERT VALUES)
INSERT INTO [ALMA].[EstatusArticuloConteo] ([Nombre], [Descripcion], [Orden], [Color], [Icono], [BadgeTexto], [Activo])
VALUES ('Pendiente 1er Conteo',  'Artículo pendiente de primer conteo',    1, '#FFA500', 'pending', '1er Conteo', 1),
       ('Pendiente 2do Conteo',  'Artículo pendiente de segundo conteo',   2, '#FF8C00', 'pending', '2do Conteo', 1),
       ('Requiere 3er Conteo',   'Artículo que requiere un tercer conteo', 3, '#FF4500', 'warning', '3er Conteo', 1),
       ('Concluido',             'Artículo con conteo finalizado',         4, '#28A745', 'check',   'Concluido',  1),
       ('En Discrepancia',       'Artículo con diferencias sin resolver',  5, '#DC3545', 'error',   'Discrepancia', 1);
GO

-- ALMA.TipoPatrimonio (INSERT VALUES)
INSERT INTO [ALMA].[TipoPatrimonio] ([Descripcion], [UsuarioCreacion])
VALUES ('BIENES PROPIOS', 1),
       ('ARRENDADOS', 1),
       ('BIENES NO PERTENECIENTES AL INSTITUTO', 1);
GO

-- ALMA.TipoPatrimonio (migración desde BD_PRESUPUESTO)
SET IDENTITY_INSERT ALMA.TipoPatrimonio ON;
INSERT INTO ALMA.TipoPatrimonio (PKIdTipoPatrimonio, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoPatrimonio, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SICOP.TipoPatrimonio
WHERE NOT EXISTS (SELECT 1 FROM ALMA.TipoPatrimonio WHERE PKIdTipoPatrimonio = PK_IdTipoPatrimonio);
SET IDENTITY_INSERT ALMA.TipoPatrimonio OFF;
GO

-- ALMA.Marca (desde 01.CONTA.CuentaContable)
SET IDENTITY_INSERT [ALMA].[Marca] ON;
INSERT INTO [ALMA].[Marca] ([PKIdMarca], [Descripcion], [Activo], [UsuarioCreacion], [FechaCreacion])
SELECT [PK_IdMarca], [Descripcion], [CT_LIVE], [CT_CreatedBy], [CT_CreatedDate]
FROM [BD_PRESUPUESTO].[SICOP].[Marca];
SET IDENTITY_INSERT [ALMA].[Marca] OFF;
GO

-- ALMA.Marca (desde 05.Catalogo - Patrimonio)
SET IDENTITY_INSERT ALMA.Marca ON;
INSERT INTO ALMA.Marca (PKIdMarca, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdMarca, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SICOP.Marca
WHERE NOT EXISTS (SELECT 1 FROM ALMA.Marca WHERE PKIdMarca = PK_IdMarca);
SET IDENTITY_INSERT ALMA.Marca OFF;
GO

-- ALMA.EstadoBien
SET IDENTITY_INSERT [ALMA].[EstadoBien] ON;
INSERT INTO [ALMA].[EstadoBien] (
    [PKIdEstadoBien], [DESCRIPCION_GENERAL], [DESCRIPCION_ESPECIFICA], [DESCRIPCION_CORTA],
    [Activo], [UsuarioCreacion], [FechaCreacion]
)
SELECT
    [PK_IdEstadoBien], [DESCRIPCION_GENERAL], [DESCRIPCION_ESPECIFICA], [DESCRIPCION_CORTA],
    [CT_LIVE], [CT_CreatedBy], [CT_CreatedDate]
FROM [BD_PRESUPUESTO].[SICOP].[EstadoBien];
SET IDENTITY_INSERT [ALMA].[EstadoBien] OFF;
GO

-- ALMA.Material
SET IDENTITY_INSERT [ALMA].[Material] ON;
INSERT INTO [ALMA].[Material] ([PKIdMaterial], [Descripcion], [Activo], [UsuarioCreacion], [FechaCreacion])
SELECT [PK_IdMaterial], [Descripcion], [CT_LIVE], [CT_CreatedBy], [CT_CreatedDate]
FROM [BD_PRESUPUESTO].[SICOP].[Material];
SET IDENTITY_INSERT [ALMA].[Material] OFF;
GO

-- ALMA.TipoAdquisicion (desde 01.CONTA.CuentaContable)
SET IDENTITY_INSERT [ALMA].[TipoAdquisicion] ON;
INSERT INTO [ALMA].[TipoAdquisicion] (
    [PKIdTipoAdq], [Clave], [Descripcion], [Descripmovto], [Activo], [UsuarioCreacion], [FechaCreacion]
)
SELECT
    [PK_IdTipoAdq], [Clave], [Descripcion], [Descripmovto], [CT_LIVE], [CT_CreatedBy], [CT_CreatedDate]
FROM [BD_PRESUPUESTO].[SICOP].[TipoAdq];
SET IDENTITY_INSERT [ALMA].[TipoAdquisicion] OFF;
GO

-- ALMA.TipoAdquisicion (desde 05.Catalogo - Patrimonio)
SET IDENTITY_INSERT ALMA.TipoAdquisicion ON;
INSERT INTO ALMA.TipoAdquisicion (PKIdTipoAdq, Clave, Descripcion, Descripmovto, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoAdq, Clave, Descripcion, Descripmovto, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.SICOP.TipoAdq
WHERE NOT EXISTS (SELECT 1 FROM ALMA.TipoAdquisicion WHERE PKIdTipoAdq = PK_IdTipoAdq);
SET IDENTITY_INSERT ALMA.TipoAdquisicion OFF;
GO

-- ALMA.Bien
SET IDENTITY_INSERT [ALMA].[Bien] ON;
INSERT INTO [ALMA].[Bien] (
    [PKIdBien], [FKIdGrupoBien_ALMA], [FKIdTipoBien_ALMA], [FKIdArea_SIS], [FKIdProveedor_SIS],
    [FKIdEstadoBien_ALMA], [FKIdTipoPatrimonio_ALMA], [FKIdMarca_ALMA], [FKIdMaterial_ALMA],
    [FKIdTipoAdq_ALMA], [FKIdPartida_CONTA], [Clave], [ClaveAnt], [Descripcion], [Modelo], [Serie],
    [Requisicion], [Factura], [Costo], [FechaAdq], [Referencia], [Notas], [Ubicacion], [AAdquisicion],
    [Frente], [Fondo], [Altura], [Diametro], [VerificacionesDias], [MantenimientoDias], [Mantenimiento],
    [Calibracion], [Rango], [Resolucion], [FechaUltInv], [FechaReqscn], [Estatus], [Caracteristicas],
    [Resguardo], [ResguardoAnterior], [RelId], [ValorRescate], [ValorActual], [Antiguedad], [Progresivo],
    [Consecutivo], [ClaveHist], [EstaResguardado], [FechaResguardado], [Localizado], [esContabilizado],
    [Activo], [FechaCreacion], [UsuarioCreacion]
)
SELECT
    [PK_IdBien], [FK_IdGrupoBien__SICOP], [FK_IdTipoBien__SICOP], [FK_IdAreaUlt__SIS], [FK_IdProveedor__SIS],
    [FK_IdEstadoBien__SICOP], [FK_IdTipoPatrimonio__SICOP], [FK_IdMarca__SICOP], [FK_IdMaterial__SICOP],
    [FK_IdTipoAdq__SICOP], [FK_IdPartida__SIS], [Clave], [ClaveAnt], [Descripcion], [Modelo], [Serie],
    [Requisicion], [Factura], [Costo], [FechaAdq], [Referencia], [Notas], [Ubicacion], [AAdquisicion],
    [Frente], [Fondo], [Altura], [Diametro], [VerificacionesDias], [MantenimientoDias], [Mantenimiento],
    [Calibracion], [Rango], [Resolucion], [FechaUltInv], [FechaReqscn], [Estatus], [Caracteristicas],
    [Resguardo], [ResguardoAnterior], [RelId], [ValorRescate], [ValorActual], [Antiguedad], [Progresivo],
    [Consecutivo], [ClaveHist], [EstaResguardado], [FechaResguardado], [Localizado], [esContabilizado],
    [CT_LIVE], [CT_CreatedDate], [CT_CreatedBy]
FROM [BD_PRESUPUESTO].[SICOP].[Bien]
WHERE [FK_IdPartida__SIS] IN (SELECT [PKIdPartida] FROM [CONTA].[Partida])
  AND [FK_IdProveedor__SIS] IN (SELECT [PKIdProveedor] FROM [SIS].[Proveedor])
  AND [FK_IdTipoBien__SICOP] IN (SELECT [PKIdTipoBien] FROM [ALMA].[TipoBien]);
SET IDENTITY_INSERT [ALMA].[Bien] OFF;
GO

-- ALMA.MotivoES (migración desde BD_PRESUPUESTO)
SET IDENTITY_INSERT ALMA.MotivoES ON;
INSERT INTO ALMA.MotivoES (PKIdMotivoES, Descripcion, AplicaEntrada, AplicaSalida, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdMotivoES, Descripcion, AplicaEntrada, AplicaSalida, 
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ALMA.MotivoES
WHERE NOT EXISTS (SELECT 1 FROM ALMA.MotivoES WHERE PKIdMotivoES = PK_IdMotivoES);
SET IDENTITY_INSERT ALMA.MotivoES OFF;
GO

-- ALMA.EstatusSolicitud (migración desde BD_PRESUPUESTO)
SET IDENTITY_INSERT ALMA.EstatusSolicitud ON;
INSERT INTO ALMA.EstatusSolicitud (PKIdEstatusSolicitud, Descripcion, Color, Activo, FechaCreacion, UsuarioCreacion)
SELECT 
    PK_IdEstatusSolicitud, Descripcion, Color, 
    ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.ALMA.EstatusSolicitud
WHERE NOT EXISTS (SELECT 1 FROM ALMA.EstatusSolicitud WHERE PKIdEstatusSolicitud = PK_IdEstatusSolicitud);
SET IDENTITY_INSERT ALMA.EstatusSolicitud OFF;
GO

-- =============================================
-- TES
-- =============================================

-- TES.TipoMoneda
SET IDENTITY_INSERT TES.TipoMoneda ON;
INSERT INTO TES.TipoMoneda (PKIdTipoMoneda, FKIdPais_SIS, Descripcion, CodigoISO4217, Simbolo, Decimales, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoMoneda, Fk_IdPais__SIS = 1, Descripcion, NULL, NULL, 2, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoMoneda
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoMoneda WHERE PKIdTipoMoneda = PK_IdTipoMoneda);
SET IDENTITY_INSERT TES.TipoMoneda OFF;
GO

-- TES.TipoCambio
SET IDENTITY_INSERT TES.TipoCambio ON;
INSERT INTO TES.TipoCambio (PKIdTipoCambio, FKIdTipoMoneda_TES, Cantidad, Fecha, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoCambio, FK_IdTipoMoneda__TES, Cantidad, Fecha, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoCambio
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoCambio WHERE PKIdTipoCambio = PK_IdTipoCambio);
SET IDENTITY_INSERT TES.TipoCambio OFF;
GO

-- TES.TipoInversion
SET IDENTITY_INSERT TES.TipoInversion ON;
INSERT INTO TES.TipoInversion (PKIdTipoInversion, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoInversion, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoInversion
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoInversion WHERE PKIdTipoInversion = PK_IdTipoInversion);
SET IDENTITY_INSERT TES.TipoInversion OFF;
GO

-- TES.TipoPago
SET IDENTITY_INSERT TES.TipoPago ON;
INSERT INTO TES.TipoPago (PKIdTipoPago, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoPago, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoPago
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoPago WHERE PKIdTipoPago = PK_IdTipoPago);
SET IDENTITY_INSERT TES.TipoPago OFF;
GO

-- TES.TipoPagoSF
SET IDENTITY_INSERT TES.TipoPagoSF ON;
INSERT INTO TES.TipoPagoSF (PKIdTipoPagoSF, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoPagoSF, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoPagoSF
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoPagoSF WHERE PKIdTipoPagoSF = PK_IdTipoPagoSF);
SET IDENTITY_INSERT TES.TipoPagoSF OFF;
GO

-- TES.TipoSolicitudCLC
SET IDENTITY_INSERT TES.TipoSolicitudCLC ON;
INSERT INTO TES.TipoSolicitudCLC (PKIdTipoSolicitudCLC, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
SELECT PK_IdTipoSolicitudCLC, Descripcion, ISNULL(CT_LIVE, 1), ISNULL(CT_CreatedDate, GETDATE()), ISNULL(CT_CreatedBy, 1)
FROM BD_PRESUPUESTO.TES.TipoSolicitudCLC
WHERE NOT EXISTS (SELECT 1 FROM TES.TipoSolicitudCLC WHERE PKIdTipoSolicitudCLC = PK_IdTipoSolicitudCLC);
SET IDENTITY_INSERT TES.TipoSolicitudCLC OFF;
GO

PRINT 'Migración completada exitosamente.';
GO
