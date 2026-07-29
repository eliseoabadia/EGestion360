USE [GestionEmpresarial];
GO
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* PAAAS: empresa forma parte de la unicidad; el mes pertenece al detalle. */
IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'ORCO.PAAAS') AND name = N'UQ_PAAAS_Area_Anio')
    ALTER TABLE [ORCO].[PAAAS] DROP CONSTRAINT [UQ_PAAAS_Area_Anio];
ELSE IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ORCO.PAAAS') AND name = N'UQ_PAAAS_Area_Anio')
    DROP INDEX [UQ_PAAAS_Area_Anio] ON [ORCO].[PAAAS];
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'ORCO.PAAAS') AND name = N'UQ_PAAAS_Empresa_Area_Anio')
    CREATE UNIQUE INDEX [UQ_PAAAS_Empresa_Area_Anio]
        ON [ORCO].[PAAAS]([FKIdEmpresa_SIS], [FKIdArea_SIS], [FKIdAnio_SIS]) WHERE [Activo] = 1;
GO
IF COL_LENGTH(N'ORCO.PAAASDetalle', N'FKIdMes_SIS') IS NULL
    ALTER TABLE [ORCO].[PAAASDetalle] ADD [FKIdMes_SIS] INT NULL;
GO
CREATE OR ALTER VIEW [ORCO].[Vw_PAAASDetalle]
AS
SELECT dp.PKIdPAAASDetalle, dp.FKIdEmpresa_SIS, dp.FKIdPAAASPartida_ORCO,
       dp.FKIdTipoBien_ALMA, dp.FKIdUnidades_ALMA, dp.FKIdMes_SIS,
       mes.Descripcion AS MesDescripcion, dp.Cantidad, dp.Observaciones, dp.LugarEntrega,
       dp.Activo, dp.FechaCreacion, dp.UsuarioCreacion, dp.FechaModificacion, dp.UsuarioModificacion,
       tb.Descripcion AS TipoBienDescripcion, tb.CodigoClave AS TipoBienCodigoClave,
       tb.CABMS, tb.Identificador, tb.ExistenciaMinima, tb.ExistenciaMaxima,
       u.Descripcion AS UnidadMedida, pp.FKIdPAAAS_ORCO, pp.FKIdPartida_CONTA,
       part.Clave AS PartidaClave, part.Descripcion AS PartidaDescripcion,
       CONCAT(tb.CodigoClave, ' - ', tb.Descripcion) AS BienClaveNombre
FROM ORCO.PAAASDetalle dp
LEFT JOIN ALMA.TipoBien tb ON dp.FKIdTipoBien_ALMA = tb.PKIdTipoBien AND tb.Activo = 1
LEFT JOIN ALMA.Unidades u ON dp.FKIdUnidades_ALMA = u.PKIdUnidades AND u.Activo = 1
LEFT JOIN SIS.Mes mes ON dp.FKIdMes_SIS = mes.PKIdMes AND mes.Activo = 1
LEFT JOIN ORCO.PAAASPartida pp ON dp.FKIdPAAASPartida_ORCO = pp.PKIdPAAASPartida AND pp.Activo = 1
LEFT JOIN CONTA.Partida part ON pp.FKIdPartida_CONTA = part.PKIdPartida AND part.Activo = 1
WHERE dp.Activo = 1;
GO

CREATE OR ALTER PROCEDURE [ORCO].[SP_MantenimientoPAAASV2]
    @Action INT, @PKIdPAAAS INT = NULL, @PKIdPAAASPartida INT = NULL,
    @PKIdPAAASDetalle INT = NULL, @FKIdEmpresa_SIS INT = NULL, @FKIdAnio_SIS INT = NULL,
    @FKIdArea_SIS INT = NULL, @FKIdPersona_NOM INT = NULL, @Descripcion NVARCHAR(100) = NULL,
    @Observaciones NVARCHAR(MAX) = NULL, @Fecha DATETIME = NULL, @FKIdProyecto_ORCO INT = NULL,
    @FKIdPrograma_PRES INT = NULL, @FKIdFuenteFinanciamiento_PRES INT = NULL,
    @FKIdPartida_CONTA INT = NULL, @FKIdTipoBien_ALMA INT = NULL,
    @FKIdUnidades_ALMA INT = NULL, @FKIdMes_SIS INT = NULL,
    @Cantidad NUMERIC(8,2) = NULL, @LugarEntrega VARCHAR(200) = NULL, @IdUser INT = NULL
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @PaaaControl INT = @PKIdPAAAS, @Id INT, @Json NVARCHAR(MAX);

    IF @PaaaControl IS NULL AND @PKIdPAAASPartida IS NOT NULL
        SELECT @PaaaControl = FKIdPAAAS_ORCO FROM ORCO.PAAASPartida WHERE PKIdPAAASPartida = @PKIdPAAASPartida;
    IF @PaaaControl IS NULL AND @PKIdPAAASDetalle IS NOT NULL
        SELECT @PaaaControl = p.FKIdPAAAS_ORCO FROM ORCO.PAAASDetalle d
        JOIN ORCO.PAAASPartida p ON p.PKIdPAAASPartida=d.FKIdPAAASPartida_ORCO
        WHERE d.PKIdPAAASDetalle=@PKIdPAAASDetalle;

    IF @PaaaControl IS NOT NULL AND EXISTS (
        SELECT 1 FROM ORCO.EstudioMercadoDetalle emd
        JOIN ORCO.EstudioMercado em ON em.PKIdEstudioMercado=emd.FKIdEstudioMercado_ORCO
        JOIN ORCO.PAAASDetalle d ON d.PKIdPAAASDetalle=emd.FKIdPAAASDetalle_ORCO
        JOIN ORCO.PAAASPartida p ON p.PKIdPAAASPartida=d.FKIdPAAASPartida_ORCO
        WHERE p.FKIdPAAAS_ORCO=@PaaaControl AND emd.Activo=1 AND em.Activo=1 AND em.Estatus<>5)
        THROW 51000, 'El PAAAS esta bloqueado por un estudio de mercado activo.', 1;

    IF @Action=1
    BEGIN
        IF EXISTS(SELECT 1 FROM ORCO.PAAAS WHERE FKIdEmpresa_SIS=@FKIdEmpresa_SIS AND FKIdArea_SIS=@FKIdArea_SIS AND FKIdAnio_SIS=@FKIdAnio_SIS AND Activo=1)
            THROW 51000,'Ya existe un programa anual activo para la empresa, anio y area.',1;
        INSERT ORCO.PAAAS(FKIdEmpresa_SIS,FKIdAnio_SIS,FKIdArea_SIS,FKIdPersona_NOM,Descripcion,Observaciones,Fecha,
            FKIdProyecto_ORCO,FKIdPrograma_PRES,FKIdFuenteFinanciamiento_PRES,Activo,FechaCreacion,UsuarioCreacion)
        VALUES(@FKIdEmpresa_SIS,@FKIdAnio_SIS,@FKIdArea_SIS,@FKIdPersona_NOM,@Descripcion,@Observaciones,COALESCE(@Fecha,GETDATE()),
            @FKIdProyecto_ORCO,@FKIdPrograma_PRES,@FKIdFuenteFinanciamiento_PRES,1,SYSDATETIME(),@IdUser);
        SET @Id=SCOPE_IDENTITY();
        SELECT (SELECT 'OK' tipo,'Programa anual creado correctamente.' mensaje,CONCAT('idPAAAS:',@Id) liga FOR JSON PATH,WITHOUT_ARRAY_WRAPPER) ResultJson;
        RETURN;
    END
    IF @Action=2
    BEGIN
        IF NOT EXISTS(SELECT 1 FROM ORCO.PAAAS WHERE PKIdPAAAS=@PKIdPAAAS AND FKIdEmpresa_SIS=@FKIdEmpresa_SIS AND Activo=1)
            THROW 51000,'El programa no pertenece a la empresa actual.',1;
        IF EXISTS(SELECT 1 FROM ORCO.PAAAS WHERE PKIdPAAAS<>@PKIdPAAAS AND FKIdEmpresa_SIS=@FKIdEmpresa_SIS AND FKIdArea_SIS=@FKIdArea_SIS AND FKIdAnio_SIS=@FKIdAnio_SIS AND Activo=1)
            THROW 51000,'Ya existe otro programa anual activo para la empresa, anio y area.',1;
        UPDATE ORCO.PAAAS SET FKIdAnio_SIS=@FKIdAnio_SIS,FKIdArea_SIS=@FKIdArea_SIS,FKIdPersona_NOM=@FKIdPersona_NOM,
            Descripcion=@Descripcion,Observaciones=@Observaciones,Fecha=COALESCE(@Fecha,Fecha),FKIdProyecto_ORCO=@FKIdProyecto_ORCO,
            FKIdPrograma_PRES=@FKIdPrograma_PRES,FKIdFuenteFinanciamiento_PRES=@FKIdFuenteFinanciamiento_PRES,
            FechaModificacion=SYSDATETIME(),UsuarioModificacion=@IdUser WHERE PKIdPAAAS=@PKIdPAAAS;
        SELECT (SELECT 'OK' tipo,'Programa anual actualizado correctamente.' mensaje,CONCAT('idPAAAS:',@PKIdPAAAS) liga FOR JSON PATH,WITHOUT_ARRAY_WRAPPER) ResultJson;
        RETURN;
    END

    IF @Action IN (7,8)
    BEGIN
        IF @FKIdMes_SIS IS NULL OR NOT EXISTS (SELECT 1 FROM SIS.Mes WHERE PKIdMes=@FKIdMes_SIS AND Activo=1)
            THROW 51000, 'Debe seleccionar un mes activo.', 1;
        IF ISNULL(@Cantidad,0)<=0 THROW 51000, 'La cantidad debe ser mayor a cero.', 1;
        IF NOT EXISTS (SELECT 1 FROM ORCO.PAAASPartida p JOIN ALMA.TipoBien tb ON tb.FKIdPartida_CONTA=p.FKIdPartida_CONTA
                       WHERE p.PKIdPAAASPartida=@PKIdPAAASPartida AND p.Activo=1 AND tb.PKIdTipoBien=@FKIdTipoBien_ALMA AND tb.Activo=1)
            THROW 51000, 'El tipo de bien no pertenece a la partida seleccionada.', 1;
        IF EXISTS (SELECT 1 FROM ORCO.PAAASDetalle WHERE FKIdPAAASPartida_ORCO=@PKIdPAAASPartida
                   AND FKIdTipoBien_ALMA=@FKIdTipoBien_ALMA AND FKIdMes_SIS=@FKIdMes_SIS AND Activo=1
                   AND (@Action=7 OR PKIdPAAASDetalle<>@PKIdPAAASDetalle))
            THROW 51000, 'El bien ya esta programado en esta partida y mes.', 1;

        IF @Action=7
        BEGIN
            INSERT ORCO.PAAASDetalle(FKIdEmpresa_SIS,FKIdPAAASPartida_ORCO,FKIdTipoBien_ALMA,FKIdUnidades_ALMA,
                FKIdMes_SIS,Cantidad,Observaciones,LugarEntrega,Activo,FechaCreacion,UsuarioCreacion)
            SELECT p.FKIdEmpresa_SIS,@PKIdPAAASPartida,@FKIdTipoBien_ALMA,COALESCE(@FKIdUnidades_ALMA,tb.FKIdUnidades_ALMA),
                @FKIdMes_SIS,@Cantidad,ISNULL(@Observaciones,''),ISNULL(@LugarEntrega,''),1,SYSDATETIME(),@IdUser
            FROM ORCO.PAAASPartida p JOIN ALMA.TipoBien tb ON tb.PKIdTipoBien=@FKIdTipoBien_ALMA
            WHERE p.PKIdPAAASPartida=@PKIdPAAASPartida;
            SET @Id=SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE ORCO.PAAASDetalle SET FKIdTipoBien_ALMA=@FKIdTipoBien_ALMA,
                FKIdUnidades_ALMA=COALESCE(@FKIdUnidades_ALMA,FKIdUnidades_ALMA), FKIdMes_SIS=@FKIdMes_SIS,
                Cantidad=@Cantidad,Observaciones=ISNULL(@Observaciones,''),LugarEntrega=ISNULL(@LugarEntrega,''),
                FechaModificacion=SYSDATETIME(),UsuarioModificacion=@IdUser
            WHERE PKIdPAAASDetalle=@PKIdPAAASDetalle AND Activo=1;
            SET @Id=@PKIdPAAASDetalle;
        END
        SELECT (SELECT 'OK' tipo, CASE WHEN @Action=7 THEN 'Tipo de bien agregado correctamente.' ELSE 'Tipo de bien actualizado correctamente.' END mensaje,
            CONCAT('idPAAASDetalle:',@Id) liga FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) ResultJson;
        RETURN;
    END

    DECLARE @R TABLE(ResultJson NVARCHAR(MAX));
    INSERT @R EXEC ORCO.SP_MantenimientoPAAAS @Action=@Action,@PKIdPAAAS=@PKIdPAAAS,
        @PKIdPAAASPartida=@PKIdPAAASPartida,@PKIdPAAASDetalle=@PKIdPAAASDetalle,@FKIdEmpresa_SIS=@FKIdEmpresa_SIS,
        @FKIdAnio_SIS=@FKIdAnio_SIS,@FKIdArea_SIS=@FKIdArea_SIS,@FKIdPersona_NOM=@FKIdPersona_NOM,
        @Descripcion=@Descripcion,@Observaciones=@Observaciones,@Fecha=@Fecha,@FKIdProyecto_ORCO=@FKIdProyecto_ORCO,
        @FKIdPrograma_PRES=@FKIdPrograma_PRES,@FKIdFuenteFinanciamiento_PRES=@FKIdFuenteFinanciamiento_PRES,
        @FKIdPartida_CONTA=@FKIdPartida_CONTA,@FKIdTipoBien_ALMA=@FKIdTipoBien_ALMA,
        @FKIdUnidades_ALMA=@FKIdUnidades_ALMA,@Cantidad=@Cantidad,@LugarEntrega=@LugarEntrega,@IdUser=@IdUser;
    SELECT ResultJson FROM @R;
END
GO

CREATE OR ALTER PROCEDURE [ORCO].[SP_ReportePAAAS] @PKIdPAAAS INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.PKIdPAAAS,p.AnioClave,p.AreaNombre,p.ResponsableCompleto,p.ProgramaClave,p.ProgramaDescripcion,
           p.FuenteFinanciamientoClave,p.FuenteFinanciamientoDescripcion,p.Descripcion,p.Observaciones,p.Fecha,
           pp.PKIdPAAASPartida,pp.PartidaClave,pp.PartidaDescripcion,d.PKIdPAAASDetalle,d.TipoBienCodigoClave,
           d.TipoBienDescripcion,d.UnidadMedida,d.FKIdMes_SIS,d.MesDescripcion,d.Cantidad,d.LugarEntrega,
           d.Observaciones AS DetalleObservaciones
    FROM ORCO.Vw_PAAAS p LEFT JOIN ORCO.Vw_PAAASPartida pp ON pp.FKIdPAAAS_ORCO=p.PKIdPAAAS
    LEFT JOIN ORCO.Vw_PAAASDetalle d ON d.FKIdPAAASPartida_ORCO=pp.PKIdPAAASPartida
    WHERE p.PKIdPAAAS=@PKIdPAAAS ORDER BY pp.PartidaClave,d.FKIdMes_SIS,d.TipoBienDescripcion;
END
GO

/* Bienes: pertenencia obligatoria a empresa. No se migran los 18 faltantes con tipos sin equivalencia. */
IF COL_LENGTH(N'ALMA.Bien', N'FKIdEmpresa_SIS') IS NULL
    ALTER TABLE ALMA.Bien ADD FKIdEmpresa_SIS INT NULL;
GO
DROP TRIGGER IF EXISTS [ALMA].[TR_Bien_ControlDirecto];
GO
DECLARE @EmpresaDefault INT=(SELECT TOP(1) PKIdEmpresa FROM SIS.Empresa WHERE Activo=1 ORDER BY PKIdEmpresa);
UPDATE b SET FKIdEmpresa_SIS=COALESCE(oc.FKIdEmpresa_SIS,r.FKIdEmpresa_SIS,@EmpresaDefault)
FROM ALMA.Bien b
LEFT JOIN ORCO.OrdenCompraDetalle od ON od.PKIdOrdenCompraDetalle=b.FKIdDetalleOrdenCompra_ORCO
LEFT JOIN ORCO.OrdenCompra oc ON oc.PKIdOrdenCompra=od.FKIdOrdenCompra_ORCO
OUTER APPLY (SELECT TOP(1) rg.FKIdEmpresa_SIS FROM ALMA.ResguardoDetalle rd JOIN ALMA.Resguardo rg
             ON rg.PKIdResguardo=rd.FKIdResguardo_ALMA WHERE rd.FKIdBien_ALMA=b.PKIdBien AND rd.Activo=1 AND rg.Activo=1) r
WHERE b.FKIdEmpresa_SIS IS NULL;
GO
ALTER TABLE ALMA.Bien ALTER COLUMN FKIdEmpresa_SIS INT NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id=OBJECT_ID(N'ALMA.Bien') AND name=N'DF_Bien_EmpresaContexto')
    ALTER TABLE ALMA.Bien ADD CONSTRAINT DF_Bien_EmpresaContexto
        DEFAULT (CONVERT(INT,SESSION_CONTEXT(N'EmpresaId'))) FOR FKIdEmpresa_SIS;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE parent_object_id=OBJECT_ID(N'ALMA.Bien') AND name=N'FK_Bien_Empresa')
    ALTER TABLE ALMA.Bien WITH CHECK ADD CONSTRAINT FK_Bien_Empresa FOREIGN KEY(FKIdEmpresa_SIS) REFERENCES SIS.Empresa(PKIdEmpresa);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'ALMA.Bien') AND name=N'IX_Bien_FKIdEmpresa_SIS')
    CREATE INDEX IX_Bien_FKIdEmpresa_SIS ON ALMA.Bien(FKIdEmpresa_SIS,Activo);
GO

CREATE OR ALTER VIEW [ALMA].[Vw_Bien]
AS
SELECT b.PKIdBien,b.FKIdEmpresa_SIS,b.Clave,b.ClaveAnt,b.Descripcion,b.Modelo,b.Serie,b.Costo,b.FechaAdq,b.Factura,
 b.Requisicion,b.Referencia,b.Notas,b.Ubicacion,b.AAdquisicion,b.Frente,b.Fondo,b.Altura,b.Diametro,
 b.VerificacionesDias,b.MantenimientoDias,b.Mantenimiento,b.Calibracion,b.Rango,b.Resolucion,b.FechaUltInv,
 b.FechaReqscn,b.Estatus,b.Caracteristicas,b.Resguardo,b.ResguardoAnterior,b.RelId,b.ValorRescate,b.ValorActual,
 b.Antiguedad,b.Progresivo,b.Consecutivo,b.ClaveHist,b.EstaResguardado,b.FechaResguardado,b.Localizado,
 b.esContabilizado,b.Activo,b.FechaCreacion,b.UsuarioCreacion,b.FechaModificacion,b.UsuarioModificacion,
 gb.Descripcion GrupoBienDescripcion,gb.Clave GrupoBienClave,tb.CodigoClave TipoBienCodigoClave,
 tb.Descripcion TipoBienDescripcion,tb.CABMS TipoBienCABMS,tb.Identificador TipoBienIdentificador,tb.CUCOP_PLUS TipoBienCUCOP_PLUS,
 a.Nombre AreaNombre,a.Clave AreaClave,p.Nombre ProveedorNombre,p.RFC ProveedorRFC,p.Clave ProveedorClave,
 eb.DESCRIPCION_GENERAL EstadoBienDescripcionGeneral,eb.DESCRIPCION_ESPECIFICA EstadoBienDescripcionEspecifica,
 eb.DESCRIPCION_CORTA EstadoBienDescripcionCorta,tp.Descripcion TipoPatrimonioDescripcion,m.Descripcion MarcaDescripcion,
 mat.Descripcion MaterialDescripcion,ta.Clave TipoAdquisicionClave,ta.Descripcion TipoAdquisicionDescripcion,
 ta.Descripmovto TipoAdquisicionDescripcionMovto,part.Clave PartidaClave,part.Descripcion PartidaDescripcion
FROM ALMA.Bien b LEFT JOIN ALMA.GrupoBien gb ON b.FKIdGrupoBien_ALMA=gb.PKIdGrupoBien
LEFT JOIN ALMA.TipoBien tb ON b.FKIdTipoBien_ALMA=tb.PKIdTipoBien LEFT JOIN SIS.Area a ON b.FKIdArea_SIS=a.PKIdArea
LEFT JOIN SIS.Proveedor p ON b.FKIdProveedor_SIS=p.PKIdProveedor LEFT JOIN ALMA.EstadoBien eb ON b.FKIdEstadoBien_ALMA=eb.PKIdEstadoBien
LEFT JOIN ALMA.TipoPatrimonio tp ON b.FKIdTipoPatrimonio_ALMA=tp.PKIdTipoPatrimonio LEFT JOIN ALMA.Marca m ON b.FKIdMarca_ALMA=m.PKIdMarca
LEFT JOIN ALMA.Material mat ON b.FKIdMaterial_ALMA=mat.PKIdMaterial LEFT JOIN ALMA.TipoAdquisicion ta ON b.FKIdTipoAdq_ALMA=ta.PKIdTipoAdq
LEFT JOIN CONTA.Partida part ON b.FKIdPartida_CONTA=part.PKIdPartida;
GO

CREATE OR ALTER TRIGGER [ALMA].[TR_Bien_ControlDirecto] ON [ALMA].[Bien] AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN deleted d ON d.PKIdBien=i.PKIdBien
   WHERE (d.EstaResguardado=1 OR d.esContabilizado=1 OR EXISTS(SELECT 1 FROM ALMA.Bajas b WHERE b.FKIdBien_ALMA=i.PKIdBien AND b.Activo=1))
   AND (ISNULL(i.FKIdTipoBien_ALMA,0)<>ISNULL(d.FKIdTipoBien_ALMA,0) OR ISNULL(i.FechaAdq,'19000101')<>ISNULL(d.FechaAdq,'19000101')
        OR ISNULL(i.Factura,'')<>ISNULL(d.Factura,'') OR ISNULL(i.Descripcion,'')<>ISNULL(d.Descripcion,'')))
   THROW 51000,'El bien no puede editarse porque esta resguardado, contabilizado o en proceso de baja.',1;
END
GO

CREATE OR ALTER PROCEDURE [ALMA].[SP_MantenimientoBienEmpresa]
 @Action INT,@PKIdBien INT=NULL,@FKIdEmpresa_SIS INT=NULL,@FKIdGrupoBien_ALMA INT=NULL,@FKIdTipoBien_ALMA INT=NULL,
 @FKIdArea_SIS INT=NULL,@FKIdProveedor_SIS INT=NULL,@FKIdEstadoBien_ALMA INT=NULL,@FKIdTipoPatrimonio_ALMA INT=NULL,
 @FKIdMarca_ALMA INT=NULL,@FKIdMaterial_ALMA INT=NULL,@FKIdTipoAdq_ALMA INT=NULL,@FKIdPartida_CONTA INT=NULL,
 @FKIdDetalleOrdenCompra_ORCO INT=NULL,@Clave NVARCHAR(50)=NULL,@ClaveAnt NVARCHAR(50)=NULL,
 @Descripcion NVARCHAR(1000)=NULL,@Modelo NVARCHAR(50)=NULL,@Serie NVARCHAR(1000)=NULL,@Requisicion NVARCHAR(25)=NULL,
 @Factura NVARCHAR(50)=NULL,@Costo DECIMAL(20,4)=NULL,@ValorActual DECIMAL(20,4)=NULL,@FechaAdq DATETIME=NULL,
 @Referencia NVARCHAR(50)=NULL,@Notas NVARCHAR(250)=NULL,@Ubicacion NVARCHAR(50)=NULL,@AAdquisicion NVARCHAR(2)=NULL,
 @Frente INT=NULL,@Fondo INT=NULL,@Altura INT=NULL,@Diametro INT=NULL,@VerificacionesDias INT=NULL,
 @MantenimientoDias INT=NULL,@Mantenimiento BIT=NULL,@Calibracion BIT=NULL,@Rango NVARCHAR(20)=NULL,
 @Resolucion NVARCHAR(20)=NULL,@FechaUltInv DATETIME=NULL,@FechaReqscn DATETIME=NULL,@Estatus NVARCHAR(1)=NULL,
 @Caracteristicas NVARCHAR(50)=NULL,@Resguardo INT=NULL,@ValorRescate DECIMAL(20,4)=NULL,@Localizado BIT=NULL,
 @EsContabilizado BIT=NULL,@LiberarResguardo BIT=0,@PropagarOrdenCompra BIT=1,@IdBaja INT=NULL,@IdUser INT=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @FKIdEmpresa_SIS IS NULL OR NOT EXISTS(SELECT 1 FROM SIS.Empresa WHERE PKIdEmpresa=@FKIdEmpresa_SIS AND Activo=1)
   THROW 51000,'La empresa actual no es valida.',1;
 IF @Action=2 AND NOT EXISTS(SELECT 1 FROM ALMA.Bien WHERE PKIdBien=@PKIdBien AND FKIdEmpresa_SIS=@FKIdEmpresa_SIS AND Activo=1)
   THROW 51000,'El bien no pertenece a la empresa actual.',1;
 IF @Action=3 THROW 51000,'Use el proceso formal de baja para retirar un bien.',1;
 DECLARE @GeneratedId INT;
 DECLARE @R TABLE(ResultJson NVARCHAR(MAX));
 EXEC sys.sp_set_session_context @key=N'EmpresaId',@value=@FKIdEmpresa_SIS;
 INSERT @R EXEC ALMA.SP_MantenimientoBien @Action=@Action,@PKIdBien=@PKIdBien,
  @FKIdGrupoBien_ALMA=@FKIdGrupoBien_ALMA,@FKIdTipoBien_ALMA=@FKIdTipoBien_ALMA,@FKIdArea_SIS=@FKIdArea_SIS,
  @FKIdProveedor_SIS=@FKIdProveedor_SIS,@FKIdEstadoBien_ALMA=@FKIdEstadoBien_ALMA,
  @FKIdTipoPatrimonio_ALMA=@FKIdTipoPatrimonio_ALMA,@FKIdMarca_ALMA=@FKIdMarca_ALMA,
  @FKIdMaterial_ALMA=@FKIdMaterial_ALMA,@FKIdTipoAdq_ALMA=@FKIdTipoAdq_ALMA,@FKIdPartida_CONTA=@FKIdPartida_CONTA,
  @FKIdDetalleOrdenCompra_ORCO=@FKIdDetalleOrdenCompra_ORCO,@Clave=@Clave,@ClaveAnt=@ClaveAnt,@Descripcion=@Descripcion,
  @Modelo=@Modelo,@Serie=@Serie,@Requisicion=@Requisicion,@Factura=@Factura,@Costo=@Costo,@ValorActual=@ValorActual,
  @FechaAdq=@FechaAdq,@Referencia=@Referencia,@Notas=@Notas,@Ubicacion=@Ubicacion,@AAdquisicion=@AAdquisicion,
  @Frente=@Frente,@Fondo=@Fondo,@Altura=@Altura,@Diametro=@Diametro,@VerificacionesDias=@VerificacionesDias,
  @MantenimientoDias=@MantenimientoDias,@Mantenimiento=@Mantenimiento,@Calibracion=@Calibracion,@Rango=@Rango,
  @Resolucion=@Resolucion,@FechaUltInv=@FechaUltInv,@FechaReqscn=@FechaReqscn,@Estatus=@Estatus,
  @Caracteristicas=@Caracteristicas,@Resguardo=@Resguardo,@ValorRescate=@ValorRescate,@Localizado=@Localizado,
  @EsContabilizado=@EsContabilizado,@LiberarResguardo=@LiberarResguardo,@PropagarOrdenCompra=@PropagarOrdenCompra,
  @IdBaja=@IdBaja,@IdUser=@IdUser,@Id=@GeneratedId OUTPUT;
 SET @GeneratedId=COALESCE(@GeneratedId,@PKIdBien);
 IF @GeneratedId IS NOT NULL UPDATE ALMA.Bien SET FKIdEmpresa_SIS=@FKIdEmpresa_SIS WHERE PKIdBien=@GeneratedId;
 SELECT ResultJson FROM @R;
END
GO

/* Cierre de recepción: estatus de OC y póliza balanceada de entrada patrimonial. */
DECLARE @UsuarioSistema INT=(SELECT TOP(1) PkIdUsuario FROM SIS.Usuario WHERE Activo=1 ORDER BY PkIdUsuario);
IF NOT EXISTS(SELECT 1 FROM CONTA.CuentaEspecial WHERE Clave=N'ENTRADA_PATRIMONIO_CUENTA_CARGO' AND Activo=1)
   AND EXISTS(SELECT 1 FROM CONTA.CuentaContable WHERE PKIdCuentaContable=259900 AND Activo=1)
 INSERT CONTA.CuentaEspecial(Clave,FKIdCuentaContable_CONTA,Descripcion,Activo,FechaCreacion,UsuarioCreacion)
 VALUES(N'ENTRADA_PATRIMONIO_CUENTA_CARGO',259900,N'Cargo por entrada de bienes patrimoniales',1,SYSDATETIME(),@UsuarioSistema);
IF NOT EXISTS(SELECT 1 FROM CONTA.CuentaEspecial WHERE Clave=N'ENTRADA_PATRIMONIO_CUENTA_ABONO' AND Activo=1)
   AND EXISTS(SELECT 1 FROM CONTA.CuentaContable WHERE PKIdCuentaContable=257075 AND Activo=1)
 INSERT CONTA.CuentaEspecial(Clave,FKIdCuentaContable_CONTA,Descripcion,Activo,FechaCreacion,UsuarioCreacion)
 VALUES(N'ENTRADA_PATRIMONIO_CUENTA_ABONO',257075,N'Abono por salida de almacén a patrimonio',1,SYSDATETIME(),@UsuarioSistema);
GO

CREATE OR ALTER PROCEDURE [ALMA].[SP_CerrarRecepcionPatrimonial]
 @DetalleOrdenCompraId INT,@EmpresaId INT,@UsuarioId INT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 DECLARE @OrdenId INT,@Completa BIT=0,@PolizaId INT,@Cargo INT,@Abono INT,@Total DECIMAL(20,4),@Fecha DATE,@AnioId INT;
 SELECT @OrdenId=oc.PKIdOrdenCompra,@Fecha=oc.FechaOrdenCompra FROM ORCO.OrdenCompraDetalle d
 JOIN ORCO.OrdenCompra oc ON oc.PKIdOrdenCompra=d.FKIdOrdenCompra_ORCO
 WHERE d.PKIdOrdenCompraDetalle=@DetalleOrdenCompraId AND d.Activo=1 AND oc.Activo=1 AND oc.FKIdEmpresa_SIS=@EmpresaId;
 IF @OrdenId IS NULL THROW 51000,'La orden no pertenece a la empresa actual.',1;

 IF NOT EXISTS(SELECT 1 FROM ORCO.OrdenCompraDetalle d WHERE d.FKIdOrdenCompra_ORCO=@OrdenId AND d.Activo=1 AND
   (ISNULL(d.CantidadRecibida,0)<d.CantidadSolicitada OR
    (SELECT COUNT(*) FROM ALMA.Bien b WHERE b.FKIdDetalleOrdenCompra_ORCO=d.PKIdOrdenCompraDetalle AND b.Activo=1)<FLOOR(ISNULL(d.CantidadRecibida,0))))
   SET @Completa=1;
 UPDATE ORCO.OrdenCompra SET FKIdEstatusOrdenCompra_ORCO=CASE WHEN @Completa=1 THEN 4 ELSE 3 END,
   FechaModificacion=SYSDATETIME(),UsuarioModificacion=@UsuarioId WHERE PKIdOrdenCompra=@OrdenId;

 IF @Completa=1 AND NOT EXISTS(SELECT 1 FROM ORCO.OrdenCompra WHERE PKIdOrdenCompra=@OrdenId AND FKIdPoliza_CONTA IS NOT NULL)
 BEGIN
  SELECT @Cargo=FKIdCuentaContable_CONTA FROM CONTA.CuentaEspecial WHERE Clave=N'ENTRADA_PATRIMONIO_CUENTA_CARGO' AND Activo=1;
  SELECT @Abono=FKIdCuentaContable_CONTA FROM CONTA.CuentaEspecial WHERE Clave=N'ENTRADA_PATRIMONIO_CUENTA_ABONO' AND Activo=1;
  SELECT @Total=SUM(ISNULL(b.Costo,b.ValorActual)) FROM ALMA.Bien b JOIN ORCO.OrdenCompraDetalle d
   ON d.PKIdOrdenCompraDetalle=b.FKIdDetalleOrdenCompra_ORCO WHERE d.FKIdOrdenCompra_ORCO=@OrdenId AND b.Activo=1;
  SELECT TOP(1) @AnioId=PKIdAnio FROM SIS.Anio WHERE Clave=YEAR(@Fecha) AND Activo=1;
  IF @Cargo IS NULL OR @Abono IS NULL OR @AnioId IS NULL OR ISNULL(@Total,0)<=0
    THROW 51000,'No se puede contabilizar la recepción: faltan cuentas especiales, ejercicio o importe.',1;
  INSERT CONTA.Poliza(FKIdAnio_SIS,FKIdMes_SIS,FKIdTipoPoliza_SIS,ClavePoliza,NombrePoliza,FechaPoliza,
    EstaBalanceado,Activo,FechaCreacion,UsuarioCreacion,PermitirModificar,Autorizado)
  VALUES(@AnioId,MONTH(@Fecha),1,CONCAT('EP',@OrdenId),CONCAT('Entrada patrimonial OC ',@OrdenId),@Fecha,1,1,SYSDATETIME(),@UsuarioId,0,0);
  SET @PolizaId=SCOPE_IDENTITY();
  INSERT CONTA.PolizaDetalle(FKIdCuentaContable_CONTA,FKIdPoliza_CONTA,Descripcion,ImporteDebe,ImporteHaber,
    FKIdReferencia,FKIdTipoDetallePoliza_SIS,Activo,FechaCreacion,UsuarioCreacion)
  VALUES(@Cargo,@PolizaId,N'Entrada de bienes patrimoniales',@Total,0,@OrdenId,3,1,SYSDATETIME(),@UsuarioId),
        (@Abono,@PolizaId,N'Salida de almacén a patrimonio',0,@Total,@OrdenId,4,1,SYSDATETIME(),@UsuarioId);
  UPDATE ORCO.OrdenCompra SET FKIdPoliza_CONTA=@PolizaId WHERE PKIdOrdenCompra=@OrdenId;
  UPDATE b SET esContabilizado=1,FechaModificacion=SYSDATETIME(),UsuarioModificacion=@UsuarioId
   FROM ALMA.Bien b JOIN ORCO.OrdenCompraDetalle d ON d.PKIdOrdenCompraDetalle=b.FKIdDetalleOrdenCompra_ORCO
   WHERE d.FKIdOrdenCompra_ORCO=@OrdenId AND b.Activo=1;
 END
END
GO
