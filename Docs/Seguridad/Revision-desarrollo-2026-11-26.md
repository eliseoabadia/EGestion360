# Revisión de seguridad en desarrollo — 26 de noviembre de 2026

## Cambios aplicados

- La identidad sólo acepta identificadores enteros positivos completos. Claims de identidad malformados o contradictorios no se sustituyen por otro claim ni por el nombre mostrado.
- La empresa seleccionada se valida contra el acceso vigente del usuario. Una selección inválida o rechazada no se sustituye por la empresa del token. La empresa del token también requiere acceso vigente.
- Los claims de sucursal u otras relaciones no se interpretan como empresa.
- El acceso por sucursal exige que el usuario siga activo.
- La API valida el contexto antes de ejecutar los controladores. Las consultas genéricas propagan el rechazo de autorización, sin convertirlo en un resultado HTTP 200.
- La auditoría envuelve autenticación, autorización y el manejo de errores para observar también los rechazos tempranos. No almacena cuerpos ni parámetros de consulta.
- Las sesiones de asistencia documental ajenas devuelven un rechazo de autorización. Las preguntas y respuestas documentales dejan de escribirse en los registros.
- La exportación de reportes obtiene la identidad del contexto validado. Los mensajes nuevos se centralizan en EG.Common.
- Se conserva la exención de permisos por acción de SuperAdmin; no se elimina el aislamiento por empresa.

## Evidencia

Compilación de API y proyecto de pruebas: correcta. Pruebas seleccionadas: **108 correctas, 0 fallidas**. Incluyen identidad, empresa, permisos por acción, SuperAdmin, navegación propia, aislamiento de sesiones documentales, errores sanitizados, recuperación de contraseña, alcance de exportación y escrituras rechazadas sin persistencia.

Consultas directas contra la API local actualizada:

| Caso | Resultado esperado y observado |
|---|---:|
| Consulta sin sesión | 401 |
| Descarga sin sesión | 401 |
| Exportación sin sesión | 401 |
| Consulta con sesión y empresa válidas | 200 |
| Consulta con empresa no autorizada | 403 |
| Descarga con empresa no autorizada | 403 |
| Exportación con empresa no autorizada | 403 |
| Consulta con empresa malformada | 403 |
| Token vencido con firma válida | 401 |

Las consultas directas no crearon, actualizaron ni eliminaron registros de negocio. El token vencido se generó y utilizó únicamente en memoria; la evidencia sólo contiene nombres de escenarios y estados HTTP.

La revisión de 30 archivos de configuración versionados no detectó valores no vacíos en los campos sensibles examinados ni contraseñas en cadenas de conexión. Esto no equivale a un análisis del historial completo de Git. La auditoría de reglas de calidad existente terminó sin infracciones.

## Alcance

Validado en Development. Las pruebas de actores sin permiso utilizan identidades y persistencia simuladas; las consultas reales utilizaron la cuenta de desarrollo autorizada. No se cambiaron roles ni cuentas reales. Esta revisión no certifica todos los endpoints, procedimientos almacenados o escenarios de producción, ni sustituye una prueba de penetración independiente. No se desplegó ni se hicieron commits, push o respaldos.
