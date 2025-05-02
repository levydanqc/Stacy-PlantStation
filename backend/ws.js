// Import required modules
const express = require('express');
const http = require('http');
const WebSocket = require('ws');

// --- Configuration ---
const PORT = 3001;

// --- Initialize Express App & HTTP Server ---
const app = express();
// Middleware to parse JSON request bodies (important for receiving ESP32 data)
app.use(express.json());
// Create an HTTP server using the Express app
const server = http.createServer(app);

// --- Initialize WebSocket Server ---
// Attach the WebSocket server to the *same* HTTP server instance
// or create a separate one if needed (using the same instance is common)
const wss = new WebSocket.Server({ server }); // Attach to the existing server

// --- Store Connected Clients ---
// Use a Set for efficient adding/removing of clients
const clients = new Set();
let lastReceivedData = null; // Store the last received weather data

// --- WebSocket Server Logic ---
wss.on('connection', (ws) => {
  console.log('Client connected via WebSocket');
  clients.add(ws); // Add new client to the set

  // Optional: Send the *last known* weather data immediately upon connection
  if (lastReceivedData) {
    try {
      ws.send(JSON.stringify(lastReceivedData));
      console.log('Sent last known data to newly connected client.');
    } catch (error) {
      console.error('Failed to send last known data to new client:', error);
    }
  }

  // Handle messages received *from* a client (optional, not needed for this use case)
  ws.on('message', (message) => {
    console.log('Received message from client:', message);
    // You could add logic here if clients need to send data back
  });

  // Handle client disconnection
  ws.on('close', () => {
    console.log('Client disconnected');
    clients.delete(ws); // Remove client from the set
  });

  // Handle WebSocket errors
  ws.on('error', (error) => {
    console.error('WebSocket error:', error);
    clients.delete(ws); // Remove client on error as well
  });
});

console.log(`WebSocket server started and attached to HTTP server`);

// --- HTTP Server Logic (Endpoint for ESP32) ---
// Define the POST endpoint that the ESP32 will send data to
app.post('/weather', (req, res) => {
  if (!req.headers.authorization || req.headers.authorization !== 'API_KEY') {
    console.log('Unauthorized');
    return res.status(401).send('Unauthorized');
  }

  // The parsed JSON data from ESP32 is in req.body
  const weatherData = req.body;

  if (!weatherData || typeof weatherData !== 'object') {
    console.error('Received invalid data format.');
    return res
      .status(400)
      .send({ message: 'Invalid data format. JSON expected.' });
  }

  console.log('Data received:', JSON.stringify(weatherData));

  // Store the latest data
  lastReceivedData = weatherData;

  // Broadcast the received data to all connected WebSocket clients
  broadcast(JSON.stringify(weatherData));

  // Send a success response back to the ESP32
  res.status(200).send({ message: 'Data received successfully' });
});

// --- Broadcast Function ---
// Sends a message to all currently connected WebSocket clients
function broadcast(data) {
  console.log(`Broadcasting data to ${clients.size} clients: ${data}`);
  clients.forEach((client) => {
    // Check if the client connection is still open
    if (client.readyState === WebSocket.OPEN) {
      try {
        client.send(data); // Send the data (usually as a string)
      } catch (error) {
        console.error('Failed to send message to a client:', error);
        // Optional: Remove problematic client
        clients.delete(client);
      }
    } else {
      // Optional: Clean up clients that are no longer open
      clients.delete(client);
      console.log('Removed stale client connection during broadcast.');
    }
  });
}

// --- Start the HTTP Server ---
// Note: The WebSocket server (wss) is already attached and runs with this server.
server.listen(PORT, () => {
  console.log(`HTTP server listening on port ${PORT}`);
  console.log(`WebSocket connections expected on the same port/path`);
  console.log(
    `ESP32 should send POST requests to http://<YOUR_SERVER_IP>:${PORT}/weather`
  );
  console.log(`Flutter app should connect to ws://<YOUR_SERVER_IP>:${PORT}`);
});

// Basic error handling for the server itself
server.on('error', (error) => {
  console.error('Server error:', error);
});
