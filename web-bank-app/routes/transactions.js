const express = require('express');
const router = express.Router();

// Transaction History
router.get('/', (req, res) => {
  res.json({
    accountNumber: '123456789',
    transactions: [
      {
        id: 'TX-001',
        date: '2026-08-29',
        merchant: 'Amazon',
        category: 'Shopping',
        amount: -89.99,
        currency: 'USD',
        description: 'Amazon order #1234'
      },
      {
        id: 'TX-002',
        date: '2026-08-28',
        merchant: 'Starbucks',
        category: 'Food & Drink',
        amount: -5.75,
        currency: 'USD',
        description: 'Latte'
      },
      {
        id: 'TX-003',
        date: '2026-08-27',
        merchant: 'Payroll',
        category: 'Income',
        amount: 3200.00,
        currency: 'USD',
        description: 'Monthly salary'
      }
    ]
  });
});

module.exports = router;
