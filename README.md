# AS_New_InMotions

Prototipo móvil Flutter de **AS_New_InMotions**, app de salud mental y bienestar emocional para estudiantes UTB.

## Estado actual

Esta versión corresponde al **Paso 10: triaje emocional conectado al backend local**.

Incluye lo anterior:

- Autenticación conectada al backend local.
- Registro e inicio de sesión con correo institucional `@utb.edu.co`.
- Sesión local con token Bearer guardado en `SharedPreferences`.
- Perfil con imagen local.
- Registro emocional e historial conectados al backend local.
- Biblioteca de recursos local con filtros responsive y favoritos.
- Recordatorios locales funcionales.
- Headers superiores reducidos para que no sean invasivos.

Nuevo en este paso:

- El backend local ahora expone endpoints de triaje.
- Las 23 preguntas oficiales del triaje se cargan desde el backend.
- Flutter ya no calcula el resultado oficial del triaje por su cuenta cuando `useRemoteBackend = true`.
- El backend valida respuestas, calcula puntaje, define nivel y activa protocolo crítico.
- El backend guarda resultados por usuario autenticado en `backend/data/local-triage-results.json`.
- Si el nivel requiere derivación, el backend crea una derivación local en `backend/data/local-referrals.json`.
- La Biblioteca sigue usando una copia local del último resultado para recomendar recursos.

## Usuario de prueba

```text
Correo: estudiante@utb.edu.co
Contraseña: Test@12345
```

## Ejecutar backend local

En una terminal:

```bash
cd backend
npm run dev
```

Debe aparecer algo como:

```text
AS_New_InMotions backend local activo en http://localhost:3000/api
Módulos activos: auth + moods + triage
Usuario de prueba: estudiante@utb.edu.co / Test@12345
```

Puedes probar el backend en el navegador con:

```text
http://localhost:3000/api/health
```

## Ejecutar Flutter

En otra terminal, desde la raíz del proyecto Flutter:

```bash
flutter clean
flutter pub get
flutter run
```

## Modo backend/local

La app quedó conectada al backend local para autenticación, registro emocional y triaje:

```text
lib/core/constants/app_config.dart
useRemoteBackend = true
```

Si quieres volver al modo 100% local sin servidor, cambia:

```text
useRemoteBackend = false
```

## URLs configuradas

```text
Android emulator: http://10.0.2.2:3000/api
Windows/macOS/Linux/iOS simulator: http://localhost:3000/api
```

Si usas un celular físico, reemplaza temporalmente la URL por la IP local de tu PC, por ejemplo:

```text
http://192.168.1.20:3000/api
```

## Cómo comprobar el Paso 10 en la app

### 1. Verificar backend activo

Abre en el navegador:

```text
http://localhost:3000/api/health
```

Debe devolver que el backend está activo y mostrar módulos:

```text
auth
moods
triage
```

### 2. Probar login

Abre la app:

```text
Welcome → Login
```

Ingresa:

```text
estudiante@utb.edu.co
Test@12345
```

Debe entrar al Dashboard.

### 3. Probar carga de preguntas desde backend

Abre:

```text
Inicio → Triaje
```

Debe aparecer:

```text
23 ítems · Últimas dos semanas · Escala de 1 a 5.
```

Eso confirma que el flujo está usando el banco oficial configurado para el backend.

### 4. Probar resultado normal

Responde todas las preguntas con opciones bajas, por ejemplo `No me identifico` o `Poco`.

Debe pasar esto:

```text
- La app muestra el resultado.
- El puntaje se calcula desde el backend.
- Se crea o actualiza backend/data/local-triage-results.json.
```

### 5. Probar protocolo crítico

En alguna pregunta crítica:

```text
A5, F1 o F2
```

Selecciona:

```text
Bastante
```

o

```text
Totalmente
```

Debe pasar esto:

```text
- El resultado muestra nivel Crítico.
- El backend crea una derivación local.
- Se actualiza backend/data/local-referrals.json.
```

### 6. Probar Biblioteca recomendada

Después de hacer un triaje, abre:

```text
Menú inferior → Biblioteca
```

Debe mostrar recomendaciones relacionadas con el último resultado guardado.

## Próximo paso sugerido

**Paso 11: conectar biblioteca de recursos al backend local**.

Cambios previstos:

```text
- Crear endpoints /articles o /resources en el backend.
- Mover el catálogo de recursos al backend local.
- Consultar biblioteca desde API.
- Mantener favoritos localmente o crear favoritos por usuario en backend.
- Conservar filtros, búsqueda y detalle de recurso.
- Mantener recordatorios todavía en local.
```
