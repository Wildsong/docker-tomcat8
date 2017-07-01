From geoceg/ubuntu-server:latest
LABEL maintainer="b.wilson@geo-ceg.org"
ENV REFRESHED_AT 2017-06-30

# If you need to expose the standard HTTP/HTTPS ports 80,443
# you can map them in the 'docker run' command.
EXPOSE 8080 8443

ENV TOMCAT=tomcat8
ENV HOME=/usr/share/${TOMCAT}
ENV WEBAPPS /var/lib/${TOMCAT}/webapps/

RUN apt-get -y install openjdk-8-jre-headless
RUN apt-get -y install ${TOMCAT} ${TOMCAT}-admin

# Note, there is a "tomcat8" string embedded in this script. Fixme!
ADD logrotate /etc/logrotate.d/${TOMCAT}
RUN chmod 644 /etc/logrotate.d/${TOMCAT}

# This is only needed if you want to use the web gui to manage tomcat.
# FIXME should not define passwords in the file.
RUN sed -i "s/<\/tomcat-users>/<user username=\"siteadmin\" password=\"changeit\" roles=\"manager-gui\"\/><\/tomcat-users>/" /etc/${TOMCAT}/tomcat-users.xml

# Create and install a self-signed certificate.
RUN keytool -genkey -alias tomcat -keyalg RSA -keystore /etc/${TOMCAT}/.keystore \
    -storepass changeit -keypass changeit \
    -dname "CN=Abraham Lincoln, OU=Legal Department, O=Whig Party, L=Springfield, ST=Illinois, C=US"
# Modify server.xml to activate the TLS service
RUN sed -i "s/<Service name=\"Catalina\">/<Service name=\"Catalina\">\n    <Connector port=\"8443\" maxThreads=\"200\" scheme=\"https\" secure=\"true\" SSLEnabled=\"true\" keystorePass=\"changeit\" clientAuth=\"false\" sslProtocol=\"TLS\" keystoreFile=\"\/etc\/${TOMCAT}\/.keystore\" \/>/" \
        /etc/${TOMCAT}/server.xml

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

# Exit if Tomcat service on port 8080 dies
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1:8080 || exit 1

# Start Tomcat running in foreground (don't daemonize)
CMD ${HOME}/bin/catalina.sh run

