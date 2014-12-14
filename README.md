# Bootstrap tutor to get geonames.org data into your Postgres fast!

This set of instructions and utilities was born during experiments with
[geonames.org](http://download.geonames.org/export/dump/) and getting it into my postgres instance.

This set is based on the following assumptions:

* There shall be a dedicated schema `geonames` to hold geonames.org data.
* You shall have admin access to postgres instance, or know someone who has it.

So...

### Install the tool

 [migrate](github.com/mattes/migrate
) tool is used to keep db updated. It requires golang to run. Get [here](http://golang.org/doc/install).

    $ go get github.com/mattes/migrate

    $ migrate --help
    usage: migrate [-path=<path>] -url=<url> <command> [<args>]

    Commands:
       create <name>  Create a new migration
       up             Apply all -up- migrations
       down           Apply all -down- migrations
       reset          Down followed by Up
       redo           Roll back most recent migration, then apply it again
       version        Show current migration version
       migrate <n>    Apply migrations -n|+n
       goto <v>       Migrate to version v
       help           Show this help

       '-path' defaults to current working directory.    

### Clone a geonames

    git clone https://github.com/lindemannrichard/geonames-installer.git
    cd geonames-installer

### Download geonames data from server

    curl http://download.geonames.org/export/dump/countryInfo.txt | sed '/^#/ d' > countryInfo.txt
    curl http://download.geonames.org/export/dump/allCountries.zip | bsdtar -xvf-

### Setup a dedicated role and schema in postgres

    CREATE ROLE geonamesuser; 
    CREATE SCHEMA IF NOT EXISTS geonames;
    GRANT USAGE ON SCHEMA geonames TO geonamesuser;

### Create tables!

    migrate -path="./migrations" -url="postgres://geonames@localhost:5432/test?sslmode=disable" goto 1

**NOTE:** Replace path to postgres instance with your own.

### Import data

    psql -U geonames -d test -f import.sql

**NOTE:** Replace database `test` with your target database.

### Create indecies!

    migrate -path="./migrations" -url="postgres://geonames@localhost:5432/test?sslmode=disable" up

**NOTE:** Replace path to postgres instance with your own.

### Done.

Now you have basic geonames db up and running:

```sql
CREATE TABLE geonames.geonames (
  geonameid      SERIAL PRIMARY KEY,  /* integer id of record in geonames database                                 */
  name           VARCHAR(200),        /* name of geographical point                                                */
  asciiname      VARCHAR(200),        /* name of geographical point in plain ascii characters                      */
  alternatenames VARCHAR(10000),      /* alternatenames, comma separated, ascii names automatically transliterated */
  latitude       FLOAT,               /* latitude in decimal degrees (wgs84)                                       */
  longitude      FLOAT,               /* longitude in decimal degrees (wgs84)                                      */
  fclass         CHAR(1),             /* see http://www.geonames.org/export/codes.html                             */
  fcode          VARCHAR(10),         /* see http://www.geonames.org/export/codes.html                             */
  country        VARCHAR(2),          /* ISO-3166 2-letter country code, 2 characters                              */
  cc2            VARCHAR(100),        /* alternate country codes, comma separated, ISO-3166 2-letter country code  */
  admin1         VARCHAR(20),         /* fipscode (subject to change to iso code), see file admin1Codes.txt        */
  admin2         VARCHAR(80),         /* code for the second administrative division, see fle admin2Codes.txt      */
  admin3         VARCHAR(20),         /* code for third level administrative division                              */
  admin4         VARCHAR(20),         /* code for fourth level administrative division                             */
  population     BIGINT,              /* bigint                                                                    */
  elevation      INTEGER,             /* in meters                                                                 */
  gtopo30        INTEGER,             /* digital elevation model, srtm3 or gtopo30,                                */
  timezone       VARCHAR(40),         /* the timezone id (see file timeZone.txt)                                   */
  moddate        DATE                 /* date of last modification in yyyy-MM-dd format                            */
);

create table geonames.countryinfo (
  iso_alpha2      CHAR(2) PRIMARY KEY,
  iso_alpha3      CHAR(3),
  iso_numeric     INTEGER,
  fips_code       VARCHAR(3),
  name            VARCHAR(200),
  capital         VARCHAR(200),
  areainsqkm      DOUBLE PRECISION,
  population      INTEGER,
  continent       VARCHAR(2),
  tld             VARCHAR(10),
  currencycode    VARCHAR(3),
  currencyname    VARCHAR(20),
  phone           VARCHAR(20),
  postalcode      VARCHAR(100),
  postalcoderegex VARCHAR(200),
  languages       VARCHAR(200),
  geonameid       INTEGER,
  neighbors       VARCHAR(50),
  equivfipscode   VARCHAR(3)
);
```

### Useful resources:

* [download.geonames.org](http://download.geonames.org/export/dump/)
* [github.com/colemanm/gazetteer/](https://raw.githubusercontent.com/colemanm/gazetteer/master/docs/geonames_postgis_import.md)
