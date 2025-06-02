# Stage 1: Builder
# Use a Node.js image with pnpm pre-installed. Node 20 is a good modern choice.
FROM node:20-alpine AS builder

# Install pnpm globally. Use the specific version from your pnpm-lock.yaml if needed for strict reproducibility.
# Your package.json says "pnpm@7.33.5", so let's stick to that for consistency.
RUN npm install -g pnpm@7.33.5

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy pnpm lockfile and package.json first to leverage Docker cache
COPY package.json pnpm-lock.yaml ./

# Install all dependencies (including devDependencies)
# --frozen-lockfile ensures exact versions are used from pnpm-lock.yaml
# This step will also run the `prepare` script successfully because 'nitro' is available.
RUN pnpm install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Build the application. This generates the production-ready .output directory.
# The `nitro build` command handles bundling and optimizing dependencies for production.
RUN pnpm run build

# --- IMPORTANT: Remove the 'pnpm prune --prod' step ---
# This step is the source of your "nitro: not found" error because
# the 'prepare' script (which calls 'nitro prepare') runs during pruning,
# but 'nitro' might be unavailable after devDependencies are removed.
# When copying only .output, this step is usually not needed.


# Stage 2: Final production image
# Use a minimal Node.js image for the final production container.
FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy ONLY the built files from the builder stage.
# Nitro's .output should be self-contained for runtime.
COPY --from=builder /usr/src/app/.output ./

# If you have an entrypoint.sh or other custom scripts needed at runtime
# that are *not* part of the .output bundle, copy them here.
# Assuming entrypoint.sh is in your root directory:
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose the port the application uses
EXPOSE 3000

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start the application directly
# The path here is relative to WORKDIR /usr/src/app (which now contains the .output content)
CMD ["node", "server/index.mjs"] # Confirm this path: .output/server/index.mjs becomes server/index.mjs after COPY ./.output ./
