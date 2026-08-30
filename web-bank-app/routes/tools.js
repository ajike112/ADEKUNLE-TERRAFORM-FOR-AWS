const express = require('express');
const router = express.Router();

// Budgeting & spending insights
router.get('/budget', (req, res) => {
  res.json({
    month: '2026-08',
    totalSpending: 1800,
    categories: [
      { name: 'Food & Drink', amount: 400 },
      { name: 'Rent', amount: 900 },
      { name: 'Shopping', amount: 300 },
      { name: 'Transport', amount: 200 }
    ],
    alerts: ['You are close to exceeding your shopping budget']
  });
});

// Savings goals
router.get('/savings-goals', (req, res) => {
  res.json({
    goals: [
      { name: 'Emergency Fund', target: 5000, current: 2500 },
      { name: 'Vacation', target: 3000, current: 1200 }
    ]
  });
});

// Credit score monitoring
router.get('/credit-score', (req, res) => {
  res.json({
    score: 745,
    rating: 'Good',
    lastUpdated: '2026-08-25'
  });
});

module.exports = router;
