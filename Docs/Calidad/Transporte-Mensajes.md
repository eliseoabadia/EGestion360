# Mensajes entre backend y frontend

Revisión: 26/11/2026.

Se corrigió BaseService, usado por los servicios CRUD, para conservar Success=false en respuestas HTTP 200. Antes la normalización podía convertir el rechazo en éxito. La variante que devuelve resultado y mensaje conserva ahora el rechazo y el mensaje del servidor en lugar de responder siempre «Operación exitosa».

Se conservan códigos de negocio y mensajes controlados; ApiResponse admite TraceId. Los mensajes de excepciones técnicas se sustituyen por una explicación controlada tanto en el cliente como en el filtro de resultados del backend, incluso para fallos reportados con HTTP 200. Los errores de validación estructurados en errors/Errors se resumen sin mostrar detalles técnicos. Una respuesta JSON ilegible no se convierte en un registro exitoso vacío. La espera agotada recomienda comprobar el resultado antes de repetir una operación.

Verificación: 17 casos nuevos del transporte usando el BaseService real con HTTP simulado; 376 pruebas totales correctas. Cubren rechazos con HTTP 200/400/409/422, contrato con mensaje, preservación de mensajes de éxito y TraceId, errores 401/403/404/429/502 sin JSON, excepciones técnicas, red, JSON inválido y validación por campo. Auditoría de calidad sin infracciones.

Alcance: se fortaleció el recorrido compartido. Esto no acredita una prueba visual individual de todos los formularios ni de los clientes especializados que usan HttpClient directamente. El middleware conserva el registro de excepciones inesperadas; cuando la respuesta ya comenzó no puede reemplazarla por otro JSON. No se promete ausencia absoluta de excepciones. No se hicieron cambios de datos, commits, push ni respaldos.
