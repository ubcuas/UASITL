# UBC UAS SITL (x86)

### SITL DOWNLOAD IMAGE ###
# Run the downloader in a pre-image so SSH keys are dropped from the image
FROM ubuntu:focal AS SITLDOWNLOADER

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
ENV ARDUPILOT_REF=master

# Now grab ArduPilot from GitHub
RUN git clone $ARDUPILOT_REPO ardupilot
WORKDIR /ardupilot

# Checkout the latest Copter
RUN git checkout $ARDUPILOT_REF

# Pull submodule dependencies
RUN git submodule update --init --recursive


### SITL BUILD IMAGE ###
FROM ubuntu:focal AS SITLBUILD

# Pull in ardupilot and build the COPTER
COPY --from=SITLDOWNLOADER /ardupilot /copter
WORKDIR /copter

# Trick to get apt-get to not prompt for timezone in tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Create a non-root user for the build
ARG USER_NAME=copter
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd ${USER_NAME} --gid ${USER_GID}\
    && useradd -l -m ${USER_NAME} -u ${USER_UID} -g ${USER_GID} -s /bin/bash

# Need sudo, lsb-release, tzdata, and bash-completion for the installation prerequisites 
RUN apt-get update && apt-get install --no-install-recommends -y \
    lsb-release \
    sudo \
    tzdata \
    bash-completion

# Create non root user for pip
ENV USER=${USER_NAME}

RUN echo "copter ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME}
RUN chmod 0440 /etc/sudoers.d/${USER_NAME}

RUN chown -R ${USER_NAME}:${USER_NAME} /${USER_NAME}

USER ${USER_NAME}

ENV SKIP_AP_EXT_ENV=1 SKIP_AP_GRAPHIC_ENV=1 SKIP_AP_COV_ENV=1 SKIP_AP_GIT_CHECK=1
# Install all prerequisites now
RUN Tools/environment_install/install-prereqs-ubuntu.sh -y

# Continue build instructions from https://github.com/ArduPilot/ardupilot/blob/master/BUILD.md
RUN ./waf distclean
RUN ./waf configure --board sitl
RUN ./waf copter


### SITL RUN IMAGE ###
FROM ubuntu:focal AS SITLRUN

# Runtime dependencies
RUN apt-get update && apt-get install -y python3 python3-pip python-is-python3 python-numpy bc screen
RUN pip install --user -U future lxml pymavlink MAVProxy pexpect

# Prepare executables
COPY --from=SITLBUILD /copter/Tools/autotest /copter/Tools/autotest
COPY --from=SITLBUILD /copter/ArduCopter /copter/ArduCopter
COPY --from=SITLBUILD /copter/build/sitl/bin/arducopter /copter/build/sitl/bin/arducopter

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
COPY startArdupilotSITL.sh /
# Fix line endings
RUN sed -i 's/\r$//' startArdupilotSITL.sh

ENTRYPOINT /startArdupilotSITL.sh ${NUMCOPTERS} ${LAT} ${LON} ${ALT} ${DIR} ${INCREMENTSTEPLAT} ${INCREMENTSTEPLON} ${COPTERMODEL} ${SPEEDUP}
