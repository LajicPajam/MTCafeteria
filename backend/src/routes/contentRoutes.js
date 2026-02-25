const express = require('express');
const contentController = require('../controllers/contentController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');
const { AdminLandingRoles } = require('../config/roles');

const router = express.Router();

router.get('/landing-items', requireAuth, contentController.listLandingItems);
router.post('/landing-items', requireAuth, requireRole(AdminLandingRoles), contentController.createLandingItem);
router.put('/landing-items/:id', requireAuth, requireRole(AdminLandingRoles), contentController.updateLandingItem);
router.delete('/landing-items/:id', requireAuth, requireRole(AdminLandingRoles), contentController.deleteLandingItem);

module.exports = router;
