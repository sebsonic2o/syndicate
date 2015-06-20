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
    # p params
    # @user = User.find_by(username: params[:session][:username].downcase)
    # p @user
    # if @user && @user.authenticate(params[:session][:password])
    #   session[:username] = @user.username
    #   redirect_to @user
    # else
    #   # Create an error message.
    #   render 'new'
    # end
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
