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
      SELECT
        e.id as event_id,
        e.title,
        e.description,
        e.lat,
        e.lng,
        e.timestamp,

        m.id as media_id,
        m.type,
        m.title as media_title,
        m.alt_text,
        m.source

      FROM events e
      LEFT JOIN media m ON e.id = m.event_id
      ORDER BY e.timestamp DESC
    `;

    const params = [];

    if (limit) {
      sql += ' LIMIT ?';
      params.push(limit);
    }

    const [rows] = await db.query(sql, params);

    // 🔥 group rows into events
    const eventsMap = new Map();

    for (const row of rows) {
      if (!eventsMap.has(row.event_id)) {
        eventsMap.set(row.event_id, {
          id: String(row.event_id),
          title: row.title,
          description: row.description,
          timestamp: row.timestamp,
          coordinates: row.lat != null && row.lng != null
              ? { lat: row.lat, lng: row.lng }
              : null,
          media: []
        });
      }

      if (row.media_id) {
        const event = eventsMap.get(row.event_id);

        event.media.push({
          id: String(row.media_id),
          type: row.type,
          title: row.media_title,
          altText: row.alt_text,
          source: row.source
        });
      }
    }

    res.json(Array.from(eventsMap.values()));

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