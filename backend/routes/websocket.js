const database = require('../utilities/database.js');

const webSocket = (wss, clients) => {
  wss.on('connection', (ws) => {
    console.log('Client connected via WebSocket');

    ws.on('message', (message) => {
      try {
        const parsedMessage = JSON.parse(message.toString());
        const uid = parsedMessage.uid;
        console.log(`Received initial message from client: ${message}`);

        if (uid) {
          clients.add({ ws, uid });
          console.log(`Client associated with ID: ${uid}`);
          console.log(`Total clients connected: ${clients.size}`);

          ws.off('message', arguments.callee);

          database
            .getPlantsDataByUserUID(uid)
            .then((plants_data) => {
              ws.send(
                JSON.stringify({
                  type: 'initial_data',
                  plants: plants_data,
                })
              );
            })
            .catch((error) => {
              console.error(`Error fetching data for user ${uid}:`, error);
            });

          ws.on('message', (data) => {
            console.log(`Received data from client ${uid}: ${data.toString()}`);
          });
        } else {
          console.log('Client did not send uid in the first message.');
          ws.close();
        }
      } catch (error) {
        console.error('Error parsing initial message:', error);
        ws.close();
      }
    });

    ws.on('close', () => {
      console.log('Client disconnected');
      clients.forEach((client) => {
        if (client.ws === ws) {
          clients.delete(client);
        }
      });
    });

    ws.on('error', (error) => {
      console.error('WebSocket error:', error);
      clients.delete(ws);
    });
  });
};

module.exports = webSocket;
