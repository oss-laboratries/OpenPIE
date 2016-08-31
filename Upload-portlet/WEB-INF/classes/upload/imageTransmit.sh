#!/bin/sh 

copy_from=$1

remote_host=$2

copy_to=$3

user=root

passwd=P@ssword




echo $copy_from $remote_host $copy_to

expect -c "

set timeout 60

spawn scp -rp $copy_from $user@$remote_host:/$copy_to
expect {
	\"*assword\" {set timeout 60; send \"$passwd\r\";}
	\"*\u30d1\u30b9\u30ef\u30fc\u30c9\" {set timeout 60; send \"$passwd\r\";}
	\"yes/no\" {send \"yes\r\"; exp_continue;}
}
expect eof"

