--
-- nota: este script assume que o pg_hba.conf está configurado corretamente
--

-- \connect postgres postgres
ALTER DATABASE hibernate  OWNER TO awsbiuser;

drop database if exists hibernate;
--drop user if exists hibuser;
drop role if exists hibuser;
--CREATE USER hibuser PASSWORD '@@hibuser@@';
CREATE role hibuser PASSWORD '@@hibuser@@' login;

CREATE DATABASE hibernate ENCODING = 'UTF8' TABLESPACE = pg_default;

ALTER DATABASE hibernate  OWNER TO hibuser;

GRANT ALL PRIVILEGES ON DATABASE hibernate to hibuser;
