SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF SCHEMA_ID(N'NOM') IS NULL
    EXEC(N'CREATE SCHEMA [NOM]');
GO

CREATE OR ALTER VIEW [NOM].[Vw_InveaNominaActualCompat]
AS
SELECT
    D.PKIdCorridaNominaDetalle AS Pk_IdSueldo,
    D.EmpresaNominaId AS Fk_IdEmpresa__EMP,
    D.EmpresaNominaNombre AS RazonSocial,
    D.PersonaId AS Fk_IdPersona__RH,
    D.PersonaClaveNombre AS Empleado,
    D.ContratoLaboralId AS Fk_IdContrato,
    D.PuestoId AS Fk_IdPuesto,
    D.PuestoNombre,
    D.IdPeriodo AS Fk_IdPeriodo,
    D.Anio AS [Anio],
    PN.Mes AS MesPago,
    PN.Periodo AS NumPeriodo,
    PN.FechaInicio AS F_Inicio,
    PN.FechaFin AS F_Fin,
    D.ConceptoId AS Fk_IdConcepto__NOM,
    D.ConceptoClave AS Clave,
    CAST(NULL AS nvarchar(40)) AS SubClave,
    D.ConceptoNombre AS Concepto,
    CAST(CASE
        WHEN D.TipoMovimiento = N'Percepcion' THEN N'P'
        WHEN D.TipoMovimiento = N'Deduccion' THEN N'D'
        ELSE N'A'
    END AS nchar(2)) AS PerDed,
    D.Percepcion,
    D.Deduccion,
    D.Aportacion,
    D.Neto,
    D.Referencia,
    D.Origen,
    D.TipoCorrida,
    D.Estatus,
    D.Activo,
    D.FechaCreacion,
    D.UsuarioCreacion
FROM [NOM].[Vw_CorridaNominaDetalle] D
LEFT JOIN [NOM].[PeriodoNomina] PN
    ON PN.PKIdPeriodoNomina = D.IdPeriodo;
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_INVEA_GetContext]
    @EmpresaId INT,
    @PeriodoId INT OUTPUT,
    @Anio INT OUTPUT,
    @FechaProceso DATE OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        @PeriodoId = PA.IdPeriodo
    FROM [NOM].[PeriodoActivo] PA
    WHERE PA.FKIdEmpresa_SIS = @EmpresaId
      AND ISNULL(PA.Activo, 1) = 1
      AND ISNULL(PA.EstaCerrado, 0) = 0
    ORDER BY PA.PKIdPeriodoActivo DESC;

    SELECT
        @Anio = COALESCE(PN.Anio, YEAR(GETDATE())),
        @FechaProceso = COALESCE(PN.FechaFin, CONVERT(date, GETDATE()))
    FROM [NOM].[PeriodoNomina] PN
    WHERE PN.PKIdPeriodoNomina = @PeriodoId;

    SET @Anio = COALESCE(@Anio, YEAR(GETDATE()));
    SET @FechaProceso = COALESCE(@FechaProceso, CONVERT(date, GETDATE()));
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_INVEA_Resultado]
    @Proceso nvarchar(200),
    @Codigo nvarchar(80),
    @Ejecutado bit,
    @Mensaje nvarchar(1000),
    @CorridaId int = NULL,
    @EmpresaId int = NULL,
    @PeriodoId int = NULL,
    @Anio int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @CorridaId AS CorridaId,
        @EmpresaId AS EmpresaId,
        CAST(NULL AS nvarchar(255)) AS EmpresaNombre,
        @PeriodoId AS PeriodoId,
        @Anio AS Anio,
        CAST(0 AS int) AS TotalPersonas,
        CAST(0 AS int) AS TotalMovimientos,
        CAST(0 AS decimal(19,4)) AS TotalPercepcion,
        CAST(0 AS decimal(19,4)) AS TotalDeduccion,
        CAST(0 AS decimal(19,4)) AS TotalAportacion,
        CAST(0 AS decimal(19,4)) AS TotalNeto,
        @Proceso AS Proceso,
        @Codigo AS Codigo,
        @Ejecutado AS Ejecutado,
        SYSDATETIME() AS FechaIntento,
        @Mensaje AS Mensaje;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_INVEA_EjecutaCalculo]
    @EmpresaId INT,
    @Proceso nvarchar(200),
    @PeriodoId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CtxPeriodoId INT = @PeriodoId,
            @Anio INT = NULL,
            @FechaProceso DATE = NULL;

    EXEC [NOM].[NOM_INVEA_GetContext]
        @EmpresaId = @EmpresaId,
        @PeriodoId = @CtxPeriodoId OUTPUT,
        @Anio = @Anio OUTPUT,
        @FechaProceso = @FechaProceso OUTPUT;

    IF OBJECT_ID(N'[NOM].[spProcesoNomina_Calcular]', N'P') IS NOT NULL
    BEGIN
        EXEC [NOM].[spProcesoNomina_Calcular]
            @EmpresaId = @EmpresaId,
            @PeriodoId = @CtxPeriodoId,
            @PersonaId = NULL,
            @Anio = @Anio,
            @FechaProceso = @FechaProceso,
            @Observaciones = @Proceso,
            @UsuarioId = NULL;
        RETURN;
    END

    EXEC [NOM].[NOM_INVEA_Resultado]
        @Proceso = @Proceso,
        @Codigo = N'NO_ENGINE',
        @Ejecutado = 0,
        @Mensaje = N'El procedimiento normalizado NOM.spProcesoNomina_Calcular no existe en esta base.',
        @EmpresaId = @EmpresaId,
        @PeriodoId = @CtxPeriodoId,
        @Anio = @Anio;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_INVEA_EjecutaCierre]
    @EmpresaId INT,
    @Proceso nvarchar(200),
    @PeriodoId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CtxPeriodoId INT = @PeriodoId,
            @Anio INT = NULL,
            @FechaProceso DATE = NULL;

    EXEC [NOM].[NOM_INVEA_GetContext]
        @EmpresaId = @EmpresaId,
        @PeriodoId = @CtxPeriodoId OUTPUT,
        @Anio = @Anio OUTPUT,
        @FechaProceso = @FechaProceso OUTPUT;

    IF OBJECT_ID(N'[NOM].[spProcesoNomina_CerrarPeriodo]', N'P') IS NOT NULL
    BEGIN
        EXEC [NOM].[spProcesoNomina_CerrarPeriodo]
            @EmpresaId = @EmpresaId,
            @PeriodoId = @CtxPeriodoId,
            @PersonaId = NULL,
            @Anio = @Anio,
            @FechaProceso = @FechaProceso,
            @Observaciones = @Proceso,
            @UsuarioId = NULL;
        RETURN;
    END

    EXEC [NOM].[NOM_INVEA_Resultado]
        @Proceso = @Proceso,
        @Codigo = N'NO_ENGINE',
        @Ejecutado = 0,
        @Mensaje = N'El procedimiento normalizado NOM.spProcesoNomina_CerrarPeriodo no existe en esta base.',
        @EmpresaId = @EmpresaId,
        @PeriodoId = @CtxPeriodoId,
        @Anio = @Anio;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_INVEA_EjecutaAguinaldo]
    @EmpresaId INT,
    @PeriodoId INT,
    @FechaProceso DATE,
    @Proceso nvarchar(200)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Anio INT = YEAR(COALESCE(@FechaProceso, GETDATE()));

    IF OBJECT_ID(N'[NOM].[spProcesoNomina_CalcularAguinaldo]', N'P') IS NOT NULL
    BEGIN
        EXEC [NOM].[spProcesoNomina_CalcularAguinaldo]
            @EmpresaId = @EmpresaId,
            @PeriodoId = @PeriodoId,
            @PersonaId = NULL,
            @Anio = @Anio,
            @FechaProceso = @FechaProceso,
            @Observaciones = @Proceso,
            @UsuarioId = NULL;
        RETURN;
    END

    EXEC [NOM].[NOM_INVEA_Resultado]
        @Proceso = @Proceso,
        @Codigo = N'NO_ENGINE',
        @Ejecutado = 0,
        @Mensaje = N'El procedimiento normalizado NOM.spProcesoNomina_CalcularAguinaldo no existe en esta base.',
        @EmpresaId = @EmpresaId,
        @PeriodoId = @PeriodoId,
        @Anio = @Anio;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_INVEA_EjecutaPrimaVacacional]
    @EmpresaId INT,
    @PeriodoId INT = NULL,
    @Proceso nvarchar(200)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CtxPeriodoId INT = @PeriodoId,
            @Anio INT = NULL,
            @FechaProceso DATE = NULL;

    EXEC [NOM].[NOM_INVEA_GetContext]
        @EmpresaId = @EmpresaId,
        @PeriodoId = @CtxPeriodoId OUTPUT,
        @Anio = @Anio OUTPUT,
        @FechaProceso = @FechaProceso OUTPUT;

    IF OBJECT_ID(N'[NOM].[spProcesoNomina_PrimaVacacionalIndividual]', N'P') IS NOT NULL
    BEGIN
        EXEC [NOM].[spProcesoNomina_PrimaVacacionalIndividual]
            @EmpresaId = @EmpresaId,
            @PeriodoId = @CtxPeriodoId,
            @PersonaId = NULL,
            @Anio = @Anio,
            @FechaProceso = @FechaProceso,
            @Observaciones = @Proceso,
            @UsuarioId = NULL;
        RETURN;
    END

    EXEC [NOM].[NOM_INVEA_Resultado]
        @Proceso = @Proceso,
        @Codigo = N'NO_ENGINE',
        @Ejecutado = 0,
        @Mensaje = N'El procedimiento normalizado NOM.spProcesoNomina_PrimaVacacionalIndividual no existe en esta base.',
        @EmpresaId = @EmpresaId,
        @PeriodoId = @CtxPeriodoId,
        @Anio = @Anio;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_FaltasActualXEmpresa]
    @p_Fk_IdEmpresa INT,
    @p_NumPeriodo INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT I.*
    FROM [NOM].[Vw_Incidencia] I
    JOIN [NOM].[ContratoLaboral] C ON C.FKIdPersona_NOM = I.FKIdPersona_NOM
    WHERE C.FKIdEmpresa_SIS = @p_Fk_IdEmpresa
      AND I.FKIdPeriodoQuincenal_SIS = @p_NumPeriodo
      AND ISNULL(I.AplicaDescuento, 0) = 1
      AND ISNULL(I.Activo, 1) = 1;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_FaltasAnualXEmpresa]
    @p_Fk_IdEmpresa INT,
    @p_Anio INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT I.*
    FROM [NOM].[Vw_Incidencia] I
    JOIN [NOM].[ContratoLaboral] C ON C.FKIdPersona_NOM = I.FKIdPersona_NOM
    WHERE C.FKIdEmpresa_SIS = @p_Fk_IdEmpresa
      AND YEAR(I.Fecha) = @p_Anio
      AND ISNULL(I.AplicaDescuento, 0) = 1
      AND ISNULL(I.Activo, 1) = 1;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SBC_ActualXEmpresa]
    @p_Fk_IdEmpresa INT,
    @p_NumPeriodo INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.PKIdContratoLaboral AS Fk_IdContrato,
        C.FKIdEmpresa_SIS AS Fk_IdEmpresa__EMP,
        C.FKIdPersona_NOM AS Fk_IdPersona__RH,
        @p_NumPeriodo AS Fk_IdPeriodo,
        C.SueldoMensual,
        CAST(C.SueldoMensual / 30.0 AS decimal(19,4)) AS SalarioDiario,
        CAST(C.SueldoMensual / 30.0 AS decimal(19,4)) AS SBC,
        C.Activo
    FROM [NOM].[ContratoLaboral] C
    WHERE C.FKIdEmpresa_SIS = @p_Fk_IdEmpresa
      AND ISNULL(C.Activo, 1) = 1;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SD_IMSS]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_SBC_ActualXEmpresa] @p_Fk_IdEmpresa = @p_Fk_IdEmpresa, @p_NumPeriodo = NULL;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SD_IMSS_Quincenal]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_SBC_ActualXEmpresa] @p_Fk_IdEmpresa = @p_Fk_IdEmpresa, @p_NumPeriodo = NULL;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SD_ISR_LiqFiniq]
    @p_idContrato INT,
    @p_IdConcepto INT,
    @p_FechaFinContrato DATE,
    @p_BaseGravable FLOAT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @p_idContrato AS Fk_IdContrato,
        @p_IdConcepto AS Fk_IdConcepto__NOM,
        @p_FechaFinContrato AS FechaFinContrato,
        CAST(@p_BaseGravable AS decimal(19,4)) AS BaseGravable,
        CAST(CASE WHEN @p_BaseGravable > 0 THEN @p_BaseGravable * 0.10 ELSE 0 END AS decimal(19,4)) AS ISR_Estimado,
        N'Compatibilidad SQL Server: calculo estimado, no tabla ISR legacy.' AS Observaciones;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SD_ISR_Quincenal]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SD_ISR_Quincenal';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SD_ISR_Quincenal_Par]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SD_ISR_Quincenal_Par';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SD_ISSSTE]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_SBC_ActualXEmpresa] @p_Fk_IdEmpresa = @p_Fk_IdEmpresa, @p_NumPeriodo = NULL;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SPR_AuxIMSSActual]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [NOM].[Vw_InveaNominaActualCompat]
    WHERE Fk_IdEmpresa__EMP = @p_Fk_IdEmpresa
      AND PerDed = N'A'
      AND ISNULL(Activo, 1) = 1;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SPR_ConceptoActual]
    @p_Fk_IdEmpresa INT,
    @p_Fk_IdConcepto INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [NOM].[Vw_InveaNominaActualCompat]
    WHERE Fk_IdEmpresa__EMP = @p_Fk_IdEmpresa
      AND Fk_IdConcepto__NOM = @p_Fk_IdConcepto
      AND ISNULL(Activo, 1) = 1;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SPR_ISRActual]
    @p_Fk_IdEmpresa INT,
    @p_Fk_IdConceptoISR INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [NOM].[Vw_InveaNominaActualCompat]
    WHERE Fk_IdEmpresa__EMP = @p_Fk_IdEmpresa
      AND Fk_IdConcepto__NOM = @p_Fk_IdConceptoISR
      AND PerDed = N'D'
      AND ISNULL(Activo, 1) = 1;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SPR_NominaActual]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PeriodoId INT = NULL, @Anio INT = NULL, @FechaProceso DATE = NULL;
    EXEC [NOM].[NOM_INVEA_GetContext] @EmpresaId = @p_Fk_IdEmpresa, @PeriodoId = @PeriodoId OUTPUT, @Anio = @Anio OUTPUT, @FechaProceso = @FechaProceso OUTPUT;

    SELECT *
    FROM [NOM].[Vw_InveaNominaActualCompat]
    WHERE Fk_IdEmpresa__EMP = @p_Fk_IdEmpresa
      AND (@PeriodoId IS NULL OR Fk_IdPeriodo = @PeriodoId)
      AND ISNULL(Activo, 1) = 1;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SPR_ReciboNomina]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PeriodoId INT = NULL, @Anio INT = NULL, @FechaProceso DATE = NULL;
    EXEC [NOM].[NOM_INVEA_GetContext] @EmpresaId = @p_Fk_IdEmpresa, @PeriodoId = @PeriodoId OUTPUT, @Anio = @Anio OUTPUT, @FechaProceso = @FechaProceso OUTPUT;

    SELECT *
    FROM [NOM].[Vw_InveaNominaActualCompat]
    WHERE Fk_IdEmpresa__EMP = @p_Fk_IdEmpresa
      AND (@PeriodoId IS NULL OR Fk_IdPeriodo = @PeriodoId)
      AND PerDed IN (N'P', N'D')
      AND ISNULL(Activo, 1) = 1;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Actualiza_SBC]
    @p_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;

    EXEC [NOM].[NOM_SBC_ActualXEmpresa] @p_Fk_IdEmpresa = @p_IdEmpresa, @p_NumPeriodo = NULL;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_CalculaAguinaldo]
    @p_idNominaEspecial INT,
    @p_Fk_IdEmpresa__EMP INT,
    @p_FechaPagoAguinaldo DATE
AS
BEGIN
    SET NOCOUNT ON;

    EXEC [NOM].[NOM_INVEA_EjecutaAguinaldo]
        @EmpresaId = @p_Fk_IdEmpresa__EMP,
        @PeriodoId = @p_idNominaEspecial,
        @FechaProceso = @p_FechaPagoAguinaldo,
        @Proceso = N'NOM_SP_CalculaAguinaldo';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_CalculaLiqFin]
    @p_idContrato INT,
    @p_DiasPendientesPago INT,
    @p_FechaInicioParaAguinaldo DATE,
    @p_FechaBaja DATE,
    @p_DiasDeVacacionesParaCalculo INT,
    @p_SaldoPendientedeVacaciones FLOAT,
    @p_EsLiquidacion BIT,
    @p_VacacionesEjercicioAnt FLOAT,
    @p_DescuentosXFaltas INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SueldoMensual decimal(19,4) = 0,
            @SalarioDiario decimal(19,4) = 0,
            @LiquidacionId int = NULL;

    SELECT @SueldoMensual = CAST(SueldoMensual AS decimal(19,4))
    FROM [NOM].[ContratoLaboral]
    WHERE PKIdContratoLaboral = @p_idContrato;

    SET @SalarioDiario = CAST(COALESCE(@SueldoMensual, 0) / 30.0 AS decimal(19,4));

    INSERT INTO [NOM].[Liquidacion]
    (
        FKIdContrato_PRES,
        DiasPendientesPago,
        FechaInicioParaAguinaldo,
        FechaBaja,
        DiasDeVacacionesParaCalculo,
        SaldoPendienteVacaciones,
        BasePorDisminuir,
        SalarioDiarioBruto,
        SalarioDiarioIntegrado,
        FactorIntegracion,
        VariableDiaria,
        DiasAguinaldo,
        DiasVacaciones,
        PrimaVacacional,
        FechaUltimoAniversario,
        AnioAntiguedad,
        DiasPrima,
        SalarioDiarioIntegradoLiquidacion,
        EsLiquidacion,
        VacacionesEjercicioAnt,
        DescuentosXFaltas,
        UsuarioCreacion,
        FechaCreacion,
        Activo
    )
    VALUES
    (
        @p_idContrato,
        @p_DiasPendientesPago,
        @p_FechaInicioParaAguinaldo,
        @p_FechaBaja,
        @p_DiasDeVacacionesParaCalculo,
        CAST(@p_SaldoPendientedeVacaciones AS decimal(19,4)),
        0,
        @SalarioDiario,
        @SalarioDiario,
        1,
        0,
        CASE WHEN @p_FechaInicioParaAguinaldo IS NULL OR @p_FechaBaja IS NULL THEN 0 ELSE DATEDIFF(day, @p_FechaInicioParaAguinaldo, @p_FechaBaja) * 15.0 / 365.0 END,
        @p_DiasDeVacacionesParaCalculo,
        CAST(COALESCE(@p_SaldoPendientedeVacaciones, 0) * 0.25 AS decimal(19,4)),
        NULL,
        NULL,
        NULL,
        @SalarioDiario,
        @p_EsLiquidacion,
        CAST(@p_VacacionesEjercicioAnt AS decimal(19,4)),
        @p_DescuentosXFaltas,
        NULL,
        SYSDATETIME(),
        1
    );

    SET @LiquidacionId = SCOPE_IDENTITY();

    SELECT *
    FROM [NOM].[Liquidacion]
    WHERE PKIdLiquidacion = @LiquidacionId;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_CierraPeriodo]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCierre] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_CierraPeriodo';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Cierra_Mes]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCierre] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Cierra_Mes';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Cierra_Quincena]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCierre] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Cierra_Quincena';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Cierra_Semana]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCierre] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Cierra_Semana';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Credito_Quincenal]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [NOM].[Vw_Credito]
    WHERE EmpresaId = @p_Fk_IdEmpresa
      AND ISNULL(Activo, 1) = 1;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_DELETE_LiqFin]
    @p_idLiquidacion INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ContratoId INT;

    SELECT @ContratoId = FKIdContrato_PRES
    FROM [NOM].[Liquidacion]
    WHERE PKIdLiquidacion = @p_idLiquidacion;

    UPDATE [NOM].[Liquidacion]
        SET Activo = 0,
            FechaModificacion = SYSDATETIME()
    WHERE PKIdLiquidacion = @p_idLiquidacion;

    UPDATE [NOM].[SueldoLiqFin]
        SET Activo = 0,
            FechaModificacion = SYSDATETIME()
    WHERE FKIdContrato_PRES = @ContratoId;

    EXEC [NOM].[NOM_INVEA_Resultado]
        @Proceso = N'NOM_SP_DELETE_LiqFin',
        @Codigo = N'OK',
        @Ejecutado = 1,
        @Mensaje = N'Liquidacion y movimientos de liquidacion desactivados.',
        @EmpresaId = NULL,
        @PeriodoId = NULL,
        @Anio = NULL;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Fijo_Mensual]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Fijo_Mensual';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Fijo_Quincenal]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Fijo_Quincenal';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Fijo_Semanal]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Fijo_Semanal';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Infonavit_Quincenal]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [NOM].[Vw_Infonavit]
    WHERE EmpresaId = @p_Fk_IdEmpresa
      AND ISNULL(Activo, 1) = 1;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_LimpiaMes]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PeriodoId INT = NULL, @Anio INT = NULL, @FechaProceso DATE = NULL;
    EXEC [NOM].[NOM_INVEA_GetContext] @EmpresaId = @p_Fk_IdEmpresa, @PeriodoId = @PeriodoId OUTPUT, @Anio = @Anio OUTPUT, @FechaProceso = @FechaProceso OUTPUT;

    UPDATE [NOM].[SueldoMensual]
        SET Activo = 0, FechaModificacion = SYSDATETIME()
    WHERE FKIdEmpresa_SIS = @p_Fk_IdEmpresa
      AND (@PeriodoId IS NULL OR FKIdPeriodoMensual_NOM = @PeriodoId);

    EXEC [NOM].[NOM_INVEA_Resultado] N'NOM_SP_LimpiaMes', N'OK', 1, N'Movimientos mensuales desactivados.', NULL, @p_Fk_IdEmpresa, @PeriodoId, @Anio;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_LimpiaQuincena]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PeriodoId INT = NULL, @Anio INT = NULL, @FechaProceso DATE = NULL;
    EXEC [NOM].[NOM_INVEA_GetContext] @EmpresaId = @p_Fk_IdEmpresa, @PeriodoId = @PeriodoId OUTPUT, @Anio = @Anio OUTPUT, @FechaProceso = @FechaProceso OUTPUT;

    UPDATE [NOM].[SueldoQuincenal]
        SET Activo = 0, FechaModificacion = SYSDATETIME()
    WHERE FKIdEmpresa_SIS = @p_Fk_IdEmpresa
      AND (@PeriodoId IS NULL OR FKIdPeriodoQuincenal_NOM = @PeriodoId);

    EXEC [NOM].[NOM_INVEA_Resultado] N'NOM_SP_LimpiaQuincena', N'OK', 1, N'Movimientos quincenales desactivados.', NULL, @p_Fk_IdEmpresa, @PeriodoId, @Anio;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_LimpiaSemana]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PeriodoId INT = NULL, @Anio INT = NULL, @FechaProceso DATE = NULL;
    EXEC [NOM].[NOM_INVEA_GetContext] @EmpresaId = @p_Fk_IdEmpresa, @PeriodoId = @PeriodoId OUTPUT, @Anio = @Anio OUTPUT, @FechaProceso = @FechaProceso OUTPUT;

    UPDATE [NOM].[SueldoSemanal]
        SET Activo = 0, FechaModificacion = SYSDATETIME()
    WHERE FKIdEmpresa_SIS = @p_Fk_IdEmpresa
      AND (@PeriodoId IS NULL OR FKIdPeriodoSemanal_NOM = @PeriodoId);

    EXEC [NOM].[NOM_INVEA_Resultado] N'NOM_SP_LimpiaSemana', N'OK', 1, N'Movimientos semanales desactivados.', NULL, @p_Fk_IdEmpresa, @PeriodoId, @Anio;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Nomina]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Nomina';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Pension_Quincenal]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT P.*
    FROM [NOM].[Vw_PersonaPension] P
    JOIN [NOM].[ContratoLaboral] C ON C.FKIdPersona_NOM = P.FKIdPersona_NOM
    WHERE C.FKIdEmpresa_SIS = @p_Fk_IdEmpresa
      AND ISNULL(P.Activo, 1) = 1
      AND ISNULL(C.Activo, 1) = 1;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Pension_Quincenal_INVEA]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_SP_Pension_Quincenal] @p_Fk_IdEmpresa = @p_Fk_IdEmpresa;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_PreparaAguinaldo]
    @p_idNominaEspecial INT,
    @p_Fk_IdEmpresa__EMP INT,
    @p_FechaPagoAguinaldo DATE
AS
BEGIN
    SET NOCOUNT ON;

    EXEC [NOM].[NOM_INVEA_EjecutaAguinaldo]
        @EmpresaId = @p_Fk_IdEmpresa__EMP,
        @PeriodoId = @p_idNominaEspecial,
        @FechaProceso = @p_FechaPagoAguinaldo,
        @Proceso = N'NOM_SP_PreparaAguinaldo';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_PrimaVac_Gral]
    @p_Fk_IdEmpresa INT,
    @p_NumPeriodo INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaPrimaVacacional] @EmpresaId = @p_Fk_IdEmpresa, @PeriodoId = @p_NumPeriodo, @Proceso = N'NOM_SP_PrimaVac_Gral';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_PrimaVac_Ind]
    @p_Fk_IdEmpresa INT,
    @p_NumPeriodo INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaPrimaVacacional] @EmpresaId = @p_Fk_IdEmpresa, @PeriodoId = @p_NumPeriodo, @Proceso = N'NOM_SP_PrimaVac_Ind';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Tabular_Mensual]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Tabular_Mensual';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Tabular_Quincenal]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Tabular_Quincenal';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Tabular_Semanal]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Tabular_Semanal';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Variable_Mensual]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Variable_Mensual';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Variable_Quincenal]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Variable_Quincenal';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_SP_Variable_Semanal]
    @p_Fk_IdEmpresa INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCalculo] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_SP_Variable_Semanal';
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_UTIL_Borra_QuincenaCerrada]
    @p_Fk_IdEmpresa INT,
    @p_NumPeriodo INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [NOM].[SueldoQuincenal]
        SET Activo = 0, FechaModificacion = SYSDATETIME()
    WHERE FKIdEmpresa_SIS = @p_Fk_IdEmpresa
      AND FKIdPeriodoQuincenal_NOM = @p_NumPeriodo;

    EXEC [NOM].[NOM_INVEA_Resultado] N'NOM_UTIL_Borra_QuincenaCerrada', N'OK', 1, N'Movimientos de quincena desactivados.', NULL, @p_Fk_IdEmpresa, @p_NumPeriodo, NULL;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_UTIL_Cierra_QuincenaEsp]
    @p_Fk_IdEmpresa INT,
    @p_NumPeriodo INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [NOM].[NOM_INVEA_EjecutaCierre] @EmpresaId = @p_Fk_IdEmpresa, @Proceso = N'NOM_UTIL_Cierra_QuincenaEsp', @PeriodoId = @p_NumPeriodo;
END
GO

CREATE OR ALTER PROCEDURE [NOM].[NOM_UTIL_LimpiaQuincena]
    @p_Fk_IdEmpresa INT,
    @p_NumPeriodo INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [NOM].[SueldoQuincenal]
        SET Activo = 0, FechaModificacion = SYSDATETIME()
    WHERE FKIdEmpresa_SIS = @p_Fk_IdEmpresa
      AND FKIdPeriodoQuincenal_NOM = @p_NumPeriodo;

    EXEC [NOM].[NOM_INVEA_Resultado] N'NOM_UTIL_LimpiaQuincena', N'OK', 1, N'Movimientos de quincena desactivados.', NULL, @p_Fk_IdEmpresa, @p_NumPeriodo, NULL;
END
GO
