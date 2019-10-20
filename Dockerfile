FROM ubuntu:latest
LABEL maintainer Eric Mikulin

# Trick to get apt-get to not prompt for timezone in tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Need Git to checkout our sources
RUN apt-get update && apt-get install -y git

# Need sudo and lsb-release for the installation prerequisites
RUN apt-get install -y sudo lsb-release tzdata bc

# Install the SSH private key for cloning repo
ARG SSH_PRIVATE_KEY

# Authorize SSH host with Gitlab & Github
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan gitlab.com >> /root/.ssh/known_hosts \
    ssh-keyscan github.com >> /root/.ssh/known_hosts

# Add in the SSH key and set permissions
RUN echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa && \
    ssh-keygen -y -f /root/.ssh/id_rsa > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa.pub

# The ARDUPILOT repo and ref to use for the build
ENV ARDUPILOT_REPO=https://github.com/ArduPilot/ardupilot.git
ENV ARDUPILOT_REF=Copter-3.6.11

# Now grab ArduPilot from GitHub
RUN git clone $ARDUPILOT_REPO ardupilot
RUN cp -r ardupilot copter

# Build the COPTER
WORKDIR /copter

# Checkout the latest Copter
RUN git checkout $ARDUPILOT_REF

# Now start build instructions from http://ardupilot.org/dev/docs/setting-up-sitl-on-linux.html
RUN git submodule update --init --recursive

# Need USER set so usermod does not fail...
# Install all prerequisites now
RUN USER=nobody Tools/scripts/install-prereqs-ubuntu.sh -y

# Continue build instructions from https://github.com/ArduPilot/ardupilot/blob/master/BUILD.md
RUN ./waf distclean
RUN ./waf configure --board sitl
RUN ./waf copter

RUN cp build/sitl/bin/arducopter /

COPY copter.parm /copter/Tools/autotest/default_params/copter.parm

# Clean up SSH keys so they aren't easily accessible
RUN rm -rf /root/.ssh

# TCP 5760 is what the sim exposes by default, each INSTANCE increments by 10
EXPOSE 5760-7760

# Variables for simulator
ENV INSTANCE 0
ENV LAT 42.3898
ENV LON -71.1476
ENV ALT 14
ENV DIR 270
ENV COPTERMODEL +
ENV SPEEDUP 1
ENV VEHICLE arducopter
ENV NUMCOPTERS 0
ENV INCREMENTSTEPLAT 0.01
ENV INCREMENTSTEPLON 0.01

# Finally the command
RUN apt-get install -y screen
COPY startArdupilotSITL.sh /startArdupilotSITL.sh
ENTRYPOINT /startArdupilotSITL.sh ${NUMCOPTERS} ${LAT} ${LON} ${ALT} ${DIR} ${INCREMENTSTEPLAT} ${INCREMENTSTEPLON} ${COPTERMODEL} ${SPEEDUP}