#! /bin/bash

apache_config_file="/etc/apache2/sites-available/default-folder.conf" #config file of virtual hosts on apache2
apache_backup_file="$PWD/.backupApacheConfig" 
windows_hosts_file="/mnt/c/Windows/System32/drivers/etc/hosts"
hosts_backup_file="$PWD/.backupHostsFile"
last_ip_file="$PWD/.last_ip"
legacy_apache_config="$PWD/.legacyApacheConfig" #this file is a main backup of the first file edited of the apache_config_file var
legacy_windows_hosts="$PWD/.legacyWindowsHosts" #this file is a main backup of the first file edited of the windws_hosts_file var
vhost_domain="test" #must be edited to your domain of preference
current_ip="$(hostname -I)"
if [ -f $last_ip_file ]; then
	last_ip=$(sed -e "1s/*/=/g" $last_ip_file)
	if [ "$last_ip" != "$current_ip" ]; then
		line_to_change=$(sed -n "/^"$last_ip"/p" $windows_hosts_file)
		line_content=$(echo ${line_to_change/"$last_ip"/""})
		number_line=$(sed -n "/^$last_ip/=" $windows_hosts_file)
		sed -i "$number_line""s/$line_to_change/$current_ip$line_content/g" $windows_hosts_file && echo "$current_ip" > $last_ip_file
	else
		echo "The ips of the hosts file are up to date"
	fi
else
	echo "$current_ip" > $last_ip_file
fi
#read -p "Enter directory to make a vhost:" newdir
newdir=$1
if [ -d $newdir ] && [ ! -z $newdir ]; then
	if [ -f $legacy_apache_config ] && [ -f $legacy_windows_hosts ]; then
		if [ -f $apache_config_file ]; then
			virtual_host="
<VirtualHost *:80> #$newdir
	#ServerAdmin admin@example.com
        ServerName $newdir.$vhost_domain
        #ServerAlias www.example.com
        DocumentRoot $PWD/$newdir/public
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>"
			if [ -f $apache_backup_config ]; then
				cp $apache_config_file $apache_backup_file
			else
				echo > .backupApacheConfig && cp $apache_config_file .backupApacheConfig
			fi
			if [ -f $hosts_backup_file ]; then
				cp $windows_hosts_file $hosts_backup_file
	                else
				 echo > .backupHostsFile && cp $windows_hosts_file .backupHostsFile
			fi
			
			number_line_ipvf=$(sed -n "/^$current_ip/=" $windows_hosts_file)
			sed -i "$number_line_ipvf""s/$/ $newdir.$vhost_domain/g" $windows_hosts_file
			number_line_ipvs=$(sed -n '/^::1/=' $windows_hosts_file)
			sed -i "$number_line_ipvs""s/$/ $newdir.$vhost_domain/g" $windows_hosts_file
			echo "$virtual_host" >> $apache_config_file
		else
			echo "Fatal error: Apache config not found"
		fi
	else
		 echo > .legacyApacheConfig && cp $apache_config_file $legacy_apache_config
		 echo > .legacyWindowsHosts && cp $windows_hosts_file $legacy_windows_hosts
		echo "The Legacy files were not found, the program just created them"
		read -p "Do you want it to run again? [Y/n]" -n 1 -r  REPLY
		echo ""
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
		    bash ./create_vhost.sh
		fi
	fi
else
	echo  "Fatal error, Directory $newdir was not found"
fi
#must be executed under a wsl host run as admin and with this syntax: sudo bash create_vhost.sh name_of_vhost
