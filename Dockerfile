From geoceg/ubuntu-server:latest
LABEL maintainer="b.wilson@geo-ceg.org"
ENV REFRESHED_AT 2017-06-30

# Let's try remapping ports in the docker run command, eh?  Not sure
# if I can make ArcGIS Web Adaptor work this way, it's fussy.

EXPOSE 8080 8443
#EXPOSE 80 443

ENV TOMCAT=tomcat8
ENV HOME=/usr/share/${TOMCAT}
ENV WEBAPPS /var/lib/${TOMCAT}/webapps/

RUN apt-get -y install openjdk-8-jre-headless
RUN apt-get -y install ${TOMCAT} ${TOMCAT}-admin

# Note, there is a "tomcat8" string embedded in this script. Fixme!
ADD logrotate /etc/logrotate.d/${TOMCAT}
RUN chmod 644 /etc/logrotate.d/${TOMCAT}

# Move Tomcat server from port 8080 to 80
#RUN sed -i s/8080/80/g /etc/${TOMCAT}/server.xml
#RUN sed -i s/#AUTHBIND=no/AUTHBIND=yes/g /etc/default/${TOMCAT}

# This is only needed if you want to use the web gui to manage tomcat.
# Tsk tsk should not define passwords in the file.
RUN sed -i "s/<\/tomcat-users>/<user username=\"siteadmin\" password=\"changeit\" roles=\"manager-gui\"\/><\/tomcat-users>/" /etc/${TOMCAT}/tomcat-users.xml

# Create and install a self-signed certificate.
RUN keytool -genkey -alias tomcat -keyalg RSA -keystore /etc/${TOMCAT}/.keystore -storepass changeit
# RUN sed .... /etc/${TOMCAT}/server.xml

ENV PIDDIR=/var/run/${TOMCAT}
RUN mkdir ${PIDDIR} && chown ${TOMCAT}.${TOMCAT} ${PIDDIR}

WORKDIR ${HOME}
USER ${TOMCAT}

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV JSSE_HOME=${JAVA_HOME}/jre
ENV CATALINA_OUT=/var/log/${TOMCAT}/catalina.out
ENV CATALINA_TMPDIR=/tmp/${TOMCAT}
RUN mkdir ${CATALINA_TMPDIR}
ENV CATALINA_PID=${PIDDIR}/${TOMCAT}.pid

ENV CATALINA_BASE=/var/lib/${TOMCAT}
# Set heap,memory etc opts here
ENV CATALINA_OPTS="-Djava.awt.headless=true -Xmx128M"

# The "&& bash" at the end gives ENTRYPOINT something to do;
# the startup.sh script will exit after starting tomcat
# and then the whole container will shut down!
CMD ${HOME}/bin/startup.sh && bash
