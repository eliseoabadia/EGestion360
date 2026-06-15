# Migracion Nomina INVEA -> EGestion360

Este bloque migra la base operativa/catalogos de Nomina a la arquitectura modular de EGestion360.

## Incluido

- 24 entidades NOM normalizadas a esquema [NOM].[Tabla].
- DTOs/Responses con campos de control.
- Servicios por controlador usando GenericService y registro de errores con EG.Logger.
- Controladores API sin acceso directo a BD.
- Paginas Blazor con GenericTable y dialogo generico de catalogo.
- Pagina operativa unica para procesos de Nomina en `/nomina/procesos`.
- Scripts SQL manuales de estructura, datos, menu/claims, vistas y SPs de consulta.
- 30 vistas SQL NOM con IDs y columnas descriptivas para empresa, persona, concepto, periodos y movimientos.
- Dependencias reales de RH/EMP migradas a NOM: empresas de nomina, universos, niveles, clases de puesto, puestos, nombramientos, importes por nivel y contratos laborales.
- Vistas enriquecidas para ConceptoFijo, ConceptoProporcional y ConceptoTabular con empresa de nomina, puesto, nivel, universo y clase de puesto.
- Demo funcional de corrida: adapta usuarios a persona NOM, genera encabezado/detalle en `NOM.CorridaNomina` y resume percepciones, deducciones y neto.
- `BackEnd/EG.Infraestructure/efpt.config.json` actualizado para incluir las vistas NOM en EF Core Power Tools.
- Stored procedures de lectura paginada sobre vistas importantes.

## Pendiente critico

Los SP del API fuente no vienen en migration_sqlserver ni en el dump revisado. Los nuevos SP de este paquete son de lectura sobre vistas importantes; no reemplazan la logica de calculo/cierre/timbrado. Procesos como calculo/cierre/timbrado requieren recuperar y migrar estos SP antes de habilitar operacion completa:

- NOM_SP_Nomina
- NOM_SP_CierraPeriodo
- NOM_SP_CalculaAguinaldo
- NOM_SP_PrimaVac_Ind
- PRES_SP_CREATE_Comprometido_Nomina
- PRES_SP_CREATE_Devengado_Nomina
- PRES_SP_CREATE_Ejercido_Nomina
- EMP_CREATE_Credito
- EMP_UPDATE_Credito
- EMP_DELETE_Credito

## Orden sugerido manual

1. Validar scripts en ambiente temporal.
2. Aplicar Scripts/Nomina/01_Estructura_NOM.sql.
3. Aplicar Scripts/Nomina/02_Datos_NOM_Migracion.sql si las llaves base existen.
4. Aplicar Scripts/Nomina/06_Dependencias_RH_EMP_NOM.sql para traer las dependencias reales de RH/EMP al esquema NOM.
5. Aplicar Scripts/Nomina/07_Demo_Corrida_NOM.sql para habilitar la demo de corrida.
6. Aplicar manualmente Scripts/Nomina/03_Menu_Claims_NOM.sql ajustando IDs si ya existen.
7. Aplicar Scripts/Nomina/04_Vistas_NOM.sql si se requiere regenerar las vistas base.
8. Aplicar Scripts/Nomina/05_StoredProcedures_NOM.sql si se requiere regenerar los SP base.
9. Ejecutar EF Core Power Tools desde Visual Studio para regenerar modelos de las vistas NOM incluidas en `efpt.config.json`.
