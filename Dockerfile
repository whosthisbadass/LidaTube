FROM python:3.12-alpine

# Set build arguments
ARG RELEASE_VERSION
ENV RELEASE_VERSION=${RELEASE_VERSION}

# Install ffmpeg, su-exec, redsocks, and iptables
RUN apk update && \
    apk add --no-cache ffmpeg su-exec redsocks iptables

# Copy LidaTube code into container
COPY . /lidatube
WORKDIR /lidatube

# Set Python path and install requirements
ENV PYTHONPATH=/lidatube/src
RUN pip install --no-cache-dir -r requirements.txt

# Make the original init script executable
RUN chmod +x thewicklowwolf-init.sh

# Expose port 5000
EXPOSE 5000

# Copy our dynamic entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use our new entrypoint
ENTRYPOINT ["/entrypoint.sh"]
