#!/usr/local/bin/bash
# This file contains the install script for bitwarden

#init jail
initplugin "$1"

# Initialise defaults
admin_token="${admin_token:-$(openssl rand -base64 16)}"
mariadb_database="${mariadb_database:-$1}"
mariadb_user="${mariadb_user:-$1}"


#TODO LINK
DB_HOST="${link_mariadb}_ip4_addr"
DB_HOST="${!DB_HOST%/*}:3306"
DB_STRING="mysql://${mariadb_user}:${mariadb_password}@${DB_HOST}/${mariadb_database}"

if [ "${reinstall}" = "true" ]; then
	echo "Reinstall of Bitwarden detected... using existing config and database"
else
	echo "No config detected, doing clean install, utilizing the Mariadb database ${DB_HOST}"
	iocage exec "${link_mariadb}" mysql -u root -e "CREATE DATABASE ${mariadb_database};" || true
	iocage exec "${link_mariadb}" mysql -u root -e "GRANT ALL ON ${mariadb_database}.* TO ${mariadb_user}@${jail_ip} IDENTIFIED BY '${mariadb_password}';"
	iocage exec "${link_mariadb}" mysqladmin reload
fi

iocage exec "${1}" chown -R bitwarden:bitwarden /usr/local/share/bitwarden /config

echo 'export DATABASE_URL="'"${DB_STRING}"'"' >> "${global_dataset_iocage}"/jails/"${1}"/root/usr/local/etc/rc.conf.d/bitwarden
echo 'export ADMIN_TOKEN="'"${admin_token}"'"' >> "${global_dataset_iocage}"/jails/"${1}"/root/usr/local/etc/rc.conf.d/bitwarden

if [ "${admin_token}" == "NONE" ]; then
	echo "Admin_token set to NONE, disabling admin portal"
else
	echo "Admin_token set and admin portal enabled"
	iocage exec "${1}" echo "${mariadb_database} Admin Token is ${admin_token}" > /root/"${1}"_admin_token.txt
fi


iocage exec "${1}" service bitwarden restart

exitplugin "$1"
echo "Admin Token is ${admin_token}"

