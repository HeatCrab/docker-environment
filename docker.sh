#!/bin/bash

# This script is used to set up a Docker environment
# Simplify the process of running Docker commands

# If the command fails, exit immediately
set -e

# Change to the directory of the script
cd "$(dirname "$0")"

# Save the first command and shift to remove it from arguments
COMMAND="$1"
shift

DEFAULT_IMAGE_NAME="aoc2026_env"
DEFAULT_CONTAINER_NAME="aoc2026_container"
DEFAULT_USERNAME="$(id -un)"
DEFAULT_HOSTNAME="docker-env"
MOUNT_PATH=()

# Parse command line arguments (excluding the first command)
while [[ $# -gt 0 ]]; do
    case $1 in 
        --image_name|-i)
            [[ -z $2 || $2 == --* ]] && { echo "--image_name requires value"; exit 1; }
            DEFAULT_IMAGE_NAME=$2; shift 2 ;;
        --cont_name|-c)
            [[ -z $2 || $2 == --* ]] && { echo "--cont_name requires value"; exit 1; }
            DEFAULT_CONTAINER_NAME=$2; shift 2 ;;
        --username|-u)
            [[ -z $2 || $2 == --* ]] && { echo "--username requires value"; exit 1; }
            DEFAULT_USERNAME=$2; shift 2 ;;
        --hostname|-h)
            [[ -z $2 || $2 == --* ]] && { echo "--hostname requires value"; exit 1; }
            DEFAULT_HOSTNAME=$2; shift 2 ;;
        --mount|-m)
            [[ -z $2 || $2 == --* ]] && { echo "--mount requires value"; exit 1; }
            MOUNT_PATH+=("$2"); shift 2 ;;
        *)
            echo "Unknown flag: $1" && show_usage && exit 1 ;;
    esac
done

# Function to print messages in color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[info]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[success]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[warning]${NC} $1"
}

print_error() {
    echo -e "${RED}[error]${NC} $1"
}

check_image_exists() {
    local image_name="$1"
    if docker image inspect "${image_name}" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

check_container_status() {
    local container_name="$1"
    if docker container inspect "${container_name}" >/dev/null 2>&1; then
        # Container exists, check its status
        local status=$(docker container inspect "${container_name}" --format '{{.State.Status}}')
        if [ "${status}" == "running" ]; then
            echo "running"
        else
            echo "stopped"
        fi
    else
        # Container does not exist
        echo "not_exists"
    fi
}

run_container() {
    if ! check_image_exists "${DEFAULT_IMAGE_NAME}"; then
        print_error "Docker image '${DEFAULT_IMAGE_NAME}' does not exist."
        print_info "Please build the image first using: ./docker.sh build"
        return 1
    fi

    local status=$(check_container_status "${DEFAULT_CONTAINER_NAME}")
    print_info "Container '${DEFAULT_CONTAINER_NAME}' status: ${status}"

    case "${status}" in
        "running")
            print_info "Container '${DEFAULT_CONTAINER_NAME}' is already running. Entering..."
            docker exec -it --user "${DEFAULT_USERNAME}" "${DEFAULT_CONTAINER_NAME}" bash
            ;;
        "stopped")
            print_info "Container '${DEFAULT_CONTAINER_NAME}' exists but is stopped. Starting and entering..."
            docker start "${DEFAULT_CONTAINER_NAME}"
            docker exec -it --user "${DEFAULT_USERNAME}" "${DEFAULT_CONTAINER_NAME}" bash
            ;;
        "not_exists")
            print_info "Container '${DEFAULT_CONTAINER_NAME}' does not exist. Creating and starting..."
            
            # Default mount if none is specified
            if [[ ${#MOUNT_PATH[@]} -eq 0 ]]; then
                HOST_DEFAULT="$(pwd)/projects"
                CTR_DEFAULT="/home/${DEFAULT_USERNAME}/projects"
                mkdir -p "$HOST_DEFAULT"
                MOUNT_PATH+=("${HOST_DEFAULT}:${CTR_DEFAULT}")
                print_info "No mount specified, using default: ${HOST_DEFAULT} -> ${CTR_DEFAULT}"
            fi
            
            # Build docker run command with detached mode
            local docker_cmd="docker run -it -d --name ${DEFAULT_CONTAINER_NAME} --hostname ${DEFAULT_HOSTNAME}"
            
            # Add UID/GID environment variables
            docker_cmd="${docker_cmd} -e USERID=$(id -u) -e GROUPID=$(id -g)"
            
            # Parse and add mount points with HOST_PATH:CONTAINER_PATH format
            for mount_spec in "${MOUNT_PATH[@]}"; do
                # Use IFS to split HOST_PATH:CONTAINER_PATH
                IFS=':' read -r host_path container_path <<<"$mount_spec"
                
                # If no container path specified, use host path
                if [ -z "$container_path" ]; then
                    container_path="$host_path"
                fi
                
                # Convert relative path to absolute path
                if [[ "$host_path" != /* ]]; then
                    host_path="$(pwd)/${host_path}"
                fi
                
                # Create host directory if it doesn't exist
                if [ ! -e "$host_path" ]; then
                    mkdir -p "$host_path"
                    print_info "Created directory: ${host_path}"
                fi
                
                docker_cmd="${docker_cmd} -v ${host_path}:${container_path}"
                print_info "Mounting: ${host_path} -> ${container_path}"
            done
            
            # Complete the command
            docker_cmd="${docker_cmd} ${DEFAULT_IMAGE_NAME}"
            
            print_info "Executing: ${docker_cmd}"
            eval "${docker_cmd}"
            
            # Enter the container
            docker exec -it "${DEFAULT_CONTAINER_NAME}" bash
            ;;
        *)
            print_error "Unexpected container status: ${status}"
            return 1
            ;;
    esac
}

stop_container() {
    local container_name=${1:-$DEFAULT_CONTAINER_NAME}

    local status=$(check_container_status "${container_name}")

    case "${status}" in
        "running")
            print_info "Stopping container '${container_name}'..."
            docker stop "${container_name}" 2>/dev/null || true
            print_success "Container '${container_name}' stopped successfully."
            ;;
        "stopped")
            print_info "Container '${container_name}' is already stopped."
            ;;
        "not_exists")
            print_warning "Container '${container_name}' does not exist."
            ;;
        *)
            print_error "Unexpected container status: ${status}"
            return 1
            ;;
    esac
}

remove_container() {
    local container_name=${1:-$DEFAULT_CONTAINER_NAME}

    local status=$(check_container_status "${container_name}")

    case "${status}" in
        "running")
            print_info "Stopping and removing container '${container_name}'..."
            docker stop "${container_name}" 2>/dev/null || true
            docker rm "${container_name}" 2>/dev/null || true
            print_success "Container '${container_name}' stopped and removed successfully."
            ;;
        "stopped")
            print_info "Removing container '${container_name}'..."
            docker rm "${container_name}" 2>/dev/null || true
            print_success "Container '${container_name}' removed successfully."
            ;;
        "not_exists")
            print_warning "Container '${container_name}' does not exist."
            ;;
        *)
            print_error "Unexpected container status: ${status}"
            return 1
            ;;
    esac
}

clean_all() {
    local image_name=${1:-$DEFAULT_IMAGE_NAME}
    local container_name=${2:-$DEFAULT_CONTAINER_NAME}

    print_info "Cleaning up Docker environment..."
    remove_container "${container_name}"
    if check_image_exists "${image_name}"; then
        print_info "Removing Docker image '${image_name}'..."
        docker rmi "${image_name}" 2>/dev/null || {
            print_error "Failed to remove Docker image '${image_name}'. It may be in use by another container."
            print_info "Please stop and remove any containers using this image first."
            return 1
        }
        print_success "Docker image '${image_name}' removed successfully."
    else
        print_warning "Docker image '${image_name}' does not exist. No action needed."
    fi
}

rebuild_image() {
    local image_name=${1:-$DEFAULT_IMAGE_NAME}
    local container_name=${2:-$DEFAULT_CONTAINER_NAME}

    print_info "Rebuilding Docker image '${image_name}'..."
    clean_all "${image_name}" "${container_name}"
    build_image "${image_name}" "nocache"
}

build_image() {
    local image_name=${1:-$DEFAULT_IMAGE_NAME}
    local nocache="$2"

    print_info "Checking if Docker image '${image_name}' already exists..."
    
    if check_image_exists "${image_name}"; then
        print_warning "Docker image '${image_name}' already exists. Skipping build."
        print_info "If you want to rebuild the image, please use: ./docker.sh rebuild"
        return 0
    fi

    print_info "Docker image '${image_name}' does not exist. Building the image..."

    if [ ! -f Dockerfile ]; then
        print_error "Dockerfile not found in the current directory."
        print_error "Please ensure you are in the correct directory or provide a valid Dockerfile."
        return 1
    fi

    print_info "Using Dockerfile to build the image '${image_name}'..."
    
    # Build docker build command with build args
    local build_cmd="docker build"
    
    # Add no-cache option if specified
    if [ "$nocache" = "nocache" ]; then
        build_cmd="${build_cmd} --no-cache"
    fi
    
    # Add build arguments for UID/GID
    build_cmd="${build_cmd} --build-arg USERNAME=${DEFAULT_USERNAME}"
    build_cmd="${build_cmd} --build-arg USER_UID=$(id -u)"
    build_cmd="${build_cmd} --build-arg USER_GID=$(id -g)"
    build_cmd="${build_cmd} -t ${image_name} ."
    
    print_info "Executing: ${build_cmd}"
    if eval "${build_cmd}"; then
        print_success "Docker image '${image_name}' built successfully."
    else
        print_error "Failed to build Docker image '${image_name}'."
        return 1
    fi
}

# Function to show usage information
show_usage() {
cat << EOF
Docker Environment Management Script

USAGE:
    $0 <command> [options]

COMMANDS:
    build       Build the Docker image
    run         Run and enter the Docker container
    stop        Stop the running container
    remove      Remove the container
    clean       Remove both container and image
    rebuild     Rebuild the image (with --no-cache)
    help        Show this help message

OPTIONS:
    -i, --image_name     IMAGE_NAME      Docker image name (default: ${DEFAULT_IMAGE_NAME})
    -c, --cont_name      CONTAINER_NAME  Container name (default: ${DEFAULT_CONTAINER_NAME})
    -u, --username       USERNAME        Username in container (default: ${DEFAULT_USERNAME})
    -h, --hostname       HOSTNAME        Container hostname (default: ${DEFAULT_HOSTNAME})
    -m, --mount          HOST:CONTAINER  Mount paths (repeatable)

QUICK START:
    1. Build the image:         $0 build
    2. Run the container:       $0 run
    3. Stop when done:          $0 stop

EXAMPLES:
    # Basic workflow
    $0 build && $0 run

    # Custom configuration
    $0 run -u \$USER -m ./src:/workspace -m ./data:/app/data

    # Clean restart
    $0 clean && $0 build && $0 run

NOTES:
    • If no mounts specified, ./projects:/home/${DEFAULT_USERNAME}/projects is used
    • Container runs in detached mode, then automatically enters bash
    • Host directories are created automatically if they don't exist
EOF
}

# Check if command is provided
if [ -z "${COMMAND}" ]; then
    show_usage
    exit 1
fi

case $COMMAND in
    build)
        build_image
        ;;
    run)
        run_container
        ;;
    stop)
        stop_container
        ;;
    remove)
        remove_container
        ;;
    clean)
        clean_all
        ;;
    rebuild)
        rebuild_image
        ;;  
    help)
        show_usage
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        echo "  Use 'help' to see available commands."
        show_usage
        exit 1
        ;;
esac