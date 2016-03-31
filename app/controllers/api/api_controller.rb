module Api
  class ApiController < ActionController::Base
    before_action :authenticate_user_from_token!
    before_action :authenticate_user!

    skip_before_filter :verify_authenticity_token

    skip_before_filter :authenticate_user_from_token!, only: [:ping, :cors]
    skip_before_filter :authenticate_user!, only: [:ping, :cors]

    respond_to :json

    def ping
      render json: { ping: :pong }
    end

    private

    def authenticate_user_from_token!

      # Set the authentication params if not already present
      if user_token = params[:user_token].blank? && request.headers["X-User-Token"]
        params[:user_token] = user_token
      end
      if user_email = params[:user_email].blank? && request.headers["X-User-Email"]
        params[:user_email] = user_email
      end

      user_email = params[:user_email].presence
      user = user_email && User.find_by(email: user_email)

      # Notice how we use Devise.secure_compare to compare the token
      # in the database with the token given in the params, mitigating
      # timing attacks.
      if user && Devise.secure_compare(user.authentication_token, params[:user_token])
        # Notice we are passing store false, so the user is not
        # actually stored in the session and a token is needed
        # for every request. If you want the token to work as a
        # sign in token, you can simply remove store: false.
        sign_in user, store: false
      end
    end

  end
end