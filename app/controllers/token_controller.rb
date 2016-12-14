require 'digest'
require 'base64'

class TokenController < SecuredController
  def refresh_token
    token = request.headers['Authorization'].split.last
    decoded_token = {}
    decoded_token['header'] = JSON.parse(Base64.decode64(token.split('.')[0]))
    decoded_token['payload'] = JSON.parse(Base64.decode64(token.split('.')[1]))

    current_hash = Digest::SHA256.base64digest current_user.updated_at.to_s

    if current_hash == decoded_token['payload']['hash']
      # token is still valid and hash is similar, so return new token
      decoded_token['payload'].delete('exp')
      new_token = Knock::AuthToken.new payload: decoded_token['payload']

      render json: new_token, status: :created
    else
      render json: '{"message":"user has changed, cannot refresh token"}', status: 401
    end
  end
end
