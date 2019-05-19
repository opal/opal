const path = require('path');
const OwlResolver = require('opal-webpack-loader/resolver'); // to resolve ruby files

const common_config = {
    mode: 'production',
    performance: {
        maxAssetSize: 20000000,
        maxEntrypointSize: 20000000
    },
    output: {
        path: path.resolve(__dirname),
        filename: '[name].js',
        libraryTarget: 'var',
        // globalObject: 'this',
        // libraryExport: 'default',
        library: '[name]'
    },
    // externals: {
    //     'lodash': {
    //         commonjs: 'lodash',
    //         commonjs2: 'lodash',
    //         amd: 'lodash',
    //         root: '_'
    //     }
    // },
    resolve: {
        plugins: [
            // this makes it possible for webpack to find ruby files
            new OwlResolver('resolve', 'resolved')
        ]
    },
    module: {
        rules: [
            {
                test: /\.(js)$/,
                exclude: /(node_modules)/
            },
            {
                // opal-webpack-loader will compile and include ruby files in the pack
                test: /.(rb|js.rb)$/,
                use: [
                    {
                        loader: 'opal-webpack-loader',
                        options: {
                            sourceMap: true,
                            hmr: false,
                            hmrHook: ''
                        }
                    }
                ]
            }
        ]
    }
};

const browser_config = {
    target: 'web',
    entry: {
        opal: path.resolve(__dirname, 'entry_opal.js'),
        parser: path.resolve(__dirname, 'entry_opal_parser.js'),
    }
};

const node_config = {
    target: 'node',
    entry: {
        opal_node: path.resolve(__dirname, 'entry_opal_node.js'),
        parser_node: path.resolve(__dirname, 'entry_opal_parser.js'),
    }
};

const browser = Object.assign({}, common_config, browser_config);
const node = Object.assign({}, common_config, node_config);

module.exports = [ browser, node ];