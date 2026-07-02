# Asistente documental RAG - configuracion y despliegue

## Alcance implementado

- Vista Blazor: `/asistente-documental`.
- API: `api/DocumentRag`.
- Carga multiple de documentos por sesion.
- Extraccion e indexacion en memoria por sesion.
- Preguntas respondidas solo con fragmentos recuperados de los documentos cargados.
- Cuando no hay evidencia suficiente, responde que la informacion no esta en los documentos.
- Historial en front: documentos cargados, preguntas, respuestas y evidencias.
- Bitacora por `ILogger<DocumentRagAppService>`: sesion creada/liberada, documentos recibidos y preguntas procesadas.
- Liberacion de memoria por boton "Liberar memoria", al salir de la vista y por expiracion de sesion.

## Formatos

Indexables sin dependencias externas:

- `.txt`, `.csv`, `.md`
- `.docx`
- `.xlsx`
- `.pdf` con texto digital embebido

Cargables con condicion:

- `.png`, `.jpg`, `.jpeg`, `.webp`, `.tif`, `.tiff`, `.bmp`: requieren Tesseract OCR configurado para indexar texto.
- `.doc`, `.xls`: se aceptan como carga, pero se marcan como no soportados para indexacion. Convertir a `.docx` o `.xlsx`.
- PDF escaneado: requiere OCR previo o conversion a imagen + Tesseract.

## Backend appsettings

Se agrego la seccion `DocumentRag` en:

- `BackEnd/EG.ApiCoreBS/appsettings.json`
- `BackEnd/EG.ApiCoreBS/appsettings.Development.json`
- `BackEnd/EG.ApiCoreBS/appsettings.Production.json`

Valores clave:

```json
"DocumentRag": {
  "MaxFileSizeMB": 50,
  "MaxSessionDocuments": 12,
  "MaxSessionTotalMB": 150,
  "SessionTtlMinutes": 120,
  "ChunkSize": 1400,
  "ChunkOverlap": 180,
  "TopK": 6,
  "MinScore": 0.08,
  "AllowedExtensions": [ ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".txt", ".csv", ".md", ".png", ".jpg", ".jpeg", ".webp", ".tif", ".tiff", ".bmp" ],
  "TesseractExePath": "",
  "TesseractLanguage": "spa+eng",
  "TempPath": "C:/inetpub/wwwroot/GE_Back/RagTemp"
}
```

## OCR en servidor

Para que fotos y documentos escaneados puedan indexarse:

1. Instalar Tesseract OCR en el servidor.
2. Instalar paquetes de idioma `spa` y `eng`.
3. Configurar `DocumentRag:TesseractExePath`, por ejemplo:

```json
"TesseractExePath": "C:/Program Files/Tesseract-OCR/tesseract.exe"
```

4. Dar permisos de escritura al usuario de la app sobre `DocumentRag:TempPath`.

Si no se configura OCR, la app carga la imagen, avisa en front que requiere OCR y no inventa respuestas.

## Ruta de menu

La vista ya existe, pero para verla en el menu dinamico hay que registrar una opcion en la base de datos con ruta:

```text
/asistente-documental
```

Icono sugerido:

```text
QuestionAnswer
```

## Memoria

La indexacion vive en memoria del proceso API. No se guarda contenido ni embeddings en base de datos.

- El boton "Liberar memoria" elimina la sesion del diccionario interno.
- Al salir de la vista Blazor se intenta liberar la sesion.
- Si el usuario abandona la pagina sin llamada de cierre, el backend libera por TTL (`SessionTtlMinutes`).
- Al reiniciar el backend se pierden las sesiones activas.

Para una version persistente futura:

- Guardar documentos y chunks en tablas SQL.
- Agregar indice vectorial o full-text por empresa/modulo/entidad.
- Guardar preguntas/respuestas en una tabla de auditoria ademas de `ILogger`.

## Endpoints

- `POST api/DocumentRag/sessions`
- `GET api/DocumentRag/sessions/{sessionId}`
- `POST api/DocumentRag/documents`
- `POST api/DocumentRag/ask`
- `GET api/DocumentRag/sessions/{sessionId}/history`
- `DELETE api/DocumentRag/sessions/{sessionId}`

Todos requieren JWT.

## Nota operativa

La respuesta actual es extractiva: arma la respuesta con frases recuperadas de los documentos. Esto prioriza no inventar. Si se decide conectar un modelo LLM despues, mantener el mismo contrato y enviar al modelo solo los chunks citados, con una instruccion estricta de responder unicamente con ese contexto.

## Detonante IA - Contabilidad Polizas

Se agrego un flujo especifico en la vista:

```text
/Contabilidad/Polizas
```

El boton "Ayuda IA para subir una poliza" abre un dialogo que:

- Toma el usuario autenticado para auditoria (`UsuarioCreacion`).
- Toma la empresa seleccionada desde el estado del front y la refuerza con el claim `empresaId` del JWT cuando existe.
- Valida cuentas contables solo contra la empresa seleccionada.
- Analiza archivos `.xlsx`, `.csv` o `.txt`.
- Detecta columnas por alias: `Cuenta`, `Concepto/Descripcion`, `Debe/Cargo`, `Haber/Abono`, `Importe` + `Naturaleza`.
- Muestra preview antes de guardar: encabezado, detalle, total debe, total haber, diferencia y mensajes por fila.
- Bloquea la importacion si hay errores o si la poliza no esta cuadrada.
- Guarda encabezado y detalle en una transaccion. Si falla, hace rollback.
- Registra en `ILogger<PolizaService>` el preview y la importacion confirmada.

Endpoints:

- `POST api/Poliza/ai-import/preview`
- `POST api/Poliza/ai-import/confirm`

Formato minimo recomendado:

```text
Cuenta,Concepto,Debe,Haber
1110-001,Bancos,1000,0
4100-001,Ingreso por factura,0,1000
```

Campos de encabezado como anio, mes, tipo, clave y fecha se pueden tomar del dialogo; si el archivo trae columnas o pares clave/valor con esos nombres, tambien se intentan detectar.
