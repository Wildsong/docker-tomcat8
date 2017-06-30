From geoceg/ubuntu-server:latest
LABEL maintainer="b.wilson@geo-ceg.org"
ENV REFRESHED_AT 2017-06-30

# Let's try remapping ports in the docker run command, eh?  Not sure
# if I can make ArcGIS Web Adaptor work this way, it's fussy.

EXPOSE 8080 8443
#EXPOSE 80 443

ENV TOMCAT=tomcat8
ENV HOME=/usr/share/${TOMCAT}

RUN apt-get -y install openjdk-8-jre-headless
RUN apt-get -y install ${TOMCAT} ${TOMCAT}-admin

# Note, there is a "tomcat8" string embedded in this script. Fixme!
ADD logrotate /etc/logrotate.d/${TOMCAT}
RUN chmod 644 /etc/logrotate.d/${TOMCAT}

# Move Tomcat server from port 8080 to 80
#RUN sed -i s/8080/80/g /var/lib/${TOMCAT}/conf/server.xml
#RUN sed -i s/#AUTHBIND=no/AUTHBIND=yes/g /etc/default/${TOMCAT}

# This is only needed if you want to use the web gui to manage tomcat.
RUN sed -i s/<tomcat-users>/<tomcat-users><user username=\"siteadmin\" password=\"thalweg\" roles="manager-gui"/>/g /var/lib/${TOMCAT}/conf/tomcat-users.xml

# Do we really need TLS support here? Or can we use a proxy?
# Create and install a self-signed certificate that actually works.
# RUN keystore genkey /var/lib/${TOMCAT}/conf/.keystore
# RUN sed .... /var/lib/${TOMCAT}/conf/server.xml
# Move Tomcat TLS server from 8443 to 443

USER tomcat8
WORKDIR ${HOME}
ENTRYPOINT [ "${TOMCAT}/bin/startup.sh" ]
