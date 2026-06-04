const express = require('express');
const cors = require('cors');

const routes = require('./routes');

const app = express();

app.use(cors());
app.use(express.json());

// all routes
app.use('/', routes);

app.listen(3000, () => {
  console.log('API running on port 3000');
});