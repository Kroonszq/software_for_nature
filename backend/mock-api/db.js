const mysql = require('mysql2');

const pool = mysql.createPool({
  host: 'mock-database',
  port: 3306,
  user: 'mock_user',
  password: 'mock_password',
  database: 'ingv_mock',
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool.promise();