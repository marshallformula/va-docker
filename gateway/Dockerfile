FROM centos:7

COPY volume.repo /etc/yum.repos.d/volume.repo

RUN yum update -y

RUN yum install -y initscripts

RUN yum install -y java-1.8.0-openjdk

RUN yum clean all

# RUN rpm -ivh volume-gateway.rpm

COPY entry-point.sh /
RUN chmod +x /entry-point.sh
COPY start-gateway.sh /
RUN chmod +x /start-gateway.sh

ADD settings /settings

EXPOSE 8080
ENTRYPOINT ["/entry-point.sh"]
CMD ["sh", "/start-gateway.sh"]
