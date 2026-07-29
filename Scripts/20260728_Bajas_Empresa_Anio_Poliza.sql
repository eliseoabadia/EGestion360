SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.spConfiguracionDeRolYClaims', N'P') IS NOT NULL
    EXEC dbo.spConfiguracionDeRolYClaims
        'Patrimonio', 'Bajas', '10000', 'view,view-menu,delete,new,update,authorize,CanExportToExcel';
GO

IF COL_LENGTH('ALMA.Bajas', 'FKIdAnio_SIS') IS NULL
    ALTER TABLE ALMA.Bajas ADD FKIdAnio_SIS int NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Bajas_Anio')
    ALTER TABLE ALMA.Bajas WITH CHECK
        ADD CONSTRAINT FK_Bajas_Anio FOREIGN KEY (FKIdAnio_SIS) REFERENCES SIS.Anio(PKIdAnio);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.Bajas') AND name = N'IX_Bajas_FKIdAnio_SIS')
    CREATE INDEX IX_Bajas_FKIdAnio_SIS ON ALMA.Bajas(FKIdAnio_SIS, FKIdEmpresa_SIS, Activo);
GO

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
    WHERE ClaveOrd = N'3 1 4 1 0000 0000 0000 0000 0000 0000 0000' AND Activo = 1
);

IF @CuentaCargo IS NULL OR @CuentaAbono IS NULL
    THROW 54200, N'No existen las cuentas presupuestal y patrimonial requeridas para bajas.', 1;

IF NOT EXISTS (SELECT 1 FROM CONTA.CuentaEspecial WHERE Clave = N'SALIDA_PATRIMONIO_CUENTA_CARGO' AND Activo = 1)
    INSERT CONTA.CuentaEspecial
        (Clave, FKIdCuentaContable_CONTA, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    VALUES
        (N'SALIDA_PATRIMONIO_CUENTA_CARGO', @CuentaCargo,
         N'Cuenta presupuestal de disminucion por salida patrimonial', 1, SYSDATETIME(), 1);

IF NOT EXISTS (SELECT 1 FROM CONTA.CuentaEspecial WHERE Clave = N'SALIDA_PATRIMONIO_CUENTA_ABONO' AND Activo = 1)
    INSERT CONTA.CuentaEspecial
        (Clave, FKIdCuentaContable_CONTA, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    VALUES
        (N'SALIDA_PATRIMONIO_CUENTA_ABONO', @CuentaAbono,
         N'Cuenta patrimonial de abono por baja de bien', 1, SYSDATETIME(), 1);
GO

CREATE OR ALTER VIEW ALMA.Vw_BienesDisponiblesBaja
AS
SELECT
    b.PKIdBien, b.FKIdEmpresa_SIS, b.Clave, b.ClaveAnt, b.Descripcion, b.Modelo, b.Serie,
    b.Factura, b.ValorActual, b.FKIdArea_SIS, a.Nombre AS AreaNombre,
    b.FKIdEstadoBien_ALMA, eb.DESCRIPCION_CORTA AS EstadoBienDescripcion
FROM ALMA.Bien b
LEFT JOIN SIS.Area a ON b.FKIdArea_SIS = a.PKIdArea
LEFT JOIN ALMA.EstadoBien eb ON b.FKIdEstadoBien_ALMA = eb.PKIdEstadoBien
WHERE b.Activo = 1
  AND ISNULL(b.EsContabilizado, 0) = 1
  AND NOT EXISTS
  (
      SELECT 1 FROM ALMA.Bajas bx
      WHERE bx.FKIdBien_ALMA = b.PKIdBien AND bx.Activo = 1
  );
GO

CREATE OR ALTER VIEW ALMA.Vw_Bajas
AS
SELECT
    b.PKIdBaja, b.Folio, b.FKIdEmpresa_SIS, b.FKIdAnio_SIS, e.Nombre AS EmpresaNombre,
    b.FKIdArea_SIS, a.Clave AS AreaClave, a.Nombre AS AreaNombre,
    b.FKIdBien_ALMA, bn.Clave AS BienClave, bn.ClaveAnt AS BienClaveAnterior,
    bn.Descripcion AS BienDescripcion, bn.Modelo, bn.Serie, bn.Factura,
    bn.ValorActual, bn.FKIdTipoBien_ALMA, tb.CodigoClave AS TipoBienCodigoClave,
    tb.Descripcion AS TipoBienDescripcion,
    b.FKIdTipoBaja_ALMA, tpb.Clave AS TipoBajaClave, tpb.Descripcion AS TipoBajaDescripcion,
    b.FKIdEstatusBaja_ALMA, eb.Descripcion AS EstatusDescripcion, eb.Color AS EstatusColor,
    b.FKIdEstadoBienAnterior_ALMA, eba.DESCRIPCION_CORTA AS EstadoAnterior,
    b.FKIdEstadoBienDestino_ALMA, ebd.DESCRIPCION_CORTA AS EstadoDestino,
    b.FechaSolicitud, b.FechaBaja,
    b.Referencia, b.FechaReferencia, b.Destinatario, b.Recibo, b.Cantidad,
    b.Motivo, b.Dictamen, b.Observaciones, b.FKIdPoliza_CONTA, po.ClavePoliza,
    b.SolicitadoPor_NOM, b.AutorizadoPor_NOM, b.FechaAutorizacion,
    b.Activo, b.FechaCreacion, b.UsuarioCreacion, b.FechaModificacion, b.UsuarioModificacion
FROM ALMA.Bajas b
INNER JOIN SIS.Empresa e ON b.FKIdEmpresa_SIS = e.PKIdEmpresa
LEFT JOIN SIS.Area a ON b.FKIdArea_SIS = a.PKIdArea
INNER JOIN ALMA.Bien bn ON b.FKIdBien_ALMA = bn.PKIdBien
LEFT JOIN ALMA.TipoBien tb ON bn.FKIdTipoBien_ALMA = tb.PKIdTipoBien
INNER JOIN ALMA.TipoBaja tpb ON b.FKIdTipoBaja_ALMA = tpb.PKIdTipoBaja
INNER JOIN ALMA.EstatusBaja eb ON b.FKIdEstatusBaja_ALMA = eb.PKIdEstatusBaja
LEFT JOIN ALMA.EstadoBien eba ON b.FKIdEstadoBienAnterior_ALMA = eba.PKIdEstadoBien
LEFT JOIN ALMA.EstadoBien ebd ON b.FKIdEstadoBienDestino_ALMA = ebd.PKIdEstadoBien
LEFT JOIN CONTA.Poliza po ON b.FKIdPoliza_CONTA = po.PKIdPoliza AND po.Activo = 1;
GO

-- Evidencia para la migracion historica; no genera polizas retroactivas ni altera bienes.
SELECT COUNT(*) AS BajasHistoricasPendientes
FROM BD_PRESUPUESTO.SICOP.Bajas antigua
LEFT JOIN ALMA.Bajas nueva ON nueva.PKIdBaja = antigua.PK_IdBajas
WHERE antigua.CT_LIVE = 1 AND nueva.PKIdBaja IS NULL;
GO
