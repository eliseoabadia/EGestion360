# OCR para documentos e imagenes

El asistente RAG indexa PDF con texto digital sin dependencia externa.

Para leer texto dentro de fotos e imagenes, el servidor debe tener Tesseract OCR. En produccion la API queda configurada para buscarlo en la instalacion estandar:

```text
C:/Program Files (x86)/Tesseract-OCR/tesseract.exe
```

La carpeta base debe contener:

- `tesseract.exe`
- La carpeta `tessdata`.
- `tessdata/eng.traineddata`.
- `tessdata/spa.traineddata` para OCR en espanol.

La configuracion aplicada es:

```json
"DocumentRag": {
  "TesseractExePath": "C:/Program Files (x86)/Tesseract-OCR/tesseract.exe",
  "TessdataPrefixPath": "C:/Program Files (x86)/Tesseract-OCR",
  "TesseractLanguage": "spa+eng"
}
```

Si `tesseract.exe` no existe, la aplicacion carga el archivo pero marca `OCR_REQUIRED` y no inventa contenido. Si falta `spa.traineddata` pero existe `eng.traineddata`, la app usa `eng` como respaldo para no bloquear la carga.
