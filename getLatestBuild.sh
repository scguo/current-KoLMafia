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

if [ -f .env ]
then
    export $(grep -v '^#' .env | xargs)
fi

# Download the latest build ...
 LATEST=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_PERSONAL_KEY" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/kolmafia/kolmafia/releases/latest \
  | grep -o 'https://github.com/kolmafia/kolmafia/releases/download/r[0-9][0-9][0-9][0-9][0-9]/KoLmafia-[0-9][0-9][0-9][0-9][0-9].jar' | head -1)
# LATEST='https://github.com/kolmafia/kolmafia/releases/download/r27528/KoLmafia-27528.jar'

echo "Current latest jar is: $LATEST"

# Check whether the current build is already present. If it is, don't bother downloading it again.
# The filename for KoLmafia is still 18 characters long, and that seems unlikely to change in the near future.
# This is a bit of a hacky solution, though ...

if [ -f ${LATEST:(-18)} ]
then
    echo "Latest KoLmafia build already present: ${LATEST##*/}" 
else
    echo "Fetching latest KoLmafia build: ${LATEST##*/}"
    echo "making a storage folder for old version/s..."
    mkdir -p old_versions
    echo "saving old versions..."
    mv -v KoL*jar old_versions
    curl -O $LATEST
    
fi

# Launch the newest build on-hand ...
java -jar ${LATEST##*/}

exit 0
