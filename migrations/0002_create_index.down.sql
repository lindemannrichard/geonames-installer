DROP INDEX geonames_country_idx;
DROP INDEX geonames_fclass_idx;

DROP INDEX countryinfo_iso_alpha2_idx;
DROP INDEX countryinfo_iso_alpha3_idx;
DROP INDEX countryinfo_name_idx;
DROP INDEX countryinfo_geonameid_idx;

ALTER TABLE ONLY geonames.countryinfo DROP CONSTRAINT countryinfo_geonameid_fkey;
