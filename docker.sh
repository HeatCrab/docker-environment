#! /bin/bash

# This script is used to set up a Docker environment
# Simplify the process of running Docker commands

# If the command failes, exit immediately
set -e

DEFAULT_IMAGE_NAME="aoc2026_env"
DEFAULT_CONTAINER_NAME="aoc2026_container"

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
    if docker images --format "table {{.Repository}}" | grep -q "^${image_name}"; then
        return 0
    else
        return 1
    fi
}

build_image() {
    local image_name=${1:-$DEFAULT_IMAGE_NAME}

    print_info "Checking if Docker image '${image_name}' already exists..."
    
    if check_image_exists "${image_name}"; then
        print_warning "Docker image '${image_name}' already exists. Skipping build."
        print_info "If you want to rebuild the image, please remove it first using:"
        echo "  docker rmi ${image_name}"
        echo "Or use: ./docker.sh rebuild"
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
        rebuild         - Rebuild the Docker image
        help            - Show this help message
    
    Options:
        image_name      - Specify a custom image name (optional, default: ${DEFAULT_IMAGE_NAME})
    
    Example:
        $0 build
        $0 run
        $0 stop
        $0 remove
        $0 rebuild
        $0 help
    
    Default settings:
        Image Name:     ${DEFAULT_IMAGE_NAME}
        Container Name: ${DEFAULT_CONTAINER_NAME}
EOF
}

main() {
    if [ $# -eq 0 ]; then
        show_usage
        return 1
    fi

    # Parse command line arguments
    case "$1" in
        build)
            if [ $# -ge 2 ]; then
                build_image "$2"
            else
                build_image
            fi
            ;;
        "help")
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Use 'help' to see available commands."
            show_usage
            return 1
            ;;
    esac
}

# Run the main function with all arguments passed to the script
main "$@"