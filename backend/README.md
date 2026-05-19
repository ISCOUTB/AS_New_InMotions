# Backend local — AS_New_InMotions

Este backend corresponde al **Paso 12**. Es un servidor local sin base de datos en la nube.

Guarda datos temporalmente en archivos JSON dentro de `backend/data/`:

```text
data/local-users.json
data/local-moods.json
data/local-triage-results.json
data/local-referrals.json
data/local-resource-favorites.json
data/local-reminders.json
data/local-devices.json
```

Estos archivos se crean automáticamente al ejecutar el servidor y no deben subirse a GitHub.

## Requisitos

- Node.js instalado.

## Ejecutar

```bash
cd backend
npm run dev
```

Servidor por defecto:

```text
http://localhost:3000/api
```

## Usuario de prueba

```text
Correo: estudiante@utb.edu.co
Contraseña: Test@12345
```

## Endpoints incluidos

```text
GET  /api/health

POST /api/auth/register
POST /api/auth/login
GET  /api/auth/me
POST /api/auth/logout

POST   /api/moods
GET    /api/moods
GET    /api/moods/today
GET    /api/moods/stats/weekly
DELETE /api/moods/:id

GET  /api/triage/questions
POST /api/triage/submit
GET  /api/triage/results
GET  /api/referrals

GET    /api/articles
GET    /api/articles/categories
GET    /api/articles/favorites
GET    /api/articles/:id
POST   /api/articles/:id/favorite
DELETE /api/articles/:id/favorite

GET    /api/reminders
POST   /api/reminders
PUT    /api/reminders/:id
DELETE /api/reminders/:id
POST   /api/reminders/reset

POST   /api/devices/register
```

## Recordatorios locales

Los recordatorios se guardan por usuario autenticado. El backend crea recordatorios por defecto cuando un usuario entra por primera vez a `/api/reminders`.

Todavía no se envían notificaciones push reales. El endpoint `/api/devices/register` queda preparado para registrar tokens cuando se integre Firebase/FCM.

## Nota

Este backend todavía no usa MongoDB, Cosmos DB ni nube. Sirve para probar autenticación, registro emocional, historial, triaje, biblioteca y recordatorios mediante API antes de conectar la base de datos real.
