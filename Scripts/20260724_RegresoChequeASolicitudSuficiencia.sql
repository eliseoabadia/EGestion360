SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'PRES.RegresoChequeSuficiencia', N'U') IS NULL
BEGIN
    CREATE TABLE PRES.RegresoChequeSuficiencia
    (
        PKIdRegresoChequeSuficiencia INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_RegresoChequeSuficiencia PRIMARY KEY,
        FKIdEmpresa_SIS INT NOT NULL,
        FKIdCheque_PRES INT NOT NULL,
        FKIdSolicitudSuficiencia_PRES INT NOT NULL,
        Motivo NVARCHAR(1000) NOT NULL,
        FechaRegreso DATETIME2(0) NOT NULL
            CONSTRAINT DF_RegresoChequeSuficiencia_FechaRegreso DEFAULT SYSDATETIME(),
        Activo BIT NOT NULL
            CONSTRAINT DF_RegresoChequeSuficiencia_Activo DEFAULT (1),
        FechaCreacion DATETIME2(0) NOT NULL
            CONSTRAINT DF_RegresoChequeSuficiencia_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        CONSTRAINT UQ_RegresoChequeSuficiencia_Cheque UNIQUE (FKIdCheque_PRES),
        CONSTRAINT FK_RegresoChequeSuficiencia_Empresa
            FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa),
        CONSTRAINT FK_RegresoChequeSuficiencia_Cheque
            FOREIGN KEY (FKIdCheque_PRES) REFERENCES PRES.Cheque(PKIdCheque),
        CONSTRAINT FK_RegresoChequeSuficiencia_Solicitud
            FOREIGN KEY (FKIdSolicitudSuficiencia_PRES)
            REFERENCES PRES.SolicitudSuficiencia(PKIdSolicitudSuficiencia),
        CONSTRAINT FK_RegresoChequeSuficiencia_Usuario
            FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END;
GO

-- Compatibilidad: la bitacora conserva ahora el punto real de regreso.
IF COL_LENGTH(N'PRES.RegresoChequeSuficiencia', N'FKIdRequisicion_ORCO') IS NULL
    ALTER TABLE PRES.RegresoChequeSuficiencia ADD FKIdRequisicion_ORCO INT NULL;
IF COL_LENGTH(N'PRES.RegresoChequeSuficiencia', N'FKIdOrdenCompra_ORCO') IS NULL
    ALTER TABLE PRES.RegresoChequeSuficiencia ADD FKIdOrdenCompra_ORCO INT NULL;
IF COL_LENGTH(N'PRES.RegresoChequeSuficiencia', N'FKIdCotizacion_ORCO') IS NULL
    ALTER TABLE PRES.RegresoChequeSuficiencia ADD FKIdCotizacion_ORCO INT NULL;
GO

IF OBJECT_ID(N'PRES.RegresoChequeSuficienciaPoliza', N'U') IS NULL
BEGIN
    CREATE TABLE PRES.RegresoChequeSuficienciaPoliza
    (
        PKIdRegresoChequeSuficienciaPoliza INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_RegresoChequeSuficienciaPoliza PRIMARY KEY,
        FKIdRegresoChequeSuficiencia_PRES INT NOT NULL,
        FKIdPolizaOriginal_CONTA INT NOT NULL,
        FKIdPolizaReversion_CONTA INT NOT NULL,
        Etapas NVARCHAR(250) NOT NULL,
        Activo BIT NOT NULL
            CONSTRAINT DF_RegresoChequeSuficienciaPoliza_Activo DEFAULT (1),
        FechaCreacion DATETIME2(0) NOT NULL
            CONSTRAINT DF_RegresoChequeSuficienciaPoliza_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        CONSTRAINT UQ_RegresoChequeSuficienciaPoliza_Original
            UNIQUE (FKIdRegresoChequeSuficiencia_PRES, FKIdPolizaOriginal_CONTA),
        CONSTRAINT UQ_RegresoChequeSuficienciaPoliza_Reversion
            UNIQUE (FKIdPolizaReversion_CONTA),
        CONSTRAINT FK_RegresoChequeSuficienciaPoliza_Regreso
            FOREIGN KEY (FKIdRegresoChequeSuficiencia_PRES)
            REFERENCES PRES.RegresoChequeSuficiencia(PKIdRegresoChequeSuficiencia),
        CONSTRAINT FK_RegresoChequeSuficienciaPoliza_Original
            FOREIGN KEY (FKIdPolizaOriginal_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza),
        CONSTRAINT FK_RegresoChequeSuficienciaPoliza_Reversion
            FOREIGN KEY (FKIdPolizaReversion_CONTA) REFERENCES CONTA.Poliza(PKIdPoliza),
        CONSTRAINT FK_RegresoChequeSuficienciaPoliza_Usuario
            FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END;
GO

CREATE OR ALTER PROCEDURE PRES.SP_RegresarChequeASolicitudSuficiencia
    @PKIdCheque INT,
    @FKIdEmpresa_SIS INT,
    @Motivo NVARCHAR(1000),
    @IdUser INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    SET @Motivo = LTRIM(RTRIM(COALESCE(@Motivo, N'')));

    IF @PKIdCheque <= 0 OR @FKIdEmpresa_SIS <= 0 OR @IdUser <= 0
        THROW 51000, N'No fue posible identificar el cheque, la empresa o el usuario activo.', 1;

    IF LEN(@Motivo) < 10
        THROW 51001, N'Capture un motivo de al menos 10 caracteres para regresar el cheque.', 1;

    DECLARE
        @PKIdCLC INT,
        @PKIdContrato INT,
        @PKIdAutorizacion INT,
        @PKIdSolicitud INT,
        @PKIdRequisicion INT,
        @PKIdOrdenCompra INT,
        @PKIdCotizacion INT,
        @PKIdRegreso INT,
        @PolizasGeneradas INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @PKIdRegreso = R.PKIdRegresoChequeSuficiencia,
               @PKIdSolicitud = R.FKIdSolicitudSuficiencia_PRES,
               @PKIdRequisicion = R.FKIdRequisicion_ORCO
        FROM PRES.RegresoChequeSuficiencia R WITH (UPDLOCK, HOLDLOCK)
        WHERE R.FKIdCheque_PRES = @PKIdCheque
          AND R.FKIdEmpresa_SIS = @FKIdEmpresa_SIS;

        IF @PKIdRegreso IS NOT NULL
        BEGIN
            SELECT @PolizasGeneradas = COUNT(*)
            FROM PRES.RegresoChequeSuficienciaPoliza
            WHERE FKIdRegresoChequeSuficiencia_PRES = @PKIdRegreso
              AND Activo = 1;

            COMMIT TRANSACTION;

            SELECT @PKIdRegreso AS PKIdRegresoChequeSuficiencia,
                   @PKIdSolicitud AS PKIdSolicitudSuficiencia,
                   @PKIdRequisicion AS PKIdRequisicion,
                   @PolizasGeneradas AS PolizasGeneradas,
                   CAST(1 AS BIT) AS YaProcesado;
            RETURN;
        END;

        SELECT @PKIdCLC = C.FKIdCLC_PRES
        FROM PRES.Cheque C WITH (UPDLOCK, HOLDLOCK)
        WHERE C.PKIdCheque = @PKIdCheque
          AND C.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
          AND C.Activo = 1
          AND C.Estatus >= 2;

        IF @PKIdCLC IS NULL
            THROW 51002, N'El cheque no existe, no pertenece a la empresa activa o todavía no está autorizado.', 1;

        SELECT @PKIdContrato = C.FKIdContrato_PRES
        FROM PRES.CLC C WITH (UPDLOCK, HOLDLOCK)
        WHERE C.PKIdCLC = @PKIdCLC
          AND C.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
          AND C.Activo = 1;

        SELECT @PKIdAutorizacion = C.FKIdAutorizacionSuficiencia_PRES
        FROM PRES.Contrato C WITH (UPDLOCK, HOLDLOCK)
        WHERE C.PKIdContrato = @PKIdContrato
          AND C.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
          AND C.Activo = 1;

        SELECT @PKIdSolicitud = A.FKIdSolicitudSuficiencia_PRES
        FROM PRES.AutorizacionSuficiencia A WITH (UPDLOCK, HOLDLOCK)
        WHERE A.PKIdAutorizacionSuficiencia = @PKIdAutorizacion
          AND A.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
          AND A.Activo = 1;

        SELECT @PKIdRequisicion = S.FKIdRequisicion_ORCO
        FROM PRES.SolicitudSuficiencia S WITH (UPDLOCK, HOLDLOCK)
        WHERE S.PKIdSolicitudSuficiencia = @PKIdSolicitud
          AND S.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
          AND S.Activo = 1;

        IF @PKIdRequisicion IS NULL OR NOT EXISTS
        (
            SELECT 1 FROM ORCO.Requisicion R WITH (UPDLOCK, HOLDLOCK)
            WHERE R.PKIdRequisicion = @PKIdRequisicion
              AND R.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND R.Activo = 1
        )
            THROW 51013, N'La requisicion de origen ya no esta activa o no pertenece a la empresa actual.', 1;

        SELECT @PKIdOrdenCompra = MIN(O.PKIdOrdenCompra)
        FROM ORCO.OrdenCompra O WITH (UPDLOCK, HOLDLOCK)
        WHERE O.FKIdRequisicion_ORCO = @PKIdRequisicion
          AND O.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND O.Activo = 1;

        IF (SELECT COUNT(*) FROM ORCO.OrdenCompra O WITH (UPDLOCK, HOLDLOCK)
            WHERE O.FKIdRequisicion_ORCO = @PKIdRequisicion
              AND O.FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND O.Activo = 1) > 1
            THROW 51014, N'La requisicion tiene mas de una orden activa. Resuelva las ramas adicionales antes de regresar el cheque.', 1;

        SELECT @PKIdCotizacion = O.FKIdCotizacion_ORCO
        FROM ORCO.OrdenCompra O WHERE O.PKIdOrdenCompra = @PKIdOrdenCompra;

        IF EXISTS
        (
            SELECT 1
            FROM ALMA.Almacen A WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN ORCO.OrdenCompraDetalle OD
                ON OD.PKIdOrdenCompraDetalle = A.FKIdDetalleOrdenCompra_ORCO
            WHERE OD.FKIdOrdenCompra_ORCO = @PKIdOrdenCompra AND A.Activo = 1
              AND (A.InventarioCerrado = 1 OR A.EsContabilizado = 1
                   OR EXISTS (SELECT 1 FROM ALMA.DetalleSolicitudSalida DS
                              WHERE DS.FKIdAlmacen_ALMA = A.PKIdAlmacen AND DS.Activo = 1))
        )
            THROW 51015, N'La orden tiene entradas cerradas, contabilizadas o con salidas. Primero tramite su devolucion en Almacen.', 1;

        IF @PKIdContrato IS NULL OR @PKIdAutorizacion IS NULL OR @PKIdSolicitud IS NULL
            THROW 51003, N'La cadena cheque, CLC, contrato, autorización y solicitud está incompleta o ya fue modificada.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM PRES.SolicitudSuficiencia S WITH (UPDLOCK, HOLDLOCK)
            WHERE S.PKIdSolicitudSuficiencia = @PKIdSolicitud
              AND S.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
              AND S.Activo = 1
        )
            THROW 51004, N'La solicitud de suficiencia de origen ya no está activa.', 1;

        IF EXISTS
        (
            SELECT 1 FROM PRES.Cheque WITH (UPDLOCK, HOLDLOCK)
            WHERE FKIdCLC_PRES = @PKIdCLC AND Activo = 1 AND PKIdCheque <> @PKIdCheque
        )
            THROW 51005, N'La CLC tiene otro cheque activo. No es seguro regresar toda la cadena desde este cheque.', 1;

        IF EXISTS
        (
            SELECT 1 FROM PRES.CLC WITH (UPDLOCK, HOLDLOCK)
            WHERE FKIdContrato_PRES = @PKIdContrato AND Activo = 1 AND PKIdCLC <> @PKIdCLC
        )
            THROW 51006, N'El contrato tiene otra CLC activa. Debe resolver esa rama antes de regresar a suficiencia.', 1;

        IF EXISTS
        (
            SELECT 1 FROM PRES.Contrato WITH (UPDLOCK, HOLDLOCK)
            WHERE FKIdAutorizacionSuficiencia_PRES = @PKIdAutorizacion
              AND Activo = 1 AND PKIdContrato <> @PKIdContrato
        )
            THROW 51007, N'La autorización tiene otro contrato activo. No se puede cancelar una rama compartida.', 1;

        IF EXISTS
        (
            SELECT 1 FROM PRES.AutorizacionSuficiencia WITH (UPDLOCK, HOLDLOCK)
            WHERE FKIdSolicitudSuficiencia_PRES = @PKIdSolicitud
              AND Activo = 1 AND PKIdAutorizacionSuficiencia <> @PKIdAutorizacion
        )
            THROW 51008, N'La solicitud tiene otra autorización activa. No se puede regresar una rama compartida.', 1;

        DECLARE @Facturas TABLE
        (
            PKIdFactura INT NOT NULL PRIMARY KEY,
            FKIdPoliza_CONTA INT NOT NULL
        );

        INSERT INTO @Facturas (PKIdFactura, FKIdPoliza_CONTA)
        SELECT F.PKIdFactura, F.FKIdPoliza_CONTA
        FROM PRES.Factura F WITH (UPDLOCK, HOLDLOCK)
        WHERE F.FKIdContrato_PRES = @PKIdContrato
          AND F.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
          AND F.Activo = 1;

        DECLARE @EtapasPoliza TABLE
        (
            FKIdPoliza_CONTA INT NOT NULL,
            Etapa NVARCHAR(50) NOT NULL
        );

        INSERT INTO @EtapasPoliza (FKIdPoliza_CONTA, Etapa)
        SELECT FKIdPoliza_CONTA, N'Cheque'
        FROM PRES.Cheque WHERE PKIdCheque = @PKIdCheque
        UNION ALL
        SELECT FKIdPoliza_CONTA, N'CLC'
        FROM PRES.CLC WHERE PKIdCLC = @PKIdCLC
        UNION ALL
        SELECT FKIdPoliza_CONTA, N'Contrato'
        FROM PRES.Contrato WHERE PKIdContrato = @PKIdContrato AND FKIdPoliza_CONTA IS NOT NULL
        UNION ALL
        SELECT FKIdPoliza_CONTA, N'Factura'
        FROM @Facturas
        UNION ALL
        SELECT FKIdPoliza_CONTA, N'Orden de compra'
        FROM ORCO.OrdenCompra
        WHERE PKIdOrdenCompra = @PKIdOrdenCompra AND FKIdPoliza_CONTA IS NOT NULL;

        DECLARE @Polizas TABLE
        (
            FKIdPolizaOriginal_CONTA INT NOT NULL PRIMARY KEY,
            Etapas NVARCHAR(250) NOT NULL
        );

        INSERT INTO @Polizas (FKIdPolizaOriginal_CONTA, Etapas)
        SELECT E.FKIdPoliza_CONTA,
               STRING_AGG(CONVERT(NVARCHAR(MAX), E.Etapa), N', ')
        FROM (SELECT DISTINCT FKIdPoliza_CONTA, Etapa FROM @EtapasPoliza) E
        GROUP BY E.FKIdPoliza_CONTA;

        IF NOT EXISTS (SELECT 1 FROM @Polizas)
            THROW 51009, N'La cadena no tiene pólizas asociadas que puedan revertirse.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM @Polizas X
            LEFT JOIN CONTA.Poliza P WITH (UPDLOCK, HOLDLOCK)
              ON P.PKIdPoliza = X.FKIdPolizaOriginal_CONTA AND P.Activo = 1
            WHERE P.PKIdPoliza IS NULL
               OR NOT EXISTS
                  (
                      SELECT 1 FROM CONTA.PolizaDetalle D
                      WHERE D.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA AND D.Activo = 1
                  )
               OR EXISTS
                  (
                      SELECT 1
                      FROM CONTA.PolizaDetalle D
                      WHERE D.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA AND D.Activo = 1
                      GROUP BY D.FKIdPoliza_CONTA
                      HAVING ABS(SUM(COALESCE(D.ImporteDebe, 0)) - SUM(COALESCE(D.ImporteHaber, 0))) > 0.01
                  )
        )
            THROW 51010, N'Una póliza de la cadena está inactiva, no tiene movimientos o no está balanceada.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM @Polizas X
            WHERE EXISTS (SELECT 1 FROM ALMA.Bajas B WHERE B.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA)
               OR EXISTS (SELECT 1 FROM ALMA.SolicitudSalida S WHERE S.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA)
               OR EXISTS (SELECT 1 FROM ORCO.OrdenCompra O WHERE O.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA AND O.PKIdOrdenCompra <> COALESCE(@PKIdOrdenCompra, -1))
               OR EXISTS (SELECT 1 FROM PRES.EgresoAutorizado E WHERE E.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA)
               OR EXISTS (SELECT 1 FROM PRES.IngreAdecuacion I WHERE I.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA)
               OR EXISTS (SELECT 1 FROM PRES.IngresoAutorizado I WHERE I.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA)
               OR EXISTS (SELECT 1 FROM PRES.Cheque C WHERE C.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA AND C.PKIdCheque <> @PKIdCheque)
               OR EXISTS (SELECT 1 FROM PRES.CLC C WHERE C.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA AND C.PKIdCLC <> @PKIdCLC)
               OR EXISTS
                  (
                      SELECT 1 FROM PRES.Factura F
                      WHERE F.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA
                        AND NOT EXISTS (SELECT 1 FROM @Facturas T WHERE T.PKIdFactura = F.PKIdFactura)
                  )
               OR EXISTS (SELECT 1 FROM PRES.Contrato C WHERE C.FKIdPoliza_CONTA = X.FKIdPolizaOriginal_CONTA AND C.PKIdContrato <> @PKIdContrato)
        )
            THROW 51011, N'Una póliza está compartida con otro documento. El regreso fue bloqueado para no afectar movimientos ajenos.', 1;

        INSERT INTO PRES.RegresoChequeSuficiencia
        (
            FKIdEmpresa_SIS,
            FKIdCheque_PRES,
            FKIdSolicitudSuficiencia_PRES,
            FKIdRequisicion_ORCO,
            FKIdOrdenCompra_ORCO,
            FKIdCotizacion_ORCO,
            Motivo,
            UsuarioCreacion
        )
        VALUES
        (
            @FKIdEmpresa_SIS,
            @PKIdCheque,
            @PKIdSolicitud,
            @PKIdRequisicion,
            @PKIdOrdenCompra,
            @PKIdCotizacion,
            @Motivo,
            @IdUser
        );

        SET @PKIdRegreso = SCOPE_IDENTITY();

        DECLARE
            @PKIdPolizaOriginal INT,
            @PKIdPolizaReversion INT,
            @FKIdAnio INT,
            @FKIdMes INT,
            @FKIdTipoPoliza INT,
            @FechaPoliza DATETIME,
            @ClaveOriginal NVARCHAR(20),
            @ClaveReversion NVARCHAR(20),
            @NombreReversion NVARCHAR(2000),
            @Etapas NVARCHAR(250),
            @Error NVARCHAR(MAX),
            @ResultadoClave INT;

        DECLARE PolizasCursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT X.FKIdPolizaOriginal_CONTA, X.Etapas
            FROM @Polizas X
            ORDER BY X.FKIdPolizaOriginal_CONTA;

        OPEN PolizasCursor;
        FETCH NEXT FROM PolizasCursor INTO @PKIdPolizaOriginal, @Etapas;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @FKIdAnio = P.FKIdAnio_SIS,
                   @FKIdMes = P.FKIdMes_SIS,
                   @FKIdTipoPoliza = P.FKIdTipoPoliza_SIS,
                   @FechaPoliza = P.FechaPoliza,
                   @ClaveOriginal = P.ClavePoliza
            FROM CONTA.Poliza P
            WHERE P.PKIdPoliza = @PKIdPolizaOriginal;

            SET @ClaveReversion = NULL;
            SET @Error = NULL;

            EXEC @ResultadoClave = CONTA.SP_CREATE_ClavePoliza
                @FK_IdAnio__SIS = @FKIdAnio,
                @FK_IdMesConta__SIS = @FKIdMes,
                @FK_IdTipoPolizaConta__SIS = @FKIdTipoPoliza,
                @CT_ModifiedBy = @IdUser,
                @ClavePoliza = @ClaveReversion OUTPUT,
                @Error = @Error OUTPUT;

            IF @ResultadoClave <> 0 OR NULLIF(@ClaveReversion, N'') IS NULL
            BEGIN
                SET @Error = LEFT(COALESCE(NULLIF(@Error, N''), N'No se pudo generar la clave de la póliza de reversión.'), 2048);
                THROW 51012, @Error, 1;
            END;

            SET @NombreReversion = LEFT(
                CONCAT(N'Reversión ', @ClaveOriginal, N' por regreso de cheque ', @PKIdCheque,
                       N' a solicitud de suficiencia. Etapas: ', @Etapas),
                2000);

            INSERT INTO CONTA.Poliza
            (
                FKIdAnio_SIS,
                FKIdMes_SIS,
                FKIdTipoPoliza_SIS,
                ClavePoliza,
                NombrePoliza,
                FechaPoliza,
                EstaBalanceado,
                Activo,
                FechaCreacion,
                UsuarioCreacion,
                PermitirModificar,
                Autorizado,
                FechaSolicitud,
                FechaAutorizacion
            )
            VALUES
            (
                @FKIdAnio,
                @FKIdMes,
                @FKIdTipoPoliza,
                @ClaveReversion,
                @NombreReversion,
                @FechaPoliza,
                1,
                1,
                SYSDATETIME(),
                @IdUser,
                0,
                1,
                SYSDATETIME(),
                SYSDATETIME()
            );

            SET @PKIdPolizaReversion = SCOPE_IDENTITY();

            INSERT INTO CONTA.PolizaDetalle
            (
                FKIdCuentaContable_CONTA,
                FKIdPoliza_CONTA,
                Descripcion,
                ImporteDebe,
                ImporteHaber,
                FKIdReferencia,
                FKIdTipoDetallePoliza_SIS,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            SELECT D.FKIdCuentaContable_CONTA,
                   @PKIdPolizaReversion,
                   LEFT(CONCAT(N'Reversión: ', COALESCE(D.Descripcion, N'')), 1200),
                   COALESCE(D.ImporteHaber, 0),
                   COALESCE(D.ImporteDebe, 0),
                   @PKIdCheque,
                   CASE D.FKIdTipoDetallePoliza_SIS
                       WHEN 1 THEN 2
                       WHEN 2 THEN 1
                       WHEN 3 THEN 4
                       WHEN 4 THEN 3
                       ELSE D.FKIdTipoDetallePoliza_SIS
                   END,
                   1,
                   SYSDATETIME(),
                   @IdUser
            FROM CONTA.PolizaDetalle D
            WHERE D.FKIdPoliza_CONTA = @PKIdPolizaOriginal
              AND D.Activo = 1;

            INSERT INTO PRES.RegresoChequeSuficienciaPoliza
            (
                FKIdRegresoChequeSuficiencia_PRES,
                FKIdPolizaOriginal_CONTA,
                FKIdPolizaReversion_CONTA,
                Etapas,
                UsuarioCreacion
            )
            VALUES
            (
                @PKIdRegreso,
                @PKIdPolizaOriginal,
                @PKIdPolizaReversion,
                @Etapas,
                @IdUser
            );

            SET @PolizasGeneradas += 1;
            FETCH NEXT FROM PolizasCursor INTO @PKIdPolizaOriginal, @Etapas;
        END;

        CLOSE PolizasCursor;
        DEALLOCATE PolizasCursor;

        UPDATE PRES.ChequePartidas
        SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE FKIdCheque_PRES = @PKIdCheque AND Activo = 1;

        UPDATE PRES.Cheque
        SET Estatus = 4,
            Activo = 0,
            Observaciones = LEFT(CONCAT(COALESCE(Observaciones + N' | ', N''),
                N'Regresado a solicitud de suficiencia. Motivo: ', @Motivo), 1000),
            FechaModificacion = SYSDATETIME(),
            UsuarioModificacion = @IdUser
        WHERE PKIdCheque = @PKIdCheque AND Activo = 1;

        UPDATE PRES.CLCFactura
        SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE Activo = 1
          AND
          (
              FKIdCLC_PRES = @PKIdCLC
              OR EXISTS
                 (
                     SELECT 1 FROM @Facturas F
                     WHERE F.PKIdFactura = PRES.CLCFactura.FKIdFactura_PRES
                 )
          );

        UPDATE PRES.CLCDetalle
        SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE FKIdCLC_PRES = @PKIdCLC AND Activo = 1;

        UPDATE PRES.CLC
        SET Estatus = 4,
            Activo = 0,
            Observaciones = LEFT(CONCAT(COALESCE(Observaciones + N' | ', N''),
                N'Regresada a solicitud de suficiencia. Motivo: ', @Motivo), 1000),
            FechaModificacion = SYSDATETIME(),
            UsuarioModificacion = @IdUser
        WHERE PKIdCLC = @PKIdCLC AND Activo = 1;

        UPDATE D
        SET D.Activo = 0, D.FechaModificacion = SYSDATETIME(), D.UsuarioModificacion = @IdUser
        FROM PRES.FacturaDetalle D
        INNER JOIN @Facturas F ON F.PKIdFactura = D.FKIdFactura_PRES
        WHERE D.Activo = 1;

        UPDATE F
        SET F.Estatus = 4,
            F.Activo = 0,
            F.Observaciones = CONCAT(COALESCE(F.Observaciones + N' | ', N''),
                N'Regresada a solicitud de suficiencia. Motivo: ', @Motivo),
            F.FechaModificacion = SYSDATETIME(),
            F.UsuarioModificacion = @IdUser
        FROM PRES.Factura F
        INNER JOIN @Facturas T ON T.PKIdFactura = F.PKIdFactura
        WHERE F.Activo = 1;

        EXEC sys.sp_set_session_context @key = N'EG_ALLOW_CONTRACT_REVERSAL', @value = 1;

        UPDATE PRES.ContratoDetalle
        SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE FKIdContrato_PRES = @PKIdContrato AND Activo = 1;

        UPDATE PRES.Contrato
        SET Estatus = 4,
            Activo = 0,
            Observaciones = CONCAT(COALESCE(Observaciones + N' | ', N''),
                N'Regresado a solicitud de suficiencia. Motivo: ', @Motivo),
            FechaModificacion = SYSDATETIME(),
            UsuarioModificacion = @IdUser
        WHERE PKIdContrato = @PKIdContrato AND Activo = 1;

        EXEC sys.sp_set_session_context @key = N'EG_ALLOW_CONTRACT_REVERSAL', @value = NULL;

        UPDATE PRES.AutorizacionSuficienciaDetalle
        SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE FKIdAutorizacionSuficiencia_PRES = @PKIdAutorizacion AND Activo = 1;

        UPDATE PRES.AutorizacionSuficiencia
        SET Estatus = 3,
            Activo = 0,
            Observaciones = LEFT(CONCAT(COALESCE(Observaciones + N' | ', N''),
                N'Regresada desde cheque. Motivo: ', @Motivo), 1000),
            FechaModificacion = SYSDATETIME(),
            UsuarioModificacion = @IdUser
        WHERE PKIdAutorizacionSuficiencia = @PKIdAutorizacion AND Activo = 1;

        UPDATE PRES.SolicitudSuficiencia
        SET Estatus = 1,
            Activo = 0,
            Justificacion = LEFT(CONCAT(COALESCE(Justificacion + N' | ', N''),
                N'Regresada desde cheque para corrección. Motivo: ', @Motivo), 2000),
            FechaModificacion = SYSDATETIME(),
            UsuarioModificacion = @IdUser
        WHERE PKIdSolicitudSuficiencia = @PKIdSolicitud;

        UPDATE PRES.SolicitudSuficienciaDetalle
        SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE FKIdSolicitudSuficiencia_PRES = @PKIdSolicitud AND Activo = 1;

        -- Entradas abiertas: se anulan; las cerradas, contabilizadas o consumidas
        -- fueron bloqueadas antes para exigir una devolucion formal.
        UPDATE A
        SET A.Activo = 0, A.FechaModificacion = SYSDATETIME(), A.UsuarioModificacion = @IdUser
        FROM ALMA.Almacen A
        INNER JOIN ORCO.OrdenCompraDetalle OD
            ON OD.PKIdOrdenCompraDetalle = A.FKIdDetalleOrdenCompra_ORCO
        WHERE OD.FKIdOrdenCompra_ORCO = @PKIdOrdenCompra AND A.Activo = 1;

        UPDATE ORCO.OrdenCompraDetalle
        SET CantidadRecibida = 0, Activo = 0,
            FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE FKIdOrdenCompra_ORCO = @PKIdOrdenCompra AND Activo = 1;

        UPDATE ORCO.OrdenCompraPartida
        SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE FKIdOrdenCompra_ORCO = @PKIdOrdenCompra AND Activo = 1;

        UPDATE ORCO.Contratos
        SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE FKIdOrdenCompra_ORCO = @PKIdOrdenCompra AND Activo = 1;

        EXEC sys.sp_set_session_context @key = N'EG_ALLOW_ORDER_REVERSAL', @value = 1;

        UPDATE ORCO.OrdenCompra
        SET Activo = 0,
            FechaCancelacion = CONVERT(date, SYSDATETIME()),
            MotivoCancelacion = LEFT(@Motivo, 1000),
            Observaciones = LEFT(CONCAT(COALESCE(Observaciones + N' | ', N''),
                N'Regresada hasta requisicion desde cheque ', @PKIdCheque, N'.'), 2000),
            FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE PKIdOrdenCompra = @PKIdOrdenCompra AND Activo = 1;

        EXEC sys.sp_set_session_context @key = N'EG_ALLOW_ORDER_REVERSAL', @value = NULL;

        UPDATE CD
        SET CD.Activo = 0, CD.FechaModificacion = SYSDATETIME(), CD.UsuarioModificacion = @IdUser
        FROM ORCO.CotizacionDetalle CD
        INNER JOIN ORCO.Cotizacion C ON C.PKIdCotizacion = CD.FKIdCotizacion_ORCO
        WHERE C.FKIdRequisicion_ORCO = @PKIdRequisicion AND CD.Activo = 1;

        UPDATE ORCO.Cotizacion
        SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE FKIdRequisicion_ORCO = @PKIdRequisicion AND Activo = 1;

        UPDATE ORCO.Requisicion
        SET Activo = 1,
            Observaciones = LEFT(CONCAT(COALESCE(Observaciones + N' | ', N''),
                N'Expediente reabierto desde cheque ', @PKIdCheque, N'. Motivo: ', @Motivo), 2000),
            FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
        WHERE PKIdRequisicion = @PKIdRequisicion;

        COMMIT TRANSACTION;

        SELECT @PKIdRegreso AS PKIdRegresoChequeSuficiencia,
               @PKIdSolicitud AS PKIdSolicitudSuficiencia,
               @PKIdRequisicion AS PKIdRequisicion,
               @PolizasGeneradas AS PolizasGeneradas,
               CAST(0 AS BIT) AS YaProcesado;
    END TRY
    BEGIN CATCH
        EXEC sys.sp_set_session_context @key = N'EG_ALLOW_ORDER_REVERSAL', @value = NULL;
        EXEC sys.sp_set_session_context @key = N'EG_ALLOW_CONTRACT_REVERSAL', @value = NULL;
        IF CURSOR_STATUS('local', 'PolizasCursor') >= 0
            CLOSE PolizasCursor;
        IF CURSOR_STATUS('local', 'PolizasCursor') >= -1
            DEALLOCATE PolizasCursor;

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
