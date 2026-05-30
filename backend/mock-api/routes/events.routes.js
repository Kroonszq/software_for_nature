const express = require('express');
const router = express.Router();
const db = require('../db');

//
// GET /events
//
router.get('/', async (req, res) => {
  try {
    const limit = req.query.limit ? parseInt(req.query.limit) : null;

    let sql = `
      SELECT id, title, description, lat, lng, timestamp
      FROM events
      ORDER BY timestamp DESC
    `;

    const params = [];

    if (limit) {
      sql += ' LIMIT ?';
      params.push(limit);
    }

    const [rows] = await db.query(sql, params);
    res.json(rows);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//
// POST /events  (CREATE new event)
//
router.post('/', async (req, res) => {
  try {
    const { title, description, lat, lng } = req.body;

    const sql = `
      INSERT INTO events (title, description, lat, lng, timestamp)
      VALUES (?, ?, ?, ?, NOW())
    `;

    const [result] = await db.query(sql, [
      title,
      description,
      lat,
      lng
    ]);

    res.json({
      id: result.insertId,
      message: 'Event created'
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//
// PUT /events/:id  (UPDATE existing event)
//
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, lat, lng } = req.body;

    const sql = `
      UPDATE events
      SET title = ?, description = ?, lat = ?, lng = ?
      WHERE id = ?
    `;

    const [result] = await db.query(sql, [
      title,
      description,
      lat,
      lng,
      id
    ]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Event not found' });
    }

    res.json({ message: 'Event updated' });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;