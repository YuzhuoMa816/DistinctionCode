
#!/bin/bash

# Configurable variables

IMAGE_NAME="devops-api"
COMPOSE_FILE="docker-compose.yml"
HEALTH_URL="http://localhost/health"
LOG_FILE="/var/log/deploys.log"
HEALTH_STATUS="NOT_CHECKED"
EXIT_CODE=0
# check argument

if [ $# -ne 1 ]; then # if no version provided, number of arguments not equal to 1
    echo "Usage: $0 <version>"
    echo "Example deploy.sh v1.4.2" # show example usage
    exit 1
fi

VERSION="$1"
FULL_IMAGE_NAME="${IMAGE_NAME}:${VERSION}" # construct full image name with version tag, e.g. devops-api:v1.4.2

# Check Docker file exists

if [ ! -f Dockerfile ]; then  # [  ] mean test, if Dockerfile not exit (! for not)
    echo "Error No Dockerfile found in current directory: $(pwd)"
    exit 1
fi

# Build the Docker image

echo "Building Docker image: ${FULL_IMAGE_NAME}"

if  ! docker build -t "${FULL_IMAGE_NAME}" .; then  # Process docker build FULL_IMAGE_NAME, if ! , then exit
    echo "Error: Failed to build Docker image ${FULL_IMAGE_NAME}"
    exit 1
fi




# verify the image exists
IMAGE_ID=$(docker images -q "$FULL_IMAGE_NAME" | head -n 1)
#  -q (Quiet) for image id 

if [ -z  "$IMAGE_ID" ]; then
    echo "Error: Failed to find Docker image ${FULL_IMAGE_NAME}"
    exit 1
fi

echo "verify local image exists: $FULL_IMAGE_NAME"

# print image size
IMAGE_SIZE=$(docker images "$FULL_IMAGE_NAME" --format "{{.Size}}" | head -n 1)  
# from AI, standard image size fetch method 
# : find images by FULL_IMAGE_NAME, --format (only find the size related info, head -n 1 only find the first line(in case there are more than one images with same name) ) 

echo "Docker image ${FULL_IMAGE_NAME} built successfully with size ${IMAGE_SIZE}"


# check if compose file exists
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "Error: $COMPOSE_FILE not found in current directory: $(pwd)"
    exit 1
fi


# Show image line before update
BEFORE_LINE=$(grep -E "^[[:space:]]*image:[[:space:]]*${IMAGE_NAME}:" "$COMPOSE_FILE" | head -n 1 || true)
# FROM AI: Use extended Regex to find the image tag line in docker-compose.yml

if [ -z "$BEFORE_LINE" ]; then
    echo "ERROR: Could not find image line for ${IMAGE_NAME}:<tag> in $COMPOSE_FILE"
    exit 1
fi

echo "Before update: $BEFORE_LINE"

# Update image tag in docker-compose.yml
sed -i -E "s|(^[[:space:]]*image:[[:space:]]*)${IMAGE_NAME}:[^[:space:]]+|\1${FULL_IMAGE_NAME}|" "$COMPOSE_FILE"
#FROM AI:  sed -i to modify the file content replace the s|old content|new content|

# Show image line after update
AFTER_LINE=$(grep -E "^[[:space:]]*image:[[:space:]]*${IMAGE_NAME}:" "$COMPOSE_FILE" | head -n 1 || true) #FROM AI
echo "After update: $AFTER_LINE"



# Re-Deploy the application using docker compose

echo "Re-deploying application with docker compose..."
if docker compose -f "$COMPOSE_FILE" up -d --no-build; then # execute the docker compose --no-build from ai, docker have to use current image, can not rebuild when compose exec
    echo "Application re-deployed successfully"
else
    echo "Error: Failed to re-deploy application with docker compose"
    EXIT_CODE=1
fi

# only do health check when deployment is successful
if [ "$EXIT_CODE" = "0" ]; then
    # Wait for a few seconds to allow the application to start
    echo "Waiting for application to start..."
    sleep 5

    # Health check
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" || true) #From AI, fetch the http status code
    if [ "$HTTP_CODE" = "200" ]; then
        HEALTH_STATUS="PASSED"
        echo "Health check passed with HTTP code: $HTTP_CODE"
    else
        HEALTH_STATUS="FAILED"
        echo "ROLLBACK WARNING: Health check failed. $HEALTH_URL returned HTTP $HTTP_CODE."
        EXIT_CODE=1
    fi
fi


# Log the deployment result
sudo mkdir -p "$(dirname "$LOG_FILE")" # create logfile if LOG_FILE does not exist
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_RECORD="[$TIMESTAMP] Deployed ${FULL_IMAGE_NAME} - Health: ${HEALTH_STATUS} - Image Size: ${IMAGE_SIZE}"


echo "Writing deployment summary into log file: $LOG_FILE"

echo "$LOG_RECORD" | sudo tee -a "$LOG_FILE" > /dev/null # write the LOG_RECORD into the end of LOG_FILE ， > /dev/null not print on console

echo "Deployment summary: $LOG_RECORD"


exit "$EXIT_CODE"