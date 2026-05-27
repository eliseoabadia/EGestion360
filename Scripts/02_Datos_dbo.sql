-- Datos del esquema dbo
SET NOCOUNT ON;
GO



PRINT N'Insertando datos en [dbo].[AspNetClaimTypes]';
SET IDENTITY_INSERT [dbo].[AspNetClaimTypes] ON;
INSERT INTO [dbo].[AspNetClaimTypes] ([Id], [Name], [Created]) VALUES (1, N'Template', CONVERT(datetime2, '2026-05-13T12:48:23.0100000', 126));
INSERT INTO [dbo].[AspNetClaimTypes] ([Id], [Name], [Created]) VALUES (2, N'Role', CONVERT(datetime2, '2026-05-13T12:48:23.0100000', 126));
SET IDENTITY_INSERT [dbo].[AspNetClaimTypes] OFF;
GO


PRINT N'Insertando datos en [dbo].[AspNetRoles]';
INSERT INTO [dbo].[AspNetRoles] ([Id], [Name], [Code]) VALUES (N'67A6E679-DBC4-402D-AE6E-7F28DDB11BD8', N'CONFIGURATION', N'30000');
INSERT INTO [dbo].[AspNetRoles] ([Id], [Name], [Code]) VALUES (N'71804e93-9753-4684-84fd-cf037349c111', N'SYSTEMADMIN', N'10000');
INSERT INTO [dbo].[AspNetRoles] ([Id], [Name], [Code]) VALUES (N'739CC754-488B-4BB4-B7FB-62F6BF3C26D0', N'SOPORTE', N'20000');
GO

PRINT N'Insertando datos en [dbo].[AspNetUserRoles]';
INSERT INTO [dbo].[AspNetUserRoles] ([UserId], [RoleId], [ExpireDate]) VALUES (N'52BEDE02-1F81-41E2-A93E-8666AB0873CE', N'71804e93-9753-4684-84fd-cf037349c111', CONVERT(datetime2, '2027-12-31T00:00:00.0000000', 126));
GO

PRINT N'Insertando datos en [dbo].[AspNetUsers]';
INSERT INTO [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [ReferenceId], [AccessNumber], [PkIdUsuario]) VALUES (N'52BEDE02-1F81-41E2-A93E-8666AB0873CE', N'', 1, N'UOxg2B7HCZwZZ/drSkwHrA==', N'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, N'0000010000', 1);
INSERT INTO [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [ReferenceId], [AccessNumber], [PkIdUsuario]) VALUES (N'78DC5D0A-A786-448D-A0F4-01F7FCD00A6D', N'', 1, N'UOxg2B7HCZwZZ/drSkwHrA==', N'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, N'0000010000', 1);
INSERT INTO [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [ReferenceId], [AccessNumber], [PkIdUsuario]) VALUES (N'DB534BEF-4348-4686-95AB-F7A1872222AC', N'', 1, N'UOxg2B7HCZwZZ/drSkwHrA==', N'C5F91B8B-9E25-4576-96E7-CD3317F1AB87', NULL, 0, 0, NULL, 0, 0, 10000, N'0000010000', 1);
GO

