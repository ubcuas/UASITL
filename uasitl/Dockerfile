# UBC UAS SITL (x86)
## SITL BUILD IMAGE ##
# Run the downloader in a pre-image so SSH keys are dropped from the image
FROM ubuntu:bionic as SITLDOWLOADER

# Need Git to checkout our sources
RUN apt-get update && apt-get install -y git

# Install the SSH private key for cloning repo
ARG SSH_PRIVATE_KEY

# Authorize SSH host with Gitlab & Github
RUN [ -z "$SSH_PRIVATE_KEY" ] || \
    ( \
        mkdir -p /root/.ssh && \
        chmod 0700 /root/.ssh && \
        ssh-keyscan gitlab.com >> /root/.ssh/known_hosts \
        ssh-keyscan github.com >> /root/.ssh/known_hosts \
    )

# Add in the SSH key and set permissions
RUN [ -z "$SSH_PRIVATE_KEY" ] || \
    ( \
        echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa && \
        chmod 600 /root/.ssh/id_rsa && \
        ssh-keygen -y -f /root/.ssh/id_rsa > /root/.ssh/id_rsa.pub && \
        chmod 600 /root/.ssh/id_rsa.pub \
    )

# The ARDUPILOT repo and ref to use for the build
ENV ARDUPILOT_REPO=https://github.com/ArduPilot/ardupilot.git
ENV ARDUPILOT_REF=Copter-4.0.4

# Now grab ArduPilot from GitHub
RUN git clone $ARDUPILOT_REPO ardupilot
WORKDIR /ardupilot

# Checkout the latest Copter
RUN git checkout $ARDUPILOT_REF

# Pull submodule dependencies
RUN git submodule update --init --recursive


## SITL BUILD & RUNTIME IMAGE ##
FROM ubuntu:bionic as SITLRUN

# Trick to get apt-get to not prompt for timezone in tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Need sudo and lsb-release for the installation prerequisites
RUN apt-get update && apt-get install -y sudo lsb-release tzdata bc screen

# Pull in ardupilot and build the COPTER
COPY --from=SITLDOWLOADER /ardupilot /copter
WORKDIR /copter

# Need USER set so usermod does not fail...
# Install all prerequisites now
RUN USER=nobody Tools/environment_install/install-prereqs-ubuntu.sh -y

# Continue build instructions from https://github.com/ArduPilot/ardupilot/blob/master/BUILD.md
RUN ./waf distclean
RUN ./waf configure --board sitl
RUN ./waf copter

# Prepare executables
RUN cp build/sitl/bin/arducopter /
COPY copter.parm /copter/Tools/autotest/default_params/copter.parm

# TCP 5760 is what the sim exposes by default, each INSTANCE increments by 10
EXPOSE 5760-7760

# Variables for simulator
ENV INSTANCE 0
ENV LAT 38.144715
ENV LON -76.427956
ENV ALT 14
ENV DIR 270
ENV COPTERMODEL +
ENV SPEEDUP 1
ENV VEHICLE arducopter
ENV NUMCOPTERS 1
ENV INCREMENTSTEPLAT 0.01
ENV INCREMENTSTEPLON 0.01

# Entrypoint
COPY startArdupilotSITL.sh /startArdupilotSITL.sh
ENTRYPOINT /startArdupilotSITL.sh ${NUMCOPTERS} ${LAT} ${LON} ${ALT} ${DIR} ${INCREMENTSTEPLAT} ${INCREMENTSTEPLON} ${COPTERMODEL} ${SPEEDUP}
