const request = require('supertest');
const app = require('../backend/nodejs/index'); // index.js sunucuyu başlatıyor, test ortamı için farklı export tercih edilebilir

describe('Health check', () => {
  test('GET /health returns ok', async () => {
    const res = await request('http://localhost:3000').get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('status', 'ok');
  });
});
