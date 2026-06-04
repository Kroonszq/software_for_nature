CREATE TABLE media (
  id INT NOT NULL AUTO_INCREMENT,
  event_id INT NOT NULL,

  type ENUM('image', 'video', 'pdf') NOT NULL,

  title VARCHAR(255) NOT NULL,
  alt_text VARCHAR(255) NOT NULL,
  source VARCHAR(500) NOT NULL,

  PRIMARY KEY (id),
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);

INSERT INTO media (event_id, type, title, alt_text, source)
VALUES
-- Event 1
(1, 'image', 'River image', 'Volunteers cleaning river',
 '/pics/EMOV/20260322/1500/EMOV_20260322-150000.jpg'),

(1, 'video', 'River video', 'Cleanup footage',
 '/multimedia/avi/EMOV_20260322-150000.avi'),

-- Event 2
(2, 'image', 'Forest image', 'Forest scenery',
 '/pics/EMOV/20260322/1500/EMOV_20260322-150000.jpg'),

-- Event 3
(3, 'image', 'Bird image', 'Bird migration',
 '/pics/EMOV/20260322/1500/EMOV_20260322-150000.jpg');