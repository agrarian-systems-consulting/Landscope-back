-- Table: projects

-- DROP TABLE projects;

CREATE TABLE projects -- Table des projets apf
(
  gid serial unique NOT NULL, -- Identifiant unique
  name_project character varying(255) NOT NULL, -- 
  country character varying(255) NOT NULL, -- 
  city character varying(255), -- 
  area character varying(50), -- integer,
  main_objective character varying NOT NULL, -- 
  funds character varying, --
  date_start character varying(255), -- timestamp without time zone,
  date_end character varying(255), -- timestamp without time zone,
  current boolean, --
  contact character varying, -- 
  phone character varying(50), -- 
  mail character varying, -- 
  links character varying, -- 
  commodities character varying, -- 
  actors character varying, -- 
  crit_formal_agreement boolean DEFAULT NULL, --
  crit_int_commitment boolean DEFAULT NULL, --
  crit_baseline boolean DEFAULT NULL, --
  crit_landscape_plan_agreed boolean DEFAULT NULL, --
  crit_landscape_plan_implemented boolean DEFAULT NULL, --
  crit_governance boolean DEFAULT NULL, --
  crit_parti_monitoring boolean DEFAULT NULL, --
  crit_strenth_capacity boolean DEFAULT NULL, --
  geometry geometry(geometry,4326) DEFAULT NULL, -- 
  CONSTRAINT projects_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE projects OWNER TO postgres;

CREATE INDEX projects_geometry_idx ON projects USING GIST(geometry);

/*

Exemple d'insertion de géométrie
INSERT INTO projects(gid,name_project,country,main_objective,geometry)
VALUES(DEFAULT,'projet1','France','préserver les forêts',ST_Transform(ST_GeomFromText('POLYGON((743238 2967416,743238 2967450,
	743265 2967450,743265.625 2967416,743238 2967416))',2249),4326))

*/
