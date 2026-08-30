const express = require('express');
const router = express.Router();

// MFA setup (dummy)
router.post('/mfa/setup', (req, res) => {
  res.json({ status: 'mfa_enabled', methods: ['sms', 'email', 'auth_app'] });
});

// Biometric login (dummy)
router.post('/biometric/login', (req, res) => {
  res.json({ status: 'biometric_login_success', method: 'fingerprint' });
});

// Fraud alerts
router.get('/fraud-alerts', (req, res) => {
  res.json({
    alerts: [
      { id: 'FA-001', type: 'card', message: 'Suspicious transaction in another country', status: 'unread' }
    ]
  });
});

// Device management
router.get('/devices', (req, res) => {
  res.json({
    devices: [
      { id: 'DEV-001', name: 'iPhone 15', lastLogin: '2026-08-29T01:23:00Z', trusted: true },
      { id: 'DEV-002', name: 'MacBook Pro', lastLogin: '2026-08-28T20:10:00Z', trusted: true }
    ]
  });
});

module.exports = router;
