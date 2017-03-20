FROM centos:7

COPY volume.repo /etc/yum.repos.d/volume.repo

RUN yum update -y

RUN yum install -y initscripts && yum clean all

RUN yum install -y java-1.8.0-openjdk

RUN yum install -y volume-neo4j

ENV GRAPH_PASSWORD password
COPY init-graph.sh /
RUN sh /init-graph.sh

EXPOSE 7687 7474

COPY start-graph.sh /
CMD ["sh", "/start-graph.sh"]
