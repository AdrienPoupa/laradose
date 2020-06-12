if (process.env.MIX_MODE === 'hot') {
    mix.options({
        hmrOptions: {
            host: 'localhost',
            port: 4445,
        }
    })
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
