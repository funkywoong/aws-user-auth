#!/bin/bash

# read config.txt and set the default configuration
i=0
while read line
do
    IFS='=' read -r -a words <<< "$line"
    array[$i]=${words[1]}
    i=` expr $i + 1 `
done < config.txt

# default variable setting
target_bucket=${array[0]}
folder_prefix=${array[1]}
user_prefix=${array[2]}
user_number=${array[3]}
temporal_password=${array[4]}

# create IAM users and policies
# these will be created as many as the number you set on config.txt
i=0
while read line
do
    array[$i]=$line
    i=` expr $i + 1 `

    IFS='u' read -r -a words <<< "$line"

    target_user=u${words[1]}
    target_folder="${line}"
    policy_doc="${target_user}Policy.json"
    policy_name="${target_user}Policy"
    
cat <<EOF > ./updatePolicy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowStatement1",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        },
        {
            "Sid": "AllowStatement2A",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${target_bucket}"
            ],
            "Condition": {
                "StringEquals": {
                    "s3:prefix": [
                        "",
                        "${target_folder}"
                    ]
                }
            }
        },
        {
            "Sid": "AllowStatement3",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${target_bucket}"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "${target_folder}/*"
                    ]
                }
            }
        },
        {
            "Sid": "AllowStatement4A",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:GetObjectVersion",
                "s3:ListObjectVersions",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${target_bucket}/${target_folder}/*"
            ]
        },
        {
            "Sid": "DenyStatement5",
            "Effect": "Deny",
            "Action": [
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::${target_bucket}"
            ]
        }
    ]
}
EOF
    aws iam create-policy-version --policy-arn arn:aws:iam::451741833328:policy/${policy_name} --policy-document file://updatePolicy.json --set-as-default | echo q

    # remove temporal json file
    rm -rf updatePolicy.json
done < user_list.txt