#! /bin/bash
# jq is nesseary for this script
# https://jqlang.github.io/jq/

URL_v1="http://127.0.0.1:8200/v1/kv_v1"
URL_v2="http://127.0.0.1:8200/v1/kv/data"
Token="123456789"

host=$(hostname)


get_changed_status(){
	changed_status=$(curl -H "X-Vault-Token:$Token" -H "Content-Type:application/json" -X GET $URL_v1/$1 | jq -r '.data.Status')
}

set_changed_status(){
	post_data=$(echo '{"Status":"'$2'"}')
	curl -H "X-Vault-Token:$Token" -H "Content-Type:application/json" -X POST -d $post_data $URL_v1/$1 
}

update_password(){
	post_data=$(echo '{"data":{"root":"'$2'"}}')

	curl -H "X-Vault-Token:$Token" -H "Content-Type:application/json" -X POST -d $post_data $URL_v2/$1
}


reset_root_passwd(){
        rnum=$(($RANDOM*2024%9999))
        rstr=$(echo $rnum | md5sum | cut -c 1-8)
        root_password="ABdsrwx#*$rstr"
		
        yes $root_password | passwd root
        return $?
}


get_changed_status $host

if [ "$changed_status" == "null" ] || [ "$changed_status" == "" ]; then
	set_changed_status $host "Pending"
else
	
	if [ "$changed_status" == "Pending" ] || [ "$changed_status" == "Changing" ]; then	
		set_changed_status $host "Changing"
		#get_changed_status "$host"
		#echo $changed_status

		reset_root_passwd
		echo $?
		if [ "$?" -eq 0 ]; then
			update_password  $host $root_password
			set_changed_status $host "Changed"
			logger "root password set"
		fi
	fi 
fi

