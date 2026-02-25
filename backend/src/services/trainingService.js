const env = require('../config/env');
const { pool } = require('../db/pool');
const mockData = require('../db/mockData');

function toTraining(row) {
  return {
    id: row.id,
    title: row.title,
    content: row.content,
    assignedDate: row.assigned_date || row.assignedDate,
  };
}

async function listTrainings() {
  if (env.useMockData) {
    return mockData.trainings;
  }

  const { rows } = await pool.query('SELECT id, title, content, assigned_date FROM trainings ORDER BY assigned_date DESC, id DESC;');
  return rows.map(toTraining);
}

module.exports = {
  listTrainings,
};
