const authenticateToken = function (req, res, next) {
  const VALID_BEARER_TOKEN = process.env.BEARER_TOKEN || 'default_token';

  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token == null) {
    console.warn('Unauthorized: No token provided for /weather');
    return res
      .status(401)
      .send({ message: 'Unauthorized: No token provided.' });
  }

  if (token === VALID_BEARER_TOKEN) {
    next();
  } else {
    console.warn('Forbidden: Invalid token provided for /weather');
    return res.status(403).send({ message: 'Forbidden: Invalid token.' });
  }
};

module.exports = authenticateToken;
