
Main() {
    git tag ${NEW_GIT_VERSION}
    git push --tags
}


# Will not run if sourced for bats.
# View src/tests for more information.
TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
    Main
else
    echo "TEST_ENV is wrong"
fi
