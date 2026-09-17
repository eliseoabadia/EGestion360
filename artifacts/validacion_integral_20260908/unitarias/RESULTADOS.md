# Resultados de las pruebas unitarias existentes

Fecha: 8 de septiembre de 2026. Ejecucion: 18:32:13 a 18:32:16, UTC-06:00.

**Resultado: 38 aprobadas, 0 fallidas y 0 omitidas.** El proceso `dotnet test` termino con codigo 0. El registro no contiene advertencias ni errores de compilacion.

| Grupo | Casos ejecutados | Resultado |
|---|---:|---|
| Atributos de autorizacion y limites del acceso | 8 | Aprobados |
| Claims del contexto de usuario | 4 | Aprobados |
| Validadores de conteo ciclico | 9 | Aprobados |
| Paginacion, filtros y asignacion de empresa en servicio generico | 6 | Aprobados |
| Normalizacion y transiciones permitidas de estados de envio | 11 | Aprobados |
| **Total** | **38** | **38 aprobados** |

## Alcance comprobado

Antes de ejecutar se revisaron las cinco clases de pruebas, el repositorio de soporte en memoria, el constructor de EGestionContext, UserContextService y los pasos de compilacion. Las pruebas de contexto usan claims preparados en memoria y no ingresan a las ramas que consultan SQL. Las pruebas de autorizacion inspeccionan atributos por reflexion; no efectuan solicitudes HTTP.

La ejecucion compilo los proyectos referenciados en Release/net10.0 y ejecuto exclusivamente las pruebas existentes. No se inicio la API, no se envio correo y no se consulto ni modifico una base de datos.

Este resultado **no acredita el flujo integral de Presupuesto y Contabilidad**: no hay en esta bateria ejercicios de presupuesto aprobado/modificado, comprometido, devengado, ejercido, pagado, generacion de polizas, balanza, cierres ni integraciones con datos de prueba persistidos. Estas verificaciones requieren evidencias independientes.

## Evidencias

- `dotnet-test.log`: registro de restauracion, compilacion y ejecucion.
- `Eliseo_DESKTOP-B2UQJB2_2026-09-08_18_32_15_net10.0.trx`: resultados individuales exportados por el ejecutor.
- `resumen.json`: conteos y alcance en formato estructurado.
- `exit-code.txt`: codigo de terminacion del proceso de pruebas, 0.

Comando ejecutado desde la raiz del repositorio:

```powershell
dotnet test Tests/EG.UnidTest/EG.UnidTest.csproj -c Release --logger trx --results-directory artifacts/validacion_integral_20260908/unitarias
```

## Reindexacion asociada

Se regenero el indice en `artifacts/validacion_integral_20260908/indice_codigo` y en `.codex/tmp/project-index`, con corte del 8 de septiembre de 2026 y commit base `211aecb674e73fe750cf8f78a390ab8ba9a247f8`. Se incluyen los cambios locales del arbol de trabajo.

Inventario: 2,291 archivos; 11,280 simbolos y rutas; 1,645 declaraciones de rutas/paginas, incluidas 467 paginas Razor; 14 proyectos .NET. Se verificaron 0 archivos inexistentes, 0 rutas de directorios excluidos y equivalencia SHA256 de los cinco archivos de inventario entre ambas ubicaciones. El indice usa regex/XML y no representa cobertura funcional.
