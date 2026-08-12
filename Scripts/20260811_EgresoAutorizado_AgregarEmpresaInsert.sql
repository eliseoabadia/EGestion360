/*
    Corrige PRES.SP_MantenimientoEgresoAutorizado para persistir la empresa
    al autorizar un presupuesto proyectado. Es idempotente y conserva el
    resto de la definición instalada del procedimiento.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @Definicion nvarchar(max) = OBJECT_DEFINITION(OBJECT_ID(N'PRES.SP_MantenimientoEgresoAutorizado'));

IF @Definicion IS NULL
    THROW 51000, N'No existe PRES.SP_MantenimientoEgresoAutorizado.', 1;

IF CHARINDEX(
       N'FKIdEmpresa_SIS,',
       SUBSTRING(@Definicion, CHARINDEX(N'INSERT INTO PRES.EgresoAutorizado', @Definicion), 150)
   ) = 0
BEGIN
    SET @Definicion = REPLACE(
        @Definicion,
        N'INSERT INTO PRES.EgresoAutorizado (
                FKIdPrograma_PRES,',
        N'INSERT INTO PRES.EgresoAutorizado (
                FKIdEmpresa_SIS,
                FKIdPrograma_PRES,'
    );

    SET @Definicion = REPLACE(
        @Definicion,
        N'VALUES (
                @FKIdPrograma_PRES,',
        N'VALUES (
                @FKIdEmpresa_SIS,
                @FKIdPrograma_PRES,'
    );

    SET @Definicion = REPLACE(@Definicion, N'CREATE PROCEDURE', N'ALTER PROCEDURE');
    SET @Definicion = REPLACE(@Definicion, N'CREATE   PROCEDURE', N'ALTER PROCEDURE');
    SET @Definicion = REPLACE(@Definicion, N'CREATE OR ALTER PROCEDURE', N'ALTER PROCEDURE');

    EXEC sys.sp_executesql @Definicion;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.sql_modules
    WHERE object_id = OBJECT_ID(N'PRES.SP_MantenimientoEgresoAutorizado')
      AND CHARINDEX(
              N'FKIdEmpresa_SIS,',
              SUBSTRING(definition, CHARINDEX(N'INSERT INTO PRES.EgresoAutorizado', definition), 150)
          ) > 0
)
    THROW 51001, N'No fue posible agregar FKIdEmpresa_SIS al INSERT del procedimiento.', 1;
GO
