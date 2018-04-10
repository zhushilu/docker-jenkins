# docker-jenkins
实际构建过程最好是在国外主机上，否则许多包的添加会超时。


## 公司地址
`xxxxxx/platform/jenkins-comall:new`
镜像地址

`xxxxxx/platform/jenkins-comall:new-secret`
添加了公司gitlab私钥的镜像

## dockerhub地址
`zhusl/jenkins-comall`

## 说明

一个定制化程度较高的 Jenkins 镜像，跳过了系统的缺省初始化过程，在使用中可以方便的加入自己的
Groovy 初始化代码、设置初始用户，以及替换 config.xml。

提供了 install-plugins.sh 脚本，用于安装插件及其依赖。

另外还添加了一些 CI/CD 相关的工具。同时支持 Jenkins 的 Master 和 Slave 模式。



## Run

docker run -it -p 3001:8080 --rm  \
-e ADMIN_PASSWORD="MY_PaSS_W0rd" \
-e ADMIN_USER="administrator"  \
--name=jenkins \
xxxxxx/platform/jenkins-comall:new


## Include

- Alpine Linux
- Oracle JDK 8u162
- Jenkins 2.107.1
- Maven 3.5.2
- Jenkins Slave 2.9
- Ansible
- Node 9.10.0
- jq
- bash

## Volumes

- `/usr/share/jenkins/config`: Volume for **initialization**:

  - Any `*.groovy` in it will be copied in to `$JENKINS_HOME/init.groovy.d/`

  - Any `*.xml` in it will be copied in to `$JENKINS_HOME`

- `/data/jenkins`: Jenkins home


- `/data/maven`: Anything in `/data/maven/conf` will be copied (**OVERWRITE**) into /usr/local/share/maven/conf,


## Ports

- 8080: Jenkins

## Env

|Name|Default Value|Comment|
|---|---|---|
|`JAVA_HOME`|`/usr/lib/java`||
|`TIMEZONE`|`Asia/Shanghai`|Will change the system settings, and Jenkins will use it when start up. |
|`JENKINS_MODE`|`MASTER`|`MASTER` or `SLAVE`|
|`MAVEN_HOME`|`/usr/local/share/maven`||
|`JENKINS_HOME`|`/data/jenkins`||
|`ADMIN_USER`|root||
|`ADMIN_PASSWORD`|`abcd!@#$`|
|`JAVA_OPTS`|`JVM 参数`||
