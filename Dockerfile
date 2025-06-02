# Stage 1: Build
FROM node:20-alpine AS builder

# Install pnpm globally (using the version from your lockfile for consistency)
RUN npm install -g pnpm@7.33.5

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and pnpm-lock.yaml
COPY package.json pnpm-lock.yaml ./

# Install all dependencies (including devDependencies)
RUN pnpm install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Build the application
RUN pnpm run build

# Stage 2: Final production image
FROM node:20-alpine # Using alpine for smaller image

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy built files from the builder stage
COPY --from=builder /usr/src/app/.output ./

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose the port the application uses
EXPOSE 3000

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start the application directly
CMD ["node", "server/index.mjs"]
