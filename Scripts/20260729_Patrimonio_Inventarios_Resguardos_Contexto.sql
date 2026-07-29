SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/*
   Patrimonio: barreras en base de datos para empresa, ejercicio y flujo.
   Los servicios ya imponen el contexto de sesión; estas validaciones protegen
   también invocaciones directas a los procedimientos.
*/
CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoCalendarioInventario
    @Action INT,
    @PKIdCalendarioInventario INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @Anio INT = NULL,
    @Descripcion NVARCHAR(300) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Folio NVARCHAR(30), @Consecutivo INT, @Msg NVARCHAR(4000);

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3)
            THROW 50001, N'Acción de calendario no válida.', 1;

        IF @Action IN (1, 2)
        BEGIN
            IF @FKIdEmpresa_SIS IS NULL OR @FKIdArea_SIS IS NULL OR @Anio IS NULL OR @FechaInicio IS NULL OR @FechaFin IS NULL
                THROW 50001, N'Empresa, área, ejercicio y fechas son requeridos.', 1;

            IF YEAR(@FechaInicio) <> @Anio OR YEAR(@FechaFin) <> @Anio OR @FechaFin < @FechaInicio
                THROW 50001, N'El periodo debe ser válido y corresponder al ejercicio presupuestal.', 1;

            IF EXISTS
            (
                SELECT 1
                FROM ALMA.CalendarioInventario c WITH (UPDLOCK, HOLDLOCK)
                WHERE c.Activo = 1
                  AND c.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
                  AND c.FKIdArea_SIS = @FKIdArea_SIS
                  AND c.Anio = @Anio
                  AND c.PKIdCalendarioInventario <> ISNULL(@PKIdCalendarioInventario, 0)
                  AND c.FechaInicio <= @FechaFin
                  AND c.FechaFin >= @FechaInicio
            )
                THROW 50001, N'Ya existe un calendario activo traslapado para el área y ejercicio.', 1;
        END

        IF @Action = 1
        BEGIN
            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, RIGHT(Folio, 5))), 0) + 1
            FROM ALMA.CalendarioInventario WITH (UPDLOCK, HOLDLOCK)
            WHERE FKIdEmpresa_SIS = @FKIdEmpresa_SIS
              AND Folio LIKE CONCAT(N'CAL-', @Anio, N'-%');

            SET @Folio = CONCAT(N'CAL-', @Anio, N'-', RIGHT(CONCAT(N'00000', @Consecutivo), 5));

            INSERT INTO ALMA.CalendarioInventario
                (FKIdEmpresa_SIS, FKIdArea_SIS, Anio, Folio, Descripcion, FechaInicio, FechaFin, Observaciones, UsuarioCreacion)
            VALUES
                (@FKIdEmpresa_SIS, @FKIdArea_SIS, @Anio, @Folio, @Descripcion, @FechaInicio, @FechaFin, @Observaciones, @IdUser);

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Calendario creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            UPDATE ALMA.CalendarioInventario
            SET FKIdArea_SIS = @FKIdArea_SIS,
                Anio = @Anio,
                Descripcion = @Descripcion,
                FechaInicio = @FechaInicio,
                FechaFin = @FechaFin,
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdCalendarioInventario = @PKIdCalendarioInventario
              AND FKIdEmpresa_SIS = @FKIdEmpresa_SIS
              AND Activo = 1;

            IF @@ROWCOUNT = 0
                THROW 50001, N'El calendario no existe, está inactivo o no pertenece a la empresa.', 1;

            SET @Id = @PKIdCalendarioInventario;
            SET @Msg = N'Calendario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            UPDATE ALMA.CalendarioInventario
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdCalendarioInventario = @PKIdCalendarioInventario
              AND FKIdEmpresa_SIS = @FKIdEmpresa_SIS
              AND Activo = 1;

            IF @@ROWCOUNT = 0
                THROW 50001, N'El calendario no existe, está inactivo o no pertenece a la empresa.', 1;

            SET @Id = @PKIdCalendarioInventario;
            SET @Msg = N'Calendario eliminado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoInventario
    @Action INT,
    @PKIdInventario INT = NULL,
    @FKIdEmpresa_SIS INT = NULL,
    @FKIdCalendarioInventario_ALMA INT = NULL,
    @FKIdArea_SIS INT = NULL,
    @FKIdEstatusInventario_ALMA INT = NULL,
    @FechaInventario DATE = NULL,
    @Responsable NVARCHAR(250) = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Folio NVARCHAR(30), @Consecutivo INT, @Anio INT, @Msg NVARCHAR(4000), @EstatusFinal INT;

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3, 4)
            THROW 50002, N'Acción de inventario no válida.', 1;

        IF @Action IN (1, 2)
        BEGIN
            SELECT @Anio = c.Anio
            FROM ALMA.CalendarioInventario c
            WHERE c.PKIdCalendarioInventario = @FKIdCalendarioInventario_ALMA
              AND c.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
              AND c.Activo = 1
              AND c.FKIdArea_SIS = @FKIdArea_SIS;

            IF @Anio IS NULL
                THROW 50002, N'El calendario no pertenece a la empresa o área indicada.', 1;

            IF @FechaInventario IS NULL OR YEAR(@FechaInventario) <> @Anio OR NOT EXISTS
            (
                SELECT 1 FROM ALMA.CalendarioInventario c
                WHERE c.PKIdCalendarioInventario = @FKIdCalendarioInventario_ALMA
                  AND @FechaInventario BETWEEN c.FechaInicio AND c.FechaFin
            )
                THROW 50002, N'La fecha del inventario debe estar dentro del calendario y ejercicio seleccionados.', 1;
        END

        IF @Action = 1
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM ALMA.EstatusInventario WHERE PKIdEstatusInventario = @FKIdEstatusInventario_ALMA AND Activo = 1 AND EsFinal = 0)
                THROW 50002, N'El inventario debe iniciar con un estatus activo no final.', 1;

            SELECT @Consecutivo = ISNULL(MAX(TRY_CONVERT(INT, RIGHT(Folio, 5))), 0) + 1
            FROM ALMA.Inventario WITH (UPDLOCK, HOLDLOCK)
            WHERE FKIdEmpresa_SIS = @FKIdEmpresa_SIS
              AND Folio LIKE CONCAT(N'INV-', @Anio, N'-%');

            SET @Folio = CONCAT(N'INV-', @Anio, N'-', RIGHT(CONCAT(N'00000', @Consecutivo), 5));

            INSERT INTO ALMA.Inventario
                (FKIdEmpresa_SIS, FKIdCalendarioInventario_ALMA, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                 Folio, FechaInventario, Responsable, Observaciones, UsuarioCreacion)
            VALUES
                (@FKIdEmpresa_SIS, @FKIdCalendarioInventario_ALMA, @FKIdArea_SIS, @FKIdEstatusInventario_ALMA,
                 @Folio, @FechaInventario, @Responsable, @Observaciones, @IdUser);

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Inventario creado correctamente.';
        END

        IF @Action = 2
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM ALMA.Inventario i
                JOIN ALMA.EstatusInventario e ON e.PKIdEstatusInventario = i.FKIdEstatusInventario_ALMA
                WHERE i.PKIdInventario = @PKIdInventario
                  AND i.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
                  AND i.Activo = 1
                  AND i.Autorizado = 0
                  AND e.EsFinal = 0
                  AND i.FKIdEstatusInventario_ALMA = @FKIdEstatusInventario_ALMA
            )
                THROW 50002, N'El inventario está finalizado, no pertenece a la empresa o su estatus no puede cambiarse por edición.', 1;

            INSERT INTO HIS.Inventario_Hist
                (FKIdInventario_ALMA, AccionHist, Folio, FKIdEmpresa_SIS, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                 FechaInventario, Responsable, Observaciones, TotalBienes, TotalLocalizados, TotalDiferencias,
                 Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion, UsuarioHist)
            SELECT PKIdInventario, N'UPDATE', Folio, FKIdEmpresa_SIS, FKIdArea_SIS, FKIdEstatusInventario_ALMA,
                   FechaInventario, Responsable, Observaciones, TotalBienes, TotalLocalizados, TotalDiferencias,
                   Activo, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion, @IdUser
            FROM ALMA.Inventario WHERE PKIdInventario = @PKIdInventario;

            UPDATE ALMA.Inventario
            SET FKIdCalendarioInventario_ALMA = @FKIdCalendarioInventario_ALMA,
                FKIdArea_SIS = @FKIdArea_SIS,
                FechaInventario = @FechaInventario,
                Responsable = @Responsable,
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdInventario = @PKIdInventario AND FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND Activo = 1;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1 FROM ALMA.Inventario i
                JOIN ALMA.EstatusInventario e ON e.PKIdEstatusInventario = i.FKIdEstatusInventario_ALMA
                WHERE i.PKIdInventario = @PKIdInventario AND i.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
                  AND i.Activo = 1 AND i.Autorizado = 0 AND e.EsFinal = 0
            )
                THROW 50002, N'El inventario está finalizado, no pertenece a la empresa o no puede eliminarse.', 1;

            UPDATE ALMA.Inventario
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdInventario = @PKIdInventario AND FKIdEmpresa_SIS = @FKIdEmpresa_SIS AND Activo = 1;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario eliminado correctamente.';
        END

        IF @Action = 4
        BEGIN
            SELECT TOP (1) @EstatusFinal = PKIdEstatusInventario
            FROM ALMA.EstatusInventario
            WHERE Activo = 1 AND EsFinal = 1
            ORDER BY Orden, PKIdEstatusInventario;

            IF @EstatusFinal IS NULL
                THROW 50002, N'No existe un estatus final activo para inventarios.', 1;

            IF NOT EXISTS
            (
                SELECT 1 FROM ALMA.Inventario i
                JOIN ALMA.EstatusInventario e ON e.PKIdEstatusInventario = i.FKIdEstatusInventario_ALMA
                WHERE i.PKIdInventario = @PKIdInventario AND i.FKIdEmpresa_SIS = @FKIdEmpresa_SIS
                  AND i.Activo = 1 AND i.Autorizado = 0 AND e.EsFinal = 0
            )
                THROW 50002, N'El inventario ya está finalizado o no pertenece a la empresa.', 1;

            IF NOT EXISTS (SELECT 1 FROM ALMA.InventarioDetalle WHERE FKIdInventario_ALMA = @PKIdInventario AND Activo = 1)
                THROW 50002, N'El inventario debe incluir al menos un bien antes de autorizarse.', 1;

            UPDATE i
            SET TotalBienes = x.TotalBienes,
                TotalLocalizados = x.TotalLocalizados,
                TotalDiferencias = x.TotalDiferencias,
                FKIdEstatusInventario_ALMA = @EstatusFinal,
                Autorizado = 1,
                FechaAutorizacion = SYSDATETIME(),
                UsuarioAutorizacion = @IdUser,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            FROM ALMA.Inventario i
            CROSS APPLY
            (
                SELECT COUNT(1) TotalBienes,
                       SUM(CASE WHEN Localizado = 1 THEN 1 ELSE 0 END) TotalLocalizados,
                       SUM(CASE WHEN TieneDiferencia = 1 THEN 1 ELSE 0 END) TotalDiferencias
                FROM ALMA.InventarioDetalle d
                WHERE d.FKIdInventario_ALMA = i.PKIdInventario AND d.Activo = 1
            ) x
            WHERE i.PKIdInventario = @PKIdInventario AND i.FKIdEmpresa_SIS = @FKIdEmpresa_SIS;

            SET @Id = @PKIdInventario;
            SET @Msg = N'Inventario autorizado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ALMA.SP_MantenimientoInventarioDetalle
    @Action INT,
    @PKIdInventarioDetalle INT = NULL,
    @FKIdInventario_ALMA INT = NULL,
    @FKIdBien_ALMA INT = NULL,
    @UbicacionSistema NVARCHAR(250) = NULL,
    @UbicacionFisica NVARCHAR(250) = NULL,
    @Localizado BIT = NULL,
    @TieneDiferencia BIT = NULL,
    @Observaciones NVARCHAR(1000) = NULL,
    @IdUser INT,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Msg NVARCHAR(4000), @EmpresaInventario INT;

    BEGIN TRY
        IF @Action NOT IN (1, 2, 3)
            THROW 50003, N'Acción de detalle de inventario no válida.', 1;

        IF @Action = 1
        BEGIN
            SELECT @EmpresaInventario = i.FKIdEmpresa_SIS
            FROM ALMA.Inventario i
            JOIN ALMA.EstatusInventario e ON e.PKIdEstatusInventario = i.FKIdEstatusInventario_ALMA
            WHERE i.PKIdInventario = @FKIdInventario_ALMA AND i.Activo = 1 AND i.Autorizado = 0 AND e.EsFinal = 0;

            IF @EmpresaInventario IS NULL
                THROW 50003, N'El inventario no existe, está finalizado o no permite modificaciones.', 1;

            IF NOT EXISTS (SELECT 1 FROM ALMA.Bien WHERE PKIdBien = @FKIdBien_ALMA AND Activo = 1 AND FKIdEmpresa_SIS = @EmpresaInventario)
                THROW 50003, N'El bien no existe, está inactivo o pertenece a otra empresa.', 1;

            IF EXISTS (SELECT 1 FROM ALMA.InventarioDetalle WHERE FKIdInventario_ALMA = @FKIdInventario_ALMA AND FKIdBien_ALMA = @FKIdBien_ALMA AND Activo = 1)
                THROW 50003, N'El bien ya está agregado al inventario.', 1;

            INSERT INTO ALMA.InventarioDetalle
                (FKIdInventario_ALMA, FKIdBien_ALMA, ClaveBien, DescripcionBien, Serie,
                 UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia, Observaciones, UsuarioCreacion)
            SELECT @FKIdInventario_ALMA, b.PKIdBien, b.Clave, b.Descripcion, b.Serie,
                   @UbicacionSistema, @UbicacionFisica, ISNULL(@Localizado,0), ISNULL(@TieneDiferencia,0), @Observaciones, @IdUser
            FROM ALMA.Bien b WHERE b.PKIdBien = @FKIdBien_ALMA;

            SET @Id = SCOPE_IDENTITY();
            SET @Msg = N'Detalle de inventario creado correctamente.';
        END

        IF @Action IN (2, 3)
        BEGIN
            SELECT @EmpresaInventario = i.FKIdEmpresa_SIS
            FROM ALMA.InventarioDetalle d
            JOIN ALMA.Inventario i ON i.PKIdInventario = d.FKIdInventario_ALMA
            JOIN ALMA.EstatusInventario e ON e.PKIdEstatusInventario = i.FKIdEstatusInventario_ALMA
            WHERE d.PKIdInventarioDetalle = @PKIdInventarioDetalle AND d.Activo = 1
              AND i.Activo = 1 AND i.Autorizado = 0 AND e.EsFinal = 0;

            IF @EmpresaInventario IS NULL
                THROW 50003, N'El detalle no existe o el inventario ya está finalizado.', 1;
        END

        IF @Action = 2
        BEGIN
            INSERT INTO HIS.InventarioDet_Hist
                (FKIdInventarioDetalle_ALMA, FKIdInventario_ALMA, FKIdBien_ALMA, AccionHist, ClaveBien,
                 DescripcionBien, Serie, UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia,
                 Observaciones, Activo, UsuarioHist)
            SELECT PKIdInventarioDetalle, FKIdInventario_ALMA, FKIdBien_ALMA, N'UPDATE', ClaveBien,
                   DescripcionBien, Serie, UbicacionSistema, UbicacionFisica, Localizado, TieneDiferencia,
                   Observaciones, Activo, @IdUser
            FROM ALMA.InventarioDetalle WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle;

            UPDATE ALMA.InventarioDetalle
            SET UbicacionSistema = @UbicacionSistema,
                UbicacionFisica = @UbicacionFisica,
                Localizado = ISNULL(@Localizado, Localizado),
                TieneDiferencia = ISNULL(@TieneDiferencia, TieneDiferencia),
                Observaciones = @Observaciones,
                FechaModificacion = SYSDATETIME(),
                UsuarioModificacion = @IdUser
            WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle AND Activo = 1;

            SET @Id = @PKIdInventarioDetalle;
            SET @Msg = N'Detalle de inventario actualizado correctamente.';
        END

        IF @Action = 3
        BEGIN
            UPDATE ALMA.InventarioDetalle
            SET Activo = 0, FechaModificacion = SYSDATETIME(), UsuarioModificacion = @IdUser
            WHERE PKIdInventarioDetalle = @PKIdInventarioDetalle AND Activo = 1;

            SET @Id = @PKIdInventarioDetalle;
            SET @Msg = N'Detalle de inventario eliminado correctamente.';
        END

        SELECT ResultJson = (SELECT N'success' AS Tipo, @Msg AS Mensaje, CONCAT(N'id:', @Id) AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END TRY
    BEGIN CATCH
        SELECT ResultJson = (SELECT N'error' AS Tipo, ERROR_MESSAGE() AS Mensaje, NULL AS Liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    END CATCH
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.CalendarioInventario') AND name = N'IX_CalendarioInventario_ContextoPeriodo')
    CREATE INDEX IX_CalendarioInventario_ContextoPeriodo
        ON ALMA.CalendarioInventario(FKIdEmpresa_SIS, Anio, FKIdArea_SIS, FechaInicio, FechaFin)
        WHERE Activo = 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.Inventario') AND name = N'IX_Inventario_ContextoCalendario')
    CREATE INDEX IX_Inventario_ContextoCalendario
        ON ALMA.Inventario(FKIdEmpresa_SIS, FKIdCalendarioInventario_ALMA, FKIdArea_SIS)
        WHERE Activo = 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ALMA.InventarioDetalle') AND name = N'UX_InventarioDetalle_InventarioBienActivo')
    CREATE UNIQUE INDEX UX_InventarioDetalle_InventarioBienActivo
        ON ALMA.InventarioDetalle(FKIdInventario_ALMA, FKIdBien_ALMA)
        WHERE Activo = 1;
GO
