CREATE INDEX geonames_country_idx ON geonames.geonames (country);
CREATE INDEX geonames_fclass_idx  ON geonames.geonames (fclass);

CREATE INDEX countryinfo_iso_alpha2_idx ON geonames.countryinfo (iso_alpha2);
CREATE INDEX countryinfo_iso_alpha3_idx ON geonames.countryinfo (iso_alpha3);
CREATE INDEX countryinfo_name_idx       ON geonames.countryinfo USING gin (to_tsvector('english', name)); 
CREATE INDEX countryinfo_geonameid_idx  ON geonames.countryinfo (geonameid); 

ALTER TABLE ONLY geonames.countryinfo ADD CONSTRAINT countryinfo_geonameid_fkey
FOREIGN KEY (geonameid) REFERENCES geonames.geonames (geonameid) ON DELETE RESTRICT;
