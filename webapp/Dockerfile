FROM centos:7

COPY volume.repo /etc/yum.repos.d/volume.repo

RUN yum update -y

RUN yum install -y initscripts

RUN yum install -y java-1.8.0-openjdk

RUN yum clean all

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
COPY start-webapp.sh /
RUN chmod +x /start-webapp.sh

ADD settings /settings

EXPOSE 9001
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh", "/start-webapp.sh"]
