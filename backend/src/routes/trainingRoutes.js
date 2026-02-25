const express = require('express');
const trainingController = require('../controllers/trainingController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');
const { TrainingRoles } = require('../config/roles');

const router = express.Router();

router.get('/trainings', requireAuth, requireRole(TrainingRoles), trainingController.listTrainings);

module.exports = router;
