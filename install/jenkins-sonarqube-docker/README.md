# 自动化代码质量管理平台: 基于Docker Compose整合Jenkins + SonarQube 

## 本文目标

> Jenkins ver. 2.207
>
> java version "1.8.0_181"
>
> sonarqube:8.5.0-community
>
> postgres:13-alpine
>
> Gitlab
>
> 

## 环境要求

### 系统环境

> CentOS7

### 组件版本

> Jenkins ver. 2.207
>
> java version "1.8.0_181"
>
> sonarqube:8.5.0-community
>
> postgres:13-alpine
>
> Gitlab

## 部署流程

### 拉取代码

```shell
git clone https://github.com/andrevilas/jenkins-sonarqube-docker-environment.git
```

### 进入文件目录

```shell
cd jenkins-sonarqube-docker-environment
```

### 执行启动脚本

```shell
bash deploy-jenkins-sonarqube-stack.sh
```

### 部署成功信息

```shell
Creating nginx-reverse-proxy ... done
Creating postgres            ... done
Creating docker-in-docker    ... done
Creating jenkins             ... done
Creating sonarqube           ... done
O deploy das aplicaçãoes foi finalizado!
Acesse o Jenkins em http://[HOST-ADDRESS]/jenkins
Acesse o SonarQube em http://[HOST-ADDRESS]/sonar
```

### 查看容器是否正常启动

```shell
[root@localhost jenkins-sonarqube-docker]# docker ps -a
CONTAINER ID   IMAGE                                COMMAND                  CREATED          STATUS          PORTS                                                                        NAMES
1f34f481eca8   jenkins-sonarqube-docker_sonarqube   "bin/run.sh -Dsonar.…"   15 seconds ago   Up 10 seconds   9000/tcp                                                                     sonarqube
11e173361c4b   jenkins-sonarqube-docker_jenkins     "/sbin/tini -- /usr/…"   15 seconds ago   Up 10 seconds   8080/tcp, 50000/tcp                                                          jenkins
ce2fc939c0cb   jenkins-sonarqube-docker_nginx       "/docker-entrypoint.…"   28 seconds ago   Up 26 seconds   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:9871-9872->9871-9872/tcp   nginx-reverse-proxy
5175655cbd1a   docker:dind                          "dockerd-entrypoint.…"   29 seconds ago   Up 26 seconds   2375/tcp, 0.0.0.0:2376->2376/tcp                                             docker-in-docker
0910d9f57220   postgres:latest                      "docker-entrypoint.s…"   33 seconds ago   Up 29 seconds   5432/tcp                                                                     postgres
e02f0776eed4   registry:2                           "/entrypoint.sh /etc…"   3 months ago     Up 24 hours     0.0.0.0:5000->5000/tcp                                                       registry2
d0e69ccfc489   portainer/portainer-ce               "/portainer"             3 months ago     Up 24 hours     0.0.0.0:8000->8000/tcp, 0.0.0.0:9000->9000/tcp                               portainer

```

## 环境配置

### Jenkins

#### Jenkins初始密码查看

```shell
docker logs jenkins
```

> 2021-05-21 06:21:49.191+0000 [id=43]	INFO	hudson.model.AsyncPeriodicWork#lambda$doRun$0: Started Download metadata
> 2021-05-21 06:21:49.196+0000 [id=43]	INFO	hudson.model.AsyncPeriodicWork#lambda$doRun$0: Finished Download metadata. 5 ms
> 2021-05-21 06:21:49.809+0000 [id=28]	INFO	jenkins.install.SetupWizard#init: 
>
> *************************************************************
>
> *************************************************************
>
> *************************************************************
>
> Jenkins initial setup is required. An admin user has been created and a password generated.
> Please use the following password to proceed to installation:
>
> 67868dccf20d4883a2584804987b3ae4
>
> This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
>
> *************************************************************
>
> *************************************************************
>
> *************************************************************
>
> 2021-05-21 06:22:28.417+0000 [id=28]	INFO	jenkins.InitReactorRunner$1#onAttained: Completed initialization
> 2021-05-21 06:22:29.318+0000 [id=22]	INFO	hudson.WebAppMain$3#run: Jenkins is fully up and running
> 2021-05-21 06:27:53.196+0000 [id=73]	INFO	hudson.model.AsyncPeriodicWork#lambda$doRun$0: Started Periodic background build discarder
> 2021-05-21 06:27:53.209+0000 [id=73]	INFO	hudson.model.AsyncPeriodicWork#lambda$doRun$0: Finished Periodic background build discarder. 8 ms

## 安装SonarQube Plugin

管理员权限登录Jenkins，选择：系统管理-->插件管理-->可选插件；搜索SonarQube Plugin，勾选，安装后重新启动JenKins。

由于我的环境是内网环境，所以只能采取离线安装的方式：

选择：系统管理-->插件管理-->高级-->上传插件，上传插件完成安装，离线插件的下载地址：https://plugins.jenkins.io/sonar/ 。

## 配置SonarQube Scanner

除了安装Plugin，还需要安装Scanner作为扫描的客户端，同样我们采用离线安装的方式，SonarQube Scanner的下载地址：https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/ ，这里我使用了当下最新的版本，[sonar-scanner-cli-4.5.0.2216-linux.zip](https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.5.0.2216-linux.zip) 。

> 如果Jenkins配置了Slave节点，那么每个节点都需要安装scanner！！！

下载之后解压到 `/var/jenkins_home/` ，并将文件夹重命名为 `sonar-scanner`。

管理员权限登录进入：系统管理--> 全局工具配置-->SonarQube Scanner，配置Scanner：

![img](https://img2020.cnblogs.com/blog/2119369/202010/2119369-20201012101105230-600807847.png)

## 配置SonarQube Servers

系统管理-->系统设置-->SonarQube servers，填写Name和Server URL，Name可以随意填写，Server URL就是SonarQube的url地址，除此之外，还需要配置token，token需要在在SonarQube中生成。

![img](https://img2020.cnblogs.com/blog/2119369/202010/2119369-20201012101123682-1004066665.png)

将生成的token配置为Jenkins的凭据：

![img](https://img2020.cnblogs.com/blog/2119369/202010/2119369-20201012101140479-1078983911.png)

凭据配置完成后，配置SonarQube Servers，最终效果图如下：

![img](https://img2020.cnblogs.com/blog/2119369/202010/2119369-20201012101154992-1169356119.png)

至此，Jenkins的配置全部完成，接下来开始配置Git触发Jenkins扫描。

## Jenkins Job配置

这里假设Jenkins的Job已经配置好，我们可以选择在 `Pre Steps`或者 `Post Steps`进行Sonar的配置，这里我选择了在 `Post Steps`进行SonarQube的配置：

![img](https://img2020.cnblogs.com/blog/2119369/202010/2119369-20201012101223217-323864600.png)

主要配置Analysis properties，我的配置如下：

```properties
#key和name保持一致且在sonar下唯一
sonar.projectKey=${POM_GROUPID}:${POM_ARTIFACTID}
sonar.projectName=${POM_ARTIFACTID}
#工程版本
sonar.projectVersion=${GIT_BRANCH}  
#sonar.branch.name=${GIT_BRANCH} 
#源代码目录
sonar.sources=$WORKSPACE
#分析的语言 
sonar.language=java
#编码sonar.sourceEncoding=UTF-8
sonar.java.binaries=$WORKSPACE
# setting the java class version
sonar.java.source=1.8
```

完整配置如图：

![img](https://img2020.cnblogs.com/blog/2119369/202010/2119369-20201012101239409-1561517709.png)

完成后进行自动扫描，Jenkins Job的界面和Sonar的界面分别如下：

![img](https://img2020.cnblogs.com/blog/2119369/202010/2119369-20201012101252633-1946309780.png)

![img](https://img2020.cnblogs.com/blog/2119369/202010/2119369-20201012101306441-116241548.png)

# 其他

社区版的SonarQube不支持多分支的扫描，目前有个开源插件可以支持，但是只支持有限的版本，有兴趣的可以尝试一下：https://github.com/mc1arke/sonarqube-community-branch-plugin 。

## SonarQube

#### 整合阿里Java开发规范（p3c-pmd）

> https://github.com/search?o=desc&q=sonar-p3c&s=updated&type=Repositories
>
> https://www.cnblogs.com/sincoolvip/p/13953743.html

### 默认检查规则配置

> 虽然已经集成了阿里P3C,但是使用的还是默认规则，这里我们需要设置为指定规则。
>
> 以admin账号登陆，打开 `质量配置` 页，点击右上方的`创建`按钮，创建 `p3c profiles`



# 问题记录



### Jenkins初始密码查看

```shell
docker logs jenkins
```

> 2021-05-21 06:21:49.191+0000 [id=43]	INFO	hudson.model.AsyncPeriodicWork#lambda$doRun$0: Started Download metadata
> 2021-05-21 06:21:49.196+0000 [id=43]	INFO	hudson.model.AsyncPeriodicWork#lambda$doRun$0: Finished Download metadata. 5 ms
> 2021-05-21 06:21:49.809+0000 [id=28]	INFO	jenkins.install.SetupWizard#init: 
>
> *************************************************************
> *************************************************************
> *************************************************************
>
> Jenkins initial setup is required. An admin user has been created and a password generated.
> Please use the following password to proceed to installation:
>
> 67868dccf20d4883a2584804987b3ae4
>
> This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
>
> *************************************************************
> *************************************************************
> *************************************************************
>
> 2021-05-21 06:22:28.417+0000 [id=28]	INFO	jenkins.InitReactorRunner$1#onAttained: Completed initialization
> 2021-05-21 06:22:29.318+0000 [id=22]	INFO	hudson.WebAppMain$3#run: Jenkins is fully up and running
> 2021-05-21 06:27:53.196+0000 [id=73]	INFO	hudson.model.AsyncPeriodicWork#lambda$doRun$0: Started Periodic background build discarder
> 2021-05-21 06:27:53.209+0000 [id=73]	INFO	hudson.model.AsyncPeriodicWork#lambda$doRun$0: Finished Periodic background build discarder. 8 ms

[SonarQube Community 实现多分支扫描分析](https://www.cnblogs.com/daodaotest/p/13164513.html)