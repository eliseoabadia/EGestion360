# Licenciamiento modular

## Ruta elegida para la primera versión

La instalación siempre contiene todos los módulos. El contrato se representa con una **licencia firmada** que se importa en el servidor del cliente. La persona que configura la instalación puede apagar módulos, pero no puede encender uno que el contrato firmado no autorice.

La documentación vigente para construir la primera versión es:

1. [Enfoque simple: licencia firmada](ENFOQUE_SIMPLE_LICENCIA_FIRMADA.md).
2. [Modelo de datos simple](MODELO_DATOS_SIMPLE.md).
3. [Plan de implementación simple](PLAN_IMPLEMENTACION_SIMPLE.md).
4. [Matriz de capacidades e integraciones](MATRIZ_CAPACIDADES_INICIALES.md).
5. [Implementación aplicada y operación](IMPLEMENTACION_APLICADA.md).

El servicio central, la sincronización continua y las tablas comerciales centrales se conservan como una alternativa posterior. No forman parte de la primera implementación:

| Documento | Uso actual |
|---|---|
| [Plan de licenciamiento modular](PLAN_LICENCIAMIENTO_MODULAR.md) | Alternativa avanzada para una fase futura con revocación remota. |
| [Modelo de datos de licenciamiento](MODELO_DATOS_LICENCIAMIENTO.md) | Modelo de la alternativa centralizada. |
| [Arquitectura de código propuesta](ARQUITECTURA_CODIGO_PROPUESTA.md) | Arquitectura de la alternativa centralizada. |
| [Backlog de implementación](BACKLOG_IMPLEMENTACION_LICENCIAS.md) | Backlog de la alternativa centralizada. |
| [Decisiones por aprobar](DECISIONES_POR_APROBAR.md) | Decisiones de producto y dependencias; las decisiones técnicas centrales fueron reemplazadas por el enfoque simple. |

La implementación ya está integrada en el código. El esquema local se crea mediante el inicializador incluido al arrancar una instalación actualizada; no se ejecutó contra una base productiva durante el desarrollo.
