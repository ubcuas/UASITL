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

# Take in a parameter for the vehicle type
ARG VEHICLE_TYPE

# if --build-arg VEHICLE_TYPE=1, set ARDUPILOT_TAG to 'Plane-X.X.X' or set to null otherwise.
ENV ARDUPILOT_TAG=${VEHICLE_TYPE:+Plane-4.3.4}
# if ARDUPILOT_TAG is null, set it to 'Copter-X.X.X' (or leave as is otherwise).
ENV ARDUPILOT_TAG=${ARDUPILOT_TAG:-Copter-4.3.7}

# The ARDUPILOT repo and ref to use for the build
ENV ARDUPILOT_REPO=https://github.com/ArduPilot/ardupilot.git
ENV ARDUPILOT_REF=$ARDUPILOT_TAG

# Now grab ArduPilot from GitHub
RUN git clone $ARDUPILOT_REPO ardupilot
WORKDIR /ardupilot

# Checkout the latest Copter/Plane release
RUN git checkout $ARDUPILOT_REF

# Pull submodule dependencies
RUN git submodule update --init --recursive


### SITL BUILD IMAGE ###
FROM ubuntu:focal AS SITLBUILD

# Trick to get apt-get to not prompt for timezone in tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Create a non-root user for the build
ARG USER_NAME=vehicle
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

# Pull in ardupilot and build the vehicle
COPY --from=SITLDOWNLOADER /ardupilot /vehicle
WORKDIR /vehicle

# Create non root user for pip
ENV USER=${USER_NAME}

RUN echo "vehicle ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME}
RUN chmod 0440 /etc/sudoers.d/${USER_NAME}

RUN chown -R ${USER_NAME}:${USER_NAME} /${USER_NAME}

USER ${USER_NAME}

ENV SKIP_AP_EXT_ENV=1 SKIP_AP_GRAPHIC_ENV=1 SKIP_AP_COV_ENV=1 SKIP_AP_GIT_CHECK=1
# Install all prerequisites now
RUN Tools/environment_install/install-prereqs-ubuntu.sh -y

# Take in a parameter for the vehicle type
ARG VEHICLE_TYPE

# if --build-arg VEHICLE_TYPE=1, set WAF_VEHICLE to 'plane' or set to null otherwise.
ENV WAF_VEHICLE=${VEHICLE_TYPE:+plane}
# if WAF_VEHICLE is null, set it to 'copter' (or leave as is otherwise).
ENV WAF_VEHICLE=${WAF_VEHICLE:-copter}

# Continue build instructions from https://github.com/ArduPilot/ardupilot/blob/master/BUILD.md
RUN ./waf distclean
RUN ./waf configure --board sitl
RUN ./waf $WAF_VEHICLE


### SITL RUN IMAGE ###
FROM ubuntu:focal AS SITLRUN

# Runtime dependencies
RUN apt-get update && apt-get install -y python3 python3-pip python-is-python3 python-numpy bc screen
RUN pip install --user -U future lxml pymavlink MAVProxy pexpect

# Take in a parameter for the vehicle type
ARG VEHICLE_TYPE

# if --build-arg VEHICLE_TYPE=1, set VEHICLE params to plane or set to null otherwise.
ENV VEHICLE=${VEHICLE_TYPE:+ArduPlane}
ENV VEHICLE_LOWER=${VEHICLE_TYPE:+arduplane}
ENV VEHICLE_PARAM=${VEHICLE_TYPE:+plane.parm}
ENV VEHICLE_FRAME=${VEHICLE_TYPE:+quadplane}
# if above variables are null, set them copter (or leave as is otherwise).
ENV VEHICLE=${VEHICLE:-ArduCopter}
ENV VEHICLE_LOWER=${VEHICLE_LOWER:-arducopter}
ENV VEHICLE_PARAM=${VEHICLE_PARAM:-copter.parm}
ENV VEHICLE_FRAME=${VEHICLE_FRAME:-X}

# Prepare executables
COPY --from=SITLBUILD /vehicle/Tools/autotest /vehicle/Tools/autotest
COPY --from=SITLBUILD /vehicle/$VEHICLE /vehicle/$VEHICLE
COPY --from=SITLBUILD /vehicle/build/sitl/bin/$VEHICLE_LOWER /vehicle/build/sitl/bin/$VEHICLE_LOWER

COPY $VEHICLE_PARAM /${VEHICLE}/Tools/autotest/default_params/$VEHICLE_PARAM

# TCP 5760 is what the sim exposes by default, each INSTANCE increments by 10
EXPOSE 5760-7760

# Variables for simulator
ENV INSTANCE 0
ENV LAT 38.315139
ENV LON -76.548751
ENV ALT 14
ENV DIR 270
ENV VEHICLEMODEL ${VEHICLE_FRAME}
ENV SPEEDUP 1
ENV VEHICLE $VEHICLE
ENV NUMVEHICLES 1
ENV INCREMENTSTEPLAT 0.01
ENV INCREMENTSTEPLON 0.01
# Default to no custom parameter file
ENV PARAM_FILE "" 

# Entrypoint
COPY startArdupilotSITL.sh /
# Give execute permissions
RUN chmod +x /startArdupilotSITL.sh

ENTRYPOINT /startArdupilotSITL.sh ${NUMVEHICLES} ${LAT} ${LON} ${ALT} ${DIR} ${INCREMENTSTEPLAT} ${INCREMENTSTEPLON} ${VEHICLE} ${VEHICLEMODEL} ${SPEEDUP} ${PARAM_FILE}
