#!/bin/bash

LOGFILE_DIRECTORY=/tmp
DATE=$(date +%F:%H:%M:%S)
SCRIPT_NAME=$0
LOGFILE=$LOGFILE_DIRECTORY/$SCRIPT_NAME-$DATE.log
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
 echo -e " Execute with root user"
 exit 1
 fi

 VALIDATE(){
if [ $1 -ne 0 ];
then
    echo -e "$2....$R FAILURE $N "
    exit 1
else
   echo -e "$2... $G SUCCESS $N "
   fi
 
 }

yum install nginx -y &>> LOG_FILE

VALIDATE $? " nginx installation "

systemctl enable nginx &>> LOG_FILE

VALIDATE $? " nginx enable "

systemctl start nginx &>> LOG_FILE

VALIDATE $? " nginx start"
rm -rf /usr/share/nginx/html/* &>> LOG_FILE

VALIDATE $? " REmoving the default nginx html code"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> LOG_FILE

VALIDATE $? "Downloading the souce code"

cd /usr/share/nginx/html &>> LOG_FILE

VALIDATE $? "Moved to the html path"

unzip /tmp/web.zip &>> LOG_FILE

VALIDATE $? " unzipped the code in tmp folder"

cp /root/roboshop_shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> LOG_FILE

VALIDATE $? " editting the conf folder"

systemctl restart nginx &>> LOG_FILE

VALIDATE $? " RESTART Triggered"



