const mongoose = require('mongoose');

const EventSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  date: Date,
  location: String,
  source: String, // kaynağın URL'si veya üniversite adı
  external: { type: Boolean, default: true }, // dışarıdan katılım
  ticket_url: String,
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Event', EventSchema);
