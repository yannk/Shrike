DROP TABLE IF EXISTS user;
CREATE TABLE user (
  user_id INTEGER NOT NULL,
  first_name varchar(255) default NULL,
  last_name varchar(255) default NULL,
  created_on datetime default NULL,
  PRIMARY KEY (user_id)
);

