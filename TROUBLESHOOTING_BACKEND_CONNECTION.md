# 🔧 Guía de Troubleshooting - Conexión Frontend-Backend

## Problema: `TypeError: Failed to fetch` / `net::ERR_CONNECTION_REFUSED`

### ⚠️ Lo que significa:
El frontend **NO puede conectar al backend**. El backend no está escuchando en `http://localhost:5163/`

---

## ✅ Checklist de Solución

### **1. Verificar que el Backend está corriendo**

#### Opción A: Desde Visual Studio

1. **Abre el archivo**: `BackEnd\EG.ApiCore\Properties\launchSettings.json`
2. **Busca la sección `"http"`** (línea ~3-8)
3. **Verifica**: `"applicationUrl": "http://localhost:5163"`

4. **En Visual Studio**:
   - Haz clic derecho en `BackEnd\EG.ApiCore` (Solution Explorer)
   - Selecciona: **"Set as Startup Project"**
   - Selector de perfil (arriba): Elige **"http"** (NO HTTPS)
   - Presiona **F5** o **Ctrl+F5**

#### Opción B: Valida que está escuchando

Abre en el navegador:
```
http://localhost:5163/swagger
```

**Resultado esperado:**
- ✅ Ves la página Swagger UI
- ✅ Sin errores de conexión
- ✅ Lista de endpoints del API

**Resultado si falla:**
- ❌ Error "No se puede alcanzar este sitio"
- ❌ El backend NO está corriendo

---

### **2. Verificar configuración de puertos**

| Componente | Puerto | URL |
|-----------|--------|-----|
| **Backend API** (HTTP) | 5163 | `http://localhost:5163/` |
| **Backend API** (HTTPS) | 7143 | `https://localhost:7143/` |
| **Frontend Blazor** (HTTP) | 5242 | `http://localhost:5242/` |
| **Frontend Blazor** (HTTPS) | 7279 | `https://localhost:7279/` |

**El frontend debe usar HTTP (5163) para conectar al backend en desarrollo.**

---

### **3. Revisar configuración en archivos**

#### `FrontEnd\EG.Web\Program.cs` (línea ~37)
```csharp
builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri("http://localhost:5163/") });
```
✅ Debe apuntar a `http://localhost:5163/`

#### `BackEnd\EG.ApiCore\Program.cs` (CORS)
```csharp
policy.WithOrigins("https://localhost:7279", "http://localhost:5242")
```
✅ Debe permitir ambos orígenes del frontend

---

### **4. Reiniciar ambas aplicaciones**

1. Cierra Visual Studio completamente
2. Abre de nuevo
3. **Inicia Backend**:
   - Haz clic derecho en `BackEnd\EG.ApiCore` → **"Set as Startup Project"**
   - Elige perfil **"http"**
   - Presiona **F5**
   - Espera a que veas: `"Application started. Press Ctrl+C to shut down."`

4. **Inicia Frontend**:
   - Haz clic derecho en `FrontEnd\EG.Web` → **"Set as Startup Project"**
   - Presiona **F5**
   - Espera a que cargue en el navegador

---

### **5. Validar en la consola del navegador (F12)**

Abre **F12** → Pestaña **Console** → Limpia los logs

Intenta hacer login. Deberías ver:

```
LoginService: Intentando login en http://localhost:5163/api/Auth/Login/
LoginService: Login exitoso para usuario tu_email@example.com
GetSucursalesUsuarioAsync: Llamando a http://localhost:5163/api/UsuarioSucursal/usuario/1
GetSucursalesUsuarioAsync: Éxito. Se obtuvieron 3 sucursales
```

---

### **6. Validar en la pestaña Network (F12)**

1. Abre **F12** → Pestaña **Network**
2. Limpia los logs
3. Intenta hacer login
4. Busca la solicitud **`Login`**
   - Status debe ser: **200 OK** (verde)
   - Headers debe incluir: `Content-Type: application/json`
   - Response debe tener: `{ "payrollId": "...", "accessToken": "..." }`

---

## 🆘 Si aún hay problemas

### **Error: Port 5163 está en uso por otra aplicación**

```powershell
# En PowerShell, encuentra qué proceso está usando el puerto
Get-NetTCPConnection -LocalPort 5163 | Select-Object OwningProcess
```

Mata el proceso:
```powershell
Stop-Process -Id <PID> -Force
```

---

### **Error: El backend se crashea al iniciar**

1. Abre la **ventana Output** de Visual Studio
2. Busca los logs de error (en rojo)
3. Comparte el mensaje de error

**Posibles causas:**
- Base de datos no accesible
- Token JWT mal configurado
- Dependencias faltantes

---

### **Error: CORS bloqueando solicitud**

Si ves en la Console (F12):
```
Access to XMLHttpRequest at 'http://localhost:5163/api/...' from origin 'http://localhost:5242' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

**Solución:**
1. Verifica que `BackEnd\EG.ApiCore\Program.cs` tiene CORS configurado
2. Asegúrate de que `app.UseCors("AllowAllOrigins")` está **ANTES** de `app.UseAuthentication()`

---

## 📝 Resumen de cambios realizados

| Archivo | Cambio |
|---------|--------|
| `FrontEnd\EG.Web\Program.cs` | `BaseAddress = "http://localhost:5163/"` |
| `FrontEnd\EG.Web\Services\LoginService.cs` | Usa `_httpClient` inyectado + logging |
| `BackEnd\EG.ApiCore\Program.cs` | CORS permite `http://localhost:5242` |

---

## ✅ Estado esperado después de la solución

- ✅ Backend escuchando en `http://localhost:5163/`
- ✅ Frontend conecta correctamente
- ✅ Login funciona
- ✅ Se cargan las sucursales del usuario
- ✅ No hay errores de conexión ni CORS en F12
