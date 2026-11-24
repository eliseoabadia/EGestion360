SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'ALMA.Conteo', N'U') IS NULL
        THROW 51100, 'No existe ALMA.Conteo; no se aplicaron los indices.', 1;
    IF OBJECT_ID(N'ALMA.Almacen', N'U') IS NULL
        THROW 51102, 'No existe ALMA.Almacen; no se aplicaron los indices.', 1;

    IF EXISTS
    (
    SELECT 1
    FROM ALMA.Conteo
    WHERE Activo = 1
      AND FKIdPeriodoConteo_ALMA IS NOT NULL
    GROUP BY FKIdTipoBien_ALMA, FKIdPeriodoConteo_ALMA
    HAVING COUNT_BIG(*) > 1
    )
        THROW 51101, 'Hay conteos activos duplicados por bien y periodo; corrige esos datos antes de crear el indice unico.', 1;

    DECLARE @ConteoIndexId INT =
    (
        SELECT index_id
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'ALMA.Conteo')
          AND name = N'UX_Conteo_Activo_TipoBien_Periodo'
    );

    IF @ConteoIndexId IS NOT NULL AND
    (
        NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.Conteo') AND index_id = @ConteoIndexId AND is_unique = 1 AND has_filter = 1)
        OR (SELECT COUNT(*) FROM sys.index_columns WHERE object_id = OBJECT_ID(N'ALMA.Conteo') AND index_id = @ConteoIndexId AND key_ordinal > 0) <> 2
        OR NOT EXISTS (SELECT 1 FROM sys.index_columns WHERE object_id = OBJECT_ID(N'ALMA.Conteo') AND index_id = @ConteoIndexId AND key_ordinal = 1 AND column_id = COLUMNPROPERTY(OBJECT_ID(N'ALMA.Conteo'), N'FKIdTipoBien_ALMA', 'ColumnId'))
        OR NOT EXISTS (SELECT 1 FROM sys.index_columns WHERE object_id = OBJECT_ID(N'ALMA.Conteo') AND index_id = @ConteoIndexId AND key_ordinal = 2 AND column_id = COLUMNPROPERTY(OBJECT_ID(N'ALMA.Conteo'), N'FKIdPeriodoConteo_ALMA', 'ColumnId'))
        OR NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.Conteo') AND index_id = @ConteoIndexId AND filter_definition LIKE N'%Activo%1%' AND filter_definition NOT LIKE N'%Activo%0%' AND filter_definition LIKE N'%FKIdPeriodoConteo_ALMA%IS NOT NULL%')
    )
        THROW 51103, 'El indice UX_Conteo_Activo_TipoBien_Periodo ya existe con una estructura incompatible.', 1;

    IF @ConteoIndexId IS NULL
    BEGIN
        CREATE UNIQUE INDEX UX_Conteo_Activo_TipoBien_Periodo
            ON ALMA.Conteo (FKIdTipoBien_ALMA, FKIdPeriodoConteo_ALMA)
            WHERE Activo = 1 AND FKIdPeriodoConteo_ALMA IS NOT NULL;
    END;

    DECLARE @AlmacenIndexId INT =
    (
        SELECT index_id
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'ALMA.Almacen')
          AND name = N'IX_Almacen_Activo_TipoBien_Area_Conteo'
    );

    IF @AlmacenIndexId IS NOT NULL AND
    (
        NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.Almacen') AND index_id = @AlmacenIndexId AND is_unique = 0 AND has_filter = 1)
        OR (SELECT COUNT(*) FROM sys.index_columns WHERE object_id = OBJECT_ID(N'ALMA.Almacen') AND index_id = @AlmacenIndexId AND key_ordinal > 0) <> 2
        OR NOT EXISTS (SELECT 1 FROM sys.index_columns WHERE object_id = OBJECT_ID(N'ALMA.Almacen') AND index_id = @AlmacenIndexId AND key_ordinal = 1 AND column_id = COLUMNPROPERTY(OBJECT_ID(N'ALMA.Almacen'), N'FKIdTipoBien_ALMA', 'ColumnId'))
        OR NOT EXISTS (SELECT 1 FROM sys.index_columns WHERE object_id = OBJECT_ID(N'ALMA.Almacen') AND index_id = @AlmacenIndexId AND key_ordinal = 2 AND column_id = COLUMNPROPERTY(OBJECT_ID(N'ALMA.Almacen'), N'FKIdArea_SIS', 'ColumnId'))
        OR NOT EXISTS (SELECT 1 FROM sys.index_columns WHERE object_id = OBJECT_ID(N'ALMA.Almacen') AND index_id = @AlmacenIndexId AND is_included_column = 1 AND column_id = COLUMNPROPERTY(OBJECT_ID(N'ALMA.Almacen'), N'Cantidad', 'ColumnId'))
        OR NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.Almacen') AND index_id = @AlmacenIndexId AND filter_definition LIKE N'%Activo%1%' AND filter_definition NOT LIKE N'%Activo%0%' AND filter_definition LIKE N'%FKIdArea_SIS%IS NOT NULL%')
    )
        THROW 51104, 'El indice IX_Almacen_Activo_TipoBien_Area_Conteo ya existe con una estructura incompatible.', 1;

    IF @AlmacenIndexId IS NULL
    BEGIN
        CREATE INDEX IX_Almacen_Activo_TipoBien_Area_Conteo
            ON ALMA.Almacen (FKIdTipoBien_ALMA, FKIdArea_SIS)
            INCLUDE (Cantidad)
            WHERE Activo = 1 AND FKIdArea_SIS IS NOT NULL;
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
