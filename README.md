# AS_New_InMotions

Prototipo móvil Flutter de **AS_New_InMotions**, app de salud mental y bienestar emocional para estudiantes UTB.

## Estado actual

Esta versión corresponde al **Paso 8: backend local inicial para autenticación**.

Incluye lo anterior:

- Autenticación local simulada.
- Validación de correo institucional `@utb.edu.co`.
- Sesión local con `SharedPreferences`.
- Registro emocional local funcional.
- Historial emocional local funcional.
- Triaje emocional local con 23 ítems oficiales.
- Clasificación por niveles: Verde, Amarillo, Naranja, Rojo y Crítico.
- Biblioteca de recursos local.
- Filtros responsive en biblioteca.
- Favoritos locales.
- Recordatorios locales funcionales.
- Perfil con imagen local.
- Headers superiores reducidos para que no sean invasivos.

Nuevo en este paso:

- Se agregó carpeta `backend/` con servidor local en Node.js.
- Se agregaron endpoints reales para registro, login, usuario actual y logout.
- El backend valida correo institucional `@utb.edu.co`.
- El backend cifra contraseñas con hash PBKDF2 usando `crypto` de Node.
- El backend genera token local tipo Bearer.
- Flutter ahora puede usar backend local para login y registro.
- Registro emocional, triaje, biblioteca, favoritos, recordatorios e imagen de perfil siguen funcionando localmente.

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

La app quedó conectada al backend local para autenticación:

```text
lib/core/constants/app_config.dart
useRemoteBackend = true
```

Si quieres volver a la autenticación 100% local sin servidor, cambia:

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

## Cómo comprobar el Paso 8 en la app

### 1. Verificar que el backend está activo

Abre en el navegador:

```text
http://localhost:3000/api/health
```

Debe devolver `Backend local activo`.

### 2. Probar login con backend

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

### 3. Probar registro con backend

Abre:

```text
Welcome → Registrarse
```

Crea un usuario con correo institucional diferente, por ejemplo:

```text
prueba.backend@utb.edu.co
```

Debe crear la cuenta y entrar al Dashboard.

### 4. Probar bloqueo de correo no institucional

Intenta registrarte con:

```text
usuario@gmail.com
```

Debe mostrar error por no usar `@utb.edu.co`.

### 5. Probar persistencia básica

Después de registrar un usuario nuevo, cierra la app y vuelve a iniciar sesión con ese usuario.
El backend guarda usuarios en:

```text
backend/data/local-users.json
```

Ese archivo es temporal y no debe subirse a GitHub.

## Próximo paso sugerido

**Paso 9: conectar backend local con registro emocional**.

Cambios previstos:

```text
- Agregar endpoints /moods al backend local.
- Guardar registros emocionales por usuario autenticado.
- Conectar Flutter para guardar emociones mediante API.
- Consultar historial emocional desde backend local.
- Mantener triaje, biblioteca y recordatorios todavía en modo local.
- Dejar preparada la migración posterior a MongoDB/Cosmos DB.
```
