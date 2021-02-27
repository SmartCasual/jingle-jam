const { environment } = require('@rails/webpacker')

environment.config.merge({
  output: {
    // Makes exports from entry packs available to global scope, e.g.
    // Packs.application.myFunction
    library: ['Packs', '[name]'],
    libraryTarget: 'var'
  },
})

module.exports = environment
