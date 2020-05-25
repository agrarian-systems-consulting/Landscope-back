-- Table: project_commodities

-- DROP TABLE project_commodities;

CREATE TABLE project_commodities -- Table des project_commodities
(
  id serial unique NOT NULL, -- Identifiant unique
  project_id integer REFERENCES projects(gid) ON DELETE RESTRICT, --
  commodity_id integer REFERENCES commodities(id) ON DELETE RESTRICT, --
  CONSTRAINT project_commodities_pkey PRIMARY KEY (id,project_id,commodity_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE project_commodities OWNER TO postgres;