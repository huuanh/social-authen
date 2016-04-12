class SessionsController < ApplicationController
  def create
    begin
      token = request.env['omniauth.auth']['credentials']['token']
      provider = request.env['omniauth.auth']['provider']
      uid = request.env['omniauth.auth']['uid']
      @user = User.from_omniauth(token, provider, uid)
      session[:user_id] = @user.id
      flash[:success] = "Welcome, #{@user.name}!"
      render json: @user.access_token
    rescue
      flash[:warning] = 'There was an error while trying to authenticate you...'
      redirect_to root_path
    end

    # respond_to do |format|
    #   format.html {redirect_to root_path}
    #   format.json {@user.access_token}
    # end
  end

  def destroy
    if current_user
      session.delete(:user_id)
      flash[:success] = 'See you!'
    end
    redirect_to root_path
  end
end
