class HMAC::Validator
  def initialize(...)
    @generator = HMAC::Generator.new(...)
  end

  def validate(hmac, against_id:)
    hmac.present? && hmac == @generator.generate(id: against_id)
  end
end
