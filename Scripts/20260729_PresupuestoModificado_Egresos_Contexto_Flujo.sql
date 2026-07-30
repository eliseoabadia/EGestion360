SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* Encabezado de adecuacion: empresa obligatoria y unica. */
IF COL_LENGTH(N'PRES.EgreAdecuacion', N'FKIdEmpresa_SIS') IS NULL
BEGIN
    ALTER TABLE PRES.EgreAdecuacion ADD FKIdEmpresa_SIS INT NULL;
END
GO

;WITH EmpresaInferida AS
(
    SELECT d.FKIdEgreAdecuacion_PRES, MIN(e.FKIdEmpresa_SIS) AS FKIdEmpresa_SIS
    FROM PRES.EgreAdecuacionDetalle d
    INNER JOIN PRES.EgresoAutorizado e ON e.PKIdEgresoAutorizado = d.FKIdEgresoAutorizado_PRES
    GROUP BY d.FKIdEgreAdecuacion_PRES
    HAVING COUNT(DISTINCT e.FKIdEmpresa_SIS) = 1
)
UPDATE a
SET FKIdEmpresa_SIS = i.FKIdEmpresa_SIS
FROM PRES.EgreAdecuacion a
INNER JOIN EmpresaInferida i ON i.FKIdEgreAdecuacion_PRES = a.PKIdEgreAdecuacion
WHERE a.FKIdEmpresa_SIS IS NULL;
GO

IF EXISTS (SELECT 1 FROM PRES.EgreAdecuacion WHERE FKIdEmpresa_SIS IS NULL)
    THROW 51001, 'No se puede asignar empresa a una o mas adecuaciones existentes. Corrige los datos antes de aplicar el contexto obligatorio.', 1;
GO

IF EXISTS
(
    SELECT 1
    FROM PRES.EgreAdecuacionDetalle d
    INNER JOIN PRES.EgresoAutorizado e ON e.PKIdEgresoAutorizado = d.FKIdEgresoAutorizado_PRES
    GROUP BY d.FKIdEgreAdecuacion_PRES
    HAVING COUNT(DISTINCT e.FKIdEmpresa_SIS) > 1
)
    THROW 51002, 'Existe una adecuacion con movimientos de empresas distintas. Corrige los datos antes de aplicar el contexto obligatorio.', 1;
GO

IF EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'PRES.EgreAdecuacion')
      AND name = N'FKIdEmpresa_SIS'
      AND is_nullable = 1
)
BEGIN
    ALTER TABLE PRES.EgreAdecuacion ALTER COLUMN FKIdEmpresa_SIS INT NOT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_EgreAdecuacion_Empresa')
BEGIN
    ALTER TABLE PRES.EgreAdecuacion WITH CHECK
        ADD CONSTRAINT FK_EgreAdecuacion_Empresa
        FOREIGN KEY (FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'PRES.EgreAdecuacion') AND name = N'IX_EgreAdecuacion_Contexto')
BEGIN
    CREATE INDEX IX_EgreAdecuacion_Contexto
        ON PRES.EgreAdecuacion(FKIdEmpresa_SIS, FKIdAnio_SIS, Activo, FKIdAccionAdecuacionMaster_PRES);
END
GO

CREATE OR ALTER VIEW PRES.Vw_EgresoAdecuacion
AS
SELECT
    ea.PKIdEgreAdecuacion,
    ea.Clave,
    ea.FKIdTipoAdecuacion_PRES,
    ta.Descripcion AS TipoAdecuacionDescripcion,
    ea.FKIdEstatusAdecuacion_PRES,
    est.Descripcion AS EstatusAdecuacionDescripcion,
    est.Color AS EstatusAdecuacionColor,
    ea.Justificacion,
    ea.Fecha,
    ea.FKIdPoliza_CONTA,
    pol.ClavePoliza,
    ea.FKIdEmpresa_SIS,
    ea.FKIdAnio_SIS,
    anio.Clave AS AnioClave,
    ea.Autorizado,
    ea.FKIdAccionAdecuacionMaster_PRES,
    acc.Accion AS AccionAdecuacion,
    acc.Comentario AS AccionComentario,
    ea.FechaSolicitud,
    ea.FechaAutorizacion,
    ea.Activo,
    ea.FechaCreacion,
    ea.UsuarioCreacion,
    ea.FechaModificacion,
    ea.UsuarioModificacion,
    CONCAT(ea.Clave, ' - ', ISNULL(ea.Justificacion, '')) AS ClaveNombre
FROM PRES.EgreAdecuacion ea
LEFT JOIN PRES.TipoAdecuacion ta ON ea.FKIdTipoAdecuacion_PRES = ta.PKIdTipoAdecuacion AND ta.Activo = 1
LEFT JOIN PRES.EstatusAdecuacion est ON ea.FKIdEstatusAdecuacion_PRES = est.PKIdEstatusAdecuacion AND est.Activo = 1
LEFT JOIN CONTA.Poliza pol ON ea.FKIdPoliza_CONTA = pol.PKIdPoliza AND pol.Activo = 1
LEFT JOIN SIS.Anio anio ON ea.FKIdAnio_SIS = anio.PKIdAnio AND anio.Activo = 1
LEFT JOIN PRES.AccionAdecuacionMaster acc ON ea.FKIdAccionAdecuacionMaster_PRES = acc.PKIdAccionAdecuacionMaster AND acc.Activo = 1
WHERE ea.Activo = 1;
GO

CREATE OR ALTER VIEW PRES.Vw_EgresoAdecuacionDetalle
AS
SELECT
    det.PKIdEgreAdecuacionDetalle,
    det.FKIdEgreAdecuacion_PRES,
    enc.Clave AS EgreAdecuacionClave,
    enc.Autorizado,
    enc.FKIdEmpresa_SIS,
    enc.FKIdAnio_SIS,
    det.FKIdEgresoAutorizado_PRES,
    egr.Descripcion AS EgresoAutorizadoDescripcion,
    det.FKIdTipoMovimiento_PRES,
    tm.Descripcion AS TipoMovimientoDescripcion,
    det.Justificacion,
    det.Fecha,
    det.Enero,
    det.Febrero,
    det.Marzo,
    det.Abril,
    det.Mayo,
    det.Junio,
    det.Julio,
    det.Agosto,
    det.Septiembre,
    det.Octubre,
    det.Noviembre,
    det.Diciembre,
    det.Total,
    det.Activo,
    det.FechaCreacion,
    det.UsuarioCreacion,
    det.FechaModificacion,
    det.UsuarioModificacion
FROM PRES.EgreAdecuacionDetalle det
INNER JOIN PRES.EgreAdecuacion enc ON enc.PKIdEgreAdecuacion = det.FKIdEgreAdecuacion_PRES AND enc.Activo = 1
LEFT JOIN PRES.EgresoAutorizado egr ON det.FKIdEgresoAutorizado_PRES = egr.PKIdEgresoAutorizado AND egr.Activo = 1
LEFT JOIN PRES.TipoMovimiento tm ON det.FKIdTipoMovimiento_PRES = tm.PKIdTipoMovimiento AND tm.Activo = 1
WHERE det.Activo = 1;
GO

/* Incluye FID: no se excluye fuente de financiamiento 6. */
CREATE OR ALTER VIEW PRES.Vw_EgresoDisponible
AS
WITH AdecXEgreAut AS
(
    SELECT
        det.FKIdEgresoAutorizado_PRES,
        SUM(det.Enero) Enero, SUM(det.Febrero) Febrero, SUM(det.Marzo) Marzo,
        SUM(det.Abril) Abril, SUM(det.Mayo) Mayo, SUM(det.Junio) Junio,
        SUM(det.Julio) Julio, SUM(det.Agosto) Agosto, SUM(det.Septiembre) Septiembre,
        SUM(det.Octubre) Octubre, SUM(det.Noviembre) Noviembre, SUM(det.Diciembre) Diciembre,
        SUM(det.Total) Total
    FROM PRES.EgreAdecuacionDetalle det
    INNER JOIN PRES.EgreAdecuacion enc ON enc.PKIdEgreAdecuacion = det.FKIdEgreAdecuacion_PRES AND enc.Activo = 1 AND enc.Autorizado = 1
    INNER JOIN PRES.EgresoAutorizado egr ON egr.PKIdEgresoAutorizado = det.FKIdEgresoAutorizado_PRES AND egr.Activo = 1
    WHERE det.Activo = 1
    GROUP BY det.FKIdEgresoAutorizado_PRES
),
CtoXEgreAut AS
(
    SELECT
        COALESCE(rp.FKIdEgresoAutorizado_PRES, req.FKIdEgresoAutorizado_PRES) FKIdEgresoAutorizado_PRES,
        SUM(cd.Enero) Enero, SUM(cd.Febrero) Febrero, SUM(cd.Marzo) Marzo,
        SUM(cd.Abril) Abril, SUM(cd.Mayo) Mayo, SUM(cd.Junio) Junio,
        SUM(cd.Julio) Julio, SUM(cd.Agosto) Agosto, SUM(cd.Septiembre) Septiembre,
        SUM(cd.Octubre) Octubre, SUM(cd.Noviembre) Noviembre, SUM(cd.Diciembre) Diciembre,
        SUM(cd.Total) Total
    FROM PRES.ContratoDetalle cd
    INNER JOIN PRES.Contrato c ON c.PKIdContrato = cd.FKIdContrato_PRES AND c.Activo = 1
    INNER JOIN PRES.AutorizacionSuficiencia au ON au.PKIdAutorizacionSuficiencia = c.FKIdAutorizacionSuficiencia_PRES AND au.Activo = 1
    INNER JOIN PRES.SolicitudSuficiencia ss ON ss.PKIdSolicitudSuficiencia = au.FKIdSolicitudSuficiencia_PRES AND ss.Activo = 1
    INNER JOIN ORCO.Requisicion req ON req.PKIdRequisicion = ss.FKIdRequisicion_ORCO AND req.Activo = 1
    LEFT JOIN ORCO.RequisicionPartida rp ON rp.FKIdRequisicion_ORCO = req.PKIdRequisicion AND rp.FKIdPartida_CONTA = cd.FKIdPartida_CONTA AND rp.Activo = 1
    INNER JOIN PRES.EgresoAutorizado egr ON egr.PKIdEgresoAutorizado = COALESCE(rp.FKIdEgresoAutorizado_PRES, req.FKIdEgresoAutorizado_PRES) AND egr.Activo = 1
    WHERE cd.Activo = 1
    GROUP BY COALESCE(rp.FKIdEgresoAutorizado_PRES, req.FKIdEgresoAutorizado_PRES)
)
SELECT
    egr.PKIdEgresoAutorizado, egr.FKIdEgresoProyectado_PRES, egr.FKIdEmpresa_SIS,
    egr.FKIdAnio_SIS, egr.AnioClave,
    egr.FKIdPrograma_PRES, egr.ProgramaClave, egr.ProgramaDescripcion, egr.ProgramaClaveNombre,
    egr.FKIdPartida_CONTA, egr.PartidaClave, egr.PartidaDescripcion, egr.PartidaClaveNombre,
    egr.FKIdArea_SIS, egr.AreaClave, egr.AreaNombre,
    egr.FKIdFuenteFinanciamiento_PRES, egr.FuenteFinanciamientoClave, egr.FuenteFinanciamientoDescripcion, egr.FuenteFinanciamientoClaveNombre,
    egr.FKIdTipoGasto_PRES, egr.TipoGastoClave, egr.TipoGastoDescripcion, egr.TipoGastoClaveNombre,
    egr.FKIdDigitoIdentificador_PRES, egr.DigitoIdentificadorClave, egr.DigitoIdentificadorDescripcion, egr.DigitoIdentificadorClaveNombre,
    egr.FKIdDestinoGasto_PRES, egr.DestinoGastoClave, egr.DestinoGastoDescripcion, egr.DestinoGastoClaveNombre,
    egr.FKIdPY_PRES, egr.PyClave, egr.PyDescripcion, egr.PyClaveNombre, egr.Descripcion, egr.Fecha,
    ISNULL(egr.Enero,0)+ISNULL(ad.Enero,0)-ISNULL(ct.Enero,0) Enero,
    ISNULL(egr.Febrero,0)+ISNULL(ad.Febrero,0)-ISNULL(ct.Febrero,0) Febrero,
    ISNULL(egr.Marzo,0)+ISNULL(ad.Marzo,0)-ISNULL(ct.Marzo,0) Marzo,
    ISNULL(egr.Abril,0)+ISNULL(ad.Abril,0)-ISNULL(ct.Abril,0) Abril,
    ISNULL(egr.Mayo,0)+ISNULL(ad.Mayo,0)-ISNULL(ct.Mayo,0) Mayo,
    ISNULL(egr.Junio,0)+ISNULL(ad.Junio,0)-ISNULL(ct.Junio,0) Junio,
    ISNULL(egr.Julio,0)+ISNULL(ad.Julio,0)-ISNULL(ct.Julio,0) Julio,
    ISNULL(egr.Agosto,0)+ISNULL(ad.Agosto,0)-ISNULL(ct.Agosto,0) Agosto,
    ISNULL(egr.Septiembre,0)+ISNULL(ad.Septiembre,0)-ISNULL(ct.Septiembre,0) Septiembre,
    ISNULL(egr.Octubre,0)+ISNULL(ad.Octubre,0)-ISNULL(ct.Octubre,0) Octubre,
    ISNULL(egr.Noviembre,0)+ISNULL(ad.Noviembre,0)-ISNULL(ct.Noviembre,0) Noviembre,
    ISNULL(egr.Diciembre,0)+ISNULL(ad.Diciembre,0)-ISNULL(ct.Diciembre,0) Diciembre,
    ISNULL(egr.Total,0)+ISNULL(ad.Total,0)-ISNULL(ct.Total,0) Total,
    CAST('' AS varchar(max)) [Message],
    CONCAT(egr.PartidaClaveNombre, ' ', FORMAT(ISNULL(egr.Total,0)+ISNULL(ad.Total,0)-ISNULL(ct.Total,0), 'C', 'es-MX'), ' ', LEFT(ISNULL(egr.Descripcion,''),30)) DescripcionRequisicion
FROM PRES.Vw_EgresoAutorizado egr
LEFT JOIN AdecXEgreAut ad ON ad.FKIdEgresoAutorizado_PRES = egr.PKIdEgresoAutorizado
LEFT JOIN CtoXEgreAut ct ON ct.FKIdEgresoAutorizado_PRES = egr.PKIdEgresoAutorizado
WHERE egr.Activo = 1;
GO

CREATE OR ALTER PROCEDURE PRES.sp_MantenimientoEgresoAdecuacion
    @Action INT,
    @PKIdEgreAdecuacion INT = NULL,
    @Autorizado BIT = 0,
    @IdUser INT = NULL,
    @idMenu INT = 85,
    @AlertMessage NVARCHAR(124) = NULL,
    @Id INT = NULL OUTPUT,
    @FkIdPolizaConta INT = NULL,
    @FkIdEmpresaSis INT = NULL,
    @FkIdAnioSis INT = NULL,
    @FkIdTipoAdecuacionPres INT = NULL,
    @FkIdEstatusAdecuacionPres INT = NULL,
    @Justificacion NVARCHAR(MAX) = NULL,
    @Fecha DATETIME2(7) = NULL,
    @FkIdAccionAdecuacionMasterPres INT = NULL,
    @FechaSolicitud DATETIME2(7) = NULL,
    @FechaAutorizacion DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSDATETIME(), @Mensaje NVARCHAR(4000), @AnioClave INT,
            @Poliza INT, @AccionActual INT, @AutorizadoActual BIT, @EmpresaActual INT,
            @AnioActual INT, @TipoActual INT, @Consecutivo INT, @ClavePoliza NVARCHAR(10),
            @ErrorPoliza NVARCHAR(MAX), @Debe DECIMAL(20,4), @Haber DECIMAL(20,4),
            @Aumento DECIMAL(20,4), @Reduccion DECIMAL(20,4), @Mes INT;

    BEGIN TRY
        IF @Action NOT IN (1,2,3)
            THROW 51010, 'Accion no valida.', 1;

        IF @FkIdEmpresaSis IS NULL OR @FkIdEmpresaSis <= 0
            THROW 51011, 'La empresa activa es obligatoria.', 1;
        IF NOT EXISTS (SELECT 1 FROM SIS.Empresa WHERE PKIdEmpresa = @FkIdEmpresaSis AND Activo = 1)
            THROW 51012, 'La empresa seleccionada no esta activa.', 1;

        IF @Action IN (1,2)
        BEGIN
            SELECT @AnioClave = Clave FROM SIS.Anio WHERE PKIdAnio = @FkIdAnioSis AND Activo = 1;
            IF @AnioClave IS NULL OR @Fecha IS NULL OR YEAR(@Fecha) <> @AnioClave
                THROW 51013, 'La fecha debe pertenecer al ejercicio presupuestal activo.', 1;
        END

        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF @FkIdTipoAdecuacionPres NOT IN (1,2,3) OR NULLIF(LTRIM(RTRIM(@Justificacion)), N'') IS NULL
                THROW 51014, 'Tipo de adecuacion y justificacion son obligatorios.', 1;

            SET @Mes = MONTH(@Fecha);
            EXEC CONTA.SP_CREATE_ClavePoliza
                @FK_IdAnio__SIS = @FkIdAnioSis,
                @FK_IdMesConta__SIS = @Mes,
                @FK_IdTipoPolizaConta__SIS = 4,
                @CT_ModifiedBy = @IdUser,
                @ClavePoliza = @ClavePoliza OUTPUT,
                @Error = @ErrorPoliza OUTPUT;
            IF NULLIF(@ClavePoliza,N'') IS NULL
                THROW 51015, 'No se pudo crear la poliza de la adecuacion.', 1;

            INSERT INTO CONTA.Poliza(FKIdAnio_SIS, FKIdMes_SIS, FKIdTipoPoliza_SIS, ClavePoliza, NombrePoliza,
                FechaPoliza, EstaBalanceado, PermitirModificar, Autorizado, Activo, FechaCreacion, UsuarioCreacion)
            VALUES(@FkIdAnioSis, @Mes, 4, @ClavePoliza, LEFT(CONCAT(N'Pres. Modificado: ', @Justificacion),1000),
                @Fecha, 0, 1, 0, 1, @Now, @IdUser);
            SET @Poliza = SCOPE_IDENTITY();

            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, RIGHT(Clave,4))),0)+1
            FROM PRES.EgreAdecuacion WITH (UPDLOCK,HOLDLOCK)
            WHERE FKIdEmpresa_SIS = @FkIdEmpresaSis AND FKIdAnio_SIS = @FkIdAnioSis;

            INSERT INTO PRES.EgreAdecuacion(Clave, FKIdTipoAdecuacion_PRES, FKIdEstatusAdecuacion_PRES,
                Justificacion, Fecha, FKIdPoliza_CONTA, FKIdEmpresa_SIS, FKIdAnio_SIS, Autorizado,
                FKIdAccionAdecuacionMaster_PRES, Activo, FechaCreacion, UsuarioCreacion)
            VALUES(CONCAT(N'ADQ-',@AnioClave,N'-',@FkIdEmpresaSis,N'-',FORMAT(@Consecutivo,'D4')),
                @FkIdTipoAdecuacionPres, 1, LTRIM(RTRIM(@Justificacion)), @Fecha, @Poliza, @FkIdEmpresaSis,
                @FkIdAnioSis, 0, 1, 1, @Now, @IdUser);
            SET @Id = SCOPE_IDENTITY();
            SET @Mensaje = N'Adecuacion creada correctamente.';
        END
        ELSE
        BEGIN
            SELECT @EmpresaActual = FKIdEmpresa_SIS, @AnioActual = FKIdAnio_SIS, @TipoActual = FKIdTipoAdecuacion_PRES,
                @Poliza = FKIdPoliza_CONTA, @AccionActual = FKIdAccionAdecuacionMaster_PRES, @AutorizadoActual = Autorizado
            FROM PRES.EgreAdecuacion WITH (UPDLOCK,HOLDLOCK)
            WHERE PKIdEgreAdecuacion = @PKIdEgreAdecuacion AND Activo = 1;

            IF @EmpresaActual IS NULL
                THROW 51016, 'Adecuacion no encontrada.', 1;
            IF @EmpresaActual <> @FkIdEmpresaSis OR (@Action = 2 AND @AnioActual <> @FkIdAnioSis)
                THROW 51017, 'La adecuacion no pertenece a la empresa y ejercicio activos.', 1;

            IF @Action = 3
            BEGIN
                IF @AutorizadoActual = 1 OR @AccionActual <> 1
                    THROW 51018, 'Solo se puede eliminar una adecuacion en captura.', 1;
                UPDATE PRES.EgreAdecuacionDetalle SET Activo=0, FechaModificacion=@Now, UsuarioModificacion=@IdUser
                WHERE FKIdEgreAdecuacion_PRES=@PKIdEgreAdecuacion AND Activo=1;
                UPDATE CONTA.PolizaDetalle SET Activo=0, FechaModificacion=@Now, UsuarioModificacion=@IdUser
                WHERE FKIdPoliza_CONTA=@Poliza AND Activo=1;
                UPDATE CONTA.Poliza SET Activo=0, PermitirModificar=0, FechaModificacion=@Now, UsuarioModificacion=@IdUser
                WHERE PKIdPoliza=@Poliza AND Activo=1;
                UPDATE PRES.EgreAdecuacion SET Activo=0, FechaModificacion=@Now, UsuarioModificacion=@IdUser
                WHERE PKIdEgreAdecuacion=@PKIdEgreAdecuacion;
                SET @Id=@PKIdEgreAdecuacion;
                SET @Mensaje=N'Adecuacion eliminada correctamente.';
            END
            ELSE IF @AccionActual = 1
            BEGIN
                IF ISNULL(@FkIdAccionAdecuacionMasterPres,1) = 1
                BEGIN
                    IF @FkIdTipoAdecuacionPres <> @TipoActual OR NULLIF(LTRIM(RTRIM(@Justificacion)),N'') IS NULL
                        THROW 51019, 'No se permite cambiar el tipo y la justificacion es obligatoria.', 1;
                    UPDATE PRES.EgreAdecuacion
                    SET Justificacion=LTRIM(RTRIM(@Justificacion)), Fecha=@Fecha, FechaModificacion=@Now, UsuarioModificacion=@IdUser
                    WHERE PKIdEgreAdecuacion=@PKIdEgreAdecuacion;
                    UPDATE CONTA.Poliza SET NombrePoliza=LEFT(CONCAT(N'Pres. Modificado: ',@Justificacion),1000), FechaPoliza=@Fecha,
                        FechaModificacion=@Now, UsuarioModificacion=@IdUser
                    WHERE PKIdPoliza=@Poliza AND Activo=1;
                    SET @Mensaje=N'Adecuacion actualizada correctamente.';
                END
                ELSE IF @FkIdAccionAdecuacionMasterPres = 2
                BEGIN
                    IF NOT EXISTS (SELECT 1 FROM PRES.EgreAdecuacionDetalle WHERE FKIdEgreAdecuacion_PRES=@PKIdEgreAdecuacion AND Activo=1)
                        THROW 51020, 'Agrega al menos un movimiento antes de solicitar autorizacion.', 1;
                    EXEC PRES.sp_ValidarAdecuacionEgreso @PKIdEgreAdecuacion, @Mensaje OUTPUT;
                    IF @Mensaje IS NOT NULL THROW 51021, @Mensaje, 1;
                    UPDATE PRES.EgreAdecuacion SET FKIdAccionAdecuacionMaster_PRES=2, FKIdEstatusAdecuacion_PRES=1,
                        FechaSolicitud=@Now, FechaModificacion=@Now, UsuarioModificacion=@IdUser
                    WHERE PKIdEgreAdecuacion=@PKIdEgreAdecuacion;
                    SET @Mensaje=N'Solicitud enviada para autorizacion.';
                END
                ELSE
                    THROW 51022, 'Transicion de flujo no valida.', 1;
                SET @Id=@PKIdEgreAdecuacion;
            END
            ELSE IF @AccionActual = 2
            BEGIN
                IF @FkIdAccionAdecuacionMasterPres = 1 AND ISNULL(@Autorizado,0) = 0
                BEGIN
                    UPDATE PRES.EgreAdecuacion SET FKIdAccionAdecuacionMaster_PRES=1, FKIdEstatusAdecuacion_PRES=1,
                        FechaModificacion=@Now, UsuarioModificacion=@IdUser WHERE PKIdEgreAdecuacion=@PKIdEgreAdecuacion;
                    UPDATE CONTA.Poliza SET PermitirModificar=1, FechaModificacion=@Now, UsuarioModificacion=@IdUser
                    WHERE PKIdPoliza=@Poliza AND Activo=1;
                    SET @Mensaje=N'Solicitud cancelada; la adecuacion regreso a captura.';
                END
                ELSE IF @FkIdAccionAdecuacionMasterPres = 3 AND ISNULL(@Autorizado,0) = 1
                BEGIN
                    EXEC PRES.sp_ValidarAdecuacionEgreso @PKIdEgreAdecuacion, @Mensaje OUTPUT;
                    IF @Mensaje IS NOT NULL THROW 51023, @Mensaje, 1;
                    SELECT @Debe=SUM(ISNULL(ImporteDebe,0)), @Haber=SUM(ISNULL(ImporteHaber,0)) FROM CONTA.PolizaDetalle
                    WHERE FKIdPoliza_CONTA=@Poliza AND Activo=1;
                    IF ISNULL(@Debe,0) <> ISNULL(@Haber,0) THROW 51024, 'La poliza no esta balanceada.', 1;
                    UPDATE PRES.EgreAdecuacion SET FKIdAccionAdecuacionMaster_PRES=3, FKIdEstatusAdecuacion_PRES=3,
                        Autorizado=1, FechaAutorizacion=@Now, FechaModificacion=@Now, UsuarioModificacion=@IdUser
                    WHERE PKIdEgreAdecuacion=@PKIdEgreAdecuacion;
                    UPDATE CONTA.Poliza SET Autorizado=1, PermitirModificar=0, EstaBalanceado=1,
                        FechaAutorizacion=@Now, FechaModificacion=@Now, UsuarioModificacion=@IdUser
                    WHERE PKIdPoliza=@Poliza AND Activo=1;
                    SET @Mensaje=N'Adecuacion autorizada correctamente.';
                END
                ELSE IF @FkIdAccionAdecuacionMasterPres = 4 AND ISNULL(@Autorizado,0) = 0
                BEGIN
                    UPDATE PRES.EgreAdecuacion SET FKIdAccionAdecuacionMaster_PRES=4, FKIdEstatusAdecuacion_PRES=4,
                        Autorizado=0, FechaAutorizacion=@Now, FechaModificacion=@Now, UsuarioModificacion=@IdUser
                    WHERE PKIdEgreAdecuacion=@PKIdEgreAdecuacion;
                    UPDATE CONTA.Poliza SET PermitirModificar=0, FechaModificacion=@Now, UsuarioModificacion=@IdUser
                    WHERE PKIdPoliza=@Poliza AND Activo=1;
                    SET @Mensaje=N'Solicitud rechazada.';
                END
                ELSE
                    THROW 51025, 'Transicion de flujo no valida.', 1;
                SET @Id=@PKIdEgreAdecuacion;
            END
            ELSE
                THROW 51026, 'La adecuacion se encuentra cerrada y no admite cambios.', 1;
        END

        COMMIT TRANSACTION;
        SELECT JSON_QUERY(CONCAT('{"tipo":"OK","mensaje":"', STRING_ESCAPE(@Mensaje,'json'), '","liga":"id:',@Id,'"}')) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT JSON_QUERY(CONCAT('{"tipo":"ERROR","mensaje":"',STRING_ESCAPE(ERROR_MESSAGE(),'json'),'","liga":""}')) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE PRES.sp_ValidarAdecuacionEgreso
    @PKIdEgreAdecuacion INT,
    @Error NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Error = NULL;
    DECLARE @Tipo INT, @Aumento DECIMAL(20,4), @Reduccion DECIMAL(20,4);
    SELECT @Tipo=FKIdTipoAdecuacion_PRES FROM PRES.EgreAdecuacion WHERE PKIdEgreAdecuacion=@PKIdEgreAdecuacion AND Activo=1;
    SELECT @Aumento=SUM(CASE WHEN FKIdTipoMovimiento_PRES=1 THEN ABS(ISNULL(Total,0)) ELSE 0 END),
           @Reduccion=SUM(CASE WHEN FKIdTipoMovimiento_PRES=2 THEN ABS(ISNULL(Total,0)) ELSE 0 END)
    FROM PRES.EgreAdecuacionDetalle WHERE FKIdEgreAdecuacion_PRES=@PKIdEgreAdecuacion AND Activo=1;
    SET @Aumento=ISNULL(@Aumento,0); SET @Reduccion=ISNULL(@Reduccion,0);
    IF @Tipo=1 AND (@Aumento=0 OR @Reduccion=0 OR @Aumento<>@Reduccion) SET @Error=N'La adecuacion compensada requiere aumentos y reducciones por el mismo importe.';
    IF @Tipo=2 AND (@Aumento<>0 OR @Reduccion=0) SET @Error=N'La reduccion solo admite movimientos de reduccion.';
    IF @Tipo=3 AND (@Reduccion<>0 OR @Aumento=0) SET @Error=N'La ampliacion solo admite movimientos de aumento.';
END
GO

CREATE OR ALTER PROCEDURE PRES.sp_MantenimientoAdecuacionDisminucion
    @Action INT,
    @PKIdEgreAdecuacionDetalle INT = NULL,
    @FKIdEgresoAutorizado_PRES INT = NULL,
    @Justificacion NVARCHAR(250) = NULL,
    @Fecha DATETIME2(7) = NULL,
    @FKIdEgreAdecuacion_PRES INT = NULL,
    @FKIdTipoMovimiento_PRES INT = NULL,
    @Enero DECIMAL(18,2)=0, @Febrero DECIMAL(18,2)=0, @Marzo DECIMAL(18,2)=0, @Abril DECIMAL(18,2)=0,
    @Mayo DECIMAL(18,2)=0, @Junio DECIMAL(18,2)=0, @Julio DECIMAL(18,2)=0, @Agosto DECIMAL(18,2)=0,
    @Septiembre DECIMAL(18,2)=0, @Octubre DECIMAL(18,2)=0, @Noviembre DECIMAL(18,2)=0, @Diciembre DECIMAL(18,2)=0,
    @IdC INT = NULL,
    @IdUser INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Now DATETIME2(7)=SYSDATETIME(), @ParentEmpresa INT, @ParentAnio INT, @AnioClave INT, @TipoAdecuacion INT,
        @Accion INT, @Autorizado BIT, @Poliza INT, @Programa INT, @Partida INT, @CuentaModificado INT, @CuentaPorEjercer INT,
        @Importe DECIMAL(20,4), @Saldo DECIMAL(20,4), @Pendiente DECIMAL(20,4), @Signo INT, @Error NVARCHAR(4000), @Mensaje NVARCHAR(4000),
        @PresModificado NVARCHAR(250), @PresPorEjercer NVARCHAR(250);
    BEGIN TRY
        IF @Action NOT IN (1,2,3) THROW 51030, 'Accion no valida.', 1;
        SET @PKIdEgreAdecuacionDetalle=COALESCE(@PKIdEgreAdecuacionDetalle,@IdC);
        IF @Action=3
            SELECT @FKIdEgreAdecuacion_PRES=FKIdEgreAdecuacion_PRES FROM PRES.EgreAdecuacionDetalle WHERE PKIdEgreAdecuacionDetalle=@PKIdEgreAdecuacionDetalle AND Activo=1;
        IF @FKIdEgreAdecuacion_PRES IS NULL OR @FKIdEmpresa_SIS IS NULL THROW 51031, 'Adecuacion y empresa activa son obligatorias.', 1;

        BEGIN TRANSACTION;
        SELECT @ParentEmpresa=FKIdEmpresa_SIS, @ParentAnio=FKIdAnio_SIS, @TipoAdecuacion=FKIdTipoAdecuacion_PRES,
            @Accion=FKIdAccionAdecuacionMaster_PRES, @Autorizado=Autorizado, @Poliza=FKIdPoliza_CONTA
        FROM PRES.EgreAdecuacion WITH (UPDLOCK,HOLDLOCK)
        WHERE PKIdEgreAdecuacion=@FKIdEgreAdecuacion_PRES AND Activo=1;
        IF @ParentEmpresa IS NULL THROW 51032, 'Adecuacion no encontrada.', 1;
        IF @ParentEmpresa<>@FKIdEmpresa_SIS THROW 51033, 'La adecuacion no pertenece a la empresa activa.', 1;
        IF @Autorizado=1 OR @Accion<>1 THROW 51034, 'La adecuacion no esta en captura y sus movimientos no pueden modificarse.', 1;

        IF @Action IN (1,2)
        BEGIN
            SELECT @AnioClave=Clave FROM SIS.Anio WHERE PKIdAnio=@ParentAnio AND Activo=1;
            IF @Fecha IS NULL OR @AnioClave IS NULL OR YEAR(@Fecha)<>@AnioClave THROW 51035, 'La fecha debe pertenecer al ejercicio presupuestal.', 1;
            IF @FKIdTipoMovimiento_PRES NOT IN (1,2) OR
                (@TipoAdecuacion=1 AND @FKIdTipoMovimiento_PRES NOT IN (1,2)) OR
                (@TipoAdecuacion=2 AND @FKIdTipoMovimiento_PRES<>2) OR
                (@TipoAdecuacion=3 AND @FKIdTipoMovimiento_PRES<>1)
                THROW 51036, 'El tipo de movimiento no corresponde a la adecuacion.', 1;
            SET @Importe=ABS(ISNULL(@Enero,0))+ABS(ISNULL(@Febrero,0))+ABS(ISNULL(@Marzo,0))+ABS(ISNULL(@Abril,0))+ABS(ISNULL(@Mayo,0))+ABS(ISNULL(@Junio,0))+ABS(ISNULL(@Julio,0))+ABS(ISNULL(@Agosto,0))+ABS(ISNULL(@Septiembre,0))+ABS(ISNULL(@Octubre,0))+ABS(ISNULL(@Noviembre,0))+ABS(ISNULL(@Diciembre,0));
            IF @Importe<=0 THROW 51037, 'Captura un importe para al menos un mes.', 1;
            SET @PresModificado=LEFT(CONCAT(N'Presupuesto Modificado ',ISNULL(@Justificacion,N'')),250);
            SET @PresPorEjercer=LEFT(CONCAT(N'Presupuesto por Ejercer ',ISNULL(@Justificacion,N'')),250);
            IF (MONTH(@Fecha)>1 AND (ABS(@Enero)+ABS(@Febrero)+ABS(@Marzo)+ABS(@Abril)+ABS(@Mayo)+ABS(@Junio)+ABS(@Julio)+ABS(@Agosto)+ABS(@Septiembre)+ABS(@Octubre)+ABS(@Noviembre)) > 0)
            BEGIN
                DECLARE @Mes INT=MONTH(@Fecha), @ImportePrevio DECIMAL(20,4)=0;
                IF @Mes>1 SET @ImportePrevio+=ABS(@Enero); IF @Mes>2 SET @ImportePrevio+=ABS(@Febrero); IF @Mes>3 SET @ImportePrevio+=ABS(@Marzo); IF @Mes>4 SET @ImportePrevio+=ABS(@Abril); IF @Mes>5 SET @ImportePrevio+=ABS(@Mayo); IF @Mes>6 SET @ImportePrevio+=ABS(@Junio); IF @Mes>7 SET @ImportePrevio+=ABS(@Julio); IF @Mes>8 SET @ImportePrevio+=ABS(@Agosto); IF @Mes>9 SET @ImportePrevio+=ABS(@Septiembre); IF @Mes>10 SET @ImportePrevio+=ABS(@Octubre); IF @Mes>11 SET @ImportePrevio+=ABS(@Noviembre);
                IF @ImportePrevio>0 THROW 51038, 'No se permiten importes en meses anteriores a la fecha.', 1;
            END
            SELECT @Programa=FKIdPrograma_PRES,@Partida=FKIdPartida_CONTA FROM PRES.Vw_EgresoAutorizado
            WHERE PKIdEgresoAutorizado=@FKIdEgresoAutorizado_PRES AND FKIdEmpresa_SIS=@ParentEmpresa AND FKIdAnio_SIS=@ParentAnio;
            IF @Programa IS NULL THROW 51039, 'El egreso autorizado no pertenece al contexto activo.', 1;
            SELECT TOP(1) @CuentaModificado=FKIdCuentaContableModificado,@CuentaPorEjercer=FKIdCuentaContablePorEjercer
            FROM CONTA.MatrizConversion WHERE FKIdAnio_SIS=@ParentAnio AND FKIdPrograma_PRES=@Programa AND FKIdPartida_SIS=@Partida AND Activo=1;
            IF @CuentaModificado IS NULL OR @CuentaPorEjercer IS NULL THROW 51040, 'No existe una matriz de conversion activa para la partida.', 1;
            IF @FKIdTipoMovimiento_PRES=2
            BEGIN
                SELECT @Saldo=Total FROM PRES.Vw_EgresoDisponible WHERE PKIdEgresoAutorizado=@FKIdEgresoAutorizado_PRES AND FKIdEmpresa_SIS=@ParentEmpresa AND FKIdAnio_SIS=@ParentAnio;
                SELECT @Pendiente=SUM(Total) FROM PRES.EgreAdecuacionDetalle WHERE FKIdEgreAdecuacion_PRES=@FKIdEgreAdecuacion_PRES AND FKIdEgresoAutorizado_PRES=@FKIdEgresoAutorizado_PRES AND Activo=1 AND PKIdEgreAdecuacionDetalle<>ISNULL(@PKIdEgreAdecuacionDetalle,0);
                IF ISNULL(@Saldo,0)+ISNULL(@Pendiente,0)-@Importe<0 THROW 51041, 'La reduccion supera el presupuesto disponible.', 1;
            END
            SET @Signo=CASE WHEN @FKIdTipoMovimiento_PRES=1 THEN 1 ELSE -1 END;
        END

        IF @Action=1
        BEGIN
            INSERT INTO PRES.EgreAdecuacionDetalle(FKIdEgresoAutorizado_PRES,Justificacion,Fecha,FKIdEgreAdecuacion_PRES,FKIdTipoMovimiento_PRES,Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre,Activo,FechaCreacion,UsuarioCreacion)
            VALUES(@FKIdEgresoAutorizado_PRES,LEFT(@Justificacion,250),@Fecha,@FKIdEgreAdecuacion_PRES,@FKIdTipoMovimiento_PRES,ABS(@Enero)*@Signo,ABS(@Febrero)*@Signo,ABS(@Marzo)*@Signo,ABS(@Abril)*@Signo,ABS(@Mayo)*@Signo,ABS(@Junio)*@Signo,ABS(@Julio)*@Signo,ABS(@Agosto)*@Signo,ABS(@Septiembre)*@Signo,ABS(@Octubre)*@Signo,ABS(@Noviembre)*@Signo,ABS(@Diciembre)*@Signo,1,@Now,@IdUser);
            SET @Id=SCOPE_IDENTITY();
        END
        ELSE IF @Action=2
        BEGIN
            IF NOT EXISTS(SELECT 1 FROM PRES.EgreAdecuacionDetalle WHERE PKIdEgreAdecuacionDetalle=@PKIdEgreAdecuacionDetalle AND FKIdEgreAdecuacion_PRES=@FKIdEgreAdecuacion_PRES AND Activo=1) THROW 51042, 'Movimiento no encontrado.', 1;
            SET @Id=@PKIdEgreAdecuacionDetalle;
            UPDATE PRES.EgreAdecuacionDetalle SET FKIdEgresoAutorizado_PRES=@FKIdEgresoAutorizado_PRES,Justificacion=LEFT(@Justificacion,250),Fecha=@Fecha,FKIdTipoMovimiento_PRES=@FKIdTipoMovimiento_PRES,Enero=ABS(@Enero)*@Signo,Febrero=ABS(@Febrero)*@Signo,Marzo=ABS(@Marzo)*@Signo,Abril=ABS(@Abril)*@Signo,Mayo=ABS(@Mayo)*@Signo,Junio=ABS(@Junio)*@Signo,Julio=ABS(@Julio)*@Signo,Agosto=ABS(@Agosto)*@Signo,Septiembre=ABS(@Septiembre)*@Signo,Octubre=ABS(@Octubre)*@Signo,Noviembre=ABS(@Noviembre)*@Signo,Diciembre=ABS(@Diciembre)*@Signo,FechaModificacion=@Now,UsuarioModificacion=@IdUser WHERE PKIdEgreAdecuacionDetalle=@Id;
            UPDATE CONTA.PolizaDetalle SET Activo=0,FechaModificacion=@Now,UsuarioModificacion=@IdUser WHERE FKIdPoliza_CONTA=@Poliza AND FKIdReferencia=@Id AND Activo=1;
        END
        ELSE
        BEGIN
            SET @Id=@PKIdEgreAdecuacionDetalle;
            UPDATE PRES.EgreAdecuacionDetalle SET Activo=0,FechaModificacion=@Now,UsuarioModificacion=@IdUser WHERE PKIdEgreAdecuacionDetalle=@Id AND Activo=1;
            IF @@ROWCOUNT=0 THROW 51043, 'Movimiento no encontrado.', 1;
            UPDATE CONTA.PolizaDetalle SET Activo=0,FechaModificacion=@Now,UsuarioModificacion=@IdUser WHERE FKIdPoliza_CONTA=@Poliza AND FKIdReferencia=@Id AND Activo=1;
            EXEC CONTA.SP_UPDATE_PolizaBalanceada @PKIdPoliza=@Poliza,@IdUser=@IdUser,@Error=@Error OUTPUT;
            IF NULLIF(@Error,N'') IS NOT NULL THROW 51044, @Error, 1;
            COMMIT TRANSACTION;
            SELECT JSON_QUERY(CONCAT('{"tipo":"OK","mensaje":"Movimiento eliminado correctamente.","liga":"id:',@Id,'"}')) AS ResultJson;
            RETURN;
        END

        IF @FKIdTipoMovimiento_PRES=2
        BEGIN
            EXEC CONTA.SP_CREATE_DetallePolizaWOM @FKIdCuentaContable_CONTA=@CuentaModificado,@FKIdPoliza_CONTA=@Poliza,@Descripcion=@PresModificado,@ImporteDebe=@Importe,@ImporteHaber=0,@FKIdReferencia=@Id,@FKIdTipoDetallePoliza_SIS=1,@IdUser=@IdUser,@Error=@Error OUTPUT;
            IF NULLIF(@Error,N'') IS NULL EXEC CONTA.SP_CREATE_DetallePolizaWOM @FKIdCuentaContable_CONTA=@CuentaPorEjercer,@FKIdPoliza_CONTA=@Poliza,@Descripcion=@PresPorEjercer,@ImporteDebe=0,@ImporteHaber=@Importe,@FKIdReferencia=@Id,@FKIdTipoDetallePoliza_SIS=2,@IdUser=@IdUser,@Error=@Error OUTPUT;
        END
        ELSE
        BEGIN
            EXEC CONTA.SP_CREATE_DetallePolizaWOM @FKIdCuentaContable_CONTA=@CuentaPorEjercer,@FKIdPoliza_CONTA=@Poliza,@Descripcion=@PresPorEjercer,@ImporteDebe=0,@ImporteHaber=@Importe,@FKIdReferencia=@Id,@FKIdTipoDetallePoliza_SIS=2,@IdUser=@IdUser,@Error=@Error OUTPUT;
            IF NULLIF(@Error,N'') IS NULL EXEC CONTA.SP_CREATE_DetallePolizaWOM @FKIdCuentaContable_CONTA=@CuentaModificado,@FKIdPoliza_CONTA=@Poliza,@Descripcion=@PresModificado,@ImporteDebe=@Importe,@ImporteHaber=0,@FKIdReferencia=@Id,@FKIdTipoDetallePoliza_SIS=1,@IdUser=@IdUser,@Error=@Error OUTPUT;
        END
        IF NULLIF(@Error,N'') IS NOT NULL THROW 51045, @Error, 1;
        EXEC CONTA.SP_UPDATE_PolizaBalanceada @PKIdPoliza=@Poliza,@IdUser=@IdUser,@Error=@Error OUTPUT;
        IF NULLIF(@Error,N'') IS NOT NULL THROW 51046, @Error, 1;
        COMMIT TRANSACTION;
        SELECT JSON_QUERY(CONCAT('{"tipo":"OK","mensaje":"Movimiento guardado correctamente.","liga":"id:',@Id,'"}')) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        SELECT JSON_QUERY(CONCAT('{"tipo":"ERROR","mensaje":"',STRING_ESCAPE(ERROR_MESSAGE(),'json'),'","liga":""}')) AS ResultJson;
        RETURN -1;
    END CATCH
END
GO
