#!/bin/sh

# Remove the socket file if it exists
if [ -S /tmp/nitro/worker-19-1.sock ]; then
    rm /tmp/nitro/worker-19-1.sock
fi

# Start the application
exec pnpm start
