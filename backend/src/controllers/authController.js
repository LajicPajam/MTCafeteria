const jwt = require('jsonwebtoken');
const env = require('../config/env');
const authService = require('../services/authService');

async function login(req, res) {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  const user = await authService.findUserByEmail(email);
  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials.' });
  }

  const isValid = await authService.validatePassword(password, user.passwordHash);
  if (!isValid) {
    return res.status(401).json({ message: 'Invalid credentials.' });
  }

  const token = jwt.sign(
    {
      sub: user.id,
      email: user.email,
      role: user.roleName,
    },
    env.jwtSecret,
    { expiresIn: '8h' }
  );

  return res.json({
    token,
    user: {
      id: user.id,
      email: user.email,
      role: user.roleName,
      points: user.points || 0,
    },
  });
}

module.exports = {
  login,
};
