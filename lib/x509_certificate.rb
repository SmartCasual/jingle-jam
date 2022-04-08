class X509Certificate
  def initialize(data)
    @cert = OpenSSL::X509::Certificate.new(data)
  end

  def common_name
    @common_name ||= get_subject_entry("CN")
  end

  def in_date?
    Time.zone.now.between?(@cert.not_before, @cert.not_after)
  end

  def verify(algorithm:, signature:, fingerprint:)
    @cert.public_key.verify_pss(
      algorithm,
      signature,
      fingerprint,
      salt_length: :auto,
      mgf1_hash: algorithm,
    )
  end

private

  def get_subject_entry(key)
    @cert.subject.to_a.assoc(key).second
  end
end
