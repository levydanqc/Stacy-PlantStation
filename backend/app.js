const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const ip = require('ip');
const dotenv = require('dotenv');
dotenv.config();

const PORT = 3001; // Or your preferred port
const ADDRESS = ip.address();

const app = express();
app.use(express.json());

const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const clients = new Set();

const routes = require('./routes/routes.js')(app, clients);
const webSocket = require('./routes/websocket.js')(wss, clients);

const database = require('./utilities/database.js');
database.connectDatabase();

// --- Start the HTTP Server ---
server.listen(PORT, () => {
  console.log(`HTTP server listening on port ${PORT} at ${ADDRESS}`);
  console.log(
    `ESP32 should send POST requests to http://${ADDRESS}:${PORT}/weather`
  );
  console.log(`Flutter app should connect to ws://${ADDRESS}:${PORT}`);
});

server.on('error', (error) => {
  console.error('Server error:', error);
});
