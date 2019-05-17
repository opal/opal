const path = require('path');
const OwlResolver = require('opal-webpack-loader/resolver');

const common_config = {
    context: path.resolve(__dirname, '../opal'),
    mode: "production",
    optimization: {
        minimize: true, // minimize
    },
    performance: {
        maxAssetSize: 20000000,
        maxEntrypointSize: 20000000
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, '../public/assets'),
        publicPath: '/assets/'
    },
    resolve: {
        plugins: [
            new OwlResolver('resolve', 'resolved', [
                // dont resolve these, use stubs instead
                'opal/platform.rb',
                "mspec-opal/runner.rb",
                "mspec/guards/block_device.rb",
                "stdlib/erb/erb_spec.rb",
                "ruby/language/source_encoding_spec.rb",
                "ruby/core/string/casecmp_spec.rb",
                "ruby/core/string/shared/to_sym.rb",
                "ruby/language/predefined_spec.rb",
                "ruby/core/regexp/union_spec.rb",
                "ruby/language/regexp_spec.rb",
                "ruby/core/regexp/to_s_spec.rb",
                "ruby/core/string/match_spec.rb",
                "ruby/core/regexp/source_spec.rb"
            ]) // resolve ruby files
        ]
    },
    module: {
        rules: [
            {
                // opal-webpack-loader will compile and include ruby files in the pack
                test: /.(rb|js.rb)$/,
                use: [
                    {
                        loader: 'opal-webpack-loader',
                        options: {
                            sourceMap: false,
                            hmr: false
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
        application: [path.resolve(__dirname, '../javascripts/application.js')]
    }
};

const ssr_config = {
    target: 'node',
    entry: {
        application_ssr: [path.resolve(__dirname, '../javascripts/application.js')]
    }
};

const web_worker_config = {
    target: 'webworker',
    entry: {
        web_worker: [path.resolve(__dirname, '../javascripts/application.js')]
    }
};

const browser = Object.assign({}, common_config, browser_config);
const ssr = Object.assign({}, common_config, ssr_config);
const web_worker = Object.assign({}, common_config, web_worker_config);

module.exports = [ browser ];
