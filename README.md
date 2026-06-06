# AS_New_InMotions

Prototipo móvil Flutter de **AS_New_InMotions**, app de salud mental y bienestar emocional para estudiantes UTB.

## Estado actual

Esta versión corresponde al **Paso 13: backend local modularizado y preparado para base de datos real**.

La app sigue funcionando igual para el usuario, pero el backend quedó mejor organizado internamente para que el siguiente paso sea migrar la persistencia a MongoDB/Cosmos DB sin reescribir toda la lógica.

Incluye lo anterior:

- Autenticación conectada al backend local.
- Registro e inicio de sesión con correo institucional `@utb.edu.co`.
- Sesión local con token Bearer guardado en `SharedPreferences`.
- Perfil con imagen local.
- Registro emocional e historial conectados al backend local.
- Triaje emocional conectado al backend local.
- Biblioteca de recursos conectada al backend local con búsqueda, filtros y favoritos por usuario.
- Recordatorios conectados al backend local.

Nuevo en este paso:

- Backend dividido en rutas, controladores, middleware, catálogos, utilidades y almacenamiento.
- `server.js` reducido a arranque del servidor.
- Archivo anterior guardado como `backend/src/server.legacy.js`.
- Configuración centralizada en `backend/src/config/appConfig.js`.
- Variables preparadas en `backend/.env.example`.
- Almacenamiento JSON local conservado como modo desarrollo.
- Estructura lista para crear repositorios de MongoDB/Cosmos DB en el siguiente paso.

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
Modo: JSON local modularizado, listo para migrar a MongoDB/Cosmos DB
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
