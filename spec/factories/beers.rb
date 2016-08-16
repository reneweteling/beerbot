FactoryGirl.define do
  factory :beer do
  	user
    amount { rand(10...1000) }
  end
end
