# Auditoria de menus Nomina INVEA

Fuente menu actual: Scripts/Nomina/16_Menu_Invea_NOM.sql
Fuente legado revisada: C:\Desarrollo\Desarrollo\CIANET\Invea

Regla aplicada: si tiene FK se prepara con vista para lectura; si es calculo/proceso/reporte/historico se prepara con SP o vista readonly; catalogo simple va por entidad/catalogo directo.

## Resumen

- TOTAL: 116
- GRUPO: 16
- MIGRADO: 100
- PENDIENTE: 0
- Claims OK: 116

## Detalle

| Id | Menu | Ruta | Claim menu | Claim | Estado | Origen viejo | Vista SQL | Regla | Accion |
|---:|---|---|---|---|---|---|---|---|---|
| 610 | Calculo | `/nom/calcnomina` | `Calculo_2050` | OK | MIGRADO | CalcnominaComponent |  | Complejo: SP/vista readonly | Preparar SP o vista readonly |
| 620 | Auxiliares | `/` | `Nomina_Auxiliares` | OK | GRUPO |  |  | Grupo menu |  |
| 621 | Calculo ISSSTE | `/aux/auxcalcissste` | `Calculo_ISSSTE_4134` | OK | MIGRADO | AuxCalcISSSTEComponent |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 622 | Calculo ISR | `/aux/auxcalcisrquincenal` | `Calculo_ISR_2053` | OK | MIGRADO | AuxCalcISRQuincenalComponent | AUX_VW_AuxCalcISRQuincenal.sql | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 623 | Calculo FOVISSSTE | `/aux/auxcalcfovissste` | `Calculo_FOVISSSTE_4136` | OK | MIGRADO | AuxCalcFovisssteComponent |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 624 | Calculo Infonavit | `/aux/auxcalcinfonavitquincenal` | `Calculo_Infonavit_139` | OK | MIGRADO | AuxCalcInfonavitQuincenalComponent | AUX_VW_AUXCalcInfonavitQuincenal.sql | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 625 | Calculo Cuotas IMSS | `/aux/auxcalcimssquincenal` | `Calculo_IMSS_3084` | OK | MIGRADO | AuxCalcIMSSQuincenalComponent | AUX_VW_AuxCalcIMSSQuincenal.sql | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 630 | Productos | `/` | `Nomina_Productos` | OK | GRUPO |  |  | Grupo menu |  |
| 631 | Resumen | `/nom/resumennomina` | `Resumen` | OK | MIGRADO | VW_ResumenNominaComponent | NHIS_VW_ResumenNomina.sql | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 632 | Recibos | `/nom/recibonomina` | `Recibos` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 633 | Archivos de Dispersion | `/nom/archivodispercion` | `Archivos_Dispersion` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 634 | Archivos de Timbrado | `/nom/timbradopercepciones` | `Archivos_Timbrado` | OK | MIGRADO | VW_TimbradoPercepcionesComponent | NOM_VW_Timbrado_Percepciones.sql | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 635 | Reporte Cuotas IMSS | `/aux/imssquincenal_rep` | `Reporte_Cuotas_IMSS` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 636 | Reporte Nomina Actual | `/nom/reportenomina` | `Reporte_Nomina` | OK | MIGRADO | VW_ReporteNominaComponent | NHIS_VW_ReporteNomina.sql | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 640 | Incidencias | `/` | `Nomina_Incidencias` | OK | GRUPO |  |  | Grupo menu |  |
| 641 | Captura de Incidencias | `/rh/incidencia` | `Captura_Incidencias` | OK | MIGRADO | IncidenciaComponent |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 642 | Justificacion de Incidencias | `/rh/justificacion` | `Justificacion_Incidencias` | OK | MIGRADO | JustificacionComponent |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 643 | Reporte de Incidencias | `/rh/incidenciareport` | `Reporte_Incidencias` | OK | MIGRADO | IncidenciaReportComponent |  | Complejo: SP/vista readonly | Preparar SP o vista readonly |
| 650 | Pagos Extraordinarios | `/nom/conceptovariable` | `Conceptos_Variables` | OK | MIGRADO | ConceptoVariableComponent |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 660 | Cierre de Periodo | `/nom/cierraperiodo` | `Cierre_Periodo` | OK | MIGRADO | CierreperiodoComponent |  | Complejo: SP/vista readonly | Preparar SP o vista readonly |
| 670 | Finiquito/Liquidacion | `/rh/liquidacion` | `Liquidacion` | OK | MIGRADO | LiquidacionComponent |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 680 | Nominas Especiales | `/` | `Nominas_Especiales` | OK | GRUPO |  |  | Grupo menu |  |
| 681 | Calculo de Aguinaldo | `/nom/calcaguinaldo` | `Calc_Aguinaldo` | OK | MIGRADO | CalcAguinaldoComponent |  | Complejo: SP/vista readonly | Preparar SP o vista readonly |
| 682 | Configura Aguinaldo | `/sis/nominaespecial` | `Configura_Aguinaldo` | OK | MIGRADO | NominaEspecialComponent | NOM_VW_NominaEspecial.sql | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 683 | Aguinaldo | `/sis/vwnominaespecial` | `Aguinaldo` | OK | MIGRADO | VW_NominaEspComponent | NOM_VW_NominaEspecial.sql | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 684 | Faltas Especiales | `/emp/faltasxempresa` | `Faltas_Especial` | OK | MIGRADO | FaltasXEmpresaComponent |  | Simple: catalogo/entidad directa | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 700 | Historicos de Nomina | `/` | `Nomina_Historicos` | OK | GRUPO |  |  | Grupo menu |  |
| 710 | Productos | `/` | `Nomina_Productos_Historicos` | OK | GRUPO |  |  | Grupo menu |  |
| 711 | Consulta de Nomina | `/nomina/historicos/consulta` | `Consulta_Nomina` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 712 | Analisis | `/nomina/historicos/analisis` | `Analisis` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 713 | Recibos | `/nomina/historicos/recibos` | `Recibos_Historicos` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 714 | Archivos de Dispersion | `/nomina/historicos/dispersion` | `Archivos_Dispersion_Historicos` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 715 | Archivos de Timbrado | `/nomina/historicos/timbrado` | `Archivos_Timbrado_Historicos` | OK | MIGRADO |  | NOM_VW_Timbrado_Deducciones.sql | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 716 | Reporte Nomina Quincenal | `/nomina/historicos/reportequincenal` | `Reporte_Nomina_Quincenal` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 717 | Resumen de Nomina Historica | `/nomina/historicos/resumen` | `Resumen_Nomina_Historica` | OK | MIGRADO |  | NHIS_VW_ResumenNomina.sql | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 718 | Reporte de Nomina Historica | `/nomina/historicos/reportehistorico` | `Reporte_Nomina_Historica` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 719 | Cubo Nomina Historica | `/nomina/historicos/cubo` | `Cubo_Nomina_Historica` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 720 | Reportes del IMSS | `/` | `Reportes_IMSS_Historicos` | OK | GRUPO |  |  | Grupo menu |  |
| 721 | Salario Base de Cotizacion | `/nomina/historicos/sbc` | `Salario_Base_Cotizacion` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 722 | Acumulados IMSS | `/nomina/historicos/acumuladosimss` | `Acumulados_IMSS` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 723 | SBC Historico | `/nomina/historicos/sbchistorico` | `SBC_Historico` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 724 | Acumulados en el Bimestre IMSS | `/nomina/historicos/acumuladosbimestre` | `Acumulados_Bimestre_IMSS` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 730 | Reportes del SAT | `/` | `Reportes_SAT_Historicos` | OK | GRUPO |  |  | Grupo menu |  |
| 731 | Acumulado Mensual ISR | `/nomina/historicos/isr_mensual` | `Acumulado_Mensual_ISR` | OK | MIGRADO |  | AUX_VW_AuxCalcISRMensual.sql | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 732 | Acumulados de ISR | `/nomina/historicos/isr_acumulados` | `Acumulados_ISR` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 740 | Impuestos sobre Nomina locales | `/nomina/historicos/impuestoslocales` | `Impuestos_Locales` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 800 | Configuracion Nominas | `/` | `Configuracion_Nominas` | OK | GRUPO |  |  | Grupo menu |  |
| 810 | Catalogos | `/` | `Nomina_Catalogos` | OK | GRUPO |  |  | Grupo menu |  |
| 811 | Tipo de Nomina | `/nomina/configuracion/catalogos/tipo-nomina` | `Tipo_Nomina` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 812 | Cuotas IMSS | `/nomina/configuracion/catalogos/cuotas-imss` | `Cuotas_IMSS` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 813 | Conceptos de Nomina | `/nomina/configuracion/catalogos/conceptos` | `Conceptos_Nomina` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 814 | UMA | `/nomina/configuracion/catalogos/uma` | `UMA` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 815 | Tipo de Contratacion | `/nomina/configuracion/catalogos/tipo-contratacion` | `Tipo_Contratacion` | OK | MIGRADO |  | `SIS.TipoContratacion` | Entidad directa SIS | Espejo NOM.CatalogoSimple conservado temporalmente por FKs operativas |
| 816 | Tipo de descanso | `/nomina/configuracion/catalogos/tipo-descanso` | `Tipo_Descanso` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 817 | Tipo de Incidencia | `/nomina/configuracion/catalogos/tipo-incidencia` | `Tipo_Incidencia` | OK | MIGRADO |  | `SIS.TipoIncidencia` | Entidad directa SIS | Espejo NOM.CatalogoSimple conservado temporalmente por FKs operativas |
| 818 | Conceptos de importe Fijo | `/nomina/configuracion/catalogos/concepto-fijo` | `Concepto_Fijo` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 819 | Tipo de Justificacion | `/nomina/configuracion/catalogos/tipo-justificacion` | `Tipo_Justificacion` | OK | MIGRADO |  | `SIS.TipoJustificacion` | Entidad directa SIS | Espejo NOM.CatalogoSimple conservado temporalmente por FKs operativas |
| 820 | Tabulador | `/nomina/configuracion/catalogos/tabulador` | `Tabulador` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 821 | Unidad Infonavit | `/nomina/configuracion/catalogos/unidad-infonavit` | `Unidad_Infonavit` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 822 | Salario Minimo General | `/nomina/configuracion/catalogos/smg` | `Salario_Minimo` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 823 | Forma de Pago | `/nomina/configuracion/catalogos/forma-pago` | `Forma_Pago` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 824 | Forma de Calculo | `/nomina/configuracion/catalogos/forma-calculo` | `Forma_Calculo` | OK | MIGRADO |  |  | Complejo: SP/vista readonly | Preparar SP o vista readonly |
| 825 | Capitulos | `/nomina/configuracion/catalogos/capitulos` | `Capitulos` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 830 | Periodos | `/` | `Nomina_Periodos` | OK | GRUPO |  |  | Grupo menu |  |
| 831 | Semanal | `/nomina/configuracion/periodos/semanal` | `Periodo_Semanal` | OK | MIGRADO |  | AUX_VW_AuxCalcIMSSSemanal.sql | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 832 | Quincenal | `/nomina/configuracion/periodos/quincenal` | `Periodo_Quincenal` | OK | MIGRADO |  | AUX_VW_AuxCalcIMSSQuincenal.sql | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 833 | Mensual | `/nomina/configuracion/periodos/mensual` | `Periodo_Mensual` | OK | MIGRADO |  | AUX_VW_AuxCalcIMSSMensual.sql | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 834 | Bimestral | `/nomina/configuracion/periodos/bimestral` | `Periodo_Bimestral` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 840 | Tablas ISR | `/` | `Nomina_Tablas_ISR` | OK | GRUPO |  |  | Grupo menu |  |
| 841 | Semanal | `/nomina/configuracion/isr/semanal` | `Tabla_ISR_Semanal` | OK | MIGRADO |  | AUX_VW_AuxCalcIMSSSemanal.sql | FK: vista para lectura + entidad/SP para guardar | Migrado a CRUD NOM.TablaFiscal; vista especifica preparada segun regla FK/vista |
| 842 | Quincenal | `/nomina/configuracion/isr/quincenal` | `Tabla_ISR_Quincenal` | OK | MIGRADO |  | AUX_VW_AuxCalcIMSSQuincenal.sql | FK: vista para lectura + entidad/SP para guardar | Migrado a CRUD NOM.TablaFiscal; vista especifica preparada segun regla FK/vista |
| 843 | Mensual | `/nomina/configuracion/isr/mensual` | `Tabla_ISR_Mensual` | OK | MIGRADO |  | AUX_VW_AuxCalcIMSSMensual.sql | FK: vista para lectura + entidad/SP para guardar | Migrado a CRUD NOM.TablaFiscal; vista especifica preparada segun regla FK/vista |
| 850 | Prestaciones | `/` | `Nomina_Prestaciones` | OK | GRUPO |  |  | Grupo menu |  |
| 860 | Subsidios ISR | `/` | `Nomina_Subsidios_ISR` | OK | GRUPO |  |  | Grupo menu |  |
| 861 | Semanal | `/nomina/configuracion/subsidios/semanal` | `Subsidio_ISR_Semanal` | OK | MIGRADO |  | AUX_VW_AuxCalcIMSSSemanal.sql | FK: vista para lectura + entidad/SP para guardar | Migrado a CRUD NOM.TablaFiscal; vista especifica preparada segun regla FK/vista |
| 862 | Quincenal | `/nomina/configuracion/subsidios/quincenal` | `Subsidio_ISR_Quincenal` | OK | MIGRADO |  | AUX_VW_AuxCalcIMSSQuincenal.sql | FK: vista para lectura + entidad/SP para guardar | Migrado a CRUD NOM.TablaFiscal; vista especifica preparada segun regla FK/vista |
| 863 | Mensual | `/nomina/configuracion/subsidios/mensual` | `Subsidio_ISR_Mensual` | OK | MIGRADO |  | AUX_VW_AuxCalcIMSSMensual.sql | FK: vista para lectura + entidad/SP para guardar | Migrado a CRUD NOM.TablaFiscal; vista especifica preparada segun regla FK/vista |
| 870 | Impuestos | `/` | `Nomina_Impuestos` | OK | GRUPO |  |  | Grupo menu |  |
| 871 | Base Gravable | `/nomina/configuracion/impuestos/base-gravable` | `Base_Gravable` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa | Migrado a CRUD NOM.TablaFiscal; vista especifica preparada segun regla FK/vista |
| 872 | Impuestos Locales | `/nomina/configuracion/impuestos/locales` | `Impuestos_Locales` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa | Migrado a CRUD NOM.TablaFiscal; vista especifica preparada segun regla FK/vista |
| 880 | IMSS | `/` | `Nomina_IMSS` | OK | GRUPO |  |  | Grupo menu |  |
| 881 | Prestaciones Minimas de Ley | `/nomina/configuracion/imss/prestaciones` | `Prestaciones_Minimas` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa | Migrado a CRUD NOM.FactorInt; vista NOM.Vw_PrestacionesMinimas preparada |
| 882 | Clase IMSS | `/nomina/configuracion/imss/clase` | `Clase_IMSS` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa | Migrado a CRUD NOM.TablaFiscal; vista especifica preparada segun regla FK/vista |
| 883 | Fraccion IMSS | `/nomina/configuracion/imss/fraccion` | `Fraccion_IMSS` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa | Migrado a CRUD NOM.TablaFiscal; vista especifica preparada segun regla FK/vista |
| 884 | Base Gravable IMSS | `/nomina/configuracion/imss/base-gravable` | `Base_Gravable_IMSS` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa | Migrado a CRUD NOM.TablaFiscal; vista especifica preparada segun regla FK/vista |
| 900 | Configuracion RH | `/rh/configuracion` | `Configuracion_RH` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa | Migrado a visor operativo NOM.spOperacionNomina_List; proceso final queda por SP especifico cuando aplique |
| 901 | Plazas Autorizadas | `/rh/configuracion/plazas` | `Plazas_Autorizadas` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 902 | Universo | `/rh/configuracion/universo` | `Universo` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 903 | Nivel | `/rh/configuracion/nivel` | `Nivel` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 904 | Sexo | `/rh/configuracion/sexo` | `Sexo` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 905 | Estado Civil | `/rh/configuracion/estado-civil` | `Estado_Civil` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 906 | Escolaridad | `/rh/configuracion/escolaridad` | `Escolaridad` | OK | MIGRADO | BD_GRP_INVEA.dbo.SIS_Escolaridad | SIS.Escolaridad | Entidad directa SIS | Migrado a CRUD propio `NomEscolaridades.razor` + API `NomEscolaridad` |
| 907 | Tipo de Parentesco | `/rh/configuracion/parentesco` | `Tipo_Parentesco` | OK | MIGRADO |  | `SIS.Parentesco` | Entidad directa SIS | Espejo NOM.CatalogoSimple conservado temporalmente por FKs operativas |
| 908 | Estado | `/rh/configuracion/estado` | `Estado` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 909 | Banco | `/rh/configuracion/banco` | `Banco` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 910 | Municipio | `/rh/configuracion/municipio` | `Municipio` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 911 | Contratos | `/rh/configuracion/contratos` | `Contratos` | OK | MIGRADO |  | RH_VW_Contratos_Todos.sql | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 912 | Base Pago | `/rh/configuracion/contratos/base-pago` | `Base_Pago` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 913 | Metodo de Pago | `/rh/configuracion/contratos/metodo-pago` | `Metodo_Pago` | OK | MIGRADO | `SIS.MedodoPago` | `FrontEnd\EG.Web\Pages\Modules\Nomina\Configuration\Catalogos\NomMedodoPagos.razor` | Entidad directa sin vista ni SP | Migrar `dbo.SIS_MedodoPago` a `SIS.MedodoPago` |
| 914 | Tipo de Regimen | `/rh/configuracion/contratos/tipo-regimen` | `Tipo_Regimen` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 915 | Base de Cotizacion | `/rh/configuracion/contratos/base-cotizacion` | `Base_Cotizacion` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 916 | Zona Geografica | `/rh/configuracion/contratos/zona-geografica` | `Zona_Geografica` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 917 | Dia de la Semana | `/rh/configuracion/contratos/dia-semana` | `Dia_Semana` | OK | MIGRADO | `SIS.DiaSemana` | `FrontEnd\EG.Web\Pages\Modules\Nomina\Configuration\Catalogos\NomDiaSemanas.razor` | Entidad directa sin vista ni SP | Migrar `dbo.SIS_DiaSemana` a `SIS.DiaSemana` |
| 918 | Tipo de Sangre | `/rh/configuracion/tipo-sangre` | `Tipo_Sangre` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 919 | Profesion | `/rh/configuracion/profesion` | `Profesion` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 920 | Regimen Fiscal | `/rh/configuracion/regimen-fiscal` | `Regimen_Fiscal` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 921 | Pais | `/rh/configuracion/pais` | `Pais` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 922 | Periodo de Pago | `/rh/configuracion/periodo-pago` | `Periodo_Pago` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 923 | Tipo Documento RH | `/rh/configuracion/tipo-documento` | `Tipo_Documento_RH` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 924 | Tipo Expediente | `/rh/configuracion/tipo-expediente` | `Tipo_Expediente` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 925 | Opcion Jubilacion | `/rh/configuracion/opcion-jubilacion` | `Opcion_Jubilacion` | OK | MIGRADO |  |  | Simple: catalogo/entidad directa |  |
| 926 | Situacion Persona | `/rh/configuracion/situacion-persona` | `Situacion_Persona` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 927 | Situacion Plaza | `/rh/configuracion/situacion-plaza` | `Situacion_Plaza` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 928 | Situacion Movimiento | `/rh/configuracion/situacion-movimiento` | `Situacion_Movimiento` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 929 | Clase Movimiento | `/rh/configuracion/clase-movimiento` | `Clase_Movimiento` | OK | MIGRADO |  |  | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
| 930 | Movimiento RH | `/rh/configuracion/movimiento` | `Movimiento_RH` | OK | MIGRADO |  | RH_VW_MovimientosXQuincena.sql | FK: vista para lectura + entidad/SP para guardar | Preparar Vw* para joins/FK |
