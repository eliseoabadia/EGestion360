# Certificado HTTPS para EGestion360

El ejecutable `EGestion360-Certificado.exe` emite, instala y renueva el certificado público de Let's Encrypt para:

- IP pública: `74.208.88.178`
- Frontend: puerto `443`
- API: puerto `8440`

## Uso recomendado

1. Copia `EGestion360-Certificado.exe` al servidor y déjalo en una ruta permanente.
2. Abre el ejecutable con doble clic.
3. Acepta la solicitud de permisos de administrador.
4. Escribe el correo que se registrará en Let's Encrypt.

También se puede ejecutar desde PowerShell o CMD:

```powershell
.\EGestion360-Certificado.exe --email "tu-correo@dominio.com"
```

El ejecutable es autónomo para Windows x64. No necesita instalar .NET, OpenSSL ni Certbot. Incluye el cliente ACME `lego` 5.3.1 y valida su SHA-256 antes de utilizarlo.

## Requisitos del servidor

- El puerto TCP `80` debe estar abierto desde internet y dirigido a este servidor durante la emisión y las renovaciones.
- Los puertos HTTPS `443` y `8440` deben estar publicados según corresponda.
- El ejecutable debe ejecutarse con permisos de administrador.

Let's Encrypt emite los certificados para direcciones IP con una vigencia aproximada de seis días. Por eso el ejecutable crea la tarea diaria `EGestion360 Renovar Certificado IP`.

La configuración, la cuenta ACME y las claves se guardan en:

```text
C:\ProgramData\EGestion360\CertificateRepair
```

El resultado detallado se guarda en `EGestion360-Certificado.log`, junto al ejecutable cuando la carpeta tiene permisos de escritura.

## Verificación

Al terminar, el ejecutable comprueba el thumbprint instalado en HTTP.sys y el certificado servido por los puertos configurados. También se puede verificar manualmente:

```powershell
Invoke-WebRequest "https://74.208.88.178/login" -UseBasicParsing
Invoke-WebRequest "https://74.208.88.178:8440/api/Navigate/ping" -UseBasicParsing
Get-ScheduledTaskInfo -TaskName "EGestion360 Renovar Certificado IP"
```

## Componente de terceros

El ejecutable incorpora `lego` 5.3.1, distribuido bajo licencia MIT:

- Proyecto: <https://github.com/go-acme/lego>
- Licencia incluida en `EGestion360.CertificateRepair\Assets\LEGO-LICENSE.txt`
