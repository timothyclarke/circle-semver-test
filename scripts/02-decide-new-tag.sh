Setup(){
    CURRENT_MAJOR=$(echo ${CURRENT_TAG} | sed -En 's/.*([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+).*/\1/p')
    CURRENT_MINOR=$(echo ${CURRENT_TAG} | sed -En 's/.*([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+).*/\2/p')
    CURRENT_PATCH=$(echo ${CURRENT_TAG} | sed -En 's/.*([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+).*/\3/p')
}

Major(){
    NEW_VERSION="v$((${CURRENT_MAJOR}+1)).0.0"
}

Minor(){
    NEW_VERSION="v${CURRENT_MAJOR}.$((${CURRENT_MINOR}+1)).0"
}

Patch(){
    NEW_VERSION="v${CURRENT_MAJOR}.${CURRENT_MINOR}.$((${CURRENT_PATCH}+1))"
}

Main() {
    Setup
    if [ "${SEMVER_INCREMENT}" == "major" ];then
      Major
    elif [ "${SEMVER_INCREMENT}" == "minor" ];then
      Minor
    else
      Patch
    fi
    echo "New Version is: ${NEW_VERSION}"
    echo "export NEW_GIT_VERSION=\"$NEW_VERSION\""  >> "$BASH_ENV"
}


# Will not run if sourced for bats.
# View src/tests for more information.
TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
    Main
else
    echo "TEST_ENV is wrong"
fi
