#!/bin/bash

# read config.txt and set the default configuration
i=0
while read line
do
	# words=$(echo $line | tr "=" "\n")
	IFS='=' read -r -a words <<< "$line"
	array[$i]=${words[1]}
	i=` expr $i + 1 `
done < config.txt

target_bucket=${array[0]}
folder_prefix=${array[1]}
user_prefix=${array[2]}
user_number=${array[3]}

# create 
for idx in $(seq ${user_number})
do
	target_folder="${folder_prefix}$idx"
	target_user="${user_prefix}$idx"

    aws s3api put-object --bucket ${target_bucket} --key "${target_folder}/" | echo q
done


