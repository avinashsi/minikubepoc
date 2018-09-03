# RMG JAVA IMAGE

# Version JDK8

FROM centos

MAINTAINER Avinash Singh, avinashsi7@hotmail.com

ENV JAVA_VERSION 8u131
ENV BUILD_VERSION b17
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.0.53
ENV JAVA_OPTS ""
RUN yum install -y wget jq
#ADD wget /usr/bin/wget
#RUN chmod +x /usr/bin/wget

####Install Java #################################
RUN wget https://gitlab.com/avinashsi/docker/raw/master/files/jdk-8u131-linux-x64.rpm -O /tmp/jdk-8u131-linux-x64.rpm
RUN cd /tmp && rpm -ivh jdk-8u131-linux-x64.rpm
RUN alternatives --install /usr/bin/java java /usr/java/latest/bin/java 200000
RUN alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000
ENV JAVA_HOME /usr/java/latest
RUN rm /tmp/jdk-8u131-linux-x64.rpm

###################################################


######Install Tomcat###############################
RUN wget http://www.mirrorservice.org/sites/ftp.apache.org/tomcat/tomcat-9/v9.0.11/bin/apache-tomcat-9.0.11.zip 
RUN yum install -y unzip
RUN unzip apache-tomcat-9.0.11.zip
RUN mv apache-tomcat-9.0.11 /home/tomcat
RUN chmod 777 /home/tomcat/bin/*
RUN rm -fr apache-tomcat-9.0.11.zip

######Deploy helloworld josn File ##################

RUN mkdir -p /home/tomcat/webapps/app
#ADD helloworld.json /home/tomcat/webapps/helloworld/helloworld.json

#####################################################

ENV CATALINA_HOME /home/tomcat
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin

EXPOSE 8080
VOLUME /home/tomcat/webapps/app/

####################################################
ENTRYPOINT /home/tomcat/bin/startup.sh && tail -f /home/tomcat/logs/catalina.out

#####################################################
CMD ["/home/tomcat/bin/startup.sh"]

#####################################################d

