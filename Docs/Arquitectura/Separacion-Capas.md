# Separación de capas — 26/11/2026

## Criterio requerido

API recibe HTTP, valida el contrato y delega en Application. Application contiene los servicios de aplicación y coordina los casos de uso. Business ejecuta las operaciones de negocio y el acceso a persistencia mediante los contratos y repositorios existentes. Infrastructure conserva modelos EF, contexto y adaptadores de persistencia. No deben cruzarse consultas diferidas hasta Application para ejecutarlas allí.

La configuración de dependencias en Program y Extensions constituye la raíz de composición: conocer las implementaciones allí no equivale a ejecutar consultas desde un controlador.

## Cambios aplicados

- UserContextService pasa de API a Application. IUserRequestContext abstrae la identidad y cabeceras; HttpUserRequestContext es únicamente el adaptador HTTP de API. IUserContextQueries y su implementación en Business realizan las comprobaciones de empresa y ejercicio con EF. Se mantienen claims, cabeceras, condiciones de activo y comportamiento ante fallos.
- BitacoraController utiliza IBitacoraAppService. Su servicio de aplicación delega en el servicio de Business existente.
- CatalogLookupAppService delega en ICatalogLookupService de Business. La materialización, ordenamiento, paginación y filtros de las cinco operaciones existentes se ejecutan en Business, manteniendo sus contratos públicos.
- Se retiraron referencias innecesarias a Business e Infrastructure de seis controladores y LookupPagingHelper, sin consumidores encontrados.
- Se agregó regresión de empresa seleccionada permitida/denegada, ejercicio activo/inactivo y fallo de consulta; además se comprueban las dependencias de constructores de todos los controladores.

## Estado pendiente explícito

El inventario completo de fuentes propias de los cuatro proyectos está en [Inventario-Capas.json](Inventario-Capas.json). Es un análisis por patrones, no una revisión manual de cada línea ni un conteo definitivo de infracciones.

Application aún tiene 101 archivos con referencias o señales de persistencia. Hay que distinguir referencias de tipos, herencia de servicios genéricos, consultas EF y SQL ejecutado; separar los últimos sin cambiar validaciones ni transacciones. Incluyen Adquisiciones, Contabilidad, Presupuesto, Patrimonio, Almacén, Nómina, PBR y servicios de plataforma. No se presentan como reorganizados.

En API quedan nueve archivos señalados: raíz de composición, clasificación de excepciones, inicializadores, tres configuradores de reportes y LicensingService. Program y el middleware requieren clasificación; inicialización, consultas de reportes y licenciamiento requieren separar el trabajo de persistencia del adaptador de API. No se hicieron cambios apresurados en las transacciones o sellos de licenciamiento.

## Verificación

Solución completa compilada sin advertencias ni errores; 359 pruebas correctas. Auditoría de calidad sin infracciones y diff sin errores de espacios. Las pruebas usan dobles de servicios y las comprobaciones existentes; no acreditan transacciones SQL reales ni el funcionamiento completo de todos los módulos. No se ejecutaron migraciones ni se hicieron commits, push o respaldos.
