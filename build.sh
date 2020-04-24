#!/usr/bin/env bash

#
# build.sh - Builds a Docker image for the SUNET upload and sign application.
#
# Author: Martin Lindström <martin@idsec.se>
# Author: Stefan Santesson <stefan@idsec.com>
#

usage() {
    echo "Usage: $0 [options...]" >&2
    echo
    echo "   -u, --user             Username for Maven repository (default is eidasuser)"
    echo "   -p, --passwd           Password for Maven repository (will be prompted for if not given)"
    echo "   -v, --version          Version for artifact to download"
    echo "   -i, --image            Name of image to create (default is upload-sign-sp)"
    echo "   -t, --tag              Optional docker tag for image"
    echo "   -c, --clear            Clears the target directory after a successful build (default is to keep it)"
    echo "   -h, --help             Prints this help"
    echo
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MAVEN_REPO_URL=https://maven.eidastest.se/artifactory/eidas-release-local
ARTIFACT_NAME=upload-sign-sp
ARTIFACT_REPO_PATH=/se/idsec/signservice/${ARTIFACT_NAME}/
FILE_EXTENSION=jar

USERNAME=""
PASSWD=""
VERSION=""
IMAGE_NAME=""
DOCKER_TAG=""
CLEAR_FLAG=false

while :
do
    case "$1" in
	-h | --help)
	    usage
	    exit 0
	    ;;
	-u | --user)
	    USERNAME="$2"
	    shift 2
	    ;;
	-p | --passwd)
	    PASSWD="$2"
	    shift 2
	    ;;
	-v | --version)
	    VERSION="$2"
	    shift 2
	    ;;
	-i | --image)
	    IMAGE_NAME="$2"
	    shift 2
	    ;;
	-t | --tag)
	    DOCKER_TAG="$2"
	    shift 2
	    ;;
	-c | --clear)
	    CLEAR_FLAG=true
	    shift 1
	    ;;
	--)
	    shift
	    break;
	    ;;
	-*)
	    echo "Error: Unknown option: $1" >&2
	    usage
	    exit 0
	    ;;
	*)
	    break
	    ;;
    esac
done

if [ "$VERSION" == "" ]; then
    echo "Error: Missing version" >&2
    usage
    exit 1
fi

if [ "$USERNAME" == "" ]; then
    USERNAME=eidasuser
    echo "Maven username not given, defaulting to $USERNAME" >&1
fi
if [ "$IMAGE_NAME" == "" ]; then
    IMAGE_NAME=upload-sign-sp
    echo "Docker image name not given, defaulting to $IMAGE_NAME" >&1
fi

if [ "$PASSWD" == "" ]; then
    echo -n "Maven password: "
    read -s PASSWD
    echo
fi

if [ -d "$SCRIPT_DIR/target" ]; then
    rm -rf "$SCRIPT_DIR/target"
fi
mkdir "$SCRIPT_DIR/target"

#
# Download distribution and signature
#

echo "Downloading ${ARTIFACT_NAME}-${VERSION}.${FILE_EXTENSION} ..."
HTTP_STATUS=$(curl --silent --user ${USERNAME}:${PASSWD} -o ${SCRIPT_DIR}/target/${ARTIFACT_NAME}.${FILE_EXTENSION} -w "%{http_code}" ${MAVEN_REPO_URL}${ARTIFACT_REPO_PATH}${VERSION}/${ARTIFACT_NAME}-${VERSION}.${FILE_EXTENSION})

if [ "$HTTP_STATUS" != "200" ]; then
    echo "Failed to download $ARTIFACT_NAME from Maven - got HTTP STATUS $HTTP_STATUS"
    exit 1
fi

echo "Downloading ${ARTIFACT_NAME}-${VERSION}.${FILE_EXTENSION}.asc (signature) ..."
HTTP_STATUS=$(curl --silent --user ${USERNAME}:${PASSWD} -o ${SCRIPT_DIR}/target/${ARTIFACT_NAME}.${FILE_EXTENSION}.asc -w "%{http_code}" ${MAVEN_REPO_URL}${ARTIFACT_REPO_PATH}${VERSION}/${ARTIFACT_NAME}-${VERSION}.${FILE_EXTENSION}.asc)

if [ "$HTTP_STATUS" != "200" ]; then
    echo "Failed to download signed file for $ARTIFACT_NAME from Maven - got HTTP STATUS $HTTP_STATUS"
    exit 1
fi

#
# Check signature
#

# Build a keyring containing the keys stored in the 'keys' directory

echo "Verifying signature on ${ARTIFACT_NAME}-${VERSION}.${FILE_EXTENSION} ..."

echo "Building trust keyring ..."
gpg --no-default-keyring --keyring $SCRIPT_DIR/target/maven-keyring.gpg --fingerprint > /dev/null 2>&1

for keyfile in $SCRIPT_DIR/keys/*; do
    echo "  Adding key file $keyfile ..."
    gpg --no-default-keyring --keyring=$SCRIPT_DIR/target/maven-keyring.gpg --import $keyfile > /dev/null 2>&1
done

echo

gpg --no-default-keyring --keyring $SCRIPT_DIR/target/maven-keyring.gpg --verify ${SCRIPT_DIR}/target/${ARTIFACT_NAME}.${FILE_EXTENSION}.asc ${SCRIPT_DIR}/target/${ARTIFACT_NAME}.${FILE_EXTENSION}

echo

if [ $? -eq 0 ]; then
    echo "Signature verification successful"
else
    echo "Signature did not verify correctly"
    exit 1
fi

#
# Unzip
#
#echo "Unzipping ${ARTIFACT_NAME}-${VERSION}.zip ..."
#unzip -qq -d target $SCRIPT_DIR/target/${ARTIFACT_NAME}-${VERSION}.zip

#
# Build Docker image
#

if [ "$DOCKER_TAG" != "" ]; then
    IMAGE_NAME="$IMAGE_NAME:$DOCKER_TAG"
fi

echo "Building Docker image '$IMAGE_NAME' ..."
docker build --no-cache=true -f "$SCRIPT_DIR/Dockerfile" -t $IMAGE_NAME $SCRIPT_DIR

if [ "$CLEAR_FLAG" == true ]; then
    rm -rf "$SCRIPT_DIR/target"
fi

echo "Done"
