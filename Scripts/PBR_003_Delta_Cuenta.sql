USE [GestionEmpresarial];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF SCHEMA_ID(N'PBR') IS NULL
    EXEC(N'CREATE SCHEMA PBR AUTHORIZATION dbo;');
GO

IF OBJECT_ID(N'PBR.Cuenta', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.Cuenta
    (
        Id int IDENTITY(1,1) NOT NULL,
        Codigo nvarchar(10) NOT NULL,
        Nombre nvarchar(500) NOT NULL,
        Tipo nvarchar(50) NOT NULL CONSTRAINT DF_PBR_Cuenta_Tipo DEFAULT ('ACTIVO'),
        Activa bit NOT NULL CONSTRAINT DF_PBR_Cuenta_Activa DEFAULT ((1)),
        FechaCreacion datetime2(7) NOT NULL CONSTRAINT DF_PBR_Cuenta_FechaCreacion DEFAULT (getdate()),
        CONSTRAINT PK_PBR_Cuenta PRIMARY KEY (Id)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.Cuenta)
BEGIN
    SET IDENTITY_INSERT PBR.Cuenta ON;
    INSERT INTO PBR.Cuenta (Id, Codigo, Nombre, Tipo, Activa, FechaCreacion)
    SELECT Id, Codigo, Nombre, Tipo, Activa, FechaCreacion
    FROM [GE_Datos].PBR.Cuenta;
    SET IDENTITY_INSERT PBR.Cuenta OFF;
END;
GO
