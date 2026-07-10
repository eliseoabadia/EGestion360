# Estructura modular EGestion360

Esta guia deja la convencion base para que nuevas vistas, servicios, contratos, controladores y flujos RAG crezcan en carpetas previsibles.

Las reglas operativas de alineacion con el menu, respuesta al usuario, Logger y `GenericTable` se detallan en [Reglas_Estructura_Respuesta_Logger_GenericTable.md](Reglas_Estructura_Respuesta_Logger_GenericTable.md).

## Principio

Separar por pertenencia funcional antes que por tipo tecnico aislado:

- `Modules`: funcionalidad de negocio por modulo del sistema.
- `Platform`: capacidades transversales de la plataforma.
- `Shared`: utilidades, componentes o helpers reutilizables sin dependencia directa de un modulo.

## FrontEnd

```text
FrontEnd/EG.Web
  Pages
    Modules
      GRP
        Contabilidad
    Platform
      DocumentRag
    Shared
      SoporteDocumental
  Contracts
    Modules
      GRP
        Contabilidad
    Platform
      DocumentRag
      SoporteDocumental
  Models
    Platform
      DocumentRag
      SoporteDocumental
  Services
    Modules
      GRP
        Contabilidad
    Platform
      DocumentRag
      SoporteDocumental
    Shared
```

Reglas:

- Una pagina de negocio vive en `Pages/Modules/{Modulo}/{Area}`.
- Una pagina transversal vive en `Pages/Platform/{Feature}`.
- Un componente reutilizable vive en `Pages/Shared/{Feature}` o `Components/Shared`.
- Los contratos y servicios deben repetir la misma pertenencia que la pagina o feature.
- Helpers de infraestructura de front van en `Services/Shared`.

## BackEnd

```text
BackEnd/EG.ApiCoreBS
  Controllers
    Modules
      GRP
        Contabilidad
    Platform
      DocumentRag
      SoporteDocumental

BackEnd/EG.Application
  Modules
    GRP
      Interfaces
      Services
  Platform
    Interfaces
    Services

BackEnd/EG.Domain
  Modules
    GRP
      DTOs
  Platform
    DTOs
    Settings
```

Reglas:

- Controladores de negocio: `Controllers/Modules/{Modulo}/{Area}`.
- Controladores transversales: `Controllers/Platform/{Feature}`.
- Servicios de negocio: `Application/Modules/{Modulo}/Services/{Area}`.
- Servicios transversales: `Application/Platform/Services/{Feature}`.
- DTOs de negocio: `Domain/Modules/{Modulo}/DTOs`.
- DTOs/settings transversales: `Domain/Platform`.

## RAG documental

El RAG documental se considera feature de plataforma:

```text
BackEnd/EG.ApiCoreBS/Controllers/Platform/DocumentRag
BackEnd/EG.Application/Platform/Interfaces/DocumentRag
BackEnd/EG.Application/Platform/Services/DocumentRag
BackEnd/EG.Domain/Platform/DTOs/Requests/DocumentRag
BackEnd/EG.Domain/Platform/DTOs/Responses/DocumentRag
BackEnd/EG.Domain/Platform/Settings

FrontEnd/EG.Web/Pages/Platform/DocumentRag
FrontEnd/EG.Web/Contracts/Platform/DocumentRag
FrontEnd/EG.Web/Models/Platform/DocumentRag
FrontEnd/EG.Web/Services/Platform/DocumentRag
```

Si despues se crea un RAG especifico de negocio, por ejemplo Contabilidad, debe vivir bajo `Modules/GRP/Contabilidad` y consumir helpers o servicios comunes del RAG de plataforma cuando aplique.

## Evitar duplicacion

- El armado de uploads multipart en front debe usar `Services/Shared/MultipartApiHelper.cs`.
- Si dos servicios repiten validacion, parsing o envio HTTP, extraer helper/shared service antes de copiar.
- Las reglas de negocio deben vivir en Application, no en Razor.
- Razor puede ayudar a resolver interaccion de usuario, pero la validacion final debe repetirse en backend antes de guardar.
