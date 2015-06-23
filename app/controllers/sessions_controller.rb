class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def new
    # call login template
  end

  # Login
  def create

    if request.xhr?
      p params
      @user = User.find_by(username: params["email"])

      if @user.nil?
        @user = User.new(username: params["email"], image_url: params["imageUrl"])
        @user.voted_issues = Issue.all
        @user.save
      end

      session[:username] = @user.username

      render json: {}
    else
      @user = User.find_by(id: params[:user_id])

      session[:username] = nil
      session[:username] = @user.username

      redirect_to request.referer
    end
  end

  def destroy
    session[:username] = nil
    redirect_to request.referer
  end

  def clear
    session[:username] = nil
    p session[:username]
    redirect_to "/"
  end
end
