class UsersController < ApplicationController
  def create
    redirect_to user_path(params[:user_id])
  end

  def show
    render layout: false
  end
end
