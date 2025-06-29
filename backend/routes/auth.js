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
};

module.exports = authRoutes;
