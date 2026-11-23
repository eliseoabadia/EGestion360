# Generador interno de licencias GE360

Este ejecutable se usa únicamente en el equipo de GE360. No se incluye en los ZIP del cliente ni en IIS.

## Primera configuración

```powershell
dotnet run --project Tools/LicensingGenerator/GE360.Licensing.Generator.csproj -- init-key --kid 2026-01
```

El comando crea el certificado de firma en el almacén de certificados del usuario actual. La clave privada no se exporta. La clave pública que muestra debe quedar integrada en `TrustedLicenseKeys.cs` antes de publicar el backend.

## Emitir una licencia

La instalación genera `solicitud.json`. Prepare un contrato, por ejemplo:

```json
{
  "licenseId": "00000000-0000-0000-0000-000000000000",
  "serial": 1,
  "modules": [
    {
      "code": "GRP.ALMA",
      "startsAtUtc": "2026-09-12T18:00:00Z",
      "endsAtUtc": "2026-10-12T18:00:00Z"
    }
  ]
}
```

Después ejecute:

```powershell
dotnet run --project Tools/LicensingGenerator/GE360.Licensing.Generator.csproj -- issue --request solicitud.json --contract contrato.json --out cliente.lic
```

Cada nueva licencia de la misma instalación debe usar un serial mayor. Para contratos revocables siempre capture `endsAtUtc`.

Los archivos de `Samples` sirven sólo para comprobar el formato. Para emitir al cliente use siempre la solicitud copiada desde su propia instalación y lleve el serial consecutivo en el control comercial de GE360.
