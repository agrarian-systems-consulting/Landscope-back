-- Table: actors

-- DROP TABLE actors;

CREATE TABLE actors -- Table des actors
(
  id serial unique NOT NULL, -- Identifiant unique
  name character varying(255), --
  type character varying(255), --
  CONSTRAINT actors_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE actors OWNER TO postgres;

/*
INSERT INTO actors(id,name) VALUES (DEFAULT,'Hugo')
*/