class ApplicationController < ActionController::API
  include Knock::Authenticable

  def index
    render json: {Iam: "sombra", pubkey: Rails.application.secrets.token_es256_pub}
  end
end
