# Use a base image
FROM ubuntu:22.04 AS builder

# Set non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    wget \
    unzip \
    python3 \
    python3-pip \
    libssl-dev \
    zlib1g-dev

# Set a working directory
WORKDIR /app

# Copy application source code (simulated)
COPY . /app/src

# Simulate downloading and extracting a library
RUN wget https://example.com/mylibrary.zip -O /tmp/mylibrary.zip && \
    unzip /tmp/mylibrary.zip -d /app/build/

# Create a build directory
RUN mkdir /app/build

# Change to the build directory
WORKDIR /app/build

# Simulate a complex build process
RUN cmake ../src -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_FEATURE_A=ON \
    -DENABLE_FEATURE_B=OFF \
    -DCMAKE_INSTALL_PREFIX=/usr/local

RUN make -j$(nproc)

RUN make install

# Install Python dependencies using a requirements file
COPY /app/src/requirements.txt /app/src/requirements.txt
RUN pip3 install --no-cache-dir -r /app/src/requirements.txt

# --- Multi-stage build ---
FROM ubuntu:22.04

# Set non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl1.1 \
    zlib1g

# Create application directory
WORKDIR /app

# Copy the built application from the builder stage
COPY --from=builder /usr/local/bin/my_application /app/my_application
COPY --from=builder /usr/local/lib/mylibrary.so /app/lib/mylibrary.so

# Copy python stuff
COPY --from=builder /usr/local/lib/python3.10/site-packages /app/python_packages

# Set environment variables
ENV MY_APP_CONFIG="/app/config/app.conf"
ENV LOG_LEVEL="INFO"
ENV PORT="8080"

# Create a configuration directory
RUN mkdir /app/config

# Copy a configuration file
COPY /app/src/config/app.conf /app/config/app.conf

# Expose a port
EXPOSE 8080

# Define a health check (simulated)
HEALTHCHECK --interval=30s --timeout=5s \
    CMD curl -f http://localhost:8080/health || exit 1

# Define a volume
VOLUME /app/data

# Set the user to run the application as
USER nonroot:nonroot

# Command to run the application
CMD ["/app/my_application", "--config", "/app/config/app.conf", "--port", "8080"]

# Add some labels
LABEL maintainer="Your Name <your.email@example.com>"
LABEL version="1.2.3"
LABEL description="A complex application image"
LABEL org.opencontainers.image.source="https://github.com/yourorg/yourrepo"

# Add an arbitrary instruction
RUN echo "This is an arbitrary step"

# Final arbitrary instruction
RUN echo "Another arbitrary step"
