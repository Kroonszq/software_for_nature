DROP TABLE IF EXISTS events;

CREATE TABLE events (
  id INT NOT NULL AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  timestamp DATETIME NOT NULL,
  lat DOUBLE NULL,
  lng DOUBLE NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO events (title, description, timestamp, lat, lng)
VALUES
(
  'River Cleanup',
  'Volunteers cleaning the river.',
  NOW() - INTERVAL 2 HOUR,
  52.0907,
  5.1214
),
(
  'Forest Walk',
  'Nature observation walk.',
  NOW() - INTERVAL 1 DAY,
  52.1000,
  5.1100
),
(
  'Research Note',
  'Bird migration spotted.',
  NOW() - INTERVAL 5 HOUR,
  NULL,
  NULL
);