const database = require('../utilities/database');
const authenticateToken = require('../middleware/authenticateToken.js');

const sessionsRoutes = (app) => {
  app.post('/sessions', async (req, res) => {
    const { email, password } = req.body;

    try {
      const user = await database.getUserByEmail(email);
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      const isValid = await database.verifyUserPassword(user.user_id, password);
      if (!isValid) {
        return res.status(401).json({ error: 'Invalid password' });
      }

      res.status(200).json({ user_id: user.user_id });
    } catch (error) {
      console.error('Error creating session:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
};

module.exports = sessionsRoutes;
