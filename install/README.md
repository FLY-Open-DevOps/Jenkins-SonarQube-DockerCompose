# 自动化代码质量管理平台: 基于Docker Compose整合Jenkins + SonarQube 

## 本文目标

> Java : 1.8.0_181
>
> Jenkins: 2.277.3
>
> sonarqube:8.5.0-community
>
> postgres:13-alpine
>
> Gitlab: 
>

## 环境要求

### 系统环境

> CentOS7

### 组件版本

> Java : 1.8.0_181
>
> Jenkins: 2.277.3
>
> sonarqube:8.5.0-community
>
> postgres:13-alpine
>
> Gitlab: 

## 前言

现如今大家越来越认识到**质量前移**的重要性。如果一开始就写出优质的、经过测试的代码，那么后面的测试阶段将会减少很多不必要的时间。

如果**开发人员迫于业务压力**，一味追求项目开发进度，往往会容易形成大量的“烂代码”。 一般的烂代码体现在逻辑混乱、复杂度高、易读性差、没有单元测试和缺乏必要的注释。如果把这样的“烂代码”编译交付测试团队，那么测试人员势必会发现很多低级缺陷，甚至连冒烟测试都无法通过，这样势必会浪费很多时间，延误测试进度。 

所以，**回到开始，为何不一开始就是写出优质代码呢？**

## 代码评审

我们都知道很多公司都在推行DevOps、推行测试前移，就是让测试人员尽早参与研发过程中来，有很多团队推行了测试人员参与代码评审流程，但是往往效果不是很理想，原因通常是由于测试人员代码能力有限，不熟悉业务代码逻辑，当然也就无法发现正确问题，这样也就而导致测试团队的代码评审变成了摆设。那么问题来了，有什么办法解决这种状况吗？

 如果**测试人员在执行代码评审的时候可以借助一些代码扫描工具，然后针对这些扫描出的问题再进一步分析，这样轻易地可以发现一些真正代码问题**。

## SonarQube简介

在实际的项目中，我们一般使用的多种编程语言，那么我们需要针对多种编程语言的一种扫描工具。

目前主流的是使用SonarQube代码质量分析平台。

> SonarQube是一个开源的代码质量分析平台，便于管理代码的质量，可检查出项目代码的漏洞和潜在的逻辑问题。同时，它提供了丰富的插件，支持多种语言的检测， 如 Java、Python、Groovy、C#、C、C++等几十种编程语言的检测。
>
> 它主要的核心价值体现在如下几个方面：
>
> - 检查代码是否遵循编程标准：如命名规范，编写的规范等。
> - 检查设计存在的潜在缺陷：SonarQube通过插件Findbugs、Checkstyle等工具检测代码存在的缺陷。
> - 检测代码的重复代码量：SonarQube可以展示项目中存在大量复制粘贴的代码。
> - 检测代码中注释的程度：源码注释过多或者太少都不好，影响程序的可读可理解性。
> - 检测代码中包、类之间的关系：分析类之间的关系是否合理，复杂度情况。

## 概述

![SonarQube实例组件](https://docs.sonarqube.org/latest/images/dev-cycle.png)

在典型的开发过程中：

1. 开发人员在IDE中开发和合并代码（最好使用[SonarLint](https://www.sonarlint.org/)在编辑器中接收即时反馈），然后将其代码签入ALM。
2. 组织的持续集成（CI）工具可以检出，构建和运行单元测试，而集成的SonarQube扫描仪可以分析结果。
3. 扫描程序将结果发布到SonarQube服务器，该服务器通过SonarQube接口，电子邮件，IDE内通知（通过SonarLint）和对拉取或合并请求的修饰（使用[Developer Edition](https://redirect.sonarsource.com/editions/developer.html)及更高[版本](https://redirect.sonarsource.com/editions/developer.html)时）向开发人员提供反馈。

## 部署流程

### 拉取代码

```shell
git clone https://github.com/andrevilas/jenkins-sonarqube-docker-environment.git
```

### 进入文件目录

```shell
cd jenkins-sonarqube-docker-environment
```

### 创建数据卷目录

```shell
# jenkins
mkdir -p /home/data/jenkins/jenkins_home
mkdir -p /home/data/jenkins/certs/client

# sonarqube
mkdir -p /home/data/sonarqube/conf
mkdir -p /home/data/sonarqube/data
mkdir -p /home/data/sonarqube/logs
mkdir -p /home/data/sonarqube/extensions/plugins
mkdir -p /home/data/sonarqube/lib/bundled-plugins

# postgresql
mkdir -p /home/data/postgresql
mkdir -p /home/data/postgresql/data

chmod  777 /home/data/jenkins/certs/client
chmod  777 /home/data/jenkins/certs/client
chmod  777 /home/data/sonarqube/conf
chmod  777 /home/data/sonarqube/data
chmod  777 /home/data/sonarqube/logs
chmod  777 /home/data/sonarqube/extensions/plugins
chmod  777 /home/data/sonarqube/lib/bundled-plugins
chmod  777 /home/data/postgresql
chmod  777 /home/data/postgresql/data
```

![image-20210522160231726](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522160231726.png)

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



### Jenkins集成gitlab

> jenkins中添加gitlab插件，选择直接安装，然后服务器中重启jenkins。

![image-20210522175928337](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522175928337.png)



##### gitlab中生成AccessToken

> gitlab，在gitlab中用户设置—>访问令牌选项中生成token,scope为第一个等级:api

![image-20210522175402618](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522175402618.png)

> GC73XmRJhztnCj14a8Dk

##### jenkins中添加gitlab中生成的token



![image-20210522180506142](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522180506142.png)

## jenkins集成sonarqube

### 获取sonarqube的Token

> 打sonarqube,点击Administrator->security->user，点击token按钮，输入key后再点击generate进行生成,复制该token
>
> d4e16d149805fb113737e6d682486f8e18258dd0

![image-20210522182830084](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522182830084.png)

### jenkins中安装sonar插件

> jenkins中要实现代码扫描，需要在jenkins中安装SonarQube Scanner插件。
>
> 从jenkins的“系统管理”-“管理插件”中找到SonarQube Scanner插件并下载安装，重启jenkins后生效。

![image-20210522183514907](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522183514907.png)

### jenkins中配置sonar插件

#### SonarQube servers 配置

> 在jenkins中，进入“系统管理”-“系统设置”-“SonarQube servers”配置。
>
> 勾上“Enable injection of SonarQube server configuration ...”选项，
>
> 输入“Name”、“Server URL”以及“Server authentication token”。
>
> token为前面部署sonarqube服务器时创建的token。

#### SonarQube Scanner配置

> 进入“系统管理”-“全局工具配置”-“SonarQube Scanner”，点击“SonarQube Scanner 安装”并配置SonarQube Scanner。



### **编写声明式Jenkinsfile**

```kotlin
pipeline {
    agent any
    options {
        timestamps()    //设置在项目打印日志时带上对应时间
        disableConcurrentBuilds()   //不允许同时执行流水线，被用来防止同时访问共享资源等
        timeout(time: 5, unit: 'MINUTES')   // 设置流水线运行超过n分钟，Jenkins将中止流水线
        buildDiscarder(logRotator(numToKeepStr: '20'))   // 表示保留n次构建历史
    }

    //gitlab  webhook触发器
    //triggers{
    //   gitlab( triggerOnPush: true,                       //代码有push动作就会触发job
    //       triggerOnMergeRequest: true,                   //代码有merge动作就会触发job
    //        branchFilterType: "NameBasedFilter",          //只有符合条件的分支才会触发构建 “ALL/NameBasedFilter/RegexBasedFilter”
    //        includeBranchesSpec: "${JOB_BASE_NAME}")      //基于branchFilterType值，输入期望包括的分支的规则
    //}

    stages{
        stage('Print Message') {      //打印信息
            steps {
                echo '打印信息'
                echo "project: ${Project_name}"
                echo "workspace: ${WORKSPACE}"
                echo "branch: ${Branch_name}"           //gitlab分支名
                echo "build_id: ${BUILD_ID}"
           }
        }
        //此步骤在调试Jenkinsfile时可以注释以便了解目录结构
        stage('Delete Workspace') {         //清理工作目录
            steps {
                echo "清理工作目录: ${WORKSPACE}"
                deleteDir()     //表示删除当前目录(${WORKSPACE})下内容，通常用在构建完毕之后清空工作空间
            }
        }
        stage ('Checkout'){         //拉取代码
            steps{
                echo '拉取代码'
                script {
                    checkout([$class: 'GitSCM', branches: [[name: '${Branch_name}']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [],
                        userRemoteConfigs: [[credentialsId: '7ff3778d-124f-40b1-a5e6-05db20a7e59e',     //gitlab登录令牌，设置自行搜索方法
                        url: 'http://192.168.1.101/java/${Project_name}.git']]])    //gitlab项目clone地址
                }
            }
        }
        stage('Sonar-canner') {   //sonar-scanner代码检查
            steps {
                echo '代码检查'
                dir ('./') {       //指定工作目录（默认为${WORKSPACE}）
                    script {
                        sh 'source /etc/profile && mvn clean package  -Dmaven.test.skip=true'
                        sh 'sonar-scanner'  //执行命令开始扫描代码(前提要maven编译生成classes文件)
                    }
                }
            }
        }
        
    }
}
```



## SonarQube

> 默认账号密码 `admin`,`admin`登录SonarQube

### 创建访问Token

> 点击右侧头像--我的账号--安全
>
> 或者访问 http://192.168.172.128/sonar/account/security/
>
> 6b8f15b2c6557500f36d2616cb4c37599fd63724

![image-20210522164344569](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522164344569.png)

![image-20210522164538625](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522164538625.png)

#### 整合阿里Java开发规范（p3c-pmd）

> https://github.com/search?o=desc&q=sonar-p3c&s=updated&type=Repositories
>
> https://www.cnblogs.com/sincoolvip/p/13953743.html

### 默认检查规则配置

> 虽然已经集成了阿里P3C,但是使用的还是默认规则，这里我们需要设置为指定规则。
>
> 以admin账号登陆，打开 `质量配置` 页，点击右上方的`创建`按钮，创建 `p3c profiles`



# 问题记录

## SonarQube多分支的扫描

### 说明

`SonarQube Community` 版本不支持多分支扫描，

`SonarQube Developer Edition` 及以上版本是支持多分支扫描的，扫描时指定分支参数`-Dsonar.branch=develop`即可，就可以实现多分支代码扫描。

```bash
$ mvn clean verify sonar:sonar -Dmaven.test.skip=true -Dsonar.branch=master
```

### 社区版多分支扫描

经过搜索和分析 Sonar 扫描原理，目前有2种方式可以实现。

- 开源插件：sonarqube-community-branch-plugin
- 替换 sonar.projectKey，porjectKey 相等于 Sonar 中每个项目的主键 ID，替换后就会以新项目创建

### 开源插件

插件地址：https://github.com/mc1arke/sonarqube-community-branch-plugin

大致操作步骤：

- 下载插件放到`${SONAR_HOME}/extensions/plugins`目录下，重启 Sonar。
- 扫描时，增加`-Dsonar.branch.name=${GIT_BRANCH}`即可。

#### 替换 sonar.projectKey

扫描时，指定不同的 `sonar.projectKey` 即可。

```bash
# jenkins 设置 projectName，projectKey 为 job 名称
# job 名称规范： 工程名称-分支名称
$ clean verify sonar:sonar -Dmaven.test.skip=true -Dsonar.projectName=${JOB_NAME} -Dsonar.projectKey=${JOB_NAME}
```

## Java项目作为示例进行扫描

> ```shell
> #执行扫描
> mvn sonar:sonar \
>   -Dsonar.host.url=http://192.168.88.45:9000 \
>   -Dsonar.login=8e359701283af794e8b77f3029863a1be7ad8ee4
>   
> mvn sonar:sonar -Dsonar.host.url=http://sonar.juneyaoair.com:9000 -Dsonar.login=aaa-Dsonar.password=aaa
> ```

### Sonar报表指标简介

| 指标              | 简介                   |
| :---------------- | :--------------------- |
| Bugs              | bug个数及评分          |
| Vulnerabilities   | 安全漏洞个数及评分     |
| Debt              | 债务(代码问题)持续时间 |
| Code Smells       | 轻微问题：代码风格等等 |
| Coverage          | 单元测试覆盖率         |
| Duplications      | 代码重复率             |
| Duplicated Blocks | 代码重复块数           |