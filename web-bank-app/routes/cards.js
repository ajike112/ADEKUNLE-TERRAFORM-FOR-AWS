const express = require('express');
const router = express.Router();

// Card controls
router.get('/controls', (req, res) => {
  res.json({
    cardNumber: '4111-xxxx-xxxx-1111',
    status: 'active',
    spendingLimit: 2000,
    internationalEnabled: false
  });
});

router.post('/freeze', (req, res) => {
  res.json({ status: 'frozen' });
});

router.post('/unfreeze', (req, res) => {
  res.json({ status: 'active' });
});

// Virtual cards
router.post('/virtual', (req, res) => {
  res.json({
    virtualCardNumber: '5555-xxxx-xxxx-2222',
    expiry: '2027-12',
    limit: req.body.limit || 500
  });
});

module.exports = router;
