const fs = require('fs');

if (process.env.MIX_MODE === 'hot') {
    mix.options({
        hmrOptions: {
            host: 'localhost',
            port: process.env.WEBPACK_PORT,
        }
    });
    mix.webpackConfig({
        devServer: {
            https: true,
            key: fs.readFileSync('/etc/ssl/server.key'),
            cert: fs.readFileSync('/etc/ssl/server.crt'),
            headers: {
                'Access-Control-Allow-Origin': '*'
            },
            host: '0.0.0.0',
            port: process.env.WEBPACK_PORT,
            public: 'https://localhost:' + process.env.WEBPACK_PORT
        },
    });
}

if (process.env.MIX_BROWSERSYNC === 'enabled') {
    mix.browserSync({
        https: {
            key: "/etc/ssl/server.key",
            cert: "/etc/ssl/server.crt"
        },
        notify: false,
        open: false,
        files: [
            './resources/views/**/*.blade.php',
            './app/**/*.php',
        ],
        reload: false
    });
}
