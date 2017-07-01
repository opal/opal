'use strict';

const webpack = require('webpack');

function criWrapper(_, options, callback) {
    window.criRequest(options, callback);
}

const webpackConfig = {
    resolve: {
        alias: {
            'ws': './websocket-wrapper.js'
        }
    },
    externals: [
        {
            './external-request.js': `var (${criWrapper})`
        }
    ],
    module: {
        loaders: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                loader: 'babel-loader'
            },
            {
                test: /\.json$/,
                loader: 'json'
            }
        ]
    },
    plugins: [
    ],
    entry: './index.js',
    output: {
        libraryTarget: process.env.TARGET || 'commonjs2',
        library: 'CDP',
        filename: 'chrome-remote-interface.js'
    }
};

if (process.env.DEBUG !== 'true') {
    webpackConfig.plugins.push(new webpack.optimize.UglifyJsPlugin({
        mangle: true,
        compress: {
            warnings: false
        },
        output: {
            comments: false
        }
    }));
}

module.exports = webpackConfig;
