# Use an official Node.js runtime as the base image
FROM node:20-alpine

# Install pnpm globally
RUN npm install -g pnpm

# Set the working directory inside the container
WORKDIR /usr/src/app

# Clone the Stremify repository
RUN apk add --no-cache git \
    && git clone https://github.com/stremify/stremify.git . 

# Install required packages using pnpm
RUN pnpm install

# Copy environmental variables file if needed
# COPY .env .env  # Uncomment if you have a .env file for configuration

# Expose the port the application uses
EXPOSE 3000

# Command to run the application in dev mode
CMD ["pnpm", "run", "dev"]
