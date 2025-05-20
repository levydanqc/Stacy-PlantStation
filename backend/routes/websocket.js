const database = require('../utilities/database.js');

const webSocket = (wss, clients) => {
  wss.on('connection', (ws) => {
    console.log('Client connected via WebSocket');

    ws.on('message', (message) => {
      try {
        const parsedMessage = JSON.parse(message.toString());
        const userId = parsedMessage.userId; // Assuming the client sends { "userId": "someId" }
        console.log(`Received initial message from client: ${message}`);

        if (userId) {
          clients.add({ ws, userId });
          console.log(`Client associated with ID: ${userId}`);

          ws.off('message', arguments.callee);

          ws.send(JSON.stringify({ message: `Welcome, client ${userId}!` }));

          database
            .getDataByUserId(userId)
            .then((sensorData) => {
              ws.send(JSON.stringify(sensorData));
            })
            .catch((error) => {
              console.error(`Error fetching data for user ${userId}:`, error);
            });

          ws.on('message', (data) => {
            console.log(
              `Received data from client ${userId}: ${data.toString()}`
            );
          });
        } else {
          console.log('Client did not send userId in the first message.');
          ws.close();
        }
      } catch (error) {
        console.error('Error parsing initial message:', error);
        ws.close();
      }
    });

    ws.on('close', () => {
      console.log('Client disconnected');
      clients.delete(ws);
    });

    ws.on('error', (error) => {
      console.error('WebSocket error:', error);
      clients.delete(ws);
    });
  });
};

module.exports = webSocket;
