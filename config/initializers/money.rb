# encoding : utf-8

MoneyRails.configure do |config|

  # To set the default currency
  #
  config.default_currency = :gbp

  # Set default bank object
  #
  # Example:
  # config.default_bank = EuCentralBank.new

  # Add exchange rates to current money bank object.
  # (The conversion rate refers to one direction only)
  #
  # Example:
  config.add_rate "GBP", "EUR", 1.1536
  config.add_rate "GBP", "USD", 1.3927
  config.add_rate "GBP", "CAD", 1.7740
  config.add_rate "GBP", "AUD", 1.8069

  config.add_rate "EUR", "GBP", 0.86684
  config.add_rate "EUR", "USD", 1.2072
  config.add_rate "EUR", "CAD", 1.5377
  config.add_rate "EUR", "AUD", 1.5663

  config.add_rate "USD", "EUR", 0.82833
  config.add_rate "USD", "GBP", 0.71803
  config.add_rate "USD", "CAD", 1.2738
  config.add_rate "USD", "AUD", 1.2974

  config.add_rate "CAD", "USD", 0.78507
  config.add_rate "CAD", "EUR", 0.65030
  config.add_rate "CAD", "GBP", 0.56371
  config.add_rate "CAD", "AUD", 1.0186

  config.add_rate "AUD", "CAD", 0.98176
  config.add_rate "AUD", "USD", 0.77075
  config.add_rate "AUD", "EUR", 0.63844
  config.add_rate "AUD", "GBP", 0.55343

  # To handle the inclusion of validations for monetized fields
  # The default value is true
  #
  # config.include_validations = true

  # Default ActiveRecord migration configuration values for columns:
  #
  config.amount_column = { prefix: '',           # column name prefix
                           postfix: '_decimals',    # column name  postfix
                           column_name: nil,     # full column name (overrides prefix, postfix and accessor name)
                           type: :integer,       # column type
                           present: true,        # column will be created
                           null: false,          # other options will be treated as column options
                           default: 0
                         }
  #
  # config.currency_column = { prefix: '',
  #                            postfix: '_currency',
  #                            column_name: nil,
  #                            type: :string,
  #                            present: true,
  #                            null: false,
  #                            default: 'USD'
  #                          }

  # Register a custom currency
  #
  # Example:
  # config.register_currency = {
  #   priority:            1,
  #   iso_code:            "EU4",
  #   name:                "Euro with subunit of 4 digits",
  #   symbol:              "€",
  #   symbol_first:        true,
  #   subunit:             "Subcent",
  #   subunit_to_unit:     10000,
  #   thousands_separator: ".",
  #   decimal_mark:        ","
  # }

  # Specify a rounding mode
  # Any one of:
  #
  # BigDecimal::ROUND_UP,
  # BigDecimal::ROUND_DOWN,
  # BigDecimal::ROUND_HALF_UP,
  # BigDecimal::ROUND_HALF_DOWN,
  # BigDecimal::ROUND_HALF_EVEN,
  # BigDecimal::ROUND_CEILING,
  # BigDecimal::ROUND_FLOOR
  #
  # set to BigDecimal::ROUND_HALF_EVEN by default
  #
  config.rounding_mode = BigDecimal::ROUND_HALF_UP

  # Set default money format globally.
  # Default value is nil meaning "ignore this option".
  # Example:
  #
  # config.default_format = {
  #   no_cents_if_whole: nil,
  #   symbol: nil,
  #   sign_before_symbol: nil
  # }

  # If you would like to use I18n localization (formatting depends on the
  # locale):
  config.locale_backend = :i18n
  #
  # Example (using default localization from rails-i18n):
  #
  # I18n.locale = :en
  # Money.new(10_000_00, 'USD').format # => $10,000.00
  # I18n.locale = :es
  # Money.new(10_000_00, 'USD').format # => $10.000,00
  #
  # For the legacy behaviour of "per currency" localization (formatting depends
  # only on currency):
  # config.locale_backend = :currency
  #
  # Example:
  # Money.new(10_000_00, 'USD').format # => $10,000.00
  # Money.new(10_000_00, 'EUR').format # => €10.000,00
  #
  # In case you don't need localization and would like to use default values
  # (can be redefined using config.default_format):
  # config.locale_backend = nil

  # Set default raise_error_on_money_parsing option
  # It will be raise error if assigned different currency
  # The default value is false
  #
  # Example:
  # config.raise_error_on_money_parsing = false

  Monetize.assume_from_symbol = true
end
