FactoryGirl.define do
  factory :user do
    first_name { (0...8).map { ('a'..'z').to_a[rand(26)] }.join }
    last_name { (0...8).map { ('a'..'z').to_a[rand(26)] }.join }
    slack_username { (0...8).map { ('a'..'z').to_a[rand(26)] }.join }
    beer_consumed { rand(10...1000) }
    beer_bought { rand(10...1000) }
    beer_total { rand(10...1000) }
    email { "#{first_name}#{last_name}@example.com" }
    authentication_token { SecureRandom.base64(32) }
    transaction_total { rand(11.2...76.9) }
    password 'password'
    password_confirmation 'password'
  end
end
