class BeersController < ApplicationController
  
  def home
  end

  def index
    render json: User.order(:first_name)
  end

  def create
    params = beer_params
    params[:creator] = User.first
    
    Beer.create! params
    render json: User.order(:first_name)
  end

  private

  def beer_params
    params.require(:beer).permit(:amount, :user_id)
  end
end
