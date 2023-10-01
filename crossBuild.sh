vehicleType=$1
version=$2
buildArgs="--build-arg ${version}"

if [[ "$vehicleType" == "" || "$vehicleType" == "copter" ]]; then
    echo "Building ArduCopter"
    vehicleType="copter"
elif [[ "$vehicleType" == "plane" || "$vehicleType" == "ArduPlane" ]]; then
    echo "Building ArduPlane"
    vehicleType="plane"
    buildArgs="${buildArgs} --build-arg VEHICLE_TYPE=1"
else 
    echo "Invalid vehicle type, using ArduCopter"
    vehicleType="copter"
fi

# Add QEMU stuff
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Create and bootstrap builder
docker buildx create --name mubuilder
docker buildx use mubuilder
docker buildx inspect --bootstrap

# Build and push images
docker buildx build ${buildArgs} --tag ubcuas/uasitl:${vehicleType}-arm-${version} --output type=image arm/ --platform "linux/arm64,linux/arm/v7"

# Cleanup
docker buildx rm mubuilder