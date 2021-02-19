#! /bin/bash

apache_file="/etc/apache2/sites-available/default-folder.conf"
hosts_file="/mnt/c/Windows/System32/drivers/etc/hosts"

#read -p "Enter name of vhost to delete:" vhost
#read -p "Enter domain of vhost to delete:" domain
if [ ! -z $1 ] || [ ! -z $2 ]; then
	sed -i "/#"$1"/,/VirtualHost>/d" $apache_file
	sed -i "s/ $1.$2//g" $hosts_file
	rm .backupApacheConfig
	rm .backupHostsFile
	rm -r $1
else
	echo "name of vhost cannot be null"
fi

#must be executed under a wsl host run as admin and with this syntax: sudo bash delete_vhost.sh folder_to_delete domain_of_vhost
