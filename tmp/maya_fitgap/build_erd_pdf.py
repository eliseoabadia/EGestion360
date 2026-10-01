from pathlib import Path
from math import hypot
import json,re
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor,white
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph
from reportlab.lib.styles import ParagraphStyle
from xml.sax.saxutils import escape

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'output/pdf/universidad-maya';OUT.mkdir(parents=True,exist_ok=True)
FILE=OUT/'03_ERD_Plan_Base_Datos_EXUX_Universidad_Maya.pdf'
LOGO='C:/Users/Eliseo/Downloads/PHOTO-2026-09-17-18-05-35.jpg'
pdfmetrics.registerFont(TTFont('A','C:/Windows/Fonts/arial.ttf'))
pdfmetrics.registerFont(TTFont('B','C:/Windows/Fonts/arialbd.ttf'))
W,H=1190.55,841.89
INK=HexColor('#163044');BLUE=HexColor('#006CA6');GRAY=HexColor('#546977')
COL={'N':('#006CA6','#EEF7FC'),'M':('#946119','#FFF6E3'),'E':('#526D76','#F1F5F6')}
EX=set('Sucursal Usuario Proveedor ResguardoDetalle WorkflowEstado'.split())
MOD=set('Empresa TipoBien SolicitudSalida DetalleSolicitudSalida PeriodoConteo Conteo ConteoDetalle PlanConteoCiclico CierreInventario Bien Resguardo ResguardoMovimiento Baja ConteoDetalleEscaneo InventarioDetalle Requisicion RequisicionDetalle CotizacionDetalle OrdenCompra OrdenCompraDetalle FacturaDetalle EgresoProyectado EgresoAutorizado EgreAdecuacionDetalle Factura CuentaBancaria Cheque Poliza Documento EnvioWorkflow WorkflowTemplate WorkflowTransicion AuditoriaCambio Notificacion NotificacionRegla'.split())
FIELDS={}
def f(n,s):FIELDS[n]=s.split('|')
for n,s in {
'Corporativo':'PK IdCorporativo|Nombre',
'Empresa':'PK Empresa existente|FK Corporativo propuesto',
'Sucursal':'PK Sucursal existente|FK Empresa / campus',
'AlmacenCatalogo':'PK IdAlmacen / FK Empresa|FK Sucursal / código / tipo',
'UsuarioAlmacen':'FK Usuario / Almacen|UK Usuario + Almacen / perfil',
'Usuario':'PK Usuario existente|Identidad y acceso',
'TipoBien':'PK TipoBien existente|Catálogo de producto / unidad',
'ProductoAlmacen':'PK IdProductoAlmacen|FK Almacen / TipoBien|Mínimo / máximo / reposición',
'UbicacionAlmacen':'PK IdUbicacion / FK Almacen|Zona / pasillo / anaquel',
'Lote':'PK IdLote / FK Empresa / TipoBien|Número / caducidad',
'PartidaStock':'PK IdPartidaStock|FK ProductoAlmacen / Ubicacion|FK Lote opcional / condición',
'MovimientoInventario':'PK IdMovimiento / FK Empresa|Tipo / fecha / estado|UK ClaveOperacion / FK Reversa',
'MovimientoInventarioDetalle':'PK IdDetalle / FK Movimiento|FK PartidaStock / origen|Cantidad firmada / valoración',
'SolicitudSalida':'PK Solicitud existente|FK Almacen que surte|Estado / autorización',
'DetalleSolicitudSalida':'PK Detalle / FK Solicitud|FK TipoBien / cantidades',
'ReservaStock':'PK IdReserva / FK PartidaStock|FK DetalleSolicitudSalida|Cantidad / vencimiento / estado',
'Transferencia':'PK IdTransferencia / FK Empresa|FK AlmacenOrigen / Destino|Folio / estado',
'TransferenciaDetalle':'PK IdDetalle / FK Transferencia|FK TipoBien / cantidad solicitada',
'PeriodoConteo':'PK Periodo existente|FK Almacen propuesto|Sucursal / periodo / estado',
'Conteo':'PK Conteo / FK Periodo|FK PartidaStock propuesta|Cantidad teórica al corte',
'ConteoDetalle':'PK Detalle / FK Conteo|FK ResponsableOperativo|Cantidad / fecha',
'PlanConteoCiclico':'PK Plan existente|FK ProductoAlmacen propuesto|Frecuencia / ABC / umbral',
'CierreInventario':'PK Cierre existente|FK PartidaStock propuesta|Periodo / saldo / valoración',
'Bien':'PK Bien existente / FK Empresa|Ubicación estructurada|Serie / valor / estado',
'HistorialUbicacionBien':'PK IdHistorial / FK Bien|FK Ubicacion según destino|Vigencia / operación origen',
'UbicacionPatrimonial':'PK IdUbicacion / FK Sucursal|Edificio / aula / oficina',
'IdentificadorBien':'PK IdIdentificador / FK Bien|QR / barras / RFID|Código único / vigencia',
'ResponsableOperativo':'PK IdResponsable / FK Empresa|FK Usuario opcional|Nombre / contacto / activo',
'Resguardo':'PK Resguardo / FK Empresa|FK ResponsableOperativo|Folio / fecha',
'ResguardoDetalle':'PK Detalle / FK Resguardo / Bien|Asignación / liberación',
'ResguardoMovimiento':'PK Movimiento / FK Bien|FK ResguardoOrigen / Destino|Tipo / fecha / observaciones',
'ConteoDetalleEscaneo':'PK Escaneo / FK Conteo|FK ResponsableOperativo|Código / bien / fecha',
'InmuebleDetalle':'PK y FK IdBien|Catastro / superficie / domicilio',
'PoliticaDepreciacionVersion':'PK IdPoliticaVersion|Método / vida útil / residual|Vigencia / versión aprobada',
'DepreciacionBienPeriodo':'PK IdCalculo / FK Bien|FK PoliticaVersion / Poliza|Periodo / base / importe',
'Baja':'PK Baja / FK Bien|Estado / motivo / autorización',
'Poliza':'PK Poliza existente|Origen y reversa verificables',
'CentroCosto':'PK IdCentroCosto|FK Empresa / Sucursal|Código / vigencia',
'EvaluacionOferta':'PK IdEvaluacion|FK CotizacionDetalle / Criterio|Puntuación / evidencia',
'CriterioEvaluacion':'PK IdCriterio|Peso / versión / vigencia',
'DestinoOrdenCompra':'PK IdDestino / FK OrdenDetalle|FK Almacen o CentroCosto|Cantidad asignada',
'Recepcion':'PK IdRecepcion / FK Empresa|Folio / fecha / responsable|Estado / operación',
'RecepcionDetalle':'PK IdDetalle / FK Recepcion|FK DestinoOrdenCompra|Cantidad aceptada / tipo',
'FacturaRecepcion':'FK FacturaDetalle|FK RecepcionDetalle|Cantidad / importe conciliado',
'PresupuestoVersion':'PK IdVersion / FK Empresa|Ejercicio / versión / estado',
'ReservaPresupuestal':'PK IdReserva / FK Egreso|FK OperacionNegocio|Importe / estado / liberación',
'ProveedorEmpresa':'PK IdProveedorEmpresa|FK Empresa / Proveedor|Condiciones / estatus',
'CuentaProveedor':'PK IdCuenta / FK ProveedorEmpresa|Banco / CLABE / titular|Estado de validación',
'EvaluacionFiscalProveedor':'PK IdEvaluacion / FK ProveedorEmpresa|RFC / opinión / 69 B|Fecha / resultado / evidencia',
'CompromisoPago':'PK IdCompromiso / FK Empresa|Origen / beneficiario / moneda|Importe / vencimiento / estado',
'NotaCredito':'PK IdNota / FK Empresa|Proveedor / CFDI / importe',
'AplicacionNotaCredito':'FK NotaCredito / Factura|Importe aplicado / reversa',
'ProgramacionPago':'PK IdProgramacion / FK Compromiso|Fecha prevista / prioridad|Versión / motivo del cambio',
'Pago':'PK IdPago / FK Empresa|FK Cuenta / beneficiario|Importe / moneda / clave única',
'AplicacionPago':'FK Pago / CompromisoPago|Importe aplicado / moneda|Reversa / fecha',
'EventoCheque':'PK IdEvento / FK Cheque|Entrega / cancelación / acuse',
'PagoPoliza':'FK Pago / Poliza|Tipo de afectación / reversa',
'LoteDispersion':'PK IdLote / FK Empresa|Estado / fecha / total de control',
'OperacionBancaria':'PK IdOperacion / FK Pago|FK LoteDispersion opcional|Clave única / estado / acuse',
'IntentoEnvioBancario':'PK IdIntento / FK Operacion|Fecha / respuesta / referencia',
'ConexionBancaria':'PK IdConexion / FK Cuenta|Banco / convenio / ambiente|Referencia segura de credenciales',
'MovimientoBancario':'PK IdMovimiento / FK Cuenta|Referencia externa única|Fecha valor / importe / moneda',
'ConciliacionDetalle':'FK MovimientoBancario / Pago|Importe conciliado / estado',
'PrevisionTesoreria':'PK IdPrevision / FK Empresa|Fecha / moneda / escenario|Entrada o salida / importe',
'FondoCaja':'PK IdFondo / FK Empresa|FK Responsable / CentroCosto|Monto autorizado / moneda',
'ValeCaja':'PK IdVale / FK Fondo|Importe / fecha / estado',
'MovimientoFondo':'PK IdMovimiento / FK Fondo|Origen / tipo / importe|Fecha / reversa',
'ArqueoCaja':'PK IdArqueo / FK Fondo|Saldo teórico / físico / diferencia',
'ArqueoDetalle':'PK IdDetalle / FK Arqueo|Denominación / cantidad / importe',
'ComprobacionCaja':'PK IdAplicacion / FK Vale|FK ComprobanteGasto|Importe aceptado / estado',
'ComprobanteGasto':'PK IdComprobante|FK Documento / CFDI opcional|Fecha / total / importe aplicado',
'ReposicionCaja':'PK IdReposicion / FK Fondo|Estado / importe / autorización',
'ReposicionDetalle':'FK Reposicion / ComprobacionCaja|Importe / control de duplicidad',
'SolicitudViatico':'PK IdSolicitud / FK Empresa|FK Responsable / CentroCosto|Comisión / fechas / estado',
'AnticipoViatico':'PK IdAnticipo / FK Solicitud|Importe / moneda / estado',
'ComprobacionViatico':'PK IdAplicacion / FK Solicitud|FK ComprobanteGasto|Importe aceptado / estado',
'ReintegroViatico':'PK IdReintegro / FK Solicitud|FK MovimientoBancario opcional|Importe / fecha / evidencia',
'CatalogoObligacion':'PK IdObligacion|Tipo / jurisdicción / periodicidad',
'ObligacionEmpresa':'PK IdAsignacion / FK Empresa|FK Catalogo / Responsable|FK Sucursal opcional / vigencia',
'VencimientoObligacion':'PK IdVencimiento / FK Asignacion|Periodo / fecha límite / estado',
'EvidenciaCumplimiento':'FK Vencimiento / Documento|Fecha / validación / responsable',
'Cfdi':'PK IdCfdi / FK Empresa|UUID normalizado / tipo|Emisor / receptor / total / estado',
'CfdiConcepto':'PK IdConcepto / FK Cfdi|Producto / cantidad / importe',
'CfdiImpuesto':'PK IdImpuesto / FK Concepto|Base / tasa / tipo / importe',
'ValidacionCfdi':'PK IdValidacion / FK Cfdi|Fecha / fuente / resultado',
'EventoCfdi':'PK IdEvento / FK Cfdi|Obtención / cancelación / acuse',
'Declaracion':'PK IdDeclaracion / FK Vencimiento|Tipo / periodo / estado',
'DeclaracionVersion':'PK IdVersion / FK Declaracion|Versión / complementaria|Acuse / fecha / validación',
'DeterminacionImpuesto':'PK IdCalculo / FK Version|FK ReglaFiscalVersion|Base / impuesto / resultado',
'ReglaFiscalVersion':'PK IdReglaVersion|Impuesto / parámetros / fuente|Vigencia / aprobación',
'ActualizacionRecargo':'PK IdCalculo / FK Determinacion|Periodo / parámetros / importes',
'DeclaracionCfdi':'FK DeclaracionVersion / Cfdi|Importe / criterio de inclusión',
'AuditoriaFiscal':'PK IdAuditoria / FK Empresa|Autoridad / periodo / expediente',
'ObservacionFiscal':'PK IdObservacion / FK Auditoria|Vencimiento / atención / evidencia',
'SancionFiscal':'PK IdSancion / FK Observacion|Concepto / importe / vencimiento',
'OperacionNegocio':'PK IdOperacion / FK Empresa|Proceso / folio / fecha|FK única desde cada cabecera',
'ReglaAutorizacion':'PK IdRegla / FK Template|Monto / empresa / campus / rol|Nivel / versión / vigencia',
'DecisionAutorizacion':'PK IdDecision / FK Envio|FK Regla / Usuario|Decisión / fecha / motivo',
'PoliticaSLA':'PK IdPolitica / FK Template|FK CalendarioAtencion|Etapa / plazo / escalamiento',
'CalendarioAtencion':'PK IdCalendario|Horario / días hábiles / zona',
'PlazoOperacion':'PK IdPlazo / FK Envio|FK PoliticaSLA|Inicio / límite / pausas / cierre',
'OperacionDocumento':'FK Operacion / Documento|Rol / vigencia / clasificación',
'ExtraccionDocumento':'PK IdExtraccion / FK Documento|Motor / versión / revisión',
'CampoExtraido':'PK IdCampo / FK Extraccion|Nombre / valor / confianza|Corrección / validación humana',
'EventoPendiente':'PK IdEvento / FK Operacion|Tipo / fecha prevista / estado|Clave única / reintentos',
'ReglaRiesgo':'PK IdRegla / FK Empresa|Escenario / umbral / vigencia',
'CasoRiesgo':'PK IdCaso / FK Regla / Operacion|Evidencia / seguimiento / cierre',
'ReglaSegregacion':'PK IdRegla / FK Empresa|Acciones o roles incompatibles',
}.items():f(n,s)

P=[]
def prose(title,lead,items):P.append(dict(kind='text',title=title,lead=lead,items=items))
def graph(title,codes,node_string,edge_string,note):
    nodes={x.split(':')[0]:int(x.split(':')[1]) for x in node_string.split()}
    edges=[]
    for line in edge_string.split(';'):
        a,b,*cards=line.strip().split('>');edges.append((a,b,cards[0] if cards else '1 : 0..N'))
    assert all(a in nodes and b in nodes for a,b,c in edges)
    P.append(dict(kind='graph',title=title,codes=codes,nodes=nodes,edges=edges,note=note))

prose('Preparación para operar multi almacén','La base actual permite trabajar por empresa y contiene sucursales. La separación completa por almacén requiere cambios.',[
('Lo que existe','ALMA.Almacen registra entradas y existencias, pero no identifica un almacén físico. El cálculo revisado agrupa por empresa, ejercicio y tipo de bien.'),
('La limitación concreta','PlanConteoCiclico permite un único plan por tipo de bien. Se necesita un plan independiente para el mismo producto en cada almacén.'),
('La ampliación propuesta','Separar almacén físico, ubicación, producto por almacén, partida de stock, movimientos, reservas y mercancía en tránsito.'),
('Alcance de este documento','Incluye todo el FIT & GAP sin RH. Es un plan de estructura lógica: no se modificó código ni base de datos y no se verificó una base desplegada.')])
prose('Cómo leer el modelo','Cada entidad repetida en distintas páginas representa la misma tabla. El diagrama muestra las relaciones principales y los campos clave.',[
('N  Nueva','Tabla propuesta para cubrir una necesidad. Los nombres son preliminares; el diseño físico definirá tipos, índices y restricciones.'),
('M  Modificar y E  Reutilizar','M conserva la tabla y adapta relaciones o reglas. E reutiliza la entidad existente. Los campos propuestos no implican que ya existan en la BD.'),
('Relaciones numeradas','Cada línea tiene un número y su relación se identifica debajo. Se lee de izquierda a derecha en la leyenda: entidad origen, entidad destino y cardinalidad.'),
('Claves y cardinalidad','PK identifica el registro; FK enlaza otra tabla; UK indica unicidad. 1 = uno; 0..1 = opcional; 0..N = cero o varios; 1..N = uno o varios.')])

graph('Organización y acceso por almacén','CAT01 a CAT06 · NFR02','Corporativo:0 Empresa:1 Sucursal:2 Usuario:3 UsuarioAlmacen:4 AlmacenCatalogo:5','Corporativo>Empresa;Empresa>Sucursal;Sucursal>AlmacenCatalogo;AlmacenCatalogo>UsuarioAlmacen;Usuario>UsuarioAlmacen','Una empresa puede tener varios campus; cada campus, varios almacenes. El acceso por almacén complementa los permisos por sucursal y acción.')
graph('Producto ubicación y lote','PAT01 a PAT04 · COM11','TipoBien:0 ProductoAlmacen:1 AlmacenCatalogo:2 Lote:3 PartidaStock:4 UbicacionAlmacen:5','TipoBien>ProductoAlmacen;AlmacenCatalogo>ProductoAlmacen;AlmacenCatalogo>UbicacionAlmacen;ProductoAlmacen>PartidaStock;UbicacionAlmacen>PartidaStock;TipoBien>Lote;Lote>PartidaStock>0..1 : 0..N','Existencia = movimientos aplicados. Disponible = existencia menos reservas activas. La partida identifica producto, ubicación, lote opcional y condición del stock.')
graph('Movimientos y reservas de inventario','COM11 · PAT01 · PRE03','Empresa:0 MovimientoInventario:1 MovimientoInventarioDetalle:2 SolicitudSalida:3 DetalleSolicitudSalida:4 PartidaStock:5 ReservaStock:7','Empresa>MovimientoInventario;MovimientoInventario>MovimientoInventarioDetalle>1 : 1..N;PartidaStock>MovimientoInventarioDetalle;SolicitudSalida>DetalleSolicitudSalida>1 : 1..N;DetalleSolicitudSalida>ReservaStock;PartidaStock>ReservaStock;DetalleSolicitudSalida>MovimientoInventarioDetalle>0..1 : 0..N','Los movimientos aplicados se corrigen por reversa. Reserva, disponibilidad y salida deben validarse y afectarse en una misma transacción, con control de concurrencia.')
graph('Transferencias y mercancía en tránsito','PAT10 · CAT02','AlmacenCatalogo:0 Transferencia:1 TransferenciaDetalle:2 PartidaStock:3 MovimientoInventarioDetalle:5','AlmacenCatalogo>Transferencia;Transferencia>TransferenciaDetalle>1 : 1..N;TransferenciaDetalle>MovimientoInventarioDetalle>0..1 : 0..N;PartidaStock>MovimientoInventarioDetalle','Transferencia tiene dos FK a AlmacenCatalogo: origen y destino. Un almacén lógico de tránsito conserva lo pendiente de recibir. Se admiten envíos y recepciones parciales.')
graph('Conteos y cierres por almacén','PAT02 · PAT08 · NFR04','AlmacenCatalogo:0 PeriodoConteo:1 Conteo:2 ProductoAlmacen:3 PlanConteoCiclico:4 PartidaStock:5 CierreInventario:6 ConteoDetalle:8','AlmacenCatalogo>PeriodoConteo;PeriodoConteo>Conteo;PartidaStock>Conteo;ProductoAlmacen>PlanConteoCiclico>1 : 0..1;ProductoAlmacen>PartidaStock;PartidaStock>CierreInventario;Conteo>ConteoDetalle','Un cierre es una fotografía del saldo; no se suma como entrada. El ajuste aprobado del conteo se vincula con el detalle de movimiento que lo aplica.')
graph('Ubicación e identificación patrimonial','PAT01 · PAT03 · PAT04 · PAT06 · PAT08','Sucursal:0 UbicacionPatrimonial:1 Bien:3 HistorialUbicacionBien:4 UbicacionAlmacen:5 IdentificadorBien:6','Sucursal>UbicacionPatrimonial;Bien>HistorialUbicacionBien;UbicacionPatrimonial>HistorialUbicacionBien>0..1 : 0..N;UbicacionAlmacen>HistorialUbicacionBien>0..1 : 0..N;Bien>IdentificadorBien','Un bien en aula u oficina no debe pertenecer obligatoriamente a un almacén. Cada ubicación del historial usa un destino patrimonial o de almacén, nunca ambos.')
graph('Custodia y responsables sin RH','PAT05 · PAT09 · PAT10','Usuario:0 ResponsableOperativo:1 Resguardo:2 ConteoDetalle:3 ConteoDetalleEscaneo:4 ResguardoDetalle:5 ResguardoMovimiento:7 Bien:8','Usuario>ResponsableOperativo>0..1 : 0..1;ResponsableOperativo>Resguardo;ResponsableOperativo>ConteoDetalle;ResponsableOperativo>ConteoDetalleEscaneo;Resguardo>ResguardoDetalle;Bien>ResguardoDetalle;Bien>ResguardoMovimiento','ResponsableOperativo conserva identificación y contacto. Las referencias necesarias a Persona de nómina se migran sin incorporar operación de RH. El resguardo activo del bien debe ser único.')
graph('Inmuebles depreciación y bajas','PAT07 · PAT09 · PAT10 · CTL04','InmuebleDetalle:0 Bien:1 Baja:2 PoliticaDepreciacionVersion:3 DepreciacionBienPeriodo:4 Poliza:5','Bien>InmuebleDetalle>1 : 0..1;Bien>Baja>1 : 0..1;Bien>DepreciacionBienPeriodo;PoliticaDepreciacionVersion>DepreciacionBienPeriodo;Poliza>DepreciacionBienPeriodo>0..1 : 0..N','Versionar políticas y validar vida útil, residual y método. El cálculo heredado requiere revisión. Las bajas conservan autorización, motivo, evidencia y efecto contable.')
graph('Compras y evaluación de ofertas','COM01 a COM10 · CAT02','Sucursal:0 CentroCosto:1 Requisicion:2 CriterioEvaluacion:3 EvaluacionOferta:4 RequisicionDetalle:5 CotizacionDetalle:8','Sucursal>CentroCosto;CentroCosto>Requisicion;Requisicion>RequisicionDetalle>1 : 1..N;RequisicionDetalle>CotizacionDetalle;CotizacionDetalle>EvaluacionOferta;CriterioEvaluacion>EvaluacionOferta','Se reutilizan requisiciones y cotizaciones. La evaluación agrega criterios de entrega, crédito, historial y riesgo fiscal, con sus ponderaciones y evidencia.')
graph('Recepción y conciliación por partida','COM10 a COM12 · PAG01 · PAG09','OrdenCompraDetalle:0 DestinoOrdenCompra:1 AlmacenCatalogo:2 Recepcion:3 RecepcionDetalle:4 CentroCosto:5 MovimientoInventarioDetalle:6 FacturaRecepcion:7 FacturaDetalle:8','OrdenCompraDetalle>DestinoOrdenCompra;AlmacenCatalogo>DestinoOrdenCompra>0..1 : 0..N;CentroCosto>DestinoOrdenCompra>0..1 : 0..N;Recepcion>RecepcionDetalle>1 : 1..N;DestinoOrdenCompra>RecepcionDetalle;RecepcionDetalle>MovimientoInventarioDetalle>0..1 : 0..N;RecepcionDetalle>FacturaRecepcion;FacturaDetalle>FacturaRecepcion','OrdenCompra conserva su cabecera y partidas. El destino diferencia bienes y servicios; aceptar un servicio no genera stock. FacturaRecepcion conserva cantidades e importes conciliados.')
graph('Presupuesto y reserva por operación','PRE01 a PRE08 · CTL04','PresupuestoVersion:0 EgresoProyectado:1 CentroCosto:2 OperacionNegocio:3 EgresoAutorizado:4 EgreAdecuacionDetalle:5 ReservaPresupuestal:7','PresupuestoVersion>EgresoProyectado;CentroCosto>EgresoProyectado;EgresoProyectado>EgresoAutorizado;EgresoAutorizado>EgreAdecuacionDetalle;EgresoAutorizado>ReservaPresupuestal;OperacionNegocio>ReservaPresupuestal','Conservar infraestructura presupuestal y adaptar clasificadores al corporativo. Conciliar reservas, liberaciones y afectaciones para evitar descontar dos veces un compromiso.')
graph('Proveedor corporativo y validación','CAT03 · FIS01 · FIS02 · BAN03','Empresa:0 ProveedorEmpresa:1 Proveedor:2 CuentaProveedor:3 EvaluacionFiscalProveedor:5','Empresa>ProveedorEmpresa;Proveedor>ProveedorEmpresa;ProveedorEmpresa>CuentaProveedor;ProveedorEmpresa>EvaluacionFiscalProveedor','El proveedor puede compartirse como catálogo. Su habilitación y condiciones se controlan por empresa; cada consulta fiscal o validación bancaria conserva fecha, resultado y evidencia.')
graph('Factura crédito y calendario de pago','PAG01 a PAG08','NotaCredito:0 AplicacionNotaCredito:1 Factura:2 CompromisoPago:5 ProgramacionPago:8','NotaCredito>AplicacionNotaCredito>1 : 1..N;Factura>AplicacionNotaCredito;Factura>CompromisoPago;CompromisoPago>ProgramacionPago','El compromiso representa deuda o salida autorizada con vencimiento. La nota reduce el saldo y la agenda conserva reprogramaciones. Los compromisos de otros módulos mantienen su origen explícito.')
graph('Pago parcial cheque y contabilidad','PAG07 a PAG12 · CTL04','CuentaBancaria:0 Pago:1 AplicacionPago:2 EventoCheque:3 Cheque:4 CompromisoPago:5 Poliza:6 PagoPoliza:7','CuentaBancaria>Pago;Pago>AplicacionPago>1 : 1..N;CompromisoPago>AplicacionPago;Pago>Cheque>1 : 0..1;Cheque>EventoCheque;Pago>PagoPoliza;Poliza>PagoPoliza','Separar compromiso, pago y aplicación permite parcialidades. Adaptar CLC y Cheque para revisar la exigencia actual de liquidar el total de la CLC, sin duplicar salidas de fondos.')
graph('Bancos dispersión y conciliación','BAN01 a BAN06 · PAG10','ConexionBancaria:0 CuentaBancaria:1 MovimientoBancario:2 LoteDispersion:3 Pago:4 ConciliacionDetalle:5 OperacionBancaria:6 IntentoEnvioBancario:7 PrevisionTesoreria:8','CuentaBancaria>ConexionBancaria;CuentaBancaria>MovimientoBancario;CuentaBancaria>Pago;MovimientoBancario>ConciliacionDetalle;Pago>ConciliacionDetalle;Pago>OperacionBancaria;LoteDispersion>OperacionBancaria>0..1 : 0..N;OperacionBancaria>IntentoEnvioBancario','PrevisionTesoreria pertenece a Empresa y separa proyección de movimientos reales. Los reintentos usan una clave única. Las credenciales se guardan como referencias a un repositorio seguro.')
graph('Caja chica vales y arqueos','CAJ01 a CAJ03 · CAJ06','ResponsableOperativo:0 FondoCaja:1 MovimientoFondo:2 ArqueoDetalle:3 ArqueoCaja:4 ValeCaja:5 ComprobanteGasto:7 ComprobacionCaja:8','ResponsableOperativo>FondoCaja;FondoCaja>MovimientoFondo;FondoCaja>ArqueoCaja;ArqueoCaja>ArqueoDetalle;FondoCaja>ValeCaja;ValeCaja>ComprobacionCaja;ComprobanteGasto>ComprobacionCaja','FondoCaja pertenece a Empresa. Los movimientos conservan cada entrada, gasto, reposición y reversa. El arqueo compara saldo teórico y efectivo contado.')
graph('Reposición de caja chica','CAJ04 · PAG06 · PAG09','FondoCaja:0 ReposicionCaja:1 CompromisoPago:2 ComprobacionCaja:3 ReposicionDetalle:4','FondoCaja>ReposicionCaja;ReposicionCaja>CompromisoPago;ReposicionCaja>ReposicionDetalle>1 : 1..N;ComprobacionCaja>ReposicionDetalle','Incluir solo comprobaciones aceptadas y aún no repuestas. La autorización genera el compromiso; el pago confirmado produce la reposición efectiva del fondo.')
graph('Viáticos anticipos y reintegros','VIA01 a VIA05','ResponsableOperativo:0 SolicitudViatico:1 AnticipoViatico:2 ComprobanteGasto:3 ComprobacionViatico:4 CompromisoPago:5 MovimientoBancario:6 ReintegroViatico:7','ResponsableOperativo>SolicitudViatico;SolicitudViatico>AnticipoViatico;AnticipoViatico>CompromisoPago;SolicitudViatico>ComprobacionViatico;ComprobanteGasto>ComprobacionViatico;SolicitudViatico>ReintegroViatico;MovimientoBancario>ReintegroViatico>0..1 : 0..N','SolicitudViatico pertenece a Empresa y CentroCosto. Las aplicaciones controlan importes para impedir que un mismo gasto se compruebe dos veces entre caja y viáticos.')
graph('Calendario de cumplimiento institucional','CUM01 a CUM06 · FIS05 · CTL07','Empresa:0 ObligacionEmpresa:1 CatalogoObligacion:2 Sucursal:3 VencimientoObligacion:4 ResponsableOperativo:5 Documento:6 EvidenciaCumplimiento:7','Empresa>ObligacionEmpresa;CatalogoObligacion>ObligacionEmpresa;Sucursal>ObligacionEmpresa>0..1 : 0..N;ResponsableOperativo>ObligacionEmpresa;ObligacionEmpresa>VencimientoObligacion;VencimientoObligacion>EvidenciaCumplimiento;Documento>EvidenciaCumplimiento','Un calendario para fiscal, licencias y Protección Civil. IMSS, INFONAVIT, REPSE e impuesto sobre nómina se limitan a expedientes corporativos, sin cálculos ni operación de RH.')
graph('CFDI y comprobantes de gasto','FIS01 a FIS04 · CAJ05 · VIA03','Empresa:0 Cfdi:1 CfdiConcepto:2 ValidacionCfdi:3 EventoCfdi:4 CfdiImpuesto:5 Factura:6 ComprobanteGasto:7 Documento:8','Empresa>Cfdi;Cfdi>CfdiConcepto;CfdiConcepto>CfdiImpuesto;Cfdi>ValidacionCfdi;Cfdi>EventoCfdi;Cfdi>Factura>0..1 : 0..1;Cfdi>ComprobanteGasto>0..1 : 0..N;Documento>ComprobanteGasto','UUID, XML y validaciones se distinguen del registro de factura. La firma PFX no sustituye SAT o PAC. La unicidad y los importes aplicados deben evitar documentos y gastos duplicados.')
graph('Declaraciones y determinación fiscal','FIS06 a FIS10','VencimientoObligacion:0 Declaracion:1 DeclaracionVersion:2 CompromisoPago:3 ReglaFiscalVersion:4 DeterminacionImpuesto:5 Cfdi:6 DeclaracionCfdi:7 ActualizacionRecargo:8','VencimientoObligacion>Declaracion;VencimientoObligacion>CompromisoPago;Declaracion>DeclaracionVersion>1 : 1..N;DeclaracionVersion>DeterminacionImpuesto;ReglaFiscalVersion>DeterminacionImpuesto;DeterminacionImpuesto>ActualizacionRecargo;DeclaracionVersion>DeclaracionCfdi;Cfdi>DeclaracionCfdi','Reglas, parámetros y cálculos requieren versiones aprobadas por el responsable fiscal. Los acuses pertenecen a una versión concreta y los CFDI explican las bases declaradas.')
graph('Auditorías fiscales y sanciones','FIS11 · CTL07','Empresa:0 AuditoriaFiscal:1 ObservacionFiscal:2 CompromisoPago:4 SancionFiscal:5','Empresa>AuditoriaFiscal;AuditoriaFiscal>ObservacionFiscal;ObservacionFiscal>SancionFiscal;SancionFiscal>CompromisoPago','Atención y evidencia quedan ligadas al expediente. Las sanciones usan el mismo modelo de tesorería; el pago mantiene una referencia verificable a su origen fiscal.')
graph('Autorización y decisiones','COM06 a COM07 · CTL01 a CTL02','Empresa:0 OperacionNegocio:1 EnvioWorkflow:2 WorkflowEstado:3 WorkflowTemplate:4 DecisionAutorizacion:5 WorkflowTransicion:6 ReglaAutorizacion:7 Usuario:8','Empresa>OperacionNegocio;OperacionNegocio>EnvioWorkflow;WorkflowTemplate>EnvioWorkflow;WorkflowTemplate>WorkflowEstado;WorkflowTemplate>WorkflowTransicion;WorkflowTemplate>ReglaAutorizacion;EnvioWorkflow>DecisionAutorizacion;ReglaAutorizacion>DecisionAutorizacion;Usuario>DecisionAutorizacion','Las cabeceras incorporan una FK única a OperacionNegocio. Se generaliza el workflow conservando compatibilidad; cada decisión conserva regla aplicada, actor, fecha y motivo.')
graph('Plazos eventos y notificaciones','COM03 a COM04 · CTL08 · PRE08','WorkflowTemplate:0 PoliticaSLA:1 CalendarioAtencion:2 EnvioWorkflow:3 PlazoOperacion:4 NotificacionRegla:5 OperacionNegocio:6 EventoPendiente:7 Notificacion:8','WorkflowTemplate>PoliticaSLA;CalendarioAtencion>PoliticaSLA;PoliticaSLA>PlazoOperacion;EnvioWorkflow>PlazoOperacion;OperacionNegocio>EventoPendiente;EventoPendiente>Notificacion;NotificacionRegla>Notificacion','Agregar prioridad y urgencia a solicitudes. El evento controla entrega y reintentos sin duplicar avisos. Los vencimientos de obligaciones usan el mismo mecanismo de notificación.')
graph('Documentos y extracción asistida','COM05 · PAT06 · CUM06 · TEC04','OperacionNegocio:0 OperacionDocumento:1 Documento:2 CampoExtraido:4 ExtraccionDocumento:5','OperacionNegocio>OperacionDocumento;Documento>OperacionDocumento;Documento>ExtraccionDocumento;ExtraccionDocumento>CampoExtraido','Reutilizar soporte documental y controlar clasificación y vigencias. El OCR conserva confianza, corrección y revisión humana antes de afectar información financiera.')
graph('Auditoría segregación y riesgo','CTL01 a CTL03','Empresa:0 ReglaRiesgo:1 CasoRiesgo:2 ReglaSegregacion:3 OperacionNegocio:4 AuditoriaCambio:5','Empresa>ReglaRiesgo;Empresa>ReglaSegregacion;Empresa>OperacionNegocio;ReglaRiesgo>CasoRiesgo;OperacionNegocio>CasoRiesgo;OperacionNegocio>AuditoriaCambio','Comprobar cobertura y conservación de bitácora. Antifraude y PLD requieren reglas aprobadas, evidencia y seguimiento; las tablas no acreditan por sí solas el cumplimiento.')

prose('Qué se modifica en almacén y patrimonio','El catálogo nuevo de almacenes no cambia el significado de la tabla ALMA.Almacen que ya existe.',[
('Empresa Sucursal y TipoBien','Agregar relación corporativa; usar sucursal como campus. Trasladar mínimos, máximos y reposición a ProductoAlmacen y mantener el catálogo de tipos de bien.'),
('ALMA.Almacen y saldos históricos','Conservar registros y referencias. Mapearlos al nuevo modelo sin convertir su PK en identificador del almacén físico; conciliar el saldo inicial por almacén.'),
('Salidas conteos y cierres','Modificar SolicitudSalida, DetalleSolicitudSalida, PeriodoConteo, Conteo y CierreInventario para delimitar almacén y partida. Cambiar la unicidad de PlanConteoCiclico.'),
('Bien InventarioDetalle y resguardos','Agregar ubicación estructurada e historial. Mantener las descripciones actuales como referencia. Incorporar ResponsableOperativo y desacoplar las referencias necesarias de nómina.')])
prose('Qué se modifica en compras y finanzas','Se conservan las entidades existentes y se agregan relaciones que permitan explicar cada afectación.',[
('Compras y presupuesto','Adaptar OrdenCompra y partidas para destinos y recepción parcial. Agregar versión, centro de costo y reservas presupuestales vinculadas a operaciones; revisar clasificadores corporativos.'),
('Factura y sus partidas','Agregar proveedor explícito, vencimiento, CFDI y conciliación contra recepción. Adaptar la dependencia obligatoria del contrato gubernamental.'),
('CLC Cheque y CuentaBancaria','Integrar compromiso, pago y aplicación; revisar la regla de liquidar toda la CLC. Registrar entrega, cancelación, confirmación bancaria y conciliación.'),
('Poliza y reportes','Relacionar operaciones con afectaciones y reversas. Ajustar vistas, procedimientos y reportes de existencias para consultar almacén y consolidar campus y empresa.')])
prose('Reglas que debe proteger la base de datos','Estas condiciones son parte del plan y deben detallarse en el diseño físico y en los servicios de negocio.',[
('Empresa y ubicación coherentes','Las FK y validaciones deben impedir mezclar empresas, campus, almacenes y partidas. Se necesita una clave coherente por producto, ubicación, lote y condición.'),
('Transferencia o movimiento intercompañía','La transferencia ordinaria ocurre dentro de la misma empresa. Entre empresas se necesita una operación diferenciada, con trazabilidad financiera y documental.'),
('Saldo y concurrencia','Validar y afectar reservas y salidas dentro de una transacción. Movimientos aplicados por reversa, claves de idempotencia para reintentos y validaciones contra duplicidad.'),
('Migración','Conciliar el saldo inicial por almacén. La ubicación histórica no demostrable queda pendiente de clasificación. Los cierres son fotografías y no se suman de nuevo como entradas.')])
prose('Decisiones que el ERD no resuelve solo','El modelo es lógico. No sustituye contratos de integración, reglas aprobadas ni pruebas operativas.',[
('Plataforma y despliegue','Confirmar SQL Server y solución propia frente a Power Platform, SharePoint o PostgreSQL. Definir Azure y operación. La decisión puede cambiar implementación e integración.'),
('Banca fiscal y dispositivos','Acordar SAT o PAC, interfaces por banco, Power BI y Atempo fuera de RH. Definir app o PWA, funcionamiento sin conexión y equipos RFID.'),
('BI y requerimientos no funcionales','Diseñar vistas y modelos analíticos sobre datos conciliados. Navegadores, 50 concurrentes, respaldo y recuperación necesitan pruebas; precisar el 97 por ciento, RPO y RTO.'),
('Alcance comercial','Separar reutilización, adaptación, desarrollo e integración. Las tablas no significan que el sistema esté completo; el plan no compromete todavía costo ni plazo.')])
prose('Fuentes y evidencia','Corte del análisis: 17 de septiembre de 2026. El documento desarrolla el ERD explicado y conserva el alcance sin RH.',[
('Archivos entregados','Propuesta_ERP_Corporativo 210526.pdf; PROPUESTA_ERP_CORPORATIVO REQ.pdf; Resumen_ERP_Cumplimiento_Fiscal.pdf; EDT del proyecto institucional. TALENTO y las ramas de RH se excluyen.'),
('Trazabilidad','Documentos 01 y 02 de Universidad Maya: 101 requerimientos y FIT & GAP. Los códigos en cada lámina indican requisitos relacionados, no cobertura funcional ya probada.'),
('Evidencia multi almacén','Models/Almacen.cs, PeriodoConteo.cs, PlanConteoCiclico.cs y EGestionContext.cs. GetExistenciasRegistradasAsync, en AlmacenAppService.cs, agrupa por tipo de bien y unidad dentro de empresa y ejercicio.'),
('Repositorio revisado','C:/Desarrollo/Desarrollo/FullStack/EGestion360. Modelos en BackEnd/EG.Infraestructure y servicios en BackEnd/EG.Application. Commit base 211aecb674e73fe750cf8f78a390ab8ba9a247f8; incluye cambios locales.')])

for n,s in {
'Proveedor':'PK Proveedor existente|RFC / datos de identificación',
'Requisicion':'PK Requisicion / FK Empresa|FK CentroCosto propuesto|Prioridad / urgencia / operación',
'RequisicionDetalle':'PK Detalle / FK Requisicion|FK TipoBien / cantidad solicitada',
'CotizacionDetalle':'PK Detalle de cotización|Oferta / precio / condiciones|Vínculo a partida solicitada',
'OrdenCompraDetalle':'PK Detalle / FK OrdenCompra|FK TipoBien / cantidad|Destinos y recepción por partida',
'FacturaDetalle':'PK Detalle / FK Factura|Concepto / cantidad / importe|Vínculos a partidas recibidas',
'EgresoProyectado':'PK Egreso existente / FK Empresa|FK Version / CentroCosto|Periodos / importes proyectados',
'EgresoAutorizado':'PK Egreso existente / FK Empresa|FK EgresoProyectado|Importes aprobados / autorización',
'EgreAdecuacionDetalle':'PK Detalle de adecuación|FK EgresoAutorizado|Importe / tipo de modificación',
'Factura':'PK Factura existente / FK Empresa|FK Proveedor / CFDI propuestos|Total / vencimiento / estado',
'CuentaBancaria':'PK Cuenta existente / FK Empresa|Banco / CLABE / moneda|Saldo y conciliación verificables',
'Cheque':'PK Cheque existente|FK Pago propuesto / cuenta|Número / estado / CLC adaptada',
'Documento':'PK Documento existente|FK Empresa / versión / hash|Contenido o referencia de archivo',
'EnvioWorkflow':'PK Envio existente|FK Operacion / Template|Estado / token / fechas',
'WorkflowTemplate':'PK Template existente|Versión / vigencia / alcance',
'WorkflowEstado':'PK Estado existente / FK Template|Código / orden / inicial / final',
'WorkflowTransicion':'PK Transicion / FK Template|FK EstadoOrigen / Destino|Roles / firma / reglas adaptadas',
'AuditoriaCambio':'PK Auditoria existente|FK Operacion / Empresa|Actor / cambio / fecha / retención',
'Notificacion':'PK Notificacion existente|FK EventoPendiente propuesto|Destinatario / estado / fecha',
'NotificacionRegla':'PK Regla existente|Evento / destino / vigencia|Ámbito y programación adaptados'
}.items():f(n,s)
C=canvas.Canvas(str(FILE),pagesize=(W,H),pageCompression=1)
C.setTitle('Plan de base de datos y ERD - EXUX - Universidad Maya');C.setAuthor('EXUX')
TOTAL=len(P)+2
def text(x,y,s,size=16,bold=False,color=INK):
    C.setFillColor(color);C.setFont('B' if bold else 'A',size);C.drawString(x,H-y-size*.82,s)
def par(s,x,y,w,size=17,color=INK):
    style=ParagraphStyle('x',fontName='A',fontSize=size,leading=size*1.32,textColor=color)
    p=Paragraph(escape(s),style);_,h=p.wrap(w,1000);p.drawOn(C,x,H-y-h);return h
def logo(x,y,w):C.drawImage(LOGO,x,H-y-w*447/1600,width=w,height=w*447/1600,mask='auto')
def base(num,title,sub=''):
    C.setFillColor(white);C.rect(0,0,W,H,fill=1,stroke=0);logo(W-165,24,115)
    text(46,30,'UNIVERSIDAD MAYA / PLAN DE BASE DE DATOS',12,True,GRAY)
    text(46,87,title,30,True)
    if sub:par(sub,46,134,W-92,15,GRAY)
    text(46,810,'EXUX  |  Diseño lógico propuesto  |  Sin RH  |  17 septiembre 2026',11,False,GRAY)
    C.setFillColor(GRAY);C.setFont('B',11);C.drawRightString(W-46,22,f'{num:02d} / {TOTAL:02d}')
def rect(slot):return (46+400*(slot%3),202+138*(slot//3),298,96)
def ports(r):
    x,y,w,h=r;return [(x-8,y+h/2),(x+w+8,y+h/2),(x+w/2,y-8),(x+w/2,y+h+8)]
def collision(a,b,r):
    x,y,w,h=r
    x-=3;y-=3;w+=6;h+=6
    if abs(a[0]-b[0])<.1:return x+1<a[0]<x+w-1 and max(min(a[1],b[1]),y+1)<min(max(a[1],b[1]),y+h-1)
    return y+1<a[1]<y+h-1 and max(min(a[0],b[0]),x+1)<min(max(a[0],b[0]),x+w-1)
def route(a,b,obs,used):
    cand=[]
    for s in ports(a):
      for t in ports(b):
        possible=[[s,(s[0],t[1]),t],[s,(t[0],s[1]),t]]
        for xx in [26,369,395,421,769,795,821,1166]:possible.append([s,(xx,s[1]),(xx,t[1]),t])
        for yy in [182,314,326,452,464,594]:possible.append([s,(s[0],yy),(t[0],yy),t])
        for pts in possible:
            q=[pts[0]]
            for p in pts[1:]:
                if p!=q[-1]:q.append(p)
            if all(not any(collision(u,v,r) for r in obs) for u,v in zip(q,q[1:])):
                length=sum(hypot(u[0]-v[0],u[1]-v[1]) for u,v in zip(q,q[1:]))
                penalty=0
                for u,v in zip(q,q[1:]):
                    for j,k in used:
                        if u[0]==v[0]==j[0]==k[0]:
                            overlap=max(0,min(max(u[1],v[1]),max(j[1],k[1]))-max(min(u[1],v[1]),min(j[1],k[1])))
                            penalty+=overlap*12
                        elif u[1]==v[1]==j[1]==k[1]:
                            overlap=max(0,min(max(u[0],v[0]),max(j[0],k[0]))-max(min(u[0],v[0]),min(j[0],k[0])))
                            penalty+=overlap*12
                cand.append((length+len(q)*18+penalty,q))
    assert cand,(a,b)
    return min(cand,key=lambda c:c[0])[1]
def node(name,r):
    x,y,w,h=r;state='E' if name in EX else 'M' if name in MOD else 'N';accent,fill=map(HexColor,COL[state])
    C.setFillColor(fill);C.setStrokeColor(accent);C.setLineWidth(1);C.roundRect(x,H-y-h,w,h,6,fill=1,stroke=1)
    C.setFillColor(accent);C.roundRect(x,H-y-28,w,28,6,fill=1,stroke=0);C.rect(x,H-y-28,w,8,fill=1,stroke=0)
    size=14.5
    while pdfmetrics.stringWidth(name,'B',size)>w-42:size-=.25
    assert size>=12.5,(name,size)
    text(x+10,y+7,name,size,True,white);text(x+w-24,y+8,state,12,True,white)
    fields=FIELDS.get(name,['PK Identificador existente','FK Alcance o vínculo propuesto'])
    for i,s in enumerate(fields):
        fs=12.5
        while pdfmetrics.stringWidth(s,'A',fs)>w-20:fs-=.25
        text(x+10,y+37+i*18,s,fs)
def diagram(p):
    boxes={name:rect(slot) for name,slot in p['nodes'].items()}
    labelpoints=[];used=[]
    for i,(a,b,card) in enumerate(p['edges'],1):
        pts=route(boxes[a],boxes[b],list(boxes.values()),used)
        used.extend(zip(pts,pts[1:]))
        C.setStrokeColor(HexColor('#75909F'));C.setLineWidth(1.3)
        for end,r in [(pts[0],boxes[a]),(pts[-1],boxes[b])]:
            ex,ey=end;rx,ry,rw,rh=r
            tx=min(max(ex,rx),rx+rw);ty=min(max(ey,ry),ry+rh)
            C.line(ex,H-ey,tx,H-ty)
        for u,v in zip(pts,pts[1:]):C.line(u[0],H-u[1],v[0],H-v[1])
        u,v=max(zip(pts,pts[1:]),key=lambda uv:hypot(uv[0][0]-uv[1][0],uv[0][1]-uv[1][1]))
        x,y=(u[0]+v[0])/2,(u[1]+v[1])/2
        for px,py in labelpoints:
            if hypot(x-px,y-py)<23:
                if abs(u[0]-v[0])<1:y+=24
                else:x+=24
        labelpoints.append((x,y));C.setFillColor(white);C.circle(x,H-y,9,fill=1,stroke=1)
        C.setFont('B',10);C.setFillColor(INK);C.drawCentredString(x,H-y-3.5,str(i))
    for name,r in boxes.items():node(name,r)
    # Relationship list is part of the ERD and carries exact cardinality.
    for i,(a,b,card) in enumerate(p['edges']):
        x=46+(i%2)*555;y=617+(i//2)*24
        s=f'{i+1}   {a} > {b}   [{card}]'
        size=11.8
        while pdfmetrics.stringWidth(s,'A',size)>540:size-=.2
        text(x,y,s,size)
    par(p['note'],46,749,W-92,14,GRAY)
    for x,state,label in [(46,'N','Nueva'),(215,'M','Modificar'),(408,'E','Reutilizar')]:
        text(x,173,state+'  '+label,12,True,HexColor(COL[state][0]))
    text(681,173,'Relaciones numeradas y cardinalidad al pie',12,False,GRAY)

base(1,'');logo(52,142,270)
text(52,285,'Plan de base de datos',44,True);text(52,344,'y diagramas ERD',44,True)
par('Universidad Maya y Corporativo SINERGIA',52,433,1050,25)
par('Modelo propuesto para cubrir el FIT & GAP con operación multi almacén y alcance sin Recursos Humanos.',52,497,1010,25)
text(52,639,'Tablas nuevas / Tablas que cambian / Relaciones reutilizables',21,True,BLUE)
par('Documento de planeación. No se han aplicado modificaciones a la base de datos ni al código.',52,705,1040,18,GRAY)
C.bookmarkPage('cover');C.addOutlineEntry('Portada','cover');C.showPage()
base(2,'Guía de navegación','Formato A3 horizontal / Diagramas vectoriales ampliables / Índice interactivo')
groups=[('Diagnóstico y lectura',0,1),('Multi almacén y patrimonio',2,9),('Compras presupuesto y proveedores',10,13),('Pagos bancos caja y viáticos',14,19),('Fiscal y cumplimiento',20,23),('Autorización documentos y control',24,27),('Cambios reglas y fuentes',28,len(P)-1)]
for i,(title,a,b) in enumerate(groups):
    y=213+i*67;text(52,y,title,22,True);text(985,y,f'{a+3:02d} - {b+3:02d}',21,False,BLUE)
    C.setStrokeColor(HexColor('#D7E2E9'));C.line(52,H-y-37,W-52,H-y-37)
    C.linkRect('',f'p{a+3}',(48,H-y-38,W-48,H-y+5),thickness=0)
par('Los identificadores CAT, COM, PRE, PAG, BAN, CAJ, VIA, PAT, FIS, CUM, CTL, TEC y NFR corresponden a los grupos de la lista de requerimientos.',52,728,1070,16,GRAY)
C.showPage()
for num,p in enumerate(P,3):
    C.bookmarkPage(f'p{num}');C.addOutlineEntry(p['title'],f'p{num}')
    base(num,p['title'],p.get('codes',''))
    if p['kind']=='graph':diagram(p)
    else:
        par(p['lead'],46,150,W-92,20,GRAY);y=251
        for title,body in p['items']:
            text(46,y,title,21,True,BLUE);h=par(body,46,y+33,W-92,19)
            y+=max(116,h+59)
        assert y<802,(p['title'],y)
    C.showPage()
C.save()
report={'file':str(FILE),'pages':TOTAL,'diagram_pages':sum(p['kind']=='graph' for p in P),'entities':len(set(n for p in P if p['kind']=='graph' for n in p['nodes']))}
(ROOT/'tmp/maya_fitgap/erd_build_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
