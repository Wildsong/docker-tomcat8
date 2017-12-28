# docker-tomcat8
Builds Tomcat8 on an Ubuntu server, to facilitate
components in the ESRI ArcGIS Enterprise ecosystem,
including Web Adaptor.

It's just a basic tomcat8 server though so no reason you can't use it for other things!

Note that it's running on ports 80/443 not 8080/8443! This is to better accomodate Web Adaptor.

## Build the Docker Image

    docker build -t geoceg/tomcat8 .

(My github repo is "geo-ceg", but Docker repo is "geoceg" (no dash). This is not a typo.)

## Set up environment

For example, put this in .bash_profile

    export AGS_DOMAIN="wildsong.lan"

## Create a network

The ArcGIS components need to talk to each other, so create Docker network like this:

    docker network create $AGS_DOMAIN

## Run the command

Running in detached mode (in the Linux world we'd say "run as a daemon"):

    docker run -d --name tomcat8 \
       -p 80:80 -p 443:443 --net ${AGS_DOMAIN} \
       -e AGS_DOMAIN \
       geoceg/tomcat8

Once the server is up you can connect to it via bash shell
If you have not already done so, now you can authorize the server, too.

    docker exec -it tomcat8 bash 

If it's all working you should be able to open a browser and connect
to port 80.  If you add "/manage" to the URL then you should be able
to log into the admin site if you have not disabled it in the
Dockerfile. (For example, try http://127.0.0.1/manage if you are running
docker locally.)

### Troubleshooting

If you are having problems, (for example the docker command starts and
then exits a few seconds later) you can run in interactive mode
and add "bash" to the end of the command.

The -it options give you interactive mode and a terminal. The --rm option
causes the whole container to stop when you exit the shell.

Once the bash shell is running you can do "bin/startup.sh" to start tomcat
and see what happens.

    docker run -it --rm --name tomcat8 \
       -p 80:80 -p 443:443 --net ${AGS_DOMAIN} \
       -e AGS_DOMAIN \
       geoceg/tomcat8 bash

and the command to start would be

    authbind --deep -c ~/bin/catalina.sh

## Files you should know about

I install 'logrotate' so that tomcat8 logs get rotate, this only
matters if you leave tomcat container(s) running for a long time
(weeks|months|years)

Look in the log file /var/log/tomcat8/catalina.out for error messages, 
they can be very detailed and helpful.

