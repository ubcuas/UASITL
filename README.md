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
> [!NOTE]
> Replace X.X.X with the desired version number


Images are multi-arch (`linux/amd64`, `linux/arm64`), so the same tag works on x86 and ARM.

**ArduPlane (VTOL):**
```
docker pull ubcuas/uasitl:plane-X.X.X
```

**ArduCopter (Quadcopter):**
```
docker pull ubcuas/uasitl:copter-X.X.X
```

The images can also be built locally for your machine's architecture:
> [!NOTE]
> To build for ArduPlane, add `--build-arg VEHICLE_TYPE=1` to the build command. Also change the tag to `plane`.
```
docker build --tag ubcuas/uasitl:copter-X.X.X --build-arg VERSION=X.X.X .
```

To build for all architectures at once (uses QEMU emulation, so the ARM builds are slow):
```
ArduCopter: ./crossBuild.sh copter X.X.X
ArduPlane: ./crossBuild.sh plane X.X.X
```


The image can be built using a custom `Ardupilot` repository:
```
ARDUPILOT_REPO=git@gitlab.com:ubcuas/accupilot.git docker build --build-arg SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" --tag ubcuas/uasitl:accupilot .
```

Please note the bash variable `$SSH_PRIVATE_KEY` needs to be a valid ssh private key. If you are building on command line you can do this in one shot like so: `--build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"`.
`ARDUPILOT_REPO` is an ssh git url to an ardupilot repository. **WARNING: Building locally bakes your private SSH key into the docker image, do NOT share this image with others.**


## Usage
To launch a single ArduCopter SITL on host TCP port 5760, with the ability for the rest of our services to connect:
```
docker run --rm -p 5760-5780:5760-5780 -it --network=gcom-x_uasnet --name=uasitl ubcuas/uasitl:copter-X.X.X
```

To launch a single ArduCopter SITL on host TCP port 5760, with the ability for the rest of our services to connect, and with a custom parameter file located in the current directory:
> [!NOTE]
> Docker volume mounts (-v option) needs absolute paths. `${PWD}` is a Windows Powershell variable that expands to the current working directory. For Linux, use `$(pwd)` and for Command Prompt use `%cd%`.
```
docker run --rm -p 5760-5780:5760-5780 -it --network=gcom-x_uasnet --name=uasitl -v ${PWD}/custom-copter.param:/custom-copter.param --env PARAM_FILE=/custom-copter.param ubcuas/uasitl:copter-X.X.X --defaults=/ardupilot/Tools/autotest/default_params/copter.parm
```

To launch a single ArduCopter SITL on host TCP port 5760:
```
docker run --rm -p 5760-5780:5760-5780 -it --name=uasitl ubcuas/uasitl:copter-X.X.X
```

To start 3 ArduCopter SITLs on host TCP ports 5760, 5770 and 5780:
```
docker run --rm -p 5760-5780:5760-5780 --env NUMCOPTERS=3 -it --name=uasitl ubcuas/uasitl:copter-X.X.X
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