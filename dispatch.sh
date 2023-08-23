#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}


yum install golang -y

VALIDATE $? "installtion success of golang"

USER_ROBOSHOP=$(id roboshop)
if [ $? -ne 0 ];
then 
    echo -e "$Y...USER roboshop is not present so creating one now..$N"
    useradd roboshop &>>$LOGFILE
else 
    echo -e "$G...USER roboshop is already present so  skipping now.$N"
 fi

 VALIDATE_APP_DIR=$(cd /app)
#write a condition to check directory already exist or not
if [ $? -ne 0 ];
then 
    echo -e " $Y /app directory not there so creating one $N"
    mkdir /app &>>$LOGFILE   
else
    echo -e "$G /app directory already present so skipping ....$N" 
    fi

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOGFILE
VALIDATE $? " downloaded dispatch code "

cd /app 

VALIDATE $? "Changed to /app path "

unzip /tmp/dispatch.zip &>>$LOGFILE

VALIDATE $? "unzipped the code .. "

cd /app 

VALIDATE $? "Changed to /app path "
go mod init dispatch
VALIDATE $? "go init successfull"
go get 
VALIDATE $? "go get triggered"
go build &>>$LOGFILE
VALIDATE $? "go build the code successfull"

cp /root/roboshop_shell/dispatch.service /etc/systemd/system/dispatch.service &>>$LOGFILE

VALIDATE $? "copying the dispatch.service "

systemctl daemon-reload  &>>$LOGFILE

VALIDATE $? " Deamon-relaoded"
systemctl enable dispatch   &>>$LOGFILE
VALIDATE $? " systemctl dipatch enabled"
systemctl start dispatch  &>>$LOGFILE

VALIDATE $? "starting the dispatch"

