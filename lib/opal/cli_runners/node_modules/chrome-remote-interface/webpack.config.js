'use strict';

const TerserPlugin = require('terser-webpack-plugin');
const webpack = require('webpack');

function criWrapper(_, options, callback) {
    window.criRequest(options, callback); // eslint-disable-line no-undef
}

module.exports = {
    mode: 'production',
    resolve: {
        fallback: {
            'util': require.resolve('util/'),
            'url': require.resolve('url/'),
            'http': false,
            'https': false,
            'dns': false
        },
        alias: {
            'ws': './websocket-wrapper.js'
        }
    },
    externals: [
        {
            './external-request.js': `var (${criWrapper})`
        }
    ],
    plugins: [
        new webpack.ProvidePlugin({
            process: 'process/browser',
        }),
    ],
    optimization: {
        minimizer: [
            new TerserPlugin({
                extractComments: false,
            })
        ],
    },
    entry: ['babel-polyfill', './index.js'],
    output: {
        path: __dirname,
        filename: 'chrome-remote-interface.js',
        libraryTarget: process.env.TARGET || 'commonjs2',
        library: 'CDP'
    }
};
