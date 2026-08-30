const express = require('express');
const router = express.Router();

// Core Banking: Account Overview
router.get('/', (req, res) => {
  res.json({
    customerId: 'CUST-001',
    accounts: [
      { type: 'Checking', number: '123456789', balance: 2450.32, currency: 'USD' },
      { type: 'Savings', number: '987654321', balance: 10250.00, currency: 'USD' },
      { type: 'Credit Card', number: '4111-xxxx-xxxx-1111', balance: -450.75, limit: 5000 },
      { type: 'Loan', number: 'LN-2024-001', balance: 15000.00, rate: 4.5 },
      { type: 'CD', number: 'CD-2023-001', balance: 5000.00, maturityDate: '2027-01-01' }
    ]
  });
});

module.exports = router;
