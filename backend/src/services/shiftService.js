const env = require('../config/env');
const { pool } = require('../db/pool');
const mockData = require('../db/mockData');

async function listShiftsWithJobsAndTasks() {
  if (env.useMockData) {
    return mockData.shifts.map((shift) => {
      const shiftJobs = mockData.jobs
        .filter((job) => job.shiftId === shift.id)
        .map((job) => {
          const jobTasks = mockData.tasks.filter((task) => task.jobId === job.id);
          return {
            ...job,
            tasks: {
              setup: jobTasks.filter((t) => t.phase === 'Setup'),
              duringShift: jobTasks.filter((t) => t.phase === 'During Shift'),
              cleanup: jobTasks.filter((t) => t.phase === 'Cleanup'),
            },
          };
        });
      return {
        ...shift,
        jobs: shiftJobs,
      };
    });
  }

  const shiftRows = await pool.query('SELECT id, shift_type AS "shiftType", meal_type AS "mealType", name FROM shifts ORDER BY id;');
  const jobRows = await pool.query('SELECT id, shift_id AS "shiftId", name FROM jobs ORDER BY id;');
  const taskRows = await pool.query('SELECT id, job_id AS "jobId", phase, description FROM tasks ORDER BY id;');

  return shiftRows.rows.map((shift) => {
    const jobs = jobRows.rows.filter((job) => job.shiftId === shift.id).map((job) => {
      const jobTasks = taskRows.rows.filter((task) => task.jobId === job.id);
      return {
        ...job,
        tasks: {
          setup: jobTasks.filter((t) => t.phase === 'Setup'),
          duringShift: jobTasks.filter((t) => t.phase === 'During Shift'),
          cleanup: jobTasks.filter((t) => t.phase === 'Cleanup'),
        },
      };
    });
    return {
      ...shift,
      jobs,
    };
  });
}

module.exports = {
  listShiftsWithJobsAndTasks,
};
