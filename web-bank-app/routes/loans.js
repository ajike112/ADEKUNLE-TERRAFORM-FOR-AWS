const express = require('express');
const router = express.Router();

// Loan management
router.get('/loans', (req, res) => {
  res.json({
    loans: [
      { id: 'LN-001', type: 'Auto', balance: 12000, rate: 3.9 },
      { id: 'LN-002', type: 'Personal', balance: 5000, rate: 7.2 }
    ]
  });
});

// Mortgage tools
router.get('/mortgage', (req, res) => {
  res.json({
    mortgageId: 'MTG-001',
    balance: 250000,
    escrow: 450,
    paymentHistory: [
      { date: '2026-08-01', amount: 1800 },
      { date: '2026-07-01', amount: 1800 }
    ]
  });
});

module.exports = router;
