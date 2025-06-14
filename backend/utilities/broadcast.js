const broadcast = function (clients, data, user_id) {
  console.log(`Broadcasting data to ${clients.size} clients: ${data}`);
  if (clients.size === 0) {
    console.log('No clients connected to broadcast data to.');
    return;
  }

  clients.forEach(({ ws: client, userId: id }) => {
    console.log(`Client ID: ${id}`);
    if (client.readyState === WebSocket.OPEN && user_id === id) {
      try {
        client.send(data);
        console.log(`Sent data to client ${id}: ${data}`);
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
