USE [GestionEmpresarial]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    Adecuaciones de ingresos.

    Objetos creados:
      - PRES.IngreAdecuacion
      - PRES.IngreAdecuacionDetalle
      - PRES.Vw_IngresoAdecuacion
      - PRES.Vw_IngresoAdecuacionDetalle
      - PRES.Vw_IngresoDisponible
      - PRES.sp_MantenimientoIngresoAdecuacion
      - PRES.sp_MantenimientoAdecuacionDisminucionIngreso

    Notas:
      1. TipoMovimiento 3 = Aumento de ingresos.
      2. TipoMovimiento 4 = Reduccion de ingresos.
      3. Vw_IngresoDisponible representa presupuesto autorizado mas adecuaciones
         autorizadas. No resta recaudacion, porque el PRES.CLCFactura actual
         corresponde al flujo CLC/Factura de contratos y no tiene relacion con
         PRES.IngresoAutorizado.
      4. Este script no migra datos de BD_PRESUPUESTO.
*/

/* ========================================================================== */
/* 0. PRERREQUISITOS                                                          */
/* ========================================================================== */

IF SCHEMA_ID(N'PRES') IS NULL
    THROW 51000, N'No existe el esquema PRES.', 1;
GO

IF TYPE_ID(N'dbo.dmoney') IS NULL
    THROW 51000, N'No existe el tipo dbo.dmoney.', 1;
GO

IF OBJECT_ID(N'PRES.IngresoAutorizado', N'U') IS NULL
    THROW 51000, N'Primero debe existir PRES.IngresoAutorizado.', 1;
GO

IF OBJECT_ID(N'PRES.Vw_IngresoAutorizado', N'V') IS NULL
    THROW 51000, N'Primero debe existir PRES.Vw_IngresoAutorizado.', 1;
GO

IF OBJECT_ID(N'PRES.TipoAdecuacion', N'U') IS NULL
 OR OBJECT_ID(N'PRES.EstatusAdecuacion', N'U') IS NULL
 OR OBJECT_ID(N'PRES.AccionAdecuacionMaster', N'U') IS NULL
 OR OBJECT_ID(N'PRES.TipoMovimiento', N'U') IS NULL
    THROW 51000, N'Faltan catalogos compartidos de adecuaciones. Aplique primero el bloque de catalogos de EgreAdecuacion.', 1;
GO

IF NOT EXISTS (
    SELECT 1
    FROM PRES.TipoMovimiento
    WHERE PKIdTipoMovimiento = 3 AND Activo = 1
)
    THROW 51000, N'Falta el TipoMovimiento 3 (Aumento Ingresos).', 1;
GO

IF NOT EXISTS (
    SELECT 1
    FROM PRES.TipoMovimiento
    WHERE PKIdTipoMovimiento = 4 AND Activo = 1
)
    THROW 51000, N'Falta el TipoMovimiento 4 (Reduccion Ingresos).', 1;
GO

IF OBJECT_ID(N'CONTA.MatrizIngreso', N'U') IS NULL
 OR OBJECT_ID(N'CONTA.Poliza', N'U') IS NULL
 OR OBJECT_ID(N'CONTA.PolizaDetalle', N'U') IS NULL
    THROW 51000, N'Faltan CONTA.MatrizIngreso, CONTA.Poliza o CONTA.PolizaDetalle.', 1;
GO

IF OBJECT_ID(N'CONTA.SP_CREATE_ClavePoliza', N'P') IS NULL
 OR OBJECT_ID(N'CONTA.SP_CREATE_DetallePolizaWOM', N'P') IS NULL
 OR OBJECT_ID(N'CONTA.SP_UPDATE_PolizaBalanceada', N'P') IS NULL
    THROW 51000, N'Faltan procedimientos contables requeridos para generar la poliza.', 1;
GO

IF OBJECT_ID(N'SIS.Anio', N'U') IS NULL
    THROW 51000, N'No existe SIS.Anio.', 1;
GO

/* ========================================================================== */
/* 1. TABLAS                                                                  */
/* ========================================================================== */

IF OBJECT_ID(N'PRES.IngreAdecuacion', N'U') IS NULL
BEGIN
    CREATE TABLE PRES.IngreAdecuacion (
        PKIdIngreAdecuacion                  int IDENTITY(1,1) NOT NULL,
        Clave                                nvarchar(50) NOT NULL,
        FKIdTipoAdecuacion_PRES              int NOT NULL,
        FKIdEstatusAdecuacion_PRES           int NOT NULL,
        Justificacion                        nvarchar(max) NULL,
        Fecha                                date NOT NULL,
        FKIdPoliza_CONTA                     int NULL,
        FKIdAnio_SIS                         int NOT NULL,
        Autorizado                           bit NOT NULL
            CONSTRAINT DF_IngreAdecuacion_Autorizado DEFAULT (0),
        FKIdAccionAdecuacionMaster_PRES      int NULL,
        FechaSolicitud                       datetime2(7) NULL,
        FechaAutorizacion                    datetime2(7) NULL,
        Activo                               bit NOT NULL
            CONSTRAINT DF_IngreAdecuacion_Activo DEFAULT (1),
        FechaCreacion                        datetime2(7) NULL
            CONSTRAINT DF_IngreAdecuacion_FechaCreacion DEFAULT (SYSDATETIME()),
        UsuarioCreacion                      int NOT NULL,
        FechaModificacion                    datetime2(7) NULL,
        UsuarioModificacion                  int NULL,
        CONSTRAINT PK_IngreAdecuacion
            PRIMARY KEY CLUSTERED (PKIdIngreAdecuacion)
    );
END
GO

IF OBJECT_ID(N'PRES.IngreAdecuacionDetalle', N'U') IS NULL
BEGIN
    CREATE TABLE PRES.IngreAdecuacionDetalle (
        PKIdIngreAdecuacionDetalle           int IDENTITY(1,1) NOT NULL,
        FKIdIngresoAutorizado_PRES           int NOT NULL,
        Justificacion                        nvarchar(max) NULL,
        Fecha                                date NOT NULL,
        FKIdIngreAdecuacion_PRES             int NOT NULL,
        FKIdTipoMovimiento_PRES              int NOT NULL,
        Enero                                dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Enero DEFAULT (0),
        Febrero                              dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Febrero DEFAULT (0),
        Marzo                                dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Marzo DEFAULT (0),
        Abril                                dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Abril DEFAULT (0),
        Mayo                                 dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Mayo DEFAULT (0),
        Junio                                dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Junio DEFAULT (0),
        Julio                                dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Julio DEFAULT (0),
        Agosto                               dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Agosto DEFAULT (0),
        Septiembre                           dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Septiembre DEFAULT (0),
        Octubre                              dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Octubre DEFAULT (0),
        Noviembre                            dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Noviembre DEFAULT (0),
        Diciembre                            dbo.dmoney NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Diciembre DEFAULT (0),
        Total AS (
            ISNULL(Enero, 0) + ISNULL(Febrero, 0) + ISNULL(Marzo, 0) +
            ISNULL(Abril, 0) + ISNULL(Mayo, 0) + ISNULL(Junio, 0) +
            ISNULL(Julio, 0) + ISNULL(Agosto, 0) + ISNULL(Septiembre, 0) +
            ISNULL(Octubre, 0) + ISNULL(Noviembre, 0) + ISNULL(Diciembre, 0)
        ) PERSISTED,
        Activo                               bit NOT NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_Activo DEFAULT (1),
        FechaCreacion                        datetime2(7) NULL
            CONSTRAINT DF_IngreAdecuacionDetalle_FechaCreacion DEFAULT (SYSDATETIME()),
        UsuarioCreacion                      int NOT NULL,
        FechaModificacion                    datetime2(7) NULL,
        UsuarioModificacion                  int NULL,
        CONSTRAINT PK_IngreAdecuacionDetalle
            PRIMARY KEY CLUSTERED (PKIdIngreAdecuacionDetalle),
        CONSTRAINT CK_IngreAdecuacionDetalle_TipoMovimiento
            CHECK (FKIdTipoMovimiento_PRES IN (3, 4)),
        CONSTRAINT CK_IngreAdecuacionDetalle_Signo
            CHECK (
                (FKIdTipoMovimiento_PRES = 3
                 AND Enero >= 0 AND Febrero >= 0 AND Marzo >= 0 AND Abril >= 0
                 AND Mayo >= 0 AND Junio >= 0 AND Julio >= 0 AND Agosto >= 0
                 AND Septiembre >= 0 AND Octubre >= 0 AND Noviembre >= 0 AND Diciembre >= 0)
                OR
                (FKIdTipoMovimiento_PRES = 4
                 AND Enero <= 0 AND Febrero <= 0 AND Marzo <= 0 AND Abril <= 0
                 AND Mayo <= 0 AND Junio <= 0 AND Julio <= 0 AND Agosto <= 0
                 AND Septiembre <= 0 AND Octubre <= 0 AND Noviembre <= 0 AND Diciembre <= 0)
            )
    );
END
GO

/* ========================================================================== */
/* 2. LLAVES FORANEAS E INDICES                                               */
/* ========================================================================== */

IF OBJECT_ID(N'PRES.FK_IngreAdecuacion_TipoAdecuacion', N'F') IS NULL
    ALTER TABLE PRES.IngreAdecuacion WITH CHECK
    ADD CONSTRAINT FK_IngreAdecuacion_TipoAdecuacion
        FOREIGN KEY (FKIdTipoAdecuacion_PRES)
        REFERENCES PRES.TipoAdecuacion (PKIdTipoAdecuacion);
GO

IF OBJECT_ID(N'PRES.FK_IngreAdecuacion_EstatusAdecuacion', N'F') IS NULL
    ALTER TABLE PRES.IngreAdecuacion WITH CHECK
    ADD CONSTRAINT FK_IngreAdecuacion_EstatusAdecuacion
        FOREIGN KEY (FKIdEstatusAdecuacion_PRES)
        REFERENCES PRES.EstatusAdecuacion (PKIdEstatusAdecuacion);
GO

IF OBJECT_ID(N'PRES.FK_IngreAdecuacion_AccionAdecuacionMaster', N'F') IS NULL
    ALTER TABLE PRES.IngreAdecuacion WITH CHECK
    ADD CONSTRAINT FK_IngreAdecuacion_AccionAdecuacionMaster
        FOREIGN KEY (FKIdAccionAdecuacionMaster_PRES)
        REFERENCES PRES.AccionAdecuacionMaster (PKIdAccionAdecuacionMaster);
GO

IF OBJECT_ID(N'PRES.FK_IngreAdecuacion_Poliza', N'F') IS NULL
    ALTER TABLE PRES.IngreAdecuacion WITH CHECK
    ADD CONSTRAINT FK_IngreAdecuacion_Poliza
        FOREIGN KEY (FKIdPoliza_CONTA)
        REFERENCES CONTA.Poliza (PKIdPoliza);
GO

IF OBJECT_ID(N'PRES.FK_IngreAdecuacion_Anio', N'F') IS NULL
    ALTER TABLE PRES.IngreAdecuacion WITH CHECK
    ADD CONSTRAINT FK_IngreAdecuacion_Anio
        FOREIGN KEY (FKIdAnio_SIS)
        REFERENCES SIS.Anio (PKIdAnio);
GO

IF OBJECT_ID(N'PRES.FK_IngreAdecuacionDetalle_IngreAdecuacion', N'F') IS NULL
    ALTER TABLE PRES.IngreAdecuacionDetalle WITH CHECK
    ADD CONSTRAINT FK_IngreAdecuacionDetalle_IngreAdecuacion
        FOREIGN KEY (FKIdIngreAdecuacion_PRES)
        REFERENCES PRES.IngreAdecuacion (PKIdIngreAdecuacion);
GO

IF OBJECT_ID(N'PRES.FK_IngreAdecuacionDetalle_IngresoAutorizado', N'F') IS NULL
    ALTER TABLE PRES.IngreAdecuacionDetalle WITH CHECK
    ADD CONSTRAINT FK_IngreAdecuacionDetalle_IngresoAutorizado
        FOREIGN KEY (FKIdIngresoAutorizado_PRES)
        REFERENCES PRES.IngresoAutorizado (PKIdIngresoAutorizado);
GO

IF OBJECT_ID(N'PRES.FK_IngreAdecuacionDetalle_TipoMovimiento', N'F') IS NULL
    ALTER TABLE PRES.IngreAdecuacionDetalle WITH CHECK
    ADD CONSTRAINT FK_IngreAdecuacionDetalle_TipoMovimiento
        FOREIGN KEY (FKIdTipoMovimiento_PRES)
        REFERENCES PRES.TipoMovimiento (PKIdTipoMovimiento);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'PRES.IngreAdecuacion')
      AND name = N'UX_IngreAdecuacion_Clave_Activo'
)
    CREATE UNIQUE INDEX UX_IngreAdecuacion_Clave_Activo
    ON PRES.IngreAdecuacion (Clave)
    WHERE Activo = 1;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'PRES.IngreAdecuacion')
      AND name = N'IX_IngreAdecuacion_Activo_Autorizado'
)
    CREATE INDEX IX_IngreAdecuacion_Activo_Autorizado
    ON PRES.IngreAdecuacion (Activo, Autorizado, FKIdAnio_SIS);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'PRES.IngreAdecuacionDetalle')
      AND name = N'UX_IngreAdecuacionDetalle_Recurso_Movimiento_Activo'
)
    CREATE UNIQUE INDEX UX_IngreAdecuacionDetalle_Recurso_Movimiento_Activo
    ON PRES.IngreAdecuacionDetalle (
        FKIdIngreAdecuacion_PRES,
        FKIdIngresoAutorizado_PRES,
        FKIdTipoMovimiento_PRES
    )
    WHERE Activo = 1;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'PRES.IngreAdecuacionDetalle')
      AND name = N'IX_IngreAdecuacionDetalle_Disponible'
)
    CREATE INDEX IX_IngreAdecuacionDetalle_Disponible
    ON PRES.IngreAdecuacionDetalle (
        Activo,
        FKIdIngresoAutorizado_PRES,
        FKIdIngreAdecuacion_PRES
    )
    INCLUDE (
        Enero, Febrero, Marzo, Abril, Mayo, Junio,
        Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre
    );
GO

/* ========================================================================== */
/* 3. VISTAS                                                                  */
/* ========================================================================== */

CREATE OR ALTER VIEW PRES.Vw_IngresoAdecuacion
AS
WITH Totales AS (
    SELECT
        det.FKIdIngreAdecuacion_PRES,
        SUM(CASE WHEN det.FKIdTipoMovimiento_PRES = 3 THEN det.Total ELSE 0 END) AS TotalAumento,
        SUM(CASE WHEN det.FKIdTipoMovimiento_PRES = 4 THEN ABS(det.Total) ELSE 0 END) AS TotalReduccion,
        COUNT_BIG(*) AS CantidadDetalles
    FROM PRES.IngreAdecuacionDetalle det
    WHERE det.Activo = 1
    GROUP BY det.FKIdIngreAdecuacion_PRES
)
SELECT
    ia.PKIdIngreAdecuacion,
    ia.Clave,
    ia.FKIdTipoAdecuacion_PRES,
    ta.Descripcion AS TipoAdecuacionDescripcion,
    ia.FKIdEstatusAdecuacion_PRES,
    est.Descripcion AS EstatusAdecuacionDescripcion,
    est.Color AS EstatusAdecuacionColor,
    ia.Justificacion,
    ia.Fecha,
    ia.FKIdPoliza_CONTA,
    pol.ClavePoliza,
    ia.FKIdAnio_SIS,
    anio.Clave AS AnioClave,
    ia.Autorizado,
    ia.FKIdAccionAdecuacionMaster_PRES,
    acc.Accion AS AccionAdecuacion,
    acc.Comentario AS AccionComentario,
    ia.FechaSolicitud,
    ia.FechaAutorizacion,
    ISNULL(t.TotalAumento, 0) AS TotalAumento,
    ISNULL(t.TotalReduccion, 0) AS TotalReduccion,
    ISNULL(t.TotalAumento, 0) - ISNULL(t.TotalReduccion, 0) AS Diferencia,
    CONVERT(bit, CASE WHEN ISNULL(t.CantidadDetalles, 0) > 0 THEN 1 ELSE 0 END) AS HasChild,
    CASE
        WHEN ia.Autorizado = 1 THEN N'#DFF6DD'
        ELSE COALESCE(est.Color, N'#FFD6D6')
    END AS Color,
    ia.Activo,
    ia.FechaCreacion,
    ia.UsuarioCreacion,
    ia.FechaModificacion,
    ia.UsuarioModificacion,
    CONCAT(ia.Clave, N' - ', ISNULL(ia.Justificacion, N'')) AS ClaveNombre
FROM PRES.IngreAdecuacion ia
LEFT JOIN PRES.TipoAdecuacion ta
    ON ia.FKIdTipoAdecuacion_PRES = ta.PKIdTipoAdecuacion
   AND ta.Activo = 1
LEFT JOIN PRES.EstatusAdecuacion est
    ON ia.FKIdEstatusAdecuacion_PRES = est.PKIdEstatusAdecuacion
   AND est.Activo = 1
LEFT JOIN CONTA.Poliza pol
    ON ia.FKIdPoliza_CONTA = pol.PKIdPoliza
   AND pol.Activo = 1
LEFT JOIN SIS.Anio anio
    ON ia.FKIdAnio_SIS = anio.PKIdAnio
   AND anio.Activo = 1
LEFT JOIN PRES.AccionAdecuacionMaster acc
    ON ia.FKIdAccionAdecuacionMaster_PRES = acc.PKIdAccionAdecuacionMaster
   AND acc.Activo = 1
LEFT JOIN Totales t
    ON ia.PKIdIngreAdecuacion = t.FKIdIngreAdecuacion_PRES
WHERE ia.Activo = 1;
GO

CREATE OR ALTER VIEW PRES.Vw_IngresoAdecuacionDetalle
AS
SELECT
    det.PKIdIngreAdecuacionDetalle,
    det.FKIdIngreAdecuacion_PRES,
    enc.Clave AS IngreAdecuacionClave,
    enc.FKIdAnio_SIS,
    enc.Autorizado,
    det.FKIdIngresoAutorizado_PRES,
    ing.Descripcion AS IngresoAutorizadoDescripcion,
    ing.FKIdPrograma_PRES,
    ing.ProgramaClave,
    ing.ProgramaDescripcion,
    ing.FKIdOrigen_PRES,
    ing.OrigenClave,
    ing.OrigenDescripcion,
    ing.PosicionPresupuestal,
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
    det.UsuarioModificacion,
    CAST(N'' AS nvarchar(4000)) AS Message
FROM PRES.IngreAdecuacionDetalle det
INNER JOIN PRES.IngreAdecuacion enc
    ON det.FKIdIngreAdecuacion_PRES = enc.PKIdIngreAdecuacion
   AND enc.Activo = 1
INNER JOIN PRES.Vw_IngresoAutorizado ing
    ON det.FKIdIngresoAutorizado_PRES = ing.PKIdIngresoAutorizado
   AND ing.Activo = 1
LEFT JOIN PRES.TipoMovimiento tm
    ON det.FKIdTipoMovimiento_PRES = tm.PKIdTipoMovimiento
   AND tm.Activo = 1
WHERE det.Activo = 1;
GO

CREATE OR ALTER VIEW PRES.Vw_IngresoDisponible
AS
WITH AjustesAutorizados AS (
    SELECT
        det.FKIdIngresoAutorizado_PRES,
        SUM(det.Enero) AS Enero,
        SUM(det.Febrero) AS Febrero,
        SUM(det.Marzo) AS Marzo,
        SUM(det.Abril) AS Abril,
        SUM(det.Mayo) AS Mayo,
        SUM(det.Junio) AS Junio,
        SUM(det.Julio) AS Julio,
        SUM(det.Agosto) AS Agosto,
        SUM(det.Septiembre) AS Septiembre,
        SUM(det.Octubre) AS Octubre,
        SUM(det.Noviembre) AS Noviembre,
        SUM(det.Diciembre) AS Diciembre,
        SUM(det.Total) AS Total
    FROM PRES.IngreAdecuacionDetalle det
    INNER JOIN PRES.IngreAdecuacion enc
        ON det.FKIdIngreAdecuacion_PRES = enc.PKIdIngreAdecuacion
       AND enc.Activo = 1
       AND enc.Autorizado = 1
    WHERE det.Activo = 1
    GROUP BY det.FKIdIngresoAutorizado_PRES
)
SELECT
    ing.PKIdIngresoAutorizado,
    ing.FKIdPrograma_PRES,
    ing.FKIdAnio_SIS,
    ing.ProgramaClave,
    ing.ProgramaDescripcion,
    ing.ProgramaClaveNombre,
    ing.AreaFuncional,
    ing.FKIdOrigen_PRES,
    ing.OrigenClave,
    ing.OrigenDescripcion,
    ing.OrigenClaveNombre,
    ing.Origen,
    ing.FKIdFuenteFinanciamiento_PRES,
    ing.FuenteFinanciamientoClave,
    ing.FuenteFinanciamientoDescripcion,
    ing.FuenteFinanciamientoClaveNombre,
    ing.FKIdTipoGasto_PRES,
    ing.TipoGastoClave,
    ing.TipoGastoDescripcion,
    ing.TipoGastoClaveNombre,
    ing.FKIdDigitoIdentificador_PRES,
    ing.DigitoIdentificadorClave,
    ing.DigitoIdentificadorDescripcion,
    ing.DigitoIdentificadorClaveNombre,
    ing.FKIdDestinoGasto_PRES,
    ing.DestinoGastoClave,
    ing.DestinoGastoDescripcion,
    ing.DestinoGastoClaveNombre,
    ing.PosicionPresupuestal,
    ing.Descripcion,
    ing.Fecha,
    ing.FKIdPoliza_CONTA,
    ISNULL(ing.Enero, 0) + ISNULL(aj.Enero, 0) AS Enero,
    ISNULL(ing.Febrero, 0) + ISNULL(aj.Febrero, 0) AS Febrero,
    ISNULL(ing.Marzo, 0) + ISNULL(aj.Marzo, 0) AS Marzo,
    ISNULL(ing.Abril, 0) + ISNULL(aj.Abril, 0) AS Abril,
    ISNULL(ing.Mayo, 0) + ISNULL(aj.Mayo, 0) AS Mayo,
    ISNULL(ing.Junio, 0) + ISNULL(aj.Junio, 0) AS Junio,
    ISNULL(ing.Julio, 0) + ISNULL(aj.Julio, 0) AS Julio,
    ISNULL(ing.Agosto, 0) + ISNULL(aj.Agosto, 0) AS Agosto,
    ISNULL(ing.Septiembre, 0) + ISNULL(aj.Septiembre, 0) AS Septiembre,
    ISNULL(ing.Octubre, 0) + ISNULL(aj.Octubre, 0) AS Octubre,
    ISNULL(ing.Noviembre, 0) + ISNULL(aj.Noviembre, 0) AS Noviembre,
    ISNULL(ing.Diciembre, 0) + ISNULL(aj.Diciembre, 0) AS Diciembre,
    ISNULL(ing.Total, 0) + ISNULL(aj.Total, 0) AS Total,
    ing.FechaAutorizacion,
    ing.UsuarioAutorizacion,
    ing.Activo,
    CAST(N'' AS nvarchar(4000)) AS Message,
    CAST(
        CONCAT(
            ing.PosicionPresupuestal,
            N' ', ISNULL(ing.Descripcion, N''),
            N' $',
            CONVERT(varchar(32), CONVERT(money, ISNULL(ing.Total, 0) + ISNULL(aj.Total, 0)), 1)
        ) AS nvarchar(4000)
    ) AS DescripcionRequisicion
FROM PRES.Vw_IngresoAutorizado ing
LEFT JOIN AjustesAutorizados aj
    ON ing.PKIdIngresoAutorizado = aj.FKIdIngresoAutorizado_PRES
WHERE ing.Activo = 1
  AND ing.FechaAutorizacion IS NOT NULL;
GO

/* ========================================================================== */
/* 4. MANTENIMIENTO DEL ENCABEZADO                                            */
/* ========================================================================== */

CREATE OR ALTER PROCEDURE PRES.sp_MantenimientoIngresoAdecuacion
    @Action int,
    @PKIdIngreAdecuacion int = NULL,
    @Autorizado bit = 0,
    @IdUser int = NULL,
    @idMenu int = NULL,
    @AlertMessage nvarchar(124) = NULL,
    @Id int = NULL OUTPUT,
    @FkIdPolizaConta int = NULL,
    @FkIdAnioSis int = NULL,
    @FkIdTipoAdecuacionPres int = NULL,
    @FkIdEstatusAdecuacionPres int = NULL,
    @Justificacion nvarchar(max) = NULL,
    @Fecha datetime2(7) = NULL,
    @FkIdAccionAdecuacionMasterPres int = NULL,
    @FechaSolicitud datetime2(7) = NULL,
    @FechaAutorizacion datetime2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @today datetime2(7) = SYSDATETIME(),
        @message nvarchar(max) = N'',
        @ErrorPoliza nvarchar(max) = N'',
        @FKIdPoliza_CONTA int = NULLIF(@FkIdPolizaConta, 0),
        @FKIdAnioActual int,
        @AnioClave int,
        @FKIdMes_SIS int,
        @FKIdTipoPoliza_SIS int = 4,
        @ClavePoliza nvarchar(20),
        @ClavePolizaActual nvarchar(20),
        @NombrePoliza nvarchar(2000),
        @Clave nvarchar(50),
        @Consecutivo int,
        @AutorizadoActual bit,
        @PolizaBalanceada bit,
        @PolizaAnterior int;

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3)
            THROW 51000, N'Accion no valida. Use 1=Insert, 2=Update o 3=Delete.', 1;

        IF @IdUser IS NULL
            THROW 51000, N'Debe indicar IdUser.', 1;

        IF @Action = 1 AND ISNULL(@Autorizado, 0) = 1
            THROW 51000, N'La adecuacion debe crearse sin autorizar; primero registre sus detalles.', 1;

        IF @Action IN (1, 2)
        BEGIN
            IF @FkIdAnioSis IS NULL
             OR @FkIdTipoAdecuacionPres IS NULL
             OR @FkIdEstatusAdecuacionPres IS NULL
             OR @Fecha IS NULL
                THROW 51000, N'Faltan Anio, Tipo de Adecuacion, Estatus o Fecha.', 1;

            SELECT @AnioClave = a.Clave
            FROM SIS.Anio a
            WHERE a.PKIdAnio = @FkIdAnioSis
              AND a.Activo = 1;

            IF @AnioClave IS NULL
                THROW 51000, N'El anio indicado no existe o esta inactivo.', 1;

            IF NOT EXISTS (
                SELECT 1 FROM PRES.TipoAdecuacion
                WHERE PKIdTipoAdecuacion = @FkIdTipoAdecuacionPres AND Activo = 1
            )
                THROW 51000, N'El tipo de adecuacion no existe o esta inactivo.', 1;

            IF NOT EXISTS (
                SELECT 1 FROM PRES.EstatusAdecuacion
                WHERE PKIdEstatusAdecuacion = @FkIdEstatusAdecuacionPres AND Activo = 1
            )
                THROW 51000, N'El estatus de adecuacion no existe o esta inactivo.', 1;

            IF @FkIdAccionAdecuacionMasterPres IS NOT NULL
               AND NOT EXISTS (
                    SELECT 1 FROM PRES.AccionAdecuacionMaster
                    WHERE PKIdAccionAdecuacionMaster = @FkIdAccionAdecuacionMasterPres
                      AND Activo = 1
               )
                THROW 51000, N'La accion de adecuacion no existe o esta inactiva.', 1;

            SET @FKIdMes_SIS = MONTH(@Fecha);
            SET @NombrePoliza = LEFT(
                CONCAT(N'Pres. Modificado Ingresos: ', @AnioClave, N' ', ISNULL(@Justificacion, N'')),
                2000
            );
        END

        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            IF @FKIdPoliza_CONTA IS NOT NULL
            BEGIN
                SELECT @ClavePolizaActual = p.ClavePoliza
                FROM CONTA.Poliza p
                WHERE p.PKIdPoliza = @FKIdPoliza_CONTA
                  AND p.Activo = 1
                  AND p.FKIdAnio_SIS = @FkIdAnioSis;

                IF @ClavePolizaActual IS NULL
                    THROW 51000, N'La poliza indicada no existe, esta inactiva o pertenece a otro anio.', 1;

                IF @ClavePolizaActual = N'NUEVA'
                    SET @FKIdPoliza_CONTA = NULL;
            END

            IF @FKIdPoliza_CONTA IS NULL
            BEGIN
                EXEC CONTA.SP_CREATE_ClavePoliza
                    @FK_IdAnio__SIS = @FkIdAnioSis,
                    @FK_IdMesConta__SIS = @FKIdMes_SIS,
                    @FK_IdTipoPolizaConta__SIS = @FKIdTipoPoliza_SIS,
                    @CT_ModifiedBy = @IdUser,
                    @ClavePoliza = @ClavePoliza OUTPUT,
                    @Error = @ErrorPoliza OUTPUT;

                IF ISNULL(@ErrorPoliza, N'') <> N'' OR ISNULL(@ClavePoliza, N'') = N''
                    THROW 51000, N'No se pudo generar la clave de poliza.', 1;

                INSERT INTO CONTA.Poliza (
                    FKIdAnio_SIS,
                    FKIdMes_SIS,
                    FKIdTipoPoliza_SIS,
                    ClavePoliza,
                    NombrePoliza,
                    FechaPoliza,
                    EstaBalanceado,
                    PermitirModificar,
                    FKIdAccionAutorizar_SIS,
                    Autorizado,
                    FechaSolicitud,
                    FechaAutorizacion,
                    Activo,
                    FechaCreacion,
                    UsuarioCreacion
                )
                VALUES (
                    @FkIdAnioSis,
                    @FKIdMes_SIS,
                    @FKIdTipoPoliza_SIS,
                    @ClavePoliza,
                    @NombrePoliza,
                    @Fecha,
                    0,
                    1,
                    NULL,
                    0,
                    COALESCE(@FechaSolicitud, @today),
                    NULL,
                    1,
                    @today,
                    @IdUser
                );

                SET @FKIdPoliza_CONTA = CONVERT(int, SCOPE_IDENTITY());
            END

            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(int, RIGHT(Clave, 4))), 0) + 1
            FROM PRES.IngreAdecuacion WITH (UPDLOCK, HOLDLOCK)
            WHERE FKIdAnio_SIS = @FkIdAnioSis;

            SET @Clave = CONCAT(
                N'ADQ-ING-',
                @AnioClave,
                N'-',
                RIGHT(N'0000' + CONVERT(nvarchar(10), @Consecutivo), 4)
            );

            INSERT INTO PRES.IngreAdecuacion (
                Clave,
                FKIdTipoAdecuacion_PRES,
                FKIdEstatusAdecuacion_PRES,
                Justificacion,
                Fecha,
                FKIdPoliza_CONTA,
                FKIdAnio_SIS,
                Autorizado,
                FKIdAccionAdecuacionMaster_PRES,
                FechaSolicitud,
                FechaAutorizacion,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            VALUES (
                @Clave,
                @FkIdTipoAdecuacionPres,
                @FkIdEstatusAdecuacionPres,
                @Justificacion,
                CONVERT(date, @Fecha),
                @FKIdPoliza_CONTA,
                @FkIdAnioSis,
                ISNULL(@Autorizado, 0),
                @FkIdAccionAdecuacionMasterPres,
                @FechaSolicitud,
                @FechaAutorizacion,
                1,
                @today,
                @IdUser
            );

            SET @Id = CONVERT(int, SCOPE_IDENTITY());
            SET @message = N'Se registro correctamente la adecuacion de ingresos.';
        END
        ELSE IF @Action = 2
        BEGIN
            SELECT
                @FKIdAnioActual = ia.FKIdAnio_SIS,
                @PolizaAnterior = ia.FKIdPoliza_CONTA,
                @AutorizadoActual = ia.Autorizado
            FROM PRES.IngreAdecuacion ia WITH (UPDLOCK, HOLDLOCK)
            WHERE ia.PKIdIngreAdecuacion = @PKIdIngreAdecuacion
              AND ia.Activo = 1;

            IF @FKIdAnioActual IS NULL
                THROW 51000, N'La adecuacion de ingresos no existe o esta inactiva.', 1;

            IF @AutorizadoActual = 1
                THROW 51000, N'No se puede modificar una adecuacion ya autorizada.', 1;

            IF @FKIdAnioActual <> @FkIdAnioSis
                THROW 51000, N'No se permite cambiar el anio de una adecuacion existente.', 1;

            IF @FkIdPolizaConta IS NOT NULL
               AND NULLIF(@FkIdPolizaConta, 0) <> @PolizaAnterior
                THROW 51000, N'No se permite cambiar la poliza de una adecuacion existente.', 1;

            SET @FKIdPoliza_CONTA = @PolizaAnterior;

            IF ISNULL(@Autorizado, 0) = 1
            BEGIN
                IF NOT EXISTS (
                    SELECT 1
                    FROM PRES.IngreAdecuacionDetalle
                    WHERE FKIdIngreAdecuacion_PRES = @PKIdIngreAdecuacion
                      AND Activo = 1
                )
                    THROW 51000, N'No se puede autorizar una adecuacion sin detalles.', 1;

                IF EXISTS (
                    SELECT 1
                    FROM PRES.IngreAdecuacionDetalle det
                    INNER JOIN PRES.IngresoAutorizado ing WITH (UPDLOCK, HOLDLOCK)
                        ON det.FKIdIngresoAutorizado_PRES = ing.PKIdIngresoAutorizado
                       AND ing.Activo = 1
                    OUTER APPLY (
                        SELECT
                            SUM(d.Enero) AS Enero,
                            SUM(d.Febrero) AS Febrero,
                            SUM(d.Marzo) AS Marzo,
                            SUM(d.Abril) AS Abril,
                            SUM(d.Mayo) AS Mayo,
                            SUM(d.Junio) AS Junio,
                            SUM(d.Julio) AS Julio,
                            SUM(d.Agosto) AS Agosto,
                            SUM(d.Septiembre) AS Septiembre,
                            SUM(d.Octubre) AS Octubre,
                            SUM(d.Noviembre) AS Noviembre,
                            SUM(d.Diciembre) AS Diciembre
                        FROM PRES.IngreAdecuacionDetalle d
                        INNER JOIN PRES.IngreAdecuacion e
                            ON d.FKIdIngreAdecuacion_PRES = e.PKIdIngreAdecuacion
                           AND e.Activo = 1
                           AND e.Autorizado = 1
                        WHERE d.FKIdIngresoAutorizado_PRES = det.FKIdIngresoAutorizado_PRES
                          AND d.Activo = 1
                    ) aj
                    WHERE det.FKIdIngreAdecuacion_PRES = @PKIdIngreAdecuacion
                      AND det.FKIdTipoMovimiento_PRES = 4
                      AND det.Activo = 1
                      AND (
                           ABS(det.Enero) > ISNULL(ing.Enero, 0) + ISNULL(aj.Enero, 0)
                        OR ABS(det.Febrero) > ISNULL(ing.Febrero, 0) + ISNULL(aj.Febrero, 0)
                        OR ABS(det.Marzo) > ISNULL(ing.Marzo, 0) + ISNULL(aj.Marzo, 0)
                        OR ABS(det.Abril) > ISNULL(ing.Abril, 0) + ISNULL(aj.Abril, 0)
                        OR ABS(det.Mayo) > ISNULL(ing.Mayo, 0) + ISNULL(aj.Mayo, 0)
                        OR ABS(det.Junio) > ISNULL(ing.Junio, 0) + ISNULL(aj.Junio, 0)
                        OR ABS(det.Julio) > ISNULL(ing.Julio, 0) + ISNULL(aj.Julio, 0)
                        OR ABS(det.Agosto) > ISNULL(ing.Agosto, 0) + ISNULL(aj.Agosto, 0)
                        OR ABS(det.Septiembre) > ISNULL(ing.Septiembre, 0) + ISNULL(aj.Septiembre, 0)
                        OR ABS(det.Octubre) > ISNULL(ing.Octubre, 0) + ISNULL(aj.Octubre, 0)
                        OR ABS(det.Noviembre) > ISNULL(ing.Noviembre, 0) + ISNULL(aj.Noviembre, 0)
                        OR ABS(det.Diciembre) > ISNULL(ing.Diciembre, 0) + ISNULL(aj.Diciembre, 0)
                      )
                )
                    THROW 51000, N'No se puede autorizar: una reduccion supera el ingreso disponible actual.', 1;

                SET @ErrorPoliza = N'';
                EXEC CONTA.SP_UPDATE_PolizaBalanceada
                    @PKIdPoliza = @FKIdPoliza_CONTA,
                    @IdUser = @IdUser,
                    @Error = @ErrorPoliza OUTPUT;

                IF ISNULL(@ErrorPoliza, N'') <> N''
                    THROW 51000, N'No se pudo validar el balance de la poliza.', 1;

                SELECT @PolizaBalanceada = EstaBalanceado
                FROM CONTA.Poliza
                WHERE PKIdPoliza = @FKIdPoliza_CONTA
                  AND Activo = 1;

                IF ISNULL(@PolizaBalanceada, 0) = 0
                    THROW 51000, N'No se puede autorizar: la poliza no esta balanceada.', 1;

                SET @FechaAutorizacion = COALESCE(@FechaAutorizacion, @today);
            END

            UPDATE PRES.IngreAdecuacion
            SET
                FKIdTipoAdecuacion_PRES = @FkIdTipoAdecuacionPres,
                FKIdEstatusAdecuacion_PRES = @FkIdEstatusAdecuacionPres,
                Justificacion = @Justificacion,
                Fecha = CONVERT(date, @Fecha),
                Autorizado = ISNULL(@Autorizado, 0),
                FKIdAccionAdecuacionMaster_PRES = @FkIdAccionAdecuacionMasterPres,
                FechaSolicitud = @FechaSolicitud,
                FechaAutorizacion = CASE WHEN ISNULL(@Autorizado, 0) = 1 THEN @FechaAutorizacion ELSE NULL END,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdIngreAdecuacion = @PKIdIngreAdecuacion;

            UPDATE CONTA.Poliza
            SET
                FKIdMes_SIS = @FKIdMes_SIS,
                NombrePoliza = @NombrePoliza,
                FechaPoliza = @Fecha,
                Autorizado = ISNULL(@Autorizado, 0),
                FechaSolicitud = COALESCE(@FechaSolicitud, FechaSolicitud),
                FechaAutorizacion = CASE WHEN ISNULL(@Autorizado, 0) = 1 THEN @FechaAutorizacion ELSE NULL END,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @FKIdPoliza_CONTA
              AND Activo = 1;

            SET @Id = @PKIdIngreAdecuacion;
            SET @message = N'Se actualizo correctamente la adecuacion de ingresos.';
        END
        ELSE
        BEGIN
            SELECT
                @FKIdAnioActual = ia.FKIdAnio_SIS,
                @FKIdPoliza_CONTA = ia.FKIdPoliza_CONTA,
                @AutorizadoActual = ia.Autorizado
            FROM PRES.IngreAdecuacion ia WITH (UPDLOCK, HOLDLOCK)
            WHERE ia.PKIdIngreAdecuacion = @PKIdIngreAdecuacion
              AND ia.Activo = 1;

            IF @FKIdAnioActual IS NULL
                THROW 51000, N'La adecuacion de ingresos no existe o esta inactiva.', 1;

            IF @AutorizadoActual = 1
                THROW 51000, N'No se puede eliminar una adecuacion autorizada.', 1;

            UPDATE pd
            SET
                pd.Activo = 0,
                pd.FechaModificacion = @today,
                pd.UsuarioModificacion = @IdUser
            FROM CONTA.PolizaDetalle pd
            INNER JOIN PRES.IngreAdecuacionDetalle det
                ON pd.FKIdReferencia = det.PKIdIngreAdecuacionDetalle
            WHERE det.FKIdIngreAdecuacion_PRES = @PKIdIngreAdecuacion
              AND det.Activo = 1
              AND pd.FKIdPoliza_CONTA = @FKIdPoliza_CONTA
              AND pd.Activo = 1;

            UPDATE PRES.IngreAdecuacionDetalle
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE FKIdIngreAdecuacion_PRES = @PKIdIngreAdecuacion
              AND Activo = 1;

            UPDATE PRES.IngreAdecuacion
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdIngreAdecuacion = @PKIdIngreAdecuacion;

            IF @FKIdPoliza_CONTA IS NOT NULL
            BEGIN
                SET @ErrorPoliza = N'';
                EXEC CONTA.SP_UPDATE_PolizaBalanceada
                    @PKIdPoliza = @FKIdPoliza_CONTA,
                    @IdUser = @IdUser,
                    @Error = @ErrorPoliza OUTPUT;

                IF ISNULL(@ErrorPoliza, N'') <> N''
                    THROW 51000, N'No se pudo recalcular el balance de la poliza.', 1;
            END

            SET @Id = @PKIdIngreAdecuacion;
            SET @message = N'Se elimino correctamente la adecuacion de ingresos.';
        END

        COMMIT TRANSACTION;

        SELECT JSON_QUERY(CONCAT(
            N'{"tipo":"OK","mensaje":"',
            STRING_ESCAPE(CONCAT(@message, N' ', ISNULL(@AlertMessage, N'')), 'json'),
            N'","liga":"id:', ISNULL(CONVERT(nvarchar(20), @Id), N''), N'"}'
        )) AS ResultJson;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @message = CONCAT(ERROR_MESSAGE(), N' Linea: ', ERROR_LINE());

        IF OBJECT_ID(N'SIS.WriteSystemLog', N'P') IS NOT NULL
        BEGIN TRY
            EXEC SIS.WriteSystemLog
                @FK_IdOrigenLogMessage__SIS = 1,
                @Date = @today,
                @_Type = 1,
                @ProgName = N'PRES.sp_MantenimientoIngresoAdecuacion',
                @EmployeeNo = @IdUser,
                @Category = NULL,
                @IPClient = NULL,
                @HostName = NULL,
                @Thread = NULL,
                @Level = N'ERROR',
                @Logger = NULL,
                @Message = @message,
                @Exception = NULL,
                @Context = NULL,
                @MethodName = N'PRES.sp_MantenimientoIngresoAdecuacion',
                @Parameters = NULL,
                @ExecutionTime = N'0';
        END TRY
        BEGIN CATCH
        END CATCH;

        SELECT JSON_QUERY(CONCAT(
            N'{"tipo":"ERROR","mensaje":"',
            STRING_ESCAPE(ISNULL(@message, N''), 'json'),
            N'","liga":""}'
        )) AS ResultJson;

        RETURN -1;
    END CATCH
END
GO

/* ========================================================================== */
/* 5. MANTENIMIENTO DEL DETALLE                                               */
/* ========================================================================== */

CREATE OR ALTER PROCEDURE PRES.sp_MantenimientoAdecuacionDisminucionIngreso
    @Action int,
    @PKIdIngreAdecuacionDetalle int = NULL,
    @FKIdIngresoAutorizado_PRES int = NULL,
    @Justificacion nvarchar(max) = NULL,
    @Fecha datetime2(7) = NULL,
    @FKIdIngreAdecuacion_PRES int = NULL,
    @FKIdTipoMovimiento_PRES int = NULL,
    @Enero decimal(18,2) = 0,
    @Febrero decimal(18,2) = 0,
    @Marzo decimal(18,2) = 0,
    @Abril decimal(18,2) = 0,
    @Mayo decimal(18,2) = 0,
    @Junio decimal(18,2) = 0,
    @Julio decimal(18,2) = 0,
    @Agosto decimal(18,2) = 0,
    @Septiembre decimal(18,2) = 0,
    @Octubre decimal(18,2) = 0,
    @Noviembre decimal(18,2) = 0,
    @Diciembre decimal(18,2) = 0,
    @IdC int = NULL,
    @IdUser int = NULL,
    @Id int = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @today datetime2(7) = SYSDATETIME(),
        @message nvarchar(max) = N'',
        @Error nvarchar(max) = N'',
        @Signo int,
        @Importe decimal(18,2),
        @FKIdAnio_SIS int,
        @FKIdAnioIngreso int,
        @FKIdPrograma_PRES int,
        @FKIdOrigen_PRES int,
        @FKIdPoliza_CONTA int,
        @FKIdPolizaAnterior int,
        @FKIdIngreAdecuacionAnterior int,
        @Autorizado bit,
        @CuentaModificado int,
        @CuentaPorEjercer int,
        @CantidadMatrices int,
        @DescripcionModificado nvarchar(500),
        @DescripcionPorEjercer nvarchar(500),
        @DispEnero decimal(20,4),
        @DispFebrero decimal(20,4),
        @DispMarzo decimal(20,4),
        @DispAbril decimal(20,4),
        @DispMayo decimal(20,4),
        @DispJunio decimal(20,4),
        @DispJulio decimal(20,4),
        @DispAgosto decimal(20,4),
        @DispSeptiembre decimal(20,4),
        @DispOctubre decimal(20,4),
        @DispNoviembre decimal(20,4),
        @DispDiciembre decimal(20,4);

    BEGIN TRY
        SET @PKIdIngreAdecuacionDetalle = COALESCE(@PKIdIngreAdecuacionDetalle, @IdC);

        IF @Action NOT IN (1, 2, 3)
            THROW 51000, N'Accion no valida. Use 1=Insert, 2=Update o 3=Delete.', 1;

        IF @IdUser IS NULL
            THROW 51000, N'Debe indicar IdUser.', 1;

        BEGIN TRANSACTION;

        IF @Action IN (1, 2)
        BEGIN
            IF @FKIdIngresoAutorizado_PRES IS NULL
             OR @FKIdIngreAdecuacion_PRES IS NULL
             OR @FKIdTipoMovimiento_PRES IS NULL
                THROW 51000, N'Debe indicar ingreso autorizado, adecuacion y tipo de movimiento.', 1;

            IF @FKIdTipoMovimiento_PRES NOT IN (3, 4)
                THROW 51000, N'Para ingresos solo se permiten los movimientos 3=Aumento y 4=Reduccion.', 1;

            IF NOT EXISTS (
                SELECT 1
                FROM PRES.TipoMovimiento
                WHERE PKIdTipoMovimiento = @FKIdTipoMovimiento_PRES
                  AND Activo = 1
            )
                THROW 51000, N'El tipo de movimiento esta inactivo.', 1;

            IF ISNULL(@Enero, 0) < 0 OR ISNULL(@Febrero, 0) < 0
             OR ISNULL(@Marzo, 0) < 0 OR ISNULL(@Abril, 0) < 0
             OR ISNULL(@Mayo, 0) < 0 OR ISNULL(@Junio, 0) < 0
             OR ISNULL(@Julio, 0) < 0 OR ISNULL(@Agosto, 0) < 0
             OR ISNULL(@Septiembre, 0) < 0 OR ISNULL(@Octubre, 0) < 0
             OR ISNULL(@Noviembre, 0) < 0 OR ISNULL(@Diciembre, 0) < 0
                THROW 51000, N'Capture importes positivos; el procedimiento aplica el signo segun el movimiento.', 1;

            SET @Importe =
                ISNULL(@Enero, 0) + ISNULL(@Febrero, 0) + ISNULL(@Marzo, 0) +
                ISNULL(@Abril, 0) + ISNULL(@Mayo, 0) + ISNULL(@Junio, 0) +
                ISNULL(@Julio, 0) + ISNULL(@Agosto, 0) + ISNULL(@Septiembre, 0) +
                ISNULL(@Octubre, 0) + ISNULL(@Noviembre, 0) + ISNULL(@Diciembre, 0);

            IF @Importe <= 0
                THROW 51000, N'El importe total de la adecuacion debe ser mayor que cero.', 1;

            SELECT
                @FKIdPoliza_CONTA = enc.FKIdPoliza_CONTA,
                @FKIdAnio_SIS = enc.FKIdAnio_SIS,
                @Autorizado = enc.Autorizado,
                @Fecha = COALESCE(@Fecha, enc.Fecha)
            FROM PRES.IngreAdecuacion enc
            WHERE enc.PKIdIngreAdecuacion = @FKIdIngreAdecuacion_PRES
              AND enc.Activo = 1;

            IF @FKIdPoliza_CONTA IS NULL
                THROW 51000, N'La adecuacion no existe o no tiene poliza activa relacionada.', 1;

            IF @Autorizado = 1
                THROW 51000, N'No se pueden modificar detalles de una adecuacion autorizada.', 1;

            IF NOT EXISTS (
                SELECT 1 FROM CONTA.Poliza
                WHERE PKIdPoliza = @FKIdPoliza_CONTA AND Activo = 1
            )
                THROW 51000, N'La poliza de la adecuacion esta inactiva.', 1;

            SELECT
                @FKIdPrograma_PRES = ing.FKIdPrograma_PRES,
                @FKIdOrigen_PRES = ing.FKIdOrigen_PRES,
                @FKIdAnioIngreso = prog.FKIdAnio_SIS
            FROM PRES.IngresoAutorizado ing
            INNER JOIN PRES.Programa prog
                ON ing.FKIdPrograma_PRES = prog.PKIdPrograma
               AND prog.Activo = 1
            WHERE ing.PKIdIngresoAutorizado = @FKIdIngresoAutorizado_PRES
              AND ing.Activo = 1
              AND ing.FechaAutorizacion IS NOT NULL;

            IF @FKIdPrograma_PRES IS NULL
                THROW 51000, N'El ingreso autorizado no existe, esta inactivo o aun no esta autorizado.', 1;

            IF @FKIdAnioIngreso <> @FKIdAnio_SIS
                THROW 51000, N'El ingreso autorizado y la adecuacion pertenecen a anios diferentes.', 1;

            SELECT
                @CantidadMatrices = COUNT(*),
                @CuentaModificado = MAX(mi.Fk_IdCuentaContableModificado),
                @CuentaPorEjercer = MAX(mi.Fk_IdCuentaContablePorEjercer)
            FROM CONTA.MatrizIngreso mi
            WHERE mi.FK_IdAnio__SIS = @FKIdAnio_SIS
              AND mi.Fk_IdPrograma = @FKIdPrograma_PRES
              AND mi.Fk_IdOrigen = @FKIdOrigen_PRES
              AND mi.Activo = 1;

            IF @CantidadMatrices = 0
                THROW 51000, N'No existe matriz de ingresos activa para el anio, programa y origen.', 1;

            IF @CantidadMatrices > 1
                THROW 51000, N'Existe mas de una matriz de ingresos activa para el anio, programa y origen.', 1;

            IF @CuentaModificado IS NULL OR @CuentaPorEjercer IS NULL
                THROW 51000, N'La matriz de ingresos no tiene cuentas de Modificado y Por Ejercer.', 1;

            IF EXISTS (
                SELECT 1
                FROM PRES.IngreAdecuacionDetalle det
                WHERE det.FKIdIngreAdecuacion_PRES = @FKIdIngreAdecuacion_PRES
                  AND det.FKIdIngresoAutorizado_PRES = @FKIdIngresoAutorizado_PRES
                  AND det.FKIdTipoMovimiento_PRES = @FKIdTipoMovimiento_PRES
                  AND det.Activo = 1
                  AND det.PKIdIngreAdecuacionDetalle <> ISNULL(@PKIdIngreAdecuacionDetalle, 0)
            )
                THROW 51000, N'Ya existe ese ingreso y tipo de movimiento dentro de la adecuacion.', 1;

            IF @FKIdTipoMovimiento_PRES = 4
            BEGIN
                SELECT
                    @DispEnero = ISNULL(ing.Enero, 0) + ISNULL(aj.Enero, 0),
                    @DispFebrero = ISNULL(ing.Febrero, 0) + ISNULL(aj.Febrero, 0),
                    @DispMarzo = ISNULL(ing.Marzo, 0) + ISNULL(aj.Marzo, 0),
                    @DispAbril = ISNULL(ing.Abril, 0) + ISNULL(aj.Abril, 0),
                    @DispMayo = ISNULL(ing.Mayo, 0) + ISNULL(aj.Mayo, 0),
                    @DispJunio = ISNULL(ing.Junio, 0) + ISNULL(aj.Junio, 0),
                    @DispJulio = ISNULL(ing.Julio, 0) + ISNULL(aj.Julio, 0),
                    @DispAgosto = ISNULL(ing.Agosto, 0) + ISNULL(aj.Agosto, 0),
                    @DispSeptiembre = ISNULL(ing.Septiembre, 0) + ISNULL(aj.Septiembre, 0),
                    @DispOctubre = ISNULL(ing.Octubre, 0) + ISNULL(aj.Octubre, 0),
                    @DispNoviembre = ISNULL(ing.Noviembre, 0) + ISNULL(aj.Noviembre, 0),
                    @DispDiciembre = ISNULL(ing.Diciembre, 0) + ISNULL(aj.Diciembre, 0)
                FROM PRES.IngresoAutorizado ing
                OUTER APPLY (
                    SELECT
                        SUM(det.Enero) AS Enero,
                        SUM(det.Febrero) AS Febrero,
                        SUM(det.Marzo) AS Marzo,
                        SUM(det.Abril) AS Abril,
                        SUM(det.Mayo) AS Mayo,
                        SUM(det.Junio) AS Junio,
                        SUM(det.Julio) AS Julio,
                        SUM(det.Agosto) AS Agosto,
                        SUM(det.Septiembre) AS Septiembre,
                        SUM(det.Octubre) AS Octubre,
                        SUM(det.Noviembre) AS Noviembre,
                        SUM(det.Diciembre) AS Diciembre
                    FROM PRES.IngreAdecuacionDetalle det
                    INNER JOIN PRES.IngreAdecuacion enc
                        ON det.FKIdIngreAdecuacion_PRES = enc.PKIdIngreAdecuacion
                       AND enc.Activo = 1
                       AND enc.Autorizado = 1
                    WHERE det.FKIdIngresoAutorizado_PRES = ing.PKIdIngresoAutorizado
                      AND det.Activo = 1
                ) aj
                WHERE ing.PKIdIngresoAutorizado = @FKIdIngresoAutorizado_PRES
                  AND ing.Activo = 1;

                SET @message = N'';
                IF ISNULL(@Enero, 0) > ISNULL(@DispEnero, 0) SET @message += N'Enero; ';
                IF ISNULL(@Febrero, 0) > ISNULL(@DispFebrero, 0) SET @message += N'Febrero; ';
                IF ISNULL(@Marzo, 0) > ISNULL(@DispMarzo, 0) SET @message += N'Marzo; ';
                IF ISNULL(@Abril, 0) > ISNULL(@DispAbril, 0) SET @message += N'Abril; ';
                IF ISNULL(@Mayo, 0) > ISNULL(@DispMayo, 0) SET @message += N'Mayo; ';
                IF ISNULL(@Junio, 0) > ISNULL(@DispJunio, 0) SET @message += N'Junio; ';
                IF ISNULL(@Julio, 0) > ISNULL(@DispJulio, 0) SET @message += N'Julio; ';
                IF ISNULL(@Agosto, 0) > ISNULL(@DispAgosto, 0) SET @message += N'Agosto; ';
                IF ISNULL(@Septiembre, 0) > ISNULL(@DispSeptiembre, 0) SET @message += N'Septiembre; ';
                IF ISNULL(@Octubre, 0) > ISNULL(@DispOctubre, 0) SET @message += N'Octubre; ';
                IF ISNULL(@Noviembre, 0) > ISNULL(@DispNoviembre, 0) SET @message += N'Noviembre; ';
                IF ISNULL(@Diciembre, 0) > ISNULL(@DispDiciembre, 0) SET @message += N'Diciembre; ';

                IF @message <> N''
                BEGIN
                    SET @message = CONCAT(N'La reduccion supera el ingreso disponible en: ', @message);
                    THROW 51000, @message, 1;
                END
            END

            SET @Signo = CASE WHEN @FKIdTipoMovimiento_PRES = 3 THEN 1 ELSE -1 END;
            SET @DescripcionModificado = LEFT(CONCAT(N'Presupuesto Modificado ', ISNULL(@Justificacion, N'')), 500);
            SET @DescripcionPorEjercer = LEFT(CONCAT(N'Presupuesto por Ejercer ', ISNULL(@Justificacion, N'')), 500);
        END

        IF @Action = 1
        BEGIN
            INSERT INTO PRES.IngreAdecuacionDetalle (
                FKIdIngresoAutorizado_PRES,
                Justificacion,
                Fecha,
                FKIdIngreAdecuacion_PRES,
                FKIdTipoMovimiento_PRES,
                Enero,
                Febrero,
                Marzo,
                Abril,
                Mayo,
                Junio,
                Julio,
                Agosto,
                Septiembre,
                Octubre,
                Noviembre,
                Diciembre,
                Activo,
                FechaCreacion,
                UsuarioCreacion
            )
            VALUES (
                @FKIdIngresoAutorizado_PRES,
                @Justificacion,
                CONVERT(date, @Fecha),
                @FKIdIngreAdecuacion_PRES,
                @FKIdTipoMovimiento_PRES,
                ISNULL(@Enero, 0) * @Signo,
                ISNULL(@Febrero, 0) * @Signo,
                ISNULL(@Marzo, 0) * @Signo,
                ISNULL(@Abril, 0) * @Signo,
                ISNULL(@Mayo, 0) * @Signo,
                ISNULL(@Junio, 0) * @Signo,
                ISNULL(@Julio, 0) * @Signo,
                ISNULL(@Agosto, 0) * @Signo,
                ISNULL(@Septiembre, 0) * @Signo,
                ISNULL(@Octubre, 0) * @Signo,
                ISNULL(@Noviembre, 0) * @Signo,
                ISNULL(@Diciembre, 0) * @Signo,
                1,
                @today,
                @IdUser
            );

            SET @Id = CONVERT(int, SCOPE_IDENTITY());
        END
        ELSE IF @Action = 2
        BEGIN
            SELECT
                @FKIdIngreAdecuacionAnterior = det.FKIdIngreAdecuacion_PRES,
                @FKIdPolizaAnterior = enc.FKIdPoliza_CONTA,
                @Autorizado = enc.Autorizado
            FROM PRES.IngreAdecuacionDetalle det WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN PRES.IngreAdecuacion enc
                ON det.FKIdIngreAdecuacion_PRES = enc.PKIdIngreAdecuacion
               AND enc.Activo = 1
            WHERE det.PKIdIngreAdecuacionDetalle = @PKIdIngreAdecuacionDetalle
              AND det.Activo = 1;

            IF @FKIdIngreAdecuacionAnterior IS NULL
                THROW 51000, N'No se encontro el detalle para modificar.', 1;

            IF @Autorizado = 1
                THROW 51000, N'No se puede modificar un detalle autorizado.', 1;

            UPDATE CONTA.PolizaDetalle
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE FKIdPoliza_CONTA = @FKIdPolizaAnterior
              AND FKIdReferencia = @PKIdIngreAdecuacionDetalle
              AND Activo = 1;

            UPDATE PRES.IngreAdecuacionDetalle
            SET
                FKIdIngresoAutorizado_PRES = @FKIdIngresoAutorizado_PRES,
                Justificacion = @Justificacion,
                Fecha = CONVERT(date, @Fecha),
                FKIdIngreAdecuacion_PRES = @FKIdIngreAdecuacion_PRES,
                FKIdTipoMovimiento_PRES = @FKIdTipoMovimiento_PRES,
                Enero = ISNULL(@Enero, 0) * @Signo,
                Febrero = ISNULL(@Febrero, 0) * @Signo,
                Marzo = ISNULL(@Marzo, 0) * @Signo,
                Abril = ISNULL(@Abril, 0) * @Signo,
                Mayo = ISNULL(@Mayo, 0) * @Signo,
                Junio = ISNULL(@Junio, 0) * @Signo,
                Julio = ISNULL(@Julio, 0) * @Signo,
                Agosto = ISNULL(@Agosto, 0) * @Signo,
                Septiembre = ISNULL(@Septiembre, 0) * @Signo,
                Octubre = ISNULL(@Octubre, 0) * @Signo,
                Noviembre = ISNULL(@Noviembre, 0) * @Signo,
                Diciembre = ISNULL(@Diciembre, 0) * @Signo,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdIngreAdecuacionDetalle = @PKIdIngreAdecuacionDetalle
              AND Activo = 1;

            SET @Id = @PKIdIngreAdecuacionDetalle;
        END
        ELSE
        BEGIN
            SELECT
                @FKIdPoliza_CONTA = enc.FKIdPoliza_CONTA,
                @Autorizado = enc.Autorizado
            FROM PRES.IngreAdecuacionDetalle det WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN PRES.IngreAdecuacion enc
                ON det.FKIdIngreAdecuacion_PRES = enc.PKIdIngreAdecuacion
               AND enc.Activo = 1
            WHERE det.PKIdIngreAdecuacionDetalle = @PKIdIngreAdecuacionDetalle
              AND det.Activo = 1;

            IF @FKIdPoliza_CONTA IS NULL
                THROW 51000, N'No se encontro el detalle para eliminar.', 1;

            IF @Autorizado = 1
                THROW 51000, N'No se puede eliminar un detalle autorizado.', 1;

            UPDATE PRES.IngreAdecuacionDetalle
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdIngreAdecuacionDetalle = @PKIdIngreAdecuacionDetalle
              AND Activo = 1;

            UPDATE CONTA.PolizaDetalle
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE FKIdPoliza_CONTA = @FKIdPoliza_CONTA
              AND FKIdReferencia = @PKIdIngreAdecuacionDetalle
              AND Activo = 1;

            SET @Error = N'';
            EXEC CONTA.SP_UPDATE_PolizaBalanceada
                @PKIdPoliza = @FKIdPoliza_CONTA,
                @IdUser = @IdUser,
                @Error = @Error OUTPUT;

            IF ISNULL(@Error, N'') <> N''
                THROW 51000, N'No se pudo recalcular el balance de la poliza.', 1;

            SET @Id = @PKIdIngreAdecuacionDetalle;
            SET @message = N'Se elimino correctamente el detalle de la adecuacion.';
        END

        IF @Action IN (1, 2)
        BEGIN
            SET @Error = N'';

            IF @FKIdTipoMovimiento_PRES = 3
            BEGIN
                EXEC CONTA.SP_CREATE_DetallePolizaWOM
                    @FKIdCuentaContable_CONTA = @CuentaModificado,
                    @FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                    @Descripcion = @DescripcionModificado,
                    @ImporteDebe = @Importe,
                    @ImporteHaber = 0,
                    @FKIdReferencia = @Id,
                    @FKIdTipoDetallePoliza_SIS = 1,
                    @IdUser = @IdUser,
                    @Error = @Error OUTPUT;

                IF ISNULL(@Error, N'') = N''
                    EXEC CONTA.SP_CREATE_DetallePolizaWOM
                        @FKIdCuentaContable_CONTA = @CuentaPorEjercer,
                        @FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                        @Descripcion = @DescripcionPorEjercer,
                        @ImporteDebe = 0,
                        @ImporteHaber = @Importe,
                        @FKIdReferencia = @Id,
                        @FKIdTipoDetallePoliza_SIS = 2,
                        @IdUser = @IdUser,
                        @Error = @Error OUTPUT;
            END
            ELSE
            BEGIN
                EXEC CONTA.SP_CREATE_DetallePolizaWOM
                    @FKIdCuentaContable_CONTA = @CuentaPorEjercer,
                    @FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                    @Descripcion = @DescripcionPorEjercer,
                    @ImporteDebe = @Importe,
                    @ImporteHaber = 0,
                    @FKIdReferencia = @Id,
                    @FKIdTipoDetallePoliza_SIS = 1,
                    @IdUser = @IdUser,
                    @Error = @Error OUTPUT;

                IF ISNULL(@Error, N'') = N''
                    EXEC CONTA.SP_CREATE_DetallePolizaWOM
                        @FKIdCuentaContable_CONTA = @CuentaModificado,
                        @FKIdPoliza_CONTA = @FKIdPoliza_CONTA,
                        @Descripcion = @DescripcionModificado,
                        @ImporteDebe = 0,
                        @ImporteHaber = @Importe,
                        @FKIdReferencia = @Id,
                        @FKIdTipoDetallePoliza_SIS = 2,
                        @IdUser = @IdUser,
                        @Error = @Error OUTPUT;
            END

            IF ISNULL(@Error, N'') <> N''
                THROW 51000, N'No se pudieron generar los detalles de la poliza.', 1;

            EXEC CONTA.SP_UPDATE_PolizaBalanceada
                @PKIdPoliza = @FKIdPoliza_CONTA,
                @IdUser = @IdUser,
                @Error = @Error OUTPUT;

            IF ISNULL(@Error, N'') <> N''
                THROW 51000, N'No se pudo recalcular el balance de la poliza.', 1;

            IF @Action = 2
               AND @FKIdPolizaAnterior IS NOT NULL
               AND @FKIdPolizaAnterior <> @FKIdPoliza_CONTA
            BEGIN
                SET @Error = N'';
                EXEC CONTA.SP_UPDATE_PolizaBalanceada
                    @PKIdPoliza = @FKIdPolizaAnterior,
                    @IdUser = @IdUser,
                    @Error = @Error OUTPUT;

                IF ISNULL(@Error, N'') <> N''
                    THROW 51000, N'No se pudo recalcular el balance de la poliza anterior.', 1;
            END

            SET @message = CASE
                WHEN @Action = 1 THEN N'Se registro correctamente el detalle de la adecuacion.'
                ELSE N'Se actualizo correctamente el detalle de la adecuacion.'
            END;
        END

        COMMIT TRANSACTION;

        SELECT JSON_QUERY(CONCAT(
            N'{"tipo":"OK","mensaje":"',
            STRING_ESCAPE(ISNULL(@message, N''), 'json'),
            N'","liga":"id:', ISNULL(CONVERT(nvarchar(20), @Id), N''), N'"}'
        )) AS ResultJson;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @message = CONCAT(ERROR_MESSAGE(), N' Linea: ', ERROR_LINE());

        IF OBJECT_ID(N'SIS.WriteSystemLog', N'P') IS NOT NULL
        BEGIN TRY
            EXEC SIS.WriteSystemLog
                @FK_IdOrigenLogMessage__SIS = 1,
                @Date = @today,
                @_Type = 1,
                @ProgName = N'PRES.sp_MantenimientoAdecuacionDisminucionIngreso',
                @EmployeeNo = @IdUser,
                @Category = NULL,
                @IPClient = NULL,
                @HostName = NULL,
                @Thread = NULL,
                @Level = N'ERROR',
                @Logger = NULL,
                @Message = @message,
                @Exception = NULL,
                @Context = NULL,
                @MethodName = N'PRES.sp_MantenimientoAdecuacionDisminucionIngreso',
                @Parameters = NULL,
                @ExecutionTime = N'0';
        END TRY
        BEGIN CATCH
        END CATCH;

        SELECT JSON_QUERY(CONCAT(
            N'{"tipo":"ERROR","mensaje":"',
            STRING_ESCAPE(ISNULL(@message, N''), 'json'),
            N'","liga":""}'
        )) AS ResultJson;

        RETURN -1;
    END CATCH
END
GO

PRINT N'Script de adecuaciones de ingresos finalizado.';
GO
