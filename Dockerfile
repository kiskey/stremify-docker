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

# Stage 2: Production
FROM node:slim

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy only the necessary files from the builder stage
COPY --from=builder /usr/src/app/.output /usr/src/app/.output
COPY --from=builder /usr/src/app/package.json ./
COPY --from=builder /usr/src/app/pnpm-lock.yaml ./

# Install pnpm globally in the production stage
RUN npm install -g pnpm@latest

# Install only production dependencies
RUN pnpm install --prod

# Copy the health check script
COPY healthcheck.js /usr/src/app/healthcheck.js

# Expose the port the application uses
EXPOSE 3000

# Add a startup script to clean up the socket file and start the application
COPY start.sh /usr/src/app/start.sh
RUN chmod +x /usr/src/app/start.sh

# Health check to ensure the application is running
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD node /usr/src/app/healthcheck.js

# Command to run the startup script
CMD ["/usr/src/app/start.sh"]
