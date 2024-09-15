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
RUN git clone https://github.com/stremify/stremify.git .

# Install required packages using pnpm
RUN pnpm install

# Copy environmental variables file if needed
# COPY .env .env  # Uncomment if you have a .env file for configuration

# Expose the port the application uses
EXPOSE 3000

# Command to run the application in dev mode
CMD ["pnpm", "run", "dev"]
