# Landscope - Serveur cartographique

L’Alliance pour la Préservation des Forêts fournit des données et outils pour donner les moyens aux entreprises françaises de mieux protéger les forêts. Landscope est une cartographie de projets qui allient des objectifs de protection des ressources naturelles avec des objectifs de développement économique, et qui mobilisent une approche paysagère. Les projets identifiés sont le fruit d’un travail de revue de la littérature existante réalisé en Mai 2020.

Cette application est le serveur cartographique qui permet de générer des flux de données visualisables dans Landscope.

## Getting Started

Ces instructions vous permettront d'obtenir une copie du projet sur votre machine locale à des fins de développement et de test. Consultez la section "Déploiement" pour obtenir des notes sur la manière de déployer le projet sur un système DEBIAN 10.

### Prerequisites

Initialement, il était prévu de concevoir une image [Docker](https://www.docker.com/) pour intégrer tous les composants du serveur cartographique reposant sur [GeoServer](http://geoserver.org/). Cependant, après plusieurs essais, il a été choisi de revenir à une succession d'étapes à réaliser du fait des délais impartis.

### Installing

Voici une série d'instructions qui vous expliquent, étape par étape, comment faire fonctionner un environnement de production pour cette application.

#### Mettre à jour le gestionnaire de paquets

```
sudo apt update
sudo apt upgrade
```

#### Tomcat

##### Installation

```
sudo apt install default-jdk
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat
cd /tmp
wget https://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.34/bin/apache-tomcat-9.0.34.tar.gz
tar -xf apache-tomcat-9.0.34.tar.gz
sudo mv apache-tomcat-9.0.34 /opt/tomcat/
sudo chown -R tomcat:/opt/tomcat
sudo sh -c 'chmod +x /opt/tomcat/bin/*.sh'

```

##### Configuration

###### Ouvrir le fichier de configuration

```
sudo nano /etc/systemd/system/tomcat.service
```

###### Copier les informations suivantes

```
[Unit]
Description=Tomcat 9.0 servlet container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/default-java"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"

Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="CATALINA_OPTS=-XX:SoftRefLRUPolicyMSPerMB=36000"
Environment="CATALINA_OPTS=-XX:-UsePerfData"
Environment="CATALINA_OPTS=-Dorg.geotools.referencing.forceXY=true "
Environment="CATALINA_OPTS=-Dorg.geotoools.render.lite.scale.unitCompensation=true"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
```

###### Redémarrer Tomcat

```
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo ufw allow 8080
```

###### Tester la configuration

Pour tester la configuration, ouvrir `http://<ip>:8080`

#### Geoserver

##### Installation

```
cd /tmp
wget http://sourceforge.net/projects/geoserver/files/GeoServer/2.17.0/geoserver-2.17.0-war.zip
sudo apt-get install unzip
unzip geoserver-2.70.0-war.zip geoserver.war
sudo mv geoserver.war /opt/tomcat/webapps/
```

##### Configuration

Configuer le cross origin dans le fichier `/opt/tomcat/web.xml` de tomcat en ajoutant :

```
<filter>
<filter-name>CorsFilter</filter-name>
<filter-class>org.apache.catalina.filters.CorsFilter</filter-class>
<init-param>
<param-name>cors.allowed.origins</param-name>
<param-value>_</param-value>
</init-param>
<init-param>
<param-name>cors.allowed.methods</param-name>
<param-value>GET,POST,DELETE,HEAD,OPTIONS,PUT</param-value>
</init-param>
<init-param>
<param-name>cors.allowed.headers</param-name>
<param-value>Authorization,Content-Type,X-Requested-With,accept,Origin,Access-Control-Request-Method,Access-Control-Request-Headers</param-value>
</init-param>
<init-param>
<param-name>cors.exposed.headers</param-name>
<param-value>Access-Control-Allow-Origin,Access-Control-Allow-Credentials</param-value>
</init-param>
<init-param>
<param-name>cors.support.credentials</param-name>
<param-value>true</param-value>
</init-param>
<init-param>
<param-name>cors.preflight.maxage</param-name>
<param-value>10</param-value>
</init-param>
</filter>
<filter-mapping>
<filter-name>CorsFilter</filter-name>
<url-pattern>/_</url-pattern>
</filter-mapping>
```

##### Redémarrer Tomcat

```
sudo systemctl restart tomcat
```

##### Tester la configuration

Pour tester la configuration, ouvrir `http://<ip>:8080/geoserver`

##### PostgreSQL

##### Installation

```
sudo apt-get install postgresql postgresql-client
sudo apt-get install postgis postgresql-11-postgis-2.5 postgresql-11-postgis-2.5-scripts
sudo ufw allow 5432
```

##### Configuration

Modifier le fichier `pg_hba.conf`, ici on laisse toutes les IP se connecter à la base :

```
host all all 0.0.0.0/0 md5
```

Configurer les IP pouvant se connecter sur `postgresql.conf`, en modifiant la ligne :

```
listen_addresses = '\*'
```

###### Redémarrer PostgreSQL

```
/etc/init.d/postgresql restart
```

###### Changer le mot de passe pour postgres

```
su -c "psql" - postgres
\password
\quit
```

###### Créer un nouveau user

```
sudo -u postgres createuser username
```

###### Créer une base de donnée

```
sudo -u postgres createdb dbname
```

Changer `dbname` pour mettre un nom le plus explicite possible.
Ne pas oublier de modifier `dbname` dans les commandes suivantes dans ce cas.

###### Changer les droits pour le nouveau user

```
sudo -u postgres psql
psql=# alter user username with encrypted password 'password';
GRANT ALL PRIVILEGES ON DATABASE dbname TO username;
```

###### Connexion à la base de données puis attribution des permissions

```
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO username;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO username;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO username;
```

###### Ajouter les tables SQL dans la base de données

Les fichiers SQL à ajouter sont disponibles dans ce repo Github. Pour la première version de Landscope, seule la table Projects.sql est utilisée.

```
psql -U username -d dbname -a -f file.sql
```

#### Finaliser la configuration

##### Dans l'UI de GeoServer

1. Changer les mots de passe maître et admin
2. Créer un nouveau rôle : `ROLE_WFS`
3. Créer un nouvel utilisateur : `apf` et mdp : `8hN5q7qmk3U5KX` , on ajoute le rôle `ROLE_WFS` à l'utilisateur
4. Sécurité du service : ajouter une nouvelle règle de service : Service wfs et Méthode \*, ajouter le rôle `ROLE_WFS`.
5. Ajouter un nouvel espace de travail : apf (avec un espace de nommage, important pour le WFS-T).
6. Ajouter un nouvel entrepôt PostGIS avec les paramètres de la bdd créée et l'utilisateur créé
7. Publier la couche projects
8. Sécurité des données, ajouter 2 nouvelle règles : espace de travail apf, layer projets et mode d'accès Lecture puis pour la seconde règle écriture, ajouter le rôle `ROLE_WFS`.

## Built With

- [Tomcat](https://tomcat.apache.org/download-80.cgi) - Open source implementation of the Java Servlet
- [PostgreSQL](https://fr.reactjs.org/) - Open Source Relational Database
- [Geoserver](https://fr.reactjs.org/) - Open source server for geospatial data

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
