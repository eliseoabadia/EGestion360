-- Datos del esquema TES
SET NOCOUNT ON;
GO

PRINT N'Insertando datos en [TES].[TipoInversion]';
SET IDENTITY_INSERT [TES].[TipoInversion] ON;
INSERT INTO [TES].[TipoInversion] ([PKIdTipoInversion], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (1, N'prueba 24', 1, CONVERT(datetime2, '2025-03-26T10:46:56.4966667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoInversion] ([PKIdTipoInversion], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (2, N'prueba 80', 0, CONVERT(datetime2, '2025-03-26T10:47:34.5766667', 126), 1, NULL, NULL);
SET IDENTITY_INSERT [TES].[TipoInversion] OFF;
GO

PRINT N'Insertando datos en [TES].[TipoMoneda]';
SET IDENTITY_INSERT [TES].[TipoMoneda] ON;
INSERT INTO [TES].[TipoMoneda] ([PKIdTipoMoneda], [FKIdPais_SIS], [Descripcion], [CodigoISO4217], [Simbolo], [Decimales], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (1, 1, N'moneda', NULL, NULL, 2, 1, CONVERT(datetime2, '2025-03-26T10:47:59.9333333', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoMoneda] ([PKIdTipoMoneda], [FKIdPais_SIS], [Descripcion], [CodigoISO4217], [Simbolo], [Decimales], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (2, 1, N'usd', NULL, NULL, 2, 0, CONVERT(datetime2, '2025-03-26T10:48:13.1866667', 126), 1, NULL, NULL);
INSERT INTO [TES].[TipoMoneda] ([PKIdTipoMoneda], [FKIdPais_SIS], [Descripcion], [CodigoISO4217], [Simbolo], [Decimales], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]) VALUES (3, 1, N'Euros', NULL, NULL, 2, 1, CONVERT(datetime2, '2025-03-26T10:48:34.0666667', 126), 1, NULL, NULL);
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

