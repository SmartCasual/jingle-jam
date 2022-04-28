# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
unless Rails.env.test?
  Rails.application.config.filter_parameters += [
    :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn,
      :code, :code_ciphertext, :code_bidx, :encrypted_kms_key
  ]
end
