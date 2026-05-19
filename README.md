# AS_New_InMotions

Prototipo móvil Flutter de **AS_New_InMotions**, app de salud mental y bienestar emocional para estudiantes UTB.

## Estado actual

Esta versión corresponde al **Paso 9: backend local para registro emocional e historial**.

Incluye lo anterior:

- Autenticación conectada al backend local.
- Registro e inicio de sesión con correo institucional `@utb.edu.co`.
- Sesión local con token Bearer guardado en `SharedPreferences`.
- Perfil con imagen local.
- Triaje emocional local con 23 ítems oficiales.
- Clasificación por niveles: Verde, Amarillo, Naranja, Rojo y Crítico.
- Biblioteca de recursos local con filtros responsive y favoritos.
- Recordatorios locales funcionales.
- Headers superiores reducidos para que no sean invasivos.

Nuevo en este paso:

- Se agregaron endpoints `/moods` al backend local.
- El backend guarda registros emocionales por usuario autenticado.
- Flutter ahora guarda el registro emocional mediante API.
- El Dashboard consulta el estado emocional de hoy desde el backend.
- El Historial consulta registros desde el backend.
- La eliminación de registros emocionales también se hace desde el backend.
- Las estadísticas semanales se calculan desde el backend local.
- La información se guarda temporalmente en `backend/data/local-moods.json`.

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
Módulos activos: auth + moods
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

La app quedó conectada al backend local para autenticación y registro emocional:

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

## Cómo comprobar el Paso 9 en la app

### 1. Verificar backend activo

Abre en el navegador:

```text
http://localhost:3000/api/health
```

Debe devolver que el backend está activo y mostrar módulos `auth` y `moods`.

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

### 3. Probar registro emocional con backend

Abre:

```text
Inicio → Registrar emoción
```

Guarda una emoción con nivel, etiquetas y nota.

Debe pasar esto:

```text
- Muestra mensaje de registro guardado.
- Regresa al Dashboard.
- El Dashboard muestra el estado emocional de hoy.
- El archivo backend/data/local-moods.json se crea o actualiza.
```

### 4. Probar historial desde backend

Abre:

```text
Menú inferior → Historial
```

Debe aparecer el registro que acabas de guardar.

### 5. Probar eliminación

En Historial:

```text
Toca un registro → Eliminar
```

Debe desaparecer de la app y también del archivo:

```text
backend/data/local-moods.json
```

### 6. Probar separación por usuario

Registra una cuenta nueva con otro correo `@utb.edu.co`, inicia sesión y abre Historial.

Debe pasar esto:

```text
- El usuario nuevo no ve los registros del usuario anterior.
- Cada registro queda asociado al usuario autenticado.
```

## Próximo paso sugerido

**Paso 10: conectar triaje emocional al backend local**.

Cambios previstos:

```text
- Crear endpoints /triage/questions y /triage/submit.
- Mover las 23 preguntas oficiales al backend local.
- Calcular puntaje oficial del triaje en el backend.
- Guardar resultados de triaje por usuario autenticado.
- Activar protocolo crítico en backend si A5, F1 o F2 tienen valor >= 4.
- Mantener biblioteca y recordatorios todavía en local.
```
