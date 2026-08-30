const express = require('express');
const path = require('path');
const cors = require('cors');

const accountsRoutes = require('./routes/accounts');
const transactionsRoutes = require('./routes/transactions');
const transfersRoutes = require('./routes/transfers');
const securityRoutes = require('./routes/security');
const cardsRoutes = require('./routes/cards');
const toolsRoutes = require('./routes/tools');
const supportRoutes = require('./routes/support');
const loansRoutes = require('./routes/loans');
const settingsRoutes = require('./routes/settings');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// API routes
app.use('/api/accounts', accountsRoutes);
app.use('/api/transactions', transactionsRoutes);
app.use('/api/transfers', transfersRoutes);
app.use('/api/security', securityRoutes);
app.use('/api/cards', cardsRoutes);
app.use('/api/tools', toolsRoutes);
app.use('/api/support', supportRoutes);
app.use('/api/loans', loansRoutes);
app.use('/api/settings', settingsRoutes);

// Fallback to SPA
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Web Bank App running on http://localhost:${PORT}`);
});
