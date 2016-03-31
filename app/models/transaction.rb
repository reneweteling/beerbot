class Transaction < ActiveRecord::Base
  belongs_to :user
  
  after_save :update_user_transaction_total
  after_create :add_beer

  scope :balance, -> { where(paid: false) }
  
  private

  def update_user_transaction_total
    user.transaction_total = user.transactions.balance.sum(:money)
    user.save!
  end

  def add_beer
    Beer.create!(user: user, amount: amount)
  end

end
