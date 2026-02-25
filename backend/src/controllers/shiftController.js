const shiftService = require('../services/shiftService');

async function listShifts(req, res) {
  const shifts = await shiftService.listShiftsWithJobsAndTasks();
  return res.json(shifts);
}

module.exports = {
  listShifts,
};
