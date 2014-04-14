#! /bin/bash -v
#
# Copyright (C) 2014 by M. Edward (Ed) Borasky
#
# This program is licensed to you under the terms of version 3 of the
# GNU Affero General Public License. This program is distributed WITHOUT
# ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING THOSE OF NON-INFRINGEMENT,
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. Please refer to the
# AGPL (http://www.gnu.org/licenses/agpl-3.0.txt) for more details.
#

export HERE=`pwd` # need absolute path later

sudo postgresql-setup initdb # fails harmlessly if data directory isn't empty
sudo systemctl enable postgresql # start the server on reboot
sudo systemctl start postgresql # start the server now

# password protect the PostgreSQL superuser, 'postgres'
echo "Create a password for 'postgres', the PostgreSQL superuser"
sudo su - postgres -c "psql -c '\password postgres'"

# install the extensions - will ERROR harmlessly if they're already there
sudo su - postgres -c "psql -c 'CREATE EXTENSION adminpack;'"

# PostgreSQL username = Linux username
export PGUSER=${USER}

# create a user
sudo su - postgres -c "dropdb ${PGUSER}"
sudo su - postgres -c "dropdb geocoder"
sudo su - postgres -c "dropuser ${PGUSER}"
sudo su - postgres -c "createuser -d ${PGUSER}"

# create a 'home' database for the user
sudo su - postgres -c "createdb -O ${PGUSER} ${PGUSER}"
echo "Create a password for the PostgreSQL user '${PGUSER}'"
psql -c '\password'

# create a 'geocoder' database for the user
sudo su - postgres -c "createdb -O ${PGUSER} geocoder"

# create a 'congress_districts' database for the user
sudo su - postgres -c "createdb -O ${PGUSER} congress_districts"

# create the PostGIS extensions in all databases
sudo ${HERE}/create-postgis.bash ${PGUSER}
sudo ${HERE}/create-postgis.bash geocoder
sudo ${HERE}/create-postgis.bash congress_districts

# create the TIGER extensions in 'geocoder'
sudo ${HERE}/create-tiger-schema.bash geocoder
