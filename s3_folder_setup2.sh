#!/bin/bash

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

while read line
do
    array[$i]=$line
    i=` expr $i + 1 `
    
    echo $line
    
    aws s3api put-object --bucket ${target_bucket} --key "${line}/" | echo q
    
done < user_list.txt

