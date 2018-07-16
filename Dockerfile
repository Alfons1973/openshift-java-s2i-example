FROM openshift/base-centos7
MAINTAINER Chakradhar Rao Jonagam (9chakri@gmail.com)

ENV BUILDER_VERSION 1.1

RUN yum -y update; \ 
    yum install wget -y; \ 
    yum install tar -y; \ 
    yum install unzip -y; \ 
    yum install ca-certificates -y;\ 
    yum install sudo -y;\ 
    yum clean all -y 

LABEL io.k8s.description="The tomcat s2i binary image \
          with universal support for popular component formats." \
      io.k8s.display-name="Tomcat binary S2" \
      io.openshift.expose-services="8080:8080" \
      io.openshift.tags="builder,tomcat"

ENV TOMCAT_MAJOR_VERSION 8 
ENV TOMCAT_MINOR_VERSION 8.0.32 
ENV CATALINA_HOME /tomcat 


# Install openjdk 1.8 
RUN yum install java-1.8.0-openjdk.x86_64* -y && \ 
    yum clean all -y && \
    rm -rf /var/lib/apt/lists/* 

# INSTALL TOMCAT 
WORKDIR /

RUN wget -q -e use_proxy=yes https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.32/bin/apache-tomcat-8.0.32.tar.gz && \
    tar -zxf apache-tomcat-*.tar.gz &&\
    rm -f apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat 


ENV JAVA_OPTS="-Dtuf.environment=DEV -Dtuf.appFiles.rootDirectory=/TempDirRoot" 


RUN mkdir -p /tomcat/webapps /TempDirRoot
#RUN chown -R 1001:1001 /tomcat /TempDirRoot 
#RUN chmod -R 777 /tomcat /TempDirRoot 

RUN chgrp -R 0 /tomcat /TempDirRoot \
  && chmod -R g+rwX /tomcat /TempDirRoot

RUN cd /tomcat/webapps/; rm -rf ROOT docs examples host-manager manager 

COPY ./.s2i/bin/ /usr/libexec/s2i

USER 1001

EXPOSE 8080

CMD $STI_SCRIPTS_PATH/usage
