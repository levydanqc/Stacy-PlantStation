const webSocket = (wss, clients) => {
  wss.on('connection', (ws) => {
    console.log('Client connected via WebSocket');

    ws.on('message', (message) => {
      try {
        const parsedMessage = JSON.parse(message.toString());
        const clientId = parsedMessage.clientId; // Assuming the client sends { "clientId": "someId" }
        console.log(`Received initial message from client: ${message}`);

        if (clientId) {
          clients.add({ ws, clientId });
          console.log(`Client associated with ID: ${clientId}`);

          // Remove the listener for the initial ID message, so subsequent messages are treated as data
          ws.off('message', arguments.callee);

          ws.send(JSON.stringify({ message: `Welcome, client ${clientId}!` }));

          // Now handle regular data messages from the client
          ws.on('message', (data) => {
            console.log(
              `Received data from client ${clientId}: ${data.toString()}`
            );
            // const parsedMessage = JSON.parse(data.toString());
            // if (parsedMessage.action === 'getData' && parsedMessage.client_id) {
            //   database
            //     .getDataByClient(parsedMessage.client_id)
            //     .then((data) => {
            //       ws.send(
            //         JSON.stringify({
            //           type: 'historicalData',
            //           client_id: parsedMessage.client_id,
            //           data: data,
            //         })
            //       );
            //     })
            //     .catch((err) => {
            //       console.error('Error fetching historical data:', err);
            //       ws.send(
            //         JSON.stringify({
            //           type: 'error',
            //           message: 'Could not fetch historical data.',
            //         })
            //       );
            //     });
            // }
          });
        } else {
          console.log('Client did not send clientId in the first message.');
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
