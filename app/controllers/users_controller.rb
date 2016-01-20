class UsersController < ApplicationController
  include QiitaModule

  def create
    redirect_to user_path(params[:user_id])
  end

  def show
    @weed = get_qiita_items(params[:user_id])
    logger.debug "@weed : #{@weed.inspect}"
    render layout: false, json: @weed
  end
end
