SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF OBJECT_ID(N'ALMA.PlanConteoCiclico', N'U') IS NULL
BEGIN
    CREATE TABLE ALMA.PlanConteoCiclico
    (
        PKIdPlanConteoCiclico INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_PlanConteoCiclico PRIMARY KEY,
        FKIdTipoBien_ALMA INT NOT NULL,
        FKIdArea_SIS INT NULL,
        ClasificacionABC CHAR(1) NOT NULL
            CONSTRAINT DF_PlanConteoCiclico_Clasificacion DEFAULT ('C'),
        FrecuenciaDias INT NOT NULL
            CONSTRAINT DF_PlanConteoCiclico_Frecuencia DEFAULT (180),
        FrecuenciaPersonalizada BIT NOT NULL
            CONSTRAINT DF_PlanConteoCiclico_FrecuenciaPersonalizada DEFAULT (0),
        UltimaFechaConteo DATE NULL,
        ProximaFechaConteo DATE NOT NULL,
        ExistenciaActual DECIMAL(18,4) NOT NULL
            CONSTRAINT DF_PlanConteoCiclico_Existencia DEFAULT (0),
        ExistenciaMinima DECIMAL(18,4) NULL,
        ValorInventario DECIMAL(18,4) NOT NULL
            CONSTRAINT DF_PlanConteoCiclico_Valor DEFAULT (0),
        GenerarPorUmbral BIT NOT NULL
            CONSTRAINT DF_PlanConteoCiclico_Umbral DEFAULT (1),
        RequiereConteoPorUmbral BIT NOT NULL
            CONSTRAINT DF_PlanConteoCiclico_RequiereUmbral DEFAULT (0),
        Activo BIT NOT NULL
            CONSTRAINT DF_PlanConteoCiclico_Activo DEFAULT (1),
        FechaCreacion DATETIME2 NOT NULL
            CONSTRAINT DF_PlanConteoCiclico_FechaCreacion DEFAULT (SYSDATETIME()),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT UQ_PlanConteoCiclico_TipoBien UNIQUE (FKIdTipoBien_ALMA),
        CONSTRAINT CK_PlanConteoCiclico_Clasificacion CHECK (ClasificacionABC IN ('A','B','C')),
        CONSTRAINT CK_PlanConteoCiclico_Frecuencia CHECK (FrecuenciaDias BETWEEN 1 AND 3650),
        CONSTRAINT FK_PlanConteoCiclico_TipoBien FOREIGN KEY (FKIdTipoBien_ALMA)
            REFERENCES ALMA.TipoBien(PKIdTipoBien),
        CONSTRAINT FK_PlanConteoCiclico_Area FOREIGN KEY (FKIdArea_SIS)
            REFERENCES SIS.Area(PKIdArea)
    );

    CREATE INDEX IX_PlanConteoCiclico_ProximaFecha
        ON ALMA.PlanConteoCiclico (Activo, ProximaFechaConteo, ClasificacionABC);
END;

IF COL_LENGTH(N'ALMA.PlanConteoCiclico', N'FrecuenciaPersonalizada') IS NULL
BEGIN
    ALTER TABLE ALMA.PlanConteoCiclico
        ADD FrecuenciaPersonalizada BIT NOT NULL
            CONSTRAINT DF_PlanConteoCiclico_FrecuenciaPersonalizada DEFAULT (0);
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_ActualizarPlanConteoCiclico
    @UsuarioActual INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @UltimoAnio INT = (SELECT MAX(FK_IdAnio__SIS) FROM ALMA.Vw_Existencias);

    ;WITH Existencias AS
    (
        SELECT
            E.PKIdTipoBien,
            SUM(CONVERT(DECIMAL(18,4), ISNULL(E.Existencias, 0))) AS ExistenciaActual,
            SUM(ABS(CONVERT(DECIMAL(18,4), ISNULL(E.Existencias, 0))) * ISNULL(E.CostoPromedio, 0)) AS ValorInventario
        FROM ALMA.Vw_Existencias E
        WHERE E.FK_IdAnio__SIS = @UltimoAnio
        GROUP BY E.PKIdTipoBien
    ),
    Base AS
    (
        SELECT
            T.PKIdTipoBien,
            ISNULL(X.ExistenciaActual, 0) AS ExistenciaActual,
            T.ExistenciaMinima,
            ISNULL(X.ValorInventario, 0) AS ValorInventario,
            CASE WHEN SUM(ISNULL(X.ValorInventario, 0)) OVER () > 0
                 THEN ISNULL(X.ValorInventario, 0)
                 ELSE ABS(ISNULL(X.ExistenciaActual, 0)) END AS Puntaje,
            A.FKIdArea_SIS
        FROM ALMA.TipoBien T
        INNER JOIN Existencias X ON X.PKIdTipoBien = T.PKIdTipoBien
        OUTER APPLY
        (
            SELECT TOP (1) M.FKIdArea_SIS
            FROM ALMA.Almacen M
            WHERE M.Activo = 1
              AND M.FKIdTipoBien_ALMA = T.PKIdTipoBien
              AND M.FKIdArea_SIS IS NOT NULL
            GROUP BY M.FKIdArea_SIS
            ORDER BY SUM(ABS(M.Cantidad)) DESC, M.FKIdArea_SIS
        ) A
        WHERE T.Activo = 1
    ),
    Clasificada AS
    (
        SELECT *,
            CASE
                WHEN SUM(Puntaje) OVER () = 0 THEN 'C'
                WHEN (SUM(Puntaje) OVER (ORDER BY Puntaje DESC, PKIdTipoBien ROWS UNBOUNDED PRECEDING) - Puntaje)
                     / NULLIF(SUM(Puntaje) OVER (), 0) < 0.80 THEN 'A'
                WHEN (SUM(Puntaje) OVER (ORDER BY Puntaje DESC, PKIdTipoBien ROWS UNBOUNDED PRECEDING) - Puntaje)
                     / NULLIF(SUM(Puntaje) OVER (), 0) < 0.95 THEN 'B'
                ELSE 'C'
            END AS ClasificacionABC
        FROM Base
    )
    MERGE ALMA.PlanConteoCiclico AS Destino
    USING Clasificada AS Origen
       ON Destino.FKIdTipoBien_ALMA = Origen.PKIdTipoBien
    WHEN MATCHED THEN
        UPDATE SET
            Destino.ClasificacionABC = Origen.ClasificacionABC,
            Destino.FKIdArea_SIS = COALESCE(Destino.FKIdArea_SIS, Origen.FKIdArea_SIS),
            Destino.FrecuenciaDias = CASE WHEN Destino.FrecuenciaPersonalizada = 1 THEN Destino.FrecuenciaDias
                ELSE CASE Origen.ClasificacionABC WHEN 'A' THEN 30 WHEN 'B' THEN 90 ELSE 180 END END,
            Destino.ProximaFechaConteo = CASE WHEN Destino.FrecuenciaPersonalizada = 1 THEN Destino.ProximaFechaConteo
                ELSE DATEADD(DAY, CASE Origen.ClasificacionABC WHEN 'A' THEN 30 WHEN 'B' THEN 90 ELSE 180 END,
                    ISNULL(Destino.UltimaFechaConteo, CONVERT(DATE, GETDATE()))) END,
            Destino.ExistenciaActual = Origen.ExistenciaActual,
            Destino.ExistenciaMinima = Origen.ExistenciaMinima,
            Destino.ValorInventario = Origen.ValorInventario,
            Destino.RequiereConteoPorUmbral = CASE
                WHEN Destino.GenerarPorUmbral = 1
                 AND Origen.ExistenciaMinima IS NOT NULL
                 AND Origen.ExistenciaActual > 0
                 AND Origen.ExistenciaActual <= Origen.ExistenciaMinima THEN 1 ELSE 0 END,
            Destino.Activo = 1,
            Destino.FechaModificacion = SYSDATETIME(),
            Destino.UsuarioModificacion = @UsuarioActual
    WHEN NOT MATCHED THEN
        INSERT
        (
            FKIdTipoBien_ALMA, FKIdArea_SIS, ClasificacionABC, FrecuenciaDias, FrecuenciaPersonalizada,
            ProximaFechaConteo, ExistenciaActual, ExistenciaMinima, ValorInventario,
            GenerarPorUmbral, RequiereConteoPorUmbral, Activo, FechaCreacion, UsuarioCreacion
        )
        VALUES
        (
            Origen.PKIdTipoBien, Origen.FKIdArea_SIS, Origen.ClasificacionABC,
            CASE Origen.ClasificacionABC WHEN 'A' THEN 30 WHEN 'B' THEN 90 ELSE 180 END,
            0,
            DATEADD(DAY, CASE Origen.ClasificacionABC WHEN 'A' THEN 30 WHEN 'B' THEN 90 ELSE 180 END, CONVERT(DATE, GETDATE())),
            Origen.ExistenciaActual, Origen.ExistenciaMinima, Origen.ValorInventario, 1,
            CASE WHEN Origen.ExistenciaMinima IS NOT NULL AND Origen.ExistenciaActual > 0 AND Origen.ExistenciaActual <= Origen.ExistenciaMinima THEN 1 ELSE 0 END,
            1, SYSDATETIME(), @UsuarioActual
        );

    UPDATE P
       SET Activo = 0,
           FechaModificacion = SYSDATETIME(),
           UsuarioModificacion = @UsuarioActual
    FROM ALMA.PlanConteoCiclico P
    WHERE P.Activo = 1
      AND NOT EXISTS
          (SELECT 1 FROM ALMA.TipoBien T WHERE T.PKIdTipoBien = P.FKIdTipoBien_ALMA AND T.Activo = 1);
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_GenerarConteosCiclicosSugeridos
    @PKIdPeriodoConteo INT,
    @UsuarioActual INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Estatus NVARCHAR(100);
    SELECT @Estatus = E.Nombre
    FROM ALMA.PeriodoConteo P
    INNER JOIN ALMA.EstatusPeriodo E ON E.PKIdEstatusPeriodo = P.FKIdEstatus_ALMA
    WHERE P.PKIdPeriodoConteo = @PKIdPeriodoConteo AND P.Activo = 1;

    IF @Estatus IS NULL
        THROW 51000, 'El periodo de conteo no existe o no esta activo.', 1;
    IF UPPER(LTRIM(RTRIM(@Estatus))) <> 'PENDIENTE'
        THROW 51000, 'Los conteos sugeridos solo se generan en periodos pendientes.', 1;

    EXEC ALMA.SP_ActualizarPlanConteoCiclico @UsuarioActual;

    INSERT INTO ALMA.Conteo
    (
        FKIdTipoBien_ALMA, CantidadInventario, Descripcion, FechaInicio,
        FKIdPeriodoConteo_ALMA, Activo, FechaCreacion, UsuarioCreacion
    )
    SELECT
        P.FKIdTipoBien_ALMA,
        P.ExistenciaActual,
        CONCAT(
            CASE WHEN P.RequiereConteoPorUmbral = 1 THEN '[UMBRAL] ' ELSE CONCAT('[ABC-', P.ClasificacionABC, '] ') END,
            T.Descripcion,
            CASE WHEN A.PKIdArea IS NOT NULL THEN CONCAT(' - ', A.Nombre) ELSE '' END),
        SYSDATETIME(), @PKIdPeriodoConteo, 1, SYSDATETIME(), @UsuarioActual
    FROM ALMA.PlanConteoCiclico P
    INNER JOIN ALMA.TipoBien T ON T.PKIdTipoBien = P.FKIdTipoBien_ALMA
    LEFT JOIN SIS.Area A ON A.PKIdArea = P.FKIdArea_SIS
    WHERE P.Activo = 1
      AND (P.ProximaFechaConteo <= CONVERT(DATE, GETDATE()) OR P.RequiereConteoPorUmbral = 1)
      AND NOT EXISTS
          (SELECT 1 FROM ALMA.Conteo C
           WHERE C.FKIdPeriodoConteo_ALMA = @PKIdPeriodoConteo
             AND C.FKIdTipoBien_ALMA = P.FKIdTipoBien_ALMA
             AND C.Activo = 1)
      AND NOT EXISTS
          (SELECT 1
           FROM ALMA.Conteo C
           INNER JOIN ALMA.PeriodoConteo PC ON PC.PKIdPeriodoConteo = C.FKIdPeriodoConteo_ALMA
           INNER JOIN ALMA.EstatusPeriodo EP ON EP.PKIdEstatusPeriodo = PC.FKIdEstatus_ALMA
           WHERE C.FKIdTipoBien_ALMA = P.FKIdTipoBien_ALMA
             AND C.Activo = 1
             AND UPPER(LTRIM(RTRIM(EP.Nombre))) IN ('PENDIENTE', 'EN PROCESO', 'COMPLETADO'));

    DECLARE @Generados INT = @@ROWCOUNT;

    UPDATE PC
       SET TotalArticulos = (SELECT COUNT(*) FROM ALMA.Conteo C WHERE C.FKIdPeriodoConteo_ALMA = PC.PKIdPeriodoConteo AND C.Activo = 1),
           FechaModificacion = SYSDATETIME(),
           UsuarioModificacion = @UsuarioActual
    FROM ALMA.PeriodoConteo PC
    WHERE PC.PKIdPeriodoConteo = @PKIdPeriodoConteo;

    SELECT @Generados AS ConteosGenerados;
END;
GO

COMMIT TRANSACTION;
