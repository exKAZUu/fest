class PreferencesController < ApplicationController
  before_filter :authenticate_user!

  def update
    preference = params[:id]
    value = params[:value]
    status = if User.valid_preference?(preference)
      current_user.send("#{preference}=", value)
      :ok
    else
      :unprocessable_entity
    end
    render json: {}, status: status
  end
end
