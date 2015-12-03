class Beer < ActiveRecord::Base
  belongs_to :user
  belongs_to :creator, :class_name => 'User'
  
  after_destroy :update_user_counters
  after_save :update_user_counters

  scope :bought, -> { where("amount > 0") }
  scope :consumed, -> { where("amount < 0") }

  after_create :track

  def update_user_counters
    user.update_counters
  end

  private

  def track
    Appsignal.increment_counter 'beers'
  end

end
