class BeersController < ApplicationController
  
  def index
    render json: User.all
  end

  def create
    params = beer_params
    params[:creator] = User.first
    
    Beer.create! params
    render json: User.all
  end

  private

  def beer_params
    params.require(:beer).permit(:amount, :user_id)
  end
end
