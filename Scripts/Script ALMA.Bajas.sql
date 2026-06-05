USE [GestionEmpresarial];
GO

-- Catalogo contable usado por procesos operativos para resolver cuentas especiales.
IF OBJECT_ID(N'CONTA.CuentaEspecial', N'U') IS NULL
CREATE TABLE CONTA.CuentaEspecial (
    PKIdCuentaEspecial INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CuentaEspecial PRIMARY KEY,
    Clave NVARCHAR(120) NOT NULL,
    FKIdCuentaContable_CONTA INT NOT NULL,
    Descripcion NVARCHAR(300) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_CuentaEspecial_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_CuentaEspecial_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL CONSTRAINT DF_CuentaEspecial_UsuarioCreacion DEFAULT(1),
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT UQ_CuentaEspecial_Clave UNIQUE(Clave),
    CONSTRAINT FK_CuentaEspecial_CuentaContable FOREIGN KEY(FKIdCuentaContable_CONTA)
        REFERENCES CONTA.CuentaContable(PKIdCuentaContable)
);
GO

IF COL_LENGTH(N'CONTA.CuentaEspecial', N'FKIdCuentaContable_CONTA') IS NULL
    ALTER TABLE CONTA.CuentaEspecial ADD FKIdCuentaContable_CONTA INT NULL;
GO

IF COL_LENGTH(N'CONTA.CuentaEspecial', N'Activo') IS NULL
    ALTER TABLE CONTA.CuentaEspecial ADD Activo BIT NULL;
GO

IF COL_LENGTH(N'CONTA.CuentaEspecial', N'FechaCreacion') IS NULL
    ALTER TABLE CONTA.CuentaEspecial ADD FechaCreacion DATETIME2(0) NULL;
GO

IF COL_LENGTH(N'CONTA.CuentaEspecial', N'UsuarioCreacion') IS NULL
    ALTER TABLE CONTA.CuentaEspecial ADD UsuarioCreacion INT NULL;
GO

IF COL_LENGTH(N'CONTA.CuentaEspecial', N'FechaModificacion') IS NULL
    ALTER TABLE CONTA.CuentaEspecial ADD FechaModificacion DATETIME2(0) NULL;
GO

IF COL_LENGTH(N'CONTA.CuentaEspecial', N'UsuarioModificacion') IS NULL
    ALTER TABLE CONTA.CuentaEspecial ADD UsuarioModificacion INT NULL;
GO

IF COL_LENGTH(N'CONTA.CuentaEspecial', N'Fk_IdCuenta') IS NOT NULL
    EXEC(N'UPDATE CONTA.CuentaEspecial
           SET FKIdCuentaContable_CONTA = Fk_IdCuenta
           WHERE FKIdCuentaContable_CONTA IS NULL;');
GO

IF COL_LENGTH(N'CONTA.CuentaEspecial', N'CT_LIVE') IS NOT NULL
    EXEC(N'UPDATE CONTA.CuentaEspecial
           SET Activo = CASE WHEN CT_LIVE = 1 THEN 1 ELSE 0 END
           WHERE Activo IS NULL;');
GO

UPDATE CONTA.CuentaEspecial
SET Activo = ISNULL(Activo, 1),
    FechaCreacion = ISNULL(FechaCreacion, SYSDATETIME()),
    UsuarioCreacion = ISNULL(UsuarioCreacion, 1);
GO

-- Catalogo de estatus del proceso
IF OBJECT_ID(N'ALMA.EstatusBaja', N'U') IS NULL
CREATE TABLE ALMA.EstatusBaja (
    PKIdEstatusBaja INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_EstatusBaja PRIMARY KEY,
    Descripcion NVARCHAR(80) NOT NULL,
    Color NVARCHAR(20) NULL,
    Orden INT NOT NULL CONSTRAINT DF_EstatusBaja_Orden DEFAULT(0),
    EsFinal BIT NOT NULL CONSTRAINT DF_EstatusBaja_EsFinal DEFAULT(0),
    Activo BIT NOT NULL CONSTRAINT DF_EstatusBaja_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_EstatusBaja_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL
);
GO

-- Catalogo operativo: robo, extravio, siniestro, donacion, venta, etc.
IF OBJECT_ID(N'ALMA.TipoBaja', N'U') IS NULL
CREATE TABLE ALMA.TipoBaja (
    PKIdTipoBaja INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TipoBaja PRIMARY KEY,
    Clave NVARCHAR(20) NOT NULL,
    Descripcion NVARCHAR(150) NOT NULL,
    FKIdEstadoBienDestino_ALMA INT NULL,
    RequiereAutorizacion BIT NOT NULL CONSTRAINT DF_TipoBaja_RequiereAutorizacion DEFAULT(1),
    Activo BIT NOT NULL CONSTRAINT DF_TipoBaja_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_TipoBaja_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT UQ_TipoBaja_Clave UNIQUE(Clave),
    CONSTRAINT FK_TipoBaja_EstadoDestino FOREIGN KEY(FKIdEstadoBienDestino_ALMA)
        REFERENCES ALMA.EstadoBien(PKIdEstadoBien)
);
GO

-- Tabla principal: una baja por bien
IF OBJECT_ID(N'ALMA.Bajas', N'U') IS NULL
CREATE TABLE ALMA.Bajas (
    PKIdBaja INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Bajas PRIMARY KEY,
    Folio NVARCHAR(30) NOT NULL,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdArea_SIS INT NULL,
    FKIdBien_ALMA INT NOT NULL,
    FKIdTipoBaja_ALMA INT NOT NULL,
    FKIdEstatusBaja_ALMA INT NOT NULL,
    FKIdEstadoBienAnterior_ALMA INT NULL,
    FKIdEstadoBienDestino_ALMA INT NULL,
    FechaSolicitud DATE NOT NULL CONSTRAINT DF_Bajas_FechaSolicitud DEFAULT(CONVERT(date, GETDATE())),
    FechaBaja DATE NULL,
    Referencia NVARCHAR(200) NULL,
    FechaReferencia DATE NULL,
    Destinatario NVARCHAR(250) NULL,
    Recibo NVARCHAR(100) NULL,
    Cantidad DECIMAL(20,4) NULL CONSTRAINT DF_Bajas_Cantidad DEFAULT(1),
    Motivo NVARCHAR(1000) NOT NULL,
    Dictamen NVARCHAR(1000) NULL,
    Observaciones NVARCHAR(1000) NULL,
    FKIdPoliza_CONTA INT NULL,
    SolicitadoPor_NOM INT NULL,
    AutorizadoPor_NOM INT NULL,
    FechaAutorizacion DATETIME2(0) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Bajas_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Bajas_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT UQ_Bajas_Folio UNIQUE(Folio),
    CONSTRAINT UX_Bajas_BienActivo UNIQUE(FKIdBien_ALMA, Activo),
    CONSTRAINT FK_Bajas_Empresa FOREIGN KEY(FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Bajas_Area FOREIGN KEY(FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea),
    CONSTRAINT FK_Bajas_Bien FOREIGN KEY(FKIdBien_ALMA) REFERENCES ALMA.Bien(PKIdBien),
    CONSTRAINT FK_Bajas_Tipo FOREIGN KEY(FKIdTipoBaja_ALMA) REFERENCES ALMA.TipoBaja(PKIdTipoBaja),
    CONSTRAINT FK_Bajas_Estatus FOREIGN KEY(FKIdEstatusBaja_ALMA) REFERENCES ALMA.EstatusBaja(PKIdEstatusBaja),
    CONSTRAINT FK_Bajas_EstadoAnterior FOREIGN KEY(FKIdEstadoBienAnterior_ALMA) REFERENCES ALMA.EstadoBien(PKIdEstadoBien),
    CONSTRAINT FK_Bajas_EstadoDestino FOREIGN KEY(FKIdEstadoBienDestino_ALMA) REFERENCES ALMA.EstadoBien(PKIdEstadoBien),
    CONSTRAINT FK_Bajas_Poliza FOREIGN KEY(FKIdPoliza_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza)
);
GO

IF COL_LENGTH(N'ALMA.Bajas', N'Referencia') IS NULL
    ALTER TABLE ALMA.Bajas ADD Referencia NVARCHAR(200) NULL;
GO

IF COL_LENGTH(N'ALMA.Bajas', N'FechaReferencia') IS NULL
    ALTER TABLE ALMA.Bajas ADD FechaReferencia DATE NULL;
GO

IF COL_LENGTH(N'ALMA.Bajas', N'Destinatario') IS NULL
    ALTER TABLE ALMA.Bajas ADD Destinatario NVARCHAR(250) NULL;
GO

IF COL_LENGTH(N'ALMA.Bajas', N'Recibo') IS NULL
    ALTER TABLE ALMA.Bajas ADD Recibo NVARCHAR(100) NULL;
GO

IF COL_LENGTH(N'ALMA.Bajas', N'Cantidad') IS NULL
    ALTER TABLE ALMA.Bajas ADD Cantidad DECIMAL(20,4) NULL CONSTRAINT DF_Bajas_Cantidad DEFAULT(1);
GO

IF COL_LENGTH(N'ALMA.Bajas', N'FKIdPoliza_CONTA') IS NULL
    ALTER TABLE ALMA.Bajas ADD FKIdPoliza_CONTA INT NULL;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Bajas_Poliza'
      AND parent_object_id = OBJECT_ID(N'ALMA.Bajas')
)
BEGIN
    ALTER TABLE ALMA.Bajas WITH CHECK ADD CONSTRAINT FK_Bajas_Poliza
        FOREIGN KEY(FKIdPoliza_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza);
END
GO

IF EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UX_Bajas_BienActivo'
      AND parent_object_id = OBJECT_ID(N'ALMA.Bajas')
)
BEGIN
    ALTER TABLE ALMA.Bajas DROP CONSTRAINT UX_Bajas_BienActivo;
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_Bajas_BienActivo'
      AND object_id = OBJECT_ID(N'ALMA.Bajas')
)
BEGIN
    CREATE UNIQUE INDEX UX_Bajas_BienActivo
    ON ALMA.Bajas(FKIdBien_ALMA)
    WHERE Activo = 1;
END
GO


CREATE OR ALTER VIEW ALMA.Vw_Bajas AS
SELECT
    b.PKIdBaja, b.Folio, b.FKIdEmpresa_SIS, e.Nombre AS EmpresaNombre,
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

CREATE OR ALTER VIEW ALMA.Vw_BienesDisponiblesBaja AS
SELECT
    b.PKIdBien, b.Clave, b.ClaveAnt, b.Descripcion, b.Modelo, b.Serie,
    b.Factura, b.ValorActual, b.FKIdArea_SIS, a.Nombre AS AreaNombre,
    b.FKIdEstadoBien_ALMA, eb.DESCRIPCION_CORTA AS EstadoBienDescripcion
FROM ALMA.Bien b
LEFT JOIN SIS.Area a ON b.FKIdArea_SIS = a.PKIdArea
LEFT JOIN ALMA.EstadoBien eb ON b.FKIdEstadoBien_ALMA = eb.PKIdEstadoBien
WHERE b.Activo = 1
  AND NOT EXISTS (
      SELECT 1 FROM ALMA.Bajas bx
      WHERE bx.FKIdBien_ALMA = b.PKIdBien AND bx.Activo = 1
  );
GO

CREATE OR ALTER PROCEDURE ALMA.SP_CREATE_PolizaSalidaPatrimonio
    @PKIdBaja INT,
    @Error NVARCHAR(MAX) = NULL OUTPUT,
    @PKIdPoliza INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @FechaPoliza DATETIME,
        @Anio INT,
        @FKIdAnio_SIS INT,
        @FKIdMes_SIS INT,
        @FKIdTipoPoliza_SIS INT = 1,
        @NombrePoliza NVARCHAR(1000),
        @ClavePoliza NVARCHAR(10),
        @ErrorClave NVARCHAR(MAX),
        @ErrorBalance NVARCHAR(MAX),
        @IdUser INT,
        @Folio NVARCHAR(30),
        @BienClave NVARCHAR(50),
        @BienDescripcion NVARCHAR(1000),
        @Importe DECIMAL(20,4),
        @CuentaCargo INT,
        @CuentaAbono INT,
        @DescripcionDetalle NVARCHAR(600),
        @StartedTran BIT = 0;

    BEGIN TRY
        SET @Error = NULL;
        SET @PKIdPoliza = NULL;

        SELECT
            @FechaPoliza = CONVERT(DATETIME, COALESCE(b.FechaBaja, b.FechaSolicitud, CONVERT(date, GETDATE()))),
            @PKIdPoliza = b.FKIdPoliza_CONTA,
            @IdUser = COALESCE(b.UsuarioModificacion, b.UsuarioCreacion, 1),
            @Folio = b.Folio,
            @BienClave = bn.Clave,
            @BienDescripcion = bn.Descripcion,
            @Importe = COALESCE(bn.ValorActual, bn.Costo, 0)
        FROM ALMA.Bajas b
        INNER JOIN ALMA.Bien bn ON b.FKIdBien_ALMA = bn.PKIdBien
        WHERE b.PKIdBaja = @PKIdBaja
          AND b.Activo = 1;

        IF @FechaPoliza IS NULL
            THROW 54100, N'La baja no existe o esta inactiva.', 1;

        IF ISNULL(@PKIdPoliza, 0) > 0
            RETURN 0;

        IF ISNULL(@Importe, 0) <= 0
            THROW 54101, N'El bien no tiene ValorActual/Costo para generar la poliza de baja.', 1;

        IF OBJECT_ID(N'CONTA.CuentaEspecial', N'U') IS NULL
            THROW 54102, N'No existe CONTA.CuentaEspecial para configurar las cuentas de salida patrimonial.', 1;

        IF COL_LENGTH(N'CONTA.CuentaEspecial', N'FKIdCuentaContable_CONTA') IS NULL
            THROW 54103, N'CONTA.CuentaEspecial debe usar FKIdCuentaContable_CONTA, Activo y campos de control nuevos.', 1;

        SELECT @CuentaCargo = FKIdCuentaContable_CONTA
        FROM CONTA.CuentaEspecial
        WHERE Clave = N'SALIDA_PATRIMONIO_CUENTA_CARGO'
          AND Activo = 1;

        SELECT @CuentaAbono = FKIdCuentaContable_CONTA
        FROM CONTA.CuentaEspecial
        WHERE Clave = N'SALIDA_PATRIMONIO_CUENTA_ABONO'
          AND Activo = 1;

        IF @CuentaCargo IS NULL OR @CuentaAbono IS NULL
            THROW 54104, N'No se han configurado las cuentas de cargo y abono para salida patrimonial.', 1;

        SET @Anio = YEAR(@FechaPoliza);
        SET @FKIdMes_SIS = MONTH(@FechaPoliza);

        SELECT @FKIdAnio_SIS = PKIdAnio
        FROM SIS.Anio
        WHERE Clave = @Anio
          AND Activo = 1;

        IF @FKIdAnio_SIS IS NULL
            THROW 54105, N'No existe el anio contable activo para la fecha de baja.', 1;

        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRAN;
            SET @StartedTran = 1;
        END

        EXEC CONTA.SP_CREATE_ClavePoliza
            @FK_IdAnio__SIS = @FKIdAnio_SIS,
            @FK_IdMesConta__SIS = @FKIdMes_SIS,
            @FK_IdTipoPolizaConta__SIS = @FKIdTipoPoliza_SIS,
            @CT_ModifiedBy = @IdUser,
            @ClavePoliza = @ClavePoliza OUTPUT,
            @Error = @ErrorClave OUTPUT;

        IF ISNULL(@ClavePoliza, N'') = N''
            THROW 54106, N'No se pudo generar la clave de poliza para la baja patrimonial.', 1;

        SET @NombrePoliza = CONCAT(N'Baja de bien solicitud: ', @Anio, N' / ', @Folio);

        INSERT INTO CONTA.Poliza (
            FKIdAnio_SIS, FKIdMes_SIS, FKIdTipoPoliza_SIS, ClavePoliza,
            NombrePoliza, FechaPoliza, EstaBalanceado, PermitirModificar,
            FKIdAccionAutorizar_SIS, Autorizado, FechaSolicitud, FechaAutorizacion,
            Activo, FechaCreacion, UsuarioCreacion
        )
        VALUES (
            @FKIdAnio_SIS, @FKIdMes_SIS, @FKIdTipoPoliza_SIS, @ClavePoliza,
            @NombrePoliza, @FechaPoliza, 0, 1,
            NULL, 0, SYSDATETIME(), NULL,
            1, SYSDATETIME(), @IdUser
        );

        SET @PKIdPoliza = CONVERT(INT, SCOPE_IDENTITY());
        SET @DescripcionDetalle = LEFT(CONCAT(N'Baja del bien: ', ISNULL(@BienClave, N''), N' ', ISNULL(@BienDescripcion, N'')), 600);

        INSERT INTO CONTA.PolizaDetalle (
            FKIdCuentaContable_CONTA, FKIdPoliza_CONTA, Descripcion,
            ImporteDebe, ImporteHaber, FKIdReferencia, FKIdTipoDetallePoliza_SIS,
            Activo, FechaCreacion, UsuarioCreacion
        )
        VALUES
            (@CuentaCargo, @PKIdPoliza, @DescripcionDetalle, @Importe, 0, @PKIdBaja, 1, 1, SYSDATETIME(), @IdUser),
            (@CuentaAbono, @PKIdPoliza, @DescripcionDetalle, 0, @Importe, @PKIdBaja, 1, 1, SYSDATETIME(), @IdUser);

        EXEC CONTA.SP_UPDATE_PolizaBalanceada
            @PKIdPoliza = @PKIdPoliza,
            @IdUser = @IdUser,
            @Error = @ErrorBalance OUTPUT;

        IF NULLIF(LTRIM(RTRIM(ISNULL(@ErrorBalance, N''))), N'') IS NOT NULL
            THROW 54107, N'Error al balancear la poliza de baja patrimonial.', 1;

        UPDATE ALMA.Bajas
        SET FKIdPoliza_CONTA = @PKIdPoliza,
            FechaModificacion = SYSDATETIME(),
            UsuarioModificacion = @IdUser
        WHERE PKIdBaja = @PKIdBaja;

        IF @StartedTran = 1 AND XACT_STATE() = 1
            COMMIT;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @StartedTran = 1 AND @@TRANCOUNT > 0
            ROLLBACK;

        SET @Error = CONCAT(N'Error al generar poliza de baja patrimonial: ', ERROR_MESSAGE(), N' Linea: ', ERROR_LINE());
        SET @PKIdPoliza = NULL;
        RETURN 1;
    END CATCH
END;
GO


-- Acciones:
-- 1 Crear solicitud
-- 2 Actualizar solicitud
-- 3 Cancelar solicitud, baja logica
-- 4 Autorizar/aplicar baja: libera resguardo activo, cambia estado del bien y desactiva ALMA.Bien
-- 5 Rechazar
CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoBajas
    @Action INT,
    @PKIdBaja INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @FKIdBien_ALMA INT = NULL,
    @FKIdTipoBaja_ALMA INT = NULL,
    @FKIdEstatusBaja_ALMA INT = NULL,
    @FKIdEstadoBienDestino_ALMA INT = NULL,
    @FechaSolicitud DATE = NULL,
    @FechaBaja DATE = NULL,
    @Referencia NVARCHAR(200) = NULL,
    @FechaReferencia DATE = NULL,
    @Destinatario NVARCHAR(250) = NULL,
    @Recibo NVARCHAR(100) = NULL,
    @Cantidad DECIMAL(20,4) = NULL,
    @Motivo NVARCHAR(1000) = NULL,
    @Dictamen NVARCHAR(1000) = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @FKIdPoliza_CONTA INT = NULL,
    @SolicitadoPor_NOM INT = NULL,
    @AutorizadoPor_NOM INT = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @Mensaje NVARCHAR(4000),
        @Liga NVARCHAR(100),
        @Folio NVARCHAR(30),
        @Consecutivo INT,
        @Anio INT,
        @IdEstatusInicial INT,
        @IdEstatusAplicada INT,
        @IdEstatusRechazada INT,
        @IdEstatusCancelada INT,
        @EsFinal BIT,
        @IdBien INT,
        @IdResguardoDetalle INT,
        @IdResguardo INT,
        @EstadoAnterior INT,
        @EstadoDestino INT,
        @FechaReferenciaActual DATE,
        @ErrorPoliza NVARCHAR(2048),
        @NuevaPoliza INT;

    BEGIN TRY
        IF @Action NOT IN (1,2,3,4,5)
            THROW 54000, N'Accion invalida para bajas.', 1;

        IF @IdUser IS NULL
            THROW 54001, N'El usuario es obligatorio.', 1;

        SELECT @IdEstatusInicial = PKIdEstatusBaja
        FROM ALMA.EstatusBaja
        WHERE Descripcion = N'INICIAL' AND Activo = 1;

        SELECT @IdEstatusAplicada = PKIdEstatusBaja
        FROM ALMA.EstatusBaja
        WHERE Descripcion = N'APLICADA' AND Activo = 1;

        SELECT @IdEstatusRechazada = PKIdEstatusBaja
        FROM ALMA.EstatusBaja
        WHERE Descripcion = N'RECHAZADA' AND Activo = 1;

        SELECT @IdEstatusCancelada = PKIdEstatusBaja
        FROM ALMA.EstatusBaja
        WHERE Descripcion = N'CANCELADA' AND Activo = 1;

        IF @IdEstatusInicial IS NULL OR @IdEstatusAplicada IS NULL OR @IdEstatusRechazada IS NULL OR @IdEstatusCancelada IS NULL
            THROW 54002, N'Faltan estatus base de bajas: INICIAL, APLICADA, RECHAZADA o CANCELADA.', 1;

        BEGIN TRAN;

        IF @Action = 1
        BEGIN
            IF @FKIdEmpresa_SIS IS NULL OR @FKIdBien_ALMA IS NULL OR @FKIdTipoBaja_ALMA IS NULL
                THROW 54003, N'Empresa, bien y tipo de baja son obligatorios.', 1;

            IF NULLIF(LTRIM(RTRIM(ISNULL(@Motivo, N''))), N'') IS NULL
                THROW 54004, N'El motivo de la baja es obligatorio.', 1;

            IF ISNULL(@Cantidad, 1) <= 0
                THROW 54013, N'La cantidad debe ser mayor a cero.', 1;

            IF @FechaReferencia IS NOT NULL AND COALESCE(@FechaBaja, @FechaSolicitud, CONVERT(date, GETDATE())) > @FechaReferencia
                THROW 54014, N'La fecha de referencia debe ser mayor o igual a la fecha de baja.', 1;

            SELECT
                @EstadoAnterior = FKIdEstadoBien_ALMA,
                @FKIdArea_SIS = COALESCE(@FKIdArea_SIS, FKIdArea_SIS)
            FROM ALMA.Bien WITH (UPDLOCK, HOLDLOCK)
            WHERE PKIdBien = @FKIdBien_ALMA AND Activo = 1;

            IF @EstadoAnterior IS NULL AND NOT EXISTS (SELECT 1 FROM ALMA.Bien WHERE PKIdBien = @FKIdBien_ALMA AND Activo = 1)
                THROW 54005, N'El bien no existe o esta inactivo.', 1;

            IF EXISTS (SELECT 1 FROM ALMA.Bajas WHERE FKIdBien_ALMA = @FKIdBien_ALMA AND Activo = 1)
                THROW 54006, N'El bien ya tiene una baja activa.', 1;

            IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE PKIdTipoBaja = @FKIdTipoBaja_ALMA AND Activo = 1)
                THROW 54007, N'El tipo de baja no existe o esta inactivo.', 1;

            SELECT @EstadoDestino = COALESCE(@FKIdEstadoBienDestino_ALMA, FKIdEstadoBienDestino_ALMA)
            FROM ALMA.TipoBaja
            WHERE PKIdTipoBaja = @FKIdTipoBaja_ALMA;

            SET @Anio = YEAR(COALESCE(@FechaSolicitud, GETDATE()));

            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, RIGHT(Folio, 5))), 0) + 1
            FROM ALMA.Bajas WITH (UPDLOCK, HOLDLOCK)
            WHERE Folio LIKE CONCAT(N'BAJ-', @Anio, N'-%');

            SET @Folio = CONCAT(N'BAJ-', @Anio, N'-', RIGHT(CONCAT(N'00000', @Consecutivo), 5));

            INSERT INTO ALMA.Bajas (
                Folio, FKIdEmpresa_SIS, FKIdArea_SIS, FKIdBien_ALMA, FKIdTipoBaja_ALMA,
                FKIdEstatusBaja_ALMA, FKIdEstadoBienAnterior_ALMA, FKIdEstadoBienDestino_ALMA,
                FechaSolicitud, FechaBaja, Referencia, FechaReferencia, Destinatario, Recibo, Cantidad,
                Motivo, Dictamen, Observaciones, FKIdPoliza_CONTA,
                SolicitadoPor_NOM, AutorizadoPor_NOM, FechaAutorizacion,
                Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @Folio, @FKIdEmpresa_SIS, @FKIdArea_SIS, @FKIdBien_ALMA, @FKIdTipoBaja_ALMA,
                COALESCE(@FKIdEstatusBaja_ALMA, @IdEstatusInicial), @EstadoAnterior, @EstadoDestino,
                COALESCE(@FechaSolicitud, CONVERT(date, GETDATE())), @FechaBaja,
                @Referencia, @FechaReferencia, @Destinatario, @Recibo, COALESCE(@Cantidad, 1),
                LTRIM(RTRIM(@Motivo)), @Dictamen, @Observaciones, @FKIdPoliza_CONTA,
                @SolicitadoPor_NOM, @AutorizadoPor_NOM, NULL,
                1, SYSDATETIME(), @IdUser
            );

            SET @Id = CONVERT(INT, SCOPE_IDENTITY());
            SET @Mensaje = N'Solicitud de baja creada correctamente.';
        END
        ELSE
        BEGIN
            SELECT
                @IdBien = FKIdBien_ALMA,
                @EsFinal = eb.EsFinal,
                @EstadoAnterior = b.FKIdEstadoBienAnterior_ALMA,
                @EstadoDestino = COALESCE(@FKIdEstadoBienDestino_ALMA, b.FKIdEstadoBienDestino_ALMA),
                @FechaReferenciaActual = COALESCE(@FechaReferencia, b.FechaReferencia)
            FROM ALMA.Bajas b WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN ALMA.EstatusBaja eb ON b.FKIdEstatusBaja_ALMA = eb.PKIdEstatusBaja
            WHERE b.PKIdBaja = @PKIdBaja AND b.Activo = 1;

            IF @IdBien IS NULL
                THROW 54008, N'La baja no existe o esta inactiva.', 1;

            IF @EsFinal = 1
                THROW 54009, N'La baja ya esta en estatus final.', 1;

            IF @Action = 2
            BEGIN
                IF NULLIF(LTRIM(RTRIM(ISNULL(@Motivo, N''))), N'') IS NULL
                    THROW 54010, N'El motivo de la baja es obligatorio.', 1;

                IF ISNULL(@Cantidad, 1) <= 0
                    THROW 54013, N'La cantidad debe ser mayor a cero.', 1;

                IF @FechaReferencia IS NOT NULL AND COALESCE(@FechaBaja, @FechaSolicitud, CONVERT(date, GETDATE())) > @FechaReferencia
                    THROW 54014, N'La fecha de referencia debe ser mayor o igual a la fecha de baja.', 1;

                UPDATE ALMA.Bajas
                SET FKIdArea_SIS = @FKIdArea_SIS,
                    FKIdTipoBaja_ALMA = COALESCE(@FKIdTipoBaja_ALMA, FKIdTipoBaja_ALMA),
                    FKIdEstatusBaja_ALMA = COALESCE(@FKIdEstatusBaja_ALMA, FKIdEstatusBaja_ALMA),
                    FKIdEstadoBienDestino_ALMA = @EstadoDestino,
                    FechaSolicitud = COALESCE(@FechaSolicitud, FechaSolicitud),
                    FechaBaja = @FechaBaja,
                    Referencia = @Referencia,
                    FechaReferencia = @FechaReferencia,
                    Destinatario = @Destinatario,
                    Recibo = @Recibo,
                    Cantidad = COALESCE(@Cantidad, Cantidad, 1),
                    Motivo = LTRIM(RTRIM(@Motivo)),
                    Dictamen = @Dictamen,
                    Observaciones = @Observaciones,
                    FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                    SolicitadoPor_NOM = @SolicitadoPor_NOM,
                    AutorizadoPor_NOM = @AutorizadoPor_NOM,
                    FechaModificacion = SYSDATETIME(),
                    UsuarioModificacion = @IdUser
                WHERE PKIdBaja = @PKIdBaja;

                SET @Id = @PKIdBaja;
                SET @Mensaje = N'Baja actualizada correctamente.';
            END

            IF @Action = 3
            BEGIN
                UPDATE ALMA.Bajas
                SET FKIdEstatusBaja_ALMA = @IdEstatusCancelada,
                    Activo = 0,
                    FechaModificacion = SYSDATETIME(),
                    UsuarioModificacion = @IdUser
                WHERE PKIdBaja = @PKIdBaja;

                SET @Id = @PKIdBaja;
                SET @Mensaje = N'Baja cancelada correctamente.';
            END

            IF @Action = 4
            BEGIN
                IF @EstadoDestino IS NULL
                    THROW 54011, N'Debe existir un estado destino para aplicar la baja.', 1;

                IF @FechaReferenciaActual IS NOT NULL AND COALESCE(@FechaBaja, CONVERT(date, GETDATE())) > @FechaReferenciaActual
                    THROW 54014, N'La fecha de referencia debe ser mayor o igual a la fecha de baja.', 1;

                IF NOT EXISTS (SELECT 1 FROM ALMA.Bien WHERE PKIdBien = @IdBien AND Activo = 1)
                    THROW 54012, N'El bien no existe o ya esta inactivo.', 1;

                SELECT TOP 1
                    @IdResguardoDetalle = PKIdResguardoDetalle,
                    @IdResguardo = FKIdResguardo_ALMA
                FROM ALMA.ResguardoDetalle WITH (UPDLOCK, HOLDLOCK)
                WHERE FKIdBien_ALMA = @IdBien AND Activo = 1
                ORDER BY FechaAsignacion DESC, PKIdResguardoDetalle DESC;

                IF @IdResguardoDetalle IS NOT NULL
                BEGIN
                    UPDATE ALMA.ResguardoDetalle
                    SET Activo = 0,
                        FechaLiberacion = SYSDATETIME(),
                        Observaciones = COALESCE(NULLIF(@Observaciones, N''), Observaciones),
                        FechaModificacion = SYSDATETIME(),
                        UsuarioModificacion = @IdUser
                    WHERE PKIdResguardoDetalle = @IdResguardoDetalle;

                    INSERT INTO ALMA.ResguardoMovimiento (
                        FKIdResguardoDetalle_ALMA, FKIdBien_ALMA, FKIdResguardoOrigen_ALMA,
                        TipoMovimiento, Observaciones, UsuarioCreacion
                    )
                    VALUES (
                        @IdResguardoDetalle, @IdBien, @IdResguardo,
                        N'BAJA', CONCAT(N'Baja patrimonial ', @PKIdBaja, N'. ', ISNULL(@Motivo, N'')), @IdUser
                    );
                END

                UPDATE ALMA.Bien
                SET ResguardoAnterior = Resguardo,
                    Resguardo = NULL,
                    EstaResguardado = 0,
                    FechaResguardado = NULL,
                    FKIdEstadoBien_ALMA = @EstadoDestino,
                    Activo = 0,
                    FechaModificacion = SYSDATETIME(),
                    UsuarioModificacion = @IdUser
                WHERE PKIdBien = @IdBien;

                UPDATE ALMA.Bajas
                SET FKIdEstatusBaja_ALMA = @IdEstatusAplicada,
                    FKIdEstadoBienDestino_ALMA = @EstadoDestino,
                    FechaBaja = COALESCE(@FechaBaja, CONVERT(date, GETDATE())),
                    Referencia = COALESCE(@Referencia, Referencia),
                    FechaReferencia = COALESCE(@FechaReferencia, FechaReferencia),
                    Destinatario = COALESCE(@Destinatario, Destinatario),
                    Recibo = COALESCE(@Recibo, Recibo),
                    Cantidad = COALESCE(@Cantidad, Cantidad, 1),
                    AutorizadoPor_NOM = @AutorizadoPor_NOM,
                    FechaAutorizacion = SYSDATETIME(),
                    Dictamen = @Dictamen,
                    Observaciones = @Observaciones,
                    FKIdPoliza_CONTA = COALESCE(@FKIdPoliza_CONTA, FKIdPoliza_CONTA),
                    FechaModificacion = SYSDATETIME(),
                    UsuarioModificacion = @IdUser
                WHERE PKIdBaja = @PKIdBaja;

                IF @FKIdPoliza_CONTA IS NULL
                BEGIN
                    EXEC ALMA.SP_CREATE_PolizaSalidaPatrimonio
                        @PKIdBaja = @PKIdBaja,
                        @Error = @ErrorPoliza OUTPUT,
                        @PKIdPoliza = @NuevaPoliza OUTPUT;
                END

                IF NULLIF(LTRIM(RTRIM(ISNULL(@ErrorPoliza, N''))), N'') IS NOT NULL
                    THROW 54015, @ErrorPoliza, 1;

                IF ISNULL(@NuevaPoliza, 0) > 0
                BEGIN
                    UPDATE ALMA.Bajas
                    SET FKIdPoliza_CONTA = @NuevaPoliza
                    WHERE PKIdBaja = @PKIdBaja AND FKIdPoliza_CONTA IS NULL;
                END

                SET @Id = @PKIdBaja;
                SET @Mensaje = N'Baja aplicada correctamente.';
            END

            IF @Action = 5
            BEGIN
                UPDATE ALMA.Bajas
                SET FKIdEstatusBaja_ALMA = @IdEstatusRechazada,
                    AutorizadoPor_NOM = @AutorizadoPor_NOM,
                    FechaAutorizacion = SYSDATETIME(),
                    Dictamen = @Dictamen,
                    Observaciones = @Observaciones,
                    FechaModificacion = SYSDATETIME(),
                    UsuarioModificacion = @IdUser
                WHERE PKIdBaja = @PKIdBaja;

                SET @Id = @PKIdBaja;
                SET @Mensaje = N'Baja rechazada correctamente.';
            END
        END

        COMMIT;

        SET @Liga = CONCAT(N'idBaja:', @Id);
        SELECT ResultJson = (SELECT N'success' AS Tipo, @Mensaje AS Mensaje, @Liga AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_ReporteBaja
    @PKIdBaja INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM ALMA.Vw_Bajas WHERE PKIdBaja = @PKIdBaja;
END;
GO


USE [GestionEmpresarial];
GO

-- =============================================
-- ALMA.EstatusBaja
-- =============================================
IF NOT EXISTS (SELECT 1 FROM ALMA.EstatusBaja WHERE Descripcion = N'INICIAL')
    INSERT INTO ALMA.EstatusBaja (Descripcion, Color, Orden, EsFinal, UsuarioCreacion)
    VALUES (N'INICIAL', N'#E3F2FD', 1, 0, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.EstatusBaja WHERE Descripcion = N'EN REVISION')
    INSERT INTO ALMA.EstatusBaja (Descripcion, Color, Orden, EsFinal, UsuarioCreacion)
    VALUES (N'EN REVISION', N'#FFF8CC', 2, 0, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.EstatusBaja WHERE Descripcion = N'AUTORIZADA')
    INSERT INTO ALMA.EstatusBaja (Descripcion, Color, Orden, EsFinal, UsuarioCreacion)
    VALUES (N'AUTORIZADA', N'#DFF6DD', 3, 0, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.EstatusBaja WHERE Descripcion = N'APLICADA')
    INSERT INTO ALMA.EstatusBaja (Descripcion, Color, Orden, EsFinal, UsuarioCreacion)
    VALUES (N'APLICADA', N'#C8E6C9', 4, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.EstatusBaja WHERE Descripcion = N'RECHAZADA')
    INSERT INTO ALMA.EstatusBaja (Descripcion, Color, Orden, EsFinal, UsuarioCreacion)
    VALUES (N'RECHAZADA', N'#FFD6D6', 5, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.EstatusBaja WHERE Descripcion = N'CANCELADA')
    INSERT INTO ALMA.EstatusBaja (Descripcion, Color, Orden, EsFinal, UsuarioCreacion)
    VALUES (N'CANCELADA', N'#ECEFF1', 6, 1, 1);
GO

-- =============================================
-- ALMA.TipoBaja
-- Usa FKIdEstadoBienDestino_ALMA segun catalogo ALMA.EstadoBien existente
-- =============================================

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'VENTA')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'VENTA', N'Baja por venta o disposicion final', 15, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'DONACION')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'DONACION', N'Baja por donacion', 34, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'SINIESTRO')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'SINIESTRO', N'Baja por siniestro', 18, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'FALTANTE')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'FALTANTE', N'Baja por faltante finiquitado', 20, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'ROBO')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'ROBO', N'Baja por robo', 47, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'EXTRAVIO')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'EXTRAVIO', N'Baja por extravio', 48, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'PERDIDA_TOTAL')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'PERDIDA_TOTAL', N'Baja por perdida total', 49, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'REPOSICION')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'REPOSICION', N'Baja por reposicion finiquitada', 32, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'MANTENIMIENTO')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'MANTENIMIENTO', N'Baja por mantenimiento finiquitado', 42, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'GARANTIA')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'GARANTIA', N'Baja por garantia finiquitada', 45, 1, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'MIGRACION')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'MIGRACION', N'Baja desde migracion', 46, 0, 1);

IF NOT EXISTS (SELECT 1 FROM ALMA.TipoBaja WHERE Clave = N'OTRA')
    INSERT INTO ALMA.TipoBaja (Clave, Descripcion, FKIdEstadoBienDestino_ALMA, RequiereAutorizacion, UsuarioCreacion)
    VALUES (N'OTRA', N'Otro tipo de baja', 25, 1, 1);
GO


USE [GestionEmpresarial];
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'ALMA')
    EXEC(N'CREATE SCHEMA ALMA');
GO

IF OBJECT_ID(N'ALMA.Resguardo', N'U') IS NULL
CREATE TABLE ALMA.Resguardo (
    PKIdResguardo INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Resguardo PRIMARY KEY,
    FKIdEmpresa_SIS INT NOT NULL,
    FKIdArea_SIS INT NULL,
    Responsable NVARCHAR(250) NOT NULL,
    Folio NVARCHAR(30) NOT NULL,
    Fecha DATE NOT NULL CONSTRAINT DF_Resguardo_Fecha DEFAULT(CONVERT(date, GETDATE())),
    Observaciones NVARCHAR(1000) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Resguardo_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Resguardo_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT UQ_Resguardo_Folio UNIQUE(Folio),
    CONSTRAINT FK_Resguardo_Empresa FOREIGN KEY(FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
    CONSTRAINT FK_Resguardo_Area FOREIGN KEY(FKIdArea_SIS) REFERENCES SIS.Area(PKIdArea)
);
GO

IF OBJECT_ID(N'ALMA.ResguardoDetalle', N'U') IS NULL
CREATE TABLE ALMA.ResguardoDetalle (
    PKIdResguardoDetalle INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ResguardoDetalle PRIMARY KEY,
    FKIdResguardo_ALMA INT NOT NULL,
    FKIdBien_ALMA INT NOT NULL,
    FKIdEstadoBien_ALMA INT NULL,
    FechaAsignacion DATETIME2(0) NOT NULL CONSTRAINT DF_ResguardoDetalle_FechaAsignacion DEFAULT(SYSDATETIME()),
    FechaLiberacion DATETIME2(0) NULL,
    ImprimeEtiqueta BIT NOT NULL CONSTRAINT DF_ResguardoDetalle_ImprimeEtiqueta DEFAULT(1),
    Observaciones NVARCHAR(1000) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_ResguardoDetalle_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_ResguardoDetalle_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT FK_ResguardoDetalle_Resguardo FOREIGN KEY(FKIdResguardo_ALMA) REFERENCES ALMA.Resguardo(PKIdResguardo),
    CONSTRAINT FK_ResguardoDetalle_Bien FOREIGN KEY(FKIdBien_ALMA) REFERENCES ALMA.Bien(PKIdBien),
    CONSTRAINT FK_ResguardoDetalle_EstadoBien FOREIGN KEY(FKIdEstadoBien_ALMA) REFERENCES ALMA.EstadoBien(PKIdEstadoBien)
);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'UX_ResguardoDetalle_BienActivo'
      AND object_id = OBJECT_ID(N'ALMA.ResguardoDetalle')
)
CREATE UNIQUE INDEX UX_ResguardoDetalle_BienActivo
ON ALMA.ResguardoDetalle(FKIdBien_ALMA)
WHERE Activo = 1;
GO

IF OBJECT_ID(N'ALMA.ResguardoMovimiento', N'U') IS NULL
CREATE TABLE ALMA.ResguardoMovimiento (
    PKIdResguardoMovimiento INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ResguardoMovimiento PRIMARY KEY,
    FKIdResguardoDetalle_ALMA INT NULL,
    FKIdBien_ALMA INT NOT NULL,
    FKIdResguardoOrigen_ALMA INT NULL,
    FKIdResguardoDestino_ALMA INT NULL,
    TipoMovimiento NVARCHAR(30) NOT NULL,
    FechaMovimiento DATETIME2(0) NOT NULL CONSTRAINT DF_ResguardoMovimiento_FechaMovimiento DEFAULT(SYSDATETIME()),
    Observaciones NVARCHAR(1000) NULL,
    Activo BIT NOT NULL CONSTRAINT DF_ResguardoMovimiento_Activo DEFAULT(1),
    FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_ResguardoMovimiento_FechaCreacion DEFAULT(SYSDATETIME()),
    UsuarioCreacion INT NOT NULL,
    FechaModificacion DATETIME2(0) NULL,
    UsuarioModificacion INT NULL,
    CONSTRAINT CK_ResguardoMovimiento_Tipo CHECK (TipoMovimiento IN (N'ASIGNACION', N'TRASPASO', N'DEVOLUCION', N'BAJA')),
    CONSTRAINT FK_ResguardoMovimiento_Detalle FOREIGN KEY(FKIdResguardoDetalle_ALMA) REFERENCES ALMA.ResguardoDetalle(PKIdResguardoDetalle),
    CONSTRAINT FK_ResguardoMovimiento_Bien FOREIGN KEY(FKIdBien_ALMA) REFERENCES ALMA.Bien(PKIdBien),
    CONSTRAINT FK_ResguardoMovimiento_Origen FOREIGN KEY(FKIdResguardoOrigen_ALMA) REFERENCES ALMA.Resguardo(PKIdResguardo),
    CONSTRAINT FK_ResguardoMovimiento_Destino FOREIGN KEY(FKIdResguardoDestino_ALMA) REFERENCES ALMA.Resguardo(PKIdResguardo)
);
GO