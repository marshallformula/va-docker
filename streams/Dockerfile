FROM centos:7

COPY volume.repo /etc/yum.repos.d/volume.repo

RUN yum update -y
RUN yum install -y initscripts
RUN yum install -y java-1.8.0-openjdk
RUN yum install -y volume-streams
RUN yum clean all

RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN python get-pip.py 
RUN pip install awscli

COPY access.json /
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
COPY start-streams.sh /
RUN chmod +x /start-streams.sh

# aws stuff
RUN mkdir -p /root/.aws && \
    echo "[default]" > "/root/.aws/config" && \
    echo "region=us-east-1" >> "/root/.aws/config"

COPY credentials /root/.aws


EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh", "/start-streams.sh"]
