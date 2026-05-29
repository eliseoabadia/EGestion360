# Certificado HTTPS gratis para EGestion360

Este paquete prepara la emision de un certificado publico gratuito con Let's Encrypt para la API:

- IP: `74.208.88.178`
- Puerto API: `8440`
- Front: `https://74.208.88.178/login`

## Importante

Un certificado valido para internet no se puede generar offline. Debe emitirse desde el servidor publico, porque Let's Encrypt necesita validar que la IP responde desde internet.

Para certificados por IP, Let's Encrypt emite certificados de vida corta, normalmente de 6 dias. Por eso es obligatorio automatizar la renovacion.

## Requisitos en el servidor

1. Ejecutar PowerShell como administrador.
2. Tener abierto el puerto `80` desde internet durante la validacion.
3. Instalar Certbot 5.4 o superior.
4. Permitir que Certbot use temporalmente el puerto `80` si se usa modo `standalone`.

## Paso 1: prueba con staging

Ejecuta primero:

```powershell
.\01_EmitirCertificadoIP.ps1 -Email "tu-correo@dominio.com" -Staging
```

Si termina correctamente, emite el certificado real:

```powershell
.\01_EmitirCertificadoIP.ps1 -Email "tu-correo@dominio.com"
```

## Paso 2: instalar en IIS/API

Despues de emitir el certificado real:

```powershell
.\02_InstalarCertificadoIIS.ps1
```

El script exporta un `.pfx`, lo instala en `Cert:\LocalMachine\My` y crea o actualiza el binding HTTPS para `0.0.0.0:8440`.

## Renovacion

Como el certificado por IP dura pocos dias, deja una tarea programada ejecutando:

```powershell
.\03_RenovarCertificadoIP.ps1
```

Idealmente cada dia. Si usas un dominio en el futuro, el certificado puede durar mas y el mantenimiento sera mas simple.

