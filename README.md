# Bootstrap tutor to get geonames.org data into your Postgres fast!

This set of instructions and utilities was born during experiments with
[geonames.org](http://download.geonames.org/export/dump/) and getting it to my postgres instance.

This set is based on the following assumptions:

* There shall be a dedicated schema `geonames` to hold geonames.org data.
* You shall have admin access to postgres instance, or know someone who has it.
* Your postgres shall have a dedicated user to manage the migrations of
  geonames data.

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

    git clone https://github.com/lindemannrichard/geonames.git
    cd geonames

### Download geonames data from server

    curl http://download.geonames.org/export/dump/countryInfo.txt | sed '/^#/ d' > countryInfo.txt
    curl http://download.geonames.org/export/dump/allCountries.zip | bsdtar -xvf-

### Setup a dedicated role and schema in postgres

    CREATE USER geonames; 
    ALTER USER geonames SET search_path = geonames;
    CREATE SCHEMA IF NOT EXISTS geonames;
    ALTER SCHEMA geonames OWNER to geonames;

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

Now you have basic geonames db up and running.
