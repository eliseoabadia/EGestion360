-- Alineacion de permisos para el menu actual de Nomina.
-- Este script NO reescribe SIS.Menu: respeta el MERGE de menu aplicado manualmente
-- y solo asegura claims + MenuRole para el rol indicado.

SET NOCOUNT ON;

DECLARE @RoleCode NVARCHAR(10) = N'10000';
DECLARE @Now DATETIME = GETDATE();
DECLARE @RoleId NVARCHAR(128);

SELECT @RoleId = Id
FROM dbo.AspNetRoles
WHERE Code = @RoleCode;

IF @RoleId IS NULL
BEGIN
    RAISERROR('No existe rol con Code=%s para alinear permisos de Nomina.', 16, 1, @RoleCode);
    RETURN;
END;

IF OBJECT_ID('tempdb..#NominaClaimSync') IS NOT NULL
    DROP TABLE #NominaClaimSync;

CREATE TABLE #NominaClaimSync
(
    ModuleName NVARCHAR(100) NOT NULL,
    SubModuleName NVARCHAR(100) NOT NULL,
    [Values] VARCHAR(MAX) NOT NULL
);

INSERT INTO #NominaClaimSync (ModuleName, SubModuleName, [Values])
VALUES
-- Raiz y operacion principal.
(N'Nomina', N'Nomina', 'view,view-menu'),
(N'Nomina', N'Nomina_Recursos_Humanos', 'view,view-menu'),
(N'Nomina', N'Empleados', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina', N'Nomina_Calculo', 'view,view-menu,new,update,authorize'),
(N'Nomina', N'Procesos', 'view,view-menu,new,update,authorize'),
(N'Nomina', N'Nomina_Auxiliares', 'view,view-menu'),
(N'Nomina', N'Nomina_Productos', 'view,view-menu'),
(N'Nomina', N'Nomina_Incidencias', 'view,view-menu'),
(N'Nomina', N'Nomina_Vacaciones', 'view,view-menu'),
(N'Nomina', N'Concepto_Variable', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina', N'Nomina_Cierre_Periodo', 'view,view-menu,new,authorize'),
(N'Nomina', N'Nomina_Finiquito_Liquidacion', 'view,view-menu'),
(N'Nomina', N'Nominas_Especiales', 'view,view-menu'),
(N'Nomina', N'Nomina_Historicos', 'view,view-menu'),
(N'Nomina', N'Configuracion_Nominas', 'view,view-menu'),
(N'Nomina', N'Configuracion_RH', 'view,view-menu'),

-- Operacion RH/NOM migrada.
(N'Nomina_Recursos_Humanos', N'Empleados', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Recursos_Humanos', N'Movimientos_Personal', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Recursos_Humanos', N'De_Personal', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Recursos_Humanos', N'Reporte_Quincenal_MP', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Incidencias', N'Captura_Incidencias', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Incidencias', N'Justificacion_Incidencias', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Incidencias', N'Reporte_Incidencias', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Incidencias', N'Faltas_Especial', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Vacaciones', N'Solicitud_Vacaciones', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Vacaciones', N'Autorizacion_Vacaciones', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Auxiliares', N'Calculo_ISSSTE_4134', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Auxiliares', N'Calculo_ISR_2053', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Auxiliares', N'Calculo_FOVISSSTE_4136', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Auxiliares', N'Calculo_Infonavit_139', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Auxiliares', N'Calculo_IMSS_3084', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Auxiliares', N'Reporte_IMSS', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Auxiliares', N'Cuotas_IMSS', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Productos', N'Resumen_Nomina', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Productos', N'Recibos_Nomina', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Productos', N'Archivos_Dispersion', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Productos', N'Archivos_Timbrado', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Productos', N'Reporte_Nomina', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Productos', N'Configura_Aguinaldo', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Productos', N'Aguinaldo', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'consulta', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'analisis', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'recibos', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'dispersion', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'timbrado', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'reportequincenal', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'resumen', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'reportehistorico', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'cubo', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'sbc', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'acumuladosimss', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'sbchistorico', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'acumuladosbimestre', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'isr_mensual', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'isr_acumulados', 'view,view-menu,CanExportToExcel'),
(N'Nomina_Historicos', N'impuestoslocales', 'view,view-menu,CanExportToExcel'),

-- Contenedores de configuracion.
(N'Configuracion_Nominas', N'Nomina_Catalogos', 'view,view-menu'),
(N'Configuracion_Nominas', N'Nomina_Periodos', 'view,view-menu'),
(N'Configuracion_Nominas', N'Nomina_Tablas_ISR', 'view,view-menu'),
(N'Configuracion_Nominas', N'Nomina_Prestaciones', 'view,view-menu'),
(N'Configuracion_Nominas', N'Nomina_Subsidios_ISR', 'view,view-menu'),
(N'Configuracion_Nominas', N'Nomina_Impuestos', 'view,view-menu'),
(N'Configuracion_Nominas', N'Nomina_IMSS', 'view,view-menu'),
(N'Configuracion_RH', N'Configuracion_RH', 'view,view-menu'),

-- Catalogos reales ya migrados con CRUD.
(N'Nomina_Catalogos', N'Empresa_Nomina', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Universo', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Nivel', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Clase_Puesto', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Puesto', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Plazas_Autorizadas', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Nombramiento', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Importe_Nivel', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Contrato_Laboral', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Contratos', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Concepto', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Conceptos_Nomina', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Concepto_Factor', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Concepto_Fijo', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Concepto_Porcentaje', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Concepto_Proporcional', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Concepto_Tabular', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Tabulador', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Concepto_Variable', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Contrato_Terceros', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Credito', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Creditos_Trabajadores', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Descuento_Credito', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Descuento_Infonavit', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Estatus_Pago', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Factor_Integracion', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Infonavit', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Periodo_Activo', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Periodo_Semanal', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Periodo_Quincenal', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Periodo_Mensual', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Periodo_Bimestral', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Salario_Minimo', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Sueldo_Especial', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Sueldo_LiqFin', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Sueldo_Mensual', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Sueldo_Quincenal', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Sueldo_Semanal', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Tipo_Incapacidad', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Tipo_Pago', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Forma_Pago', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Tipo_Pension', 'view,view-menu,delete,new,update,CanExportToExcel'),

-- Catalogos simples migrados desde BD_GRP_INVEA.dbo.SIS_*.
(N'Nomina_Catalogos', N'Tipo_Nomina', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Cuotas_IMSS', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'UMA', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Tipo_Contratacion', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Tipo_Descanso', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Tipo_Incidencia', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Tipo_Justificacion', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Unidad_Infonavit', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Forma_Calculo', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Nomina_Catalogos', N'Capitulos', 'view,view-menu,delete,new,update,CanExportToExcel'),
(N'Plazas_Autorizadas', N'Plazas_Autorizadas', 'view,view-menu,delete,new,update'),
(N'Universo', N'Universo', 'view,view-menu,delete,new,update'),
(N'Nivel', N'Nivel', 'view,view-menu,delete,new,update'),
(N'Sexo', N'Sexo', 'view,view-menu,delete,new,update'),
(N'Estado_Civil', N'Estado_Civil', 'view,view-menu,delete,new,update'),
(N'Escolaridad', N'Escolaridad', 'view,view-menu,delete,new,update'),
(N'Tipo_Parentesco', N'Tipo_Parentesco', 'view,view-menu,delete,new,update'),
(N'Estado', N'Estado', 'view,view-menu,delete,new,update'),
(N'Banco', N'Banco', 'view,view-menu,delete,new,update'),
(N'Municipio', N'Municipio', 'view,view-menu,delete,new,update'),
(N'Contratos', N'Contratos', 'view,view-menu'),
(N'Contratos', N'Base_Pago', 'view,view-menu,delete,new,update'),
(N'Contratos', N'Metodo_Pago', 'view,view-menu,delete,new,update'),
(N'Contratos', N'Tipo_Regimen', 'view,view-menu,delete,new,update'),
(N'Contratos', N'Base_Cotizacion', 'view,view-menu,delete,new,update'),
(N'Contratos', N'Zona_Geografica', 'view,view-menu,delete,new,update'),
(N'Contratos', N'Dia_Semana', 'view,view-menu,delete,new,update'),

-- Catalogos/rutas aun pendientes: solo vista/menu para no exponer acciones inexistentes.
(N'Nomina_Tablas_ISR', N'Tabla_ISR_Semanal', 'view,view-menu'),
(N'Nomina_Tablas_ISR', N'Tabla_ISR_Quincenal', 'view,view-menu'),
(N'Nomina_Tablas_ISR', N'Tabla_ISR_Mensual', 'view,view-menu'),
(N'Nomina_Subsidios_ISR', N'Subsidio_ISR_Semanal', 'view,view-menu'),
(N'Nomina_Subsidios_ISR', N'Subsidio_ISR_Quincenal', 'view,view-menu'),
(N'Nomina_Subsidios_ISR', N'Subsidio_ISR_Mensual', 'view,view-menu'),
(N'Nomina_Impuestos', N'Base_Gravable', 'view,view-menu'),
(N'Nomina_Impuestos', N'Impuestos_Locales', 'view,view-menu'),
(N'Nomina_IMSS', N'Prestaciones_Minimas', 'view,view-menu'),
(N'Nomina_IMSS', N'Clase_IMSS', 'view,view-menu'),
(N'Nomina_IMSS', N'Fraccion_IMSS', 'view,view-menu'),
(N'Nomina_IMSS', N'Base_Gravable_IMSS', 'view,view-menu');

;WITH ClaimsBase AS
(
    SELECT
        ModuleName,
        SubModuleName,
        [Values],
        ROW_NUMBER() OVER (ORDER BY ModuleName, SubModuleName) AS RowNumber
    FROM #NominaClaimSync
)
INSERT INTO dbo.AspNetClaims
(
    ClaimTypeId,
    Name,
    [Group],
    RoleId,
    TokenFormat,
    Created,
    SubGroup,
    Code,
    [Description],
    [Values],
    ReferenceId
)
SELECT
    2,
    ModuleName,
    ModuleName,
    NULL,
    N'app://{0}/{1}',
    @Now,
    SubModuleName,
    CONCAT(N'NOM', RIGHT(CONCAT(N'0000', RowNumber), 4)),
    SubModuleName,
    [Values],
    0
FROM ClaimsBase source
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.AspNetClaims target
    WHERE target.RoleId IS NULL
      AND target.[Group] = source.ModuleName
      AND target.SubGroup = source.SubModuleName
);

DECLARE @ModuleName NVARCHAR(100);
DECLARE @SubModuleName NVARCHAR(100);
DECLARE @Values VARCHAR(MAX);

DECLARE claim_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT ModuleName, SubModuleName, [Values]
FROM #NominaClaimSync;

OPEN claim_cursor;
FETCH NEXT FROM claim_cursor INTO @ModuleName, @SubModuleName, @Values;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC spConfiguracionDeRolYClaims @ModuleName, @SubModuleName, @RoleCode, @Values;
    FETCH NEXT FROM claim_cursor INTO @ModuleName, @SubModuleName, @Values;
END;

CLOSE claim_cursor;
DEALLOCATE claim_cursor;

UPDATE target
SET target.[Values] = source.[Values]
FROM dbo.AspNetClaims target
INNER JOIN #NominaClaimSync source
    ON source.ModuleName = target.[Group]
    AND source.SubModuleName = target.SubGroup;

;WITH NominaTree AS
(
    SELECT PKIdMenu
    FROM SIS.Menu
    WHERE PKIdMenu = 7

    UNION ALL

    SELECT child.PKIdMenu
    FROM SIS.Menu child
    INNER JOIN NominaTree parent ON parent.PKIdMenu = child.FKIdMenu_SIS
)
MERGE INTO SIS.MenuRole AS TARGET
USING
(
    SELECT m.PKIdMenu, @RoleId AS RoleId, 1 AS Activo, 1 AS CreatedByOperatorId, @Now AS CreatedDateTime
    FROM NominaTree t
    INNER JOIN SIS.Menu m ON m.PKIdMenu = t.PKIdMenu
    WHERE m.Activo = 1
) AS SOURCE
ON TARGET.FKIdMenu_SIS = SOURCE.PKIdMenu
AND TARGET.RoleId = SOURCE.RoleId
WHEN MATCHED THEN
    UPDATE SET
        TARGET.Activo = SOURCE.Activo,
        TARGET.ModifiedByOperatorId = SOURCE.CreatedByOperatorId,
        TARGET.ModifiedDateTime = SOURCE.CreatedDateTime
WHEN NOT MATCHED BY TARGET THEN
    INSERT (FKIdMenu_SIS, RoleId, Activo, CreatedByOperatorId, CreatedDateTime)
    VALUES (SOURCE.PKIdMenu, SOURCE.RoleId, SOURCE.Activo, SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime);

DROP TABLE #NominaClaimSync;
