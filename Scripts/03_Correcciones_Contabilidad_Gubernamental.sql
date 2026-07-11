SET XACT_ABORT ON;
GO

IF COL_LENGTH(N'CONTA.MatrizConversion', N'FKIdTipoGasto_PRES') IS NULL
BEGIN
    ALTER TABLE CONTA.MatrizConversion ADD FKIdTipoGasto_PRES int NULL;
END;
GO

BEGIN TRANSACTION;

DECLARE @TipoGastoCorriente int =
(
    SELECT TOP (1) PKIdTipoGasto
    FROM PRES.TipoGasto
    WHERE Clave = 1 AND Activo = 1
    ORDER BY PKIdTipoGasto
);

IF @TipoGastoCorriente IS NULL
    THROW 51000, 'No existe el Tipo de Gasto 1 activo. Corrija PRES.TipoGasto antes de ejecutar esta migracion.', 1;

UPDATE CONTA.MatrizConversion
SET FKIdTipoGasto_PRES = @TipoGastoCorriente
WHERE FKIdTipoGasto_PRES IS NULL;

ALTER TABLE CONTA.MatrizConversion ALTER COLUMN FKIdTipoGasto_PRES int NOT NULL;

IF NOT EXISTS
(
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_MatrizConversion_TipoGasto'
      AND parent_object_id = OBJECT_ID(N'CONTA.MatrizConversion')
)
BEGIN
    ALTER TABLE CONTA.MatrizConversion WITH CHECK
        ADD CONSTRAINT FK_MatrizConversion_TipoGasto
        FOREIGN KEY (FKIdTipoGasto_PRES) REFERENCES PRES.TipoGasto(PKIdTipoGasto);
END;

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_MatrizConversion_Clasificacion_Activa'
      AND object_id = OBJECT_ID(N'CONTA.MatrizConversion')
)
BEGIN
    CREATE INDEX IX_MatrizConversion_Clasificacion_Activa
        ON CONTA.MatrizConversion(FKIdAnio_SIS, FKIdPrograma_PRES, FKIdPartida_SIS, FKIdTipoGasto_PRES)
        WHERE Activo = 1;
END;

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_MatrizConversion_FKIdTipoGasto_PRES'
      AND object_id = OBJECT_ID(N'CONTA.MatrizConversion')
)
BEGIN
    CREATE INDEX IX_MatrizConversion_FKIdTipoGasto_PRES
        ON CONTA.MatrizConversion(FKIdTipoGasto_PRES);
END;

COMMIT TRANSACTION;
GO

PRINT N'Matriz de conversion actualizada para distinguir COG + TG.';
GO
