/*
EXUX | Universidad Maya | Propuesta de reestructura SQL Server 2022
98 / Mapa ERD y reestructura
Generado a partir de metadatos: EmptyProjects (26 tablas) y GestionEmpresarial (309 tablas).
SOLO ARCHIVO GENERADO. NO APLICADO. SIN DATOS, SIN USUARIOS, SIN CREDENCIALES.
ENTIDADES DEL ERD (128)
ActualizacionRecargo -> FIS.ActualizacionRecargo
AlmacenCatalogo -> ALMA.AlmacenCatalogo
AnticipoViatico -> VIA.AnticipoViatico
AplicacionNotaCredito -> PAG.AplicacionNotaCredito
AplicacionPago -> PAG.AplicacionPago
ArqueoCaja -> CAJA.ArqueoCaja
ArqueoDetalle -> CAJA.ArqueoDetalle
AuditoriaCambio -> PBR.AuditoriaCambio
AuditoriaFiscal -> FIS.AuditoriaFiscal
Baja -> ALMA.Bajas
Bien -> ALMA.Bien
CalendarioAtencion -> WF.CalendarioAtencion
CampoExtraido -> DOC.CampoExtraido
CasoRiesgo -> CTL.CasoRiesgo
CatalogoObligacion -> CUM.CatalogoObligacion
CentroCosto -> SIS.CentroCosto
Cfdi -> FIS.Cfdi
CfdiConcepto -> FIS.CfdiConcepto
CfdiImpuesto -> FIS.CfdiImpuesto
Cheque -> PRES.Cheque
CierreInventario -> ALMA.CierreInventario
ComprobacionCaja -> CAJA.ComprobacionCaja
ComprobacionViatico -> VIA.ComprobacionViatico
ComprobanteGasto -> FIS.ComprobanteGasto
CompromisoPago -> PAG.CompromisoPago
ConciliacionDetalle -> TES.ConciliacionDetalle
ConexionBancaria -> TES.ConexionBancaria
Conteo -> ALMA.Conteo
ConteoDetalle -> ALMA.ConteoDetalle
ConteoDetalleEscaneo -> ALMA.ConteoDetalleEscaneo
Corporativo -> SIS.Corporativo
CotizacionDetalle -> ORCO.CotizacionDetalle
CriterioEvaluacion -> ORCO.CriterioEvaluacion
CuentaBancaria -> TES.CuentaBancaria
CuentaProveedor -> ORCO.CuentaProveedor
DecisionAutorizacion -> WF.DecisionAutorizacion
Declaracion -> FIS.Declaracion
DeclaracionCfdi -> FIS.DeclaracionCfdi
DeclaracionVersion -> FIS.DeclaracionVersion
DepreciacionBienPeriodo -> PAT.DepreciacionBienPeriodo
DestinoOrdenCompra -> ORCO.DestinoOrdenCompra
DetalleSolicitudSalida -> ALMA.DetalleSolicitudSalida
DeterminacionImpuesto -> FIS.DeterminacionImpuesto
Documento -> SIS.Documento
EgreAdecuacionDetalle -> PRES.EgreAdecuacionDetalle
EgresoAutorizado -> PRES.EgresoAutorizado
EgresoProyectado -> PRES.EgresoProyectado
Empresa -> SIS.Empresa
EnvioWorkflow -> SIS.EnvioWorkflow
EvaluacionFiscalProveedor -> ORCO.EvaluacionFiscalProveedor
EvaluacionOferta -> ORCO.EvaluacionOferta
EventoCfdi -> FIS.EventoCfdi
EventoCheque -> TES.EventoCheque
EventoPendiente -> WF.EventoPendiente
EvidenciaCumplimiento -> CUM.EvidenciaCumplimiento
ExtraccionDocumento -> DOC.ExtraccionDocumento
Factura -> PRES.Factura
FacturaDetalle -> PRES.FacturaDetalle
FacturaRecepcion -> PAG.FacturaRecepcion
FondoCaja -> CAJA.FondoCaja
HistorialUbicacionBien -> PAT.HistorialUbicacionBien
IdentificadorBien -> PAT.IdentificadorBien
InmuebleDetalle -> PAT.InmuebleDetalle
IntentoEnvioBancario -> TES.IntentoEnvioBancario
Lote -> ALMA.Lote
LoteDispersion -> TES.LoteDispersion
MovimientoBancario -> TES.MovimientoBancario
MovimientoFondo -> CAJA.MovimientoFondo
MovimientoInventario -> ALMA.MovimientoInventario
MovimientoInventarioDetalle -> ALMA.MovimientoInventarioDetalle
NotaCredito -> PAG.NotaCredito
Notificacion -> SIS.Notificacion
NotificacionRegla -> SIS.NotificacionRegla
ObligacionEmpresa -> CUM.ObligacionEmpresa
ObservacionFiscal -> FIS.ObservacionFiscal
OperacionBancaria -> TES.OperacionBancaria
OperacionDocumento -> DOC.OperacionDocumento
OperacionNegocio -> SIS.OperacionNegocio
OrdenCompraDetalle -> ORCO.OrdenCompraDetalle
Pago -> PAG.Pago
PagoPoliza -> PAG.PagoPoliza
PartidaStock -> ALMA.PartidaStock
PeriodoConteo -> ALMA.PeriodoConteo
PlanConteoCiclico -> ALMA.PlanConteoCiclico
PlazoOperacion -> WF.PlazoOperacion
PoliticaDepreciacionVersion -> PAT.PoliticaDepreciacionVersion
PoliticaSLA -> WF.PoliticaSLA
Poliza -> CONTA.Poliza
PresupuestoVersion -> PRES.PresupuestoVersion
PrevisionTesoreria -> TES.PrevisionTesoreria
ProductoAlmacen -> ALMA.ProductoAlmacen
ProgramacionPago -> PAG.ProgramacionPago
Proveedor -> SIS.Proveedor
ProveedorEmpresa -> SIS.ProveedorEmpresa
Recepcion -> ORCO.Recepcion
RecepcionDetalle -> ORCO.RecepcionDetalle
ReglaAutorizacion -> WF.ReglaAutorizacion
ReglaFiscalVersion -> FIS.ReglaFiscalVersion
ReglaRiesgo -> CTL.ReglaRiesgo
ReglaSegregacion -> CTL.ReglaSegregacion
ReintegroViatico -> VIA.ReintegroViatico
ReposicionCaja -> CAJA.ReposicionCaja
ReposicionDetalle -> CAJA.ReposicionDetalle
Requisicion -> ORCO.Requisicion
RequisicionDetalle -> ORCO.RequisicionDetalle
ReservaPresupuestal -> PRES.ReservaPresupuestal
ReservaStock -> ALMA.ReservaStock
Resguardo -> ALMA.Resguardo
ResguardoDetalle -> ALMA.ResguardoDetalle
ResguardoMovimiento -> ALMA.ResguardoMovimiento
ResponsableOperativo -> SIS.ResponsableOperativo
SancionFiscal -> FIS.SancionFiscal
SolicitudSalida -> ALMA.SolicitudSalida
SolicitudViatico -> VIA.SolicitudViatico
Sucursal -> SIS.Sucursal
TipoBien -> ALMA.TipoBien
Transferencia -> ALMA.Transferencia
TransferenciaDetalle -> ALMA.TransferenciaDetalle
UbicacionAlmacen -> ALMA.UbicacionAlmacen
UbicacionPatrimonial -> PAT.UbicacionPatrimonial
Usuario -> SIS.Usuario
UsuarioAlmacen -> ALMA.UsuarioAlmacen
ValeCaja -> CAJA.ValeCaja
ValidacionCfdi -> FIS.ValidacionCfdi
VencimientoObligacion -> CUM.VencimientoObligacion
WorkflowEstado -> PBR.WorkflowEstado
WorkflowTemplate -> PBR.WorkflowTemplate
WorkflowTransicion -> PBR.WorkflowTransicion

CAMBIOS EXPLÍCITOS RESPECTO DE LOS ORÍGENES
ALMA.Bajas.SolicitadoPor_NOM -> Sustituido por SolicitadoPor_Responsable -> SIS.ResponsableOperativo
ALMA.Bajas.AutorizadoPor_NOM -> Sustituido por AutorizadoPor_Responsable -> SIS.ResponsableOperativo
ALMA.Bien.Costo -> Alias dmoney -> decimal(20,4)
ALMA.Bien.ValorRescate -> Alias dmoney -> decimal(20,4)
ALMA.Bien.ValorActual -> Alias dmoney -> decimal(20,4)
ALMA.ConteoDetalle.FKIdPersona_NOM -> Sustituido por FKIdPersona_Responsable -> SIS.ResponsableOperativo
ALMA.ConteoDetalleEscaneo.FKIdPersona_NOM -> Sustituido por FKIdPersona_Responsable -> SIS.ResponsableOperativo
CONTA.PolizaDetalle.ImporteDebe -> Alias dmoney -> decimal(20,4)
CONTA.PolizaDetalle.ImporteHaber -> Alias dmoney -> decimal(20,4)
ORCO.CotizacionDetalle.PrecioUnitario -> Alias dmoney -> decimal(20,4)
ORCO.EstudioMercado.FKIdResponsable_NOM -> Sustituido por FKIdResponsable_Responsable -> SIS.ResponsableOperativo
ORCO.EstudioMercadoDetalleCosto.PrecioUnitario -> Alias dmoney -> decimal(20,4)
ORCO.PAAAS.FKIdPersona_NOM -> Sustituido por FKIdPersona_Responsable -> SIS.ResponsableOperativo
ORCO.Requisicion.Importe -> Alias dmoney -> decimal(20,4)
ORCO.Requisicion.FKIdPersona_NOM -> Sustituido por FKIdPersona_Responsable -> SIS.ResponsableOperativo
ORCO.Requisicion.FKIdJefeAlmacen_NOM -> Sustituido por FKIdJefeAlmacen_Responsable -> SIS.ResponsableOperativo
ORCO.Requisicion.FKIdSuperviso_NOM -> Sustituido por FKIdSuperviso_Responsable -> SIS.ResponsableOperativo
ORCO.Requisicion.FKIdAutorizo_NOM -> Sustituido por FKIdAutorizo_Responsable -> SIS.ResponsableOperativo
ORCO.Requisicion.FKIdPSolicita_NOM -> Sustituido por FKIdPSolicita_Responsable -> SIS.ResponsableOperativo
ORCO.Requisicion.FKIdPJefeAlmacen_NOM -> Sustituido por FKIdPJefeAlmacen_Responsable -> SIS.ResponsableOperativo
ORCO.Requisicion.FKIdPSuficiencia_NOM -> Sustituido por FKIdPSuficiencia_Responsable -> SIS.ResponsableOperativo
ORCO.Requisicion.FKIdPSuperviso_NOM -> Sustituido por FKIdPSuperviso_Responsable -> SIS.ResponsableOperativo
ORCO.Requisicion.FKIdPAutorizo_NOM -> Sustituido por FKIdPAutorizo_Responsable -> SIS.ResponsableOperativo
ORCO.RequisicionPartida.Monto -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficiencia.AutorizadoPor_NOM -> Sustituido por AutorizadoPor_Responsable -> SIS.ResponsableOperativo
PRES.AutorizacionSuficienciaDetalle.Enero -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficienciaDetalle.Febrero -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficienciaDetalle.Marzo -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficienciaDetalle.Abril -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficienciaDetalle.Mayo -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficienciaDetalle.Junio -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficienciaDetalle.Julio -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficienciaDetalle.Agosto -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficienciaDetalle.Septiembre -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficienciaDetalle.Octubre -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficienciaDetalle.Noviembre -> Alias dmoney -> decimal(20,4)
PRES.AutorizacionSuficienciaDetalle.Diciembre -> Alias dmoney -> decimal(20,4)
PRES.CLC.ImporteTotal -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Enero -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Febrero -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Marzo -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Abril -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Mayo -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Junio -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Julio -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Agosto -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Septiembre -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Octubre -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Noviembre -> Alias dmoney -> decimal(20,4)
PRES.CLCDetalle.Diciembre -> Alias dmoney -> decimal(20,4)
PRES.CLCFactura.MontoAplicado -> Alias dmoney -> decimal(20,4)
PRES.Cheque.ImporteTotal -> Alias dmoney -> decimal(20,4)
PRES.ChequePartidas.MontoPagado -> Alias dmoney -> decimal(20,4)
PRES.Contrato.MontoTotal -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Enero -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Febrero -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Marzo -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Abril -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Mayo -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Junio -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Julio -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Agosto -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Septiembre -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Octubre -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Noviembre -> Alias dmoney -> decimal(20,4)
PRES.ContratoDetalle.Diciembre -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Enero -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Febrero -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Marzo -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Abril -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Mayo -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Junio -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Julio -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Agosto -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Septiembre -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Octubre -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Noviembre -> Alias dmoney -> decimal(20,4)
PRES.EgreAdecuacionDetalle.Diciembre -> Alias dmoney -> decimal(20,4)
PRES.Factura.Subtotal -> Alias dmoney -> decimal(20,4)
PRES.Factura.IVA -> Alias dmoney -> decimal(20,4)
PRES.Factura.Retencion -> Alias dmoney -> decimal(20,4)
PRES.Factura.Total -> Alias dmoney -> decimal(20,4)
PRES.FacturaDetalle.MontoAplicado -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Enero -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Febrero -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Marzo -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Abril -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Mayo -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Junio -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Julio -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Agosto -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Septiembre -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Octubre -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Noviembre -> Alias dmoney -> decimal(20,4)
PRES.IngreAdecuacionDetalle.Diciembre -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Enero -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Febrero -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Marzo -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Abril -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Mayo -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Junio -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Julio -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Agosto -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Septiembre -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Octubre -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Noviembre -> Alias dmoney -> decimal(20,4)
PRES.SolicitudSuficienciaDetalle.Diciembre -> Alias dmoney -> decimal(20,4)
TES.CuentaBancaria.SaldoInicial -> Alias dmoney -> decimal(20,4)
TES.CuentaBancaria.SaldoActual -> Alias dmoney -> decimal(20,4)
CONTA.Poliza.IdEmpresa -> Nueva pertenencia obligatoria a empresa
ALMA.Conteo.IdEmpresa -> Nueva pertenencia obligatoria a empresa
ALMA.ConteoDetalle.IdEmpresa -> Nueva pertenencia obligatoria a empresa
ALMA.ConteoDetalleEscaneo.IdEmpresa -> Nueva pertenencia obligatoria a empresa
ALMA.PlanConteoCiclico.IdEmpresa -> Nueva pertenencia obligatoria a empresa
ALMA.PeriodoConteo.IdEmpresa -> Nueva pertenencia obligatoria a empresa
ALMA.ResguardoDetalle.IdEmpresa -> Nueva pertenencia obligatoria a empresa
ALMA.ResguardoMovimiento.IdEmpresa -> Nueva pertenencia obligatoria a empresa
ALMA.InventarioDetalle.IdEmpresa -> Nueva pertenencia obligatoria a empresa
ORCO.OrdenCompraDetalle.IdEmpresa -> Nueva pertenencia obligatoria a empresa
ORCO.CotizacionDetalle.IdEmpresa -> Nueva pertenencia obligatoria a empresa
PBR.WorkflowTemplate.IdEmpresa -> Nueva pertenencia obligatoria a empresa
PBR.WorkflowEstado.IdEmpresa -> Nueva pertenencia obligatoria a empresa
PBR.WorkflowTransicion.IdEmpresa -> Nueva pertenencia obligatoria a empresa
PBR.AuditoriaCambio.IdEmpresa -> Nueva pertenencia obligatoria a empresa
SIS.EnvioWorkflow.IdEmpresa -> Nueva pertenencia obligatoria a empresa
SIS.Notificacion.IdEmpresa -> Nueva pertenencia obligatoria a empresa
SIS.NotificacionRegla.IdEmpresa -> Nueva pertenencia obligatoria a empresa
ALMA.Conteo.CantidadInventario -> decimal(20,4), alineado a ALMA.Almacen
ALMA.ConteoDetalle.Cantidad -> decimal(20,4), alineado a ALMA.Almacen
ALMA.PlanConteoCiclico.UQ_PlanConteoCiclico_TipoBien -> Unicidad rediseñada: IdProductoAlmacen
ALMA.CierreInventario.UQ_CierreInventario_EmpresaAnioBienMes -> Unicidad rediseñada: IdPartidaStock, FKIdAnio_SIS, Mes
ALMA.PeriodoConteo.UQ_PeriodoConteo_Codigo -> Unicidad rediseñada: IdAlmacen, CodigoPeriodo
PRES.Factura.FKIdContrato_PRES -> Ahora opcional en estructura nueva; vinculación contable por operación
PRES.Factura.FKIdPoliza_CONTA -> Ahora opcional en estructura nueva; vinculación contable por operación
PRES.FacturaDetalle.FKIdContratoDetalle_PRES -> Ahora opcional en estructura nueva; vinculación contable por operación
PRES.Cheque.FKIdCLC_PRES -> Ahora opcional en estructura nueva; vinculación contable por operación
PRES.Cheque.FKIdPoliza_CONTA -> Ahora opcional en estructura nueva; vinculación contable por operación
CONTA.Poliza.UQ_Poliza_Anio_Tipo_Clave -> Ahora incluye empresa
SIS.Documento.FkidEmpresaSis -> Obligatoria; protección de pertenencia documental
SIS.Proveedor.FKIdCuentaContable_SIS -> Trasladada a ProveedorEmpresa.IdCuentaContable para permitir proveedor compartido
ALMA.Resguardo.UQ_Resguardo_Folio -> Unicidad por empresa
ALMA.Bajas.UQ_Bajas_Folio -> Unicidad por empresa
ORCO.OrdenCompra.UQ_OrdenCompra_Numero -> Unicidad por empresa
ALMA.DetalleSolicitudSalida.IdEmpresa -> Contexto obligatorio por relación de negocio
ALMA.TipoBien.IdEmpresa -> Contexto obligatorio por relación de negocio
CONTA.CuentaEspecial.IdEmpresa -> Contexto obligatorio por relación de negocio
CONTA.MatrizConversion.IdEmpresa -> Contexto obligatorio por relación de negocio
CONTA.MatrizIngreso.IdEmpresa -> Contexto obligatorio por relación de negocio
CONTA.PolizaDetalle.IdEmpresa -> Contexto obligatorio por relación de negocio
ORCO.Cotizacion.IdEmpresa -> Contexto obligatorio por relación de negocio
ORCO.OrdenCompraPartida.IdEmpresa -> Contexto obligatorio por relación de negocio
PRES.EgreAdecuacionDetalle.IdEmpresa -> Contexto obligatorio por relación de negocio
PRES.IngreAdecuacion.IdEmpresa -> Contexto obligatorio por relación de negocio
PRES.IngreAdecuacionDetalle.IdEmpresa -> Contexto obligatorio por relación de negocio
PRES.IngresoAutorizado.IdEmpresa -> Contexto obligatorio por relación de negocio
PRES.RegresoChequeSuficienciaPoliza.IdEmpresa -> Contexto obligatorio por relación de negocio
SIS.DocumentoAnotacion.IdEmpresa -> Contexto obligatorio por relación de negocio
SIS.DocumentoEvento.IdEmpresa -> Contexto obligatorio por relación de negocio
SIS.NotificacionDestino.IdEmpresa -> Contexto obligatorio por relación de negocio

Cambios adicionales: las cabeceras identifican OperacionNegocio; Factura agrega proveedor, vencimiento y CFDI;
Documento exige empresa; responsables no dependen de RH; las FK y UQ compuestas protegen pertenencia.

*/

-- Archivo de comentarios; no contiene instrucciones de modificación.
