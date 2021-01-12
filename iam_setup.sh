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
for idx in $(seq $user_number)
do
    target_folder="${folder_prefix}$idx"
    target_user="${user_prefix}$idx"
    policy_doc="${target_user}Policy.json"
    policy_name="${target_user}Policy"

# create temporal policy json file
cat <<EOF > ./${policy_doc}
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
                "arn:aws:s3:::$target_bucket"
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
                "s3:PutObject"
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
    # create policy
    response=$(aws iam create-policy --policy-name ${policy_name} --policy-document file://${policy_doc} | grep "arn")
    IFS='"' read -r -a tmp <<< "$response"
    policy_arn=${tmp[3]}
    echo ${policy_arn}

    # create user
    aws iam create-user --user-name ${target_user} | echo q

    # attach user-policy
    aws iam attach-user-policy --policy-arn ${policy_arn} --user-name ${target_user} | echo q

    # change password
    aws iam create-login-profile --user-name ${target_user} --password ${temporal_password} --password-reset-required | echo q

    # remove temporal json file
    rm -rf ${policy_doc}
done