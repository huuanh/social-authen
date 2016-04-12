class WelcomeController < ApplicationController
  def index
    if current_user
      @identities = Identity.where(user: current_user)
    else
      @identities = []
    end
  end
end
