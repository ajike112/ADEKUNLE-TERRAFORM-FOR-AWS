const express = require('express');
const router = express.Router();

// Funds Transfer (dummy)
router.post('/internal', (req, res) => {
  res.json({ status: 'success', type: 'internal', details: req.body });
});

router.post('/ach', (req, res) => {
  res.json({ status: 'success', type: 'ach', details: req.body });
});

router.post('/wire', (req, res) => {
  res.json({ status: 'success', type: 'wire', details: req.body });
});

router.post('/schedule', (req, res) => {
  res.json({ status: 'scheduled', details: req.body });
});

module.exports = router;
