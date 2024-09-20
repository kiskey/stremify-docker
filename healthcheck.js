const http = require('http');

const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/',
    method: 'GET'
};

const req = http.request(options, (res) => {
    if (res.statusCode === 200) {
        process.exit(0); // Healthy
    } else {
        process.exit(1); // Unhealthy
    }
});

req.on('error', () => {
    process.exit(1); // Unhealthy
});

req.end();
