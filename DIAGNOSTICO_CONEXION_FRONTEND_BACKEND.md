# 🔍 Diagnóstico: Problema Frontend-Backend

## Problemas Encontrados

### ❌ PROBLEMA 1: CORS Deshabilitado
**Ubicación**: `BackEnd\EG.ApiCore\Program.cs` línea ~120

**El código estaba comentado**:
```csharp
////CORS   // ← 4 BARRAS = COMENTADO!
builder.Services.AddCors(options => { ... });
```

**Consecuencia**: El backend **no permitía solicitudes CORS**, por lo que cualquier solicitud desde el frontend era bloqueada por el navegador.

---

### ❌ PROBLEMA 2: CORS solo permitía HTTPS
**Configuración anterior**:
```csharp
policy.WithOrigins("https://localhost:7279") // Solo HTTPS
```

**El problema**:
- Frontend envía solicitud desde: `http://localhost:5163/` (HTTP)
- Backend solo acepta: `https://localhost:7279` (HTTPS)
- **Origen NO coincide** → **Bloqueado por CORS**

---

### ❌ PROBLEMA 3: Puerto Backend incorrecto
El frontend intentaba conectar al puerto 5163 pero ese puerto no estaba en la lista blanca de CORS.

---

## ✅ Soluciones Aplicadas

### **Cambio 1: CORS Habilitado**
```csharp
// CORS Configuration
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAllOrigins", policy =>
    {
        policy.WithOrigins(
            "http://localhost:5242",      // Frontend dev HTTP ✓
            "https://localhost:7279",     // Frontend dev HTTPS ✓
            "http://localhost:5163"       // Backend local ✓
        )
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();  // Necesario para auth
    });
});
```

**Beneficio**: Ahora CORS está **activo** y permite **HTTP y HTTPS**.

---

## 📋 Configuración Correcta Ahora

### Backend (`BackEnd\EG.ApiCore`)
- **HTTP**: `http://localhost:5163/`
- **HTTPS**: `https://localhost:7143/`
- **CORS**: Permite `http://localhost:5242`, `https://localhost:7279`, `http://localhost:5163`

### Frontend (`FrontEnd\EG.Web`)
- **HTTP**: `http://localhost:5242/`
- **HTTPS**: `https://localhost:7279/`
- **HttpClient BaseAddress**: `http://localhost:5163/` (apunta al backend HTTP)

---

## 🚀 Pasos para Validar Que Funciona

### **Paso 1: Limpia el caché del navegador**
1. Abre **F12** (Developer Tools)
2. Pestaña **Application**
3. Selecciona **"Clear site data"**
4. ✓ Cookies and site data
5. ✓ Cache storage
6. Presiona **Clear**

### **Paso 2: Cierra Visual Studio completamente**
```powershell
taskkill /F /IM devenv.exe
```

### **Paso 3: Abre Visual Studio de nuevo**

### **Paso 4: Ejecuta el Backend primero**
1. Haz clic derecho en `BackEnd\EG.ApiCore`
2. **"Set as Startup Project"**
3. Selector de perfil: elige **"http"**
4. Presiona **F5**
5. Espera a ver: `"Application started"`

**Valida que esté respondiendo:**
```
Abre: http://localhost:5163/swagger
Deberías ver la página Swagger
```

### **Paso 5: Ejecuta el Frontend**
1. Haz clic derecho en `FrontEnd\EG.Web`
2. **"Set as Startup Project"**
3. Presiona **F5**

### **Paso 6: Abre F12 → Console y busca estos logs**

**Logs esperados**:
```
LoginService: Intentando login en http://localhost:5163/api/Auth/Login/
LoginService: Login exitoso para usuario [tu_email]
```

**Logs que NO deberías ver**:
```
ERR_HTTP2_PROTOCOL_ERROR
ERR_CONNECTION_REFUSED
Access denied (CORS error)
```

### **Paso 7: Valida en Network (F12)**
1. Abre pestaña **Network**
2. Intenta login
3. Busca solicitud **"Login"**
4. **Status**: debe ser **200 OK** (verde)
5. **Headers Response**: debe incluir CORS headers:
   ```
   Access-Control-Allow-Origin: http://localhost:5242
   Access-Control-Allow-Methods: GET, POST, PUT, DELETE
   Access-Control-Allow-Headers: ...
   ```

---

## 🎯 Resumen de Cambios Realizados

| Archivo | Cambio | Estado |
|---------|--------|--------|
| `BackEnd\EG.ApiCore\Program.cs` | CORS descommentado y configurado | ✅ Completo |
| `FrontEnd\EG.Web\Program.cs` | HttpClient BaseAddress = `http://localhost:5163/` | ✅ Completo |
| `FrontEnd\EG.Web\Services\LoginService.cs` | Usa `_httpClient` inyectado + logging | ✅ Completo |

---

## ⚠️ Si aún hay problemas

### **Síntoma: "ERR_CONNECTION_REFUSED"**
- El backend NO está corriendo en el puerto 5163
- **Solución**: Asegúrate de que está en el perfil "http"

### **Síntoma: "ERR_HTTP2_PROTOCOL_ERROR"**
- El puerto está respondiendo pero con protocolo incorrecto
- **Solución**: Verifica que es HTTP, no HTTPS

### **Síntoma: "CORS error - Access denied"**
- El header `Access-Control-Allow-Origin` no está en la respuesta
- **Solución**: Verifica que `app.UseCors("AllowAllOrigins")` está en Program.cs

### **Síntoma: Login funciona pero no carga sucursales**
- El endpoint `api/UsuarioSucursal/usuario/{id}` devuelve error
- **Solución**: Revisa si el token de autenticación es válido

---

## 📊 Flujo de Conexión Correcto

```
Frontend (http://localhost:5242)
    ↓
HttpClient (BaseAddress: http://localhost:5163/)
    ↓
Solicitud POST a: http://localhost:5163/api/Auth/Login/
    ↓
Backend recibe solicitud
    ↓
Backend verifica CORS: ¿origen es http://localhost:5242? ✓ SÍ
    ↓
Backend responde con headers CORS
    ↓
Navegador acepta respuesta
    ↓
Frontend procesa JSON y guarda token
    ✓ ¡ÉXITO!
```

