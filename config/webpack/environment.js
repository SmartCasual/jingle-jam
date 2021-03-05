const { environment } = require('@rails/webpacker')
const jquery = require('./plugins/jquery')

environment.config.merge({
  output: {
    // Makes exports from entry packs available to global scope, e.g.
    // Packs.application.myFunction
    library: ['Packs', '[name]'],
    libraryTarget: 'var'
  },
})

environment.plugins.prepend('jquery', jquery)
module.exports = environment
