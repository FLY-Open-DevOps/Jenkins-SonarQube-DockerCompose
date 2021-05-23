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

## 环境配置

### Jenkinss

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

## SonarQube

#### 整合阿里Java开发规范（p3c-pmd）

> https://github.com/search?o=desc&q=sonar-p3c&s=updated&type=Repositories

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