#!/bin/sh
# Description:
# This script create a tag and a release. Also pushes all the needed assets.

############################ FUNCTIONS ############################
validateParams()
{
    if [ -z "${VERSION}" ]; then echo "Environment variable \$VERSION is empty, please set this before run the github_release.sh script" && exit 1; fi
    if [ -z "${REPOSITORY}" ]; then echo "Environment variable \$REPOSITORY is empty, please set this before run the github_release.sh script" && exit 1; fi
    if [ -z "${GITHUB_TOKEN}" ]; then echo "Environment variable \$GITHUB_TOKEN is empty, please set this before run the github_release.sh script" && exit 1; fi
}

release()
{
    # Get CHANGELOG description for the selected version
    changelog=$(cat CHANGELOG.md)
    description=$(sed -n "/### ${VERSION}/,/###/p" CHANGELOG.md | sed '1d;$d' | sed ':a;N;$!ba;s/\n/\\r\\n/g' | sed 's/* //g' )
    echo "Description to use :\n${description}"

    # Check if tag allready exists. 
    if [ $(git tag -l "${VERSION}") ]; then
        echo "[ERROR] Tag allready exists !"; exit 1;
    fi

    # Create new tag
    echo "Creation of tag for version ${VERSION}"
    git tag -a ${VERSION} -m "$description"

    # Create new release
    release=$(curl -XPOST -s -H "Authorization:token ${GITHUB_TOKEN}" \
        --data "{\"tag_name\": \"${VERSION}\", \"target_commitish\": \"master\", \"name\": \"version ${VERSION}\", \"body\": \"${description}\", \"draft\": false, \"prerelease\": false}" \
        https://api.github.com/repos/${REPOSITORY}/releases)

    # Extract the id of the release from the creation response
    release_id=$(echo "$release" | sed -n -e 's/"id":\ \([0-9]\+\),/\1/p' | head -n 1 | sed 's/[[:blank:]]//g')
    
    # Check if release was correctly created
    if [ -z ${release_id} ]; then
        echo "[ERROR] Creating Github Release. No ID received"
        echo $release
        
        echo "[ERROR] Deleting created tag (${VERSION})"
        git tag -d ${VERSION}
        exit 1;
    fi

    echo "Release ${release_id} created !"
}
###################################################################

############################## MAIN ###############################
validateParams
release
###################################################################
