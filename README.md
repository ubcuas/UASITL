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
To launch a single ArduCopter SITL on host TCP port 5760:
```
docker run --rm -p 5760-5780:5760-5780 -it ubcuas/uasitl:latest
```
To start 3 ArduCopter SITLs on host TCP ports 5760, 5770 and 5780:
```
docker run --rm -p 5760-5780:5760-5780 --env NUMCOPTERS=3 -it ubcuas/uasitl:latest
```

## Troubleshooting
Contact `Eric Mikulin`
