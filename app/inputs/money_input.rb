class MoneyInput
  include Formtastic::Inputs::Base

  def to_html
    template.capture do
      builder.input "#{method}_currency", as: :select, collection: Currency.present_all, include_blank: false, label: "Currency", required: true
      builder.input "human_#{method}", label: label_text, required: true
    end
  end
end
