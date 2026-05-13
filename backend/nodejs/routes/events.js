const express = require('express');
const router = express.Router();

// Placeholder: gerçek DB bağlantısı eklenecek
router.get('/', async (req, res) => {
  res.json([
    {
      id: 'sample-1',
      title: 'Örnek Etkinlik',
      date: '2026-03-01',
      location: 'Üniversite A'
    }
  ]);
});

module.exports = router;
