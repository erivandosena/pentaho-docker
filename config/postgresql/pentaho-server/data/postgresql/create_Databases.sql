DROP DATABASE IF EXISTS hibernate;
DROP DATABASE IF EXISTS sampledata;
DROP DATABASE IF EXISTS quartz;
DROP DATABASE IF EXISTS shark;

DROP USER IF EXISTS hibuser, pentaho_user, pentaho_admin;
-- Alterar senhas para segurança
-- NOTA: As senhas devem corresponder às fontes de dados no sistema Pentaho
CREATE USER "hibuser" WITH LOGIN PASSWORD '@@hibuser@@';
CREATE USER "pentaho_user" WITH LOGIN PASSWORD '@@pentaho_user@@';
CREATE USER "pentaho_admin" WITH LOGIN PASSWORD '@@pentaho_admin@@';

CREATE DATABASE hibernate WITH OWNER = hibuser ENCODING = 'UTF8';
CREATE DATABASE sampledata WITH OWNER = pentaho_user ENCODING = 'UTF8';
CREATE DATABASE quartz  WITH OWNER = pentaho_user  ENCODING = 'UTF8';
CREATE DATABASE shark  WITH OWNER = pentaho_user  ENCODING = 'UTF8';  
