# Use Ubuntu as base image
FROM ubuntu:latest

# Install required packages
RUN apt update && apt install -y \
  iverilog \
  gtkwave \
  nano \
  && rm -rf /var/lib/apt/lists/*

# Set working directory inside the container
WORKDIR /verilog

# Default command: Open a shell
CMD ["/bin/bash"]
