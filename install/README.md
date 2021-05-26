# 自动化代码质量管理平台: 基于Docker Compose整合Jenkins + SonarQube 

## 本文目标

> 1. 提交SpringBoot项目代码至GitLab
>2. GitLab通过WebHook自动触发Jenkins执行任务
> 3. Jenkins获取代码，执行Sonar(阿里代码规约)分析代码。
>4. 在Sonar的服务器界面查看代码审查结果
> 5. 在IDE的SonrLint中实时查看代码审查结果

## 环境要求

### 系统环境

> CentOS 7

| 工具/环境      | 版本    |
| -------------- | ------- |
| CentOS         | 7       |
| Docker         | 20.10.2 |
| Docker-Compose | 1.28.2  |

### 组件服务版本

| 工具/环境 | 版本            |
| --------- | --------------- |
| Jenkins   | 2.277.3         |
| Sonarqube | 8.5.0-community |
| postgres  | 13-alpine       |
| GitLab    |                 |
| Maven     | 3.6.3           |
| JDK       | 1.8.0_292       |

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

![SonarQube实例组件](https://docs.Sonarqube.org/latest/images/dev-cycle.png)

在典型的开发过程中：

1. 开发人员在IDE中开发和合并代码（最好使用[SonarLint](https://www.Sonarlint.org/)在编辑器中接收即时反馈），然后将其代码签入ALM。
2. 组织的持续集成（CI）工具可以检出，构建和运行单元测试，而集成的SonarQube扫描仪可以分析结果。
3. 扫描程序将结果发布到SonarQube服务器，该服务器通过SonarQube接口，电子邮件，IDE内通知（通过SonarLint）和对拉取或合并请求的修饰（使用[Developer Edition](https://redirect.Sonarsource.com/editions/developer.html)及更高[版本](https://redirect.Sonarsource.com/editions/developer.html)时）向开发人员提供反馈。

## 部署流程

### **检查系统参数**

> sysctl vm.max_map_count #vm.max_map_count 大于或等于524288
>
> sysctl fs.file-max #fs.file-max 大于或等于131072
>
> ulimit –n #SonarQube的用户可以打开至少131072个文件描述符
>
> ulimit –u #运行SonarQube的用户可以打开至少8192个线程

### **设置系统参数**

```shell
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
```

### 拉取代码

```shell
git clone https://github.com/andrevilas/Jenkins-Sonarqube-docker-environment.git
```

### 进入文件目录

```shell
cd Jenkins-Sonarqube-docker-environment
```

### 创建数据卷目录

```shell
# Jenkins
mkdir -p /home/data/Jenkins/Jenkins_home

cd /home/data/Jenkins
chown -R 1000 Jenkins_home #把当前目录的拥有者赋值给uid 1000

# Sonarqube
mkdir -p /home/data/Sonarqube/conf
mkdir -p /home/data/Sonarqube/data
mkdir -p /home/data/Sonarqube/logs
mkdir -p /home/data/Sonarqube/extensions/plugins
mkdir -p /home/data/Sonarqube/lib/bundled-plugins

# postgresql
mkdir -p /home/data/postgresql
mkdir -p /home/data/postgresql/data

chmod  777 /home/data/Jenkins/Jenkins_home

chmod  777 /home/data/Sonarqube/conf
chmod  777 /home/data/Sonarqube/data
chmod  777 /home/data/Sonarqube/logs
chmod  777 /home/data/Sonarqube/extensions/plugins
chmod  777 /home/data/Sonarqube/lib/bundled-plugins
chmod  777 /home/data/postgresql
chmod  777 /home/data/postgresql/data
```

![image-20210522160231726](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522160231726.png)

### 执行启动脚本

```shell
bash deploy-Jenkins-Sonarqube-stack.sh
```

### 部署成功信息

```shell
Creating nginx-reverse-proxy ... done
Creating postgres            ... done
Creating docker-in-docker    ... done
Creating Jenkins             ... done
Creating Sonarqube           ... done
O deploy das aplicaçãoes foi finalizado!
Acesse o Jenkins em http://[HOST-ADDRESS]/Jenkins
Acesse o SonarQube em http://[HOST-ADDRESS]/Sonar
```

### 查看容器是否正常启动

```shell
[root@localhost Jenkins-Sonarqube-docker]# docker ps -a
CONTAINER ID   IMAGE                                COMMAND                  CREATED          STATUS          PORTS                                                                        NAMES
1f34f481eca8   Jenkins-Sonarqube-docker_Sonarqube   "bin/run.sh -DSonar.…"   15 seconds ago   Up 10 seconds   9000/tcp                                                                     Sonarqube
11e173361c4b   Jenkins-Sonarqube-docker_Jenkins     "/sbin/tini -- /usr/…"   15 seconds ago   Up 10 seconds   8080/tcp, 50000/tcp                                                          Jenkins
ce2fc939c0cb   Jenkins-Sonarqube-docker_nginx       "/docker-entrypoint.…"   28 seconds ago   Up 26 seconds   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:9871-9872->9871-9872/tcp   nginx-reverse-proxy
5175655cbd1a   docker:dind                          "dockerd-entrypoint.…"   29 seconds ago   Up 26 seconds   2375/tcp, 0.0.0.0:2376->2376/tcp                                             docker-in-docker
0910d9f57220   postgres:latest                      "docker-entrypoint.s…"   33 seconds ago   Up 29 seconds   5432/tcp                                                                     postgres
e02f0776eed4   registry:2                           "/entrypoint.sh /etc…"   3 months ago     Up 24 hours     0.0.0.0:5000->5000/tcp                                                       registry2
d0e69ccfc489   portainer/portainer-ce               "/portainer"             3 months ago     Up 24 hours     0.0.0.0:8000->8000/tcp, 0.0.0.0:9000->9000/tcp                               portainer

```

## 环境配置

![img](http://ww1.sinaimg.cn/large/007vhU0ely1g2w0v9k2jmj30m80ovwer.jpg)

### Jenkins初始密码查看

```shell
docker logs Jenkins
或者
# Get the initial admin password
docker exec my-Jenkins-3 cat /var/Jenkins_home/secrets/initialAdminPassword
```

> 2021-05-21 06:21:49.809+0000 [id=28]	INFO	Jenkins.install.SetupWizard#init: 
> 
> *************************************************************
>
> *************************************************************
>
> *************************************************************
>
> Jenkins initial setup is required. An admin user has been created and a password generated.
>Please use the following password to proceed to installation:
> 
> 67868dccf20d4883a2584804987b3ae4
>
> This may also be found at: /var/Jenkins_home/secrets/initialAdminPassword
>
> *************************************************************
>
> *************************************************************
>
> *************************************************************
>
> 2021-05-21 06:22:28.417+0000 [id=28]	INFO	Jenkins.InitReactorRunner$1#onAttained: Completed initialization

### Jenkins集成GitLab

> Jenkins中添加GitLab插件，选择直接安装，然后服务器中重启Jenkins。

![image-20210522175928337](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522175928337.png)



#### GitLab中生成AccessToken

> GitLab，在GitLab中用户设置—>访问令牌选项中生成token,scope为第一个等级:api

![image-20210522175402618](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522175402618.png)

> GC73XmRJhztnCj14a8Dk
>
> F9LvpyU5dBK7iuf9Xst4

#### Jenkins中添加GitLab中生成的token

![image-20210522180506142](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522180506142.png)

#### 测试Jenkins连接GitLab

![image-20210525103938207](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210525103938207.png)

### Jenkins集成Maven

> 在宿主机环境安装maven, 记得修改和生效/etc/profile

```shell
export MAVEN_HOME=/usr/local/jt/apache-maven-3.6.3
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64/jre/bin/java
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$MAVEN_HOME/bin:$JAVA_HOME/bin:$PATH
```

![image-20210525111220044](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210525111220044.png)

#### 配置maven

> 进入“系统管理”-“全局工具配置”-“Maven”，配置maven

![image-20210525162931117](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210525162931117.png)

##### settings.xml配置

![image-20210525162849056](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210525162849056.png)

#### 安装“Maven Integration”插件

![image-20210525142148859](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210525142148859.png)

#### 创建Maven任务(单模块)

> 进入任务的配置界面，在`源码管理`设置部分，选择“Git”，配置好工程的git地址以及获取代码的凭证信息。
>
> 然后在“Additional Behaviours”中添加“Clean before checkout”。可以根据自己的需要在“Branches to build”中设置所需要获取的代码分支。

![image-20210525141944865](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210525141944865.png)

##### 源码管理

> 在源码管理设置部分，选择“Git”，配置好工程的git地址以及获取代码的凭证信息。然后在“Additional Behaviours”中添加“Clean before checkout”。可以根据自己的需要在“Branches to build”中设置所需要获取的代码分支。

![image-20210525151731687](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210525151731687.png)

在“构建环境”配置中勾选“Prepare SonarQube Scanner environment”。

##### 添加“Execute SonarQube Scanner”

> 在“Post Steps”中点击“Add post-build step”，添加“Execute SonarQube Scanner”。

![image-20210525160721229](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210525160721229.png)

##### Maven项目-单模块

```properties
sonar.projectKey=webvr-end
sonar.projectName=webvr-end
sonar.language=java
sonar.java.binaries=$WORKSPACE/target/classes/ 
sonar.sources=$WORKSPACE/src
```

参数说明：

| 参数项               | 说明                                                         |
| -------------------- | ------------------------------------------------------------ |
| sonar.projectKey     | 项目Key，需要唯一，建议使用GroupId+ArtifactId                |
| sonar.projectName    | 项目名称，跟ArtifactId保持一致即可                           |
| sonar.projectVersion | 项目版本，跟pom.xml保持一致即可                              |
| sonar.sources        | 源码目录，Java项目默认就是src，如果项目有多个module，那就需要配置为{moduleDirectory}/src |
| sonar.java.binaries  | 编译产出的classes目录，如果项目有多个module，那就需要配置为{moduleDirectory}/target/classes |
| sonar.language       | 项目语言，例如 Java、NodeJS、C#、PHP 等                      |

![image-20210525185716097](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210525185716097.png)

## **GitLab Push 自动触发Jenkins构建**

#### 点击构建触发器

> 根据需要选择触发事件, 我这里选择了Push Events 和 Opened

![image-20210526164709521](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526164709521.png)





> 554d19ea326bb5ee22e3f016073f7d56

![image-20210526164722345](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526164722345.png)





![image-20210526165925933](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526165925933.png)



![image-20210526153358222](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526153358222.png)



![image-20210526153104155](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526153104155.png)





![image-20210526153242568](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526153242568.png)

```shell
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
                        userRemoteConfigs: [[credentialsId: 'F9LvpyU5dBK7iuf9Xst4',     //gitlab登录令牌，设置自行搜索方法
                        url: 'http://10.0.0.247/jiean/webvr-end.git']]])    //gitlab项目clone地址
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





> clean install -pl xsjt-comp-manager -am -amd -Pdev -Dmaven.test.skip=true

Mvn命令参数

| 参数 | 全称                   | 释义                                                         | 说明                                                         |
| ---- | ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| -pl  | --projects             | Build specified reactor projects instead of all projects     | 选项后可跟随{groupId}:{artifactId}或者所选模块的相对路径(多个模块以逗号分隔) |
| -am  | --also-make            | If project list is specified, also build projects required by the list | 表示同时处理选定模块所依赖的模块                             |
| -amd | --also-make-dependents | If project list is specified, also build projects that depend on projects on the list | 表示同时处理依赖选定模块的模块                               |
| -N   | --Non-recursive        | Build projects without recursive                             | 表示不递归子模块                                             |
| -rf  | --resume-from          | Resume reactor from specified project                        | 表示从指定模块开始继续处理                                   |

> 在“Task to run”中输入scan，即分析代码。
>
> 在“Analysis properties”中输入下面内容。
>
> sonar.language 指定了要分析的开发语言（特定的开发语言对应了特定的规则），
>
> sonar.sources 定义了需要分析的源代码位置（示例中的$WORKSPACE 所指示的是当前 Jenkins 项目的目录），
>
> sonar.java.binaries 定义了需要分析代码的编译后 class 文件位置；sonar.java.source 指定java版本。

```
Caused by: The folder '/var/jenkins_home/workspace/demo-sonar/src' does not exist for 'demo-sonar' (base directory = /var/jenkins_home/workspace/demo-sonar)
WARN: Unable to locate 'report-task.txt' in the workspace. Did the SonarScanner succeed?
ERROR: SonarQube scanner exited with non-zero code: 1
```

> ```
> ERROR: Error during SonarScanner execution
> ERROR: Tasks support was removed in SonarQube 7.6.
> ERROR: 
> ERROR: Re-run SonarScanner using the -X switch to enable full debug logging.
> WARN: Unable to locate 'report-task.txt' in the workspace. Did the SonarScanner succeed?
> ERROR: SonarQube scanner exited with non-zero code: 2
> ```



![image-20210525164519268](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210525164519268.png)



## Jenkins集成Sonarqube

### 获取Sonarqube的Token

> 打Sonarqube,点击Administrator->security->user，点击token按钮，输入key后再点击generate进行生成,复制该token
>
> 2d99bc078e3cd46e4b77aa560ca66b5575a9fc47

![image-20210522182830084](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522182830084.png)

### Jenkins中安装Sonar插件

> Jenkins中要实现代码扫描，需要在Jenkins中安装SonarQube Scanner插件。
>
> 从Jenkins的“系统管理”-“管理插件”中找到SonarQube Scanner插件并下载安装，重启Jenkins后生效。

![image-20210522183514907](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522183514907.png)

### Jenkins中配置Sonar插件

#### SonarQube servers 配置

> 系统管理-->系统设置-->SonarQube servers，填写Name和Server URL，Name可以随意填写，Server URL就是SonarQube的url地址，
>
> 除此之外，还需要配置token，token需要在在SonarQube中生成。

![image-20210524172008754](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210524172008754.png)

SonarQube Scanner配置

> “系统管理”-“全局工具配置”-“SonarQube Scanner”，点击“SonarQube Scanner 安装”并配置SonarQube Scanner。



离线安装的方式，SonarQube Scanner的下载地址：https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/ ，这里我使用了当下最新的版本，[sonar-scanner-cli-4.5.0.2216-linux.zip](https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.5.0.2216-linux.zip) 。

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

    //GitLab  webhook触发器
    //triggers{
    //   GitLab( triggerOnPush: true,                       //代码有push动作就会触发job
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
                echo "branch: ${Branch_name}"           //GitLab分支名
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
                        userRemoteConfigs: [[credentialsId: '7ff3778d-124f-40b1-a5e6-05db20a7e59e',     //GitLab登录令牌，设置自行搜索方法
                        url: 'http://192.168.1.101/java/${Project_name}.git']]])    //GitLab项目clone地址
                }
            }
        }
        stage('Sonar-canner') {   //Sonar-scanner代码检查
            steps {
                echo '代码检查'
                dir ('./') {       //指定工作目录（默认为${WORKSPACE}）
                    script {
                        sh 'source /etc/profile && mvn clean package  -Dmaven.test.skip=true'
                        sh 'Sonar-scanner'  //执行命令开始扫描代码(前提要maven编译生成classes文件)
                    }
                }
            }
        }
        
    }
}
```



## SonarQube

> 默认账号密码 `admin`,`admin`登录SonarQube

### admin用户的权限配置：开启执行分析权限

![image-20210525170358760](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210525170358760.png)

### 创建访问Token

> 点击右侧头像--我的账号--安全
>
> 或者访问 http://192.168.172.128/Sonar/account/security/
>
> 6b8f15b2c6557500f36d2616cb4c37599fd63724

![image-20210522164344569](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522164344569.png)

![image-20210522164538625](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210522164538625.png)

#### 整合阿里Java开发规范（p3c-pmd）

> 虽然已经集成了阿里P3C,但是使用的还是默认规则，这里我们需要设置为指定规则。

##### 创建规则

> 管理员帐户登陆Sonarqube，【质量配置】-创建，填写【名称】和选择【语言】，点击【创建】p3c-java
>
> 点击创建后进入P3C规则界面，点击【更多激活规则】

![image-20210524165400745](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210524165400745.png)

##### 激活规则

> 进入激活界面后，输入【p3c】过滤出规则，规则前都有【p3c】标识，选择【批量修改】，点击【激活p3c-java】

![image-20210524165451615](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210524165451615.png)

##### 设置规则

> 进入【质量配置】，设置默认规则

![image-20210524165552429](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210524165552429.png)

## 支持 Docker

> [Docker-in-Docker: Jenkins CI 内部如何运行 docker](https://glory.blog.csdn.net/article/details/117254938)
>
> https://glory.blog.csdn.net/article/details/117254938

## Jenkins插件离线下载地址

> http://updates.jenkins-ci.org/download/plugins/

## **使用 SonarQube 分析 Maven 项目**

### Maven 的 setting.xml文件

> 我们需要配置 Maven 的 setting.xml文件，增加 sonarQube 配置。

```xml
<settings>
    <pluginGroups>
        <pluginGroup>org.sonarsource.scanner.maven</pluginGroup>
    </pluginGroups>
    <profiles>
        <profile>
            <id>sonar</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <!-- 配置 Sonar Host地址，默认：http://localhost:9000 -->
                <sonar.host.url>
                  http://192.168.172.128:9090
                </sonar.host.url>
            </properties>
        </profile>
     </profiles>
</settings>
```

### 项目或模块的Pom文件

```xml
<build>
    <pluginManagement>
        <!--使用 SonarQube 分析 Maven 项目-->
        <plugin>
            <groupId>org.sonarsource.scanner.maven</groupId>
            <artifactId>sonar-maven-plugin</artifactId>
            <version>3.9.0.2155</version>
        </plugin>
        </plugins>
    </pluginManagement>
</build>

```

### 执行代码分析命令

```shell
mvn clean verify sonar:sonar -DskipTest=true
```

#### 分析输出

```shell
[INFO] ------------- Run sensors on project
[INFO] Sensor Zero Coverage Sensor
[INFO] Sensor Zero Coverage Sensor (done) | time=205ms
[INFO] Sensor Java CPD Block Indexer
[INFO] Sensor Java CPD Block Indexer (done) | time=373ms
[INFO] SCM Publisher is disabled
[INFO] CPD Executor 183 files had no CPD blocks
[INFO] CPD Executor Calculating CPD for 510 files
[INFO] CPD Executor CPD calculation finished (done) | time=456ms
[INFO] Analysis report generated in 371ms, dir size=7 MB
[INFO] Analysis report compressed in 1480ms, zip size=2 MB
[INFO] Analysis report uploaded in 160ms
[INFO] ANALYSIS SUCCESSFUL, you can browse http://192.168.172.128:9090/dashboard?id=com.bigunion%3Abigunion
[INFO] Note that you will be able to access the updated dashboard once the server has processed the submitted analysis report
[INFO] More about the report processing at http://192.168.172.128:9090/api/ce/task?id=AXmnaSyaTReHGmpr1jBO
[INFO] Analysis total time: 1:15.595 s
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary for bigunion 2.3.0:
[INFO]
[INFO] bigunion ........................................... SUCCESS [01:17 min]
[INFO] bigunion-common .................................... SUCCESS [  0.020 s]
[INFO] bigunion-common-core ............................... SUCCESS [  3.103 s]
[INFO] bigunion-api ....................................... SUCCESS [  0.168 s]
[INFO] bigunion-api-system ................................ SUCCESS [  0.441 s]
[INFO] bigunion-common-redis .............................. SUCCESS [  0.362 s]
[INFO] bigunion-common-security ........................... SUCCESS [  0.423 s]
[INFO] bigunion-auth ...................................... SUCCESS [  3.714 s]
[INFO] bigunion-gateway ................................... SUCCESS [  1.622 s]
[INFO] bigunion-common-datascope .......................... SUCCESS [  0.351 s]
[INFO] bigunion-common-log ................................ SUCCESS [  0.340 s]
[INFO] bigunion-common-swagger ............................ SUCCESS [  0.253 s]
[INFO] bigunion-modules ................................... SUCCESS [  0.072 s]
[INFO] bigunion-system .................................... SUCCESS [  3.121 s]
[INFO] bigunion-file ...................................... SUCCESS [  2.189 s]
[INFO] bigunion-exam ...................................... SUCCESS [  4.003 s]
[INFO] bigunion-devicemag ................................. SUCCESS [  5.598 s]
[INFO] bigunion-student ................................... SUCCESS [  2.941 s]
[INFO] bigunion-project ................................... SUCCESS [  3.937 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  01:51 min
[INFO] Finished at: 2021-05-26T14:42:37+08:00
[INFO] ------------------------------------------------------------------------
```

### Sonarqube分析结果

> 登录 http://192.168.172.128:9090/查看

![img](file:///C:/Users/FLY/AppData/Local/Temp/企业微信截图_16220102108769.png)

# SonarLint使用

## 安装插件SonarLint

> **Plugins**菜单, 搜索sonar,选择SonarLint,再点击页面右边的绿底色**Install**按钮

![image-20210526150511157](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526150511157.png)

## 配置SonarLint

> Ctrl+Alt+S呼叫出设置菜单,过滤窗口可以输入sonar,找到SonarLint 菜单
> **SonarLint General Settings** :针对IDEA所有打开项目之后的SonarLint通用配置.
> **SonarLint Project Settings** :针对当前这一个项目配置生效

安装后,底部工具栏也会出现SonarLint,也可以配置编辑

![image-20210526151151568](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526151151568.png)

> 如果没有,或者不小心关闭了.
> 可以点击菜单 **view**->**Tool Windows**中找到 **SonarLint**.重新打开SonarLint窗口

### 关联SonarQube

#### SonarQube地址

> 点击+号, 使用的是本地sonarQube,选择的右边配置,输入sonarQube IP和端口号.完成后点击Next.

![image-20210526145813645](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526145813645.png)

#### 输入SonarQube账户的Token

![image-20210526145906194](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526145906194.png)

#### 连接成功

![image-20210526145940266](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526145940266.png)

## SonarLint审查代码

> 在项目目录结构中选择要分析的文件夹或是代码文件,右键菜单
> **Anaylyze**->**Analyze with SonarLint Https…**
> 或者选中后使用快捷键
> Ctrl+Shift+S

![image-20210526151621531](C:\Users\FLY\AppData\Roaming\Typora\typora-user-images\image-20210526151621531.png)

# 问题记录

## SonarQube多分支的扫描

### 说明

`SonarQube Community` 版本不支持多分支扫描，

`SonarQube Developer Edition` 及以上版本是支持多分支扫描的，扫描时指定分支参数`-DSonar.branch=develop`即可，就可以实现多分支代码扫描。

```bash
$ mvn clean verify Sonar:Sonar -Dmaven.test.skip=true -DSonar.branch=master
```

### 社区版多分支扫描

经过搜索和分析 Sonar 扫描原理，目前有2种方式可以实现。

- 开源插件：Sonarqube-community-branch-plugin
- 替换 Sonar.projectKey，porjectKey 相等于 Sonar 中每个项目的主键 ID，替换后就会以新项目创建

### 开源插件

插件地址：https://github.com/mc1arke/Sonarqube-community-branch-plugin

大致操作步骤：

- 下载插件放到`${Sonar_HOME}/extensions/plugins`目录下，重启 Sonar。
- 扫描时，增加`-DSonar.branch.name=${GIT_BRANCH}`即可。

#### 替换 Sonar.projectKey

扫描时，指定不同的 `Sonar.projectKey` 即可。

```bash
# Jenkins 设置 projectName，projectKey 为 job 名称
# job 名称规范： 工程名称-分支名称
$ clean verify Sonar:Sonar -Dmaven.test.skip=true -DSonar.projectName=${JOB_NAME} -DSonar.projectKey=${JOB_NAME}
```

### Jenkins添加Sonarqube不能添加token问题！！

> https://blog.csdn.net/qq_41554118/article/details/103215716

### Jenkins GitLab api token 点击 add按钮没有反应

> Blocked a frame with origin "http://192.168.172.128" from accessing a cross-origin frame.
>     at HTMLIFrameElement.<anonymous> (http://192.168.172.128/Jenkins/adjuncts/fe8d3312/lib/credentials/select/select.js:156:58)

## Java项目作为示例进行扫描

> ```shell
> #执行扫描
> mvn Sonar:Sonar \
>   -DSonar.host.url=http://192.168.88.45:9000 \
>   -DSonar.login=8e359701283af794e8b77f3029863a1be7ad8ee4
>   
> mvn Sonar:Sonar -DSonar.host.url=http://Sonar.juneyaoair.com:9000 -DSonar.login=aaa-DSonar.password=aaa
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

https://www.cnblogs.com/klvchen/p/13601681.html

#### 使用yum install java-1.8.0-openjdk 安装jdk后, 找不到安装路径或AVA_HOME没有输出信息

> https://glory.blog.csdn.net/article/details/117250344