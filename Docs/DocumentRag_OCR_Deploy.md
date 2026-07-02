# OCR para documentos e imagenes

El asistente RAG indexa PDF con texto digital sin dependencia externa.

Para leer texto dentro de fotos, imagenes y PDFs escaneados, el servidor debe tener Tesseract OCR. En produccion la API queda configurada para buscarlo en:

```text
C:/inetpub/wwwroot/GE_Back/DocOcr/tesseract.exe
```

Coloca en esa carpeta:

- `tesseract.exe`
- Las DLL/runtime que requiera la instalacion portable o instalada de Tesseract.
- La carpeta `tessdata` con al menos `spa.traineddata` y `eng.traineddata`.

La configuracion aplicada es:

```json
"DocumentRag": {
  "TesseractExePath": "C:/inetpub/wwwroot/GE_Back/DocOcr/tesseract.exe",
  "TesseractLanguage": "spa+eng"
}
```

Si `tesseract.exe` no existe, la aplicacion carga el archivo pero marca `OCR_REQUIRED` y no inventa contenido.
