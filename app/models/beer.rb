class Beer < ActiveRecord::Base
  belongs_to :user
  belongs_to :creator, :class_name => 'User'
end
