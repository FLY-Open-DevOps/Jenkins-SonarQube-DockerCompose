FROM jenkins/jenkins:2.277.3-lts-jdk11
USER root
RUN apt-get update && apt-get install -y apt-transport-https \
ca-certificates curl gnupg2 \
software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/debian \
$(lsb_release -cs) stable"
RUN apt-get update && apt-get install -y docker-ce-cli build-essential gcc
USER root
RUN jenkins-plugin-cli --plugins "blueocean:1.24.6 docker-workflow:1.26"
