# Use the official Node.js 20 slim runtime as the base image
FROM node:slim

# Install pnpm globally
RUN npm install -g pnpm

# Install git for cloning the repository
RUN apt-get update && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*  # Clean up the apt cache

# Set the working directory inside the container
WORKDIR /usr/src/app

# Clone the Stremify repository
RUN git clone https://github.com/kiskey/stremify-docker.git

# Install required packages using pnpm
RUN pnpm install

# Copy environmental variables file if needed
# COPY .env .env  # Uncomment if you have a .env file for configuration

# Add a startup script to clean up the socket file and start the application
COPY start.sh /usr/src/app/start.sh
RUN chmod +x /usr/src/app/start.sh

# Expose the port the application uses
EXPOSE 3000

# Health check to ensure the application is running
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:3000/ || exit 1

# Command to run the startup script
CMD ["/usr/src/app/start.sh"]
