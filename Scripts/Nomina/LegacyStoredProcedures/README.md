# Stored procedures legacy de Nomina

Estos archivos son extracciones de referencia para migrar la logica legacy. No se deben ejecutar directamente sobre `GestionEmpresarial` sin adaptar dependencias, nombres de esquemas y contratos de entrada/salida.

## Origen revisado

- `BD_GRP_INVEA`: no tiene stored procedures en el servidor local revisado.
- `BD_ExuxFinanzas`: contiene logica legacy de calculo y nomina actual.
- `BD_PRESUPUESTO`: contiene logica legacy de devengo/comprometido/ejercido de nomina.

## Archivos extraidos

- `BD_ExuxFinanzas.nom.spP_Nomina.sql`: candidato principal para adaptar `NOM_SP_Nomina`; depende de varios `nom.spP_*`, vistas/tablas `nom`, `emp`, `com` y `cat`.
- `BD_ExuxFinanzas.nom.SPR_NominaActual.sql`: consulta de nomina actual legacy; util para validar salidas y reportes.
- `BD_ExuxFinanzas.nom.spU_NominaAutorizar.sql`: autorizacion/cambio de estado de nomina legacy.
- `BD_ExuxFinanzas.nom.spU_Periodos.sql`: actualizacion de periodos legacy; candidato parcial para cierre.
- `BD_PRESUPUESTO.NOMI.SP_DevengaQuincena.sql`: logica presupuestal de devengo por quincena; depende de `NOMI`, `PRES`, `ORCO` y `CONTA`.
- `BD_PRESUPUESTO.NOMI.SP_WS_GetNomina.sql`: integracion legacy por archivo/servicio; usa `xp_cmdshell`, por lo que requiere rediseño antes de migrarse.
- `BD_PRESUPUESTO.PRES.SP_CREATE_DetalleComprometidoNomina.sql`: candidato para adaptar `PRES_SP_CREATE_Comprometido_Nomina`.
- `BD_PRESUPUESTO.PRES.SP_CREATE_DetalleDevengadoNomina.sql`: candidato para adaptar `PRES_SP_CREATE_Devengado_Nomina`.
- `BD_PRESUPUESTO.PRES.SP_CREATE_EgresoEjercido.sql`: candidato para adaptar `PRES_SP_CREATE_Ejercido_Nomina`.

## Siguiente paso tecnico

Mapear cada dependencia legacy contra las tablas actuales `NOM`, `RH`, `EMP`, `PRES` y `SIS`, y crear wrappers `CREATE OR ALTER PROCEDURE` en `Scripts/Nomina/05_StoredProcedures_NOM.sql` solo cuando el contrato este validado con datos reales.
