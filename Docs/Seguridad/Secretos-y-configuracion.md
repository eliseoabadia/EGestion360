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

## Recuperación de contraseña

La pantalla `resetPassword` es pública y el acceso está disponible desde «Recuperar acceso» en el login. La API recibe `POST api/Auth/forgot-password` (correo) y `POST api/Auth/reset-password` (token, nueva contraseña y confirmación). El correo debe identificar una única cuenta vinculada a un usuario activo; una dirección duplicada no selecciona una cuenta arbitraria.

Configura `PasswordReset__FrontendUrl` con la URL HTTPS pública del frontend, incluida su subcarpeta si existe, y configura las credenciales SMTP en el servidor. Si falta la URL específica y CORS declara un único origen HTTPS, se usa ese origen autorizado. En desarrollo se utiliza el frontend HTTPS local existente. La URL del enlace procede de configuración del servidor, nunca de una dirección enviada por el navegador. La respuesta pública no confirma la existencia de una cuenta ni el resultado interno del SMTP; los fallos de configuración y envío quedan registrados sin contenido sensible. Si falta la configuración global de correo o una URL válida, la API devuelve HTTP 503 y la pantalla informa que la recuperación no está disponible, antes de consultar ninguna cuenta.

El enlace protegido vence en 30 minutos y lleva el token en el fragmento de URL para evitar enviarlo en registros HTTP. La actualización condicionada de contraseña y SecurityStamp invalida todos los enlaces pendientes y evita dos consumos simultáneos. Las contraseñas deben coincidir, tener entre 6 y 128 caracteres y ser diferentes a la anterior. Se conserva el cifrado de acceso heredado. No se cambia el esquema SQL ni los modelos generados.

En IIS conserva las claves de ASP.NET Core Data Protection con acceso exclusivo de la identidad del pool; si hay varias instancias, deben compartir el mismo almacén de claves y nombre de aplicación ya configurado. Perder las claves invalida enlaces pendientes. El cambio de SecurityStamp no revoca automáticamente los JWT existentes: éstos conservan su vencimiento actual.

La compilación y las pruebas de protección/expiración de tokens no sustituyen un recorrido de correo y SQL en un entorno autorizado. Para aceptación: solicitar correo, abrir enlace, guardar una contraseña diferente, iniciar sesión y comprobar rechazo al reutilizar el enlace o intentar dos cambios simultáneos. No se envían correos reales ni se modifica una cuenta real como parte de las pruebas locales.

## Rotación de valores expuestos

Los valores retirados ya estuvieron en commits anteriores. Borrarlos del estado actual no limpia el historial de Git. Rota la contraseña de SQL, la contraseña SMTP y la clave JWT expuestas; al cambiar la clave JWT, los tokens existentes dejarán de ser válidos y los usuarios deberán iniciar sesión de nuevo. No reescribas ni fuerces el historial compartido para ocultar una exposición: primero revoca y reemplaza los secretos.
