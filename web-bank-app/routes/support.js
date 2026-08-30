const express = require('express');
const router = express.Router();

// Secure messaging (dummy)
router.get('/messages', (req, res) => {
  res.json({
    messages: [
      { id: 'MSG-001', from: 'Support', subject: 'Welcome to Web Bank', unread: true }
    ]
  });
});

// Branch/ATM locator
router.get('/locations', (req, res) => {
  res.json({
    locations: [
      { name: 'Main Branch', address: '123 Bank St', city: 'Houston', services: ['Teller', 'ATM', 'Loans'] },
      { name: 'ATM - Richmond', address: '456 Market Rd', city: 'Richmond', services: ['ATM'] }
    ]
  });
});

// Document center
router.get('/documents', (req, res) => {
  res.json({
    documents: [
      { id: 'DOC-001', type: 'Tax Form', year: 2025 },
      { id: 'DOC-002', type: 'Statement', month: '2026-07' }
    ]
  });
});

module.exports = router;
