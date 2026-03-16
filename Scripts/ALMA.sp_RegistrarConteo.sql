
-- =============================================
-- PROCEDIMIENTOS ALMACENADOS
-- =============================================

-- SP para registrar un conteo (con lógica de negocio)
GO
CREATE OR ALTER PROCEDURE ALMA.sp_RegistrarConteo
    @PKIdArticuloConteo INT,
    @CantidadContada DECIMAL(18,4),
    @FKIdUsuario_SIS INT,
    @Observaciones NVARCHAR(500) = NULL,
    @Latitud DECIMAL(9,6) = NULL,
    @Longitud DECIMAL(9,6) = NULL,
    @FotoPath NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @FKIdPeriodoConteo INT
    DECLARE @FKIdSucursal INT
    DECLARE @ConteosRealizados INT
    DECLARE @MaximoConteos INT
    DECLARE @ExistenciaSistema DECIMAL(18,4)
    DECLARE @EstatusActual INT
    DECLARE @NuevoEstatus INT
    DECLARE @NumeroConteo INT
    DECLARE @FechaActual DATETIME2 = GETDATE()
    
    BEGIN TRANSACTION
    
    BEGIN TRY
        -- Obtener información del artículo con bloqueo
        SELECT 
            @FKIdPeriodoConteo = ac.FKIdPeriodoConteo_ALMA,
            @FKIdSucursal = ac.FKIdSucursal_SIS,
            @ConteosRealizados = ac.ConteosRealizados,
            @ExistenciaSistema = ac.ExistenciaSistema,
            @EstatusActual = ac.FKIdEstatus_ALMA,
            @MaximoConteos = p.MaximoConteosPorArticulo
        FROM ALMA.ArticuloConteo ac WITH (UPDLOCK)
        INNER JOIN ALMA.PeriodoConteo p ON ac.FKIdPeriodoConteo_ALMA = p.PKIdPeriodoConteo
        WHERE ac.PKIdArticuloConteo = @PKIdArticuloConteo AND ac.Activo = 1
        
        -- Validaciones
        IF @EstatusActual IN (4, 5, 6) -- Concluido o en discrepancia
        BEGIN
            RAISERROR('Este artículo ya ha sido concluido', 16, 1)
            ROLLBACK
            RETURN
        END
        
        IF @ConteosRealizados >= @MaximoConteos
        BEGIN
            RAISERROR('Se alcanzó el máximo de conteos permitidos para este artículo', 16, 1)
            ROLLBACK
            RETURN
        END
        
        -- Verificar que el usuario no haya contado antes este artículo
        IF EXISTS (
            SELECT 1 FROM ALMA.RegistroConteo 
            WHERE FKIdArticuloConteo_ALMA = @PKIdArticuloConteo 
            AND FKIdUsuario_SIS = @FKIdUsuario_SIS
        )
        BEGIN
            RAISERROR('Este usuario ya realizó un conteo para este artículo', 16, 1)
            ROLLBACK
            RETURN
        END
        
        -- Determinar el número de conteo
        SET @NumeroConteo = @ConteosRealizados + 1
        
        -- Insertar el registro de conteo
        INSERT INTO ALMA.RegistroConteo (
            FKIdArticuloConteo_ALMA,
            FKIdPeriodoConteo_ALMA,
            FKIdSucursal_SIS,
            NumeroConteo,
            CantidadContada,
            FechaConteo,
            FKIdUsuario_SIS,
            Observaciones,
            Latitud,
            Longitud,
            FotoPath
        ) VALUES (
            @PKIdArticuloConteo,
            @FKIdPeriodoConteo,
            @FKIdSucursal,
            @NumeroConteo,
            @CantidadContada,
            @FechaActual,
            @FKIdUsuario_SIS,
            @Observaciones,
            @Latitud,
            @Longitud,
            @FotoPath
        )
        
        -- Actualizar contador en el artículo
        UPDATE ALMA.ArticuloConteo
        SET ConteosRealizados = @ConteosRealizados + 1,
            ConteosPendientes = CASE 
                WHEN @ConteosRealizados + 1 >= @MaximoConteos THEN 0
                ELSE 1
            END,
            FechaModificacion = @FechaActual,
            UsuarioModificacion = @FKIdUsuario_SIS
        WHERE PKIdArticuloConteo = @PKIdArticuloConteo
        
        -- Determinar el nuevo estatus basado en la lógica de negocio
        DECLARE @Conteos TABLE (Numero INT, Cantidad DECIMAL(18,4))
        
        INSERT INTO @Conteos
        SELECT NumeroConteo, CantidadContada
        FROM ALMA.RegistroConteo
        WHERE FKIdArticuloConteo_ALMA = @PKIdArticuloConteo
        ORDER BY NumeroConteo
        
        DECLARE @TotalConteos INT = (SELECT COUNT(*) FROM @Conteos)
        
        -- Lógica de negocio para determinar estatus
        IF @TotalConteos = 1
        BEGIN
            -- Primer conteo realizado, esperar segundo
            SET @NuevoEstatus = 2 -- Pendiente 2do Conteo
        END
        ELSE IF @TotalConteos = 2
        BEGIN
            -- Segundo conteo, verificar si coinciden
            DECLARE @Cantidad1 DECIMAL(18,4) = (SELECT Cantidad FROM @Conteos WHERE Numero = 1)
            DECLARE @Cantidad2 DECIMAL(18,4) = (SELECT Cantidad FROM @Conteos WHERE Numero = 2)
            
            IF @Cantidad1 = @Cantidad2
            BEGIN
                -- Coinciden, concluir sin diferencia
                SET @NuevoEstatus = 4 -- Concluido Sin Diferencia
                
                -- Actualizar valores finales
                UPDATE ALMA.ArticuloConteo
                SET ExistenciaFinal = @Cantidad1,
                    Diferencia = @Cantidad1 - @ExistenciaSistema,
                    PorcentajeDiferencia = CASE 
                        WHEN @ExistenciaSistema = 0 THEN 0
                        ELSE ((@Cantidad1 - @ExistenciaSistema) / @ExistenciaSistema) * 100
                    END,
                    FechaConclusion = @FechaActual,
                    FKIdUsuarioConcluyo_SIS = @FKIdUsuario_SIS
                WHERE PKIdArticuloConteo = @PKIdArticuloConteo
            END
            ELSE
            BEGIN
                -- No coinciden, verificar si podemos hacer tercer conteo
                IF @MaximoConteos >= 3
                BEGIN
                    SET @NuevoEstatus = 3 -- Pendiente 3er Conteo
                END
                ELSE
                BEGIN
                    -- No hay más conteos permitidos, pasa a discrepancia
                    SET @NuevoEstatus = 6 -- En Discrepancia
                    
                    -- Insertar en tabla de discrepancias
                    INSERT INTO ALMA.DiscrepanciaConteo (
                        FKIdArticuloConteo_ALMA,
                        Valor1,
                        Valor2,
                        FechaCreacion,
                        UsuarioCreacion
                    ) VALUES (
                        @PKIdArticuloConteo,
                        @Cantidad1,
                        @Cantidad2,
                        @FechaActual,
                        @FKIdUsuario_SIS
                    )
                END
            END
        END
        ELSE IF @TotalConteos = 3
        BEGIN
            -- Tercer conteo, determinar resultado
            DECLARE @Cant3 DECIMAL(18,4) = (SELECT Cantidad FROM @Conteos WHERE Numero = 3)
            DECLARE @ValorFinal DECIMAL(18,4)
            
            -- Buscar si alguna cantidad coincide
            IF @Cant3 = @Cantidad1 OR @Cant3 = @Cantidad2
            BEGIN
                -- Coincide con alguno anterior
                SET @ValorFinal = @Cant3
                SET @NuevoEstatus = 4 -- Concluido Sin Diferencia
            END
            ELSE IF @Cantidad1 = @Cantidad2
            BEGIN
                -- Los dos primeros coinciden, ese es el bueno
                SET @ValorFinal = @Cantidad1
                SET @NuevoEstatus = 4 -- Concluido Sin Diferencia
            END
            ELSE
            BEGIN
                -- Los tres son diferentes, pasa a discrepancia
                SET @NuevoEstatus = 6 -- En Discrepancia
                
                INSERT INTO ALMA.DiscrepanciaConteo (
                    FKIdArticuloConteo_ALMA,
                    Valor1,
                    Valor2,
                    Valor3,
                    FechaCreacion,
                    UsuarioCreacion
                ) VALUES (
                    @PKIdArticuloConteo,
                    @Cantidad1,
                    @Cantidad2,
                    @Cant3,
                    @FechaActual,
                    @FKIdUsuario_SIS
                )
            END
            
            IF @NuevoEstatus = 4 -- Si concluyó, actualizar valores finales
            BEGIN
                UPDATE ALMA.ArticuloConteo
                SET ExistenciaFinal = @ValorFinal,
                    Diferencia = @ValorFinal - @ExistenciaSistema,
                    PorcentajeDiferencia = CASE 
                        WHEN @ExistenciaSistema = 0 THEN 0
                        ELSE ((@ValorFinal - @ExistenciaSistema) / @ExistenciaSistema) * 100
                    END,
                    FechaConclusion = @FechaActual,
                    FKIdUsuarioConcluyo_SIS = @FKIdUsuario_SIS
                WHERE PKIdArticuloConteo = @PKIdArticuloConteo
            END
        END
        
        -- Actualizar el estatus si cambió
        IF @NuevoEstatus IS NOT NULL AND @NuevoEstatus != @EstatusActual
        BEGIN
            -- Guardar en historial
            INSERT INTO ALMA.HistorialEstatusArticulo (
                FKIdArticuloConteo_ALMA,
                FKIdEstatusAnterior_ALMA,
                FKIdEstatusNuevo_ALMA,
                FKIdRegistroConteo_ALMA,
                Observaciones,
                FKIdUsuario_SIS,
                FechaCambio
            ) VALUES (
                @PKIdArticuloConteo,
                @EstatusActual,
                @NuevoEstatus,
                SCOPE_IDENTITY(), -- Último registro de conteo insertado
                'Cambio automático por regla de negocio',
                @FKIdUsuario_SIS,
                @FechaActual
            )
            
            -- Actualizar artículo
            UPDATE ALMA.ArticuloConteo
            SET FKIdEstatus_ALMA = @NuevoEstatus
            WHERE PKIdArticuloConteo = @PKIdArticuloConteo
        END
        
        COMMIT TRANSACTION
        
        -- Retornar resultado
        SELECT 
            'Éxito' as Resultado,
            @NumeroConteo as ConteoRegistrado,
            (SELECT Nombre FROM ALMA.EstatusArticuloConteo WHERE PKIdEstatusArticulo = ISNULL(@NuevoEstatus, @EstatusActual)) as NuevoEstatus,
            CASE 
                WHEN @NuevoEstatus = 4 THEN 'Artículo concluido - Coincidencia'
                WHEN @NuevoEstatus = 5 THEN 'Artículo concluido con diferencia'
                WHEN @NuevoEstatus = 6 THEN 'Artículo en discrepancia - Requiere supervisor'
                WHEN @NuevoEstatus = 3 THEN 'Requiere tercer conteo'
                ELSE 'Conteo registrado exitosamente'
            END as Mensaje
            
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    END CATCH
END
GO

