-- Table: project_actors

-- DROP TABLE project_actors;

CREATE TABLE project_actors -- Table des project_actors
(
  id serial unique NOT NULL, -- Identifiant unique
  project_id integer REFERENCES projects(gid) ON DELETE RESTRICT, --
  actor_id integer REFERENCES actors(id) ON DELETE RESTRICT, --
  name character varying(255), --
  CONSTRAINT project_actors_pkey PRIMARY KEY (id,project_id,actor_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE project_actors OWNER TO postgres;

/*
INSERT INTO project_actors(id,project_id,actor_id,name) VALUES (DEFAULT,2,1,'test')
*/