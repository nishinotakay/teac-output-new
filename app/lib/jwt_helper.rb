module JwtHelper
  EXPIRY = 24.hours

  def self.secret
    Rails.application.credentials.secret_key_base
  end

  def self.encode(payload)
    payload = payload.merge(exp: EXPIRY.from_now.to_i)
    JWT.encode(payload, secret, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret, true, algorithm: 'HS256')
    decoded.first.with_indifferent_access
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
