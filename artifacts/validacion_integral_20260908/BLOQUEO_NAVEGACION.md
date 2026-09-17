# Bloqueo de navegación para la prueba integral

Fecha de comprobación: 8 de septiembre de 2026, 19:06, hora local.
Proyecto: EGestion360.

## Resultado
Las pruebas funcionales mediante navegación no han comenzado. El controlador falla antes de enumerar o abrir las pestañas. No hay evidencia de operaciones realizadas como usuario.

## Evidencia actual
- Se restableció la sesión del controlador y se volvió a intentar conectar.
- Error del controlador: node_repl kernel exited unexpectedly; windows sandbox failed: helper_unknown_error: apply deny-read ACLs.
- El registro también mantiene: deny ACE failed on C:\Desarrollo\Desarrollo\FullStack\EGestion360\.codex; SetNamedSecurityInfoW failed: 5.
- El error de lectura transitoria del estado ACL fue: EOF while parsing a value at line 1 column 0, en deny_read_acl_state.json. Una lectura posterior devolvió JSON válido; no se modificó ese archivo.
- El diagnóstico integrado de Codex 0.153.4 informa sandbox.helpers = fail, sandbox backend = elevated, sandbox provisioning = failed. Su recomendación es reparar o reinstalar Codex CLI desde una distribución aprobada.
- El token del proceso de herramientas informa Administrador=False. Esto no demuestra por sí solo cómo se abrió la aplicación de escritorio.

## Alcance conservado
Continuar pruebas reales mediante la interfaz, con la base existente y datos de prueba identificables. Cubrir año presupuestal, modificaciones de presupuesto, requisición, cotización, suficiencia, contrato, factura, cheque, pólizas y los pasos relacionados. Excluir catálogos. No repetir reindexado. No crear copias de la base ni scripts de prueba.

## Siguiente paso
Reparar la configuración del sandbox de Codex mediante sus mecanismos oficiales y verificar que el controlador pueda enumerar pestañas antes de iniciar las pruebas. No se han alterado permisos de seguridad para eludir el bloqueo.

Referencia: https://learn.chatgpt.com/docs/windows/windows-sandbox#troubleshooting-and-faq
