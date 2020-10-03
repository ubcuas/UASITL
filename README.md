# UBC UAS ArduPilot Software-in-the-Loop Simulator Docker Container
`UASITL` is a docker container that can be used to run one or more ArduPilot SITL simulators.


## Connections
```
[SkyLink]---<tcp/mavlink>---[UASITL]
```


## Dependencies
- Docker


## Installation
The image can be directly pulled from DockerHub:
```
docker pull ubcuas/uasitl:latest
```

The image can also be built locally:
```
./configure.sh
docker build --tag ubcuas/uasitl:latest uasitl/
```

The image can be built using a custom `Ardupilot` repository:
```
./configure.sh
ARDUPILOT_REPO=git@gitlab.com:ubcuas/accupilot.git docker build --build-arg SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" --tag ubcuas/uasitl:accupilot uasitl/
```

Please note the bash variable `$SSH_PRIVATE_KEY` needs to be a valid ssh private key. If you are building on command line you can do this in one shot like so: `--build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"`.
`ARDUPILOT_REPO` is an ssh git url to an ardupilot repository.


## Usage
To launch a single ArduCopter SITL on host TCP port 5760, with the ability for the rest of our services to connect:
```
docker run --rm -p 5760-5780:5760-5780 -it --network=gcom-x_uasnet --name=uasitl ubcuas/uasitl:latest
```

To launch a single ArduCopter SITL on host TCP port 5760:
```
docker run --rm -p 5760-5780:5760-5780 -it ubcuas/uasitl:latest
```

To start 3 ArduCopter SITLs on host TCP ports 5760, 5770 and 5780:
```
docker run --rm -p 5760-5780:5760-5780 --env NUMCOPTERS=3 -it ubcuas/uasitl:latest
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
`Anything Else`
> Contact `Eric Mikulin`
