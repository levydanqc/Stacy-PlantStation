const broadcast = function (clients, data, client_id) {
  console.log(`Broadcasting data to ${clients.size} clients: ${data}`);
  if (clients.size === 0) {
    console.log('No clients connected to broadcast data to.');
    return;
  }

  clients.forEach((id, client) => {
    if (client.readyState === WebSocket.OPEN && client_id === id) {
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
    } else {
      clients.delete(client);
      console.log('Removed stale client connection during broadcast.');
    }
  });
};

module.exports = broadcast;
