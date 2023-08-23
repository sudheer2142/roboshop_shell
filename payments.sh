#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
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

yum install python36 gcc python3-devel -y &>>$LOGFILE

VALIDATE $? "Installing python"

USER_ROBOSHOP=$(id roboshop)
if [ $? -ne 0 ];
then 
    echo -e "$Y...USER roboshop is not present so creating one now..$N"
    useradd roboshop &>>$LOGFILE
else 
    echo -e "$G...USER roboshop is already present so  skipping now.$N"
 fi

#write a condition to check directory already exist or not
VALIDATE_APP_DIR=$(cd /app)
#write a condition to check directory already exist or not
if [ $? -ne 0 ];
then 
    echo -e " $Y /app directory not there so creating one $N"
    mkdir /app &>>$LOGFILE   
else
    echo -e "$G /app directory already present so skipping ....$N" 
    fi

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE

VALIDATE $? "Downloading artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving to app directory"

unzip /tmp/payment.zip

VALIDATE $? "unzip artifact"

pip3.6 install -r requirements.txt &>>$LOGFILE

VALIDATE $? "Installing dependencies"

cp /root/roboshop_shell/payment.service /etc/systemd/system/payment.service &>>$LOGFILE

VALIDATE $? "copying payment service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable payment  &>>$LOGFILE

VALIDATE $? "enable payment"

systemctl start payment &>>$LOGFILE

VALIDATE $? "starting payment"