const jwt = require('jsonwebtoken');

const verifyToken = function (req, res, next) {
  const JWT_SECRET = process.env.JWT_SECRET;

  console.log('Trying to access protected route:', req.originalUrl);

  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    console.warn('Unauthorized: No Authorization header provided');
    return res
      .status(401)
      .json({ error: 'Unauthorized: No Authorization header provided' });
  }

  const token = authHeader.split(' ')[1];

  console.log('Received token:', token);

  if (!token) {
    console.warn('Unauthorized: Token missing');
    return res.status(401).json({ error: 'Token missing' });
  }

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      console.error('Token verification failed:', err);
      return res.status(403).json({ error: 'Token invalid or expired' });
    }

    console.log('Token verified successfully:', decoded);
    req.device = decoded;
    next();
  });
};

module.exports = verifyToken;
