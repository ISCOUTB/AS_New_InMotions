const http = require('http');
const { host, port, apiPrefix } = require('./config/appConfig');
const { ensureDataFiles } = require('./storage/localDatabase');
const { router } = require('./routes/router');

ensureDataFiles();

const server = http.createServer(router);

server.listen(port, host, () => {
  console.log(`AS_New_InMotions backend local activo en http://localhost:${port}${apiPrefix}`);
  console.log('Modo: JSON local modularizado, listo para migrar a MongoDB/Cosmos DB');
  console.log('Usuario de prueba: estudiante@utb.edu.co / Test@12345');
});
