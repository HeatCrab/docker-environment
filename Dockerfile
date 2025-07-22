# This dockerfile uses the ubuntu 24.04

#  Stage: base
FROM ubuntu:24.04

# Set mode in none interactive to avoid
# installation from be interrupted
# And install the time zone date
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# set time zone Asia/Taipei
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

# Define non-root user 
ARG USERNAME=user
ARG USER_UID=1001
ARG USER_GID=1001        
RUN groupadd -g $USER_GID $USERNAME \
    && useradd -u $USER_UID -g $USER_GID -s /bin/bash $USERNAME \
    # Delete unneeded cache
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /app

USER $USERNAME

CMD ["/bin/bash"]