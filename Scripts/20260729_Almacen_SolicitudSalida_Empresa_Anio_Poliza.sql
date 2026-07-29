SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* Alcance obligatorio: empresa + ejercicio presupuestal. */
IF COL_LENGTH(N'ALMA.SolicitudSalida', N'FKIdAnio_SIS') IS NULL
    ALTER TABLE ALMA.SolicitudSalida ADD FKIdAnio_SIS int NULL;
GO

IF COL_LENGTH(N'ALMA.Almacen', N'FKIdAnio_SIS') IS NULL
    ALTER TABLE ALMA.Almacen ADD FKIdAnio_SIS int NULL;
GO

/* Sólo completa registros históricos cuyo año se puede inferir de la fecha. */
UPDATE ss
SET FKIdAnio_SIS = a.PKIdAnio
FROM ALMA.SolicitudSalida ss
INNER JOIN SIS.Anio a ON a.Clave = YEAR(ss.FechaSolicitud) AND a.Activo = 1
WHERE ss.FKIdAnio_SIS IS NULL;
GO

UPDATE a
SET FKIdAnio_SIS = an.PKIdAnio
FROM ALMA.Almacen a
INNER JOIN SIS.Anio an ON an.Clave = YEAR(a.FechaEntrada) AND an.Activo = 1
WHERE a.FKIdAnio_SIS IS NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_SolicitudSalida_Anio')
    ALTER TABLE ALMA.SolicitudSalida WITH CHECK
        ADD CONSTRAINT FK_SolicitudSalida_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Almacen_Anio')
    ALTER TABLE ALMA.Almacen WITH CHECK
        ADD CONSTRAINT FK_Almacen_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.SolicitudSalida') AND name = N'IX_SolicitudSalida_FKIdAnio_SIS')
    CREATE INDEX IX_SolicitudSalida_FKIdAnio_SIS ON ALMA.SolicitudSalida(FKIdAnio_SIS, FKIdEmpresa_SIS, Activo);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.Almacen') AND name = N'IX_Almacen_FKIdAnio_SIS')
    CREATE INDEX IX_Almacen_FKIdAnio_SIS ON ALMA.Almacen(FKIdAnio_SIS, FKIdEmpresa_SIS, Activo);
GO

IF OBJECT_ID(N'ALMA.CierreInventario', N'U') IS NULL
BEGIN
    CREATE TABLE ALMA.CierreInventario
    (
        PKIdCierreInventario int IDENTITY(1,1) NOT NULL CONSTRAINT PK_CierreInventario PRIMARY KEY,
        FKIdEmpresa_SIS int NOT NULL,
        FKIdAnio_SIS int NOT NULL,
        FKIdTipoBien_ALMA int NOT NULL,
        FKIdUnidades_ALMA int NULL,
        Mes tinyint NOT NULL,
        Existencias decimal(20,4) NOT NULL CONSTRAINT DF_CierreInventario_Existencias DEFAULT(0),
        CostoExistencias decimal(20,4) NULL,
        CostoPromedio decimal(20,4) NULL,
        Activo bit NOT NULL CONSTRAINT DF_CierreInventario_Activo DEFAULT(1),
        FechaCreacion datetime2(0) NOT NULL CONSTRAINT DF_CierreInventario_FechaCreacion DEFAULT(SYSDATETIME()),
        UsuarioCreacion int NOT NULL CONSTRAINT DF_CierreInventario_UsuarioCreacion DEFAULT(1),
        FechaModificacion datetime2(0) NULL,
        UsuarioModificacion int NULL,
        CONSTRAINT CK_CierreInventario_Mes CHECK (Mes BETWEEN 1 AND 12),
        CONSTRAINT FK_CierreInventario_Empresa FOREIGN KEY(FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
        CONSTRAINT FK_CierreInventario_Anio FOREIGN KEY(FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio),
        CONSTRAINT FK_CierreInventario_TipoBien FOREIGN KEY(FKIdTipoBien_ALMA) REFERENCES ALMA.TipoBien(PKIdTipoBien),
        CONSTRAINT FK_CierreInventario_Unidad FOREIGN KEY(FKIdUnidades_ALMA) REFERENCES ALMA.Unidades(PKIdUnidades)
    );
    CREATE UNIQUE INDEX UQ_CierreInventario_EmpresaAnioBienMes ON ALMA.CierreInventario(FKIdEmpresa_SIS, FKIdAnio_SIS, FKIdTipoBien_ALMA, FKIdUnidades_ALMA, Mes);
END;
GO

IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'ALMA.SolicitudSalida') AND name = N'UQ_SolicitudSalida_Folio')
    ALTER TABLE ALMA.SolicitudSalida DROP CONSTRAINT UQ_SolicitudSalida_Folio;
ELSE IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.SolicitudSalida') AND name = N'UQ_SolicitudSalida_Folio')
    DROP INDEX UQ_SolicitudSalida_Folio ON ALMA.SolicitudSalida;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.SolicitudSalida') AND name = N'UQ_SolicitudSalida_EmpresaAnioFolio')
    CREATE UNIQUE INDEX UQ_SolicitudSalida_EmpresaAnioFolio
        ON ALMA.SolicitudSalida(FKIdEmpresa_SIS, FKIdAnio_SIS, Folio)
        WHERE FKIdAnio_SIS IS NOT NULL;
GO

/* Cuentas equivalentes a las configuradas en el sistema anterior. */
DECLARE @CuentaCargo int =
(
    SELECT TOP (1) PKIdCuentaContable
    FROM CONTA.CuentaContable
    WHERE ClaveOrd = N'5 5 3 5 0000 0000 0000 0000 0000 0000 0000' AND Activo = 1
);
DECLARE @CuentaAbono int =
(
    SELECT TOP (1) PKIdCuentaContable
    FROM CONTA.CuentaContable
    WHERE ClaveOrd = N'1 1 5 1 0000 0000 0000 0000 0000 0000 0000' AND Activo = 1
);

IF @CuentaCargo IS NULL OR @CuentaAbono IS NULL
    THROW 54210, N'No se localizaron las cuentas requeridas para la póliza de salida de almacén.', 1;

UPDATE CONTA.CuentaEspecial
SET FKIdCuentaContable_CONTA = @CuentaCargo, Activo = 1,
    Descripcion = N'Debe por disminución de almacén de materiales y suministros de consumo'
WHERE Clave = N'SALIDA_ALMACEN_CUENTA_CARGO';

IF @@ROWCOUNT = 0
    INSERT CONTA.CuentaEspecial (Clave, FKIdCuentaContable_CONTA, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    VALUES (N'SALIDA_ALMACEN_CUENTA_CARGO', @CuentaCargo,
            N'Debe por disminución de almacén de materiales y suministros de consumo', 1, SYSDATETIME(), 1);

UPDATE CONTA.CuentaEspecial
SET FKIdCuentaContable_CONTA = @CuentaAbono, Activo = 1,
    Descripcion = N'Haber por salida de almacén de materiales y suministros de consumo'
WHERE Clave = N'SALIDA_ALMACEN_CUENTA_ABONO';

IF @@ROWCOUNT = 0
    INSERT CONTA.CuentaEspecial (Clave, FKIdCuentaContable_CONTA, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    VALUES (N'SALIDA_ALMACEN_CUENTA_ABONO', @CuentaAbono,
            N'Haber por salida de almacén de materiales y suministros de consumo', 1, SYSDATETIME(), 1);
GO

CREATE OR ALTER VIEW ALMA.Vw_SolicitudSalida
AS
SELECT
    s.PKIdSolicitudSalida, s.FKIdEmpresa_SIS, s.FKIdAnio_SIS, an.Clave AS AnioClave,
    e.Nombre AS EmpresaNombre,
    s.FKIdAreaSolicita_SIS, areaSol.Nombre AS AreaSolicitaNombre,
    s.FKIdAreaEntrega_SIS, areaEnt.Nombre AS AreaEntregaNombre,
    s.FKIdEstatusSolicitudSalida_ALMA, est.Descripcion AS EstatusDescripcion, est.Color AS EstatusColor,
    s.Folio, s.FechaSolicitud, s.FechaRequerida, s.Solicitante,
    s.Justificacion, s.Observaciones, s.Autorizado, s.FechaAutorizacion, s.UsuarioAutorizacion,
    s.FKIdPoliza_CONTA, s.Activo, s.FechaCreacion, s.UsuarioCreacion, s.FechaModificacion, s.UsuarioModificacion
FROM ALMA.SolicitudSalida s
INNER JOIN SIS.Empresa e ON s.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN SIS.Anio an ON s.FKIdAnio_SIS = an.PKIdAnio
LEFT JOIN SIS.Area areaSol ON s.FKIdAreaSolicita_SIS = areaSol.PKIdArea
LEFT JOIN SIS.Area areaEnt ON s.FKIdAreaEntrega_SIS = areaEnt.PKIdArea
INNER JOIN ALMA.EstatusSolicitudSalida est ON s.FKIdEstatusSolicitudSalida_ALMA = est.PKIdEstatusSolicitudSalida;
GO

CREATE OR ALTER VIEW ALMA.Vw_Almacen
AS
SELECT
    a.PKIdAlmacen, a.FKIdEmpresa_SIS, a.FKIdAnio_SIS, an.Clave AS AnioClave, e.Nombre AS EmpresaNombre,
    a.FKIdArea_SIS, ar.Nombre AS AreaNombre,
    a.FKIdTipoBien_ALMA, tb.CodigoClave AS TipoBienClave, tb.Descripcion AS TipoBienDescripcion,
    a.FKIdUnidades_ALMA, u.Descripcion AS UnidadDescripcion,
    a.FKIdMotivoES_ALMA, m.Descripcion AS MotivoDescripcion,
    a.Clave, a.Cantidad, a.CostoUnitario, a.Costo, a.Factura, a.Remision, a.Lote,
    a.FechaEntrada, a.FechaCaducidad, a.AplicaAlmacen, a.InventarioCerrado, a.EsContabilizado,
    a.Activo, a.FechaCreacion, a.UsuarioCreacion, a.FechaModificacion, a.UsuarioModificacion
FROM ALMA.Almacen a
INNER JOIN SIS.Empresa e ON a.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN SIS.Anio an ON a.FKIdAnio_SIS = an.PKIdAnio
LEFT JOIN SIS.Area ar ON a.FKIdArea_SIS = ar.PKIdArea
INNER JOIN ALMA.TipoBien tb ON a.FKIdTipoBien_ALMA = tb.PKIdTipoBien
LEFT JOIN ALMA.Unidades u ON a.FKIdUnidades_ALMA = u.PKIdUnidades
LEFT JOIN ALMA.MotivoES m ON a.FKIdMotivoES_ALMA = m.PKIdMotivoES;
GO

/* Ninguna ruta, incluido un uso directo del SP, puede ligar una póliza a una salida parcial. */
CREATE OR ALTER TRIGGER ALMA.TRG_SolicitudSalida_PolizaSoloSurtida
ON ALMA.SolicitudSalida
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(FKIdPoliza_CONTA) AND EXISTS
    (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.PKIdSolicitudSalida = i.PKIdSolicitudSalida
        WHERE i.FKIdPoliza_CONTA IS NOT NULL
          AND ISNULL(i.FKIdPoliza_CONTA, 0) <> ISNULL(d.FKIdPoliza_CONTA, 0)
          AND EXISTS
          (
              SELECT 1
              FROM ALMA.DetalleSolicitudSalida ds
              WHERE ds.FKIdSolicitudSalida_ALMA = i.PKIdSolicitudSalida
                AND ds.Activo = 1
                AND ISNULL(ds.CantidadEntregada, 0) < ISNULL(ds.CantidadAutorizada, ds.CantidadSolicitada)
          )
    )
        THROW 54211, N'La póliza sólo puede generarse cuando todos los bienes de la solicitud estén surtidos.', 1;
END;
GO

IF OBJECT_ID(N'dbo.spConfiguracionDeRolYClaims', N'P') IS NOT NULL
BEGIN
    EXEC dbo.spConfiguracionDeRolYClaims 'Almacen', 'Solicitudes_Salida', '10000', 'view,view-menu,delete,new,update,authorize,CanExportToExcel';
    EXEC dbo.spConfiguracionDeRolYClaims 'Almacen', 'Suministros_Salida', '10000', 'view,view-menu,update,authorize,CanExportToExcel';
    EXEC dbo.spConfiguracionDeRolYClaims 'Almacen', 'Existencias_Registradas', '10000', 'view,view-menu,CanExportToExcel';
END;
GO
