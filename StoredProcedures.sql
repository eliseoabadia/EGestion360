USE [GestionEmpresarial];
GO

-- =============================================
-- STORED PROCEDURES DEL SISTEMA GestionEmpresarial
-- =============================================

-- =============================================
-- ALMA
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [ALMA].[SP_CargaInicialConteo]
    @P_Partida INT = NULL,
    @P_Periodo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ResultJson NVARCHAR(MAX);
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM [ALMA].[ConteoDetalle];
        DELETE FROM [ALMA].[Conteo];

        IF @P_Partida IS NULL
        BEGIN
            INSERT INTO [ALMA].[Conteo]
                ([FKIdTipoBien_ALMA]
                ,[CantidadInventario]
                ,[Descripcion]
                ,[FechaInicio]
                ,[Activo]
                ,[FechaCreacion]
                ,[UsuarioCreacion]
                ,FKIdPeriodoConteo_ALMA)
            SELECT
                CI.PKIdTipoBien,
                CI.Existencias,
                CI.Descripcion,
                GETDATE(),
                1,
                GETDATE(),
                1,
                @P_Periodo
            FROM
                [ALMA].[VW_Existencias] CI
                INNER JOIN [ALMA].[TipoBien] TB ON CI.PKIdTipoBien = TB.[PKIdTipoBien]
            WHERE
                TB.[FKIdPartida_CONTA] > 20000
                AND TB.[FKIdPartida_CONTA] < 30000
                AND TB.[Activo] = 1;
        END
        ELSE
        BEGIN
            IF @P_Partida <= 20000 OR @P_Partida >= 30000
            BEGIN
                SET @ResultJson = '{"tipo":"ERROR","mensaje":"Solo se permiten conteos del cap�tulo 20000. Partida no permitida: ' + CAST(@P_Partida AS NVARCHAR) + '","liga":""}';
                SELECT JSON_QUERY(@ResultJson) AS ResultJson;
                RETURN;
            END

            INSERT INTO [ALMA].[Conteo]
                ([FKIdTipoBien_ALMA]
                ,[CantidadInventario]
                ,[Descripcion]
                ,[FechaInicio]
                ,[Activo]
                ,[FechaCreacion]
                ,[UsuarioCreacion]
                ,FKIdPeriodoConteo_ALMA)
            SELECT
                CI.PKIdTipoBien,
                CI.Existencias,
                CI.Descripcion,
                GETDATE(),
                1,
                GETDATE(),
                1,
                @P_Periodo
            FROM
                [ALMA].[VW_Existencias] CI
                INNER JOIN [ALMA].[TipoBien] TB ON CI.PKIdTipoBien = TB.[PKIdTipoBien]
            WHERE
                TB.[FKIdPartida_CONTA] = @P_Partida
                AND TB.[Activo] = 1;
        END

        COMMIT TRANSACTION;

        SET @ResultJson = '{"tipo":"EXITO","mensaje":"Conteo generado correctamente","liga":""}';
        SELECT JSON_QUERY(@ResultJson) AS ResultJson;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        SET @ResultJson = '{"tipo":"ERROR","mensaje":"' + REPLACE(@ErrorMessage, '"', '\"') + '","liga":""}';
        SELECT JSON_QUERY(@ResultJson) AS ResultJson;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [ALMA].[SP_MantenimientoTipoBien] (
    @Action INT,
    @PKIdTipoBien INT = NULL,
    @FKIdGrupoBien_ALMA INT = NULL,
    @FKIdNivel_ALMA INT = NULL,
    @FKIdPartida_CONTA INT = NULL,
    @FKIdCuentaContable_CONTA INT = NULL,
    @FKIdUnidades_ALMA INT = NULL,
    @FKIdLocalizacion_ALMA INT = NULL,
    @FKIdUnidades_Equivalente INT = NULL,
    @CodigoClave NVARCHAR(200) = NULL,
    @Descripcion NVARCHAR(1200) = NULL,
    @DepreciacionAnual DECIMAL(18,4) = NULL,
    @Consecutivo INT = NULL,
    @CABMS NVARCHAR(50) = NULL,
    @Identificador NVARCHAR(50) = NULL,
    @ExistenciaMinima DECIMAL(18,4) = NULL,
    @ExistenciaMaxima DECIMAL(18,4) = NULL,
    @TiempoVida INT = NULL,
    @Pk_IdTratadoInt INT = NULL,
    @Cuota NUMERIC(8,2) = NULL,
    @ProveeduriaNac BIT = NULL,
    @CatalogoBasico BIT = NULL,
    @CUCOP_PLUS VARCHAR(25) = NULL,
    @Cantidad_Equivalente INT = NULL,
    @IdUser INT = NULL,
    @Id INT = NULL OUTPUT
)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(4000);
    DECLARE @errorMessage NVARCHAR(MAX);
    DECLARE @today DATETIME = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            DECLARE @FKIdPartidaCalculada INT = @FKIdPartida_CONTA;
            DECLARE @CABMSCalculada VARCHAR(50) = @CABMS;

            INSERT INTO ALMA.TipoBien (
                FKIdGrupoBien_ALMA, FKIdNivel_ALMA,
                FKIdPartida_CONTA, FKIdCuentaContable_CONTA,
                FKIdUnidades_ALMA, FKIdLocalizacion_ALMA,
                FKIdUnidades_Equivalente,
                CodigoClave, Descripcion,
                DepreciacionAnual, Consecutivo, CABMS,
                Identificador, ExistenciaMinima, ExistenciaMaxima,
                TiempoVida, Pk_IdTratadoInt, Cuota,
                ProveeduriaNac, CatalogoBasico, CUCOP_PLUS,
                Cantidad_Equivalente,
                Activo, FechaCreacion, UsuarioCreacion
            )
            VALUES (
                @FKIdGrupoBien_ALMA, @FKIdNivel_ALMA,
                @FKIdPartidaCalculada, @FKIdCuentaContable_CONTA,
                @FKIdUnidades_ALMA, @FKIdLocalizacion_ALMA,
                @FKIdUnidades_Equivalente,
                @CodigoClave, @Descripcion,
                @DepreciacionAnual, @Consecutivo, @CABMSCalculada,
                @Identificador, @ExistenciaMinima, @ExistenciaMaxima,
                @TiempoVida, @Pk_IdTratadoInt, @Cuota,
                @ProveeduriaNac, @CatalogoBasico, @CUCOP_PLUS,
                @Cantidad_Equivalente,
                1, @today, @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @tipo = 'OK';
            SET @message = 'Tipo de bien creado correctamente.';
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdTipoBien IS NULL OR NOT EXISTS (SELECT 1 FROM ALMA.TipoBien WHERE PKIdTipoBien = @PKIdTipoBien AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'Tipo de bien no encontrado';
                GOTO ERR_HANDLER;
            END

            UPDATE ALMA.TipoBien
            SET
                FKIdGrupoBien_ALMA = ISNULL(@FKIdGrupoBien_ALMA, FKIdGrupoBien_ALMA),
                FKIdNivel_ALMA = ISNULL(@FKIdNivel_ALMA, FKIdNivel_ALMA),
                FKIdPartida_CONTA = ISNULL(@FKIdPartida_CONTA, FKIdPartida_CONTA),
                FKIdCuentaContable_CONTA = ISNULL(@FKIdCuentaContable_CONTA, FKIdCuentaContable_CONTA),
                FKIdUnidades_ALMA = ISNULL(@FKIdUnidades_ALMA, FKIdUnidades_ALMA),
                FKIdLocalizacion_ALMA = ISNULL(@FKIdLocalizacion_ALMA, FKIdLocalizacion_ALMA),
                FKIdUnidades_Equivalente = ISNULL(@FKIdUnidades_Equivalente, FKIdUnidades_Equivalente),
                CodigoClave = ISNULL(@CodigoClave, CodigoClave),
                Descripcion = ISNULL(@Descripcion, Descripcion),
                DepreciacionAnual = ISNULL(@DepreciacionAnual, DepreciacionAnual),
                Consecutivo = ISNULL(@Consecutivo, Consecutivo),
                CABMS = ISNULL(@CABMS, CABMS),
                Identificador = ISNULL(@Identificador, Identificador),
                ExistenciaMinima = ISNULL(@ExistenciaMinima, ExistenciaMinima),
                ExistenciaMaxima = ISNULL(@ExistenciaMaxima, ExistenciaMaxima),
                TiempoVida = ISNULL(@TiempoVida, TiempoVida),
                Pk_IdTratadoInt = ISNULL(@Pk_IdTratadoInt, Pk_IdTratadoInt),
                Cuota = ISNULL(@Cuota, Cuota),
                ProveeduriaNac = ISNULL(@ProveeduriaNac, ProveeduriaNac),
                CatalogoBasico = ISNULL(@CatalogoBasico, CatalogoBasico),
                CUCOP_PLUS = ISNULL(@CUCOP_PLUS, CUCOP_PLUS),
                Cantidad_Equivalente = ISNULL(@Cantidad_Equivalente, Cantidad_Equivalente),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdTipoBien = @PKIdTipoBien;

            SET @Id = @PKIdTipoBien;
            SET @tipo = 'OK';
            SET @message = 'Tipo de bien actualizado correctamente.';
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdTipoBien IS NULL OR NOT EXISTS (SELECT 1 FROM ALMA.TipoBien WHERE PKIdTipoBien = @PKIdTipoBien AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'Tipo de bien no encontrado';
                GOTO ERR_HANDLER;
            END

            UPDATE ALMA.TipoBien
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdTipoBien = @PKIdTipoBien;

            SET @Id = @PKIdTipoBien;
            SET @tipo = 'OK';
            SET @message = 'Tipo de bien eliminado correctamente.';
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT
                tb.PKIdTipoBien,
                tb.FKIdGrupoBien_ALMA,
                gb.Descripcion AS GrupoBien,
                tb.FKIdNivel_ALMA,
                tb.FKIdPartida_CONTA,
                p.Clave AS PartidaClave,
                p.Descripcion AS PartidaDescripcion,
                tb.FKIdCuentaContable_CONTA,
                tb.FKIdUnidades_ALMA,
                u.Descripcion AS UnidadMedida,
                tb.FKIdLocalizacion_ALMA,
                tb.FKIdUnidades_Equivalente,
                tb.CodigoClave,
                tb.Descripcion,
                tb.DepreciacionAnual,
                tb.Consecutivo,
                tb.CABMS,
                tb.Identificador,
                tb.ExistenciaMinima,
                tb.ExistenciaMaxima,
                tb.TiempoVida,
                tb.Pk_IdTratadoInt,
                tb.Cuota,
                tb.ProveeduriaNac,
                tb.CatalogoBasico,
                tb.CUCOP_PLUS,
                tb.Cantidad_Equivalente,
                tb.Activo,
                tb.FechaCreacion,
                tb.UsuarioCreacion,
                tb.FechaModificacion,
                tb.UsuarioModificacion
            FROM ALMA.TipoBien tb
            LEFT JOIN ALMA.GrupoBien gb ON tb.FKIdGrupoBien_ALMA = gb.PKIdGrupoBien
            LEFT JOIN CONTA.Partida p ON tb.FKIdPartida_CONTA = p.PKIdPartida
            LEFT JOIN ALMA.Unidades u ON tb.FKIdUnidades_ALMA = u.PKIdUnidades
            WHERE tb.PKIdTipoBien = @PKIdTipoBien;

            SET @tipo = 'OK';
            GOTO FINISH;
        END
        ELSE
        BEGIN
            SET @tipo = 'ERROR';
            SET @message = 'Acci�n no v�lida. Use 1=Insert, 2=Update, 3=Delete, 4=GetById';
            GOTO ERR_HANDLER;
        END

        FINISH:
        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRANSACTION;

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"', @tipo, '","mensaje":"', @message, '","liga":"idTipoBien:', ISNULL(CAST(@Id AS NVARCHAR), ''), '"}')
        ) AS ResultJson;

        RETURN 0;

        ERR_HANDLER:
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END CATCH
END;
GO

-- =============================================
-- dbo
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_RegistrarEntidad]
    @Grupo          NVARCHAR(100),
    @SubGrupo       NVARCHAR(100),
    @NombreMenu     NVARCHAR(150),
    @Ruta           NVARCHAR(200),
    @MenuPadreNombre NVARCHAR(150) = NULL,
    @Icono          NVARCHAR(120) = NULL,
    @Orden          INT = 0,
    @Descripcion    NVARCHAR(200) = NULL,
    @Codigo         NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdMenu INT;
    DECLARE @IdMenuPadre INT = NULL;
    DECLARE @PermisosAdmin    NVARCHAR(100) = 'view,view-menu,delete,new,update,CanExportToExcel';
    DECLARE @PermisosSoporte  NVARCHAR(100) = 'view,view-menu';
    DECLARE @PermisosConfig   NVARCHAR(100) = 'view,view-menu,delete,new,update';

    IF @MenuPadreNombre IS NOT NULL
    BEGIN
        SELECT @IdMenuPadre = PKIdMenu
        FROM SIS.Menu
        WHERE Nombre = @MenuPadreNombre AND Activo = 1;
        
        IF @IdMenuPadre IS NULL
        BEGIN
            PRINT 'Advertencia: No se encontr� el men� padre "' + @MenuPadreNombre + '". Se registrar� como ra�z.';
        END
    END

    IF @Codigo IS NULL
        SET @Codigo = UPPER(LEFT(@Grupo, 2) + LEFT(@SubGrupo, 2) + '001');

    IF NOT EXISTS (SELECT 1 FROM SIS.Menu WHERE Nombre = @NombreMenu AND Ruta = @Ruta AND Activo = 1)
    BEGIN
        INSERT INTO SIS.Menu (
            Nombre, Tipo, FKIdMenu_SIS, LegacyName, Ruta,
            ImageUrl, Lenguaje, Orden, Activo, CreatedDateTime
        ) VALUES (
            @NombreMenu, 2, @IdMenuPadre, @NombreMenu, @Ruta,
            @Icono, 'ESP', @Orden, 1, GETDATE()
        );
        SET @IdMenu = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SELECT @IdMenu = PKIdMenu FROM SIS.Menu WHERE Nombre = @NombreMenu AND Ruta = @Ruta AND Activo = 1;
    END

    DECLARE @Roles TABLE (Code NVARCHAR(10), Permisos NVARCHAR(100));
    INSERT INTO @Roles VALUES ('10000', @PermisosAdmin), ('20000', @PermisosSoporte), ('30000', @PermisosConfig);

    DECLARE @CodeRole NVARCHAR(10), @PermisosRole NVARCHAR(100), @RoleId NVARCHAR(128);

    DECLARE role_cursor CURSOR FOR
        SELECT r.Code, rp.Permisos
        FROM AspNetRoles r
        INNER JOIN @Roles rp ON r.Code = rp.Code;

    OPEN role_cursor;
    FETCH NEXT FROM role_cursor INTO @CodeRole, @PermisosRole;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @RoleId = (SELECT Id FROM AspNetRoles WHERE Code = @CodeRole);

        IF NOT EXISTS (
            SELECT 1 FROM AspNetClaims
            WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo
        )
        BEGIN
            INSERT INTO AspNetClaims (
                ClaimTypeId, Name, [Group], RoleId, TokenFormat, Created,
                SubGroup, Code, [Description], [Values], ReferenceId
            )
            VALUES (
                2, @Grupo, @Grupo, @RoleId, 'app://{0}/{1}', GETDATE(),
                @SubGrupo, @Codigo, @Descripcion, @PermisosRole,
                ISNULL((SELECT TOP 1 Id FROM AspNetClaims WHERE [Group] = @Grupo AND SubGroup = @SubGrupo), 0)
            );
        END
        ELSE
        BEGIN
            DECLARE @CurrentValues NVARCHAR(MAX);
            SELECT @CurrentValues = [Values] FROM AspNetClaims
            WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo;

            SET @PermisosRole = (
                SELECT STRING_AGG(value, ',') WITHIN GROUP (ORDER BY value)
                FROM (
                    SELECT DISTINCT value FROM STRING_SPLIT(@CurrentValues, ',')
                    UNION
                    SELECT DISTINCT value FROM STRING_SPLIT(@PermisosRole, ',')
                ) AS t
            );

            UPDATE AspNetClaims
            SET [Values] = @PermisosRole,
                [Description] = ISNULL(@Descripcion, [Description])
            WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo;
        END

        DECLARE @ClaimId INT;
        SELECT @ClaimId = Id FROM AspNetClaims
        WHERE RoleId = @RoleId AND [Group] = @Grupo AND SubGroup = @SubGrupo;

        INSERT INTO AspNetClaimValues (ClaimId, Value, Created)
        SELECT @ClaimId, TRIM(value), GETDATE()
        FROM STRING_SPLIT(@PermisosRole, ',')
        WHERE NOT EXISTS (
            SELECT 1 FROM AspNetClaimValues
            WHERE ClaimId = @ClaimId AND Value = TRIM(value)
        );

        IF EXISTS (SELECT 1 FROM STRING_SPLIT(@PermisosRole, ',') WHERE value = 'view-menu')
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SIS.MenuRole WHERE FKIdMenu_SIS = @IdMenu AND RoleId = @RoleId)
            BEGIN
                INSERT INTO SIS.MenuRole (FKIdMenu_SIS, RoleId, Activo, CreatedDateTime)
                VALUES (@IdMenu, @RoleId, 1, GETDATE());
            END
        END
        ELSE
        BEGIN
            DELETE FROM SIS.MenuRole WHERE FKIdMenu_SIS = @IdMenu AND RoleId = @RoleId;
        END

        FETCH NEXT FROM role_cursor INTO @CodeRole, @PermisosRole;
    END

    CLOSE role_cursor;
    DEALLOCATE role_cursor;

    PRINT 'Entidad "' + @Grupo + '/' + @SubGrupo + '" registrada correctamente.';
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[spConfiguracionDeRolYClaims]
	@group NVARCHAR(100),
	@subgroup NVARCHAR(100),
	@code NVARCHAR(10),
	@values NVARCHAR(max),
	@description NVARCHAR(200) = NULL,
	@rolName NVARCHAR(256) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @IdRole NVARCHAR(128),
	        @value NVARCHAR(max),
	        @claims NVARCHAr(max),
			@IdReference INT,
			@Cod NVARCHAR(10),
			@IdClaim INT,
			@errorMassage1 NVARCHAR(200),
			@errorMassage2 NVARCHAR(200);

	IF EXISTS(SELECT 1 FROM AspNetRoles WHERE Code = @code)
	BEGIN
    
		SET @IdRole = (SELECT Id FROM AspNetRoles WHERE Code = @code)
		SET @Cod = (SELECT TOP 1 Code FROM AspNetClaims WHERE [Group] = @group)
		SET @IdReference = (SELECT TOP 1 Id FROM AspNetClaims WHERE [Group] = @group AND [SubGroup] = @subgroup)
	
		IF EXISTS(SELECT 1 FROM AspNetClaims WHERE RoleId = @IdRole and [Group] = @group)
		BEGIN

			IF EXISTS(SELECT 1 FROM AspNetClaims WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup)
			BEGIN
			
				SET @claims = (SELECT [Values] FROM AspNetClaims WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup);

				IF EXISTS(SELECT 1 FROM [dbo].[STRING_SPLIT](@claims) WHERE Name = @values)
				BEGIN
					SET @errorMassage1 = 'El Claim ' + @values + ' ya Existe';
				END
				ELSE
				BEGIN
			    
					UPDATE AspNetClaims SET [Values] = @claims + ',' + @values
					WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup

				END
			END
			ELSE
			BEGIN
		    
				IF @Description IS NULL
				BEGIN
					SET @Description=(SELECT TOP 1 Description FROM AspNetClaims WHERE [Group] = @group AND [SubGroup] = @subgroup)
				END

				INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
				VALUES(2,@group,@group,@IdRole,'app://{0}/{1}',GETDATE(),@subgroup,@Cod,@Description,@values,@IdReference)
				
			END

		END
		ELSE
		BEGIN

			IF @Description IS NULL
			BEGIN
				SET @Description=(SELECT TOP 1 Description FROM AspNetClaims WHERE [Group] = @group AND [SubGroup] = @subgroup)
			END
	    
			INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
			VALUES(2,@group,@group,@IdRole,'app://{0}/{1}',GETDATE(),@subgroup,@Cod,@Description,@values,@IdReference)

		END

	END
	ELSE
	BEGIN
        
		IF @rolName IS NOT NULL
		BEGIN
			SET @IdRole = NEWID();
			SET @Cod = (SELECT TOP 1 Code FROM AspNetClaims WHERE [Group] = @group)
			SET @IdReference = (SELECT TOP 1 Id FROM AspNetClaims WHERE [Group] = @group)

			INSERT INTO AspNetRoles
			VALUES(@IdRole,@rolName,@code)

			INSERT INTO AspNetClaims(ClaimTypeId,Name,[Group],RoleId,TokenFormat,Created,SubGroup,Code,[Description],[Values],ReferenceId)
			VALUES(2,@group,@group,@IdRole,'app://{0}/{1}',GETDATE(),@subgroup,@Cod,@Description,@values,@IdReference)
		
		END
		ELSE
		BEGIN
		    SET @errorMassage1 = 'Para agregar un rol se necesita el nombre que se le asignara';
		END

	END

	IF @errorMassage1 <> 'Success'
	BEGIN
		SELECT @errorMassage1 AS AspNetClaims;
	END
	
	SET @IdClaim = (SELECT MAX(Id) FROM AspNetClaims WHERE RoleId = @IdRole AND [Group] = @group AND [SubGroup] = @subgroup);

	IF @IdClaim IS NULL
	BEGIN
	    SET @errorMassage2 = 'Revisar parametros de entrada';
	END
	ELSE
	BEGIN
	    
		IF EXISTS(SELECT 1 FROM AspNetClaimValues WHERE ClaimId = @IdClaim AND Value = @Values)
		BEGIN
	    
			SET @errorMassage2 = 'El valor ya se encuentra registrado';

		END
		ELSE
		BEGIN
	    
			INSERT INTO AspNetClaimValues(ClaimId,Value,Created)
			VALUES(@IdClaim,@values,GETDATE())
		
		END

	END

	IF @errorMassage2 <> 'Success'
	BEGIN
		SELECT @errorMassage2 AS AspNetClaimValues;
	END
END
GO

-- =============================================
-- SIS
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC [SIS].[LoginInformationEmployee] @PayrollID = 'ADMIN001'
CREATE OR ALTER PROCEDURE [SIS].[LoginInformationEmployee](
	@PayrollID NVARCHAR(60)
)
AS BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	SELECT e.PkIdUsuario
    , iif(e.FKIdPersona_NOM IS NULL,0,e.FKIdPersona_NOM) FKIdPersonaNOM
    , e.PayrollID
    , iif(p.Gafete is null,e.PayrollID,p.Gafete) Gafete
    , ANU.PasswordHash
    , rol.Name
    , iif(p.CORREO_ELECTRONICO IS NULL ,'ADMIN@eg.COM',p.CORREO_ELECTRONICO) AS Email
    , NombreUsuario = IIF(p.Nombre IS NULL,'Admin',CONCAT(p.Nombre, ' ', p.Paterno, ' ', p.Materno))
	FROM SIS.Usuario AS e WITH (NOLOCK)
	LEFT JOIN NOM.Persona p ON e.FKIdPersona_NOM = p.PKIdPersona
	INNER JOIN dbo.AspNetUsers AS ANU WITH (NOLOCK) ON ANU.PkIdUsuario = e.PkIdUsuario
	INNER JOIN [dbo].[AspNetUserRoles] AS UR WITH (NOLOCK) ON UR.UserId = ANU.Id
	INNER JOIN AspNetRoles AS rol WITH (NOLOCK) ON UR.RoleId = rol.Id
	WHERE e.PayrollID = @PayrollID AND e.Activo = 1
END;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [SIS].[spEliminarUsuarioSucursal]
    @FkidUsuarioSis INT,
    @FkidSucursalSis INT,
    @UsuarioModificacion VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM SIS.UsuarioSucursal 
            WHERE FkidUsuario_Sis = @FkidUsuarioSis 
            AND FkidSucursal_Sis = @FkidSucursalSis
        )
        BEGIN
            SELECT 
                0 AS Success,
                'No se encontr� la asignaci�n especificada' AS Message,
                'NOT_FOUND' AS Code;
            RETURN;
        END

        DELETE FROM SIS.UsuarioSucursal 
        WHERE FkidUsuario_Sis = @FkidUsuarioSis 
        AND FkidSucursal_Sis = @FkidSucursalSis;

        COMMIT TRANSACTION;

        SELECT 
            1 AS Success,
            'Asignaci�n eliminada correctamente' AS Message,
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

    END CATCH
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [SIS].[spGetClaimsByUser] @PkIdUser = 1, @EsParaLogin = 1
CREATE OR ALTER PROCEDURE [SIS].[spGetClaimsByUser]
    @PkIdUser INT, 
    @EsParaLogin BIT = 0
AS
BEGIN
    ;WITH Claims AS (
        SELECT 
            ANC.[Group], 
            ANC.SubGroup, 
            ANC.[Values]
        FROM SIS.Usuario AS U WITH (NOLOCK)
        INNER JOIN dbo.AspNetUsers AS ANU WITH (NOLOCK) 
            ON U.PkIdUsuario = ANU.PkIdUsuario
        INNER JOIN dbo.AspNetUserRoles AS ANUR WITH (NOLOCK) 
            ON ANUR.UserId = ANU.Id
        INNER JOIN dbo.AspNetRoles AS R WITH (NOLOCK) 
            ON R.Id = ANUR.RoleId
        INNER JOIN dbo.AspNetClaims AS ANC WITH (NOLOCK) 
            ON ANC.RoleId = R.Id
        LEFT JOIN SIS.MenuRole AS MR WITH (NOLOCK) 
            ON MR.RoleId = R.Id
        LEFT JOIN SIS.Menu AS M WITH (NOLOCK) 
            ON M.PKIdMenu = MR.FKIdMenu_SIS
        WHERE 
            U.PkIdUsuario = @PkIdUser
            AND U.Activo = 1
            AND (@EsParaLogin = 0 OR M.Activo = 1)
    )
    SELECT
        [Group], SubGroup, [Values]
    FROM Claims
    GROUP BY [Group], SubGroup, [Values]
    ORDER BY [Group], SubGroup, [Values];
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [SIS].[spNodeMenu] @NoEmploye = 1, @Lenguaje = 'ESP'
CREATE OR ALTER PROCEDURE [SIS].[spNodeMenu]
	@NoEmploye int, 
	@Lenguaje char(3)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	IF (@NoEmploye <= 0)
		set @NoEmploye = 1000
	;with cte as 
	(
		SELECT  [SM].[PKIdMenu],[SM].[Nombre],[SM].[Tipo],[SM].[FKIdMenu_SIS],[SM].[LegacyName],[SM].[Ruta],[SM].[ImageUrl],[SM].[Activo],[SM].[Lenguaje],[R].[UserId], [SM].[Orden]
		FROM SIS.Menu [SM] (NOLOCK)
			INNER JOIN SIS.MenuRole [RM] (NOLOCK) ON [RM].[FKIdMenu_SIS] = [SM].[PKIdMenu]
			INNER JOIN [dbo].[AspNetUserRoles] AS R (NOLOCK) ON R.RoleId = RM.RoleID
			INNER JOIN [dbo].[AspNetUsers] [ANU] (NOLOCK) ON [ANU].[Id] = [R].[UserId]
			INNER JOIN SIS.Usuario [EMP] (NOLOCK) ON [EMP].PkIdUsuario = [ANU].PkIdUsuario
		WHERE  [SM].[Activo] = 1 and [SM].FKIdMenu_SIS is null AND [EMP].PkIdUsuario = @NoEmploye
		union all
		SELECT  [SM].[PKIdMenu],[SM].[Nombre],[SM].[Tipo],[SM].[FKIdMenu_SIS],[SM].[LegacyName],[SM].[Ruta],[SM].[ImageUrl],[SM].[Activo],[SM].[Lenguaje],[R].[UserId], [SM].[Orden]
		FROM cte
		INNER JOIN SIS.Menu [SM] (NOLOCK) on SM.FKIdMenu_SIS = cte.PKIdMenu
		INNER JOIN SIS.MenuRole [RM] (NOLOCK) ON [RM].FKIdMenu_SIS = [SM].[PKIdMenu]
		INNER JOIN [dbo].[AspNetUserRoles] AS R (NOLOCK) ON R.RoleId = RM.RoleID
		INNER JOIN [dbo].[AspNetUsers] [ANU] (NOLOCK) ON [ANU].[Id] = [R].[UserId]
		INNER JOIN SIS.Usuario [EMP] (NOLOCK) ON [EMP].PkIdUsuario = [ANU].PkIdUsuario
		WHERE  [SM].[Activo] = 1 and [SM].FKIdMenu_SIS is not null AND [EMP].PkIdUsuario = @NoEmploye
	)    
	SELECT DISTINCT [SM].[PKIdMenu],[SM].[Nombre],[SM].[Tipo],
		[FKIdMenuSIS] = case when [SM].[FKIdMenu_SIS] IS NULL THEN 0 ELSE  [SM].[FKIdMenu_SIS] END,
		[SM].[LegacyName],[SM].[Ruta],[SM].[ImageUrl],[SM].[Activo],[SM].[Lenguaje],[SM].[UserId], [SM].[Orden] 
	FROM cte [SM]
	Order by [SM].[PKIdMenu] 
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [SIS].[WriteSystemLog] (
	@FK_IdOrigenLogMessage__SIS  nvarchar(24) = NULL
	,@Date nvarchar(24) = NULL 
	,@_Type nvarchar(24) = NULL
	,@ProgName nvarchar(256) = NULL
	,@EmployeeNo nvarchar(24) = NULL
	,@Category nvarchar(24) = NULL
	,@IPClient nvarchar(24) = NULL
	,@HostName nvarchar(32) = NULL
	,@Thread nvarchar(255) = NULL 
	,@Level nvarchar(20) =NULL 
	,@Logger nvarchar(255) =NULL 
	,@Message nvarchar(4000)= NULL
	,@Exception nvarchar(4000) = null
	,@Context nvarchar(10)  =null
	,@MethodName nvarchar(200)  =null
	,@Parameters nvarchar(4000) = null
	,@ExecutionTime nvarchar(32) = null
)
AS
BEGIN
	IF ISNULL(@Logger,'') = 'Microsoft.EntityFrameworkCore.Database.Command'
		return;

	IF EXISTS(SELECT 1
				FROM  SIS.SystemParamCatalog AS c 
					INNER JOIN SIS.SystemParamValue AS t ON c.PKIdSystemParamCatalog = t.FKIdSystemParamCatalog_SIS
				WHERE c.Code = 'SISTEMA'
					AND t.PKIdSystemParamValue = 1
					AND C.Activo = 1
					AND t.Activo = 1
					AND CAST(T.Value  AS INT) = 1)
	BEGIN 

		if @Exception     = '' set @Exception = null;
        if @Context       = '(null)' set @Context = null;
        if @MethodName    = '(null)' set @MethodName = null;
        if @Parameters    = '(null)' set @Parameters = null;        
        if @ExecutionTime = '(null)' set @ExecutionTime = null;

		if (@Date = '' Or @Date = '(null)' Or @Date is null) set @Date = GETDATE();
		
        DECLARE @ETInt int;
		set @ETInt  = IIF(@ExecutionTime IS NULL,0,convert(int, @ExecutionTime));

		INSERT INTO SIS.SystemLog (
				 [FKIdOrigenLogMessage_SIS]
				,[Date]
				,[Type]
				,[ProgName]
				,[EmployeeNo]
				,[Category]
				,[IPClient]
				,[HostName]
				,[Thread]
				,[Level]
				,[Logger]
				,[Message]
				,[Exception]
				,[Context]
				,[MethodName]
				,[Parameters]
			)
		values(  IIF(@FK_IdOrigenLogMessage__SIS IS NULL, 1, @FK_IdOrigenLogMessage__SIS)
				,@Date
				,@_Type
				,@ProgName 
				,@EmployeeNo 
				,@Category 
				,@IPClient 
				,@HostName 
				,@Thread 
				,@Level  
				,@Logger  
				,@Message 
				,@Exception 
				,@Context 
				,@MethodName 
				,@Parameters 
			)
	END
END
GO

-- =============================================
-- CONTA
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Tabla de consecutivos para p�lizas (por a�o, mes y tipo)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ConsecutivoPoliza' AND schema_id = SCHEMA_ID('CONTA'))
BEGIN
    CREATE TABLE CONTA.ConsecutivoPoliza (
        PKIdConsecutivoPoliza INT IDENTITY(1,1) NOT NULL,
        FK_IdAnio__SIS INT NOT NULL,
        FK_IdMes__SIS INT NOT NULL,
        FK_IdTipoPoliza__SIS INT NOT NULL,
        UltimoValor INT NOT NULL CONSTRAINT DF_ConsecutivoPoliza_UltimoValor DEFAULT (0),
        Activo BIT NOT NULL CONSTRAINT DF_ConsecutivoPoliza_Activo DEFAULT (1),
        FechaCreacion DATETIME2 CONSTRAINT DF_ConsecutivoPoliza_FechaCreacion DEFAULT SYSDATETIME(),
        UsuarioCreacion INT NOT NULL,
        FechaModificacion DATETIME2 NULL,
        UsuarioModificacion INT NULL,
        CONSTRAINT PK_ConsecutivoPoliza PRIMARY KEY (PKIdConsecutivoPoliza),
        CONSTRAINT FK_ConsecutivoPoliza_Anio FOREIGN KEY (FK_IdAnio__SIS) REFERENCES SIS.Anio(PKIdAnio),
        CONSTRAINT FK_ConsecutivoPoliza_TipoPoliza FOREIGN KEY (FK_IdTipoPoliza__SIS) REFERENCES SIS.TipoPoliza(PKIdTipoPoliza),
        CONSTRAINT UQ_ConsecutivoPoliza UNIQUE (FK_IdAnio__SIS, FK_IdMes__SIS, FK_IdTipoPoliza__SIS),
        CONSTRAINT FK_ConsecutivoPoliza_UsuarioCreacion FOREIGN KEY (UsuarioCreacion) REFERENCES SIS.Usuario(PkIdUsuario),
        CONSTRAINT FK_ConsecutivoPoliza_UsuarioModificacion FOREIGN KEY (UsuarioModificacion) REFERENCES SIS.Usuario(PkIdUsuario)
    );
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [CONTA].[SP_CREATE_ClavePoliza]
    @FK_IdAnio__SIS INT,
    @FK_IdMesConta__SIS INT,
    @FK_IdTipoPolizaConta__SIS INT,
    @CT_ModifiedBy INT,
    @ClavePoliza NVARCHAR(10) OUTPUT,
    @Error NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Auto-registro: si no existe el consecutivo, lo crea
        IF NOT EXISTS (
            SELECT 1 FROM CONTA.ConsecutivoPoliza
            WHERE FK_IdAnio__SIS = @FK_IdAnio__SIS
              AND FK_IdMes__SIS = @FK_IdMesConta__SIS
              AND FK_IdTipoPoliza__SIS = @FK_IdTipoPolizaConta__SIS
        )
        BEGIN
            INSERT INTO CONTA.ConsecutivoPoliza (
                FK_IdAnio__SIS, FK_IdMes__SIS, FK_IdTipoPoliza__SIS,
                UltimoValor, Activo, FechaCreacion, UsuarioCreacion
            ) VALUES (
                @FK_IdAnio__SIS, @FK_IdMesConta__SIS, @FK_IdTipoPolizaConta__SIS,
                0, 1, GETDATE(), @CT_ModifiedBy
            );
        END

        SELECT @ClavePoliza = CONVERT(NVARCHAR, (CC.FK_IdMes__SIS + CC.UltimoValor + 1))
        FROM CONTA.ConsecutivoPoliza CC WITH (UPDLOCK, ROWLOCK)
        WHERE CC.FK_IdAnio__SIS = @FK_IdAnio__SIS
          AND CC.FK_IdMes__SIS = @FK_IdMesConta__SIS
          AND CC.FK_IdTipoPoliza__SIS = @FK_IdTipoPolizaConta__SIS;

        IF @ClavePoliza IS NULL
        BEGIN
            SET @Error = 'No se pudo generar la clave de p�liza';
            GOTO ERR_HANDLER;
        END

        UPDATE CP
        SET CP.UltimoValor = CP.UltimoValor + 1,
            CP.FechaModificacion = GETDATE(),
            CP.UsuarioModificacion = @CT_ModifiedBy
        FROM CONTA.ConsecutivoPoliza CP
        WHERE CP.FK_IdAnio__SIS = @FK_IdAnio__SIS
          AND CP.FK_IdMes__SIS = @FK_IdMesConta__SIS
          AND CP.FK_IdTipoPoliza__SIS = @FK_IdTipoPolizaConta__SIS;

        IF @@ERROR <> 0
        BEGIN
            SET @Error = CAST(@@ERROR AS NVARCHAR);
            GOTO ERR_HANDLER;
        END

        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRAN;
        RETURN 0;

        ERR_HANDLER:
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK;
        END
        RETURN 1;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK;
        END
        SET @Error = CONCAT('Error: ', ERROR_MESSAGE(), ' Línea: ', ERROR_LINE());
        RETURN 1;
    END CATCH
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [CONTA].[SP_MantenimientoPoliza] (
    @Action INT,
    @PKIdPoliza INT = NULL,
    @FKIdAnio_SIS INT = NULL,
    @FKIdMes_SIS INT = NULL,
    @FKIdTipoPoliza_SIS INT = NULL,
    @NombrePoliza NVARCHAR(1000) = NULL,
    @FechaPoliza DATETIME = NULL,
    @EstaBalanceado BIT = NULL,
    @PermitirModificar BIT = NULL,
    @FKIdAccionAutorizar_SIS INT = NULL,
    @Autorizado BIT = NULL,
    @FechaSolicitud DATETIME = NULL,
    @FechaAutorizacion DATETIME = NULL,
    @IdUser INT = NULL,
    @Id INT = NULL OUTPUT
)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(4000);
    DECLARE @errorMessage NVARCHAR(MAX);
    DECLARE @today DATETIME = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 1
        BEGIN
            DECLARE @ClavePoliza NVARCHAR(10);
            DECLARE @ErrMsg NVARCHAR(MAX);

            EXEC [CONTA].[SP_CREATE_ClavePoliza]
                @FK_IdAnio__SIS = @FKIdAnio_SIS,
                @FK_IdMesConta__SIS = @FKIdMes_SIS,
                @FK_IdTipoPolizaConta__SIS = @FKIdTipoPoliza_SIS,
                @CT_ModifiedBy = @IdUser,
                @ClavePoliza = @ClavePoliza OUTPUT,
                @Error = @ErrMsg OUTPUT;

            IF @ClavePoliza IS NULL OR @ClavePoliza = ''
            BEGIN
                SET @message = ISNULL(@ErrMsg, 'Error al generar clave de p�liza');
                SET @tipo = 'ERROR';
                GOTO ERR_HANDLER;
            END

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
                @FKIdAnio_SIS,
                @FKIdMes_SIS,
                @FKIdTipoPoliza_SIS,
                @ClavePoliza,
                @NombrePoliza,
                @FechaPoliza,
                ISNULL(@EstaBalanceado, 0),
                @PermitirModificar,
                @FKIdAccionAutorizar_SIS,
                @Autorizado,
                @FechaSolicitud,
                @FechaAutorizacion,
                1,
                @today,
                @IdUser
            );

            SET @Id = SCOPE_IDENTITY();
            SET @tipo = 'OK';
            SET @message = CONCAT('P�liza creada correctamente. Clave: ', @ClavePoliza);
        END
        ELSE IF @Action = 2
        BEGIN
            IF @PKIdPoliza IS NULL OR NOT EXISTS (SELECT 1 FROM CONTA.Poliza WHERE PKIdPoliza = @PKIdPoliza AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'P�liza no encontrada';
                GOTO ERR_HANDLER;
            END

            UPDATE CONTA.Poliza
            SET
                FKIdAnio_SIS = ISNULL(@FKIdAnio_SIS, FKIdAnio_SIS),
                FKIdMes_SIS = ISNULL(@FKIdMes_SIS, FKIdMes_SIS),
                FKIdTipoPoliza_SIS = ISNULL(@FKIdTipoPoliza_SIS, FKIdTipoPoliza_SIS),
                NombrePoliza = ISNULL(@NombrePoliza, NombrePoliza),
                FechaPoliza = ISNULL(@FechaPoliza, FechaPoliza),
                EstaBalanceado = ISNULL(@EstaBalanceado, EstaBalanceado),
                PermitirModificar = ISNULL(@PermitirModificar, PermitirModificar),
                FKIdAccionAutorizar_SIS = ISNULL(@FKIdAccionAutorizar_SIS, FKIdAccionAutorizar_SIS),
                Autorizado = ISNULL(@Autorizado, Autorizado),
                FechaSolicitud = ISNULL(@FechaSolicitud, FechaSolicitud),
                FechaAutorizacion = ISNULL(@FechaAutorizacion, FechaAutorizacion),
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @PKIdPoliza;

            SET @Id = @PKIdPoliza;
            SET @tipo = 'OK';
            SET @message = 'P�liza actualizada correctamente.';
        END
        ELSE IF @Action = 3
        BEGIN
            IF @PKIdPoliza IS NULL OR NOT EXISTS (SELECT 1 FROM CONTA.Poliza WHERE PKIdPoliza = @PKIdPoliza AND Activo = 1)
            BEGIN
                SET @tipo = 'ERROR';
                SET @message = 'P�liza no encontrada';
                GOTO ERR_HANDLER;
            END

            UPDATE CONTA.Poliza
            SET
                Activo = 0,
                FechaModificacion = @today,
                UsuarioModificacion = @IdUser
            WHERE PKIdPoliza = @PKIdPoliza;

            SET @Id = @PKIdPoliza;
            SET @tipo = 'OK';
            SET @message = 'P�liza eliminada correctamente.';
        END
        ELSE IF @Action = 4
        BEGIN
            SELECT
                p.PKIdPoliza,
                p.FKIdAnio_SIS,
                a.Clave AS AnioClave,
                p.FKIdMes_SIS,
                p.FKIdTipoPoliza_SIS,
                tp.Descripcion AS TipoPoliza,
                p.ClavePoliza,
                p.NombrePoliza,
                p.FechaPoliza,
                p.EstaBalanceado,
                p.PermitirModificar,
                p.FKIdAccionAutorizar_SIS,
                p.Autorizado,
                p.FechaSolicitud,
                p.FechaAutorizacion,
                p.Activo,
                p.FechaCreacion,
                p.UsuarioCreacion,
                p.FechaModificacion,
                p.UsuarioModificacion
            FROM CONTA.Poliza p
            LEFT JOIN SIS.Anio a ON p.FKIdAnio_SIS = a.PKIdAnio
            LEFT JOIN SIS.TipoPoliza tp ON p.FKIdTipoPoliza_SIS = tp.PKIdTipoPoliza
            WHERE p.PKIdPoliza = @PKIdPoliza;

            SET @tipo = 'OK';
            GOTO FINISH;
        END
        ELSE
        BEGIN
            SET @tipo = 'ERROR';
            SET @message = 'Acci�n no v�lida. Use 1=Insert, 2=Update, 3=Delete, 4=GetById';
            GOTO ERR_HANDLER;
        END

        FINISH:
        IF @@TRANCOUNT > 0 AND XACT_STATE() = 1
            COMMIT TRANSACTION;

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"', @tipo, '","mensaje":"', @message, '","liga":"idPoliza:', ISNULL(CAST(@Id AS NVARCHAR), ''), '"}')
        ) AS ResultJson;

        RETURN 0;

        ERR_HANDLER:
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            IF XACT_STATE() = 1
                ROLLBACK TRANSACTION;
            ELSE IF XACT_STATE() = -1
                ROLLBACK TRANSACTION;
        END

        SELECT @errorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'Línea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @errorMessage, '","liga":""}')
        ) AS ResultJson;

        RETURN -1;
    END CATCH
END
GO

PRINT 'Procedimientos de CONTA creados exitosamente.';
GO
