# This dockerfile uses the ubuntu 24.04

#  Stage: Common Package Provider 
FROM ubuntu:24.04 AS common_pkg_provider

# Install Core CLI tools and Python
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y \
        vim \
        git \
        curl \
        wget \
        ca-certificates \
        build-essential \
        python3 \
        python3-pip && \
    # Create symlink for python3 to python
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Miniconda
ARG TARGETARCH
ARG CONDA_DIR=/opt/conda

RUN case "$TARGETARCH" in \
        "amd64") \
            wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;; \
        "arm64") \
            wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O miniconda.sh;; \
        *) \
            echo "Unsupported architecture: $TARGETARCH"; exit 1;; \
    esac && \
    bash miniconda.sh -b -p $CONDA_DIR && \
    rm miniconda.sh && \    
    ln -s $CONDA_DIR/etc/profile.d/conda.sh /etc/profile.d/conda.sh

# Stage: Verilater Provider
FROM ubuntu:24.04 AS verilator_provider

# Install Verilator dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y \
        git \
        autoconf \
        g++ \
        make \
        flex \
        bison \
        help2man \
        python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Verilator from source
RUN git clone https://github.com/verilator/verilator.git /tmp/verilator && \
    cd /tmp/verilator && \
    git checkout stable && \
    autoconf && \
    ./configure && make -j$(nproc) && make install && \
    rm -rf /tmp/verilator && \
    rm -rf /var/lib/apt/lists/*

# Stage: SystemC Provider
FROM ubuntu:24.04 AS systemc_provider

# Install SystemC dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y \
        g++ \
        make \
        wget \
        autoconf \
        tar \
        automake \
        libtool && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone and install SystemC
RUN wget https://github.com/accellera-official/systemc/archive/refs/tags/2.3.4.tar.gz && \
    tar -xzf 2.3.4.tar.gz && \
    cd systemc-2.3.4 && \
    mkdir build && autoreconf -i && cd build && \
    ../configure --prefix=/opt/systemc && \
    make -j$(nproc) && make install && \
    cd ../.. && rm -rf 2.3.4.tar.gz && rm -rf systemc-2.3.4 && \
    rm -rf /var/lib/apt/lists/*


# Stage: base image
FROM ubuntu:24.04 AS base

# Set mode in none interactive to avoid installation 
# from being interrupted and install the time zone data
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata &&\
    # Delete unneeded cache
    apt-get clean && rm -rf /var/lib/apt/lists/*

# set time zone Asia/Taipei
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Define non-root user 
ARG USERNAME=user
ARG USER_UID=1001
ARG USER_GID=1001        

# Copy common packages and conda from common_pkg_provider
COPY --from=common_pkg_provider /usr/bin /usr/bin
COPY --from=common_pkg_provider /usr/lib /usr/lib
COPY --from=common_pkg_provider /usr/local /usr/local
COPY --from=common_pkg_provider $CONDA_DIR $CONDA_DIR
COPY --from=common_pkg_provider /etc/profile.d/conda.sh /etc/profile.d/conda.sh

# Verilator and SystemC libraries from their respective providers 
COPY --from=verilator_provider /usr/local /usr/local
COPY --from=systemc_provider /opt/systemc /opt/systemc

RUN (groupadd -g $USER_GID $USERNAME 2>/dev/null || true) && \
    useradd -u $USER_UID -g $USER_GID -s /bin/bash -m $USERNAME &&\
    chown -R $USER_UID:$USER_GID /opt/conda && \
    mkdir -p /home/$USERNAME/.conda && \
    chown -R $USER_UID:$USER_GID /home/$USERNAME/.conda && \
    chown -R $USER_UID:$USER_GID /opt/systemc

# Set environment variables for conda
ENV PATH="/opt/conda/bin:$PATH"

# Set environment for SystemC, dynamically set library path based on architecture
ENV SYSTEMC_HOME=/opt/systemc
ENV SYSTEMC_CXXFLAGS="-I${SYSTEMC_HOME}/include -std=c++17"
ENV CPATH="${SYSTEMC_HOME}/include:"
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        echo "${SYSTEMC_HOME}/lib-linux64" > /etc/ld.so.conf.d/systemc.conf; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        echo "${SYSTEMC_HOME}/lib-linuxaarch64" > /etc/ld.so.conf.d/systemc.conf; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; exit 1; \
    fi && \
    ldconfig

# Create script to set SystemC LDFLAGS based on runtime architecture
RUN echo '#!/bin/bash' > /usr/local/bin/set-systemc-env.sh && \
    echo 'ARCH=$(uname -m)' >> /usr/local/bin/set-systemc-env.sh && \
    echo 'if [ "$ARCH" = "x86_64" ]; then' >> /usr/local/bin/set-systemc-env.sh && \
    echo '    export SYSTEMC_LDFLAGS="-L${SYSTEMC_HOME}/lib-linux64 -lsystemc"' >> /usr/local/bin/set-systemc-env.sh && \
    echo 'elif [ "$ARCH" = "aarch64" ]; then' >> /usr/local/bin/set-systemc-env.sh && \
    echo '    export SYSTEMC_LDFLAGS="-L${SYSTEMC_HOME}/lib-linuxaarch64 -lsystemc"' >> /usr/local/bin/set-systemc-env.sh && \
    echo 'fi' >> /usr/local/bin/set-systemc-env.sh && \
    chmod +x /usr/local/bin/set-systemc-env.sh && \
    echo 'source /usr/local/bin/set-systemc-env.sh' >> /etc/bash.bashrc

WORKDIR /home/$USERNAME

USER $USERNAME

CMD ["/bin/bash"]