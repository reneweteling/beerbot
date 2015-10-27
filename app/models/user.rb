class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable
  has_many :beers

  def update_counters
    self.beer_bought = beers.bought.sum(:amount)
    self.beer_consumed = -1 * beers.consumed.sum(:amount)
    self.beer_total = beer_bought - beer_consumed
    save!
  end
end
