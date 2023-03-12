#!/bin/bash

numVehicles=${1}
initialAgentLat=${2}
initialAgentLon=${3}
initialAgentAlt=${4}
initialAgentHeading=${5}
incrementStepLat=${6}
incrementStepLon=${7}
VEHICLE=${8}
VEHICLEMODEL=${9}
SPEEDUP=${10}

incrementStepAlt=0
incrementStepHdg=0

echo "Number of ${VEHICLE}s: $numVehicles"

# Start ArduPilots
LAT=${initialAgentLat}
LON=${initialAgentLon}
ALT=${initialAgentAlt}
HDG=${initialAgentHeading}

echo "Initial Position: $LAT,$LON,$ALT,$HDG"
echo "Increment Lat: $incrementStepLat"
echo "Increment Lon: $incrementStepLon"
echo "VehicleModel: $VEHICLEMODEL"
echo "Speedup: $SPEEDUP"

arduPilotInstance=0

if [ $numVehicles -ne 0 ]; then
    for i in $(seq 0 $(($numVehicles-1))); do

            INSTANCE=$arduPilotInstance

            export SITL_RITW_TERMINAL="screen -D -m -S ${VEHICLE}${INSTANCE}"
            
            rm -rf ./${VEHICLE}${INSTANCE}
            mkdir ./${VEHICLE}${INSTANCE} && cd ${VEHICLE}${INSTANCE}

            simCommand="/vehicle/Tools/autotest/sim_vehicle.py \
                -I${INSTANCE} \
                --vehicle ${VEHICLE} \
                --custom-location=${LAT},${LON},${ALT},${DIR} \
                -w \
                --speedup ${SPEEDUP} \
                -f ${VEHICLEMODEL} \
                --no-rebuild \
                --no-mavproxy"

            echo "Starting Sim ${VEHICLE} with command '$simCommand'"
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
