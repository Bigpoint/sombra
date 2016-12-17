class ApplicationController < ActionController::API
  include Knock::Authenticable

  def index
    render json: {IAm: "sombra", Pubkey: Rails.application.secrets.token_es256_pub}
  end

  rescue_from "AccessGranted::AccessDenied" do |exception|
    render json: {IAm: "sombra", Message: "Authorization denied"}, status: 403
  end
end
