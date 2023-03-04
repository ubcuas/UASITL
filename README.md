[![License: MIT](https://img.shields.io/github/license/vintasoftware/django-react-boilerplate.svg?label=License&labelColor=323940)](LICENSE)
[![Docker](https://badgen.net/badge/icon/Docker%20Hub?icon=docker&label&labelColor=323940)](https://hub.docker.com/r/ubcuas/uasitl/tags)
[![Docker CI](https://github.com/ubcuas/UASITL/actions/workflows/docker.yml/badge.svg)](https://github.com/ubcuas/UASITL/actions/workflows/docker.yml)

# UBC UAS ArduPilot SITL Docker Images
`UASITL` is a collection of docker images that can be used to run one or more ArduPilot SITL (software-in-the-Loop) simulators.


## Connections
```
[ACOM/MissionPlanner/SkyLink]---<tcp/mavlink>---[UASITL]
```


## Dependencies
- Docker


## Installation
The images can be directly pulled from DockerHub:

**ArduPlane (VTOL):**
```
FOR x86: docker pull ubcuas/uasitl:plane
FOR arm: docker pull ubcuas/uasitl:plane-arm
```

**ArduCopter (Quadcopter):**
```
FOR x86: docker pull ubcuas/uasitl:copter
FOR arm: docker pull ubcuas/uasitl:copter-arm
```

The images can also be built locally:
> **Note**
> To build for ArduPlane, add `--build-arg VEHICLE_TYPE=1` to the build command. Also change the tag to `plane` or `plane-arm` depending on the architecture.
```
./configure.sh
FOR x86: docker build --tag ubcuas/uasitl:copter x86/ --platform "linux/amd64"
FOR armv7: docker build --tag ubcuas/uasitl:copter-arm arm/ --platform "linux/arm/v7"
FOR arm64: docker build --tag ubcuas/uasitl:copter-arm arm/ --platform "linux/arm64"
```
> **Note**
> If you get an error akin to `./configure.sh: line 2: $'\r': command not found` then run `sed -i 's/\r$//' configure.sh` to fix the line endings.

To build the armv7 and arm64 images on x86, you need to run the following commands:
```
./configure.sh
ArduCopter: ./crossBuild.sh copter
ArduPlane: ./crossBuild.sh plane
```


The image can be built using a custom `Ardupilot` repository:
```
./configure.sh
FOR x86: ARDUPILOT_REPO=git@gitlab.com:ubcuas/accupilot.git docker build --build-arg SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" --tag ubcuas/uasitl:accupilot x86/
FOR arm: ARDUPILOT_REPO=git@gitlab.com:ubcuas/accupilot.git docker build --build-arg SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" --tag ubcuas/uasitl:accupilot arm/
```

Please note the bash variable `$SSH_PRIVATE_KEY` needs to be a valid ssh private key. If you are building on command line you can do this in one shot like so: `--build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"`.
`ARDUPILOT_REPO` is an ssh git url to an ardupilot repository. **WARNING: Building locally bakes your private SSH key into the docker image, do NOT share this image with others.**


## Usage
To launch a single ArduCopter SITL on host TCP port 5760, with the ability for the rest of our services to connect:
```
docker run --rm -p 5760-5780:5760-5780 -it --network=gcom-x_uasnet --name=uasitl ubcuas/uasitl:copter
```

To launch a single ArduCopter SITL on host TCP port 5760:
```
docker run --rm -p 5760-5780:5760-5780 -it --name=uasitl ubcuas/uasitl:copter
```

To start 3 ArduCopter SITLs on host TCP ports 5760, 5770 and 5780:
```
docker run --rm -p 5760-5780:5760-5780 --env NUMCOPTERS=3 -it --name=uasitl ubcuas/uasitl:copter
```


## Troubleshooting
----
`docker: Error response from daemon: network gcom-x_uasnet not found.`
> You need to create the network that the containers connect to. Starting up `gcom-x` will create the network.
> It can also manually be created using the command `docker network create gcom-x_uasnet`.

----
`Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?` or similar.
> You need to run the `docker` commands as root. Use sudo: `sudo docker <command>`. Or add yourself to the docker group.

----
`filename: line 2: $'\r': command not found`
> Run `sed -i 's/\r$//' filename` to fix the line endings.