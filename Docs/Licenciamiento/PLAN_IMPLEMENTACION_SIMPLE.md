# Plan de implementación: licencia firmada simple

Fecha: 12 de septiembre de 2026. Estado: implementación base terminada en el código; queda validarla en una instalación de pruebas y sustituir la cuenta SQL `sa` antes de liberarla.

## Resultado de la primera entrega

Una instalación completa de GE360 puede recibir un archivo `.lic` firmado. Un administrador local puede apagar o encender sólo los módulos que el archivo permite. Los módulos no vendidos o vencidos no aparecen como disponibles y el backend rechaza sus operaciones, incluso mediante una llamada directa a la API.

La primera entrega no requiere un servidor de licencias, una conexión a Internet ni reinicios manuales de IIS para que venza un módulo.

## Fase 0. Decisiones y preparación

1. Confirmar la vigencia normal de los contratos revocables: la propuesta es 30, 60, 90 o 365 días.
2. Nombrar a las personas de GE360 que pueden emitir licencias y custodiar la clave privada.
3. Definir el permiso administrativo que puede importar licencias y ajustar módulos.
4. Acordar el comportamiento inicial de un módulo vencido: bloquear operaciones y conservar datos; los accesos históricos específicos se agregan después de identificar cada reporte.
5. Validar la [matriz de capacidades](MATRIZ_CAPACIDADES_INICIALES.md), empezando por Almacén y sus cruces.
6. Preparar una cuenta técnica SQL de aplicación con permisos mínimos, sustituyendo la conexión productiva con `sa` antes de liberar esta función.

## Fase 1. Núcleo de licencia en el backend

Crear un componente del backend, por ejemplo `ILicenseCapabilityEvaluator`, con cuatro responsabilidades:

- importar y validar un sobre firmado;
- resolver si un módulo o capacidad está contratado, vigente y activo localmente;
- detectar retroceso de reloj y devolver una causa segura de bloqueo;
- exponer una instantánea de sólo lectura para Blazor.

El evaluador se registra en la API y no se coloca en el frontend. La autorización existente de permisos personales se mantiene; el evaluador añade un requisito comercial antes de ejecutar operaciones. Los resultados iniciales serán claros y reutilizables:

| Código | Significado |
|---|---|
| `LIC_MODULO_NO_CONTRATADO` | El contrato firmado no incluye el módulo. |
| `LIC_MODULO_VENCIDO` | El contrato terminó. |
| `LIC_MODULO_DESACTIVADO` | Un administrador local decidió apagarlo. |
| `LIC_INTEGRACION_INCOMPLETA` | Falta uno de los módulos requeridos por el cruce. |
| `LIC_ARCHIVO_INVALIDO` | Firma, instalación, serial o formato inválido. |
| `LIC_RELOJ_SOSPECHOSO` | La hora local retrocedió y requiere atención. |

No se usan claims del JWT para guardar derechos comerciales, porque una renovación o vencimiento debe hacerse efectiva sin volver a emitir el token del usuario.

## Fase 2. Base local y seguridad de instalación

1. Crear el esquema y las seis tablas descritas en [MODELO_DATOS_SIMPLE.md](MODELO_DATOS_SIMPLE.md), mediante un script repetible y revisado en una base de pruebas.
2. Sembrar los ocho códigos de `LIC.Modulo`.
3. En el primer arranque, crear `InstalacionId` y un secreto aleatorio protegido por ASP.NET Core Data Protection.
4. Mostrar y exportar la solicitud de instalación para que GE360 emita el primer archivo.
5. Guardar el serial y la hora máxima aceptada en el estado protegido de máquina.
6. Añadir auditoría sin registrar archivos completos, claves, contraseñas ni información innecesaria.

No se ejecutará este script en producción hasta revisar el destino, respaldos y mecanismo de despliegue que usa el proyecto.

## Fase 3. Generador interno de licencias

Crear un pequeño `GE360.Licensing.Generator.exe` para uso interno de GE360. No se distribuye al cliente ni se agrega al paquete de IIS.

El generador recibe la solicitud de instalación y el contrato. Genera un JWS firmado con:

- producto y versión de formato;
- identificador y huella de la instalación;
- serial consecutivo por instalación;
- módulos, inicios y finales de vigencia;
- fecha de emisión y `keyId` de firma.

Antes de emitir, el generador rechaza un serial repetido, un módulo desconocido, fechas inválidas y una solicitud de otra instalación. Conserva un registro interno mínimo de qué licencia se entregó, pero no necesita exponer una API al cliente.

La clave privada se carga de un almacén protegido de GE360. No se acepta una clave desde argumentos, archivos del proyecto ni variables visibles durante el despliegue del cliente.

## Fase 4. Pantalla de configuración

Agregar **Sistema > Licencia y módulos** con estas acciones:

1. Crear o consultar la solicitud de instalación.
2. Importar un `.lic` firmado.
3. Ver número de licencia, serial, módulos, vigencias y mensajes de estado.
4. Apagar o encender sólo módulos que sigan contratados y vigentes.
5. Consultar auditoría y descargar un diagnóstico sin secretos.

La pantalla debe requerir el nuevo permiso administrativo. El cambio local se registra, invalida el estado de menú del usuario y no exige reiniciar IIS. El backend vuelve a consultar el evaluador en la siguiente operación.

## Fase 5. Aplicación de controles por capas

Cada capacidad se protege en tres lugares cuando existan:

| Capa | Acción |
|---|---|
| Interfaz | Ocultar o bloquear menú, tarjeta, botón y búsqueda. |
| API | Rechazar endpoint antes de cambiar datos. |
| Servicio/proceso | Revalidar antes de procedimientos SQL, reportes, exportaciones, lotes y tareas alojadas. |

El control de interfaz mejora la claridad, pero API y servicio son obligatorios. `SuperAdmin` no debe crear un camino que salte la licencia.

El piloto recomendado es `GRP.ALMA`, porque permite probar controles propios e integraciones. Se aplican además los requisitos de `GRP.ADQ` en recepción desde orden y de `GRP.CONTA` cuando una salida genera póliza. Después se replica el patrón a Adquisiciones, Presupuesto, Patrimonio, Nómina, PBR y Administración funcional.

## Fase 6. Pruebas de aceptación

| Caso | Resultado esperado |
|---|---|
| Archivo firmado correcto para Almacén | Se importa y permite sólo las capacidades vendidas. |
| JSON o firma alterada | Se rechaza y no cambia configuración ni derechos. |
| `ActivoOperativo = 1` en SQL para PBR no contratado | El backend mantiene el rechazo. |
| Usuario sin permiso funcional | La licencia válida no le concede la acción. |
| Llamada directa a API sin módulo | No se escriben datos. |
| Almacén activo, Contabilidad no contratada | Se bloquea sólo la salida que genera póliza. |
| Módulo con fecha vencida | Se bloquea sin reiniciar IIS. |
| Renovación con serial mayor | Se aplica al importar y actualiza menús/capacidades. |
| Archivo de serial anterior | Se rechaza. |
| Reloj del servidor retrocede | Se registra el evento y se bloquean escrituras comerciales. |

Las pruebas se harán con usuarios de prueba, llamadas directas a endpoints y revisión de que una denegación no modifique información.

## Fase 7. Criterios para liberar

Se considera lista la primera versión cuando:

- ningún módulo no contratado puede activarse desde la pantalla, API o tablas locales;
- todos los módulos vendidos se pueden apagar sin reiniciar el servidor;
- un vencimiento de prueba bloquea operaciones por fecha;
- las integraciones comunican el módulo faltante;
- el código no contiene la clave privada de firma;
- importar, rechazar, encender y apagar deja auditoría;
- el despliegue usa una cuenta SQL de aplicación con permisos mínimos;
- las pruebas de la fase 6 pasan en una instalación de prueba.

## Lo que queda para una fase posterior

La alternativa centralizada puede añadirse después si se necesita revocación inmediata, suspensión desde GE360 sin cooperación del cliente, administración masiva de contratos o un panel comercial en línea. Está documentada por separado en [PLAN_LICENCIAMIENTO_MODULAR.md](PLAN_LICENCIAMIENTO_MODULAR.md) y no bloquea esta ruta simple.
