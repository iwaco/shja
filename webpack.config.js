'use strict';
const webpack = require('webpack');
const path = require('path');
module.exports = {
    devtool: 'eval-source-map',
    entry: [
        path.join(__dirname, 'app/client/js/main.js')
    ],
    output: {
        path: path.join(__dirname, 'dist/js'),
        filename: '[name].js',
        publicPath: '/js/'
    },
    module: {
        loaders: [{
            test: /\.js?$/,
            exclude: /node_modules/,
            loader: 'babel-loader'
        }, {
            test: /bootstrap\/js\//,
            loader: 'imports?jQuery=jquery'
        // }, {
        //     test   : /\.css$/,
        //     loader : 'style!css'
        }, {
            test: /\.(scss)$/,
            use: [{
              loader: 'style-loader', // inject CSS to page
            }, {
              loader: 'css-loader', // translates CSS into CommonJS modules
            }, {
              loader: 'postcss-loader', // Run post css actions
              options: {
                plugins: function () { // post css plugins, can be exported to postcss.config.js
                  return [
                    require('precss'),
                    require('autoprefixer')
                  ];
                }
              }
            }, {
              loader: 'sass-loader' // compiles Sass to CSS
            }]
        },{
            test: /\.(png|woff|woff2|eot|ttf|svg|gif)$/,
            loader: 'url?limit=100000'
        }],
    },
};
