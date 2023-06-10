#!/bin/bash

numVehicles=${1}
initialAgentLat=${2}
initialAgentLon=${3}
initialAgentAlt=${4}
initialAgentHeading=${5}
incrementStepLat=${6}
incrementStepLon=${7}
vehicle=${8}
vehicleModel=${9}
speedup=${10}
paramFile=${11}
paramFileArg=""

incrementStepAlt=0
incrementStepHdg=0

echo "Number of ${vehicle}s: $numVehicles"

# Start ArduPilots
LAT=${initialAgentLat}
LON=${initialAgentLon}
ALT=${initialAgentAlt}
HDG=${initialAgentHeading}

echo "Initial Position: $LAT,$LON,$ALT,$HDG"
echo "Increment Lat: $incrementStepLat"
echo "Increment Lon: $incrementStepLon"
echo "VehicleModel: $vehicleModel"
echo "Speedup: $speedup"

arduPilotInstance=0

# Add param file if one is specified
if [ -n "$paramFile" ]; then
    paramFileArg="--add-param-file=${paramFile}"
fi

if [ $numVehicles -ne 0 ]; then
    for i in $(seq 0 $(($numVehicles-1))); do

            INSTANCE=$arduPilotInstance

            export SITL_RITW_TERMINAL="screen -D -m -S ${vehicle}${INSTANCE}"
            
            rm -rf ./${vehicle}${INSTANCE}
            mkdir ./${vehicle}${INSTANCE} && cd ${vehicle}${INSTANCE}

            simCommand="/vehicle/Tools/autotest/sim_vehicle.py \
                -I ${INSTANCE} \
                --vehicle=${vehicle} \
                --custom-location=${LAT},${LON},${ALT},${DIR} \
                -w \
                --speedup ${speedup} \
                --frame=${vehicleModel} \
                --no-rebuild \
                --no-mavproxy \
                ${paramFileArg}"

            echo "Starting Sim ${vehicle} with command '$simCommand'"
            exec $simCommand &
            pids[${arduPilotInstance}]=$!

            #Make it so all the instances don't start at the same Lat/Lon
            LAT=$(echo "$LAT + $incrementStepLat" | bc)
            LON=$(echo "$LON + $incrementStepLon" | bc)
            ALT=$(echo "$ALT + $incrementStepAlt" | bc)
            HDG=$(echo "$HDG + $incrementStepHdg" | bc)

            # Exit folder
            cd ..

            # Increment arduPilotInstance
            let arduPilotInstance=$(($arduPilotInstance+1))

            # This shouldn't be necessary, but let's give it some time to spin-up
            sleep 3
    done
fi

# Wait for all pids
for pid in ${pids[*]}; do
    wait $pid
done
