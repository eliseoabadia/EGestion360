# Modelo de datos simple para licencia firmada

Fecha: 12 de septiembre de 2026. Este documento describe el esquema local propuesto para SQL Server. No es un script ejecutado ni autoriza cambios sobre una base productiva.

## 1. Alcance y principio de autoridad

Se agrega el esquema `LIC` a la base ya usada por cada instalación. No se crea una base central en esta etapa.

La autoridad comercial es el **sobre firmado original** guardado en `LIC.LicenciaImportada` y validado criptográficamente por el backend. Las tablas normalizadas facilitan consultas, menús y auditoría; por sí solas nunca conceden un módulo. En particular, cambiar `ActivoOperativo`, insertar una fila de módulo o editar una fecha en SQL no puede convertir un módulo no contratado en autorizado.

Las seis tablas propuestas son suficientes para la primera versión:

| Tabla | Propósito |
|---|---|
| `LIC.Modulo` | Catálogo fijo de los ocho módulos comerciales. |
| `LIC.EstadoInstalacion` | Identidad local, serial mínimo aceptado y sello de tiempo protegido. Una sola fila. |
| `LIC.LicenciaImportada` | Sobres `.lic` recibidos, aceptados o rechazados; conserva el original. |
| `LIC.LicenciaModulo` | Vista normalizada de los módulos extraídos de un sobre ya validado. |
| `LIC.ConfiguracionModulo` | Decisión local de dejar activo o apagar un módulo contratado. |
| `LIC.EventoLicencia` | Auditoría anexa de importación, configuración, vencimiento y anomalías. |

Todos los tiempos son `datetime2(3)` en UTC. Las tablas mutables usan `rowversion`; los eventos y el sobre original se conservan para trazabilidad y no se actualizan para cambiar el pasado.

## 2. `LIC.Modulo`

Catálogo sembrado mediante script repetible. No se administra desde la pantalla del cliente.

| Campo | Tipo | Regla |
|---|---|---|
| `CodigoModulo` | `varchar(32)` | PK. Código estable comercial. |
| `Nombre` | `nvarchar(80)` | Etiqueta visible. |
| `Grupo` | `varchar(16)` | `GRP` o `INDEPENDIENTE`. |
| `Orden` | `smallint` | Orden de presentación; `UNIQUE`. |
| `ActivoCatalogo` | `bit` | Permite retirar un producto de nuevas licencias, sin reinterpretar las anteriores. |
| `CreadoUtc` | `datetime2(3)` | Auditoría. |
| `RowVersion` | `rowversion` | Concurrencia. |

Filas iniciales:

```text
GRP.ADMIN, GRP.ADQ, GRP.ALMA, GRP.CONTA,
GRP.PATRI, GRP.PRES, NOM, PBR
```

El núcleo de acceso, usuarios, configuración de licencia y recuperación no se agrega a este catálogo porque no es un módulo comercial.

## 3. `LIC.EstadoInstalacion`

Contiene una sola fila por base, con `PkidEstado = 1`. No es una tabla de configuraciones libres.

| Campo | Tipo | Regla |
|---|---|---|
| `PkidEstado` | `tinyint` | PK con `CHECK (PkidEstado = 1)`. |
| `InstalacionId` | `uniqueidentifier` | `UNIQUE`; se crea una vez en el primer asistente. |
| `HuellaInstalacion` | `char(64)` | SHA-256 hexadecimal del secreto aleatorio protegido; `UNIQUE`. |
| `SerialMinimoAceptado` | `bigint` | Mayor serial de licencia aceptado. No puede ser negativo. |
| `UltimaHoraConfiableUtc` | `datetime2(3)` | Última hora UTC admitida por el evaluador. |
| `EstadoReloj` | `varchar(16)` | `VALIDO` o `SOSPECHOSO`. |
| `SelloProtegidoMaquina` | `varbinary(max)` | Copia protegida en Windows de instalación, serial y hora. No contiene la clave privada de firma. |
| `CreadoUtc` / `ModificadoUtc` | `datetime2(3)` | Auditoría. |
| `RowVersion` | `rowversion` | Concurrencia. |

El secreto aleatorio de instalación queda dentro de `SelloProtegidoMaquina`, protegido por ASP.NET Core Data Protection. El campo visible sólo conserva su huella. El sello se compara con el identificador, serial y huella visibles; una edición directa de SQL no puede producir un sello nuevo válido sin las llaves de protección de la instalación.

Este mecanismo detecta cambios ordinarios de reloj o de base de datos. No sustituye un servicio central frente a quien pueda restaurar el servidor completo, incluidos sus secretos y respaldos.

## 4. `LIC.LicenciaImportada`

Guarda cada archivo procesado. El backend trabaja sobre el sobre firmado exacto, no sobre valores reescritos por SQL.

| Campo | Tipo | Regla |
|---|---|---|
| `PkidLicenciaImportada` | `bigint identity` | PK técnica. |
| `LicenciaId` | `uniqueidentifier` | Identificador firmado; `UNIQUE`. |
| `InstalacionId` | `uniqueidentifier` | Debe coincidir con `LIC.EstadoInstalacion`. |
| `Serial` | `bigint` | Revisión comercial firmada; `UNIQUE (InstalacionId, Serial)`. |
| `VersionFormato` | `smallint` | Formato que entiende el backend. |
| `KeyId` | `varchar(32)` | Identifica una clave pública permitida. |
| `SobreFirmado` | `nvarchar(max)` | JWS original recibido; no se reconstruye con columnas. |
| `HuellaSobre` | `binary(32)` | SHA-256 del sobre exacto; `UNIQUE`. |
| `EmitidaUtc` | `datetime2(3)` | Copia de la reclamación validada. |
| `VigenteDesdeUtc` | `datetime2(3)` | Copia de la reclamación validada. |
| `Resultado` | `varchar(16)` | `ACEPTADA`, `RECHAZADA` o `SUSTITUIDA`. |
| `MotivoRechazo` | `nvarchar(500) NULL` | Sólo para diagnóstico seguro; no guardar el archivo completo en logs. |
| `ImportadaPor` | `nvarchar(128) NULL` | Identidad del usuario que ejecutó la acción. |
| `ImportadaUtc` | `datetime2(3)` | Auditoría. |
| `RowVersion` | `rowversion` | Concurrencia. |

Una licencia se considera apta para evaluación únicamente si su firma vuelve a verificarse, su instalación coincide y su serial es igual al que marca el sello protegido de la máquina. `Resultado = ACEPTADA` no basta por sí solo.

## 5. `LIC.LicenciaModulo`

Se rellena dentro de la transacción de importación sólo después de que el sobre pase todas las verificaciones. Acelera la pantalla y la consulta de capacidades, pero es una copia derivada.

| Campo | Tipo | Regla |
|---|---|---|
| `PkidLicenciaModulo` | `bigint identity` | PK técnica. |
| `FkidLicenciaImportada` | `bigint` | FK a `LIC.LicenciaImportada`. |
| `CodigoModulo` | `varchar(32)` | FK a `LIC.Modulo`. |
| `InicioUtc` | `datetime2(3)` | Inicio de uso firmado. |
| `FinUtc` | `datetime2(3) NULL` | Fin firmado. Para productos revocables debe ser obligatorio. |
| `EsContratoActivo` | `bit` | Copia firmada de la concesión; normalmente `1`. |
| `CreadoUtc` | `datetime2(3)` | Auditoría. |

Reglas:

- `UNIQUE (FkidLicenciaImportada, CodigoModulo)`.
- `CHECK (FinUtc IS NULL OR FinUtc > InicioUtc)`.
- una operación comercial toma el módulo con el serial actual y vuelve a validar su sobre firmado;
- no se consulta una fila de una licencia anterior como forma de reactivar un producto vencido.

## 6. `LIC.ConfiguracionModulo`

Registra la decisión operativa local. Tiene una fila por módulo del catálogo.

| Campo | Tipo | Regla |
|---|---|---|
| `CodigoModulo` | `varchar(32)` | PK y FK a `LIC.Modulo`. |
| `ActivoOperativo` | `bit` | Puede apagar un módulo autorizado; no concede contrato. |
| `Motivo` | `nvarchar(300) NULL` | Recomendado cuando se apaga. |
| `ActualizadoPor` | `nvarchar(128) NULL` | Usuario autorizado. |
| `ActualizadoUtc` | `datetime2(3)` | Auditoría. |
| `RowVersion` | `rowversion` | Evita sobrescrituras concurrentes. |

Al importar la primera licencia, los módulos contratados quedan activos y los no contratados quedan apagados. Si llega una nueva licencia, una desactivación explícita se conserva para un módulo que siga contratado; un código que deje de estar contratado queda bloqueado independientemente de su valor local.

La fórmula que usa el backend es:

```text
Habilitado efectivo = sobre firmado válido
                   Y módulo contratado y vigente
                   Y ConfiguracionModulo.ActivoOperativo
```

Por ello, establecer `ActivoOperativo = 1` en SQL no habilita un módulo ausente, vencido o firmado para otra instalación.

## 7. `LIC.EventoLicencia`

Bitácora anexa, sin borrado lógico para ocultar cambios.

| Campo | Tipo | Regla |
|---|---|---|
| `PkidEventoLicencia` | `bigint identity` | PK. |
| `FkidLicenciaImportada` | `bigint NULL` | FK cuando el evento corresponde a un archivo. |
| `Tipo` | `varchar(32)` | `SOLICITUD_CREADA`, `IMPORTACION_ACEPTADA`, `IMPORTACION_RECHAZADA`, `MODULO_APAGADO`, `MODULO_ENCENDIDO`, `VENCIMIENTO`, `RELOJ_SOSPECHOSO`, `RECUPERACION`. |
| `CodigoModulo` | `varchar(32) NULL` | FK opcional a `LIC.Modulo`. |
| `DetalleSeguro` | `nvarchar(500) NULL` | Sin secretos, contraseñas ni sobre completo. |
| `Actor` | `nvarchar(128) NULL` | Usuario o proceso responsable. |
| `OcurridoUtc` | `datetime2(3)` | Fecha de auditoría. |
| `Origen` | `varchar(16)` | `WEB`, `API`, `HOSTED_SERVICE` o `SOPORTE`. |

La auditoría no se toma como control de licencia. Su función es explicar qué ocurrió y facilitar soporte.

## 8. Flujo transaccional de importación

1. El backend recibe el archivo por un endpoint administrativo.
2. Lee el JWS y verifica firma, algoritmo permitido, `keyId`, producto, versión, `InstalacionId`, huella de clave, serial y fechas.
3. Comprueba el sello protegido de la máquina y rechaza seriales no mayores que el ya aceptado.
4. Inserta el sobre original y su resultado, así como sus módulos derivados.
5. Actualiza en la misma transacción el estado visible y el nuevo sello protegido de máquina.
6. Registra el evento y notifica al servidor para invalidar su caché de menú y capacidades.

Un error revierte los pasos SQL. Si la protección de Windows no puede actualizarse, se rechaza la importación: no debe quedar una licencia aceptada en SQL pero ausente del estado protegido.

## 9. Restricciones de seguridad de datos

- No guardar la clave privada de GE360, claves simétricas compartidas ni contraseñas en ninguna tabla, archivo de configuración o paquete del cliente.
- El usuario de conexión de la aplicación debe tener permisos mínimos sobre el esquema requerido; el uso de `sa` queda fuera del diseño final de despliegue.
- La base de datos no se publica a Internet. El navegador usa API autenticada; nunca acceso SQL directo.
- Las tablas de licencia se modifican por servicios del backend autorizados. La pantalla no recibe permisos para editar registros arbitrarios.
- Los scripts deberán ser repetibles, validar estructura y no alterar licencias históricas ya importadas.

Las pruebas de esquema deben cubrir segunda ejecución, sobre alterado, serial repetido, serial inferior, módulo desconocido, fechas invertidas, instalación distinta, intento de encender un módulo no contratado y reversión de transacción.
