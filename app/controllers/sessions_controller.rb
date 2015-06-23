class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def new
    # call login template
  end

  # Login
  def create
    p params
    @user = User.find_by(id: params[:user_id])
    p @user.username
    session[:username] = nil
    session[:username] = @user.username
    p session[:username]
    redirect_to request.referer
  end

  def destroy
    p session
    session[:username] = nil
    redirect_to "/"
  end

  def clear
    session[:username] = nil
    p session[:username]
    redirect_to "/"
  end
end
