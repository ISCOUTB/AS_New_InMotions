# Backend local — AS_New_InMotions

Este backend corresponde al **Paso 13**. Sigue usando almacenamiento local en archivos JSON, pero ahora está **modularizado** para que sea más fácil migrarlo luego a MongoDB, MongoDB Atlas o Azure Cosmos DB.

## Estructura nueva

```text
backend/src/
 ├── server.js
 ├── config/
 │   └── appConfig.js
 ├── routes/
 │   └── router.js
 ├── controllers/
 │   ├── authController.js
 │   ├── moodController.js
 │   ├── triageController.js
 │   ├── resourceController.js
 │   ├── reminderController.js
 │   └── healthController.js
 ├── middleware/
 │   └── auth.js
 ├── storage/
 │   ├── jsonStore.js
 │   └── localDatabase.js
 ├── catalogs/
 │   ├── triageQuestions.js
 │   ├── resourceCatalog.js
 │   └── reminderCatalog.js
 └── utils/
     ├── http.js
     ├── security.js
     ├── validators.js
     ├── presenters.js
     └── dateUtils.js
```

El archivo anterior quedó como respaldo en:

```text
backend/src/server.legacy.js
```

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

## Variables de entorno

Copia `.env.example` como `.env` si quieres modificar la configuración local.

```text
PORT=3000
HOST=0.0.0.0
API_PREFIX=/api
INSTITUTIONAL_DOMAIN=@utb.edu.co
PSYCHOLOGY_EMAIL=bienestar@utb.edu.co
TOKEN_SECRET=change-this-secret-before-production
```

## Usuario de prueba

```text
Correo: estudiante@utb.edu.co
Contraseña: Test@12345
```

## Datos locales

Se guardan temporalmente en:

```text
backend/data/local-users.json
backend/data/local-moods.json
backend/data/local-triage-results.json
backend/data/local-referrals.json
backend/data/local-resource-favorites.json
backend/data/local-reminders.json
backend/data/local-devices.json
```

Estos archivos no deben subirse a GitHub.

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

## Qué queda listo para el siguiente paso

La lógica ya está separada por capas. En el Paso 14 se puede crear una capa de repositorios de persistencia para cambiar de JSON local a MongoDB/Cosmos DB sin reescribir controladores ni pantallas Flutter.
