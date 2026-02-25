const bcrypt = require('bcryptjs');
const env = require('../config/env');
const { pool } = require('../db/pool');
const mockData = require('../db/mockData');

async function findUserByEmail(email) {
  if (env.useMockData) {
    const user = mockData.users.find((u) => u.email.toLowerCase() === email.toLowerCase());
    if (!user) return null;
    const role = mockData.roles.find((r) => r.id === user.roleId);
    return { ...user, roleName: role?.name };
  }

  const query = `
    SELECT u.id, u.email, u.password_hash AS "passwordHash", u.role_id AS "roleId", p.points, r.name AS "roleName"
    FROM users u
    JOIN roles r ON r.id = u.role_id
    LEFT JOIN points p ON p.user_id = u.id
    WHERE LOWER(u.email) = LOWER($1)
    LIMIT 1;
  `;
  const { rows } = await pool.query(query, [email]);
  return rows[0] || null;
}

async function validatePassword(inputPassword, passwordHash) {
  return bcrypt.compare(inputPassword, passwordHash);
}

module.exports = {
  findUserByEmail,
  validatePassword,
};
