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
    git push --follow-tags

    # Create new release
    release=$(curl -XPOST -s -H "Authorization:token ${GITHUB_TOKEN}" \
        --data "{\"tag_name\": \"${VERSION}\", \"name\": \"version ${VERSION}\", \"body\": \"${description}\", \"draft\": false, \"prerelease\": false}" \
        https://api.github.com/repos/${REPOSITORY}/releases)

    # Extract the id of the release from the creation response
    release_id=$(echo "$release" | sed -n -e 's/"id":\ \([0-9]\+\),/\1/p' | head -n 1 | sed 's/[[:blank:]]//g')
    
    # Check if release was correctly created
    if [ -z ${release_id} ]; then
        echo "[ERROR] Creating Github Release. No ID received"
        echo $release
        
        echo "[ERROR] Deleting created tag (${VERSION})"
        git tag -d ${VERSION}
        git push --follow-tags
        exit 1;
    fi

    echo "Release ${release_id} created !"

    # Upload the assets
    echo "Upload the assets from upload folder"
    for f in upload/*; do
        assetsUpload "${release_id}" "${f}"
    done

}

assetsUpload()
{
    release_id=$1
    asset_path=$2
    asset_name=$(echo $f | sed 's/^upload\///g');

    echo "Upload : ${asset_name}"
    result=$(curl -XPOST -H "Authorization:token ${GITHUB_TOKEN}" \
        -H "Content-Type:application/binary" \
        --data-binary @${asset_path} \
        https://uploads.github.com/repos/CanalTP/hofundapi/releases/${release_id}/assets?name=${asset_name})

    if [ -z ${result} ]; then
        echo "[ERROR] Upload asset ${asset_path} \nResult : ${result}"

        echo "[ERROR] Deleting created tag (${VERSION})"
        git tag -d ${VERSION}

        echo "[ERROR] Deleting created release (version ${VERSION})"
        curl -XDELETE -s -H "Authorization:token ${GITHUB_TOKEN}" \
            https://api.github.com/repos/CanalTP/hofundapi/releases/${release_id}

    fi
}

###################################################################

############################## MAIN ###############################
validateParams
release
###################################################################
