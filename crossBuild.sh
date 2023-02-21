# Add QEMU stuff
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Create and bootstrap builder
docker buildx create --name mubuilder
docker buildx use mubuilder
docker buildx inspect --bootstrap

# Build and push images
docker buildx build --tag ubcuas/uasitl:arm --output type=image arm/ --platform "linux/arm64,linux/arm/v7"

# Cleanup
docker buildx rm mubuilder