const dotenv = require('dotenv');

dotenv.config();

const env = {
  port: Number(process.env.PORT || 3001),
  databaseUrl: process.env.DATABASE_URL || '',
  jwtSecret: process.env.JWT_SECRET || 'dev-secret',
  useMockData: String(process.env.USE_MOCK_DATA || 'true').toLowerCase() === 'true',
};

module.exports = env;
