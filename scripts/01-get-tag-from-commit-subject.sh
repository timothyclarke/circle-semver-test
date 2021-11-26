Setup() {
    COMMIT_SUBJECT=$(git log -1 --pretty=%s.)
}

GetIncrement() {
    SEMVER_INCREMENT=$(echo "${COMMIT_SUBJECT}" | sed -En 's/.*\[semver:(major|minor|patch|skip)\].*/\1/p')
    echo "Commit subject: ${COMMIT_SUBJECT}"
    echo "export SEMVER_INCREMENT=\"$SEMVER_INCREMENT\""  >> "$BASH_ENV"
}

GetTicket() {
    JIRA_TICKET=$(echo "${COMMIT_SUBJECT}" | sed -En 's/.*((JIRA|TEST)\-[[:digit:]]+).*/\1/p')
    echo "export JIRA_TICKET=\"$JIRA_TICKET\""  >> "$BASH_ENV"
}

GetCurrentTag(){
    CURRENT_TAG=$(git for-each-ref --sort=creatordate --format '%(refname)' refs/tags| sed -En 's/.*(v([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+)).*/\1/p'| tail -1)
    echo "Current version is: ${CURRENT_TAG}"
    echo "export CURRENT_TAG=\"$CURRENT_TAG\""  >> "$BASH_ENV"
}

CheckIncrement() {
    if [ -z "${SEMVER_INCREMENT}" ];then
        echo "Commit subject did not indicate which SemVer increment to make."
        echo "To create a version, you can ammend the commit or push another commit with [semver:FOO] in the subject where FOO is major, minor, patch."
        echo "Note: To indicate intention to skip promotion, include [semver:skip] in the commit subject instead."
        if [ "$SHOULD_FAIL" == "1" ];then
            exit 1
        else
        echo "export PR_MESSAGE=\"BotComment: Versioning was skipped due to [semver:patch|minor|major] not being included in commit message.\""  >> "$BASH_ENV"
        fi
    elif [ "$SEMVER_INCREMENT" == "skip" ];then
        echo "SEMVER in commit indicated to skip orb release"
        echo "export PR_MESSAGE=\"BotComment: Versioning was skipped due to [semver:skip] in commit message.\""  >> "$BASH_ENV"
    else
        GetCurrentTag
    fi
}

CheckTicket() {
    if [ -z "${JIRA_TICKET}" ];then
        echo "Commit subject did not indicate a ticket for this change. eg JIRA-123"
        echo "To create a version, you can ammend the commit or push another commit with the ticket and a version meta eg [semver:FOO] in the subject where FOO is major, minor, patch."
        echo "Note: To indicate intention to skip promotion, include [semver:skip] in the commit subject instead."
        if [ "$SHOULD_FAIL" == "1" ];then
            exit 1
        else
        echo "export PR_MESSAGE=\"BotComment: Versioning was skipped due to Ticket reference and versioning [semver:patch|minor|major] not being included in commit message.\""  >> "$BASH_ENV"
        fi
    else
        CheckIncrement
    fi
}


Main() {
    Setup
    GetTicket
    GetIncrement
    CheckTicket
}

# Will not run if sourced for bats.
# View src/tests for more information.
TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
    Main
fi
