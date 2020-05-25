-- Table: commodities

-- DROP TABLE commodities;

CREATE TABLE commodities -- Table des commodities
(
  id serial unique NOT NULL, -- Identifiant unique
  name character varying(255), --
  CONSTRAINT commodities_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE commodities OWNER TO postgres;