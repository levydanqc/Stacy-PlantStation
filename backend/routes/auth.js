const bcrypt = require('bcrypt');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');

const database = require('../utilities/database.js');

const User = require('../models/User.js');

const authRoutes = (app) => {
  app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    const user = await database.getUserByEmail(email);
    if (!user) {
      console.error(`User not found for email: ${email}`);
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    try {
      const isMatch = await bcrypt.compare(password, user.password);

      if (!isMatch) {
        console.error(`Invalid password for user: ${email}`);
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      const uid = user.uid;
      const token = jwt.sign({ uid }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRES_IN,
      });

      console.log(`JWT token generated for user ${uid}: ${token}`);

      res.setHeader('auth_token', token);
      return res.status(200).json({ uid: user.uid });
    } catch (error) {
      console.error('Error creating session:', error);
      return res.status(500).json({ error: 'Error logging in' });
    }
  });

  app.post('/signup', async (req, res) => {
    const { email, password } = req.body;
    console.log('Received signup data:', req.body);

    const uid = crypto.randomBytes(8).toString('hex');

    if (!(await database.isUniqueEmail(email))) {
      console.error(`Email already exists: ${email}`);
      return res.status(409).json({ error: 'Email already exists' });
    }

    try {
      const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS, 10);
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      const userObject = User.fromObject({
        uid: uid,
        email: email,
        password: hashedPassword,
      });

      database.createUser(userObject).then((uid) => {
        if (!uid) {
          console.log('User creation failed');
          return res.status(500).send({ error: 'User creation failed' });
        }

        const token = jwt.sign({ uid }, process.env.JWT_SECRET, {
          expiresIn: process.env.JWT_EXPIRES_IN,
        });

        console.log(`User signed up successfully with UID: ${uid}`);
        console.log(`JWT token generated: ${token}`);

        res.setHeader('auth_token', token);
        return res.status(201).send({ uid: uid });
      });
    } catch (error) {
      console.error('Error hashing password:', error);
      return res
        .status(500)
        .json({ error: error.message || 'Internal server error' });
    }
  });

  app.post('/refresh', (req, res) => {
    const authHeader = req.headers['authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      console.warn('Unauthorized: No Authorization header provided');
      return res
        .status(401)
        .json({ error: 'Unauthorized: No Authorization header provided' });
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      console.warn('Unauthorized: Token missing');
      return res.status(401).json({ error: 'Token missing' });
    }

    const uid = req.headers['uid'];
    if (!uid || uid.length === 0) {
      console.warn('Unauthorized: No User-ID provided');
      return res
        .status(401)
        .json({ error: 'Unauthorized: No User-ID provided' });
    }

    database
      .getPlantByDeviceID(req.headers['device-id'])
      .then((plant) => {
        if (!plant) {
          console.error(
            'Plant not found for device ID:',
            req.headers['device-id']
          );
          return res.status(404).json({ error: 'Plant not found' });
        }

        jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
          if (err) {
            console.error('Token verification failed:', err);
            return res.status(403).json({ error: 'Token invalid or expired' });
          }

          console.log('Token verified successfully:', decoded);
          const newToken = jwt.sign({ uid }, process.env.JWT_SECRET, {
            expiresIn: process.env.JWT_EXPIRES_IN,
          });

          console.log(`New JWT token generated for user ${uid}: ${newToken}`);
          res.setHeader('auth_token', newToken);
          return res.status(200).json({ auth_token: newToken, uid: uid });
        });
      })
      .catch((error) => {
        console.error('Error retrieving plant by device ID:', error);
        return res.status(500).json({ error: 'Internal server error' });
      });
  });
};

module.exports = authRoutes;
