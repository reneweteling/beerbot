class BeersController < ApplicationController
  
  def home
  end

  def index
    stats = Beer.bought.joins(:user)
      .select("users.first_name, SUM(beers.amount) as total, DATE(beers.created_at)")
      .group("users.first_name, DATE(beers.created_at)")
      .order("DATE(beers.created_at)")
      
    render json: { users: User.order(:first_name), stats: stats }
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
