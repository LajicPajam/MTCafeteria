const trainingService = require('../services/trainingService');

async function listTrainings(req, res) {
  const trainings = await trainingService.listTrainings();
  const today = new Date().toISOString().slice(0, 10);

  return res.json({
    today,
    trainings,
    todaysTraining: trainings.find((training) => training.assignedDate === today) || null,
  });
}

module.exports = {
  listTrainings,
};
