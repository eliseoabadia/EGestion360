# Revisión de flujos de EGestion360 — 8 de septiembre de 2026

## Resultado y alcance real

Se revisó el código de los flujos presupuestales, adquisiciones, cuentas por pagar, contabilidad, almacén y resguardo. Se consultó en solo lectura la base local GestionEmpresarial para contrastar el cierre instalado y los triggers de pólizas. Se corrigió una inconsistencia de autorización en la importación de pólizas y se compiló el backend Release: 0 errores y 0 advertencias.

**Las pruebas completas mediante la interfaz no se ejecutaron.** El navegador interno sigue fallando antes de enumerar pestañas. No se crearon documentos operativos, folios ni datos de prueba en esta revisión. Una regla localizada en el código no constituye un caso funcional aprobado.

No se repitió el reindexado, no se generaron scripts de prueba y no se hicieron copias de la base. La consulta a la base local no acredita el estado de la base del servidor público. La corrección está en el código local y aún no está desplegada.

## Hallazgos

### F01 — Importación de pólizas podía omitir autorización — corregido en código

El alta manual fija Autorizado=false. La importación conservaba el valor recibido en el encabezado y lo persistía directamente. Por ello una solicitud de importación con Autorizado=true podía crear una póliza ya autorizada sin recorrer la autorización ordinaria.

Se fijó Autorizado=false tanto en el encabezado de la previsualización como al persistir la póliza importada. La compilación del backend terminó correctamente y la revisión de diferencias confirma únicamente esas dos asignaciones. La importación funcional en pantalla no se ha ejecutado.

Referencia: BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/PolizaService.cs, líneas 220 y 339.

### F02 — Cierre del mes 13 con posibilidad de cambios parciales — sin corregir

El servicio admite el mes 13. El procedimiento SP_SaldoMensual elimina e inserta saldos, desactiva el periodo actual e inserta el siguiente. Después construye el mensaje con DATEFROMPARTS usando el mes actual. El mes 13 no es válido para esa función de calendario.

El procedimiento y su invocación no incluyen una transacción que revierta toda la operación si esa instrucción final falla. La consulta de solo lectura confirmó que los procedimientos instalados CONTA.CierreMensual y CONTA.SP_SaldoMensual no contienen transacción; el segundo contiene DATEFROMPARTS. El riesgo es avanzar el periodo y modificar saldos aunque la pantalla reciba un error. No se ejecutó el cierre para reproducirlo sobre los datos existentes.

Referencias: BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/CierreMensualService.cs; Scripts/01_GestionEmpresarial_Script_Final_BD.sql, líneas 89498–89669.

### F03 — Alcance y condiciones del cierre no coinciden con la información mostrada — sin corregir

La pantalla obtiene estadísticas filtradas por empresa, pero llama a un cierre sin parámetro de empresa. El procedimiento elimina y reconstruye saldos del periodo sin filtro por empresa. La consulta a la base local confirmó que ninguno de esos dos procedimientos contiene referencia a FKIdEmpresa.

Además, el servicio calcula pólizas pendientes y diferencia entre debe y haber, pero no utiliza esos valores para determinar PuedeRealizarCierre. La regla de fecha compara solo el número de mes: permite un mes distinto del actual sin distinguir un periodo futuro. El año resuelto para mostrar el periodo no interviene en esa decisión.

Antes de modificar esta operación se debe definir y hacer coherente su alcance global o por empresa. La reparación también debe verificar el periodo completo y la integridad de las pólizas. La consulta actual encontró junio de 2026 como periodo activo local; no se avanzó.

Referencia: BackEnd/EG.Application/Modules/GRP/Services/Contabilidad/CierreMensualService.cs, métodos BuildEstadoAsync, PuedeCerrarMes y AplicarCierreMensualAsync.

### F04 — Falta de bloqueo de edición y eliminación de pólizas autorizadas — sin corregir

La eliminación de la cabecera desactiva la póliza y sus detalles sin comprobar Autorizado o PermitirModificar. La creación y modificación del detalle comprueban existencia de póliza/cuenta y los importes, pero no esas banderas; su eliminación tampoco las comprueba. El cambio de cabecera utiliza la actualización genérica sin un bloqueo específico de póliza.

Esto permite que una operación ordinaria de edición o eliminación alcance una póliza que debería conservar su autorización y trazabilidad, si el usuario dispone del permiso general de la operación. No se encontró una protección compensatoria mediante triggers en las tablas locales CONTA.Poliza y CONTA.PolizaDetalle. No se alteró una póliza real para reproducir el efecto.

Referencias: PolizaService.cs, DeleteAsync; PolizaDetalleService.cs, CreateAsync, UpdateAsync, DeleteAsync y ValidateReferencesAsync; AdquisicionCrudAppService.cs, UpdateAsync.

## Recorrido revisado y evidencia que falta obtener en pantalla

| Tramo | Regla localizada durante la revisión | Comprobación funcional necesaria |
|---|---|---|
| Ejercicio y empresa | Adecuaciones requieren empresa y ejercicio activos; distintos servicios contrastan el ejercicio de los documentos relacionados. | Seleccionar contexto, crear operación y volver a abrirla; cambiar contexto y verificar aislamiento. |
| Presupuesto modificado | Adecuación compensada exige aumentos y reducciones iguales; ampliación/reducción restringen el tipo de movimiento; envío y autorización requieren póliza balanceada. | Captura, envío, rechazo, reenvío y autorización; comprobar disponible antes y después. |
| Requisición | Las cotizaciones o suficiencias activas bloquean cambios en el origen. | Guardar cabecera y partidas, volver a abrir; intentar cambiar el origen después de cotizar. |
| Cotización y suficiencia | Se requieren bienes con partida y precios; tres proveedores completos, salvo la condición de compra directa prevista. | Registrar cotizaciones, comprobar totales y bloqueo de cotización incompleta. |
| Autorización de suficiencia | Verifica solicitud activa, ejercicio, detalle, duplicados, persona del usuario y disponibilidad presupuestal. | Autorizar y comprobar afectación; intentar duplicado e importe sin disponibilidad. |
| Contrato | Solo se autoriza en borrador, con partidas positivas cuyo total coincide con el contrato. | Generación desde suficiencia, autorización y comprobación de póliza de compromiso. |
| Factura | Contrato autorizado de la empresa y ejercicio; fecha posterior al contrato; UUID no duplicado; detalle con suma coincidente en el alta. | Registrar y autorizar; verificar detalle, total y bloqueo de cambios posteriores. |
| CLC | Contrato y facturas válidos; detalle y facturas deben sumar el total; evita reaplicar partidas de factura activas. | Generación, autorización y conciliación de importes con factura y contrato. |
| Cheque/provisión | Cuenta bancaria de la empresa; CLC completa; partidas y total coincidentes; evita otra provisión activa para la misma CLC. | Captura y autorización de un registro de prueba, sin pago bancario real. |
| Reversa de cheque | Requiere motivo de al menos diez caracteres, empresa coincidente y cheque que haya avanzado a autorización; invoca regreso hasta requisición. | Ejecutar reversa de expediente de prueba y verificar estados, disponible y pólizas inversas; repetir y comprobar ausencia de duplicación. |
| Almacén y salida | Bloqueos de movimientos cerrados/contabilizados; salidas autorizadas no editables; comprueba ejercicio, áreas y existencia en ajustes. | Recepción, suministro, existencias y rechazo de salida que exceda lo disponible. |
| Resguardo | Exige persona y área responsable. | Asignación de bienes, reapertura del documento y conciliación con almacén. |
| Pólizas | Valida debe/haber por detalle y recalcula balance. Se detectaron F01 y F04. | Alta, detalle, balance, autorización, edición prohibida y trazabilidad con el documento origen. |
| Cierre | Se detectaron F02 y F03. | Verificación funcional posterior a corregir transacción, mes 13, alcance y condiciones de cierre. |

## Estado de aceptación

No se emite aprobación integral ni liberación basada en esta revisión. La evidencia de agosto y las pruebas unitarias anteriores no se presentan como una nueva ejecución. El resultado entregado ahora es una corrección compilada y un diagnóstico del flujo con referencias concretas; siguen faltando operaciones reales verificadas en pantalla.
