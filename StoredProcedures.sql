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

CREATE PROCEDURE [ALMA].[SP_CargaInicialConteo]
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

CREATE PROCEDURE [ALMA].[SP_MantenimientoTipoBien]
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
    @IdC INT = NULL,
    @IdUser INT = NULL,
    @Id INT = NULL OUTPUT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @tipo NVARCHAR(100);
    DECLARE @message NVARCHAR(100);
    DECLARE @FKIdPartidaCalculada INT;
    DECLARE @CABMSCalculada VARCHAR(50);

    BEGIN TRY
        IF @Action = 1
        BEGIN
            SET @FKIdPartidaCalculada = @FKIdPartida_CONTA;
            SET @CABMSCalculada = @CABMS;

            BEGIN TRANSACTION;

            INSERT INTO ALMA.TipoBien (
                FKIdGrupoBien_ALMA,
                FKIdNivel_ALMA,
                FKIdPartida_CONTA,
                FKIdCuentaContable_CONTA,
                FKIdUnidades_ALMA,
                FKIdLocalizacion_ALMA,
                FKIdUnidades_Equivalente,
                CodigoClave,
                Descripcion,
                DepreciacionAnual,
                Consecutivo,
                CABMS,
                Identificador,
                ExistenciaMinima,
                ExistenciaMaxima,
                TiempoVida,
                Pk_IdTratadoInt,
                Cuota,
                ProveeduriaNac,
                CatalogoBasico,
                CUCOP_PLUS,
                Cantidad_Equivalente,
                Activo,
                FechaCreacion,
                UsuarioCreacion,
                FechaModificacion,
                UsuarioModificacion
            )
            VALUES (
                @FKIdGrupoBien_ALMA,
                @FKIdNivel_ALMA,
                @FKIdPartidaCalculada,
                @FKIdCuentaContable_CONTA,
                @FKIdUnidades_ALMA,
                @FKIdLocalizacion_ALMA,
                @FKIdUnidades_Equivalente,
                @CodigoClave,
                @Descripcion,
                @DepreciacionAnual,
                @Consecutivo,
                @CABMSCalculada,
                @Identificador,
                @ExistenciaMinima,
                @ExistenciaMaxima,
                @TiempoVida,
                @Pk_IdTratadoInt,
                @Cuota,
                @ProveeduriaNac,
                @CatalogoBasico,
                @CUCOP_PLUS,
                @Cantidad_Equivalente,
                1,
                GETDATE(),
                @IdUser,
                NULL,
                NULL
            );

            SET @Id = SCOPE_IDENTITY();
            SET @tipo = 'OK';
            SET @message = 'Los datos se han guardado correctamente.';
        END
        ELSE IF @Action = 2
        BEGIN
            BEGIN TRANSACTION;

            UPDATE ALMA.TipoBien
            SET 
                FKIdGrupoBien_ALMA = @FKIdGrupoBien_ALMA,
                FKIdNivel_ALMA = @FKIdNivel_ALMA,
                FKIdPartida_CONTA = @FKIdPartida_CONTA,
                FKIdCuentaContable_CONTA = @FKIdCuentaContable_CONTA,
                FKIdUnidades_ALMA = @FKIdUnidades_ALMA,
                FKIdLocalizacion_ALMA = @FKIdLocalizacion_ALMA,
                FKIdUnidades_Equivalente = @FKIdUnidades_Equivalente,
                CodigoClave = @CodigoClave,
                Descripcion = @Descripcion,
                DepreciacionAnual = @DepreciacionAnual,
                Consecutivo = @Consecutivo,
                CABMS = @CABMS,
                Identificador = @Identificador,
                ExistenciaMinima = @ExistenciaMinima,
                ExistenciaMaxima = @ExistenciaMaxima,
                TiempoVida = @TiempoVida,
                Pk_IdTratadoInt = @Pk_IdTratadoInt,
                Cuota = @Cuota,
                ProveeduriaNac = @ProveeduriaNac,
                CatalogoBasico = @CatalogoBasico,
                CUCOP_PLUS = @CUCOP_PLUS,
                Cantidad_Equivalente = @Cantidad_Equivalente,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE PKIdTipoBien = @PKIdTipoBien;

            SET @Id = @PKIdTipoBien;
            SET @tipo = 'OK';
            SET @message = 'Los datos se han actualizado correctamente.';
        END
        ELSE IF @Action = 3
        BEGIN
            BEGIN TRANSACTION;

            UPDATE ALMA.TipoBien
            SET 
                Activo = 0,
                FechaModificacion = GETDATE(),
                UsuarioModificacion = @IdUser
            WHERE PKIdTipoBien = @IdC;

            SET @Id = @IdC;
            SET @tipo = 'OK';
            SET @message = 'Registro eliminado correctamente.';
        END
        ELSE
        BEGIN
            SET @tipo = 'ERROR';
            SET @message = 'Acci�n no v�lida. Use 1=Insert, 2=Update, 3=Delete';
            GOTO ERR_HANDLER;
        END

        IF @@TRANCOUNT > 0 COMMIT TRANSACTION;

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"', @tipo, '","mensaje":"', @message, '","liga":""}')
        ) AS ResultJson;

        RETURN 0;

    END TRY
    BEGIN CATCH
        ERR_HANDLER:
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage VARCHAR(MAX);
        SELECT @ErrorMessage = CONCAT(
            ISNULL(PROGRAM_NAME(), ''), CHAR(10),
            'Error: ', ERROR_MESSAGE(), CHAR(10),
            'L�nea: ', ERROR_LINE()
        );

        SELECT JSON_QUERY(
            CONCAT('{"tipo":"ERROR","mensaje":"', @ErrorMessage, '","liga":""}')
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

CREATE PROCEDURE [dbo].[sp_RegistrarEntidad]
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

CREATE PROCEDURE [dbo].[spConfiguracionDeRolYClaims]
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

CREATE PROCEDURE [SIS].[LoginInformationEmployee](
	@PayrollID NVARCHAR(60)
)
AS BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
	SELECT e.PkIdUsuario, e.FKIdPersona_NOM FKIdPersonaNOM, e.PayrollID, p.Gafete, ANU.PasswordHash, rol.Name, p.CORREO_ELECTRONICO AS Email, NombreUsuario = CONCAT(p.Nombre, ' ', p.Paterno, ' ', p.Materno)
	FROM SIS.Usuario AS e WITH (NOLOCK)
	INNER JOIN NOM.Persona p ON e.FKIdPersona_NOM = p.PKIdPersona
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

CREATE PROCEDURE [SIS].[spEliminarUsuarioSucursal]
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

CREATE PROCEDURE [SIS].[spGetClaimsByUser]
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

CREATE PROCEDURE [SIS].[spNodeMenu]
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

CREATE PROCEDURE [SIS].[WriteSystemLog] (
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

PRINT 'Stored Procedures creados exitosamente.';
GO
