# Base Linux image
FROM ubuntu:24.04

# Optional build arg to skip cloning osxcross during image build (helps fast local tests)
ARG SKIP_OSXCROSS=0

# Install tools
RUN apt-get update && apt-get install -y \
    git cmake build-essential clang xz-utils python3 curl unzip wget ca-certificates sudo autoconf automake libtool pkg-config g++ make bash ninja-build \
    libssl-dev libxml2-dev libbz2-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Create osxcross directory
WORKDIR /opt/osxcross

# Clone osxcross unless SKIP_OSXCROSS=1
RUN if [ "${SKIP_OSXCROSS}" != "1" ]; then \
      git clone https://github.com/tpoechtrager/osxcross.git .; \
    else \
      echo "Skipping osxcross clone because SKIP_OSXCROSS=1"; \
      mkdir -p /opt/osxcross; \
    fi

ENV PATH="/opt/osxcross/target/bin:${PATH}"

# Create the tarballs dir
RUN mkdir -p /opt/osxcross/tarballs

# Add a small setup script that will run at container start. It will copy any SDK tarballs
# provided by the developer in the mounted workspace under /.devcontainer/SDK into osxcross
# and build osxcross at runtime. (We do this at runtime because SDK tarballs are not
# always present during image build and using COPY with globs and shell redirection
# can cause build-time errors.)

# The Docker build context is the workspace root, so reference the script using
# the path from the workspace root: .devcontainer/docker/setup-osxcross.sh
COPY --chown=root:root .devcontainer/docker/setup-osxcross.sh /usr/local/bin/setup-osxcross.sh
RUN chmod +x /usr/local/bin/setup-osxcross.sh

# Set the working directory to /workspace
WORKDIR /workspace

# Default command: run the setup script (which will copy SDK tarballs and optionally build osxcross), then drop to a shell
ENTRYPOINT ["/usr/local/bin/setup-osxcross.sh"]
CMD ["/bin/bash"]
