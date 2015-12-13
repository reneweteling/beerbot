class BeersController < ApplicationController
  
  def home
  end

  def index
    render json: { users: User.order(:first_name), stats: Stats::user }
  end

  def create
    params = beer_params
    params[:creator] = User.first
    
    Beer.create! params
    render action: :index
  end

  private

  def beer_params
    params.require(:beer).permit(:amount, :user_id)
  end
end
