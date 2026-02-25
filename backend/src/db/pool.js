const { Pool } = require('pg');
const env = require('../config/env');

let pool;

if (!env.useMockData) {
  pool = new Pool({
    connectionString: env.databaseUrl,
  });
}

module.exports = { pool };
