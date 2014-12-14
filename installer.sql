CREATE USER geonamesadmin; 
ALTER  USER geonamesadmin SET search_path=geonames;

CREATE SCHEMA geonames;
ALTER  SCHEMA geonames OWNER TO geonamesadmin;

SET ROLE geonamesadmin;
SET search_path=geonames;

CREATE TABLE geonames (
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

create table countryinfo (
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

\copy countryinfo (iso_alpha2,iso_alpha3,iso_numeric,fips_code,name,capital,areainsqkm,population,continent,tld,currencycode,currencyname,phone,postalcode,postalcoderegex,languages,geonameid,neighbors,equivfipscode) from 'countryInfo.txt' NULL as '';

\copy geonames ( geonameid, name, asciiname, alternatenames, latitude, longitude, fclass, fcode, country, cc2, admin1, admin2, admin3, admin4, population, elevation, gtopo30, timezone, moddate) from 'allCountries.txt' with NULL as ''; 

CREATE INDEX geonames_country_idx ON geonames (country);
CREATE INDEX geonames_fclass_idx  ON geonames (fclass);
CREATE INDEX geonames_name_gin    ON geonames USING gin (to_tsvector('english', name)); 

CREATE INDEX countryinfo_iso_alpha2_idx ON countryinfo (iso_alpha2);
CREATE INDEX countryinfo_iso_alpha3_idx ON countryinfo (iso_alpha3);
CREATE INDEX countryinfo_name_idx       ON countryinfo (name); 
CREATE INDEX countryinfo_geonameid_idx  ON countryinfo (geonameid); 

ALTER TABLE ONLY countryinfo ADD CONSTRAINT countryinfo_geonameid_fkey
FOREIGN KEY (geonameid) REFERENCES geonames (geonameid) ON DELETE RESTRICT;
