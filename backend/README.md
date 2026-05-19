# Backend local — AS_New_InMotions

Este backend corresponde al **Paso 9**. Es un servidor local sin base de datos en la nube.

Guarda datos temporalmente en archivos JSON dentro de `backend/data/`:

```text
data/local-users.json
data/local-moods.json
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
```

## Nota

Este backend todavía no usa MongoDB, Cosmos DB ni nube. Sirve para probar autenticación, registro emocional e historial mediante API antes de conectar la base de datos real.
