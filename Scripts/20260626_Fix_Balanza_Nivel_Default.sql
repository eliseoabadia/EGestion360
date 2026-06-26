USE [GestionEmpresarial];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*
    Fix puntual para Balanza de Comprobacion.

    El visor puede llegar con p_nivel = 0 desde enlaces legacy o defaults del .repx.
    CONTA.SPR_Get_Balanza no regresa filas con nivel 0, asi que se normaliza a 10
    para mostrar el detalle completo.
*/

DECLARE @ObjectId int = OBJECT_ID(N'[CONTA].[SPR_Get_Balanza]');
DECLARE @Definition nvarchar(max);
DECLARE @Upper nvarchar(max);
DECLARE @CreatePos int;
DECLARE @AfterCreatePos int;

IF @ObjectId IS NULL
BEGIN
    THROW 51020, N'No existe CONTA.SPR_Get_Balanza.', 1;
END;

SET @Definition = OBJECT_DEFINITION(@ObjectId);
SET @Definition = REPLACE(@Definition, CHAR(13), N'');

IF CHARINDEX(N'IF @p_nivel IS NULL OR @p_nivel <= 0', @Definition) = 0
BEGIN
    SET @Definition = REPLACE(
        @Definition,
        N'SET NOCOUNT ON;',
        N'SET NOCOUNT ON;

    IF @p_nivel IS NULL OR @p_nivel <= 0
    BEGIN
        SET @p_nivel = 10;
    END;'
    );

    IF @@ROWCOUNT = 0 OR CHARINDEX(N'IF @p_nivel IS NULL OR @p_nivel <= 0', @Definition) = 0
    BEGIN
        THROW 51021, N'No se pudo insertar normalizacion de p_nivel en CONTA.SPR_Get_Balanza.', 1;
    END;
END;

SET @Upper = UPPER(@Definition);
SET @CreatePos = CHARINDEX(N'CREATE', @Upper);

IF @CreatePos = 0
BEGIN
    THROW 51022, N'No se pudo ubicar CREATE en CONTA.SPR_Get_Balanza.', 1;
END;

SET @AfterCreatePos = @CreatePos + LEN(N'CREATE');

WHILE @AfterCreatePos <= LEN(@Upper)
  AND SUBSTRING(@Upper, @AfterCreatePos, 1) IN (N' ', NCHAR(9), NCHAR(10))
BEGIN
    SET @AfterCreatePos += 1;
END;

IF SUBSTRING(@Upper, @AfterCreatePos, LEN(N'OR ALTER')) <> N'OR ALTER'
BEGIN
    SET @Definition = STUFF(@Definition, @CreatePos, LEN(N'CREATE'), N'CREATE OR ALTER');
END;

EXEC sys.sp_executesql @Definition;
GO

PRINT N'Validacion SPR_Get_Balanza con p_nivel = 0';
EXEC [CONTA].[SPR_Get_Balanza]
    @p_FecInicio = N'2026-01-01',
    @p_FecFin = N'2026-06-25',
    @p_nivel = 0,
    @p_UsaMesTrece = 0,
    @p_SoloCuentasPres = 0;
GO
