CREATE OR ALTER PROCEDURE SIS.spEliminarUsuarioSucursal
    @FkidUsuarioSis INT,
    @FkidSucursalSis INT,
    @UsuarioModificacion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificar si existe la asignación
        IF NOT EXISTS (
            SELECT 1 FROM SIS.UsuarioSucursal 
            WHERE FkidUsuario_Sis = @FkidUsuarioSis 
            AND FkidSucursal_Sis = @FkidSucursalSis
        )
        BEGIN
            SELECT 
                0 AS Success,
                'No se encontró la asignación especificada' AS Message,
                'NOT_FOUND' AS Code;
            RETURN;
        END

        -- Eliminar físicamente el registro
        DELETE FROM SIS.UsuarioSucursal 
        WHERE FkidUsuario_Sis = @FkidUsuarioSis 
        AND FkidSucursal_Sis = @FkidSucursalSis;

        -- Si quieres en lugar de eliminar físicamente, hacer baja lógica (soft delete)
        -- UPDATE UsuarioSucursal
        -- SET Activo = 0,
        --     FechaModificacion = GETDATE(),
        --     UsuarioModificacion = @UsuarioModificacion
        -- WHERE FkidUsuarioSis = @FkidUsuarioSis 
        -- AND FkidSucursalSis = @FkidSucursalSis;

        COMMIT TRANSACTION;

        SELECT 
            1 AS Success,
            'Asignación eliminada correctamente' AS Message,
            'SUCCESS' AS Code;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        SELECT 
            0 AS Success,
            @ErrorMessage AS Message,
            'ERROR' AS Code;

        -- Opcional: Registrar el error en una tabla de log
        -- INSERT INTO ErrorLog (ErrorMessage, ErrorProcedure, ErrorLine, ErrorTime)
        -- VALUES (@ErrorMessage, ERROR_PROCEDURE(), ERROR_LINE(), GETDATE());

    END CATCH
END
GO