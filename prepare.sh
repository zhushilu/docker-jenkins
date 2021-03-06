#!/bin/sh

set -xe

#PREPARE
#Linux Version
SIG=`cat /etc/*release | grep  ^NAME | cut -c7`

mkdir -p /usr/share/jenkins/config

cat << EOF > /usr/share/jenkins/config/init.user.groovy
#!groovy

import jenkins.model.*
import hudson.security.*

def user = System.getenv('ADMIN_USER')
def password = System.getenv('ADMIN_PASSWORD')

def instance = Jenkins.getInstance()

println "--> creating local user"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(user,password)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()
EOF
# Alpine
if [ $SIG = "A" ]; then
  apk update
  apk add --update git subversion curl nodejs ansible bash
fi

# Ubuntu
if [ "$SIG" = "U" ]; then
  export DEBIAN_FRONTEND="noninteractive"
  apt-get update
  apt-get -y upgrade
  apt-get install -y --no-install-recommends \
    apt-transport-https ca-certificates npm ansible \
    curl git subversion unzip
fi

curl -L -o /usr/share/jenkins/jenkins.war \
http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war

curl -L -o /usr/share/jenkins/slave.jar \
https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${SLAVE_VER}/remoting-${SLAVE_VER}.jar

curl -L -o apache-maven-$MAVEN_VER-bin.tar.gz \
http://apache.mirror.cdnetworks.com/maven/maven-3/$MAVEN_VER/binaries/apache-maven-$MAVEN_VER-bin.tar.gz
tar xf apache-maven-$MAVEN_VER-bin.tar.gz
mv apache-maven-$MAVEN_VER $MAVEN_HOME
rm apache-maven-$MAVEN_VER-bin.tar.gz

curl -L -o /usr/local/bin/kubectl \
https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VER/bin/linux/amd64/kubectl
chmod a+x /usr/local/bin/kubectl

curl -L -o sonar-scanner-$SONAR_SCANNER_VER.zip \
https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VER.zip
unzip sonar-scanner-$SONAR_SCANNER_VER.zip
mv sonar-scanner-$SONAR_SCANNER_VER $SONAR_HOME
rm sonar-scanner-$SONAR_SCANNER_VER.zip

if [ $SIG = "A" ]; then
  apk add --update py-pip postgresql-dev gcc python-dev musl-dev
fi

if [ "$SIG" = "U" ]; then
  apt-get install python-pip python-setuptools libpq-dev python-dev gcc xvfb firefox \
  -y --no-install-recommends
  pip install --upgrade pip
  curl -L -o /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v0.11.1/geckodriver-v0.11.1-linux64.tar.gz
  tar xf /tmp/geckodriver.tar.gz --directory=/usr/local/bin
  rm  /tmp/geckodriver.tar.gz
fi

pip install --no-cache-dir decorator Django django-filter djangorestframework docutils \
Markdown psycopg2 PyMySQL requests robotframework \
robotframework-databaselibrary robotframework-ftplibrary \
robotframework-requests robotframework-ride \
robotframework-selenium2library

ln -s /usr/local/share/maven/bin/* /usr/local/bin
mkdir -p /data/jenkins
mkdir -p /data/maven
mkdir -p /data/kube
mkdir -p /data/sonar

if [ "$SIG" = "A" ]; then
  apk del --purge postgresql-dev gcc python-dev musl-dev
  rm -rf /var/cache/apk/*
  rm -rf /tmp/*.apk
fi

if [ "$SIG" = "U" ]; then
  apt-get -y purge libpq-dev python-dev gcc
  apt-get -y autoremove
  rm -rf /var/lib/apt/lists/*
fi

install-plugins.sh blueocean
