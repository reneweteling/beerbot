class User < ActiveRecord::Base
  devise :database_authenticatable, :validatable

  has_many :beers, dependent: :destroy
  
  validates :password, :password_confirmation, presence: true, on: :create
  validates :password, confirmation: true

  def to_s
    first_name
  end

  def update_counters
    self.beer_bought = beers.bought.sum(:amount)
    self.beer_consumed = -1 * beers.consumed.sum(:amount)
    self.beer_total = beer_bought - beer_consumed
    save!
  end
end
