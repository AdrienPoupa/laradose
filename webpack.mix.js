const mix = require('laravel-mix');

/*
 |--------------------------------------------------------------------------
 | Mix Asset Management
 |--------------------------------------------------------------------------
 |
 | Mix provides a clean, fluent API for defining some Webpack build steps
 | for your Laravel application. By default, we are compiling the Sass
 | file for the application as well as bundling up all the JS files.
 |
 */

mix.js('resources/js/app.js', 'public/js')
    .sass('resources/sass/app.scss', 'public/css');
    
// Docker additions
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
