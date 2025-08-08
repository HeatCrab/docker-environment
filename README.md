# Docker Development Environment - TA Training Lab1

A comprehensive Docker-based development environment designed for TA training, demonstrating modern containerization practices and providing hands-on experience with container lifecycle management.

## 🎯 Learning Objectives

This lab teaches essential Docker skills through practical implementation:

- **Docker Containerization**: Multi-stage builds, image optimization, and container management
- **Cross-platform Development**: Architecture-aware builds supporting AMD64 and ARM64  
- **Container Lifecycle Management**: Automated build, run, and management workflows

## 🏗️ Docker Architecture

### Multi-Stage Build Design

```dockerfile
FROM ubuntu:24.04 AS common_pkg_provider    # Core tools & Python/Miniconda
FROM ubuntu:24.04 AS verilator_provider     # Verilator from source
FROM ubuntu:24.04 AS systemc_provider       # SystemC 2.3.4 libraries
FROM ubuntu:24.04 AS base                   # Final production image
```

**Educational Benefits**: 
- Demonstrates layer optimization and build caching
- Shows parallel build capabilities
- Illustrates separation of concerns in containerization

### Architecture-Aware Configuration
Automatically detects and configures for AMD64/ARM64 architectures, demonstrating cross-platform container design patterns.

## 🚀 Container Management with `docker.sh`

### Intelligent Container Lifecycle
```bash
./docker.sh build          # Build image if not exists
./docker.sh run            # Smart container startup
./docker.sh stop           # Graceful shutdown
./docker.sh clean          # Complete cleanup
```

### Smart State Detection Logic
The script demonstrates advanced container management by automatically handling different states:
- **Container doesn't exist**: Creates new container with proper mounting
- **Container stopped**: Restarts existing container  
- **Container running**: Attaches to running container

### Advanced Mount Management
```bash
# Default behavior - creates ./projects mount
./docker.sh run

# Custom mounts with automatic path resolution
./docker.sh run -m ./src:/workspace -m ./data:/app/data

# Full customization options
./docker.sh run -u developer -h dev-env -m /host:/container
```

## 🛠️ Environment Management with `eman`

The `eman` script showcases container-internal tooling and automation (used inside the container):

```bash
# Development tool verification
eman check-verilator        # Verify Verilator installation
eman c-compiler-version     # Check GCC and Make versions

# Automated example execution
eman verilator-example projects/lab0/verilog/hello
eman c-compiler-example projects/lab0/c_cpp/pointers/address_operator

# Documentation
eman help                   # Show all available commands
```

**Key Features**:
- Installed at `/usr/local/bin/eman` during container build
- Provides shortcuts for common development tasks
- Automatically handles compilation and execution
- Demonstrates container-internal script management

**Learning Value**: Shows how to create user-friendly interfaces for complex development environments and integrate custom tooling into containers.

## 📊 Hands-On Lab Exercise

### Quick Start Tutorial
```bash
# Step 1: Build the development environment
./docker.sh build

# Step 2: Launch and enter the container  
./docker.sh run

# Step 3: Verify the environment (inside container)
eman check-verilator
eman c-compiler-version

# Step 4: Test with sample projects using eman
eman verilator-example projects/lab0/verilog/hello
eman c-compiler-example projects/lab0/c_cpp/numeric_data/size_of_data_type

# Step 5: Manual project exploration
cd projects/lab0/verilog/counter
make clean all

# Step 6: Understanding container persistence
exit                    # Container keeps running
./docker.sh run         # Re-enter same container
./docker.sh stop        # Proper shutdown
```

## 🎛️ Advanced Container Concepts

### Customization Examples
```bash
# User and mount customization
./docker.sh run -u $USER -m ./workspace:/dev -m ./data:/storage

# Container naming and networking
./docker.sh run -h training-env -c custom-container
```

### Container Inspection and Debugging
```bash
# Monitor container resources
docker stats aoc2026_container

# View container logs
docker logs aoc2026_container

# Inspect container configuration
docker inspect aoc2026_container
```

## 🛠️ Lab Materials Structure

```
.
├── docker.sh              # Container management script
├── Dockerfile              # Multi-stage build definition
├── eman.sh                 # Environment management utilities
└── projects/
    └── lab0/               # Sample development projects
        ├── c_cpp/          # C/C++ examples
        ├── python/         # Python examples
        └── verilog/        # Hardware description examples
```

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Master Docker through hands-on TA training! 🐳**