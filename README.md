# docker-tomcat8
Builds Tomcat8 on an Ubuntu server, to facilitate
components in the ESRI ArcGIS Enterprise ecosystem,
including Web Adaptor.

It's just a basic tomcat8 server though so no reason you can't use it for other things!

## Build the Docker Image

 ```
 docker build -t geoceg/tomcat8 .
 ```
(My github repo is "geo-ceg", but Docker repo is "geoceg" (no dash). This is not a typo.)

## Create a network

The ArcGIS components need to talk to each other, so create Docker network like this:

 sudo docker network create arcgis-network

## Run the command

Running in detached mode (in the Linux world we'd say "run as a daemon"):
```
 docker run -d --name tomcat8 \
   -net arcgis-network \
   -p 80:8080 -p 443:8443  \
   geoceg/tomcat8
```
Once the server is up you can connect to it via bash shell
If you have not already done so, now you can authorize the server, too.
 ```
 docker exec -it tomcat8 bash 
 ```

### Troubleshooting

If you are having problems, (for example the docker command starts and
then exits a few seconds later) you can run in interactive mode
and add "bash" to the end of the command.

This Dockerfile uses an ENTRYPOINT instead of a CMD so it will always
try to run tomcat even when you run in interactive mode, I hope this
is okay.

The -it options give you interactive mode and a terminal. The --rm option
causes the whole container to stop when you exit the shell.

```
 docker run -it --rm --name tomcat8 \
  --net arcgis-network \
  -p 80:8080 -p 443:8443  \
   geoceg/tomcat8 bash
```

## Files you should know about

I install 'logrotate' so that tomcat8 logs get rotate, this only matters if you leave tomcat container(s)
running for a long time (weeks|months|years)

I find the log file most useful for debugging is catalina.out in /var/lib/tomcat8/logs.

