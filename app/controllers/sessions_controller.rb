class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def new
    # call login template
  end

  # Login
  def create

    if request.xhr?

      @user = User.find_by(username: params["email"])

      if @user.nil?
        @user = User.new(username: params["email"], image_url: params["imageUrl"], first_name: params["givenName"], last_name: params["familyName"])

        Issue.all.each do |issue|
          if !issue.closed?
            @user.voted_issues << issue
          end
        end

        if @user.save
          firebase_user
        end
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
    redirect_to "/"
  end

  private

    def firebase_user

      data = {
        id: @user.id,
        username: @user.username,
        first_name: @user.first_name,
        last_name: @user.last_name,
        image_url: @user.image_url
      }

      firebase_client.push("users", data)

    end
end
