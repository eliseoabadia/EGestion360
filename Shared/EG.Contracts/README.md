# EG.Contracts

Contratos de intercambio compartidos por la API y el cliente Blazor.

## Reglas de dependencia

- Este proyecto solo contiene DTOs, solicitudes y respuestas serializables.
- No debe depender de SQL, Entity Framework, ASP.NET Core ni componentes de UI.
- Los namespaces `EG.Domain.DTOs.*` se conservan temporalmente para mantener compatibilidad de código fuente y evitar una migración masiva.
- Los cambios incompatibles deben publicarse en una nueva versión del endpoint; los cambios aditivos deben usar propiedades opcionales o valores predeterminados.

## Despliegue

- Un cambio interno del backend que no modifica contratos solo requiere publicar la API.
- Un cambio de interfaz o consumo del contrato requiere volver a publicar el Front.
- No se deben copiar DLLs manualmente dentro de una publicación Blazor; el proceso de `dotnet publish` genera el manifiesto, hashes y archivos comprimidos correspondientes.
