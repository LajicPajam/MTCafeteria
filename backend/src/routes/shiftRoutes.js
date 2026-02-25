const express = require('express');
const shiftController = require('../controllers/shiftController');
const { requireAuth } = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/shifts', requireAuth, shiftController.listShifts);

module.exports = router;
