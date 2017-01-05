# encoding: UTF-8
# frozen_string_literal: true

##
# The User model.
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

  ##
  # Method to check if current_user is an admin.
  def admin?
    role == 'admin'
  end

  ##
  # Method to check if current_user is an application.
  def application?
    role != 'admin'
  end

  ##
  # Method to find the correct user model by :name.
  # @note Knocks default is searching for emails.
  # @raise [UserNotFound] if the user cannot be found in mongodb
  def self.from_token_request(request)
    name = request.params['auth'] && request.params['auth']['name']
    find_by name: name
  end

  ##
  # Method to expand the returned JWT with more claims:
  #   * subject (sub)
  #   * issued at (iat)
  #   * issuer (iss)
  #   * role
  #   * name
  # @return [Hash] the payload as hash
  def to_token_payload
    payload = {}
    # std jwt claims
    payload['sub'] = id.to_s
    payload['iat'] = Time.now.utc.to_i
    payload['iss'] = Rails.application.secrets.jwt_issuer
    # sombra claims
    payload['role'] = role
    payload['name'] = name
    payload
  end
end
