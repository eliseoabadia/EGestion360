# Migracion Nomina INVEA -> EGestion360

Este bloque migra la base operativa/catalogos de Nomina a la arquitectura modular de EGestion360.

## Incluido

- 24 entidades NOM normalizadas a esquema [NOM].[Tabla].
- DTOs/Responses con campos de control.
- Servicios por controlador usando GenericService y registro de errores con EG.Logger.
- Controladores API sin acceso directo a BD.
- Paginas Blazor con GenericTable y dialogo generico de catalogo.
- Pagina operativa unica para procesos de Nomina en `/nomina/procesos` y alias legado `/nom/calcnomina`.
- Alias de rutas alineados al menu vigente de Nomina: calculo, cierre, aguinaldo, creditos trabajadores, catalogos, periodos, historicos y configuracion RH.
- Pantalla controlada de pendiente de migracion para rutas legacy sin entidad/SP real, evitando 404 y dejando visible la clave legacy faltante.
- Scripts SQL manuales de estructura, datos, menu/claims, vistas y SPs de consulta.
- Menu de Nomina compatible con el arbol Invea 610-930 mediante `16_Menu_Invea_NOM.sql`, con claims legacy y `SIS.MenuRole` para rol 10000.
- Capa de procesos de compatibilidad en `17_Procesos_Compat_NOM.sql`: calculo via corrida migrada, cierre de periodo, aguinaldo, prima vacacional individual y marcas de comprometido/devengado/ejercido.
- Catalogos simples `SIS_*` migrados a `NOM.CatalogoSimple` desde `BD_GRP_INVEA`: Sexo, Estado Civil, Escolaridad, Parentesco, Estado, Banco, Municipio, Base Pago, Metodo Pago, Tipo Regimen, Base Cotizacion, Zona Geografica, Dia Semana, Tipo Nomina, Cuotas IMSS, UMA, Tipo Contratacion, Tipo Descanso, Tipo Incidencia, Tipo Justificacion, Unidad Infonavit, Forma Calculo y Capitulos.
- Catalogos ampliados SIS/RH en `18_Catalogos_Ampliados_SIS_RH_NOM.sql`: Tipo Sangre, Profesion, Regimen Fiscal, Pais, Periodo Pago, Tipo Documento SIS, Tipo Documento RH, Tipo Expediente, Opcion Jubilacion, Situacion Persona, Situacion Plaza, Situacion Movimiento, Clase Movimiento y Movimiento RH, cada uno con vista `NOM.Vw_*` propia.
- Vista `NOM.Vw_CatalogoSimple` y SP `NOM.spCatalogoSimplePorCatalogo` para consulta rapida de esos catalogos.
- 30 vistas SQL NOM con IDs y columnas descriptivas para empresa, persona, concepto, periodos y movimientos.
- Dependencias reales de RH/EMP migradas a NOM: empresas de nomina, universos, niveles, clases de puesto, puestos, nombramientos, importes por nivel y contratos laborales.
- Vistas enriquecidas para ConceptoFijo, ConceptoProporcional y ConceptoTabular con empresa de nomina, puesto, nivel, universo y clase de puesto.
- Demo funcional de corrida: adapta usuarios a persona NOM, genera encabezado/detalle en `NOM.CorridaNomina` y resume percepciones, deducciones y neto.
- `BackEnd/EG.Infraestructure/efpt.config.json` actualizado para incluir las vistas NOM en EF Core Power Tools.
- Stored procedures de lectura paginada sobre vistas importantes.
- Capa operativa `NOM.VwOperacionNomina` + `NOM.spOperacionNomina_List` para quitar pantallas pendientes y mostrar datos reales por ruta.
- Tablas operativas migradas a `NOM`: expedientes, pensiones, motivos de movimiento, plazas autorizadas, persona-plaza, movimientos de personal, incidencias, vacaciones, liquidaciones, periodos de nomina y tablas fiscales.
- Insercion no destructiva de personas faltantes desde `RH_Persona` cuando no existen en `NOM.Persona`.
- Pantalla generica de operaciones en Blazor para empleados, movimientos, incidencias, vacaciones, liquidaciones, productos, historicos y auxiliares.
- Pantalla RH profesional en `/nomina/empleados` y alias `/rh/persona`: maestro editable de empleados con detalle por tabs para contratos, expedientes, dependientes, incidencias y pensiones.
- Script `11_RH_Empleados_NOM.sql` con `NOM.VwRhEmpleado`, `NOM.VwRhEmpleadoDetalle`, SPs paginados y alta/edicion/baja logica de la ficha maestra.

## Stored procedures legacy encontrados

En el servidor local revisado, `BD_GRP_INVEA` no contiene stored procedures. La logica legacy localizada esta en `BD_ExuxFinanzas` y `BD_PRESUPUESTO`; se extrajo como fuente de analisis en `Scripts/Nomina/LegacyStoredProcedures`.

Estos SP no se aplican automaticamente porque dependen de esquemas/tablas legacy (`nom`, `NOMI`, `PRES`, `ORCO`, `CONTA`, `com`, `cat`, `rh`) y requieren mapeo a la estructura `NOM`/`RH`/`EMP` de EGestion360.

## Pendiente critico

Los nuevos SP de compatibilidad habilitan el flujo operativo sobre datos migrados, pero no reemplazan la logica fiscal/presupuestal completa de Invea. Para operacion final certificada siguen pendientes los SP legacy o su reimplementacion completa:

- NOM_SP_Nomina
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
5. Aplicar Scripts/Nomina/09_Catalogos_Simples_SIS.sql para traer catalogos `SIS_*` desde `BD_GRP_INVEA`.
6. Aplicar Scripts/Nomina/07_Demo_Corrida_NOM.sql para habilitar la demo de corrida.
7. Aplicar Scripts/Nomina/17_Procesos_Compat_NOM.sql para habilitar procesos ejecutables de compatibilidad.
8. Aplicar Scripts/Nomina/10_Operaciones_RH_NOM.sql para cargar operaciones RH/NOM y crear la vista/SP unificados.
9. Aplicar Scripts/Nomina/11_RH_Empleados_NOM.sql para habilitar la ficha RH de empleados y sus tabs.
10. Aplicar Scripts/Nomina/04_Vistas_NOM.sql si se requiere regenerar las vistas base.
11. Aplicar Scripts/Nomina/05_StoredProcedures_NOM.sql si se requiere regenerar los SP base.
12. Aplicar Scripts/Nomina/15_Vistas_Unicas_Menu_Catalogos_NOM.sql para validar vistas de catalogos del menu.
13. Aplicar Scripts/Nomina/18_Catalogos_Ampliados_SIS_RH_NOM.sql para completar entidades SIS/RH faltantes como Tipo Sangre, Profesion, Pais y Movimiento RH.
14. Aplicar Scripts/Nomina/08_Alineacion_Menu_Claims_NOM.sql para claims y `SIS.MenuRole`.
15. Aplicar Scripts/Nomina/16_Menu_Invea_NOM.sql para insertar/actualizar el arbol Invea 610-930 y claims legacy.
16. Ejecutar EF Core Power Tools desde Visual Studio para regenerar modelos de las vistas NOM incluidas en `efpt.config.json`.

## Codigo faltante para el arbol legado

Los nodos del arbol vigente que no tienen proceso final migrado ya no quedan como 404 ni como pendiente vacio: apuntan a la pantalla operativa generica y consultan `NOM.spOperacionNomina_List`.

Los procesos de calculo/timbrado/dispersion siguen requiriendo adaptar los SP legacy antes de considerarse operacion fiscal final. Cierre, aguinaldo, prima vacacional individual y marcas presupuestales ya tienen una version de compatibilidad, pero deben sustituirse por reglas definitivas cuando se migre la logica fiscal completa.

Los nodos con entidad NOM ya migrada usan CRUD real:

- Conceptos de Nomina.
- Conceptos de importe fijo.
- Tabulador.
- Salario Minimo General.
- Forma de Pago.
- Periodos activos.
- Creditos Trabajadores.
- Plazas/Puestos.
- Universo.
- Nivel.
- Contratos laborales.
