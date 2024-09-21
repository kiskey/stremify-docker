#!/bin/sh

# Remove stale socket files
if [ -d /tmp ]; then
    echo "Cleaning up stale socket files..."
    rm -f /tmp/nitro/*.sock
fi

# Start the application
exec "$@"
