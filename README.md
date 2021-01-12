# aws-user-auth
- IAM user creation by using AWS CLI
- Create S3 folders for each IAM user

## requirements
### 1. AWS CLI
- The latest version of AWS CLI. Please check the following link for installing it.
- [AWS_CLI_link](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/cli-chap-install.html).

### 2. OS Platform
- These scripts are made for the Linux and OSX. For using the scripts, you should run it by using shell command interface such as bash/zsh. 

## Usage
### 1. Clone this repository
```
$git clone https://github.com/funkywoong/aws-user-auth.git
```
### 2. Modify ***config.txt*** following your requirements
 - **target_bucket** means the S3 bucket you want to use
 - **folder_prefix** means the prefix of folder created by this scripts. Postfix number increases sequentially like '20_u10-01_0', '20_u10-01_1'
 - **user_prefix** means the prefix of user created by this scripts. Postfix number increases sequentially like '_u-01_1', '_u-01_2'
 - **user_number** means how many folders or users you want to create.
 - **temporal_password** means the first password embeded in newly-created user. The password will have to be changed by users when they access their console at the first time.

### 3. Run the scripts
 - Creating S3 folders
```
$sh s3_folder_setup.sh 
```
 - Creating IAM users
```
$sh iam_setup.sh
```

