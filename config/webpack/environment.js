const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

environment.plugins.prepend(
    'Provide',
    new webpack.ProvidePlugin({
         $: 'jquery',
          jQuery: 'jquery',
          jquery: 'jquery',
          Popper: ['popper.js', 'default'],
          tinycolor: 'tinycolor2'
        })
)

environment.loaders.append('expose', {
      test: require.resolve('jquery'),
      use: [
                  { loader: 'expose-loader', options: '$' },
                  { loader: 'expose-loader', options: 'jQuery' },
                  { loader: 'expose-loader', options: 'tinycolor' }
                ]
})

module.exports = environment
