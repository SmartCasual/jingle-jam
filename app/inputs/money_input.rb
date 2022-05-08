class MoneyInput
  include Formtastic::Inputs::Base

  def initialize(*args, default_currency: nil, **kwargs)
    super(*args, **kwargs)
    @required = kwargs[:required]
    @default_currency = default_currency
  end

  def to_html
    block = -> {
      builder.input "#{method}_currency",
        as: :select,
        collection: Currency.present_all,
        include_blank: !@required,
        label: "Currency",
        required: @required,
        selected: builder.object.send("#{method}_currency").presence || @default_currency
      builder.input "human_#{method}", label: label_text, required: @required
    }

    if builder&.options&.has_key?(:parent_builder)
      block.call
    else
      template.capture(&block)
    end
  end
end
