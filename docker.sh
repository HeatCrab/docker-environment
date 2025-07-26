#!/bin/bash

# This script is used to set up a Docker environment
# Simplify the process of running Docker commands

# If the command fails, exit immediately
set -e

# Save the first command and shift to remove it from arguments
COMMAND="$1"
shift

DEFAULT_IMAGE_NAME="aoc2026_env"
DEFAULT_CONTAINER_NAME="aoc2026_container"
DEFAULT_USERNAME="user"
DEFAULT_HOSTNAME="docker-env"
MOUNT_PATH=()

# Parse command line arguments (excluding the first command)
while [[ $# -gt 0 ]]; do
    case $1 in 
        --image_name)
            [[ -z $2 || $2 == --* ]] && { echo "--image_name requires value"; exit 1; }
            DEFAULT_IMAGE_NAME=$2; shift 2 ;;
        --cont_name)
            [[ -z $2 || $2 == --* ]] && { echo "--cont_name requires value"; exit 1; }
            DEFAULT_CONTAINER_NAME=$2; shift 2 ;;
        --username)
            [[ -z $2 || $2 == --* ]] && { echo "--username requires value"; exit 1; }
            DEFAULT_USERNAME=$2; shift 2 ;;
        --hostname)
            [[ -z $2 || $2 == --* ]] && { echo "--hostname requires value"; exit 1; }
            DEFAULT_HOSTNAME=$2; shift 2 ;;
        --mount)
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
            
            # Build docker run command
            local docker_cmd="docker run -it --name ${DEFAULT_CONTAINER_NAME} --hostname ${DEFAULT_HOSTNAME}"
            
            # Add mount points
            for mount_path in "${MOUNT_PATH[@]}"; do
                if [ -d "${mount_path}" ] || [ -f "${mount_path}" ]; then
                    docker_cmd="${docker_cmd} -v ${mount_path}:${mount_path}"
                    print_info "Mounting: ${mount_path}"
                else
                    print_warning "Mount path does not exist: ${mount_path}"
                fi
            done
            
            # Add current directory mount
            docker_cmd="${docker_cmd} -v $(pwd):/workspace --workdir /workspace"
            docker_cmd="${docker_cmd} ${DEFAULT_IMAGE_NAME} bash"
            
            print_info "Executing: ${docker_cmd}"
            eval "${docker_cmd}"
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
            docker stop "${container_name}"
            print_success "Container '${container_name}' stopped successfully."
            ;;
        "stopped")
            print_info "Container '${container_name}' is already stopped."
            ;;
        "not_exists")
            print_error "Container '${container_name}' does not exist."
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
            docker stop "${container_name}"
            docker rm "${container_name}"
            print_success "Container '${container_name}' stopped and removed successfully."
            ;;
        "stopped")
            print_info "Removing container '${container_name}'..."
            docker rm "${container_name}"
            print_success "Container '${container_name}' removed successfully."
            ;;
        "not_exists")
            print_error "Container '${container_name}' does not exist."
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
        if docker rmi "${image_name}"; then
            print_success "Docker image '${image_name}' removed successfully."
        else
            print_error "Failed to remove Docker image '${image_name}'. It may be in use by another container."
            print_info "Please stop and remove any containers using this image first."
            return 1
        fi
    else
        print_warning "Docker image '${image_name}' does not exist. No action needed."
    fi
}

rebuild_image() {
    local image_name=${1:-$DEFAULT_IMAGE_NAME}
    local container_name=${2:-$DEFAULT_CONTAINER_NAME}

    print_info "Rebuilding Docker image '${image_name}'..."
    clean_all "${image_name}" "${container_name}"
    build_image "${image_name}"
}

build_image() {
    local image_name=${1:-$DEFAULT_IMAGE_NAME}

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
    if docker build -t "${image_name}" .; then
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

    Usage: $0 <command> [options]
    
    Commands:
        build           - Build the Docker image
        run             - Run the Docker container
        stop            - Stop the Docker container
        remove          - Remove the Docker container
        clean           - Clean up the Docker environment (remove container and image)
        rebuild         - Rebuild the Docker image
        help            - Show this help message
    
    Options:
        --image_name    IMAGE_NAME               Set the name of the Docker image (default: ${DEFAULT_IMAGE_NAME})
        --cont_name     CONTAINER_NAME           Set the name of the Docker container (default: ${DEFAULT_CONTAINER_NAME})
        --username      USERNAME                 Set the username inside container (default: ${DEFAULT_USERNAME})
        --hostname      HOSTNAME                 Set the hostname for container (default: ${DEFAULT_HOSTNAME})
        --mount         HOST_PATH                Mount a directory/file (can be used multiple times)
    
    Examples:
        $0 build
        $0 run --username \$USER --mount /home/data
        $0 stop
        $0 remove
        $0 rebuild
        $0 help
    
    Default settings:
        Image Name:     ${DEFAULT_IMAGE_NAME}
        Container Name: ${DEFAULT_CONTAINER_NAME}
        Username:       ${DEFAULT_USERNAME}
        Hostname:       ${DEFAULT_HOSTNAME}

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