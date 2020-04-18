Multi-Agent ArduPilot Software-in-the-Loop Simulator Docker Container
=====================================================================

The purpose of this is to run /many/ ArduPilot SITL from within Docker.


DockerHub
---------

A pre-built Docker image is available on DockerHub at:

https://hub.docker.com/r/ubcuas/uasitl

To download it, simply:

`docker pull ubcuas/uasitl`

and to run it:

`docker run --rm -p 5760-5780:5760-5780 -it ubcuas/uasitl:latest`

This will start 1 ArduCopter SITLs on host TCP ports 5760.


Quick Start
-----------

If you'd rather build the docker image yourself:

```
./configure.sh
docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" --tag uasitl x86
```

To run the image:

`docker run --rm -p 5760-5810:5760-5810 --env NUMCOPTERS=3 -it uasitl`

This will start 3 ArduCopter SITLs on host TCP ports 5760, 5770 and 5780 so to connect to it from the host, you could:

```
mavproxy.py --master=tcp:localhost:5760
mavproxy.py --master=tcp:localhost:5770
mavproxy.py --master=tcp:localhost:5780
```

**WARNING: This bakes your private SSH key into the docker image, do NOT share this image with others.**

Options
-------

The full list of options and their default values is:

```
INSTANCE          0
LAT               42.3898
LON               -71.1476
ALT               14
DIR               270
COPTERMODEL       +
SPEEDUP           1
NUMCOPTERS        1
INCREMENTSTEPLAT  0.01
INCREMENTSTEPLON  0.01
```

Vehicles and their corresponding models are listed below:

```
ArduCopter: octa-quad|tri|singlecopter|firefly|gazebo-
    iris|calibration|hexa|heli|+|heli-compound|dodeca-
    hexa|heli-dual|coaxcopter|X|quad|y6|IrisRos|octa
```
