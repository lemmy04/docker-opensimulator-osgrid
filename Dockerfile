#Name of container: docker-opensimulator-osgrid
#Version of container: 0.9.2.e24dd01

FROM lemmy04/mono-base:0.1

MAINTAINER lemmy04 <Mathias.Homann@openSUSE.org>

LABEL version=0.9.2.dev.1b9cea0 Description="For running an opensim that hooks into osgrid instance in a docker container." Vendor="Mathias.Homann@openSUSE.org"

## install all updates
## Date: 2020-11-27

## setup /run/uscreens
RUN mkdir -p /run/uscreens
RUN chmod a+rwx,o+t /run/uscreens

## create an opensim user and group
RUN useradd \
        -c "The user that runs the opensim regions" \
        --no-log-init \
        -m \
        -U \
        opensim

##Adding opensim zip file
# Unpacking to /home/opensim/opensim
ADD ["https://danbanner.onikenkon.com/osgrid/osgrid-opensim-05122021.v0.9.2.1b9cea0.zip", "/tmp/opensim.zip"]
RUN unzip -d /home/opensim/opensim /tmp/opensim.zip
RUN rm /tmp/opensim.zip

# create persistence
RUN mkdir -p /home/opensim/opensim/bin/persistence

# add opensim preconfigured ini files
ADD ["http://download.osgrid.org/OpenSim.ini.txt", "/home/opensim/opensim/bin/OpenSim.ini"]
ADD ["http://download.osgrid.org/GridCommon.ini.txt", "/home/opensim/opensim/bin/config-include/GridCommon.ini"]
ADD ["http://download.osgrid.org/FlotsamCache.ini.txt", "/home/opensim/opensim/bin/config-include/FlotsamCache.ini"]
ADD ["SQLiteStandalone.ini", "/home/opensim/opensim/bin/config-include/storage/SQLiteStandalone.ini"]

# rename osslEnable.ini.example
RUN mv /home/opensim/opensim/bin/config-include/osslEnable.ini.example /home/opensim/opensim/bin/config-include/osslEnable.ini

# add startup script
COPY opensim.sh /home/opensim/opensim/bin

# fix owner and perms
RUN chmod +x /home/opensim/opensim/bin/opensim.sh
RUN chown -R opensim:opensim /home/opensim/opensim

# To allow access from outside of the container  to the container service at these ports
# Need to allow ports access rule at firewall too .  
EXPOSE 9000-9003/tcp
EXPOSE 9000-9003/udp

WORKDIR /home/opensim/opensim/bin
USER opensim
CMD ["/home/opensim/opensim/bin/opensim.sh"]
