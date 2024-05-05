# Copy the shared libraries to the appropriate directories

sed 's/\r$//' lib/startArdupilotSITL.sh > lib/startArdupilotSITL.sh.new
mv lib/startArdupilotSITL.sh.new lib/startArdupilotSITL.sh
cp lib/* arm/
cp lib/* x86/