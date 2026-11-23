# Decisiones por aprobar antes de construir licencias

> **Estado actualizado:** las decisiones de producto e integraciones siguen siendo útiles. Las decisiones técnicas que hablan de API y base centrales fueron reemplazadas para la primera versión por [ENFOQUE_SIMPLE_LICENCIA_FIRMADA.md](ENFOQUE_SIMPLE_LICENCIA_FIRMADA.md).

Este documento resume las decisiones de negocio que afectan las tablas y el código. Las propuestas marcadas como recomendadas permiten comenzar el primer incremento sin alterar el alcance acordado: instalación completa, venta por módulos y cambios durante la operación.

## Decisiones de producto

| ID | Decisión | Propuesta recomendada | Por qué importa |
|---|---|---|---|
| D1 | Unidad de venta | Ocho módulos: seis GRP, Nómina y PBR | Define los códigos estables de licencia y los paquetes comerciales |
| D2 | Paquetes | “GRP completo” y “Sistema completo” son selecciones de módulos, no módulos nuevos | Evita que un derecho GRP contradiga a sus seis módulos hijos |
| D3 | Administración funcional | Mantener como núcleo acceso, usuarios, roles, permisos, activación, estado de licencia y configuración mínima de empresa/sucursal/ejercicio | El cliente debe poder renovar, recuperar o administrar usuarios aunque ningún módulo comercial esté vigente |
| D4 | Pruebas | Empiezan al activar la instalación; cada módulo agregado después empieza cuando se concede desde el panel | Una reinstalación no reinicia la prueba |
| D5 | Días de prueba | N periodos de 24 horas UTC | Es preciso y consistente entre servidores; no depende de la medianoche local |
| D6 | Gracia comercial | Cero horas por defecto; sólo una extensión registrada la concede | Evita extensiones implícitas por errores de reloj o reintentos |
| D7 | Sin Internet | Sincronizar cada 15 minutos y permitir hasta 72 horas desde la última autorización válida | Mantiene continuidad ante fallos temporales; suspensiones llegan rápido mientras haya conexión |
| D8 | Módulo vencido o suspendido | Mantener consulta histórica y exportación autorizada; bloquear nuevas escrituras e integraciones | Conserva acceso a datos sin permitir nueva operación comercial |
| D9 | Renovación | Reactiva y amplía fechas sin reinstalar ni recapturar | Cumple la operación comercial cotidiana |
| D10 | Pago inicial | Operador comercial registra renovación manual con referencia | Permite arrancar sin integrar pasarela de pagos |

## Decisiones de integraciones entre módulos

| ID | Escenario | Decisión requerida | Recomendación inicial |
|---|---|---|---|
| I1 | Adquisiciones usa disponibilidad presupuestal para requisiciones | ¿Adquisiciones se puede vender sin Presupuesto? | Sí, sólo si se implementa una modalidad independiente; la modalidad actual requiere GRP.ADQ + GRP.PRES |
| I2 | Solicitud de suficiencia vive en Adquisiciones pero ejecuta procesos PRES | ¿Se vende con Adquisiciones o como integración? | Capacidad de integración que exige ambos módulos hasta definir su propietario funcional final |
| I3 | Almacén recibe contra órdenes autorizadas | ¿Almacén sin Adquisiciones puede recibir mercancía? | Sí mediante entrada independiente futura; recepción desde orden exige GRP.ALMA + GRP.ADQ |
| I4 | Salida de Almacén genera póliza | ¿La póliza es parte de Almacén o requiere Contabilidad? | Tratarla como integración GRP.ALMA + GRP.CONTA hasta aprobar una modalidad sin póliza o una contabilización interna incluida |
| I5 | Patrimonio crea bienes desde compras | ¿Patrimonio requiere Adquisiciones? | Patrimonio base puede ser independiente; alta desde orden exige GRP.PATRI + GRP.ADQ |
| I6 | Nómina genera comprometido, devengado y ejercido | ¿Cálculo y presupuesto se venden juntos? | Cálculo NOM independiente; generación presupuestal requiere NOM + GRP.PRES |
| I7 | PBR consume programas y presupuesto | ¿PBR incluye consulta presupuestal? | Definirla como capacidad separada; provisionalmente PBR + GRP.PRES hasta decidir si se entrega como catálogo compartido |

No vender como “independiente” una operación que todavía requiera un módulo no contratado. Primero se define la alternativa funcional y después se habilita comercialmente.

## Decisiones técnicas ya fijadas en el diseño

- La autoridad comercial está en una base y API centrales; cada instalación guarda sólo una autorización firmada verificable.
- La clave privada para firmar queda en custodia central. El cliente recibe claves públicas y nunca puede emitir módulos.
- El rol SuperAdmin conserva permisos funcionales, pero no anula vencimientos, suspensiones ni requisitos comerciales.
- Los menús sólo muestran disponibilidad; el backend vuelve a validar cada operación, reporte, exportación y proceso interno.
- La licencia se vincula a una identidad criptográfica de instalación, no sólo a una IP, un nombre de servidor o un identificador editable.
- Los cambios comerciales son idempotentes y auditables. Reintentar renovar o activar no duplica días ni derechos.

## Orden recomendado para aprobar y empezar

1. Aprobar D1 a D8.
2. Resolver I1 a I4, que son los cruces que impiden el piloto de Almacén.
3. Aprobar el catálogo inicial de capacidades de [MATRIZ_CAPACIDADES_INICIALES.md](MATRIZ_CAPACIDADES_INICIALES.md).
4. Construir el primer incremento: prueba de Almacén de 15 días, activación, menú, control de endpoint, suspensión y renovación.
5. Extender el mismo patrón a los demás dominios.

Los documentos técnicos de respaldo son el [plan de acción](PLAN_LICENCIAMIENTO_MODULAR.md), el [modelo de datos](MODELO_DATOS_LICENCIAMIENTO.md) y el [backlog](BACKLOG_IMPLEMENTACION_LICENCIAS.md).
