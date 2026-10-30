vehicleType=$1
version=$2
buildArgs="--build-arg VERSION=${version}"

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
docker run --privileged --rm tonistiigi/binfmt --install arm64

# Build a single multi-arch image
# --load of a multi-platform image needs Docker's containerd image store enabled
docker buildx build ${buildArgs} --tag ubcuas/uasitl:${vehicleType}-${version} --load --platform "linux/amd64,linux/arm64" .