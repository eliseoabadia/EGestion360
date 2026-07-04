# Pruebas de estres EGestion360

Este flujo sirve para encontrar endpoints lentos, errores bajo concurrencia y crecimiento de memoria.

## 1. Preparar ambiente

1. Levanta la API en Release:

```powershell
dotnet run --project BackEnd\EG.ApiCoreBS\EG.ApiCoreBS.csproj -c Release --urls http://localhost:5058
```

2. Para endpoints autenticados, inicia sesion en el frontend y copia el JWT desde `localStorage.authToken`.
3. Si no tienes k6 instalado, usa el runner local incluido en `Tools\StressTest\EgestionStressRunner`.

## 2. Prueba base

Sin token, para medir capacidad base de API/middleware:

```powershell
powershell -ExecutionPolicy Bypass -File Tools\StressTest\egestion-stress.ps1 `
  -BaseUrl http://localhost:5058 `
  -Endpoint /api/Navigate/ping `
  -TotalRequests 1000 `
  -Concurrency 50
```

Con token, para medir una pantalla real:

```powershell
powershell -ExecutionPolicy Bypass -File Tools\StressTest\egestion-stress.ps1 `
  -BaseUrl http://localhost:5058 `
  -Endpoint /api/Empresa/GetAllPaginado `
  -TotalRequests 1000 `
  -Concurrency 50 `
  -Token "pega_aqui_el_token"
```

Si tienes k6 instalado:

```powershell
$env:BASE_URL="http://localhost:5058"
$env:TOKEN="pega_aqui_el_token"
$env:ENDPOINT="/api/Empresa/GetAllPaginado"
$env:VUS="20"
$env:DURATION="2m"
k6 run Tools\StressTest\egestion-stress.k6.js
```

## 3. Subir carga gradualmente

Ejecuta la misma prueba con concurrencia `20`, `50`, `100` y `200`. No subas al siguiente nivel si ya ves:

- `http_req_failed` mayor a 2%.
- `p(95)` arriba de 1000 ms en endpoints CRUD normales.
- CPU sostenido arriba de 80%.
- memoria del proceso creciendo sin bajar tras terminar la prueba.
- errores 401/403 no esperados, 500 o timeouts SQL.

## 4. Medir memoria y runtime .NET

En otra terminal:

```powershell
dotnet-counters monitor --process-id <PID_API> System.Runtime Microsoft.AspNetCore.Hosting
```

Observa especialmente:

- `GC Heap Size`
- `Gen 2 GC Count`
- `ThreadPool Queue Length`
- `Requests / sec`
- `Current Requests`

## 5. Probar endpoints especificos

```powershell
powershell -ExecutionPolicy Bypass -File Tools\StressTest\egestion-stress.ps1 `
  -BaseUrl http://localhost:5058 `
  -Endpoint /api/Usuario/GetAllPaginado `
  -TotalRequests 2000 `
  -Concurrency 100 `
  -Token "pega_aqui_el_token"
```

Prioriza pantallas pesadas: usuarios, menu, presupuesto, requisiciones, ordenes de compra, polizas, nomina y reportes.
