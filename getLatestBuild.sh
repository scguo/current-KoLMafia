#!/bin/bash

#
# Quick-and-dirty script to retrieve the latest build of KoL Mafia, then launch it.
# Obtained from GitHub
# 
# Play KoL at: https://www.kingdomofloathing.com
#
# - Zombie Feynman (#1886944), a Curious Character
# - @scguo (on GitHub), a Bad Coder
#
# Time delay code Src: https://askubuntu.com/a/829425

# File that stores the last execution date in plain text. relies on file last touched date
datefile=./.datefile

launch_latest() {
    # Launch the newest build on-hand ...
    latestLocal=$(ls -t KoL*jar | head -1)
    echo "launching newest file $latestLocal, sit tight!"
    java -jar $latestLocal &
}

if [ -f .env ]
then
    export $(grep -v '^#' .env | xargs)
fi

if [ -z ${DELAY_DAYS} ]
then
echo "Missing .env variable DELAY_DAYS!!! Defaulting to zero days"
DELAY_DAYS=0
fi

# Minimum delay between two script executions, in seconds. 
delaySeconds=$((60*60*24*DELAY_DAYS))

echo "Update delay set to $delaaySeconds seconds ($DELAY_DAYS days)"

# Test if datefile exists and compare the difference between the stored date 
# and now with the given minimum delay in seconds. 
# Exit with error code 1 if the minimum delay is not exceeded yet.
if test -f "$datefile" ; then
    elapsedTime="$(($(date "+%s")-$(date -r "$datefile" "+%s")))"
    if test $elapsedTime -lt "$delaySeconds" ; then
        echo "Has been $elapsedTime second(s) since last run..."
        echo "$DELAY_DAYS day(s) have not passed...skipping update!"
        
        launch_latest
        exit 0
    fi
fi

# Store the current date and time in datefile. Not this method relies on file last modified date.
date -R > "$datefile"

# Download the latest build ...
 
 LATESTJAR=$(curl -L \
  https://ci.kolmafia.us/job/Kolmafia/lastSuccessfulBuild/artifact/dist/ \
  | grep -o 'KoLmafia-[0-9][0-9][0-9][0-9][0-9].jar' | head -1)

#LATESTJAR='KoLmafia-27532.jar'
LATEST="https://ci.kolmafia.us/job/Kolmafia/lastSuccessfulBuild/artifact/dist/$LATESTJAR"


echo "Current latest jar is: $LATEST"

if [ -z ${LATEST} ]
then
    echo "Empty response... something went wrong..."
    exit 1
fi

# Check whether the current build is already present. If it is, don't bother downloading it again.
# The filename for KoLmafia is still 18 characters long, and that seems unlikely to change in the near future.
# This is a bit of a hacky solution, though ...

if [ -f ${LATEST:(-18)} ]
then
    echo "Latest KoLmafia build already present: ${LATEST##*/}" 
else
    echo "making a storage folder for old version(s)..."
    mkdir -p old_versions
    echo "saving old versions..."
    mv -v KoL*jar old_versions

    echo "Fetching latest KoLmafia build: ${LATEST##*/}"
    curl -LO $LATEST
    
fi

# start the jar
launch_latest

exit $?
