USE [GestionEmpresarial];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF SCHEMA_ID(N'PBR') IS NULL
    EXEC(N'CREATE SCHEMA PBR AUTHORIZATION dbo;');
GO

IF OBJECT_ID(N'PBR.MigracionMap', N'U') IS NULL
BEGIN
    CREATE TABLE PBR.MigracionMap
    (
        EntidadOrigen sysname NOT NULL,
        IdOrigen int NOT NULL,
        EntidadDestino nvarchar(256) NOT NULL,
        IdDestino int NOT NULL,
        Clave nvarchar(100) NULL,
        Descripcion nvarchar(1000) NULL,
        FechaMigracion datetime2(7) NOT NULL CONSTRAINT DF_PBR_MigracionMap_Fecha DEFAULT sysdatetime(),
        CONSTRAINT PK_PBR_MigracionMap PRIMARY KEY (EntidadOrigen, IdOrigen)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[AlertaConfig])
BEGIN
    SET IDENTITY_INSERT PBR.[AlertaConfig] ON;
    INSERT INTO PBR.[AlertaConfig] ([PKIdAlertaConfig], [FKIdProgramaPresupuestario_PBR], [FKIdIndicador_PBR], [Nombre], [Tipo], [Umbral], [Direccion], [Activa], [UltimaRevision], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdAlertaConfig], [FKIdProgramaPresupuestario_PBR], [FKIdIndicador_PBR], [Nombre], [Tipo], [Umbral], [Direccion], [Activa], [UltimaRevision], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[AlertaConfig];
    SET IDENTITY_INSERT PBR.[AlertaConfig] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[AuditoriaCambio])
BEGIN
    SET IDENTITY_INSERT PBR.[AuditoriaCambio] ON;
    INSERT INTO PBR.[AuditoriaCambio] ([PKIdAuditoria], [Entidad], [EntidadId], [Accion], [FKIdUsuario_PBR], [Cambios], [Ip], [FechaCreacion])
    SELECT [PKIdAuditoria], [Entidad], [EntidadId], [Accion], [FKIdUsuario_PBR], [Cambios], [Ip], [FechaCreacion]
    FROM [GE_Datos].PBR.[AuditoriaCambio];
    SET IDENTITY_INSERT PBR.[AuditoriaCambio] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ConfiguracionSistema])
BEGIN
    SET IDENTITY_INSERT PBR.[ConfiguracionSistema] ON;
    INSERT INTO PBR.[ConfiguracionSistema] ([PKIdConfiguracion], [Clave], [Valor], [Tipo], [Descripcion], [Modulo], [Activo], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdConfiguracion], [Clave], [Valor], [Tipo], [Descripcion], [Modulo], [Activo], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[ConfiguracionSistema];
    SET IDENTITY_INSERT PBR.[ConfiguracionSistema] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Notificacion])
BEGIN
    SET IDENTITY_INSERT PBR.[Notificacion] ON;
    INSERT INTO PBR.[Notificacion] ([PKIdNotificacion], [FKIdUsuario_PBR], [Tipo], [Titulo], [Mensaje], [Link], [Leida], [InformeId], [FechaCreacion])
    SELECT [PKIdNotificacion], [FKIdUsuario_PBR], [Tipo], [Titulo], [Mensaje], [Link], [Leida], [InformeId], [FechaCreacion]
    FROM [GE_Datos].PBR.[Notificacion];
    SET IDENTITY_INSERT PBR.[Notificacion] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Anteproyecto])
BEGIN
    SET IDENTITY_INSERT PBR.[Anteproyecto] ON;
    INSERT INTO PBR.[Anteproyecto] ([PKIdAnteproyecto], [FKIdProgramaPresupuestario_PBR], [Anio], [MontoSolicitado], [MontoAutorizado], [Estatus], [Justificacion], [Observaciones], [FKIdUsuario_PBR], [FKIdPresupuestoPrograma_PBR], [FKIdMirVersion_PBR], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdAnteproyecto], [FKIdProgramaPresupuestario_PBR], [Anio], [MontoSolicitado], [MontoAutorizado], [Estatus], [Justificacion], [Observaciones], [FKIdUsuario_PBR], [FKIdPresupuestoPrograma_PBR], [FKIdMirVersion_PBR], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[Anteproyecto];
    SET IDENTITY_INSERT PBR.[Anteproyecto] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Aprobacion])
BEGIN
    SET IDENTITY_INSERT PBR.[Aprobacion] ON;
    INSERT INTO PBR.[Aprobacion] ([PKIdAprobacion], [WorkflowCodigo], [EntidadId], [EstadoAnterior], [EstadoNuevo], [Comentario], [FKIdUsuario_PBR], [FirmaHash], [Ip], [FechaCreacion])
    SELECT [PKIdAprobacion], [WorkflowCodigo], [EntidadId], [EstadoAnterior], [EstadoNuevo], [Comentario], [FKIdUsuario_PBR], [FirmaHash], [Ip], [FechaCreacion]
    FROM [GE_Datos].PBR.[Aprobacion];
    SET IDENTITY_INSERT PBR.[Aprobacion] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ArbolNodo])
BEGIN
    SET IDENTITY_INSERT PBR.[ArbolNodo] ON;
    INSERT INTO PBR.[ArbolNodo] ([PKIdArbolNodo], [FKIdDiagnostico_PBR], [Tipo], [FKIdArbolNodo_Padre_PBR], [Codigo], [Descripcion], [Orden], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdArbolNodo], [FKIdDiagnostico_PBR], [Tipo], [FKIdArbolNodo_Padre_PBR], [Codigo], [Descripcion], [Orden], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[ArbolNodo];
    SET IDENTITY_INSERT PBR.[ArbolNodo] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Asm])
BEGIN
    SET IDENTITY_INSERT PBR.[Asm] ON;
    INSERT INTO PBR.[Asm] ([PKIdAsm], [FKIdEvaluacion_PBR], [Titulo], [Descripcion], [Prioridad], [TipoAsm], [FechaTermino], [ResultadoEsperado], [Avance], [Estado], [FKIdResponsable_PBR], [Observaciones], [Evidencia], [AccionesPamge], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdAsm], [FKIdEvaluacion_PBR], [Titulo], [Descripcion], [Prioridad], [TipoAsm], [FechaTermino], [ResultadoEsperado], [Avance], [Estado], [FKIdResponsable_PBR], [Observaciones], [Evidencia], [AccionesPamge], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[Asm];
    SET IDENTITY_INSERT PBR.[Asm] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[AvanceIndicador])
BEGIN
    SET IDENTITY_INSERT PBR.[AvanceIndicador] ON;
    INSERT INTO PBR.[AvanceIndicador] ([PKIdAvanceIndicador], [FKIdIndicador_PBR], [Anio], [Trimestre], [ValorProgramado], [ValorAlcanzado], [FechaReporte], [FKIdUsuario_PBR], [Observaciones], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdAvanceIndicador], [FKIdIndicador_PBR], [Anio], [Trimestre], [ValorProgramado], [ValorAlcanzado], [FechaReporte], [FKIdUsuario_PBR], [Observaciones], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[AvanceIndicador];
    SET IDENTITY_INSERT PBR.[AvanceIndicador] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[CalendarioPresupuesto])
BEGIN
    SET IDENTITY_INSERT PBR.[CalendarioPresupuesto] ON;
    INSERT INTO PBR.[CalendarioPresupuesto] ([PKIdCalendario], [Anio], [Fecha], [FechaFin], [Titulo], [Descripcion], [Etapa], [FKIdProgramaPresupuestario_PBR], [Tipo], [Orden], [Color], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdCalendario], [Anio], [Fecha], [FechaFin], [Titulo], [Descripcion], [Etapa], [FKIdProgramaPresupuestario_PBR], [Tipo], [Orden], [Color], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[CalendarioPresupuesto];
    SET IDENTITY_INSERT PBR.[CalendarioPresupuesto] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[CRI])
BEGIN
    SET IDENTITY_INSERT PBR.[CRI] ON;
    INSERT INTO PBR.[CRI] ([Id], [Codigo], [Nombre], [Rubro], [Tipo], [Clase], [Concepto], [Activo], [FechaCreacion])
    SELECT [Id], [Codigo], [Nombre], [Rubro], [Tipo], [Clase], [Concepto], [Activo], [FechaCreacion]
    FROM [GE_Datos].PBR.[CRI];
    SET IDENTITY_INSERT PBR.[CRI] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Cuenta])
BEGIN
    SET IDENTITY_INSERT PBR.[Cuenta] ON;
    INSERT INTO PBR.[Cuenta] ([Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion])
    SELECT [Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion]
    FROM [GE_Datos].PBR.[Cuenta];
    SET IDENTITY_INSERT PBR.[Cuenta] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Dependencia])
BEGIN
    SET IDENTITY_INSERT PBR.[Dependencia] ON;
    INSERT INTO PBR.[Dependencia] ([Id], [Nombre], [Siglas], [Activa], [createdAt], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [Id], [Nombre], [Siglas], [Activa], [createdAt], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[Dependencia];
    SET IDENTITY_INSERT PBR.[Dependencia] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Diagnostico])
BEGIN
    SET IDENTITY_INSERT PBR.[Diagnostico] ON;
    INSERT INTO PBR.[Diagnostico] ([PKIdDiagnostico], [FKIdProgramaPresupuestario_PBR], [ProblemaCentral], [Metodologia], [Estado], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdDiagnostico], [FKIdProgramaPresupuestario_PBR], [ProblemaCentral], [Metodologia], [Estado], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[Diagnostico];
    SET IDENTITY_INSERT PBR.[Diagnostico] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[EjercicioGasto])
BEGIN
    SET IDENTITY_INSERT PBR.[EjercicioGasto] ON;
    INSERT INTO PBR.[EjercicioGasto] ([PKIdEjercicioGasto], [FKIdPartidaGasto_PBR], [Trimestre], [MontoEjercido], [FechaCreacion])
    SELECT [PKIdEjercicioGasto], [FKIdPartidaGasto_PBR], [Trimestre], [MontoEjercido], [FechaCreacion]
    FROM [GE_Datos].PBR.[EjercicioGasto];
    SET IDENTITY_INSERT PBR.[EjercicioGasto] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Entidad])
BEGIN
    SET IDENTITY_INSERT PBR.[Entidad] ON;
    INSERT INTO PBR.[Entidad] ([PKIdEntidad], [Codigo], [Nombre], [Siglas], [Tipo], [Activa], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [PKIdEntidad], [Codigo], [Nombre], [Siglas], [Tipo], [Activa], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[Entidad];
    SET IDENTITY_INSERT PBR.[Entidad] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[EntidadesExternas])
BEGIN
    SET IDENTITY_INSERT PBR.[EntidadesExternas] ON;
    INSERT INTO PBR.[EntidadesExternas] ([Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion])
    SELECT [Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion]
    FROM [GE_Datos].PBR.[EntidadesExternas];
    SET IDENTITY_INSERT PBR.[EntidadesExternas] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Evaluacion])
BEGIN
    SET IDENTITY_INSERT PBR.[Evaluacion] ON;
    INSERT INTO PBR.[Evaluacion] ([PKIdEvaluacion], [FKIdProgramaPresupuestario_PBR], [Tipo], [Nombre], [EjercicioFiscal], [PaeAnio], [Estado], [FechaInicio], [FechaFin], [FKIdResponsable_PBR], [EvaluadorExterno], [Recomendaciones], [RespuestaDependencia], [InformeUrl], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdEvaluacion], [FKIdProgramaPresupuestario_PBR], [Tipo], [Nombre], [EjercicioFiscal], [PaeAnio], [Estado], [FechaInicio], [FechaFin], [FKIdResponsable_PBR], [EvaluadorExterno], [Recomendaciones], [RespuestaDependencia], [InformeUrl], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[Evaluacion];
    SET IDENTITY_INSERT PBR.[Evaluacion] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[EvaluacionConsistencia])
BEGIN
    SET IDENTITY_INSERT PBR.[EvaluacionConsistencia] ON;
    INSERT INTO PBR.[EvaluacionConsistencia] ([PKIdEvaluacionConsistencia], [FKIdProgramaPresupuestario_PBR], [Anio], [Estado], [PuntuacionTotal], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdEvaluacionConsistencia], [FKIdProgramaPresupuestario_PBR], [Anio], [Estado], [PuntuacionTotal], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[EvaluacionConsistencia];
    SET IDENTITY_INSERT PBR.[EvaluacionConsistencia] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[EvaluacionConsistenciaPregunta])
BEGIN
    SET IDENTITY_INSERT PBR.[EvaluacionConsistenciaPregunta] ON;
    INSERT INTO PBR.[EvaluacionConsistenciaPregunta] ([PKIdPregunta], [Seccion], [SeccionNombre], [Numero], [Pregunta], [TipoRespuesta], [Peso], [Activa], [Orden])
    SELECT [PKIdPregunta], [Seccion], [SeccionNombre], [Numero], [Pregunta], [TipoRespuesta], [Peso], [Activa], [Orden]
    FROM [GE_Datos].PBR.[EvaluacionConsistenciaPregunta];
    SET IDENTITY_INSERT PBR.[EvaluacionConsistenciaPregunta] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[EvaluacionConsistenciaRespuesta])
BEGIN
    SET IDENTITY_INSERT PBR.[EvaluacionConsistenciaRespuesta] ON;
    INSERT INTO PBR.[EvaluacionConsistenciaRespuesta] ([PKIdRespuesta], [FKIdEvaluacionConsistencia_PBR], [FKIdPregunta_PBR], [Respuesta], [Justificacion], [Puntuacion], [FechaCreacion])
    SELECT [PKIdRespuesta], [FKIdEvaluacionConsistencia_PBR], [FKIdPregunta_PBR], [Respuesta], [Justificacion], [Puntuacion], [FechaCreacion]
    FROM [GE_Datos].PBR.[EvaluacionConsistenciaRespuesta];
    SET IDENTITY_INSERT PBR.[EvaluacionConsistenciaRespuesta] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Indicador])
BEGIN
    SET IDENTITY_INSERT PBR.[Indicador] ON;
    INSERT INTO PBR.[Indicador] ([PKIdIndicador], [FKIdMirNivel_PBR], [Nombre], [Definicion], [Tipo], [Dimension], [Formula], [Algoritmo], [Frecuencia], [Unidad], [LineaBase], [Meta], [MedioVerificacion], [Supuesto], [Sentido], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdIndicador], [FKIdMirNivel_PBR], [Nombre], [Definicion], [Tipo], [Dimension], [Formula], [Algoritmo], [Frecuencia], [Unidad], [LineaBase], [Meta], [MedioVerificacion], [Supuesto], [Sentido], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[Indicador];
    SET IDENTITY_INSERT PBR.[Indicador] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[InformeTrimestral])
BEGIN
    SET IDENTITY_INSERT PBR.[InformeTrimestral] ON;
    INSERT INTO PBR.[InformeTrimestral] ([PKIdInformeTrimestral], [FKIdProgramaPresupuestario_PBR], [Anio], [Trimestre], [Estatus], [Observaciones], [Analisis], [FKIdUsuario_PBR], [FechaCreacion], [FechaModificacion], [EnviadoAt])
    SELECT [PKIdInformeTrimestral], [FKIdProgramaPresupuestario_PBR], [Anio], [Trimestre], [Estatus], [Observaciones], [Analisis], [FKIdUsuario_PBR], [FechaCreacion], [FechaModificacion], [EnviadoAt]
    FROM [GE_Datos].PBR.[InformeTrimestral];
    SET IDENTITY_INSERT PBR.[InformeTrimestral] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[MetaODS])
BEGIN
    SET IDENTITY_INSERT PBR.[MetaODS] ON;
    INSERT INTO PBR.[MetaODS] ([PKIdMetaODS], [FKIdObjetivoODS_PBR], [Numero], [Descripcion], [Activo], [FechaCreacion])
    SELECT [PKIdMetaODS], [FKIdObjetivoODS_PBR], [Numero], [Descripcion], [Activo], [FechaCreacion]
    FROM [GE_Datos].PBR.[MetaODS];
    SET IDENTITY_INSERT PBR.[MetaODS] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[MirNivel])
BEGIN
    SET IDENTITY_INSERT PBR.[MirNivel] ON;
    INSERT INTO PBR.[MirNivel] ([PKIdMirNivel], [FKIdProgramaPresupuestario_PBR], [Nivel], [Objetivo], [Descripcion], [Orden], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdMirNivel], [FKIdProgramaPresupuestario_PBR], [Nivel], [Objetivo], [Descripcion], [Orden], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[MirNivel];
    SET IDENTITY_INSERT PBR.[MirNivel] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[MirVersion])
BEGIN
    SET IDENTITY_INSERT PBR.[MirVersion] ON;
    INSERT INTO PBR.[MirVersion] ([PKIdMirVersion], [FKIdProgramaPresupuestario_PBR], [Version], [Snapshot], [FKIdUsuario_PBR], [Comentario], [FechaCreacion])
    SELECT [PKIdMirVersion], [FKIdProgramaPresupuestario_PBR], [Version], [Snapshot], [FKIdUsuario_PBR], [Comentario], [FechaCreacion]
    FROM [GE_Datos].PBR.[MirVersion];
    SET IDENTITY_INSERT PBR.[MirVersion] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ObjetivoODS])
BEGIN
    SET IDENTITY_INSERT PBR.[ObjetivoODS] ON;
    INSERT INTO PBR.[ObjetivoODS] ([PKIdObjetivoODS], [Numero], [Nombre], [Descripcion], [Icono], [Activo], [FechaCreacion])
    SELECT [PKIdObjetivoODS], [Numero], [Nombre], [Descripcion], [Icono], [Activo], [FechaCreacion]
    FROM [GE_Datos].PBR.[ObjetivoODS];
    SET IDENTITY_INSERT PBR.[ObjetivoODS] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ObjetivoPED])
BEGIN
    SET IDENTITY_INSERT PBR.[ObjetivoPED] ON;
    INSERT INTO PBR.[ObjetivoPED] ([PKIdObjetivoPED], [Codigo], [Eje], [Objetivo], [Indicador], [Meta], [ODS], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [PKIdObjetivoPED], [Codigo], [Eje], [Objetivo], [Indicador], [Meta], [ODS], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[ObjetivoPED];
    SET IDENTITY_INSERT PBR.[ObjetivoPED] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[PartidaGasto])
BEGIN
    SET IDENTITY_INSERT PBR.[PartidaGasto] ON;
    INSERT INTO PBR.[PartidaGasto] ([PKIdPartidaGasto], [FKIdPresupuestoPrograma_PBR], [FKIdCapitulo_SIS], [FKIdConcepto_SIS], [FKIdPartida_SIS], [CapituloClave], [Descripcion], [MontoAnual], [MontoModificado], [FKIdTipoGasto_PRES], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [PKIdPartidaGasto], [FKIdPresupuestoPrograma_PBR], [FKIdCapitulo_SIS], [FKIdConcepto_SIS], [FKIdPartida_SIS], [CapituloClave], [Descripcion], [MontoAnual], [MontoModificado], [FKIdTipoGasto_PRES], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[PartidaGasto];
    SET IDENTITY_INSERT PBR.[PartidaGasto] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[PoblacionObjetivo])
BEGIN
    SET IDENTITY_INSERT PBR.[PoblacionObjetivo] ON;
    INSERT INTO PBR.[PoblacionObjetivo] ([PKIdPoblacionObjetivo], [FKIdProgramaPresupuestario_PBR], [Anio], [PoblacionPotencial], [PoblacionObjetivo], [PoblacionReferencia], [Metodologia], [Fuente], [Notas], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdPoblacionObjetivo], [FKIdProgramaPresupuestario_PBR], [Anio], [PoblacionPotencial], [PoblacionObjetivo], [PoblacionReferencia], [Metodologia], [Fuente], [Notas], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[PoblacionObjetivo];
    SET IDENTITY_INSERT PBR.[PoblacionObjetivo] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[PresupuestoPrograma])
BEGIN
    SET IDENTITY_INSERT PBR.[PresupuestoPrograma] ON;
    INSERT INTO PBR.[PresupuestoPrograma] ([PKIdPresupuestoPrograma], [FKIdProgramaPresupuestario_PBR], [Anio], [PresupuestoAnual], [PresupuestoModificado], [FKIdEntidad_PBR], [FKIdUnidadResponsable_PRES], [FKIdFuenteFinanciamiento_PRES], [FKIdActividadInstitucional_SIS], [FKIdProyectoInversion_PRES], [FKIdRegion_PBR], [ComponenteActivado], [Futuro], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [PKIdPresupuestoPrograma], [FKIdProgramaPresupuestario_PBR], [Anio], [PresupuestoAnual], [PresupuestoModificado], [FKIdEntidad_PBR], [FKIdUnidadResponsable_PRES], [FKIdFuenteFinanciamiento_PRES], [FKIdActividadInstitucional_SIS], [FKIdProyectoInversion_PRES], [FKIdRegion_PBR], [ComponenteActivado], [Futuro], [Activo], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[PresupuestoPrograma];
    SET IDENTITY_INSERT PBR.[PresupuestoPrograma] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ProyeccionMultianual])
BEGIN
    SET IDENTITY_INSERT PBR.[ProyeccionMultianual] ON;
    INSERT INTO PBR.[ProyeccionMultianual] ([PKIdProyeccion], [FKIdProgramaPresupuestario_PBR], [AnioBase], [Anio], [MontoProyectado], [TasaCrecimiento], [TipoEscenario], [Metodo], [Notas], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdProyeccion], [FKIdProgramaPresupuestario_PBR], [AnioBase], [Anio], [MontoProyectado], [TasaCrecimiento], [TipoEscenario], [Metodo], [Notas], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[ProyeccionMultianual];
    SET IDENTITY_INSERT PBR.[ProyeccionMultianual] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[RecomendacionEvaluacion])
BEGIN
    SET IDENTITY_INSERT PBR.[RecomendacionEvaluacion] ON;
    INSERT INTO PBR.[RecomendacionEvaluacion] ([PKIdRecomendacion], [FKIdEvaluacion_PBR], [Numero], [Descripcion], [Tipo], [Prioridad], [FKIdResponsable_PBR], [FechaLimite], [MedioVerificacion], [Avance], [Estado], [Observaciones], [Evidencia], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdRecomendacion], [FKIdEvaluacion_PBR], [Numero], [Descripcion], [Tipo], [Prioridad], [FKIdResponsable_PBR], [FechaLimite], [MedioVerificacion], [Avance], [Estado], [Observaciones], [Evidencia], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[RecomendacionEvaluacion];
    SET IDENTITY_INSERT PBR.[RecomendacionEvaluacion] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[Region])
BEGIN
    SET IDENTITY_INSERT PBR.[Region] ON;
    INSERT INTO PBR.[Region] ([Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion])
    SELECT [Id], [Codigo], [Nombre], [Tipo], [Activa], [FechaCreacion]
    FROM [GE_Datos].PBR.[Region];
    SET IDENTITY_INSERT PBR.[Region] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[ReglaOperacion])
BEGIN
    SET IDENTITY_INSERT PBR.[ReglaOperacion] ON;
    INSERT INTO PBR.[ReglaOperacion] ([PKIdReglaOperacion], [FKIdProgramaPresupuestario_PBR], [Version], [Titulo], [Descripcion], [Secciones], [PdfUrl], [FKIdUsuario_PBR], [Activa], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdReglaOperacion], [FKIdProgramaPresupuestario_PBR], [Version], [Titulo], [Descripcion], [Secciones], [PdfUrl], [FKIdUsuario_PBR], [Activa], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[ReglaOperacion];
    SET IDENTITY_INSERT PBR.[ReglaOperacion] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[TechoGasto])
BEGIN
    SET IDENTITY_INSERT PBR.[TechoGasto] ON;
    INSERT INTO PBR.[TechoGasto] ([PKIdTechoGasto], [FKIdEntidad_PBR], [Anio], [MontoTecho], [TipoTecho], [FechaAsignacion], [FKIdUsuario_PBR], [Notas], [FechaCreacion], [FechaModificacion])
    SELECT [PKIdTechoGasto], [FKIdEntidad_PBR], [Anio], [MontoTecho], [TipoTecho], [FechaAsignacion], [FKIdUsuario_PBR], [Notas], [FechaCreacion], [FechaModificacion]
    FROM [GE_Datos].PBR.[TechoGasto];
    SET IDENTITY_INSERT PBR.[TechoGasto] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[TipologiaPrograma])
BEGIN
    SET IDENTITY_INSERT PBR.[TipologiaPrograma] ON;
    INSERT INTO PBR.[TipologiaPrograma] ([PKIdTipologia], [Codigo], [Nombre], [Descripcion], [Activa], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion])
    SELECT [PKIdTipologia], [Codigo], [Nombre], [Descripcion], [Activa], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion]
    FROM [GE_Datos].PBR.[TipologiaPrograma];
    SET IDENTITY_INSERT PBR.[TipologiaPrograma] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[VinculacionProgramaODS])
BEGIN
    SET IDENTITY_INSERT PBR.[VinculacionProgramaODS] ON;
    INSERT INTO PBR.[VinculacionProgramaODS] ([PKIdVinculacionODS], [FKIdProgramaPresupuestario_PBR], [FKIdObjetivoODS_PBR], [FKIdMetaODS_PBR], [Contribucion], [FechaCreacion])
    SELECT [PKIdVinculacionODS], [FKIdProgramaPresupuestario_PBR], [FKIdObjetivoODS_PBR], [FKIdMetaODS_PBR], [Contribucion], [FechaCreacion]
    FROM [GE_Datos].PBR.[VinculacionProgramaODS];
    SET IDENTITY_INSERT PBR.[VinculacionProgramaODS] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[VinculacionProgramaPED])
BEGIN
    SET IDENTITY_INSERT PBR.[VinculacionProgramaPED] ON;
    INSERT INTO PBR.[VinculacionProgramaPED] ([PKIdVinculacionPED], [FKIdProgramaPresupuestario_PBR], [FKIdObjetivoPED_PBR], [LineaAccion], [Contribucion], [FechaCreacion])
    SELECT [PKIdVinculacionPED], [FKIdProgramaPresupuestario_PBR], [FKIdObjetivoPED_PBR], [LineaAccion], [Contribucion], [FechaCreacion]
    FROM [GE_Datos].PBR.[VinculacionProgramaPED];
    SET IDENTITY_INSERT PBR.[VinculacionProgramaPED] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[WorkflowEstado])
BEGIN
    SET IDENTITY_INSERT PBR.[WorkflowEstado] ON;
    INSERT INTO PBR.[WorkflowEstado] ([PKIdWorkflowEstado], [FKIdWorkflowTemplate_PBR], [Codigo], [Nombre], [Orden], [EsInicial], [EsFinal], [Activo])
    SELECT [PKIdWorkflowEstado], [FKIdWorkflowTemplate_PBR], [Codigo], [Nombre], [Orden], [EsInicial], [EsFinal], [Activo]
    FROM [GE_Datos].PBR.[WorkflowEstado];
    SET IDENTITY_INSERT PBR.[WorkflowEstado] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[WorkflowTemplate])
BEGIN
    SET IDENTITY_INSERT PBR.[WorkflowTemplate] ON;
    INSERT INTO PBR.[WorkflowTemplate] ([PKIdWorkflowTemplate], [Codigo], [Nombre], [Activo], [FechaCreacion])
    SELECT [PKIdWorkflowTemplate], [Codigo], [Nombre], [Activo], [FechaCreacion]
    FROM [GE_Datos].PBR.[WorkflowTemplate];
    SET IDENTITY_INSERT PBR.[WorkflowTemplate] OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PBR.[WorkflowTransicion])
BEGIN
    SET IDENTITY_INSERT PBR.[WorkflowTransicion] ON;
    INSERT INTO PBR.[WorkflowTransicion] ([PKIdWorkflowTransicion], [FKIdWorkflowTemplate_PBR], [FKIdEstadoOrigen_PBR], [FKIdEstadoDestino_PBR], [Nombre], [RolesPermitidos], [RequiereFirma], [Activo])
    SELECT [PKIdWorkflowTransicion], [FKIdWorkflowTemplate_PBR], [FKIdEstadoOrigen_PBR], [FKIdEstadoDestino_PBR], [Nombre], [RolesPermitidos], [RequiereFirma], [Activo]
    FROM [GE_Datos].PBR.[WorkflowTransicion];
    SET IDENTITY_INSERT PBR.[WorkflowTransicion] OFF;
END;
GO

BEGIN TRY
    BEGIN TRAN;

    DECLARE @UsuarioSistema int = 1;
    DECLARE @GFDefault int = (SELECT TOP (1) PKIdGF FROM PRES.GF ORDER BY PKIdGF);
    DECLARE @FNDefault int = (SELECT TOP (1) PKIdFN FROM PRES.FN ORDER BY PKIdFN);
    DECLARE @SFDefault int = (SELECT TOP (1) PKIdSF FROM PRES.SF ORDER BY PKIdSF);
    DECLARE @URDefault int = (SELECT TOP (1) PKIdUR FROM PRES.UR ORDER BY PKIdUR);
    DECLARE @GrupoPresupuestoDefault int = (SELECT TOP (1) PKIdGrupoPresupuesto FROM PRES.GrupoPresupuesto ORDER BY PKIdGrupoPresupuesto);
    DECLARE @ActividadDefault int = (SELECT TOP (1) PKIdActividadInstitucional FROM SIS.ActividadInstitucional ORDER BY PKIdActividadInstitucional);
    DECLARE @CapituloDefault int = (SELECT TOP (1) PKIdCapitulo FROM SIS.Capitulo ORDER BY PKIdCapitulo);

    INSERT INTO SIS.Concepto (FKIdCapitulo_SIS, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    SELECT
        COALESCE(sc.PKIdCapitulo, @CapituloDefault),
        LEFT(cg.Codigo, 60),
        LEFT(cg.Nombre, 240),
        cg.Activo,
        COALESCE(cg.FechaCreacion, sysdatetime()),
        @UsuarioSistema
    FROM [GE_Datos].PBR.ConceptoGasto cg
    LEFT JOIN [GE_Datos].PBR.CapituloGasto cap ON cap.Id = cg.FKIdCapitulo
    LEFT JOIN SIS.Capitulo sc ON sc.Clave = cap.Codigo
    WHERE NOT EXISTS (SELECT 1 FROM SIS.Concepto x WHERE x.Clave = cg.Codigo);

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdConcepto) AS PKIdConcepto
        FROM SIS.Concepto
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'ConceptoGasto' AS EntidadOrigen, cg.Id AS IdOrigen, N'SIS.Concepto' AS EntidadDestino,
               d.PKIdConcepto AS IdDestino, cg.Codigo AS Clave, cg.Nombre AS Descripcion
        FROM [GE_Datos].PBR.ConceptoGasto cg
        INNER JOIN Dest d ON d.Clave = cg.Codigo
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    IF NOT EXISTS (SELECT 1 FROM PBR.PartidaGenerica)
    BEGIN
        SET IDENTITY_INSERT PBR.PartidaGenerica ON;
        INSERT INTO PBR.PartidaGenerica
        (
            Id,
            Codigo,
            Nombre,
            Descripcion,
            FKIdConcepto_SIS,
            Activa,
            FechaCreacion
        )
        SELECT
            pg.Id,
            LEFT(pg.Codigo, 10),
            LEFT(pg.Nombre, 500),
            pg.Descripcion,
            mm.IdDestino,
            pg.Activa,
            COALESCE(pg.FechaCreacion, sysdatetime())
        FROM [GE_Datos].PBR.PartidaGenerica pg
        INNER JOIN PBR.MigracionMap mm ON mm.EntidadOrigen = N'ConceptoGasto' AND mm.IdOrigen = pg.FKIdConcepto;
        SET IDENTITY_INSERT PBR.PartidaGenerica OFF;
    END;

    INSERT INTO SIS.Partida (FKIdConcepto_SIS, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    SELECT
        mm.IdDestino,
        LEFT(pe.Codigo, 20),
        LEFT(pe.Nombre, 510),
        pe.Activa,
        COALESCE(pe.FechaCreacion, sysdatetime()),
        @UsuarioSistema
    FROM [GE_Datos].PBR.PartidaEspecifica pe
    LEFT JOIN [GE_Datos].PBR.PartidaGenerica pg ON pg.Id = pe.FKIdGenerica
    LEFT JOIN PBR.MigracionMap mm ON mm.EntidadOrigen = N'ConceptoGasto' AND mm.IdOrigen = pg.FKIdConcepto
    WHERE NOT EXISTS (SELECT 1 FROM SIS.Partida x WHERE x.Clave = pe.Codigo);

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdPartida) AS PKIdPartida
        FROM SIS.Partida
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'PartidaEspecifica' AS EntidadOrigen, pe.Id AS IdOrigen, N'SIS.Partida' AS EntidadDestino,
               d.PKIdPartida AS IdDestino, pe.Codigo AS Clave, pe.Nombre AS Descripcion
        FROM [GE_Datos].PBR.PartidaEspecifica pe
        INNER JOIN Dest d ON d.Clave = pe.Codigo
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    INSERT INTO PRES.PY (Clave, Descripcion, NombreProyecto, ProyectoInversion, DescripcionProyecto, Activo, FechaCreacion, UsuarioCreacion)
    SELECT LEFT(pi.Codigo, 15), LEFT(pi.Nombre, 300), LEFT(pi.Nombre, 1000), 1,
           LEFT(COALESCE(CONVERT(nvarchar(max), pi.Descripcion), pi.Nombre), 1000),
           pi.Activo, COALESCE(pi.FechaCreacion, sysdatetime()), @UsuarioSistema
    FROM [GE_Datos].PBR.ProyectoInversion pi
    WHERE NOT EXISTS (SELECT 1 FROM PRES.PY x WHERE x.Clave = pi.Codigo);

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdPY) AS PKIdPY
        FROM PRES.PY
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'ProyectoInversion' AS EntidadOrigen, pi.PKIdProyectoInversion AS IdOrigen, N'PRES.PY' AS EntidadDestino,
               d.PKIdPY AS IdDestino, pi.Codigo AS Clave, pi.Nombre AS Descripcion
        FROM [GE_Datos].PBR.ProyectoInversion pi
        INNER JOIN Dest d ON d.Clave = pi.Codigo
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    INSERT INTO PRES.FN (FKIdGF_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    SELECT COALESCE(gf.PKIdGF, @GFDefault), TRY_CONVERT(int, f.Codigo), LEFT(f.Nombre, 100),
           f.Activo, COALESCE(f.FechaCreacion, sysdatetime()), @UsuarioSistema
    FROM [GE_Datos].PBR.Funcion f
    LEFT JOIN [GE_Datos].PBR.Finalidad pf ON pf.PKIdFinalidad = f.FKIdFinalidad_PBR
    LEFT JOIN PRES.GF gf ON CONVERT(nvarchar(20), gf.Clave) = pf.Codigo
    WHERE TRY_CONVERT(int, f.Codigo) IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM PRES.FN x WHERE x.Clave = TRY_CONVERT(int, f.Codigo));

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdFN) AS PKIdFN
        FROM PRES.FN
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'Funcion' AS EntidadOrigen, f.PKIdFuncion AS IdOrigen, N'PRES.FN' AS EntidadDestino,
               d.PKIdFN AS IdDestino, f.Codigo AS Clave, f.Nombre AS Descripcion
        FROM [GE_Datos].PBR.Funcion f
        INNER JOIN Dest d ON d.Clave = TRY_CONVERT(int, f.Codigo)
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    INSERT INTO PRES.SF (FKIdFN_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    SELECT COALESCE(mm.IdDestino, @FNDefault), TRY_CONVERT(int, sf.Codigo), LEFT(sf.Nombre, 100),
           sf.Activa, COALESCE(sf.FechaCreacion, sysdatetime()), @UsuarioSistema
    FROM [GE_Datos].PBR.Subfuncion sf
    LEFT JOIN PBR.MigracionMap mm ON mm.EntidadOrigen = N'Funcion' AND mm.IdOrigen = sf.FKIdFuncion_PBR
    WHERE TRY_CONVERT(int, sf.Codigo) IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM PRES.SF x WHERE x.Clave = TRY_CONVERT(int, sf.Codigo));

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdSF) AS PKIdSF
        FROM PRES.SF
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'Subfuncion' AS EntidadOrigen, sf.PKIdSubfuncion AS IdOrigen, N'PRES.SF' AS EntidadDestino,
               d.PKIdSF AS IdDestino, sf.Codigo AS Clave, sf.Nombre AS Descripcion
        FROM [GE_Datos].PBR.Subfuncion sf
        INNER JOIN Dest d ON d.Clave = TRY_CONVERT(int, sf.Codigo)
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    INSERT INTO PRES.UR (FKIdGrupoPresupuesto_PRES, Clave, Descripcion, Activo, FechaCreacion, UsuarioCreacion)
    SELECT @GrupoPresupuestoDefault, LEFT(ur.Codigo, 20), LEFT(ur.Nombre, 100),
           ur.Activa, COALESCE(ur.FechaCreacion, sysdatetime()), COALESCE(ur.UsuarioCreacion, @UsuarioSistema)
    FROM [GE_Datos].PBR.UnidadResponsable ur
    WHERE NOT EXISTS (SELECT 1 FROM PRES.UR x WHERE x.Clave = ur.Codigo);

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdUR) AS PKIdUR
        FROM PRES.UR
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'UnidadResponsable' AS EntidadOrigen, ur.PKIdUnidadResponsable AS IdOrigen, N'PRES.UR' AS EntidadDestino,
               d.PKIdUR AS IdDestino, ur.Codigo AS Clave, ur.Nombre AS Descripcion
        FROM [GE_Datos].PBR.UnidadResponsable ur
        INNER JOIN Dest d ON d.Clave = ur.Codigo
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    ;WITH Src AS
    (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY Codigo ORDER BY PKIdProgramaPresupuestario) AS rn
        FROM [GE_Datos].PBR.ProgramaPresupuestario
    )
    INSERT INTO PRES.Programa
    (
        Clave,
        Descripcion,
        Activo,
        FechaCreacion,
        UsuarioCreacion,
        FKIdUR_PRES,
        FKIdGF_PRES,
        FKIdFN_PRES,
        FKIdSF_PRES,
        FKIdActividadInstitucional_SIS,
        Objetivo
    )
    SELECT LEFT(pp.Codigo, 100), LEFT(pp.Nombre, 510), pp.Activo, COALESCE(pp.FechaCreacion, sysdatetime()),
           COALESCE(pp.UsuarioCreacion, @UsuarioSistema), @URDefault, @GFDefault,
           COALESCE(mfn.IdDestino, @FNDefault), COALESCE(msf.IdDestino, @SFDefault),
           @ActividadDefault, LEFT(pp.DescripcionPrograma, 1000)
    FROM Src pp
    LEFT JOIN PBR.MigracionMap mfn ON mfn.EntidadOrigen = N'Funcion' AND mfn.IdOrigen = pp.FKIdFuncion_PBR
    LEFT JOIN PBR.MigracionMap msf ON msf.EntidadOrigen = N'Subfuncion' AND msf.IdOrigen = pp.FKIdSubfuncion_PBR
    WHERE pp.rn = 1
      AND NOT EXISTS (SELECT 1 FROM PRES.Programa x WHERE x.Clave = pp.Codigo);

    ;WITH Dest AS
    (
        SELECT Clave, MIN(PKIdPrograma) AS PKIdPrograma
        FROM PRES.Programa
        GROUP BY Clave
    )
    MERGE PBR.MigracionMap AS tgt
    USING
    (
        SELECT N'ProgramaPresupuestario' AS EntidadOrigen, pp.PKIdProgramaPresupuestario AS IdOrigen,
               N'PRES.Programa' AS EntidadDestino, d.PKIdPrograma AS IdDestino, pp.Codigo AS Clave,
               pp.Nombre AS Descripcion
        FROM [GE_Datos].PBR.ProgramaPresupuestario pp
        INNER JOIN Dest d ON d.Clave = pp.Codigo
    ) AS src
    ON tgt.EntidadOrigen = src.EntidadOrigen AND tgt.IdOrigen = src.IdOrigen
    WHEN MATCHED THEN UPDATE SET EntidadDestino = src.EntidadDestino, IdDestino = src.IdDestino,
        Clave = src.Clave, Descripcion = src.Descripcion, FechaMigracion = sysdatetime()
    WHEN NOT MATCHED THEN INSERT (EntidadOrigen, IdOrigen, EntidadDestino, IdDestino, Clave, Descripcion)
        VALUES (src.EntidadOrigen, src.IdOrigen, src.EntidadDestino, src.IdDestino, src.Clave, src.Descripcion);

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;
    THROW;
END CATCH;
GO

PRINT 'Carga de datos PBR completada.';
GO
