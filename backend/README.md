# Backend local inicial — AS_New_InMotions

Este backend corresponde al Paso 8. Es un servidor local sin base de datos en la nube.
Guarda usuarios temporalmente en un archivo JSON dentro de `backend/data/local-users.json`.

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
```

## Nota

Este backend todavía no usa MongoDB, Cosmos DB ni nube. Sirve para probar login y registro reales por API antes de conectar la base de datos.
