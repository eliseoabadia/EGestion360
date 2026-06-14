# Migracion Nomina INVEA -> EGestion360

Este bloque migra la base operativa/catalogos de Nomina a la arquitectura modular de EGestion360.

## Incluido

- 24 entidades NOM normalizadas a esquema [NOM].[Tabla].
- DTOs/Responses con campos de control.
- Servicios por controlador usando GenericService y registro de errores con EG.Logger.
- Controladores API sin acceso directo a BD.
- Paginas Blazor con GenericTable y dialogo generico de catalogo.
- Scripts SQL manuales de estructura, datos y menu/claims.

## Pendiente critico

Los SP del API fuente no vienen en migration_sqlserver ni en el dump revisado. Procesos como calculo/cierre/timbrado requieren recuperar y migrar estos SP antes de habilitar operacion completa:

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
3. Revisar dependencias de puestos, forma de calculo, periodos e Infonavit.
4. Aplicar Scripts/Nomina/02_Datos_NOM_Migracion.sql si las llaves base existen.
5. Aplicar manualmente Scripts/Nomina/03_Menu_Claims_NOM.sql ajustando IDs.