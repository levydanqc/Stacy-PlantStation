const weatherRoutes = (app, fs) => {
  const dataPath = './data/weather.json';

  const readFile = (
    callback,
    returnJson = false,
    filePath = dataPath,
    encoding = 'utf8'
  ) => {
    fs.readFile(filePath, encoding, (err, data) => {
      if (err) {
        throw err;
      }

      callback(returnJson ? JSON.parse(data) : data);
    });
  };

  const writeFile = (
    fileData,
    callback,
    filePath = dataPath,
    encoding = 'utf8'
  ) => {
    fs.writeFile(filePath, fileData, encoding, (err) => {
      if (err) {
        throw err;
      }

      callback();
    });
  };

  // CREATE
  app.post('/weather', (req, res) => {
    // check if the request header has Authorization
    if (!req.headers.authorization || req.headers.authorization !== 'API_KEY') {
      console.log('Unauthorized');
      return res.status(401).send('Unauthorized');
    }
    readFile((data) => {
      console.log('req.body', req.body);
      const newUserId = Date.now().toString();

      // add the new user
      // data[newUserId.toString()] = req.body;

      // console.log('data', data);

      //   writeFile(JSON.stringify(data, null, 2), () => {
      //     res.status(200).send('new user added');
      //   });
    }, true);

    return res.status(200).send('good');
  });

  // READ
  app.get('/weather', (req, res) => {
    readFile((data) => {
      res.status(200).send(data);
    }, true);

    // send an update to a websocket client

    // use function
    createWebSocketClient(data);
  });
};

// Write a curl command to test the above API
// curl -X GET http://localhost:3001/weather

module.exports = weatherRoutes;
