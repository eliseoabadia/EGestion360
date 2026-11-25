# Correo de recuperación en desarrollo

El remitente preparado es `eliseo.abadia@gmail.com`. El configurador solicita la dirección del portal y la contraseña de aplicación mediante entrada oculta. No envía mensajes ni modifica usuarios o contraseñas de EGestion360.

1. Crea una contraseña de aplicación llamada **EGestion360** en https://myaccount.google.com/apppasswords. Google requiere verificación en dos pasos; consulta https://support.google.com/accounts/answer/185833?hl=es si no aparece la opción.
2. Abre Windows PowerShell 5.1 o PowerShell 7 y ejecuta desde la carpeta del proyecto:

   ```powershell
   ./Tools/Configuration/Set-DevelopmentGmail.ps1
   ```

3. Introduce la dirección donde abres el portal, incluyendo su subcarpeta si existe. No uses la URL de Swagger o de la API. Se acepta HTTPS; HTTP sólo para localhost.
4. Pega la contraseña de aplicación cuando la solicite. No la pegues en el chat ni como argumento del comando.
5. Reinicia la API en **Development**. Desde **Olvidé mi contraseña**, solicita recuperación para una cuenta activa de prueba cuyo buzón controles.
6. Verifica la recepción y que el enlace abra el portal correcto. El titular debe introducir su nueva contraseña. Comprueba después que el enlace ya utilizado se rechace.

El configurador utiliza el `UserSecretsId` existente. La clave queda fuera del repositorio, en el almacén de desarrollo de .NET del usuario de Windows. Ese almacén **no cifra el archivo en disco**; no es un almacén para producción. Se conservan los demás secretos existentes. La clave no se pasa como argumento del proceso ni se crea un archivo temporal con ella.

IIS no utiliza automáticamente los secretos de desarrollo. Para ese destino se debe configurar el secreto en el entorno del servidor y establecer `PasswordReset:FrontendUrl` con la dirección pública real. No publiques la clave en `appsettings.json`, frontend o Git.

Si Google acepta la conexión, eso no demuestra que el mensaje llegue a la bandeja de entrada: revisa también spam. El mensaje público de recuperación es deliberadamente el mismo para cuentas existentes y desconocidas. Ante un error de red no se reenvía automáticamente.

Configuración SMTP utilizada: `smtp.gmail.com`, puerto `587` y STARTTLS. Referencia oficial: https://developers.google.com/workspace/gmail/imap/imap-smtp
