# Backend local — AS_New_InMotions

Este backend corresponde al **Paso 10**. Es un servidor local sin base de datos en la nube.

Guarda datos temporalmente en archivos JSON dentro de `backend/data/`:

```text
data/local-users.json
data/local-moods.json
data/local-triage-results.json
data/local-referrals.json
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
```

## Triaje local

El triaje usa las 23 preguntas oficiales del anexo técnico. El backend valida que todas las preguntas estén respondidas, calcula el puntaje, asigna el nivel y activa protocolo crítico si A5, F1 o F2 tienen respuesta con puntaje mayor o igual a 4.

Niveles:

```text
23–45   Verde
46–70   Amarillo
71–95   Naranja
96–115  Rojo
Crítico si A5, F1 o F2 >= 4
```

## Nota

Este backend todavía no usa MongoDB, Cosmos DB ni nube. Sirve para probar autenticación, registro emocional, historial y triaje mediante API antes de conectar la base de datos real.
