class ApplicationController < ActionController::Base

  protect_from_forgery

  ACCESS_DENIED_PATH = '/reviews'

  helper_method :current_user, :signed_in?, :login_user

  def must_be_signed_in
    respond_to do |format|
      format.html {
        unless signed_in?
          flash[:notice] = "You must be signed in for that."
          store_return_url
          return redirect_to login_path
        end
      }
      format.json {}
      format.js {}
    end
  end

  private

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def signed_in?
    current_user.present?
  end

  def sign_in(user, options={})
    if options.delete(:permanent)
      cookies.permanent[:auth_token] = user.auth_token
    else
      cookies[:auth_token] = user.auth_token
    end
  end

  def store_return_url(path=request.fullpath)
    session[:return_to] = path
  end

  def reject_unauthorized(authorized=false, options={})
    path = options.delete(:path) || ACCESS_DENIED_PATH

    unless authorized
      respond_to do |format|
        format.html { return redirect_to path }
        format.json { return render json: {} }
      end
    end
  end

end
