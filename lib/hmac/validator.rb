class HMAC::Validator
  def initialize(*args)
    @generator = HMAC::Generator.new(*args)
  end

  def validate(hmac, against_id:)
    hmac.present? && hmac == @generator.generate(id: against_id)
  end
end
