require 'digest'
require 'base64'

##
# This controller contains the logic to refresh a JWT by passing a JWT.
class TokenController < SecuredController
  before_action :calc_current_hash
  before_action :decode_token

  ##
  # Method to refresh a token.
  # It loads the current token from the request's authorization header.
  def refresh_token
    if @current_hash == @decoded_token['payload']['hash']
      # token is still valid and hash is similar, so return new token
      @decoded_token['payload'].delete('exp')
      new_token = Knock::AuthToken.new payload: @decoded_token['payload']

      render json: new_token, status: :created
    else
      render json: '{"IAm": "sombra", "Message":"user has changed, cannot refresh token. Boop!"}', status: 401
    end
  end

  private

  def calc_current_hash
    @current_hash = Digest::SHA256.base64digest current_user.updated_at.to_s
  end

  def decode_token
    token = request.headers['Authorization'].split.last
    @decoded_token = {}
    @decoded_token['header'] = JSON.parse(Base64.decode64(token.split('.')[0]))
    @decoded_token['payload'] = JSON.parse(Base64.decode64(token.split('.')[1]))
  end
end
