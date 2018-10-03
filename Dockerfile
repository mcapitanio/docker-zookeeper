FROM parrotstream/centos-openjdk:8

MAINTAINER Matteo Capitanio <matteo.capitanio@gmail.com>

USER root

ENV ZOOKEEPER_VER 3.4.8
ENV EXHIBITOR_VER 1.5.6
ENV GRADLE_VER 3.0

ENV ZOOKEEPER_HOME /opt/zookeeper
ENV EXHIBITOR_HOME /opt/exhibitor
ENV GRADLE_HOME /opt/gradle

ENV PATH $GRADLE_HOME/bin:$EXHIBITOR_HOME/bin:$ZOOKEEPER_HOME/bin:$ZOOKEEPER_HOME/sbin:$PATH

# Install needed packages
RUN yum clean all; yum update -y
RUN yum install -y ant which openssh-clients openssh-server python-setuptools git svn
RUN easy_install supervisor
RUN yum clean all

WORKDIR /opt/docker

# Apache ZooKeeper
RUN wget https://github.com/apache/zookeeper/archive/release-$ZOOKEEPER_VER.tar.gz
RUN tar -xvf release-$ZOOKEEPER_VER.tar.gz -C ..; \
    mv ../zookeeper-release-$ZOOKEEPER_VER $ZOOKEEPER_HOME
RUN cd $ZOOKEEPER_HOME; \
    ant
RUN rm $ZOOKEEPER_HOME/conf/*.cfg; \
    rm $ZOOKEEPER_HOME/conf/*.properties
COPY zookeeper/ $ZOOKEEPER_HOME/
COPY ./etc /etc

RUN mkdir -p /zookeeper/data; \
    mkdir -p /zookeeper/logs

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

EXPOSE 2181 2888 3888

VOLUME [ "/zookeeper/data", "/zookeeper/logs", "/opt/zookeeper/conf" ]

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
