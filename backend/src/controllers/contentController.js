const contentService = require('../services/contentService');

async function listLandingItems(req, res) {
  const items = await contentService.listLandingItems();
  return res.json(items);
}

async function createLandingItem(req, res) {
  const { type, title, content, startDate, endDate } = req.body;
  if (!type || !title || !content || !startDate || !endDate) {
    return res.status(400).json({ message: 'type, title, content, startDate, endDate are required.' });
  }

  const item = await contentService.createLandingItem({
    type,
    title,
    content,
    startDate,
    endDate,
    createdBy: req.user.sub,
  });

  return res.status(201).json(item);
}

async function updateLandingItem(req, res) {
  const { id } = req.params;
  const { type, title, content, startDate, endDate } = req.body;

  const updated = await contentService.updateLandingItem(id, {
    type,
    title,
    content,
    startDate,
    endDate,
  });

  if (!updated) {
    return res.status(404).json({ message: 'Landing item not found.' });
  }

  return res.json(updated);
}

async function deleteLandingItem(req, res) {
  const { id } = req.params;
  const removed = await contentService.deleteLandingItem(id);

  if (!removed) {
    return res.status(404).json({ message: 'Landing item not found.' });
  }

  return res.status(204).send();
}

module.exports = {
  listLandingItems,
  createLandingItem,
  updateLandingItem,
  deleteLandingItem,
};
