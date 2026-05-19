# AS_New_InMotions

Prototipo móvil Flutter de **AS_New_InMotions**, app de salud mental y bienestar emocional para estudiantes UTB.

## Estado actual

Esta versión corresponde al **Paso 12: recordatorios conectados al backend local**.

Incluye lo anterior:

- Autenticación conectada al backend local.
- Registro e inicio de sesión con correo institucional `@utb.edu.co`.
- Sesión local con token Bearer guardado en `SharedPreferences`.
- Perfil con imagen local.
- Registro emocional e historial conectados al backend local.
- Triaje emocional conectado al backend local.
- Biblioteca de recursos conectada al backend local con búsqueda, filtros y favoritos por usuario.
- Headers superiores reducidos para que no sean invasivos.

Nuevo en este paso:

- Recordatorios conectados al backend local.
- Crear recordatorio usando API.
- Editar recordatorio usando API.
- Activar/desactivar recordatorio usando API.
- Eliminar recordatorio usando API.
- Restaurar recordatorios por defecto usando API.
- Guardado por usuario autenticado en `backend/data/local-reminders.json`.
- Endpoint preparado para registrar token de dispositivo en `backend/data/local-devices.json`.

> Nota: todavía no hay notificaciones push reales. Este paso deja lista la lógica backend para recordatorios; Firebase/FCM queda para después.

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
Módulos activos: auth + moods + triage + resources + reminders
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

La app quedó conectada al backend local para autenticación, registro emocional, triaje, biblioteca y recordatorios:

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

## Cómo comprobar el Paso 12 en la app

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
resources
reminders
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

### 3. Probar recordatorios desde backend

Abre:

```text
Perfil → Recordatorios
```

Debe mostrar los recordatorios por defecto cargados desde el backend.

### 4. Crear recordatorio

En Recordatorios:

```text
Agregar recordatorio → Motivo → Hora → Días activos → Guardar
```

Debe aparecer en la lista y crear/actualizar:

```text
backend/data/local-reminders.json
```

### 5. Editar o activar/desactivar

En Recordatorios:

```text
Toca un recordatorio → cambia hora/días/motivo → Guardar
```

También prueba el switch de activo/inactivo. El cambio debe persistir al cerrar y abrir la app mientras el backend esté corriendo.

### 6. Eliminar y restaurar

En Recordatorios:

```text
Eliminar un recordatorio
Restaurar
```

Debe eliminarse o volver a la configuración por defecto desde el backend.

### 7. Probar separación por usuario

Crea otro usuario con correo `@utb.edu.co`, entra a Recordatorios y modifica uno. Luego vuelve al usuario de prueba. Cada usuario debe conservar sus propios recordatorios.

## Próximo paso sugerido

**Paso 13: preparación de persistencia real / capa de base de datos**.

Cambios previstos:

```text
- Crear una capa DB dentro del backend para no depender directamente de archivos JSON.
- Separar controladores, rutas y almacenamiento.
- Preparar variables de entorno para MongoDB o Cosmos DB.
- Mantener modo JSON local como respaldo de desarrollo.
- Dejar listo el backend para migrar usuarios, emociones, triaje, biblioteca, favoritos y recordatorios a base de datos real.
```
