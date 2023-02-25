# Copy the shared libraries to the appropriate directories

sed -i 's/\r$//' lib/startArdupilotSITL.sh
cp lib/* arm/
cp lib/* x86/