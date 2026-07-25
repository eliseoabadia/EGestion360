SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE [ALMA].[SP_CargaInicialConteo]
    @P_Partida INT = NULL,
    @P_Periodo INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @P_Periodo IS NULL OR NOT EXISTS
    (
        SELECT 1
        FROM [ALMA].[PeriodoConteo]
        WHERE [PKIdPeriodoConteo] = @P_Periodo
          AND [Activo] = 1
    )
    BEGIN
        THROW 51013, 'El periodo de conteo es requerido y debe estar activo.', 1;
    END;

    IF @P_Partida IS NOT NULL AND (@P_Partida <= 20000 OR @P_Partida >= 30000)
    BEGIN
        THROW 51012, 'Solo se permiten partidas del capitulo 20000.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE E
        FROM [ALMA].[ConteoDetalleEscaneo] E
        INNER JOIN [ALMA].[Conteo] C ON C.[PKIdConteo] = E.[FKIdConteo_ALMA]
        WHERE C.[FKIdPeriodoConteo_ALMA] = @P_Periodo;

        DELETE D
        FROM [ALMA].[ConteoDetalle] D
        INNER JOIN [ALMA].[Conteo] C ON C.[PKIdConteo] = D.[FKIdConteo_ALMA]
        WHERE C.[FKIdPeriodoConteo_ALMA] = @P_Periodo;

        DELETE FROM [ALMA].[Conteo]
        WHERE [FKIdPeriodoConteo_ALMA] = @P_Periodo;

        INSERT INTO [ALMA].[Conteo]
        (
            [FKIdTipoBien_ALMA],
            [CantidadInventario],
            [Descripcion],
            [FechaInicio],
            [FKIdPeriodoConteo_ALMA],
            [Activo],
            [FechaCreacion],
            [UsuarioCreacion]
        )
        SELECT
            E.[PKIdTipoBien],
            SUM(ISNULL(E.[Existencias], 0)),
            MAX(E.[Descripcion]),
            SYSDATETIME(),
            @P_Periodo,
            1,
            SYSDATETIME(),
            1
        FROM [ALMA].[Vw_Existencias] E
        INNER JOIN [ALMA].[TipoBien] TB ON TB.[PKIdTipoBien] = E.[PKIdTipoBien]
        WHERE TB.[Activo] = 1
          AND TB.[FKIdPartida_CONTA] > 20000
          AND TB.[FKIdPartida_CONTA] < 30000
          AND (@P_Partida IS NULL OR TB.[FKIdPartida_CONTA] = @P_Partida)
          AND ISNULL(E.[Existencias], 0) > 0
        GROUP BY E.[PKIdTipoBien];

        COMMIT TRANSACTION;

        SELECT JSON_QUERY(CONCAT(
            '{"tipo":"OK","mensaje":"Carga inicial generada para el periodo ',
            @P_Periodo,
            '.","liga":""}'
        )) AS ResultJson;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
