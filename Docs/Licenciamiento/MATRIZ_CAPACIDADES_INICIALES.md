# Matriz inicial de capacidades e integraciones

Fecha: 12 de septiembre de 2026. Estado: base de inventario; todavía no es catálogo ejecutable ni habilita módulos.

Esta matriz convierte los módulos comerciales en operaciones comprobables. El código de capacidad será la referencia común para licencia, menú, endpoint, servicio interno, reporte y proceso. Una ruta, un nombre de pantalla o un prefijo de controlador no decide por sí mismo qué se vende.

`CORE` no es vendible. Es el mínimo para iniciar sesión, administrar permisos, activar la instalación, consultar su licencia y recuperarla. Los módulos vendidos son los ocho definidos en el [plan](PLAN_LICENCIAMIENTO_MODULAR.md).

## Reglas de lectura

- **Módulos requeridos** se evalúan juntos: todos deben estar vigentes.
- **Evidencia** muestra por qué se registró la dependencia; no reemplaza la revisión de todos los endpoints, procedimientos y reportes.
- **Decisión pendiente** bloquea vender la operación como independiente hasta que se defina su comportamiento.
- Una capacidad puede usar una consulta limitada de otro módulo sin abrir sus menús, reportes ni API general.

## Capacidades núcleo

| Código propuesto | Uso | Módulos requeridos | Estado |
|---|---|---|---|
| `CORE.LICENCIA.ACTIVAR` | Registrar el código inicial y la identidad de instalación | Núcleo | Requerida |
| `CORE.LICENCIA.CONSULTAR` | Mostrar módulos, fechas, estado y avisos | Núcleo | Requerida |
| `CORE.LICENCIA.SINCRONIZAR` | Actualizar autorización firmada | Núcleo | Requerida |
| `CORE.SISTEMA.USUARIOS` | Operar usuarios, roles y permisos | Núcleo | Decidir alcance de Administración funcional |
| `CORE.SISTEMA.CONFIGURACION` | Configuración mínima de empresas, sucursales y ejercicio | Núcleo | Inventariar catálogo mínimo |

La administración comercial de módulos vive en el panel central. Ninguna capacidad `CORE` otorga, renueva ni suspende derechos dentro de la instalación del cliente.

## Capacidades comerciales e integraciones detectadas

| Código propuesto | Operación | Módulos requeridos | Evidencia actual | Decisión o trabajo pendiente |
|---|---|---|---|---|
| `GRP.ADQ.REQUISICION.OPERAR` | Crear y actualizar requisiciones en una modalidad sin presupuesto | GRP.ADQ | Pantallas de requisición existen bajo `Pages/Modules/GRP/Adquisiciones` | Confirmar si existe un flujo realmente independiente antes de ofrecerlo |
| `GRP.ADQ.REQUISICION.CON_DISPONIBILIDAD` | Elegir partida y egreso disponible en requisición | GRP.ADQ + GRP.PRES | `RequisicionPartidaDialog.razor` exige disponible y hereda partida/egreso | Mantener ambos módulos o desarrollar modalidad sin disponibilidad |
| `GRP.ADQ.SUFICIENCIA.OPERAR` | Solicitud y autorización de suficiencia | GRP.ADQ + GRP.PRES | `SolicitudSuficienciaAppService.cs` usa `PRES.SP_MantenimientoSolicitudSuficiencia` | Definir propietario funcional y transiciones permitidas |
| `GRP.ALMA.RECEPCION.DESDE_ORDEN` | Recibir pedido desde una orden autorizada | GRP.ALMA + GRP.ADQ | `Recepcion_Pedidos.razor` carga órdenes y detalles autorizados | Definir consulta limitada de orden y qué hacer con recepciones pendientes |
| `GRP.ALMA.SALIDA.SURTIR` | Surtir y entregar una solicitud de salida | GRP.ALMA | `DetalleSolicitudSalidaAppService.cs` gestiona la entrega | Separar las operaciones que no requieren contabilidad de las que sí la requieren |
| `GRP.ALMA.SALIDA.CONTABILIZAR` | Crear póliza al surtir completamente una salida | GRP.ALMA + GRP.CONTA | El servicio ejecuta `ALMA.SP_CREATE_PolizaSalidaAlmacen` dentro de la transacción | Decidir si se vende como integración incluida o requisito de Contabilidad; no omitirla silenciosamente |
| `GRP.PATRI.BIEN.OPERAR` | Alta, inventario y baja de bienes | GRP.PATRI | Servicios y pantallas de Patrimonio | Inventariar catálogos mínimos compartidos |
| `GRP.PATRI.BIEN.DESDE_ORDEN` | Generar bien desde detalle de orden y cerrar recepción | GRP.PATRI + GRP.ADQ | `BienAppService.GenerarDesdeDetalleOrdenCompraAsync` | Definir continuación de pendientes si vence Adquisiciones |
| `GRP.PRES.DISPONIBILIDAD.CONSULTAR` | Consultar saldo disponible usado por otros procesos | GRP.PRES | `EgresoDisponibleResponse` se consume desde Adquisiciones | Crear consulta contextual; no publicar la API general de Presupuesto por esa razón |
| `GRP.PRES.EJECUCION.OPERAR` | Operaciones presupuestales propias | GRP.PRES | Servicios PRES y pantallas de Presupuesto | Inventariar operaciones, exportaciones y reportes |
| `NOM.CALCULAR` | Ejecutar cálculo de nómina | NOM | `NominaProcesoAppService.cs` inicia cálculo mediante procedimientos | Revisar procedimientos y dependencias antes de afirmar autonomía total |
| `NOM.PRESUPUESTO.GENERAR` | Generar comprometido, devengado o ejercido desde nómina | NOM + GRP.PRES | El mismo servicio expone acciones presupuestales separadas | Bloquear la integración, no el cálculo, cuando Presupuesto no esté contratado |
| `PBR.PLANEACION.OPERAR` | Operar anteproyectos, MIR e indicadores | PBR | Controladores y pantallas bajo PBR | Inventariar datos compartidos que necesita |
| `PBR.PRESUPUESTO.CONSULTAR` | Consultar programas y presupuesto por programa para tablero PBR | PBR + GRP.PRES, propuesta | `PbrDashboardAppService.cs` consulta `VwProgramas` y `VwPresupuestoProgramas` | Decidir si la consulta viene incluida con PBR como servicio compartido o exige Presupuesto |

La propuesta no declara todavía capacidades individuales para cada catálogo, reporte o exportación. Primero se definen las unidades de negocio; el inventario posterior las divide solo cuando la venta, una integración o un riesgo operativo lo requiere.

## Inventario que falta completar antes de codificar los filtros

Para cada elemento se registrará una fila con estas columnas:

| Dato | Finalidad |
|---|---|
| Tipo de recurso | Menú, pantalla, endpoint, servicio, procedimiento, reporte, exportación, proceso o documento |
| Clave estable | Nombre de capacidad o identificador técnico que no dependa de la URL visible |
| Módulo propietario | Quién lo vende y mantiene funcionalmente |
| Capacidades exigidas | Operaciones que debe validar antes de ejecutarse |
| Permiso actual | Policy, claim o verificación manual existente |
| Alcance de datos | Empresa, sucursal, año, área u otro contexto |
| Efecto | Consulta, escritura, transición de workflow, integración externa o proceso en segundo plano |
| Dependencias | Módulos, catálogos, SP, documentos y trabajos involucrados |
| Comportamiento al vencer | Bloquear, consulta histórica, terminar unidad ya iniciada o requerir recuperación |
| Evidencia | Ruta, endpoint, SP o tarea verificada |
| Estado | Confirmado, pendiente técnico, pendiente comercial o aprobado |

Se incluirán rutas alternativas y llamados internos. El middleware HTTP no protege una invocación directa de servicio ni un procedimiento disparado desde un proceso; cada uno debe quedar clasificado.

## Orden del inventario

1. Núcleo y Administración funcional.
2. Almacén, Adquisiciones y Contabilidad como piloto de integración real.
3. Patrimonio y sus vínculos con compras.
4. Nómina y sus tres salidas presupuestales.
5. PBR, programas y consultas presupuestales.
6. Reportes, exportaciones, documentos, tareas y procedimientos de todos los módulos.

Una combinación de módulos se aprueba sólo después de que todas sus capacidades dependientes tengan comportamiento definido. El validador podrá rechazar perfiles incoherentes antes de que el operador comercial los guarde.
