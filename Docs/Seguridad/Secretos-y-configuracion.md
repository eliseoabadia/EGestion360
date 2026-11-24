# Secretos y configuración

Las cadenas de conexión, claves de firma y contraseñas no deben guardarse en `appsettings*.json`, archivos de despliegue ni en el control de versiones. Los campos sensibles de las configuraciones registradas quedaron vacíos; el servidor requiere que se suministren desde el entorno.

## Desarrollo local

La API y `EG.Builder` tienen identificadores de User Secrets. Configura los valores en el proyecto correspondiente desde una terminal local, usando tus propios datos:

```powershell
dotnet user-secrets set "ConnectionStrings:GestionEmpresarialConn" "<cadena local de SQL Server>" --project BackEnd/EG.ApiCoreBS/EG.ApiCoreBS.csproj
dotnet user-secrets set "JsonWebTokenKeys:IssuerSigningKey" "<clave local de al menos 32 bytes UTF-8>" --project BackEnd/EG.ApiCoreBS/EG.ApiCoreBS.csproj
dotnet user-secrets set "EmailSettings:Password" "<contraseña SMTP local>" --project BackEnd/EG.ApiCoreBS/EG.ApiCoreBS.csproj
dotnet user-secrets set "ConnectionStrings:GestionEmpresarialConn" "<cadena local de SQL Server>" --project EG.Builder/EG.Builder.csproj
```

Los valores de ejemplo entre `< >` son marcadores; sustitúyelos localmente. No los guardes en un archivo del repositorio ni los pegues en registros o capturas.

## Servidores y paquetes publicados

Inyecta los secretos desde el almacén del entorno o el gestor de secretos del servidor:

- `ConnectionStrings__GestionEmpresarialConn`
- `JsonWebTokenKeys__IssuerSigningKey` (mínimo 32 bytes UTF-8)
- `EmailSettings__Password`
- `CorsSettings__AllowOrigins__0` y los índices siguientes para los orígenes HTTPS autorizados

Fuera de `Development`, la API rechaza el arranque si no hay una cadena de conexión, una clave de firma válida o una lista explícita de orígenes CORS. No habilites `*` en producción.

## Rotación

Los valores retirados ya estuvieron en commits anteriores. Borrarlos del estado actual no limpia el historial de Git. Rota la contraseña de SQL, la contraseña SMTP y la clave JWT expuestas; al cambiar la clave JWT, los tokens existentes dejarán de ser válidos y los usuarios deberán iniciar sesión de nuevo. No reescribas ni fuerces el historial compartido para ocultar una exposición: primero revoca y reemplaza los secretos.
