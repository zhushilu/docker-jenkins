FROM node:8.10.0-alpine


RUN    apk update  ;  apk add --update  bash  curl  wget  tar   unzip   xz gzip 



############安装jdk8####################
######https://github.com/fleeto/docker-java.git########

ENV TIMEZONE="Asia/Shanghai" \
PRODUCT="jdk" \
JAVA_HOME="/usr/lib/java"

COPY prepare-jdk.sh /usr/local/bin
RUN prepare-jdk.sh



############安装jenkins,并初始化################

COPY run.sh /usr/local/bin
COPY prepare.sh /usr/local/bin
COPY config.xml /usr/share/jenkins/config/config.xml
COPY install-plugins.sh /usr/local/bin
COPY jenkins-support /usr/local/bin
ENV JENKINS_HOME="/data/jenkins" \
  MAVEN_HOME="/usr/local/share/maven" \
  SONAR_HOME="/usr/local/share/sonar" \
  MAVEN_VER="3.5.2" \
  SONAR_SCANNER_VER="3.0.3.778" \
  KUBECTL_VER="1.7.10" \
  SLAVE_VER="3.9" \
  JENKINS_MODE="MASTER" \
  TIMEZONE="Asia/Shanghai" \
  JENKINS_UC="https://updates.jenkins-ci.org" \
  REF="$JENKINS_HOME/plugins" \
  ADMIN_USER="root" \
  ADMIN_PASSWORD="abcd!@#$"
RUN prepare.sh

RUN apk update ; apk add openssh

EXPOSE 8080
VOLUME ["/usr/share/jenkins/", "/data/jenkins", "/data/maven", "/data/kube", "/data/sonar", "/data/robot"]
CMD ["run.sh"]
