/*
EXUX | Universidad Maya | Propuesta de reestructura SQL Server 2022
00 / Instrucciones y prevalidación de solo lectura
Generado a partir de metadatos: EmptyProjects (26 tablas) y GestionEmpresarial (309 tablas).
SOLO ARCHIVO GENERADO. NO APLICADO. SIN DATOS, SIN USUARIOS, SIN CREDENCIALES.
DESTINO Y ALCANCE
- Base destino de referencia: EmptyProjects existente, conservando su seguridad y organización.
- Complemento de estructura obtenido de GestionEmpresarial; no se conecta a esa base al ejecutar estos archivos.
- No se crea otra base, no se copian filas, no se asignan usuarios, no se cargan credenciales ni contraseñas.
- El proyecto anterior necesita adaptar sus modelos y servicios: esto es una REESTRUCTURA, no una migración compatible del código actual.
- No se crean ni amplían tablas RH. EmptyProjects ya contiene NOM.Persona y NOM.PersonaArea: permanecen intactas
  para conservar seguridad heredada. Las NUEVAS referencias de negocio apuntan a SIS.ResponsableOperativo.
- No se importan funciones, vistas, triggers ni procedimientos heredados de GestionEmpresarial.
  Sus automatismos quedarían sujetos a la arquitectura nueva; solo se incluyen los controles explícitos de FASE C.
- Las 128 entidades del ERD están trazadas en 98_Trazabilidad_ERD.sql. 'Baja' se materializa como ALMA.Bajas.

ORDEN MANUAL (estos comentarios NO ejecutan otros archivos)
1. Revisar 00_Leer_Primero.sql; su parte ejecutable solo consulta metadatos.
2. FASE A: ejecutar 01_Estructura.sql de las carpetas 01 a 15, en orden numérico.
3. FASE B: ejecutar 02_Relaciones.sql de las carpetas 01 a 15; antes deben existir TODAS las estructuras.
4. FASE C: ejecutar 02_Polizas_Contabilidad/03_Controles.sql y 04_Almacen/03_Controles.sql.
5. Ejecutar 99_Verificar_Estructura.sql. Es comprobación de metadatos; no prueba funcional ni carga de datos.
Los módulos son archivos separados, pero NO todos son instalables aisladamente: las cabeceras enumeran dependencias.
Las relaciones se dejan para FASE B porque existen ciclos funcionales entre compras, almacén, presupuesto y contabilidad.
Cada archivo tiene transacción y revierte su propio trabajo si falla; la totalidad del paquete NO es una sola transacción.

REESTRUCTURA MULTI ALMACÉN
- ALMA.Almacen conserva el significado de entrada histórica, NO se usa como catálogo de almacenes físicos.
- ALMA.AlmacenCatalogo distingue almacenes FISICO y TRANSITO por empresa y sucursal.
- ProductoAlmacen, UbicacionAlmacen, Lote y PartidaStock separan producto, ubicación, lote y condición.
- Las claves compuestas validan empresa, almacén y producto entre las entidades relacionadas.
- PlanConteoCiclico deja la unicidad global por tipo de bien y la cambia a producto por almacén.
- CierreInventario se identifica por partida, ejercicio y mes. No se suma al libro de movimientos.
- La existencia de vExistenciasPorAlmacen sale SOLO de movimientos aplicados; reserva activa reduce disponible.
- El traslado normal ocurre dentro de una empresa. Operaciones entre empresas requieren otro flujo financiero.
- Crear primero todas las partidas en BORRADOR y después aplicar la cabecera. Los aplicados son inmutables.
- No se infiere ubicación para saldos antiguos. La carga de apertura exige clasificación y conciliación previas.

PRECISIONES Y MONEDA
- Se conserva la precisión de GestionEmpresarial: dmoney se expresa como decimal(20,4), sin alias dependiente.
- Presupuesto proyectado/autorizado y reservas nuevas usan decimal(18,2), coherente con sus meses existentes.
- Stock y conteos nuevos usan decimal(20,4); OrdenCompraDetalle mantiene decimal(18,4) para cantidad.
- Tasas/porcentajes son parámetros con 6 decimales; no se siembran valores fiscales ni reglas de redondeo.
- La nueva IdMoneda de CuentaBancaria necesita correspondencia aprobada con el catálogo anterior TipoMoneda.
- Pago y compromiso de una aplicación deben tener la misma moneda. No se implementa conversión implícita.

LO QUE REQUIERE LÓGICA DE NEGOCIO POSTERIOR (NO AFIRMAR OPERACIÓN COMPLETA POR TENER TABLAS)
- Reservar/consumir stock y aplicar movimientos con bloqueo transaccional por partida, evitando saldo negativo.
- Validar cantidades acumuladas pedidas, enviadas, recibidas y facturadas; impedir sobre-recepción y sobre-facturación.
- En transferencias, validar almacén TRANSITO, rutas de salida/recepción y cantidades pendientes antes de aplicar.
- Evitar sobrepago y sobreaplicación de notas; validar mismo beneficiario y documentos admitidos.
- Sumar comprobaciones de caja y viáticos bajo bloqueo del comprobante para impedir doble aplicación entre módulos.
- Autorizar presupuesto con disponibilidad real, conciliando reservas y afectaciones existentes sin duplicar descuentos.
- Aplicar segregación de funciones, decisiones de workflow y autorización por almacén desde la API.
- Integrar SAT/PAC, bancos, OCR y notificaciones sin almacenar secretos directamente en estas tablas.
- Cargar catálogos funcionales, tipos, estados, moneda y reglas aprobadas antes de iniciar operaciones.
- Validar concurrencia, reversas, reintentos y migración en ambiente de prueba cuando se autorice ejecutar.

REPETICIÓN Y RECUPERACIÓN
- La estructura existente se verifica por columnas, tipo, longitud, precisión, nulabilidad y claves.
- Si existe una definición incompatible el archivo falla; no borra ni convierte tablas automáticamente.
- Un archivo fallido revierte su propia transacción. No se suministra DROP masivo como supuesto rollback.
- Para deshacer todo tras cargar datos se requiere recuperación de respaldo o migración inversa revisada.
- Para otra copia de EmptyProjects, cambiar @BaseDestino en cada archivo tras revisar el destino.

CONTENIDO: 15 módulos; 169 tablas tomadas de GestionEmpresarial; 90 tablas nuevas ERD; 917 relaciones verificables.
01 Base_Organizacion: 15 entidades propias/reutilizadas.
02 Polizas_Contabilidad: 15 entidades propias/reutilizadas.
03 Presupuesto: 46 entidades propias/reutilizadas.
04 Almacen: 32 entidades propias/reutilizadas.
05 Patrimonio: 22 entidades propias/reutilizadas.
06 Compras_Proveedores: 47 entidades propias/reutilizadas.
07 Cuentas_por_Pagar: 11 entidades propias/reutilizadas.
08 Bancos_Tesoreria: 16 entidades propias/reutilizadas.
09 Caja_Chica: 8 entidades propias/reutilizadas.
10 Viaticos: 4 entidades propias/reutilizadas.
11 Cumplimiento: 4 entidades propias/reutilizadas.
12 Fiscal: 15 entidades propias/reutilizadas.
13 Workflow_Notificaciones: 15 entidades propias/reutilizadas.
14 Documentos: 8 entidades propias/reutilizadas.
15 Control_Auditoria: 4 entidades propias/reutilizadas.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
DECLARE @BaseDestino sysname = N'EmptyProjects';
IF DB_NAME() <> @BaseDestino THROW 51000, N'Base incorrecta. Seleccione EmptyProjects o edite @BaseDestino para una copia autorizada.', 1;
IF DB_NAME() IN (N'GestionEmpresarial',N'master',N'model',N'msdb',N'tempdb') THROW 51000, N'Destino protegido: este paquete no se aplica en la base origen.', 1;
IF @@TRANCOUNT <> 0 THROW 51000, N'Ejecute cada archivo fuera de una transacción previa.', 1;
IF TRY_CONVERT(int,SERVERPROPERTY('ProductMajorVersion')) < 16 THROW 51000,N'Este paquete está preparado para SQL Server 2022 o posterior.',1;
IF (SELECT compatibility_level FROM sys.databases WHERE name=DB_NAME()) < 130 THROW 51000,N'OPENJSON requiere compatibilidad 130 o superior.',1;
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PKIdEmpresa","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Nombre","type":"nvarchar","length":512,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"RFC","type":"nvarchar","length":52,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"RazonSocial","type":"nvarchar","length":1020,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Giro","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FKIdMonedaBase_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdIdiomaPreferido_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Logo","type":"nvarchar","length":4096,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaCreacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioCreacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FechaModificacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioModificacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"RegIMSS","type":"nvarchar","length":100,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"RegInfonavit","type":"nvarchar","length":100,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CedEmpadronam","type":"nvarchar","length":100,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"NoFonacot","type":"nvarchar","length":100,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"UsAdmin","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"EmailAdmin","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FKIdPeriodoPago_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"PrimaRiesgoIMSS","type":"decimal","length":9,"precision":18,"scale":4,"nullable":1,"identity":0,"computed":0},{"name":"UsaSueldoTabular","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdTipoPago_NOM","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"LogoEmpresa","type":"varbinary","length":-1,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"NombreCorto","type":"nvarchar","length":256,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.Empresa',N'U')
) THROW 51001,N'Estructura incompatible: SIS.Empresa. No se modifica ni sustituye automáticamente.',1;
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PKIdSucursal","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"FKIdEmpresa_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdEstado_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Nombre","type":"nvarchar","length":512,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CodigoSucursal","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Alias","type":"nvarchar","length":200,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FKIdTipoSucursal","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdMonedaLocal_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Direccion","type":"nvarchar","length":1024,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Colonia","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Ciudad","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"CodigoPostal","type":"nvarchar","length":40,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"TelefonoPrincipal","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"TelefonoSecundario","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"Email","type":"nvarchar","length":400,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"HorarioApertura","type":"time","length":5,"precision":16,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"HorarioCierre","type":"time","length":5,"precision":16,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"EsMatriz","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"EsActiva","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Latitud","type":"decimal","length":5,"precision":9,"scale":6,"nullable":1,"identity":0,"computed":0},{"name":"Longitud","type":"decimal","length":5,"precision":9,"scale":6,"nullable":1,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaCreacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioCreacion","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaModificacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioModificacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.Sucursal',N'U')
) THROW 51001,N'Estructura incompatible: SIS.Sucursal. No se modifica ni sustituye automáticamente.',1;
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PkIdUsuario","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"FKIdEmpresa_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FKIdPersona_NOM","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"AspNetUserId","type":"nvarchar","length":900,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"PayrollID","type":"nvarchar","length":80,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FKIdIdiomaPreferido_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FKIdMonedaPreferida_SIS","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"EsAdministrador","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"FechaCreacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioCreacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0},{"name":"FechaModificacion","type":"datetime2","length":8,"precision":27,"scale":7,"nullable":1,"identity":0,"computed":0},{"name":"UsuarioModificacion","type":"int","length":4,"precision":10,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.Usuario',N'U')
) THROW 51001,N'Estructura incompatible: SIS.Usuario. No se modifica ni sustituye automáticamente.',1;
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"Id","type":"nvarchar","length":512,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Name","type":"nvarchar","length":1024,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Code","type":"nvarchar","length":40,"precision":0,"scale":0,"nullable":1,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'dbo.AspNetRoles',N'U')
) THROW 51001,N'Estructura incompatible: dbo.AspNetRoles. No se modifica ni sustituye automáticamente.',1;
IF EXISTS (
 SELECT [name],[type],[length],[precision],[scale],[nullable],[identity],[computed]
 FROM OPENJSON(N'[{"name":"PKIdMoneda","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":1,"computed":0},{"name":"Nombre","type":"nvarchar","length":200,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"CodigoISO4217","type":"char","length":3,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Simbolo","type":"nvarchar","length":20,"precision":0,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Decimales","type":"int","length":4,"precision":10,"scale":0,"nullable":0,"identity":0,"computed":0},{"name":"Activo","type":"bit","length":1,"precision":1,"scale":0,"nullable":0,"identity":0,"computed":0}]') WITH ([name] sysname, [type] sysname, [length] int, [precision] int, [scale] int, [nullable] int, [identity] int, [computed] int)
 EXCEPT
 SELECT c.name,TYPE_NAME(c.system_type_id),c.max_length,c.precision,c.scale,CONVERT(int,c.is_nullable),CONVERT(int,c.is_identity),CONVERT(int,c.is_computed)
 FROM sys.columns c WHERE c.object_id=OBJECT_ID(N'SIS.Moneda',N'U')
) THROW 51001,N'Estructura incompatible: SIS.Moneda. No se modifica ni sustituye automáticamente.',1;
SELECT DB_NAME() AS BaseSeleccionada,N'Prevalidación de esquema base; ningún cambio ejecutado por este archivo' AS Resultado;

/* VALIDACIÓN REALIZADA SIN APLICAR
35 archivos SQL y 2,277 sentencias DDL internas analizadas con Microsoft SQL Server ScriptDom (TSql160): 0 errores.
Modelo completo resuelto con Microsoft SQL Server DacFx (Sql160): 0 incidencias.
Comprobado el cierre de referencias, los tipos de claves y la trazabilidad de las 128 entidades ERD.
No se ejecutaron estos scripts, cargas de datos ni pruebas de transacciones en ninguna base.
Las pruebas operativas, segunda ejecución sobre servidor y concurrencia siguen pendientes de una autorización posterior.
*/
