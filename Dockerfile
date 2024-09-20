# Stage 1: Build
FROM node:slim AS builder

# Install pnpm globally
RUN npm install -g pnpm@latest

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and pnpm-lock.yaml (if available)
COPY package.json pnpm-lock.yaml ./

# Install all dependencies (including devDependencies)
RUN pnpm install

# Copy the rest of the application code
COPY . .

# Build the application
RUN pnpm run build 

RUN pnpm prune --prod


# Expose the port the application uses
EXPOSE 3000

# Add a startup script to clean up the socket file and start the application
COPY start.sh /usr/src/app/start.sh
RUN chmod +x /usr/src/app/start.sh


# Command to run the startup script
CMD ["/usr/src/app/start.sh"]
