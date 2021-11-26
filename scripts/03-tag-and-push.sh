
Main() {
    echo "New Version is ${NEW_GIT_VERSION}"
    git tag ${NEW_GIT_VERSION}
    ssh-keyscan github.com >> ~/.ssh/known_hosts
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
