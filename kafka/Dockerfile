FROM centos:7

COPY volume.repo /etc/yum.repos.d/volume.repo

RUN yum update -y

RUN yum install -y initscripts && yum clean all

RUN yum install -y java-1.8.0-openjdk

RUN yum install -y volume-kafka

COPY entrypoint.sh /
COPY start-zoo-kafka.sh /
RUN chmod +x /entrypoint.sh
RUN chmod +x /start-zoo-kafka.sh

EXPOSE 2181 2888 3888

#RUN sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh", "/start-zoo-kafka.sh"]

