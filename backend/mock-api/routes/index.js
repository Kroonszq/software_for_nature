const express = require('express');
const router = express.Router();

const eventsRoutes = require('./events.routes');

router.use('/events', eventsRoutes);

module.exports = router;