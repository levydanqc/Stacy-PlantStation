const broadcast = function (clients, data, user_uid) {
  const WebSocket = require('ws');

  console.log(`Broadcasting data to ${clients.size} clients: ${data}`);
  if (clients.size === 0) {
    console.log('No clients connected to broadcast data to.');
    return;
  }

  clients.forEach(({ ws: client, uid }) => {
    console.log(`Client ID: ${uid}`);
    if (client.readyState === WebSocket.OPEN && user_uid === uid) {
      try {
        client.send(data);
        console.log(`Sent data to client ${uid}: ${data}`);
      } catch (error) {
        console.error(
          'Failed to send message to a client during broadcast:',
          error
        );
        clients.delete(client);
      }
    }
  });
};

module.exports = broadcast;
