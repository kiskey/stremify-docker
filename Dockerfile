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

# Prune unnecessary dependencies
RUN pnpm prune --prod

# Stage 2: Final production image
FROM node:slim

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy built files from the builder stage
COPY --from=builder /usr/src/app/.output ./.output
COPY --from=builder /usr/src/app/package.json ./
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Expose the port the application uses
EXPOSE 3000

# Start the application directly without additional builds
CMD ["node", ".output/server/index.mjs"]
