ParameterType(
  name: "amount",
  regexp: /-?[#{Monetize::Parser::CURRENCY_SYMBOLS.keys.join}]\d+(?:\.\d{2})?/,
  transformer: -> (amount) {
    Monetize.parse(amount)
  }
)
