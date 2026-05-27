-- Datos del esquema TES
SET NOCOUNT ON;
GO

PRINT N'Insertando datos en [TES].[TipoDoctoCLC]';
SET IDENTITY_INSERT [TES].[TipoDoctoCLC] ON;
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (1, N'F', N'Factura ', N'P', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (2, N'RF', N'Relacion de facturas', N'P', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (3, N'R', N'Recibo', N'P', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (4, N'N', N'Nomina ', N'F', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (5, N'RR', N'Relacion de Recibos ', N'P', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (6, N'E', N'Estimación de obra ', N'F', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (7, N'O', N'Otros', N'F', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (8, N'RO', N'Relación otros ', N'F', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (9, N'AB', N'Aguinaldos najas ', N'F', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (10, N'NF', N'Nómina finiquitos', N'F', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (11, N'NE', N'Nómina extraordinaria', N'F', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (12, N'RI', N'Registro de Intereses', N'P', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (13, N'GO', N'Gastos de operación presupuestal', N'F', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (14, N'NO', N'Gastos de nóminas y terceros institucionales', N'P', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (15, N'GS', N'Gastos servicio social, impuestos sobre nómina', N'P', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (16, N'N', N'Convenio', N'P', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoDoctoCLC] ([PKIdTipoDoctoCLC], [Clave], [Nombre], [TipoRecurso], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (1016, N'VBL', N'Bases de licitación', N'P', 1, CONVERT(datetime2, '2024-09-18T18:20:03.7866667', 126), 1, NULL, NULL);
SET IDENTITY_INSERT [TES].[TipoDoctoCLC] OFF;
GO

PRINT N'Insertando datos en [TES].[TipoInversion]';
SET IDENTITY_INSERT [TES].[TipoInversion] ON;
INSERT INTO [TES].[TipoInversion] ([PKIdTipoInversion], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (1, N'prueba 24', 1, CONVERT(datetime2, '2025-03-26T10:46:56.4966667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoInversion] ([PKIdTipoInversion], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (2, N'prueba 80', 0, CONVERT(datetime2, '2025-03-26T10:47:34.5766667', 126), 1, NULL, NULL);
SET IDENTITY_INSERT [TES].[TipoInversion] OFF;
GO

PRINT N'Insertando datos en [TES].[TipoPlazo]';
IF NOT EXISTS (SELECT 1 FROM [TES].[TipoPlazo] WHERE [Descripcion] = N'Corto plazo' AND [Dias] = 30)
    INSERT INTO [TES].[TipoPlazo] ([Descripcion], [Dias], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    VALUES (N'Corto plazo', 30, 1, SYSDATETIME(), 1, NULL, NULL);

IF NOT EXISTS (SELECT 1 FROM [TES].[TipoPlazo] WHERE [Descripcion] = N'Mediano plazo' AND [Dias] = 180)
    INSERT INTO [TES].[TipoPlazo] ([Descripcion], [Dias], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    VALUES (N'Mediano plazo', 180, 1, SYSDATETIME(), 1, NULL, NULL);

IF NOT EXISTS (SELECT 1 FROM [TES].[TipoPlazo] WHERE [Descripcion] = N'Largo plazo' AND [Dias] = 365)
    INSERT INTO [TES].[TipoPlazo] ([Descripcion], [Dias], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    VALUES (N'Largo plazo', 365, 1, SYSDATETIME(), 1, NULL, NULL);
GO

PRINT N'Insertando datos en [TES].[TipoMoneda]';
SET IDENTITY_INSERT [TES].[TipoMoneda] ON;
INSERT INTO [TES].[TipoMoneda] ([PKIdTipoMoneda], [FKIdPais_SIS], [Descripcion], [CodigoISO4217], [Simbolo], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (1, 1, N'Peso Mexicano', N'MXN', N'$', 1, CONVERT(datetime2, '2025-03-26T10:47:59.9333333', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoMoneda] ([PKIdTipoMoneda], [FKIdPais_SIS], [Descripcion], [CodigoISO4217], [Simbolo], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (2, 1, N'Dolar Estadounidense', N'USD', N'US$', 0, CONVERT(datetime2, '2025-03-26T10:48:13.1866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoMoneda] ([PKIdTipoMoneda], [FKIdPais_SIS], [Descripcion], [CodigoISO4217], [Simbolo], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (3, 1, N'Euro', N'EUR', N'EUR', 1, CONVERT(datetime2, '2025-03-26T10:48:34.0666667', 126), 1, NULL, NULL);
SET IDENTITY_INSERT [TES].[TipoMoneda] OFF;
GO

PRINT N'Insertando datos en [TES].[TipoPago]';
SET IDENTITY_INSERT [TES].[TipoPago] ON;
INSERT INTO [TES].[TipoPago] ([PKIdTipoPago], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (1, N'prueba teso Lore 56', 0, CONVERT(datetime2, '2025-03-26T10:42:16.7066667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoPago] ([PKIdTipoPago], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (2, N'pruebas lore 3', 1, CONVERT(datetime2, '2025-03-26T10:46:00.0200000', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoPago] ([PKIdTipoPago], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (3, N'pago 100', 1, CONVERT(datetime2, '2025-03-26T10:48:58.6000000', 126), 1, NULL, NULL);
SET IDENTITY_INSERT [TES].[TipoPago] OFF;
GO

PRINT N'Insertando datos en [TES].[TipoPagoSF]';
SET IDENTITY_INSERT [TES].[TipoPagoSF] ON;
INSERT INTO [TES].[TipoPagoSF] ([PKIdTipoPagoSF], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (1, N'sin factura100', 1, CONVERT(datetime2, '2025-03-26T10:49:15.2666667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoPagoSF] ([PKIdTipoPagoSF], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (2, N'pago 200', 1, CONVERT(datetime2, '2025-03-26T10:49:26.3533333', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoPagoSF] ([PKIdTipoPagoSF], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (3, N'pago 56', 1, CONVERT(datetime2, '2025-03-26T10:49:40.7166667', 126), 1, NULL, NULL);
SET IDENTITY_INSERT [TES].[TipoPagoSF] OFF;
GO

PRINT N'Insertando datos en [TES].[TipoSolicitudCLC]';
SET IDENTITY_INSERT [TES].[TipoSolicitudCLC] ON;
INSERT INTO [TES].[TipoSolicitudCLC] ([PKIdTipoSolicitudCLC], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (1, N'clc 45', 1, CONVERT(datetime2, '2025-03-26T10:49:52.8000000', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoSolicitudCLC] ([PKIdTipoSolicitudCLC], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (2, N'clc 8965', 1, CONVERT(datetime2, '2025-03-26T10:50:00.8800000', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoSolicitudCLC] ([PKIdTipoSolicitudCLC], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (3, N'clc 67', 1, CONVERT(datetime2, '2025-03-26T10:50:10.0566667', 126), 1, NULL, NULL);
SET IDENTITY_INSERT [TES].[TipoSolicitudCLC] OFF;
GO

INSERT INTO tes.Banco
    (FKIdEmpresa_SIS, Clave, Nombre, NombreCorto, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
VALUES
    (1, '001', 'BANCO NACIONAL DE MÉXICO', 'BANAMEX', 1, GETDATE(), 1, NULL, NULL),
    (1, '002', 'BANCO SANTANDER MÉXICO', 'SANTANDER', 1, GETDATE(), 1, NULL, NULL),
    (1, '003', 'BBVA MÉXICO', 'BBVA', 1, GETDATE(), 1, NULL, NULL);

    SET IDENTITY_INSERT tes.CuentaBancaria ON;

INSERT INTO tes.CuentaBancaria
    (PKIdCuentaBancaria, FKIdEmpresa_SIS, FKIdBanco_TES, FKIdTipoMoneda_TES,
     NumeroCuenta, CLABE, Titular, SaldoInicial, SaldoActual,
     FechaApertura, Activo, FechaCreacion, UsuarioCreacion,
     FechaModificacion, UsuarioModificacion)
VALUES
    (1, 1, 1, 1, '70700501-7', NULL, 'CUENTA 70700501-7', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    (2, 1, 1, 1, '70700500-9', NULL, 'CUENTA 70700500-9', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    --(3, 1, 2, 1, '492217', NULL, 'CUENTA 492217', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    --(4, 1, 2, 1, '492208', NULL, 'CUENTA 492208', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    --(5, 1, 2, 1, '492187', NULL, 'CUENTA 492187', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    --(6, 1, 2, 1, '697763', NULL, 'CUENTA 697763', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    (7, 1, 2, 1, '4189281060157428', NULL, 'TARJETA IFT PRESIDENCIA', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    (8, 1, 2, 1, '4189281060157436', NULL, 'TARJETA IFT UNIDAD DE CONCESIONES Y SERVICIOS', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    (9, 1, 2, 1, '4189281060157444', NULL, 'TARJETA IFT UNIDAD DE ESPECTRO RADIOELECTRICO', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    (10, 1, 2, 1, '4189281060157451', NULL, 'TARJETA IFT UNIDAD DE POLITICA REGULATORIA', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    (11, 1, 2, 1, '4189281060157469', NULL, 'TARJETA IFT ASUNTOS INTERNACIONALES', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    (12, 1, 2, 1, '4189281060157477', NULL, 'TARJETA IFT UNIDAD DE CUMPLIMIENTO', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    (13, 1, 2, 1, '4189281060157162', NULL, 'TARJETA IFT UNIDAD DE ADMINISTRACION', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    (14, 1, 3, 1, '83884', NULL, 'CUENTA 83884', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL)
    --(15, 1, 1, 1, '0197496516', NULL, 'CUENTA 0197496516', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    --(16, 1, 2, 1, '300158178', NULL, 'INTERACCIONES 300158178', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    --(17, 1, 3, 1, '0097801', NULL, 'SABADELL 0097801', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL),
    --(18, 1, 1, 1, '7423853', NULL, 'MULTIVA 7423853', 0, 0, '2025-08-05', 1, GETDATE(), 1, NULL, NULL);

SET IDENTITY_INSERT tes.CuentaBancaria OFF;


INSERT INTO TES.TipoInversion
    (Descripcion, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
VALUES
    ('Acciones', 1, GETDATE(), 1 , NULL, NULL),
    ('Bonos', 1, GETDATE(), 1 , NULL, NULL),
    ('Fondos de Inversión', 1, GETDATE(), 1 , NULL, NULL),
    ('Bienes Raíces', 1, GETDATE(), 1 , NULL, NULL),
    ('Certificados de Depósito', 1, GETDATE(), 1 , NULL, NULL),
    ('Criptomonedas', 1, GETDATE(), 1 , NULL, NULL),
    ('ETF (Fondos Cotizados)', 1, GETDATE(), 1 , NULL, NULL),
    ('Materias Primas', 1, GETDATE(), 1 , NULL, NULL);

select * from tes.IntermediarioFinanciero

INSERT INTO tes.IntermediarioFinanciero
    (FKIdEmpresa_SIS, Clave, Nombre, RazonSocial, RFC, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
VALUES
    (1, '001', 'BBVA México', 'Banco Bilbao Vizcaya Argentaria México, S.A.', 'BBM9705191H0', 1, GETDATE(), 1, NULL, NULL),
    (1, '002', 'Santander México', 'Banco Santander (México), S.A.', 'BSM970519K45', 1, GETDATE(), 1, NULL, NULL),
    (1, '003', 'Banorte', 'Banco Mercantil del Norte, S.A.', 'BMN970519L23', 1, GETDATE(), 1, NULL, NULL),
    (1, '004', 'Citibanamex', 'Banco Nacional de México, S.A.', 'BNM970519M67', 1, GETDATE(), 1, NULL, NULL),
    (1, '005', 'HSBC México', 'HSBC México, S.A.', 'HSM970519N89', 1, GETDATE(), 1, NULL, NULL),
    (1, '006', 'Inbursa', 'Banco Inbursa, S.A.', 'BIS970519P12', 1, GETDATE(), 1, NULL, NULL),
    (1, '007', 'Scotiabank México', 'Scotiabank Inverlat, S.A.', 'SBI970519Q34', 1, GETDATE(), 1, NULL, NULL),
    (1, '008', 'Banco Azteca', 'Banco Azteca, S.A.', 'BAZ970519R56', 1, GETDATE(), 1, NULL, NULL);


    TES.TipoPlazo

    INSERT INTO TES.TipoPlazo
    (Descripcion, Dias, Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion)
VALUES
    ('Plazo 7 días', 7, 1, GETDATE(), 1 , NULL, NULL),
    ('Plazo 14 días', 14, 1, GETDATE(), 1 , NULL, NULL),
    ('Plazo 30 días', 30, 1, GETDATE(), 1 , NULL, NULL),
    ('Plazo 60 días', 60, 1, GETDATE(), 1 , NULL, NULL),
    ('Plazo 90 días', 90, 1, GETDATE(), 1 , NULL, NULL),
    ('Plazo 180 días', 180, 1, GETDATE(), 1 , NULL, NULL),
    ('Plazo 365 días', 365, 1, GETDATE(), 1 , NULL, NULL),
    ('Plazo 730 días (2 años)', 730, 1, GETDATE(), 1 , NULL, NULL);
    