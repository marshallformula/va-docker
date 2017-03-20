FROM centos:latest

RUN yum update -y

RUN yum install -y initscripts
RUN yum install -y java-1.8.0-openjdk-devel
RUN yum install -y curl
RUN yum install -y wget
RUN yum install -y rpm-build

RUN yum clean all

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.121-0.b13.el7_3.x86_64
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 6.9.2

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash

RUN source ~/.bashrc && nvm install $NODE_VERSION && npm install -g elm

RUN wget https://downloads.gradle.org/distributions/gradle-3.4.1-bin.zip && \ 
    unzip -d /opt/gradle gradle-3.4.1-bin.zip


ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:/opt/gradle/gradle-3.4.1/bin:$PATH

WORKDIR /code

CMD ["gradle", "clean", "rpm"]


