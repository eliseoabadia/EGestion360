# Firma Documental Inteligente

## Objetivo

El modulo de Firma Documental funciona como un hub ligero sobre Soporte Documental. No intenta meter toda la firma dentro de cada modulo; cada registro conserva sus documentos en Soporte Documental y Firma Documental agrega evidencia, proveedores y trazabilidad.

## Flujo principal

1. El usuario adjunta documentos soporte o genera un documento oficial desde el registro.
2. El usuario registra su certificado PFX si usara SAT/e.firma.
3. Para firmar, el sistema pide la contrasena del PFX en ese momento.
4. El sistema descifra temporalmente el PFX guardado en la boveda.
5. El proveedor `SAT_PFX` firma el hash SHA-256 del documento.
6. El sistema borra la llave de memoria y guarda evidencia de firma por documento, registro y usuario.

## Documento oficial para firma

La firma no debe aplicarse sobre cualquier adjunto del expediente. Para registros como polizas, el boton **Enviar a firma** genera primero el reporte oficial del sistema, lo guarda en Soporte Documental y lo marca como protegido.

Reglas:

- se genera desde el reporte oficial del registro,
- se guarda en Soporte Documental,
- queda arriba de los demas documentos,
- se etiqueta como `Oficial para firma`,
- no se puede eliminar desde soporte documental,
- la firma siempre apunta a ese documento oficial.

## Centro de control SAT/PFX

Ruta frontend:

```text
/firma-documental/control
```

Uso operativo:

1. El usuario decide usar SAT/e.firma.
2. Soporte tecnico acude con el usuario y genera el PFX en sitio.
3. En el centro de control se captura alias, archivo `.pfx` o `.p12` y contrasena.
4. El sistema valida el certificado y guarda el PFX cifrado en la boveda.
5. La contrasena no queda guardada.
6. Para firmar documentos, el sistema vuelve a pedir la contrasena.

Alcance actual:

- El PFX se registra para el usuario autenticado.
- Si soporte necesita cargar PFX para otro usuario sin iniciar sesion como ese usuario, falta agregar un endpoint administrado con permiso explicito y bitacora de soporte.
- La preferencia "este usuario firma por SAT por defecto" todavia no esta persistida; hoy se resuelve por proveedor elegido al firmar y por disponibilidad del certificado.

## Seguridad

- La contrasena del PFX no se almacena.
- El PFX se guarda cifrado con `FirmaDocumental:VaultKey`.
- Si no se configura `VaultKey`, el sistema usa llave efimera de proceso; sirve para demo, pero no para persistencia real.
- La evidencia guarda hash del documento, certificado, algoritmo, fecha UTC y usuario firmante.

## Proveedores

- `INTERNA`: firma operativa interna con usuario autenticado y hash documental.
- `SAT_PFX`: firma tecnica con PFX del usuario.
- `PROVEEDOR_PAGO`: adaptador reservado para proveedores comerciales.
- `OPEN_SOURCE_PDF`: adaptador reservado para estampado PDF local/open source.

## Endpoints

- `GET /api/FirmaDocumental/proveedores`
- `POST /api/FirmaDocumental/certificados`
- `GET /api/FirmaDocumental/certificados`
- `POST /api/FirmaDocumental/firmar`
- `POST /api/FirmaDocumental/firmas`

## Configuracion sugerida

```json
{
  "FirmaDocumental": {
    "VaultPath": "FirmaDocumental",
    "VaultKey": "cambiar-por-secreto-largo-en-produccion",
    "MaxCertificateSizeMB": 2,
    "AllowedCertificateExtensions": [ ".pfx", ".p12" ],
    "EnabledProviders": [ "SAT_PFX", "INTERNA" ]
  }
}
```

## RAG

El RAG no firma ni toca llaves privadas. Su papel comercial es inteligente:

- resumir documentos antes de firmar,
- detectar diferencias entre borrador y firmado,
- decir que documentos faltan por firma,
- responder preguntas del expediente,
- validar si un expediente esta listo para auditoria.

Mensaje de venta:

> Firma multimodal e inteligente: interna, SAT/e.firma, proveedores comerciales u opciones open source, con expediente digital, evidencia y consulta documental con IA.

## Flujo ejemplo: poliza contable

### 1. Captura de la poliza

El usuario crea una poliza desde Contabilidad con sus movimientos contables.

Datos base:

- Tipo de poliza
- Fecha contable
- Concepto
- Empresa
- Centro de costo / proyecto si aplica
- Cargos y abonos
- Documento origen: factura, contrato, orden de compra, pago, comprobante o evidencia

Estado inicial:

```text
BORRADOR
```

### 2. Validacion contable

Antes de permitir firma o autorizacion, el sistema valida:

- cargos y abonos cuadrados,
- cuenta contable activa,
- periodo contable abierto,
- empresa del usuario,
- documentos soporte requeridos,
- reglas fiscales/administrativas configuradas.

Si falta soporte documental, la poliza queda en:

```text
REQUIERE SOPORTE
```

### 3. Soporte documental y envio a firma

El usuario adjunta documentos a la poliza usando Soporte Documental.

Relacion sugerida:

```text
Modulo: Contabilidad
SubModulo: Polizas
Controlador: Poliza
EntidadId: PkidPoliza
```

Documentos posibles:

- PDF de factura
- XML de factura
- contrato
- orden de compra
- comprobante de pago
- evidencia interna
- documento de autorizacion

Cuando el usuario presiona **Enviar a firma**, el sistema:

1. genera el reporte `Report_Polizas`,
2. lo exporta a PDF,
3. lo guarda en Soporte Documental como documento oficial,
4. lo marca como protegido,
5. lo muestra arriba de los demas documentos,
6. lo deja listo para firma.

Este PDF no se puede borrar porque es la version oficial que sera firmada.

### 4. Revision inteligente con RAG

El RAG se usa como asistente de expediente antes de firmar.

Preguntas utiles:

- "Resume los documentos soporte de esta poliza"
- "Esta poliza tiene factura y comprobante de pago?"
- "Hay diferencias entre el importe de la factura y la poliza?"
- "Que documento justifica esta cuenta contable?"
- "El expediente esta listo para auditoria?"

Resultado esperado:

```text
LISTA PARA REVISION
```

o

```text
REQUIERE CORRECCION
```

### 5. Revision del responsable

El responsable contable revisa la poliza y decide:

- aprobar,
- rechazar,
- solicitar correccion,
- enviar a firma.

Estado:

```text
EN REVISION
```

### 6. Firma interna

Para control operativo, el jefe de contabilidad puede aplicar firma interna.

La firma interna guarda:

- usuario firmante,
- fecha UTC,
- hash SHA-256 del documento o representacion de la poliza,
- motivo,
- evidencia JSON.

Estado:

```text
FIRMADA INTERNAMENTE
```

### 7. Firma SAT/e.firma si aplica

Si la poliza requiere formalidad mayor, se usa `SAT_PFX`.

Flujo:

1. El usuario ya tiene PFX registrado en la boveda.
2. El sistema pide contrasena del PFX.
3. El sistema descifra temporalmente el PFX.
4. Firma el hash SHA-256 del documento de poliza.
5. Borra la llave de memoria.
6. Guarda evidencia de firma.

La contrasena nunca se guarda.

Estado:

```text
FIRMADA CON EFIRMA
```

### 8. Cierre de expediente

Cuando la poliza esta firmada y con soporte completo, queda cerrada para auditoria.

Estado final:

```text
EXPEDIENTE CERRADO
```

El expediente debe mostrar:

- poliza,
- movimientos contables,
- documentos soporte,
- firmas,
- hashes,
- bitacora de eventos,
- resultado de revision RAG,
- historial de autorizaciones.

### Flujo resumido

```text
BORRADOR
  -> REQUIERE SOPORTE
  -> LISTA PARA REVISION
  -> EN REVISION
  -> FIRMADA INTERNAMENTE
  -> FIRMADA CON EFIRMA
  -> EXPEDIENTE CERRADO
```

### Valor comercial

Este flujo convierte una poliza en un expediente contable auditable. La venta no es solo "capturar polizas"; es:

- control documental,
- evidencia de firma,
- trazabilidad,
- reduccion de riesgo,
- revision inteligente,
- expediente listo para auditoria.
