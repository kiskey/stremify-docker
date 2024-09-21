# Stage 1: Build Stage
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

# Build the application (this will run vite and any other build tools)
RUN pnpm run build

# Prune devDependencies to leave only production dependencies
RUN pnpm prune --prod

# Stage 2: Production Stage
FROM node:slim AS production

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the built application from the builder stage
COPY --from=builder /usr/src/app ./

# Ensure the startup script is executable
COPY start.sh /usr/src/app/start.sh
RUN chmod +x /usr/src/app/start.sh

# Expose the application port
EXPOSE 3000

# Run the startup script
ENTRYPOINT ["/usr/src/app/start.sh"]
