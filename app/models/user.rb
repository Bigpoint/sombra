require 'digest'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :name, type: String
  field :password_digest, type: String
  field :role, type: String, default: 'application'

  validates :name, uniqueness: true
  validates :name, presence: true
  validates :role, presence: true

  has_secure_password

  def admin?
    self.role == 'admin'
  end

  def application?
    self.role == 'application'
  end

  def self.from_token_request request
    name = request.params["auth"] && request.params["auth"]["name"]
    self.find_by name: name
  end

  def to_token_payload
    payload = {}
    # std jwt claims
    payload['sub'] = self.id
    payload['iat'] = Time.now.utc.to_i
    payload['iss'] = Rails.application.secrets.jwt_issuer
    # sombra claims
    payload['role'] = self.role
    payload['name'] = self.name
    payload['hash'] = Digest::SHA256.base64digest self.updated_at.to_s
    return payload
  end
end
